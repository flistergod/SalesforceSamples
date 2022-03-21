public without sharing class SWAN_BatchGenerateCSVHedgAndForecast implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts{
    
    private static final Integer MAX_FILE_SIZE = 12000000; //Likely will need to change value to something lower due to heap size limit - 12MB (batchable is Async)
    Segment_Values__c segmentVal = Segment_Values__c.getOrgDefaults();
    static final String NUL = '';
    static final String SEP = '","';
    private String fileName;
    private Integer numberOfFiles = 0;
    Integer totalRecordCount = 0;
    String csv = '';
    
    Map<Id,DateTime> contractIdToSignedDate = new  Map<Id,DateTime>();

    public SWAN_BatchGenerateCSVHedgAndForecast() {
        Integer randomNumber = Integer.valueof(Math.round((Math.random() * (9000000) + 1000000)));
        fileName = 'WINS_'+randomNumber+'_'+DateTime.now().format('YYYYMMddHHmm')+'.csv'; 
        numberOfFiles = 0;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
                        
        List<String> contractIds = new List<String>(); 
        Datetime dt1 = system.now().addMonths(-4);
        Map<Id,DateTime> quoteIdToSignedDate = new Map<Id,DateTime>();
        Set<String> cliIdForDeDuplicate = new set<String>();
      
        List<SWAN_Custom_Report__c> custList = [Select id,createdDate  from SWAN_Custom_Report__c where SWAN_Report_Type__c = 'HnF Report' order by createdDate desc limit 1];
        if(!custList.isEmpty())
        {
            dt1 = custList[0].createdDate;
        }
    //system.debug('conHist=='+[SELECT id, ContractId,newValue , createdDate 
      //                                  FROM ContractHistory]);
        for(Contract  con : [SELECT id, SWAN_Signed_Date__c,status 
                                        FROM Contract 
                                        WHERE SWAN_Signed_Date__c != null AND SWAN_Signed_Date__c >= : dt1  AND vlocity_cmt__QuoteId__r.SWAN_Quote_for_Fuel_Type__c = 'Electricity']){

            if((con.SWAN_Signed_Date__c != null && !contractIdToSignedDate.containsKey(con.Id) && con.Status != 'Contract Cancelled') || test.isRunningTest()){
                contractIdToSignedDate.put(con.Id,con.SWAN_Signed_Date__c);
                contractIds.add(con.Id);
            }
        }

        //Scenario 2
        //original filter :New_Status__c ='Accepted' AND createdDate >: System.today() AND createdDate <= : dt1 AND SWAN_Quote__r.SWAN_Quote_for_Fuel_Type__c = 'Electricity'
        for(SWAN_Quote_Status_Tracking__c qtStatTrack : [SELECT id,SWAN_Quote__c, createdDate 
                                                         FROM SWAN_Quote_Status_Tracking__c 
                                                         WHERE New_Status__c ='Accepted' 
                                                         AND createdDate >: dt1 AND SWAN_Quote__r.SWAN_Quote_for_Fuel_Type__c = 'Electricity']){

            quoteIdToSignedDate.put(qtStatTrack.SWAN_Quote__c,qtStatTrack.createdDate);
        } 

        return Database.getQueryLocator([SELECT id, 
                                                vlocity_cmt__ContractId__c,vlocity_cmt__ContractId__r.Status, 
                                                SWAN_Service_Point__c,vlocity_cmt__LineStatus__c,
                                                SWAN_Service_Point__r.vlocity_cmt__ServicePointNumber__c,
                                                SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.recordType.Name,
                                                SWAN_Quote__C,SWAN_Quote__r.swan_JSONAttribute__c,
                                                SWAN_Quote__r.SWAN_NeedToReset__c,
                                                vlocity_cmt__EffectiveStartDate__c, 
                                                vlocity_cmt__EffectiveEndDate__c,
                                                vlocity_cmt__ContractId__r.Account.Name,
                                                vlocity_cmt__ContractId__r.AccountId,
                                                SWAN_Service_Point__r.SWAN_Measurement_Class__c,
                                                SWAN_Service_Point__r.SWAN_Measurement_Class_Ovrd__c,
                                                SWAN_Service_Point__r.SWAN_Profile_Class__c,
                                                SWAN_Service_Point__r.SWAN_Profile_Class_Ovrd__c,
                                                SWAN_Service_Point__r.SWAN_Meter_Time_Switch_Code__c,
                                                SWAN_Service_Point__r.SWAN_Meter_Time_switch_Class_Ovrd__c,
                                                SWAN_Service_Point__r.SWAN_Line_Loss_Factor_Class__c,
                                                SWAN_Service_Point__r.SWAN_Line_Loss_Factor_Class_Ovrd__c,
                                                SWAN_Service_Point__r.SWAN_energisation_status__c,
                                                SWAN_Service_Point__r.SWAN_Grid_Supply_Point__c,
                                                SWAN_Service_Point__r.SWAN_Grid_Supply_Point_Group_Id_Ovrd__c,
                                                vlocity_cmt__ContractId__r.ContractNumber,
                                                vlocity_cmt__ContractId__r.Account.SWAN_Customer_Segment__c,
                                                SWAN_Service_Point__r.SWAN_distributor_mpid__c,
                                                SWAN_Service_Point__r.SWAN_Distributor_Id__c,
                                                SWAN_Service_Point__r.SWAN_Distributor_ID_Ovrd__c,
                                                SWAN_Service_Point__r.SWAN_Standard_Settlement_Configuration__c,
                                                SWAN_Quote__r.Annual_Volume__c,
                                                SWAN_Quote__r.SWAN_Parent_Quote__r.SWAN_Quote_Type__c,
                                                SWAN_Service_Point__r.SWAN_Standard_Settlement_Config_Ovrd__c
                                         FROM vlocity_cmt__ContractLineItem__c 
                                         WHERE ( vlocity_cmt__ContractId__c in :contractIds 
                                                OR SWAN_Quote__c in : quoteIdToSignedDate.keyset() ) 
                                         AND vlocity_cmt__Product2Id__r.name = null 
                                         AND SWAN_Quote__c != null
                                         AND SWAN_Service_Point__c != null]);
    }
    
    public void execute(Database.BatchableContext BC, List<vlocity_cmt__ContractLineItem__c> cliLst){
        
        Integer recordCount = 0;
        Set<Id> ContractLineItemIds = new Set<Id>();
        //String csv = '';
                

        for(vlocity_cmt__ContractLineItem__c cli : cliLst){

            if(!ContractLineItemIds.contains(cli.Id)){
        if(cli.vlocity_cmt__ContractId__r.Status != 'Contract Cancelled' && cli.vlocity_cmt__LineStatus__c != 'Cancelled'){
                csv=csv+getRow(cli,'gorilla');  
               // csvSAP = csvSAP+getRow(cli,'SAP');              
                ContractLineItemIds.add(cli.id);
                recordCount++;
                totalRecordCount++;
        }
            }
        }
        writeFileAttachment(csv, fileName,recordCount);
    }
    
    public void finish(Database.BatchableContext BC){

        Attachment latestAttachment = getLatestAttachment(fileName);
        Map<String, Object> ipInput = new Map<String, Object>();
        ipInput.put('FileName',fileName);
        
        if(latestAttachment != null && totalRecordCount > 0){
            String headerSAP =getHeaderColumns();
            uploadCSVtoSAPCPI(fileName, headerSAP.toUpperCase()+ csv);
            CallIPService('BG-H&FReporting_DataComponent',ipInput);

            //Integer csvSize = totalRecordCount;
          //  latestAttachment.Body=Blob.valueOf(latestAttachment.Body.toString() + csvSize);
          
          //  latestAttachment.Name= latestAttachment.Name.removeEnd('.csv')+' - Last File'+'.csv';
           // update latestAttachment;
           
        }
        else
        {
           string csvdummy = '';
           writeFileAttachment(csvdummy, fileName,totalRecordCount);
        }
        
    }
    private String getHeaderColumns(){
       String  headerColumn =    '"' +
                                'supplier'            + SEP +
                                'mpan'                + SEP +
                                'last_updated'        + SEP +
                                'customer_name'       + SEP +
                                'site_name'           + SEP +
                                'customer_no'         + SEP +
                                'hh'                  + SEP +
                                'regstatus'           + SEP +
                                'win_start_date'      + SEP +
                                'win_end_date'        + SEP +
                                'profile_class'       + SEP +
                                'mtc'                 + SEP +
                                'llf'                 + SEP +
                                'energisation_status' + SEP +
                                'measurement_class'   + SEP +
                                'gsp_group'           + SEP +
                                'contract_id'         + SEP +
                                'contract_type'       + SEP +
                                'customer_type'       + SEP +
                                'product_type'        + SEP +
                                'estimated_eac'       + SEP +
                                'distributor'         + SEP +
                                'dno'                 + SEP +
                                'ssc'                 + SEP +
                                'customer_eac'        + SEP +
                                'meter_usage'+'"\r\n';
        return headerColumn;
    }
    private String getRow( vlocity_cmt__ContractLineItem__c cli,String csvType){
        Map<String, String> measurementClassOvrd = new Map<String, String>{'A' => 'N', 'B' => 'N', 'C' => 'H', 'D' => 'H','E' => 'H', 'F' => 'H','G' => 'H'};
        String measurementClass  = (cli.SWAN_Service_Point__r.SWAN_Measurement_Class_Ovrd__c == null ? cli.SWAN_Service_Point__r.SWAN_Measurement_Class__c : cli.SWAN_Service_Point__r.SWAN_Measurement_Class_Ovrd__c );
        Double custEAC = null;
        Integer dno = Integer.valueOf( (cli.SWAN_Service_Point__r.SWAN_Distributor_ID_Ovrd__c == null ? cli.SWAN_Service_Point__r.SWAN_Distributor_Id__c : cli.SWAN_Service_Point__r.SWAN_Distributor_ID_Ovrd__c) );
          if(!String.isblank(cli.SWAN_Quote__r.SWAN_JSONAttribute__c) && cli.SWAN_Quote__r.SWAN_NeedToReset__c)
            {
                Map<string,object> AttributeMap = new Map<string,object>();
                for(object Attr : (List<object>) ((Map<String, Object>)JSON.deserializeUntyped(cli.SWAN_Quote__r.SWAN_JSONAttribute__c)).get('SWAN_SP_ATT_CAT'))
                {
                    String key = (string) ((map<string,object>)Attr).get('attributeuniquecode__c');
                    if(key == 'SWAN_ATT_CUST_EAC')
                    {
                       custEAC = Double.valueOf(((MAP<string,object>)((map<string,object>)Attr).get('attributeRunTimeInfo')).get('value'));
                    }
                }
            }
        String row = '"' + 
                    'ENRD'+ SEP +
                    cli.SWAN_Service_Point__r.vlocity_cmt__ServicePointNumber__c + SEP +
                    (csvType == 'gorilla' ? contractIdToSignedDate.get(cli.vlocity_cmt__ContractId__c).format('yyyy-MM-dd hh:mm:ss') : contractIdToSignedDate.get(cli.vlocity_cmt__ContractId__c).format('dd/MM/yyyy hh:mm:ss'))  + SEP +
                    cli.vlocity_cmt__ContractId__r.Account.Name + SEP +
                    cli.vlocity_cmt__ContractId__r.Account.Name + SEP +
                    cli.vlocity_cmt__ContractId__r.AccountId + SEP +
                    measurementClassOvrd.get(measurementClass) + SEP +
                    'WIN' + SEP +
                    (csvType == 'gorilla' ? cli.vlocity_cmt__EffectiveStartDate__c.format('yyyy-MM-dd') : cli.vlocity_cmt__EffectiveStartDate__c.format('dd/MM/yyyy')) + SEP +
                    (csvType == 'gorilla' ? cli.vlocity_cmt__EffectiveEndDate__c.format('yyyy-MM-dd') : cli.vlocity_cmt__EffectiveEndDate__c.format('dd/MM/yyyy')) + SEP +
                    (cli.SWAN_Service_Point__r.SWAN_Profile_Class_Ovrd__c == null ? cli.SWAN_Service_Point__r.SWAN_Profile_Class__c : cli.SWAN_Service_Point__r.SWAN_Profile_Class_Ovrd__c) + SEP +
                    (cli.SWAN_Service_Point__r.SWAN_Meter_Time_switch_Class_Ovrd__c == null ? cli.SWAN_Service_Point__r.SWAN_Meter_Time_Switch_Code__c : cli.SWAN_Service_Point__r.SWAN_Meter_Time_switch_Class_Ovrd__c) + SEP + 
                    (cli.SWAN_Service_Point__r.SWAN_Line_Loss_Factor_Class_Ovrd__c == null ? cli.SWAN_Service_Point__r.SWAN_Line_Loss_Factor_Class__c : cli.SWAN_Service_Point__r.SWAN_Line_Loss_Factor_Class_Ovrd__c) + SEP + 
                    cli.SWAN_Service_Point__r.SWAN_energisation_status__c + SEP + 
                    measurementClass + SEP + 
                    (cli.SWAN_Service_Point__r.SWAN_Grid_Supply_Point_Group_Id_Ovrd__c == null ? cli.SWAN_Service_Point__r.SWAN_Grid_Supply_Point__c : cli.SWAN_Service_Point__r.SWAN_Grid_Supply_Point_Group_Id_Ovrd__c) + SEP + 
                    cli.vlocity_cmt__ContractId__r.ContractNumber + SEP + 
                    'Contract' + SEP + 
                    cli.vlocity_cmt__ContractId__r.Account.SWAN_Customer_Segment__c + SEP +
                    (cli.SWAN_Quote__r.SWAN_Parent_Quote__r.SWAN_Quote_Type__c.Startswithignorecase('Flex') ? 'Flexible' : 'Fixed') + SEP + 
                    cli.SWAN_Quote__r.Annual_Volume__c + SEP +
                    cli.SWAN_Service_Point__r.SWAN_distributor_mpid__c + SEP +
                    dno + SEP +
                    (cli.SWAN_Service_Point__r.SWAN_Standard_Settlement_Config_Ovrd__c == null ? cli.SWAN_Service_Point__r.SWAN_Standard_Settlement_Configuration__c : cli.SWAN_Service_Point__r.SWAN_Standard_Settlement_Config_Ovrd__c) + SEP +
                    custEAC+ SEP + '' +
                    '"\r\n';
                    
        return row;
    }
    
    private void writeFileAttachment(String csvD, String ff, Integer recordCount){
        Attachment latestAttachment = getLatestAttachment(fileName);
        if(latestAttachment == null){
            String header =getHeaderColumns();
            createAttachment((header + csvD), fileName);
        }else{
            if(latestAttachment.BodyLength+csvD.length() < MAX_FILE_SIZE){
                latestAttachment.Body=Blob.valueOf(latestAttachment.Body.toString() + csvD);
                update latestAttachment;
            }else{
                Integer csvSize = totalRecordCount - recordCount;
                String header =getHeaderColumns();
                totalRecordCount = recordCount;
                latestAttachment.Body=Blob.valueOf(latestAttachment.Body.toString() + csvSize);
                latestAttachment.Name = latestAttachment.Name.removeEnd('.csv')+' - File ' + (++numberOfFiles) + '.csv';
                update latestAttachment;
                createAttachment((header + csvD), fileName);
            }
        }
    }

    private Attachment getLatestAttachment(String ff){
        string fname = fileName.removeEnd('.csv')+'%';
        List<Attachment> lstAttachments = [SELECT id, Name, ParentId, OwnerId, Body, BodyLength FROM Attachment WHERE Name Like :fname ORDER BY CreatedDate DESC];
    
        if(lstAttachments.size() == 0){
            return null;
        }else {
            return lstAttachments.get(0);
        }
    }
    
    private void createAttachment(String csv1, String ff){
        //csv = header+'\r\n' + csv;
        SWAN_Custom_Report__c atlasReport = new SWAN_Custom_Report__c(Name = fileName, SWAN_Report_Type__c = 'HnF Report');
        if (Schema.sObjectType.SWAN_Custom_Report__c.isCreateable()){
            insert atlasReport; 
        }
        
        try{
            if(Schema.sObjectType.Attachment.fields.Body.isCreateable()){
                insert new Attachment(Name = fileName, 
                                      ParentId = atlasReport.Id, 
                                      Body = Blob.valueOf(csv1)); 
            }
        }catch(Exception e){
            System.debug(e.getMessage());
        }       
    }
   
    private void uploadCSVtoSAPCPI(String fileName, String SAPBody){

        ECOE_Service__mdt  credSapCPI = [SELECT ECOES_Grant_Type__c,  
                                                ECOES_Secret__c, ECOS_Client_ID__c, 
                                                Label 
                                         FROM ECOE_Service__mdt Where Label='IntegrationEnvironmentSAPCPI'];  
        // request token
        HttpRequest reqToken = new HttpRequest();
        reqToken.setEndpoint('callout:SAPCPIToken');
        reqToken.setMethod('POST');
        reqToken.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        reqToken.setBody('client_id='+ credSapCPI.ECOS_Client_ID__c + '&client_secret=' + credSapCPI.ECOES_Secret__c+'&grant_type=' + credSapCPI.ECOES_Grant_Type__c);
        Http http = new Http();
        HTTPResponse resToken = new HTTPResponse();
        if(!test.isRunningTest())
        resToken = http.send(reqToken);
        else
            resToken.setBody('{"access_token":"12343"}');

        Map<String, String>  token = (Map<String, String>)json.deserialize(resToken.getBody(), Map<String, String>.class);
        
        //upload file 
        HttpRequest reqUploadFile = new HttpRequest();
        reqUploadFile.setEndpoint('callout:SAPCPIUploadCSV');
        reqUploadFile.setMethod('POST');
        reqUploadFile.setHeader('Authorization', 'Bearer ' + token.get('access_token') );
       
        Map<String, Object> mapBody = new Map<String, Object>();
        Map<String, String> mapPayLoad = new Map<String, String>{'payload' => SAPBody };
        //system.debug('String.valueOf(mapPayLoad) ' + String.valueOf(mapPayLoad) );
        mapBody.put('FileContent',mapPayLoad);
        mapBody.put('filename', fileName );
        reqUploadFile.setBody(JSON.serialize(mapBody));
        Http httpUploadFile = new Http();
        //system.debug('JSON.serialize(mapBody) ' + JSON.serialize(mapBody) );
        system.debug('reqUploadFile ' + reqUploadFile );
        if(!test.isRunningTest()){
        HTTPResponse resUploadFile = httpUploadFile.send(reqUploadFile);
       if(resUploadFile.getStatusCode() == 202){system.debug('File ' + fileName  + ' upload into SAP CPI');
        }else{system.debug('File  ' + fileName  + ' NOT upload into SAP CPI');}}
        
    }
    
    private static boolean CallIPService(string IPname,Map<String, Object> ipInput) {
        
        Map<String, Object> ipOutput = new Map<String, Object> ();
                
        /* Call the IP via runIntegrationService, 
        and save the output to ipOutput */
        try{
            ipOutput = (Map<String, Object>) vlocity_cmt.IntegrationProcedureService.runIntegrationService(IPname, ipInput, new Map<String, Object>());
            system.debug('OUT#######>>>\n'+ipOutput );
            return true;
        }
        catch(Exception ex)
        {
            system.debug('===>'+ex);
            return false;
        }
    }

}