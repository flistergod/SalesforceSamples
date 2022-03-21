global with sharing class SWAN_ExtractServicePoints implements vlocity_cmt.VlocityOpenInterface2 {
    
   /**
     * Top level call by a Vlocity Remote Action
     *
     * @param inputMap  - The input provided to the Remote Action
     * @param outputMap - Any output to be provided back to the Remote Action
     * @param options   - Any options to aid in the execution of this class
     *
     * @returns true if the method completes successfully, false otherwise
     */ 
    global Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {

        Boolean result = true;
        try
        {
            if (methodName.equals('getServicePointsOfMasterQuote'))
            {
                getServicePointsOfMasterQuote(inputMap,outputMap,options);
            }
            else if (methodName.equals('getServicePointsOfMasterQuoteElec'))
            {
                getServicePointsOfMasterQuoteElec(inputMap,outputMap,options);
            }
            else
            {
                result = false;
            }   
        }catch(Exception e){
        
            System.debug('SWAN_ExtractServicePoints:invokeMethod -> exception: '+e);
            result = false;
        }
        
        return result;
    
    }
    
    
    private Boolean getServicePointsOfMasterQuote(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
       
        List<vlocity_cmt__servicepoint__c> lstSP =new List<vlocity_cmt__servicepoint__c>();
        String quoteId = String.ValueOf(inputMap.get('ContextId'));
        
        lstSP = [Select Id , name, SWAN_Priority_1_Issue__c, vlocity_cmt__ServiceType__c,
                 SWAN_AQ_Validation_Issue__c from vlocity_cmt__servicepoint__c 
                 Where Id in (Select SWAN_Service_Point__c from Quote Where SWAN_Parent_Quote__c=:quoteId)  and (SWAN_Priority_1_Issue__c=true or SWAN_AQ_Validation_Issue__c=true  ) ];
        
        outputMap.put('lstSP', lstSP );
        
        return null;
    }
    
        private Boolean getServicePointsOfMasterQuoteElec(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
       
        List<vlocity_cmt__servicepoint__c> lstSP =new List<vlocity_cmt__servicepoint__c>();
        String quoteId = String.ValueOf(inputMap.get('ContextId'));
        Map<Id, OpportunityLineItem> mapOPI = new Map<Id,OpportunityLineItem>([select vlocity_cmt__ServicePointId__r.Id FROM OpportunityLineItem WHERE SWAN_IsActive__c = true]);
        
        lstSP = [SELECT Id , Name, SWAN_Supply_Capacity_Issue__c, SWAN_MDD_Combination_Supported__c, vlocity_cmt__ServiceType__c,
        SWAN_Electralink_Retrieval_Status__c, SWAN_Unsupported_Reason__c, SWAN_HH_Data_Uploaded_into_Gorilla__c FROM vlocity_cmt__servicepoint__c
        WHERE Id IN (SELECT SWAN_Service_Point__c FROM Quote WHERE vlocity_cmt__ParentQuoteId__c =:quoteId) AND (SWAN_MDD_Combination_Supported__c = false
        OR (SWAN_Supply_Capacity_Issue__c = true AND ((SWAN_Measurement_Class__c IN ('C','E') AND SWAN_Measurement_Class_Ovrd__c = NULL) OR SWAN_Measurement_Class_Ovrd__c IN ('C','E')))
        OR (((SWAN_Measurement_Class__c NOT IN ('A','B') AND SWAN_Measurement_Class_Ovrd__c = NULL) OR SWAN_Measurement_Class_Ovrd__c NOT IN ('A','B')) AND (SWAN_Electralink_Retrieval_Status__c = 'Error' AND SWAN_HH_Data_Uploaded_into_Gorilla__c = false))
        OR (((SWAN_Measurement_Class__c IN ('A','B') AND SWAN_Measurement_Class_Ovrd__c = NULL) OR SWAN_Measurement_Class_Ovrd__c IN ('A','B')) AND Id NOT IN :mapOPI.keyset() AND SWAN_Electralink_Retrieval_Status__c = 'Error'))];
             
              
        outputMap.put('lstSP', lstSP );
        
        return null;
    }

}