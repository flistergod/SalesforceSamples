public without sharing class SWAN_BatchGenerateCSVForAtlas implements Database.Batchable<sObject>, Database.Stateful{
    
    private static final Integer MAX_FILE_SIZE = 12000000; //Likely will need to change value to something lower due to heap size limit - 12MB (batchable is Async)
    List<String> statusList = new List<String> {'Contract Signed', 'Contract Counter Signed', 'Contract Live'};
    Segment_Values__c segmentVal = Segment_Values__c.getOrgDefaults();
    static final String NUL = '';
    static final String SEP = ',';
    private String fileName;
    private Integer numberOfFiles = 0;
    Integer totalRecordCount = 0;
    
    public SWAN_BatchGenerateCSVForAtlas() {
        fileName = 'BGB_Cust_Data_ISS_'+DateTime.now().format('YYYYMMddHHmmss')+'.csv'; 
        numberOfFiles = 0;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT id, vlocity_cmt__ContractId__c, vlocity_cmt__LineStatus__c, 
        SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.Name,SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.QuoteNumber,SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.SWAN_Quote_Type__c,
        vlocity_cmt__ContractId__r.vlocity_cmt__QuoteId__r.vlocity_cmt__PriceListId__c, 
        vlocity_cmt__ContractId__r.vlocity_cmt__QuoteId__r.vlocity_cmt__PriceListId__r.Name,
        SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.SWAN_Offer_Start_Date__c,vlocity_cmt__ContractId__r.Account.Name, 
        vlocity_cmt__ContractId__r.vlocity_cmt__OpportunityId__r.RecordType.Name,
        vlocity_cmt__ContractId__r.vlocity_cmt__OpportunityId__c, SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.recordtype.name,
        SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.SWAN_Service_Point_End_Date__c, SWAN_Quote__c,SWAN_Quote__r.Name,
        SWAN_Quote__r.vlocity_cmt__DefaultServicePointId__c,SWAN_Quote__r.recordType.Name,
        SWAN_Quote__r.SWAN_Service_Point_Start_Date__c,SWAN_Quote__r.SWAN_Service_Point_End_Date__c, 
        SWAN_Quote__r.vlocity_cmt__ParentQuoteId__c,SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.SWAN_Site_Addition_Parent__c,
        SWAN_Service_Point__c, vlocity_cmt__EffectiveStartDate__c, vlocity_cmt__EffectiveEndDate__c
        FROM vlocity_cmt__ContractLineItem__c where vlocity_cmt__ContractId__r.Status in :statusList and 
        vlocity_cmt__Product2Id__r.name = null and SWAN_Quote__c != null and SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.SWAN_Quote_for_Fuel_Type__c = 'Gas' AND SWAN_Service_Point__c != null]);
    }
    
    public void execute(Database.BatchableContext BC, List<vlocity_cmt__ContractLineItem__c> cliList){
        
        String csv ='';
        Integer recordCount = 0;
        Set<Id> contractIds = new Set<Id>();
        Set<Id> quoteQLI = new Set<Id>();
        List<id> servicePointIds = new List<id>();
        Set<Id> siteAdditionQuoteIds = new Set<Id>();
        for(vlocity_cmt__ContractLineItem__c cli : cliList) {
            contractIds.add(cli.vlocity_cmt__ContractId__c);
            servicePointIds.add(cli.SWAN_Service_Point__c);
            quoteQLI.add(cli.SWAN_Quote__c);
            if(cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.recordType.Name.containsIgnoreCase('Site Addition'))
                siteAdditionQuoteIds.add(cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__c);
        }
        
        Map<Id,DateTime> contractIdToSignedDate = new Map<Id,DateTime>();
        for(ContractHistory conHist : [SELECT ContractId,CreatedById,CreatedDate,Field,Id,IsDeleted,NewValue,OldValue FROM ContractHistory 
            WHERE ContractId IN :contractIds AND Field = 'Status' ORDER BY CreatedDate DESC]){
            if(conHist.NewValue == 'Contract Signed' && !contractIdToSignedDate.containsKey(conHist.ContractId))
                contractIdToSignedDate.put(conHist.ContractId,conHist.CreatedDate);
        } 
        
        Map<Id,DateTime> quoteIdToSignedDate = new Map<Id,DateTime>();
        for(SWAN_Quote_Status_Tracking__c qtStatTrack : [select id,SWAN_Quote__c, createdDate from SWAN_Quote_Status_Tracking__c where New_Status__c ='Accepted' AND SWAN_Quote__c IN :siteAdditionQuoteIds]) {
          quoteIdToSignedDate.put(qtStatTrack.SWAN_Quote__c,qtStatTrack.createdDate);
        } 
        
        Map<id,vlocity_cmt__ServicePoint__c> servicePointMap = new Map<id,vlocity_cmt__ServicePoint__c>(
            [SELECT id,Name,SWAN_Supply_Offtake_Quantity__c,SWAN_Exit_Zone__c,SWAN_End_User_Category_Code__c,SWAN_Local_Distribution_Zone__c,vlocity_cmt__ServicePointNumber__c,SWAN_Formula_Year_Annual_Quantity__c,Annual_Quantity__c,SWAN_Product_Class__c,vlocity_cmt__PremisesId__c,SWAN_Formula_Year_Offtake_Quantity__c, SWAN_End_Date__c 
                    FROM vlocity_cmt__ServicePoint__c WHERE id IN :servicePointIds]);
        
        Map<id,vlocity_cmt__ContractLineItem__c> contractIdToCLI = new Map<id,vlocity_cmt__ContractLineItem__c>();
        for(vlocity_cmt__ContractLineItem__c cli:[SELECT Id, vlocity_cmt__OriginalLineItemId__c, vlocity_cmt__Product2Id__r.Name, SWAN_Service_Point__c, vlocity_cmt__EffectiveStartDate__c, 
            vlocity_cmt__ContractId__c, vlocity_cmt__ContractId__r.Status, vlocity_cmt__EffectiveEndDate__c, vlocity_cmt__LineStatus__c, SWAN_Service_Point_End_Date__c, 
            vlocity_cmt__ProductCode__c, vlocity_cmt__ContractId__r.vlocity_cmt__QuoteId__c FROM vlocity_cmt__ContractLineItem__c 
            WHERE vlocity_cmt__ContractId__c IN :contractIds and vlocity_cmt__OriginalLineItemId__c != null and vlocity_cmt__Product2Id__c != null and vlocity_cmt__Product2Id__r.vlocity_cmt__IsOrderable__c=true])
        {
            if(!contractIdToCLI.containskey(cli.vlocity_cmt__OriginalLineItemId__c))
                contractIdToCLI.put(cli.vlocity_cmt__OriginalLineItemId__c, cli);
        }
        
        //
        //String nowString = Datetime.now().format('YYYYMMddHHmmss');
        //system.debug(nowString);
        //String header = 'ISS' + SEP +nowString;
        //csv = header+'\r\n';
        JSON2Apex jj = new JSON2Apex();
        Map<Id,List<JSON2Apex.SWAN_SP_ATT_CAT>> map_sp_Wrapper = new Map<Id,List<JSON2Apex.SWAN_SP_ATT_CAT>>();
        for(QuoteLineItem qli : [SELECT id,Quote.Name,Quote.vlocity_cmt__DefaultServicePointId__c,Product2.Name,vlocity_cmt__JSONAttribute__c FROM QuoteLineItem where QuoteId IN :quoteQLI and Product2.vlocity_cmt__IsOrderable__c =true]) {
            String json = (String)qli.vlocity_cmt__JSONAttribute__c;
            if(String.IsNotBlank(json))
            {       
                jj = JSON2Apex.parse(json);       
                map_sp_Wrapper.put(qli.Quote.vlocity_cmt__DefaultServicePointId__c,jj.SWAN_SP_ATT_CAT);
            }
        } 
           
        for(vlocity_cmt__ContractLineItem__c cli : cliList) {
            // 
            Boolean isRenewal = false;
            Boolean isUpgrade = false;
            Boolean isSiteAddition = false;
            if(cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.recordType.Name.containsIgnoreCase('Site Addition')){
                isRenewal = false;
                isUpgrade = false;
                isSiteAddition = true;
            }else if(cli.vlocity_cmt__ContractId__r.vlocity_cmt__OpportunityId__c != null && cli.vlocity_cmt__ContractId__r.vlocity_cmt__OpportunityId__r.RecordType.Name.containsIgnoreCase('Renewal')){
                isRenewal = true;
                isUpgrade = false;
                isSiteAddition = false; 
            }else if(cli.vlocity_cmt__ContractId__r.vlocity_cmt__OpportunityId__c != null && cli.vlocity_cmt__ContractId__r.vlocity_cmt__OpportunityId__r.RecordType.Name.containsIgnoreCase('Upgrade')){
                isRenewal = false;
                isUpgrade = true;
                isSiteAddition = false;
                
            }else{
                isRenewal = false;
                isUpgrade = false;
                isSiteAddition = false;

            }
            
            //
            vlocity_cmt__ServicePoint__c servicePoint = servicePointMap.get(cli.SWAN_Service_Point__c);
            if((isRenewal || isUpgrade) && cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.SWAN_Service_Point_End_Date__c < System.now().date()){
                continue;
            }else if(isSiteAddition && servicePoint.SWAN_End_Date__c < System.now().date()){
                continue;
            }
            
            //
            String meterType = '';
            Integer durationDays = cli.SWAN_Quote__r.SWAN_Service_Point_Start_Date__c.daysBetween(cli.SWAN_Quote__r.SWAN_Service_Point_End_Date__c)+1;
            DateTime startDateTime = cli.SWAN_Quote__r.SWAN_Service_Point_Start_Date__c;
            DateTime endDateTime = cli.SWAN_Quote__r.SWAN_Service_Point_End_Date__c;
            String startDate = startDateTime.format('YYYYMMdd');
            String endDate = endDateTime.format('YYYYMMdd');
            if((isRenewal || isUpgrade) || (!isRenewal && !isUpgrade && !isSiteAddition) || isSiteAddition) {
                if(cli.vlocity_cmt__LineStatus__c == 'Terminated' || cli.vlocity_cmt__LineStatus__c == 'Cancelled')
                    continue;
                else {
                    durationDays = ((cli.vlocity_cmt__EffectiveStartDate__c != null && cli.vlocity_cmt__EffectiveEndDate__c != null)?Date.valueOf(cli.vlocity_cmt__EffectiveStartDate__c).daysBetween(Date.valueof(cli.vlocity_cmt__EffectiveEndDate__c))+1:0);
                    startDate = (cli.vlocity_cmt__EffectiveStartDate__c != null?cli.vlocity_cmt__EffectiveStartDate__c.format('YYYYMMdd'):'');
                    endDate = (cli.vlocity_cmt__EffectiveEndDate__c != null?cli.vlocity_cmt__EffectiveEndDate__c.format('YYYYMMdd'):'');
                }
            }
            
            //
            String dateSigned = '';
            if(contractIdToSignedDate.containskey(cli.vlocity_cmt__ContractId__c)){
                DateTime signedDateTime = contractIdToSignedDate.get(cli.vlocity_cmt__ContractId__c);
                dateSigned = signedDateTime.format('dd/MM/YYYY HH:mm:ss');
            }
            
            // Populate segment for master quotes
            String segment='';
            if(cli.vlocity_cmt__ContractId__r.vlocity_cmt__QuoteId__r.vlocity_cmt__PriceListId__c != null)
            {
                if(cli.vlocity_cmt__ContractId__r.vlocity_cmt__QuoteId__r.vlocity_cmt__PriceListId__r.Name == label.Swan_Enterprise_Price_List)
                    segment = segmentVal.Enterprise_Segment__c;
                else if(cli.vlocity_cmt__ContractId__r.vlocity_cmt__QuoteId__r.vlocity_cmt__PriceListId__r.Name == label.Swan_I_C_Price_List)
                    segment = segmentVal.I_C_Segment__c;
            }
             
            //For a site addition the Execute Time column on the CSV needs to come from the time and date the quote was accepted
            if(isSiteAddition && quoteIdToSignedDate.containsKey(cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__c)) 
                dateSigned =  quoteIdToSignedDate.get(cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__c).format('dd/MM/YYYY HH:mm:ss');
            
            //
            if(servicePoint.SWAN_Product_Class__c == '1' || servicePoint.SWAN_Product_Class__c == '2'){
                meterType = 'DM';
            } else if (servicePoint.SWAN_Product_Class__c =='3' || servicePoint.SWAN_Product_Class__c == '4'){
                meterType = 'NDM';
            }
            
            String productName ='';
            if(contractIdToCLI.containskey(cli.Id)){
                productName = contractIdToCLI.get(cli.Id).vlocity_cmt__Product2Id__r.Name;
            }
            
            Boolean isCustAQnull = true;
            Boolean isCustSOQnull = true;
            String cust_SOQ ='';
            String cust_AQ ='';
            String cust_AQ_fromdate ='';
            String cust_AQ_todate ='';
            Date fromdate;
            Date todate;
            if(map_sp_Wrapper.containskey(cli.SWAN_Quote__r.vlocity_cmt__DefaultServicePointId__c))
            {   
                for(JSON2Apex.SWAN_SP_ATT_CAT qli_attb : map_sp_Wrapper.get(cli.SWAN_Quote__r.vlocity_cmt__DefaultServicePointId__c))
                {
                    if(String.IsNotBlank(String.valueOf(qli_attb)))
                    { 
                        if(qli_attb.attributedisplayname == 'Customer AQ Effective From Date')
                        {
                                
                                cust_AQ_fromdate = qli_attb.value;
                                //System.debug('cust_AQ_fromdate'+cust_AQ_fromdate);
                                if((String.IsNotBlank(cust_AQ_fromdate) && cust_AQ_fromdate != null && cust_AQ_fromdate != 'false' )){
                                    fromdate = Date.valueOf(cust_AQ_fromdate);
                                }
                                else 
                                {
                                    cust_AQ_fromdate = ''; //defaulting date to consider blank value in qli_attb for dates
                                    //fromdate = Date.valueOf(cust_AQ_fromdate);
                                }
                                //System.debug('fromdate'+fromdate);
                               
                        }
                            
                        if(qli_attb.attributedisplayname == 'Customer AQ Effective To Date')
                        {
                            
                                cust_AQ_todate = qli_attb.value;
                                //System.debug('cust_AQ_todate'+cust_AQ_todate);
                                if(String.IsNotBlank(cust_AQ_todate) && cust_AQ_todate != null && cust_AQ_todate != 'false' ){
                                todate = Date.valueOf(cust_AQ_todate);
                                }
                                else
                                {
                                    cust_AQ_todate = ''; //defaulting date to consider blank value in qli_attb for dates
                                    //todate = Date.valueOf(cust_AQ_todate);
                                }
                                //System.debug('todate'+todate);
                                  
                        }
                        
                        if(qli_attb.attributedisplayname == 'Customer AQ')
                        {
                            cust_AQ = qli_attb.value;
                            //System.debug('cust_AQ'+cust_AQ);
                        }   
                        
                        if(qli_attb.attributedisplayname == 'Customer SOQ')
                        {
                            cust_SOQ = qli_attb.value;
                            //System.debug('cust_SOQ'+cust_SOQ);
                        }   
                        
                        if((String.IsBlank(cust_AQ_fromdate) && String.IsBlank(cust_AQ_todate)) || (String.IsNotBlank(cust_AQ_fromdate) && String.IsBlank(cust_AQ_todate) && (isValidDateRangeFromDateNotBlank(fromdate,cli.SWAN_Quote__r.SWAN_Service_Point_End_Date__c)))|| (String.IsNotBlank(cust_AQ_todate) && String.IsBlank(cust_AQ_fromdate) && (isValidDateRangeToDateNotBlank(todate,cli.SWAN_Quote__r.SWAN_Service_Point_Start_Date__c)))|| (String.IsNotBlank(cust_AQ_fromdate) && String.IsNotBlank(cust_AQ_todate) && (isValidDateRangeFromDateNotBlank(fromdate,cli.SWAN_Quote__r.SWAN_Service_Point_End_Date__c)) && (isValidDateRangeToDateNotBlank(todate,cli.SWAN_Quote__r.SWAN_Service_Point_Start_Date__c))))
                        {
                            if(String.IsNotBlank(cust_AQ) && cust_AQ != 'false'  )
                            {
                                isCustAQnull = false;
                            }
                            else if(cust_AQ == null || cust_AQ =='')
                            {
                                isCustAQnull = true;
                            }
                            //System.debug('cust_AQ'+ cust_AQ);
                        
                            if(String.IsNotBlank(cust_SOQ)  && cust_SOQ != 'false' )
                            {
                                isCustSOQnull = false;
                            } 
                            else if(cust_SOQ == null || cust_SOQ =='')
                            {
                                isCustSOQnull = true;
                            }   
                            //System.debug('cust_SOQ'+ cust_SOQ);        
                        }
                    }   
                }
            }
            String quoteType;
			if(cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.SWAN_Quote_Type__c == 'Flex')
			{
				quoteType ='FLEXIBLE';
			}else{
				quoteType ='FIXED';
			}
            // create csv
            csv += cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.QuoteNumber + 
            SEP + NUL + 
            SEP + servicePoint.vlocity_cmt__PremisesId__c + 
            SEP + startDate + 
            SEP + endDate + 
            SEP + durationDays + 
            SEP + NUL + 
            SEP + NUL + 
            SEP + NUL + 
            SEP + '0' + 
            SEP + returnFieldvalueDecimal(servicePoint.SWAN_Formula_Year_Offtake_Quantity__c) ;
            
            if(isCustSOQnull){
                csv+= SEP + returnFieldvalueDecimal(servicePoint.SWAN_Formula_Year_Offtake_Quantity__c);
            } else {
                csv+= SEP + cust_SOQ;
            }
            
            csv+= SEP + NUL + 
            SEP + returnFieldValueString(servicePoint.SWAN_Exit_Zone__c) + 
            SEP + returnFieldValueString(servicePoint.SWAN_End_User_Category_Code__c) + 
            SEP + NUL + 
            SEP + returnFieldvalueDecimal(servicePoint.SWAN_Formula_Year_Annual_Quantity__c) + 
            SEP + 'Recorded in iPrice' + 
            SEP + quoteType + 
            SEP + 'INC' + 
            SEP + productName + 
            SEP + returnFieldValueString(servicePoint.SWAN_Local_Distribution_Zone__c) + 
            SEP + servicePoint.vlocity_cmt__ServicePointNumber__c + 
            SEP + meterType + 
            SEP + NUL + 
            SEP + servicePoint.vlocity_cmt__ServicePointNumber__c + 
            SEP + NUL + 
            SEP + NUL + 
            SEP + NUL + 
            SEP + 'INC' + 
            SEP + NUL + 
            SEP + 'N';
            
            if(isRenewal){
                csv+= SEP + 'RENEWAL';
            } else if(isSiteAddition){
                csv+= SEP + 'SITE ADDITION';
            } else if(isUpgrade){
                csv+= SEP + 'UPGRADE';
            } else{
                csv+= SEP + 'ACQUISITION';
            }

            if(isCustAQnull){
                csv+= SEP +  returnFieldvalueDecimal(servicePoint.SWAN_Formula_Year_Annual_Quantity__c);
            } else {
                csv+= SEP + cust_AQ;
            }
            
            csv+= SEP + returnFieldvalueDecimal(servicePoint.SWAN_Formula_Year_Annual_Quantity__c) + 
            SEP + segment + 
            SEP + NUL + 
            SEP + returnFieldvalueDecimal(servicePoint.Annual_Quantity__c) + 
            SEP + returnFieldValueString(servicePoint.SWAN_Product_Class__c) + 
            SEP + dateSigned + 
            SEP + cli.vlocity_cmt__ContractId__r.Account.Name + '\r\n';
            
            recordCount++;
            totalRecordCount++;
        }
        //csv += recordCount;
        
        writeFileAttachment(csv, fileName, recordCount);
    }
    
    public void finish(Database.BatchableContext BC){
        Attachment latestAttachment = getLatestAttachment(fileName);
        if(latestAttachment != null)
        {
            Integer csvSize = totalRecordCount;
            latestAttachment.Body=Blob.valueOf(latestAttachment.Body.toString() + csvSize);
            latestAttachment.Name= latestAttachment.Name.removeEnd('.csv')+' - Last File'+'.csv';
            update latestAttachment;
            //TO-DO: Create the task for running user
            Task userTask = new Task();
            userTask.OwnerId = latestAttachment.OwnerId;
            userTask.Subject = 'Atlas Report Ready';
            userTask.priority= 'Normal';
            userTask.status = 'Open';
            userTask.ActivityDate = System.Today();
            userTask.IsReminderSet=true;
            userTask.ReminderDateTime=system.now();
            insert userTask;
        }
    }
    
    private void writeFileAttachment(String csv, String ff, Integer recordCount){
        Attachment latestAttachment = getLatestAttachment(fileName);
        if(latestAttachment == null){
            createAttachment(csv, fileName);
        }else{
            if(latestAttachment.BodyLength+csv.length() < MAX_FILE_SIZE){
                latestAttachment.Body=Blob.valueOf(latestAttachment.Body.toString() + csv);
                update latestAttachment;
            }else{
                Integer csvSize = totalRecordCount - recordCount;
                totalRecordCount = recordCount;
                latestAttachment.Body=Blob.valueOf(latestAttachment.Body.toString() + csvSize);
                latestAttachment.Name = latestAttachment.Name.removeEnd('.csv')+' - File ' + (++numberOfFiles) + '.csv';
                update latestAttachment;
                createAttachment(csv, fileName);
            }
        }
    }

    private Attachment getLatestAttachment(String ff){
        string fname = fileName.removeEnd('.csv')+'%';
        List<Attachment> lstAttachments = [SELECT id, Name, ParentId, OwnerId, Body, BodyLength FROM Attachment WHERE Name Like :fname ORDER BY CreatedDate DESC];
        system.debug('lstAttachments: '+lstAttachments);
        if(lstAttachments.size() == 0){
            return null;
        }else {
            return lstAttachments.get(0);
        }
    }
    
    private void createAttachment(String csv, String ff){
        String header = 'ISS' + SEP + Datetime.now().format('YYYYMMddHHmmss');
        csv = header+'\r\n' + csv;
        SWAN_Custom_Report__c atlasReport = new SWAN_Custom_Report__c(Name = fileName, SWAN_Report_Type__c = 'ATLAS');
        if (Schema.sObjectType.SWAN_Custom_Report__c.isCreateable()){
            insert atlasReport; 
        }
        
        try{
            if(Schema.sObjectType.Attachment.fields.Body.isCreateable()){
                insert new Attachment(Name = fileName, 
                                      ParentId = atlasReport.Id, 
                                      Body = Blob.valueOf(csv)); 
            }
        }catch(Exception e){
            System.debug(e.getMessage());
        }       
    }
    
    public static String returnFieldvalueDecimal(Decimal fieldvalue){
        if (fieldvalue == null){
            return '';
        } else{
            return String.valueof(fieldvalue);
        }
    }
    
    public static String returnFieldValueString(String fieldvalue){
        if (string.isblank(fieldvalue)){
            return '';
        } else{
            return fieldvalue;
        }
    }
    
    public static Boolean isValidDateRangeFromDateNotBlank(Date d1,Date d2){
        Integer noofdays = d1.daysBetween(d2);
        if(noofdays >= 0)
        {
            return true;
        }
        else return false;
    }
    
    public static Boolean isValidDateRangeToDateNotBlank(Date d1,Date d2){
        Integer noofdays = d1.daysBetween(d2);
        if(noofdays <= 0)
        {
            return true;
        }
        else return false;
    }
}