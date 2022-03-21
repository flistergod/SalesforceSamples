global with sharing class AWSS3csvFileReader implements vlocity_cmt.VlocityOpenInterface {
    List<String> SPNumberList = new List<String>();
    global boolean exceptionOccur = false;
    global boolean statusUpdated = false;
    global Boolean invokeMethod(String methodName,
                                Map < String, Object > input,
                                Map < String, Object > output,
                                Map < String, Object > options) {
                                    
                                    system.debug('In AWSS3csvFileReader: ' + methodName);
                                    
                                    /* ************************************** ATTENTION ************************************** 
                                    DEVELOPMENT HELPER
                                    Curious on what is coming in the request? 
                                    Need to debug something on a VIP with callouts and DMLs?
                                    Need to check values?

                                    Uncomment for loop and run the call with a method that doesn't exist.
                                    Do set up debug logs so it's easier. 
                                    Remember to comment it again after it's no longer needed.
                                    Remember if doing it from a VIP, remove the Fail on Step checkbox so it doesn't break the execution
                                    
                                    */
                                    for(String s : input.keySet()){
                                        system.debug('KEY: '+s+' VALUE: '+input.get(s));
                                    }
                                    
                                    switch on methodName{
                                        when 'AWSReadcsvFile'{
                                            return AWSReadcsvFile(input, output, options);
                                        }
                                        when 'AWSReadcsvFileForContract'{
                                            return AWSReadcsvFileForContract(input, output, options);
                                        }
                                        when 'AWSReadcsvFileForVolumeSummary'{
                                            return AWSReadcsvFileForVolumeSummary(input, output, options);                                        
                                        }
                                        when 'AWSReadcsvFileMeterLevel'{
                                            return AWSReadcsvFileMeterLevel(input, output, options);
                                        }
                                        when 'AWSReadcsvFileMeterLevelElec'{
                                            return AWSReadcsvFileMeterLevelElec(input, output, options);
                                        }
                                        when 'AWSReadMDDResultFile'{
                                            return AWSReadMDDResultFile(input, output, options);
                                        }
                                        when 'AWSReadElectralinkResultFile'{
                                            return AWSReadElectralinkResultFile (input, output, options);
                                        }
                                        when 'GetDataComponentId'{
                                            return GetDataComponentId(input, output, options);
                                        }
                                        when 'processFlexSummary'{
                                            return processFlexQuoteSummary(input, output, options);
                                        }
                                    }
                                    
                                    return false;
                                }
    
    public Boolean GetDataComponentId (Map < String, Object > input,Map < String, Object > output,Map < String, Object > options) {
        String dataComponentId = '';
        try {
        Map<String,Object> ExtractData_OriginalMap = (Map<String,Object>)input.get('ExtractData_Original');
        String notificationMessage = (String)ExtractData_OriginalMap.get('NotifcationMessage');
        
        system.debug('==== :: '+notificationMessage);
        
        Map<String,Object> notificationMessageMap =  (Map<String,Object>)JSON.deserializeUntyped(notificationMessage);
        Map<String,Object> dataComponentMap = (Map<String,Object>)notificationMessageMap.get('metadata');
        
        system.debug('====notificationMessageMap:: '+ notificationMessageMap);
        
        dataComponentId = (String)dataComponentMap.get('datacomponent-id');
        string dataComponentVersion = (String)dataComponentMap.get('datacomponent-version-id');
        
        system.debug(dataComponentId);
        system.debug(output);
        system.debug(options);
        
        output.put('outputMapdataComponentId',dataComponentId);
        output.put('outputMapdataComponentVersion',dataComponentVersion);
        system.debug('outputMapdataComponentId: '+output.get('outputMapdataComponentId'));
        system.debug('outputMapdataComponentVersion: '+output.get('outputMapdataComponentVersion'));
        }catch(Exception ex) {
            system.debug('EXCEPTION==='+ex.getMessage());
        }

        return true;
    }
    
    public Boolean AWSReadMDDResultFile (Map < String, Object > input,Map < String, Object > output,Map < String, Object > options) {
        try{
    
            // Get inputs ***
            
            String filePath = (string)input.get('strUploadedCSVURL'); // Get File Name
            
            
            system.debug('AWSS3csvFileReader:AWSReadcsvFile UploadedCSVURL: ' + filePath);
            SWAN_Status_Log__c st = new SWAN_Status_Log__c();
            String dataCompId = (String)input.get('DataComponentId');
            String sCalculationId = (string)input.get('strCalculationId');
            if(!String.isBlank(sCalculationId)){
             st = [select id , swan_record_Id__c,OwnerId from SWAN_Status_Log__c where SWAN_WorkflowId__c = : sCalculationId limit 1];
            }
            Http httpreq = new Http();
            
            HttpRequest sRequest = new HttpRequest();
            sRequest.setMethod('GET');
            
            sRequest.setEndpoint(filePath);
            
            system.debug('AWSReadcsvFile Request: ' + sRequest);
            
            HTTPResponse sResponse = httpreq.send(sRequest);
            
            system.debug('AWSReadcsvFile Response Code: ' + sResponse);           
            system.debug('AWSReadcsvFile Response Body: ' + sResponse.getBody());
            
            if (sResponse.getStatusCode() == 200) {
                system.debug('AWSReadcsvFile extract data: ');
                String strUploadedCSVData = String.valueOf(sResponse.getBody());
                String[] sCSVLines = strUploadedCSVData.split('\n');
                if(sCSVLines.size() > 2000)
                {
                    SWAN_CSVUpload_MDD batchMdd = new SWAN_CSVUpload_MDD(sCSVLines,st.SWAN_Record_Id__c,st.ownerId);
                   database.executeBatch(batchMdd,2000);
                }
                else{
                    parseMDDFile(sCSVLines);
                    createTaskNotification(st.ownerId,st.SWAN_Record_Id__c,'Supply point upload/ MDD validation completed','Supply point upload/ MDD validation completed for related records.');
                    SWAN_Electralink_Connectors_Codes__c cs = SWAN_Electralink_Connectors_Codes__c.getOrgDefaults();
                    List<String> NHH_SP = new List<String>();
                    List<String> HH_SP = new List<String>();
                    List<vlocity_cmt__ServicePoint__c> splst_to_blank = new List<vlocity_cmt__ServicePoint__c>(); 
                    if(!SPNumberList.IsEmpty())
                    {
                        for(vlocity_cmt__ServicePoint__c SP : [select id,SWAN_Measurement_Class__c,SWAN_MDD_Combination_Supported__c,SWAN_HH_Number_of_days__c,SWAN_Total_EAC__c,SWAN_Electralink_Error_Message__c from vlocity_cmt__ServicePoint__c where vlocity_cmt__ServicePointNumber__c in :SPNumberList])
                        {
                            if(SP.SWAN_MDD_Combination_Supported__c){
                                if(SP.SWAN_Measurement_Class__c == 'A' || SP.SWAN_Measurement_Class__c == 'B')
                                {
                                    NHH_SP.add(SP.Id); 
                                }
                                else
                                {
                                    HH_SP.add(SP.Id);
                                }
                            }
                            //SP.SWAN_Electralink_Retrieval_Status__c = false;
                            SP.SWAN_Total_EAC__c = null;
                            SP.SWAN_Electralink_Error_Message__c = '';
                            SP.SWAN_HH_Number_of_days__c = null;
                            splst_to_blank.add(SP); 
                        }
                    update splst_to_blank;
                    if(!NHH_SP.IsEmpty())
                    {   
                        callElectralinkIP(NHH_SP,st.ownerId,st.SWAN_Record_Id__c,cs.NHH_Code__c);
                    }
                    if(!HH_SP.IsEmpty())
                    {callElectralinkIP(HH_SP,st.ownerId,st.SWAN_Record_Id__c,cs.HH_Code__c);}
                    }
                    
                  }
                
                
            }
        }
        catch(Exception e) {
            exceptionOccur = true;
            system.debug('AWSReadcsvFile Exception: ' + e.getMessage());
            system.debug('AWSReadcsvFile Exception: ' + e.getStackTraceString());
        }
        return true;
    }
    
    @future(callout=true)
    public static void callElectralinkIP(List<String> SPID,string userId ,String recordId,String code){
       
        CallElectralinkVIP.CallIPService('BG-Electralinkdata_BGGorillaElectralinkDataComponent',SPID,recordId,UserId,code);
    }  
    
    public void createTaskNotification(String userId , string recordid,String subject,String description)
    {
                Task notify = new Task();
                notify.OwnerId = UserId;
                notify.Subject = subject;
                notify.Status = 'Open';
                notify.Priority = 'High';
                notify.WhatId = recordid;
                notify.ActivityDate=date.today();
                notify.Description= description;
                notify.IsReminderSet=true;
                notify.ReminderDateTime=system.now();
                insert notify;
    }
    public void parseMDDFile(List<String> strUploadedCSVData){
        
            List<String> sCSVHeader = strUploadedCSVData[0].split(',');
            List<vlocity_cmt__ServicePoint__c> serPointList = new List<vlocity_cmt__ServicePoint__c>();
              system.debug('sCSVHeader='+sCSVHeader+' size='+sCSVHeader.size());
            for(Integer iMeterIndex = 1; iMeterIndex < strUploadedCSVData.size();iMeterIndex++){ // Loop CSV LINE
                String[] sCurrentMeterData = strUploadedCSVData[iMeterIndex].split(',');
                 vlocity_cmt__ServicePoint__c serPoin = new vlocity_cmt__ServicePoint__c();
                 for(Integer iMeterDataIndex = 0;iMeterDataIndex < sCurrentMeterData.size();iMeterDataIndex++)
                 {
                    system.debug('sCSV Header: '+sCSVHeader[iMeterDataIndex]);
                    if(sCSVHeader[iMeterDataIndex] == 'mpan')
                    {
                        serPoin.vlocity_cmt__ServicePointNumber__c = sCurrentMeterData[iMeterDataIndex];
                        SPNumberList.add(sCurrentMeterData[iMeterDataIndex]);
                    }
                    else if(sCSVHeader[iMeterDataIndex] == 'import_export')
                    {
                        serPoin.SWAN_Import_Export_Identifier__c = sCurrentMeterData[iMeterDataIndex];
                    }
                    /*else if(sCSVHeader[iMeterDataIndex] == 'prepayment_indicator')
                    {
                        serPoin.SWAN_prepayment_indicator__c = Boolean.valueOf(sCurrentMeterData[iMeterDataIndex]);
                    }*/
                    else if(sCSVHeader[iMeterDataIndex] == 'voltage')
                    {
                        serPoin.vlocity_cmt__VoltageLevel__c = sCurrentMeterData[iMeterDataIndex];
                    }
                    else if(sCSVHeader[iMeterDataIndex] == 'site_specific')
                    {
                        serPoin.SWAN_Site_Specific_Indicator__c = Boolean.valueOf(sCurrentMeterData[iMeterDataIndex]);
                    }
                    else if(sCSVHeader[iMeterDataIndex] == 'combination_valid')
                    {
                        serPoin.SWAN_MDD_Validation__c = Boolean.valueOf(sCurrentMeterData[iMeterDataIndex]);
                    }
                    else if(sCSVHeader[iMeterDataIndex] == 'combination_supported')
                    {
                        serPoin.SWAN_MDD_Combination_Supported__c = Boolean.valueOf(sCurrentMeterData[iMeterDataIndex]);
                    }
                    else if(sCSVHeader[iMeterDataIndex] == 'unsupported_reason')
                    {
                        serPoin.SWAN_Unsupported_Reason__c = sCurrentMeterData[iMeterDataIndex];
                    }
                    else if(sCSVHeader[iMeterDataIndex] == 'distributor_id')
                    {
                        if(sCurrentMeterData[iMeterDataIndex] != null && sCurrentMeterData[iMeterDataIndex] !='')
                        serPoin.SWAN_Distributor_ID_Ovrd__c = Integer.valueOf(sCurrentMeterData[iMeterDataIndex]);
                    }
                    else if(sCSVHeader[iMeterDataIndex] == 'profile_class')
                    {
                        serPoin.SWAN_Profile_Class_Ovrd__c = sCurrentMeterData[iMeterDataIndex];
                    }
                    else if(sCSVHeader[iMeterDataIndex] == 'meter_timeswitch_class')
                    {
                        serPoin.SWAN_Meter_Time_switch_Class_Ovrd__c = sCurrentMeterData[iMeterDataIndex];
                    }
                    else if(sCSVHeader[iMeterDataIndex] == 'line_loss_factor_class')
                    {
                        serPoin.SWAN_Line_Loss_Factor_Class_Ovrd__c = sCurrentMeterData[iMeterDataIndex];
                    }
                    else if(sCSVHeader[iMeterDataIndex] == 'gsp_group_id')
                    {
                        serPoin.SWAN_Grid_Supply_Point_Group_Id_Ovrd__c = sCurrentMeterData[iMeterDataIndex];
                    }
                    else if(sCSVHeader[iMeterDataIndex] == 'measurement_class')
                    {
                        serPoin.SWAN_Measurement_Class_Ovrd__c = sCurrentMeterData[iMeterDataIndex];
                       
                    }
                    else if(sCSVHeader[iMeterDataIndex] == 'standard_settlement_configuration')
                    {
                        serPoin.SWAN_Standard_Settlement_Config_Ovrd__c = sCurrentMeterData[iMeterDataIndex];
                    }
                    else if(sCSVHeader[iMeterDataIndex].equalsIgnoreCase('ssc_group_id')){
                        try{
                            serPoin.SWAN_SSC_Grp__c = sCurrentMeterData[iMeterDataIndex];
                        }catch(Exception ex){
                            serPoin.SWAN_SSC_Grp__c = null;
                        }
                    }
                    
                }
                serPointList.add(serPoin);
            }
            system.debug('serPointList='+serPointList);
            if(!serPointList.isEmpty())
            {
                upsert serPointList vlocity_cmt__ServicePointNumber__c;
            }
        
    }
    
      public Boolean AWSReadElectralinkResultFile (Map < String, Object > input,Map < String, Object > output,Map < String, Object > options) {
        try{
    
                // Get inputs ***
                
                String filePath = (string)input.get('strUploadedCSVURL'); // Get File Name
                
                
                system.debug('AWSS3csvFileReader:AWSReadcsvFile UploadedCSVURL: ' + filePath);
                SWAN_Status_Log__c st = new SWAN_Status_Log__c();
                String dataCompId = (String)input.get('DataComponentId');
                String sCalculationId = (string)input.get('strCalculationId');
                if(!String.isBlank(sCalculationId)){
                 st = [select id , swan_record_Id__c,OwnerId,SWAN_process_Name__c from SWAN_Status_Log__c where SWAN_WorkflowId__c = : sCalculationId limit 1];
                }
                Http httpreq = new Http();
                
                HttpRequest sRequest = new HttpRequest();
                sRequest.setMethod('GET');
                
                sRequest.setEndpoint(filePath);
                
                system.debug('AWSReadcsvFile Request: ' + sRequest);
                
                HTTPResponse sResponse = httpreq.send(sRequest);
                
                system.debug('AWSReadcsvFile Response Code: ' + sResponse);           
                system.debug('AWSReadcsvFile Response Body: ' + sResponse.getBody());
                
                if (sResponse.getStatusCode() == 200) {
                    String strUploadedCSVData = String.valueOf(sResponse.getBody());
                    String[] sCSVLines = strUploadedCSVData.split('\n');
                    parseElectralinkFile(sCSVLines);
                    createTaskNotification(st.ownerId,st.SWAN_Record_Id__c,'Consumption data retrieval from '+st.SWAN_process_Name__c+' completed','Consumption data retrieval from '+st.SWAN_process_Name__c+ ' completed for related records.');
                }
            }
            catch(Exception e) {
            exceptionOccur = true;
            system.debug('AWSReadcsvFile Exception: ' + e.getMessage());
            system.debug('AWSReadcsvFile Exception: ' + e.getStackTraceString());
        }
        return true;
                
        }
        
     public void parseElectralinkFile(List<String> strUploadedCSVData){
        
            List<String> sCSVHeader = strUploadedCSVData[0].split(',');
            List<vlocity_cmt__ServicePoint__c> serPointList = new List<vlocity_cmt__ServicePoint__c>();
              system.debug('sCSVHeader='+sCSVHeader+' size='+sCSVHeader.size());
            for(Integer iMeterIndex = 1; iMeterIndex < strUploadedCSVData.size();iMeterIndex++){ // Loop CSV LINE
                String[] sCurrentMeterData = strUploadedCSVData[iMeterIndex].split(',');
                 vlocity_cmt__ServicePoint__c serPoin = new vlocity_cmt__ServicePoint__c();
                for(Integer iMeterDataIndex = 0;iMeterDataIndex < sCurrentMeterData.size();iMeterDataIndex++)
                {
                    if(sCSVHeader[iMeterDataIndex] == 'mpan')
                    {
                        serPoin.vlocity_cmt__ServicePointNumber__c = sCurrentMeterData[iMeterDataIndex];
                    }
                    else if(sCSVHeader[iMeterDataIndex] == 'meter_Id')
                    {
                        serPoin.vlocity_cmt__ServicePointNumber__c = sCurrentMeterData[iMeterDataIndex];
                    }
                    else if(sCSVHeader[iMeterDataIndex] == 'Total_EAC')
                    {
                        if(sCurrentMeterData[iMeterDataIndex] != '')
                        serPoin.SWAN_Total_EAC__c = Double.valueOf(sCurrentMeterData[iMeterDataIndex]);
                    }
                    else if(sCSVHeader[iMeterDataIndex] == 'number_of_days')
                    {
                        if(sCurrentMeterData[iMeterDataIndex] != '')
                        serPoin.SWAN_HH_Number_of_days__c = Double.ValueOf(sCurrentMeterData[iMeterDataIndex]);
                    }
                    else if(sCSVHeader[iMeterDataIndex] == 'error')
                    {
                        serPoin.SWAN_Electralink_Error_Message__c = sCurrentMeterData[iMeterDataIndex];
                    }
                    
                }
                serPointList.add(serPoin);
            }
            system.debug('serPointList='+serPointList);
            if(!serPointList.isEmpty())
            {
                upsert serPointList vlocity_cmt__ServicePointNumber__c;
            }
        
    }
    public Boolean AWSReadcsvFileForContract (Map < String, Object > input,Map < String, Object > output,Map < String, Object > options) {
    try{    
        system.debug('Begin AWSS3csvFileReader:AWSReadcsvFile '+input);
            
            map<String,Object> mapResponse = (map<String,Object>)input.get('SetResultsURL');
            
            system.debug((String)mapResponse.get('strCalculationResultsCSVURLContract'));
            String contractLevelURL = (String)mapResponse.get('strCalculationResultsCSVURLContract');
            //String filePath = (string)input.get('SetResultsURL'); // Get File Name
            
            
            system.debug('AWSS3csvFileReader:AWSReadcsvFile UploadedCSVURL: ' + contractLevelURL);
            
            Http httpreqContract = new Http();
            
            HttpRequest sRequestContract = new HttpRequest();
            sRequestContract.setMethod('GET');
            
            sRequestContract.setEndpoint(contractLevelURL);
            
            system.debug('AWSReadcsvFile Request: ' + sRequestContract);
            
            HTTPResponse sResponseContract = httpreqContract.send(sRequestContract);
            
            //system.debug('AWSReadcsvFile Response Code: ' + sResponseContract);           
            //system.debug('AWSReadcsvFile Response Body: ' + sResponseContract.getBody());
            
            if (sResponseContract.getStatusCode() == 200) {
                system.debug('AWSReadcsvFile extract data: ');
                input.put('strUploadedCSVContract',sResponseContract.getBody());
                output.put('strUploadedCSVContract',sResponseContract.getBody());
                //AWSParseFile(input, output, options);
                
            }
            output.put('exceptionOccur',exceptionOccur);
            
            system.debug('End AWSS3csvFileReader:AWSReadcsvFileForContract');
    }   catch(System.CalloutException e) {
            system.debug('AWSReadcsvFile Service Callout Exception: ' + e.getMessage());
            system.debug('AWSReadcsvFile Service Callout Exception: ' + e.getCause());
            system.debug('AWSReadcsvFileException: ' + e.getStackTraceString());
        } catch(Exception e) {
            exceptionOccur = true;
            system.debug('AWSReadcsvFile Exception: ' + e.getMessage());
            system.debug('AWSReadcsvFile Exception: ' + e.getStackTraceString());
        }
        return true;
        
    }
    
    public Boolean AWSReadcsvFileMeterLevel (Map < String, Object > input,Map < String, Object > output,Map < String, Object > options) {
        try{
            
            
            
            // Get inputs ***
            
            String filePath = (string)input.get('strUploadedCSVURL'); // Get File Name
            
            
            system.debug('AWSS3csvFileReader:AWSReadcsvFileMeterLevel UploadedCSVURL: ' + filePath);
            
            Http httpreq = new Http();
            
            HttpRequest sRequest = new HttpRequest();
            sRequest.setMethod('GET');
            
            sRequest.setEndpoint(filePath);
            
            system.debug('AWSReadcsvFile Request: ' + sRequest);
            
            HTTPResponse sResponse = httpreq.send(sRequest);
            
            //system.debug('AWSReadcsvFile Response Code: ' + sResponse);           
            //system.debug('AWSReadcsvFile Response Body: ' + sResponse.getBody());
            
            
            if (sResponse.getStatusCode() == 200) {
                system.debug('AWSReadcsvFile extract data: ');
                //output.put('meterCalloutStatusCode',200);
                //input.put('strUploadedCSV',sResponse.getBody());
                //output.put('strUploadedCSV',sResponse.getBody());
                 if((string)input.get('csvFlexPriceSummaryGas') != null && (string)input.get('csvFlexPriceSummaryGas') != ''){
                     input.put('strUploadedCSVData',(string)input.get('csvFlexPriceSummaryGas'));
                     input.put('strCalculationId',input.get('strCalculationId'));
                     AWSReadQuotePriceSummaryFile(input, output, options);
                     input.put('strUploadedCSV',(string)input.get('csvFlexVolSummaryGas'));
                     input.put('strDataComponentName','Volume Summary');
                     AWSS3csvFileReader1.AWSParseFileClone(input, output, options);
                     
                 }else{
                    //When  enters here ? only when is gas fixed ? 
                    input.put('strDataComponentName','Offer summary');
                    AWSS3csvFileReader1.AWSParseFileClone(input, output, options);
                }
                //AWSParseFileClone(input, output, options);
                input.put('strUploadedCSV',sResponse.getBody());
                input.put('strDataComponentName','Meter level results');
                AWSS3csvFileReader1.AWSParseFileClone(input, output, options);
                //Process 'Gas Cost Summary'
                invokeMethod('processFlexSummary', new Map < String, Object >{'strDataComponentName' => 'Gas Cost Summary',
                                                                              'strCalculationId' => input.get('strCalculationId'),
                                                                              'csvGasFlexCostSummary' => input.get('GetCsvFlexGasCostSummary')}, output, options);

                //Ipdate Quote gas flex summary  on quote mater details                                                                                   
                if(input.get('csvFlexGasQuoteSummary') !=null ){
                     
                    AWSS3csvFileReader1.AWSParseFileClone(new Map < String, Object >{   'strDataComponentName' => 'Offer summary',
                                                                                        'strCalculationId' => input.get('strCalculationId'),
                                                                                        'UploadData' => new Map < String, Object >{ 'strUploadedCSVContract' => input.get('csvFlexGasQuoteSummary') }
                                                                                    }, output, options);
                 }   

            }
            output.put('exceptionOccur',exceptionOccur);
            //system.debug('End AWSS3csvFileReader:AWSReadcsvFile');
            output.put('statusUpdated',statusUpdated);
        } catch(System.CalloutException e) {
            system.debug('AWSReadcsvFile Service Callout Exception: ' + e.getMessage());
            system.debug('AWSReadcsvFile Service Callout Exception: ' + e.getCause());
            system.debug('AWSReadcsvFileException: ' + e.getStackTraceString());
        } catch(Exception e) {
            exceptionOccur = true;
            system.debug('AWSReadcsvFile Exception: ' + e.getMessage());
            system.debug('AWSReadcsvFile Exception: ' + e.getStackTraceString());
        }
        return true;
    }
    
    public Boolean AWSReadcsvFileForVolumeSummary (Map < String, Object > input,Map < String, Object > output,Map < String, Object > options) {
        try{
            // Get inputs ***
            String filePath = (string)input.get('strUploadedCSVURL'); // Get File Name
            system.debug('AWSS3csvFileReader:AWSReadcsvFile UploadedCSVURL: ' + filePath);
            Http httpreq = new Http();
            HttpRequest sRequest = new HttpRequest();
            sRequest.setMethod('GET');
            sRequest.setEndpoint(filePath);
            system.debug('AWSReadcsvFile Request: ' + sRequest);
            HTTPResponse sResponse = httpreq.send(sRequest);
            if (sResponse.getStatusCode() == 200) {
                system.debug('AWSReadcsvFile extract data: ');
                //input.put('strUploadedCSV',sResponse.getBody());
                output.put('volSummaryRespData',sResponse.getBody());
            }
            output.put('exceptionOccur',exceptionOccur);
            output.put('statusUpdated',statusUpdated);
        } catch(System.CalloutException e) {
            system.debug('AWSReadcsvFile Service Callout Exception: ' + e.getMessage());
            system.debug('AWSReadcsvFile Service Callout Exception: ' + e.getCause());
            system.debug('AWSReadcsvFileException: ' + e.getStackTraceString());
        } catch(Exception e) {
            exceptionOccur = true;
            system.debug('AWSReadcsvFile Exception: ' + e.getMessage());
            system.debug('AWSReadcsvFile Exception: ' + e.getStackTraceString());
        }
        return true;
    }       
    
    public Boolean AWSReadcsvFileMeterLevelElec (Map < String, Object > input,Map < String, Object > output,Map < String, Object > options) {
        try{
            
            
            
            // Get inputs ***
            
            String filePath = (string)input.get('strUploadedCSVURL'); // Get File Name
            
            
            system.debug('AWSS3csvFileReader:AWSReadcsvFileMeterLevelElec UploadedCSVURL: ' + filePath);
            
            Http httpreq = new Http();
            
            HttpRequest sRequest = new HttpRequest();
            sRequest.setMethod('GET');
            
            sRequest.setEndpoint(filePath);
            
            system.debug('AWSReadcsvFile Request: ' + sRequest);
            
            HTTPResponse sResponse = httpreq.send(sRequest);
            
            //system.debug('AWSReadcsvFile Response Code: ' + sResponse);           
            //system.debug('AWSReadcsvFile Response Body: ' + sResponse.getBody());
            
            
            if (sResponse.getStatusCode() == 200) {
                system.debug('AWSReadcsvFile extract data: ');
                //output.put('meterCalloutStatusCode',200);
                input.put('strUploadedCSV',sResponse.getBody());
                //output.put('strUploadedCSV',sResponse.getBody());
                input.put('strDataComponentName','Quote level results');
                AWSS3csvFileReader1.AWSParseFileClone(input, output, options);
                //AWSParseFileClone(input, output, options);
                input.put('strDataComponentName','Elec Meter level results');
                AWSS3csvFileReader1.AWSParseFileClone(input, output, options);
                //AWSParseFileClone(input, output, options);
            }
            output.put('exceptionOccur',exceptionOccur);
            //system.debug('End AWSS3csvFileReader:AWSReadcsvFile');
            output.put('statusUpdated',statusUpdated);
        } catch(System.CalloutException e) {
            system.debug('AWSReadcsvFile Service Callout Exception: ' + e.getMessage());
            system.debug('AWSReadcsvFile Service Callout Exception: ' + e.getCause());
            system.debug('AWSReadcsvFileException: ' + e.getStackTraceString());
        } catch(Exception e) {
            exceptionOccur = true;
            system.debug('AWSReadcsvFile Exception: ' + e.getMessage());
            system.debug('AWSReadcsvFile Exception: ' + e.getStackTraceString());
        }
        return true;
    }
    
    public Boolean AWSReadcsvFile (Map < String, Object > input,Map < String, Object > output,Map < String, Object > options) {
        try{
            
            
            
            // Get inputs ***
            
            String filePath = (string)input.get('strUploadedCSVURL'); // Get File Name
            
            
            system.debug('AWSS3csvFileReader:AWSReadcsvFile UploadedCSVURL: ' + filePath);
            
            Http httpreq = new Http();
            
            HttpRequest sRequest = new HttpRequest();
            sRequest.setMethod('GET');
            
            sRequest.setEndpoint(filePath);
            
            system.debug('AWSReadcsvFile Request: ' + sRequest);
            
            HTTPResponse sResponse = httpreq.send(sRequest);
            
            system.debug('AWSReadcsvFile Response Code: ' + sResponse);           
            system.debug('AWSReadcsvFile Response Body: ' + sResponse.getBody());

            if (sResponse.getStatusCode() == 200) {
                system.debug('AWSReadcsvFile extract data: ');
                input.put('strUploadedCSVContract',sResponse.getBody());
                input.put('UploadData',input);
                //AWSParseFile(input, output, options);
                //input.put('strDataComponentName','Meter level results');
                AWSS3csvFileReader1.AWSParseFileClone(input, output, options);
               // AWSParseFile(input, output, options);
            }
            output.put('exceptionOccur',exceptionOccur);
            system.debug('End AWSS3csvFileReader:AWSReadcsvFile');
            output.put('statusUpdated',statusUpdated);
            
        } catch(System.CalloutException e) {
            system.debug('AWSReadcsvFile Service Callout Exception: ' + e.getMessage());
            system.debug('AWSReadcsvFile Service Callout Exception: ' + e.getCause());
            system.debug('AWSReadcsvFileException: ' + e.getStackTraceString());
        } catch(Exception e) {
            exceptionOccur = true;
            system.debug('AWSReadcsvFile Exception: ' + e.getMessage());
            system.debug('AWSReadcsvFile Exception: ' + e.getStackTraceString());
        }
        return true;
    }

    public static Boolean processFlexQuoteSummary(Map < String, Object > input,Map < String, Object > output,Map < String, Object > options){
        system.debug('input keys: '+input.keyset());
        if((string)input.get('csvFlexPriceSummary') != null){
            system.debug('csvFlexPriceSummary');
            AWSS3csvFileReader1.processFlexSummary( new Map < String, Object >{'strUploadedCSVURL' => input.get('csvFlexPriceSummary'),
                                                                               'strCalculationId' => input.get('strCalculationId')}, output, options);
        }
         if((string)input.get('csvFlexCostSummary') != null){
            system.debug('csvFlexCostSummary');
            AWSS3csvFileReader1.processFlexSummary( new Map < String, Object >{'strUploadedCSVURL' => input.get('csvFlexCostSummary'),
                                                                              'strCalculationId' => input.get('strCalculationId')}, output, options);
        }
         if((string)input.get('csvGasFlexCostSummary') != null){
             system.debug('csvFlexCostSummary');
             AWSS3csvFileReader1.AWSParseFileClone( new Map < String, Object >{'strUploadedCSVURL' => input.get('csvGasFlexCostSummary'),
                                                                              'strCalculationId' => input.get('strCalculationId'),
                                                                              'strDataComponentName' => 'Gas Cost Summary'}, output, options);
        }
        if((string)input.get('csvFlexMeterLevelSum') != null){
            AWSS3csvFileReader1.AWSParseFileClone( new Map < String, Object >{'strUploadedCSV' => input.get('csvFlexMeterLevelSum'),
                                                                              'strCalculationId' => input.get('strCalculationId'),
                                                                              'strDataComponentName' => 'Elec Meter level results'}, output, options);
        }
        if((string)input.get('csvFlexQuoteSummary') != null){
            Map < String, Object > contractMap = new Map < String, Object >{'strUploadedCSVContract' => input.get('csvFlexQuoteSummary')};
            AWSS3csvFileReader1.AWSParseFileClone( new Map < String, Object >{'UploadData'=>contractMap,
                                                                              'strCalculationId' => input.get('strCalculationId'),
                                                                              'strDataComponentName' => 'Quote level results'}, output, options);
        }
        if(input.get('UploadData') != null ){
            AWSS3csvFileReader1.AWSParseFileClone(input, output, options);
        }
        system.debug('csvFlexVolumeSummary: '+input.get('csvFlexVolumeSummary'));
        if((string)input.get('csvFlexVolumeSummary') != null){
            system.debug('AWS3csvFileReader.processFlexQuoteSummary.strVolumeSummary: '+input.get('csvFlexVolumeSummary'));
            AWSS3csvFileReader1.AWSParseFileClone( new Map < String, Object >{'strUploadedCSV' => input.get('csvFlexVolumeSummary'),
                                                                              'strCalculationId' => input.get('strCalculationId'),
                                                                              'strDataComponentName' => 'Volume Summary'}, output, options);
        }

        return true;
    }
    
      public Boolean AWSReadQuotePriceSummaryFile (Map < String, Object > input,Map < String, Object > output,Map < String, Object > options) {
        try{
                Map<String,QuoteLineItem> qliMap = new Map<String,QuoteLineItem>();
                    String strResponseCSVData = (String)input.get('strUploadedCSVData');
                    String strCalculationId = String.ValueOf(input.get('strCalculationId'));
                    String[] strUploadedCSVData = strResponseCSVData.split('\n');
                    List<String> sCSVHeader = strUploadedCSVData[0].split(',');
                    List<QuotelineItem> qtLiItemsList = new List<QuotelineItem>();
                    for(Quote qt : [SELECT id,name,(select id,product2.ProductCode,vlocity_cmt__OneTimeCost__c,vlocity_cmt__UsageUnitPrice__c,SWAN_UnitRate__c,SWAN_Unit_Rate_Therms__c from QuoteLineItems where product2.vlocity_cmt__type__c='Flex Fee') FROM Quote WHERE RecordType.DeveloperName = 'SubQuote' AND (vlocity_cmt__ParentQuoteId__r.SWAN_Pricing_Calculation_Id__c =: strCalculationId OR vlocity_cmt__ParentQuoteId__r.SWAN_ReAssess_Calculation_Id__c =: strCalculationId) AND vlocity_cmt__QuoteGroupId__r.vlocity_cmt__MemberType__c = 'Business_Account' Limit 1])
                    {
                        for(QuoteLineItem qli : qt.QuoteLineItems)
                        {
                            qliMap.put(qli.product2.ProductCode.toUpperCase(),qli);
                        }
                    }
                    for(Integer iMeterIndex = 1; iMeterIndex < strUploadedCSVData.size();iMeterIndex++){     //      Loop CSV LINE
                            String[] sCurrentMeterData = strUploadedCSVData[iMeterIndex].split(',');
                            String catVal = '';
                            String compoVal = '';   
                            
                            QuotelineItem qliUpdate = new QuotelineItem();
                            for(Integer iMeterDataIndex = 0;iMeterDataIndex < sCurrentMeterData.size();iMeterDataIndex++)
                            {
                                
                                if(sCSVHeader[iMeterDataIndex] == 'component' )
                                {
                                    compoVal = sCurrentMeterData[iMeterDataIndex];
                                }
                                else if(sCSVHeader[iMeterDataIndex] == 'category' )
                                {
                                    catVal = sCurrentMeterData[iMeterDataIndex];
                                }
                                if(catVal == 'Management Fee' && compoVal=='Total')
                                {
                                    qliUpdate.id = qliMap.get('BG_GAS_MANAGEMENT_FEE').Id;
                                }else if(catVal == 'Balance and Imbalance' && compoVal=='Total')
                                {
                                    qliUpdate.id = qliMap.get('BG_BALANCE_IMBALANCE').Id;
                                }else if(catVal == 'Industry Charges' && compoVal=='Total')
                                {
                                    qliUpdate.id = qliMap.get('BG_GAS_INDUSTRY_CHARGES').Id;
                                }
                                else if(catVal == 'Industry Charges' && compoVal=='Xoserve Charge')
                                {
                                    qliUpdate.id = qliMap.get('BG_XOSERVE').Id;
                                }
                                else if(catVal == 'Balance and Imbalance' && compoVal=='Balance and Imbalance Premium')
                                {
                                    qliUpdate.id = qliMap.get('BG_BALANCE_IMBALANCE_PREMIUM').Id;
                                }
                                else if(compoVal != '')
                                {
                                    string compVal ='BG_'+compoVal.replace(' ','_').toUppercase();
                                    if(qliMap.containsKey(compVal))
                                    {
                                        qliUpdate.id = qliMap.get(compVal).Id;
                                    }
                                }
                                if(sCSVHeader[iMeterDataIndex] == 'pounds')
                                {
                                        qliUpdate.vlocity_cmt__OneTimeCost__c = Double.valueOf(sCurrentMeterData[iMeterDataIndex]);
                                }
                                else if(sCSVHeader[iMeterDataIndex] == 'pound_per_mwh')
                                {
                                        qliUpdate.vlocity_cmt__UsageUnitPrice__c = Double.valueOf(sCurrentMeterData[iMeterDataIndex]);
                                }
                                else if(sCSVHeader[iMeterDataIndex] == 'pence_per_kwh')
                                {
                                        qliUpdate.SWAN_UnitRate__c = Double.valueOf(sCurrentMeterData[iMeterDataIndex]);
                                }
                                else if(sCSVHeader[iMeterDataIndex] == 'pence_per_therm')
                                {
                                        qliUpdate.SWAN_Unit_Rate_Therms__c = Double.valueOf(sCurrentMeterData[iMeterDataIndex]);
                                } 
                                
                            }
                            qtLiItemsList.add(qliUpdate);
                        }
                        system.debug('serPointList='+qtLiItemsList);
                        if(!qtLiItemsList.isEmpty())
                        {
                            update qtLiItemsList;
                        }
            }
            catch(Exception e) {
                        exceptionOccur = true;system.debug('AWSReadcsvFile Exception: ' + e.getMessage());
                    }
        return true;
    }   
}