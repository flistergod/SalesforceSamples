global with sharing class SWAN_multisiteDataload implements vlocity_cmt.VlocityOpenInterface2 {

    public integer ECOESBatchSize=integer.ValueOf(System.Label.ECOESBatchSize);
    public integer MaxECOESBatchSize=integer.ValueOf(System.Label.Max_ECOES_Batch_Size);

    global Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {

        if (methodName == 'load') return load(inputMap, outputMap, options);  
        if (methodName == 'load_ELEC') return load_ELEC(inputMap, outputMap, options);
        if (methodName == 'gasIndustryDataLoad') return gasIndustryDataLoad(inputMap, outputMap, options);  
        if (methodName == 'electricityIndustryDataLoad') return electricityIndustryDataLoad(inputMap, outputMap, options);
        if (methodName == 'bulkIndustryDataRefresh') return bulkIndustryDataRefresh(inputMap, outputMap, options);
       /* if (methodName == 'dummyMethod') {
           // System.debug('inside invoke');
            return dummyMethod(inputMap, outputMap, options); }*/
        
        return false;
    }
    
    private Boolean load(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
        try{
            Database.executeBatch(new SWAN_CSVUpload(inputMap,UserInfo.getUserId()),250);
            return true;
        }
        catch(exception e){
            System.debug('Exception: ' + e.getMessage());
            return false;
        }    
    }
    
    private Boolean load_ELEC(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
        try{
            Database.executeBatch(new SWAN_CSVUpload_ELEC(inputMap,UserInfo.getUserId()),250);
            return true;
        }
        catch(exception e){
            System.debug('Exception: ' + e.getMessage());
            return false;
        }    
    }

    private Boolean gasIndustryDataLoad(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
        try{
            
            String UserId=UserInfo.getUserId();
            Map<String,Object> spIds=(Map<String,Object>)inputMap.get('spIds');
            Map<String, Object> ParentAccount=(Map<String,Object>)inputMap.get('ParentAccount');
            Map<String, Object> AccountDetails=(Map<String,Object>)ParentAccount.get('AccountDetails');
            String parentAccName=(String)AccountDetails.get('AccountName');
            String parentAccId=(String)AccountDetails.get('AccountId');
            List<Object> gasList=(List<Object>)spIds.get('spIds_Gas');
            Set<Id> gasIds = new Set<Id>();


            if(gasList.size()>0){

                for(Object obj: gasList){
                    Id gasId=(Id) obj;
                    gasIds.add(gasId);  
                }
             //   System.debug(gasIds.size()+' '+gasList.size()+' '+ECOESBatchSize+' '+MaxECOESBatchSize);
                    Database.executeBatch(new callVIP (gasIds,UserId,parentAccName,parentAccId), 45);

            }
            outputMap.put('FinalResponse', 'Success');
            return true;
        }
        catch(exception e){
            System.debug('Exception: ' + e.getMessage());
            return false;
        }    
    }

    private Boolean electricityIndustryDataLoad(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
        try{

            String UserId=UserInfo.getUserId();
            Map<String,Object> spIds=(Map<String,Object>)inputMap.get('spIds');
            Map<String, Object> ParentAccount=(Map<String,Object>)inputMap.get('ParentAccount');
            Map<String, Object> AccountDetails=(Map<String,Object>)ParentAccount.get('AccountDetails');
            String parentAccName=(String)AccountDetails.get('AccountName');
            String parentAccId=(String)AccountDetails.get('AccountId');
            List<Object> eleList=(List<Object>)spIds.get('spIds_Elec');
            Set<Id> elecIds = new Set<Id>();

            if(eleList.size()>0){

                for(Object obj: eleList){
                    Id elecId=(Id) obj;
                    elecIds.add(elecId);    
                }

           
                 //   System.debug(eleList.size()+' '+elecIds.size()+' '+ECOESBatchSize+' '+MaxECOESBatchSize);
                if(ECOESBatchSize<=MaxECOESBatchSize)
                Database.executeBatch(new callVIP_ELEC(elecIds,UserId,parentAccName,parentAccId), ECOESBatchSize);
                else
                Database.executeBatch(new callVIP_ELEC(elecIds,UserId,parentAccName,parentAccId), MaxECOESBatchSize);
                }
               
                outputMap.put('FinalResponse', 'Success');
                return true;
        }
        catch(exception e){
            System.debug('Exception: ' + e.getMessage());
            return false;
        }    
    }

    private Boolean bulkIndustryDataRefresh(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
        try{
            electricityIndustryDataLoad(inputMap, outputMap, options);
            gasIndustryDataLoad(inputMap, outputMap, options);  
            
            outputMap.put('FinalResponse', 'Success');
            return true;
        }
        catch(exception e){
            System.debug('Exception: ' + e.getMessage());
            return false;
        }    
    }

    /*
    private Boolean dummyMethod(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
        System.debug('inside dummy');
        try{

            String UserId=UserInfo.getUserId();
            Map<String,Object> spIds=(Map<String,Object>)inputMap.get('spIds');
            Map<String, Object> ParentAccount=(Map<String,Object>)inputMap.get('ParentAccount');
            Map<String, Object> AccountDetails=(Map<String,Object>)ParentAccount.get('AccountDetails');
            String parentAccName=(String)AccountDetails.get('AccountName');
            String parentAccId=(String)AccountDetails.get('AccountId');
            List<Object> eleList=(List<Object>)spIds.get('spIds_Elec');
            List<Object> gasList=(List<Object>)spIds.get('spIds_Gas');
            Set<Id> elecIds = new Set<Id>();
            Set<Id> gasIds = new Set<Id>();

            for(Object obj: eleList){
                Id elecId=(Id) obj;
                elecIds.add(elecId);    
            }

            for(Object obj: gasList){
                Id gasId=(Id) obj;
                gasIds.add(gasId);  
            }

            System.debug(elecIds);
            System.debug(gasIds);
            System.debug(parentAccName);
            System.debug(parentAccId);
            System.debug(UserId);
            outputMap.put('FinalResponse', 'Success');
            return true;
        }
        catch(exception e){
            System.debug('Exception: ' + e.getMessage());
            return false;
        }    
    }*/
  
}