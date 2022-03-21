global with sharing class SWAN_GetServicePointsForCustomerData implements vlocity_cmt.VlocityOpenInterface {
    
/**
* Initialize queries to be used to include namespace prefix
*/
    static
        
    {
        // Retrieve the service points that have active opportunity line items for this opportunity
        String queryOpportunityLineItems =
            'SELECT vlocity_cmt__ServicePointId__c ' +
            'FROM OpportunityLineItem ' +
            'WHERE OpportunityId = :opportunityId AND SWAN_IsActive__c = true';
        
        // Retrieve the premises associated with the service accounts for this customer
        String queryPremiseIdsFromAccount = 
            'SELECT vlocity_cmt__PremisesId__c ' +
            'FROM Account ' +
            'WHERE ParentId = :accountId ' +
            'AND Type = :fuelType';
        
        // Retrieve the service points for display
        String queryGasServicePoints = 
            'SELECT Id, Name, SWAN_AQ_Validation_Issue__c, SWAN_Priority_1_Issue__c, SWAN_MDD_Combination_Supported__c, SWAN_ECOES_Issue__c, SWAN_Electralink_Retrieval_Status__c,' +
            'vlocity_cmt__ServicePointNumber__c, vlocity_cmt__ServiceType__c, vlocity_cmt__PremisesId__r.id, ' +
            'vlocity_cmt__PremisesId__r.vlocity_cmt__PostalCode__c ' +
            'FROM vlocity_cmt__ServicePoint__c ' +
            'WHERE vlocity_cmt__PremisesId__c IN :premiseList ' +
            'AND Id NOT IN :lstServicePointIds ' +
            'AND RecordType.DeveloperName = :recordTypeDevName';
    }
    
    /**
        * Top level call by a Vlocity Remote Action
        *
        * @param inputMap - The input provided to the Remote Action
        * @param outputMap - Any output to be provided back to the Remote Action
        * @param options - Any options to aid in the execution of this class
        *
    * @returns true if the method completes successfully, false otherwise
    */ 
    global Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
        
        Boolean result = true;
        try
        {
            if (methodName.equals('retrieveGasServicePointsFromOpportunity'))
            {
                retrieveGasServicePointsFromOpportunity(inputMap,outputMap,options);
            }else
            {
                result = false;
            } 
        } 
        catch(Exception e)
        {System.debug('SWAN_GetServicePointsForCustomerData:invokeMethod -> exception: '+e);
         result = false;}
        
        return result;
        
    }
    
    private Boolean retrieveGasServicePointsFromOpportunity(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
        
        String  opportunityId = (String) inputMap.get('contextId');
        String recordTypeDevName = (String) inputMap.get('recordTypeDevName');
        String fuelType = (String) inputMap.get('fuelType');
        
        //opp id: 0068E00000PVSWmQAP
        //RecordType.DeveloperName= 'SWAN_Gas_Service_Point'
        //fuelType= 'Gas'
        
        // TO DO: retrieve list of service points to exclude queryOpportunityLineItems
        Set<String> setOLI = new Set<String>();
        for(OpportunityLineItem oli : [SELECT vlocity_cmt__ServicePointId__c FROM OpportunityLineItem  WHERE OpportunityId =:opportunityId  AND SWAN_IsActive__c = true  ]  ){
            setOLI.add(oli.vlocity_cmt__ServicePointId__c);
        }
        
        // TO DO: retrieve all premises related to this account queryPremiseIdsFromAccount
        Set<String> setACC = new Set<String>();
        for(Account acc : [Select vlocity_cmt__PremisesId__c from Account Where ParentId in ( Select  AccountId  from Opportunity Where Id =:opportunityId )  and type =:fuelType ]  ){
            setACC.add(acc.vlocity_cmt__PremisesId__c);
        }
        // TO DO: retrieve all service points queryGasServicePoints, excluding the service points from above and including the premises
        List<vlocity_cmt__ServicePoint__c> lstSP = new List<vlocity_cmt__ServicePoint__c>(
            [SELECT Id, Name, SWAN_AQ_Validation_Issue__c, SWAN_Priority_1_Issue__c, SWAN_MDD_Combination_Supported__c, SWAN_ECOES_Issue__c, SWAN_Electralink_Retrieval_Status__c, vlocity_cmt__ServicePointNumber__c, SWAN_Data_Logger__c, SWAN_Corrector__c,
             vlocity_cmt__ServiceType__c, vlocity_cmt__PremisesId__r.id,  vlocity_cmt__PremisesId__r.vlocity_cmt__PostalCode__c, SWAN_Class__c 
             FROM vlocity_cmt__ServicePoint__c
             WHERE vlocity_cmt__PremisesId__c IN : setACC 
             AND Id NOT IN : setOLI
             AND RecordType.DeveloperName = :recordTypeDevName 
            ]
        );

        //outputMap.put('lstSP', lstSP);  //
        outputMap.put('ServiceLocations', lstSP);
        outputMap.put('SPCount1', lstSP.size());
        
        return true;
    }

}