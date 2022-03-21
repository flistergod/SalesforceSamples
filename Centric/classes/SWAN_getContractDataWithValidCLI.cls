global with sharing class SWAN_getContractDataWithValidCLI implements vlocity_cmt.VlocityOpenInterface {

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
            if (methodName.equals('getContractDataWithValidCLI'))
            {
                getContractDataWithValidCLI(inputMap,outputMap,options);
            }
            else 
            {
                result = false;
            }   
        } 
        catch(Exception e)
        {System.debug('SWAN_getContractDataWithValidCLI:invokeMethod -> exception: '+e);
            result = false;}
        
        return result;
    
    }
    
    global Boolean getContractDataWithValidCLI(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
        List<Object> childcli = new List<Object>();
        list<Id> cliIds = new List<Id>();
        
        Integer i = 0;
        String contractID = String.ValueOf(inputMap.get('ContextId'));
        for(vlocity_cmt__ContractLineItem__c cli : [SELECT id,SWAN_Service_Point__c,vlocity_cmt__ContractId__r.StartDate,vlocity_cmt__ContractId__r.EndDate,vlocity_cmt__ContractId__c,vlocity_cmt__ContractId__r.vlocity_cmt__QuoteId__c from vlocity_cmt__ContractLineItem__c where vlocity_cmt__ContractId__c =:contractID AND vlocity_cmt__LineStatus__c != 'Cancelled' AND vlocity_cmt__LineStatus__c != 'Terminated' AND vlocity_cmt__OriginalLineItemId__c = null])
        {
            system.debug('cli'+cli);
            if(i == 0)
            {   
                Map<String, Object> eachRecContract = pushEachRecordforContract(cli);
                i++;
                if(!eachRecContract.isEmpty())
                {
                    outputMap.put('Contract',eachRecContract);
                    System.debug('eachRecContractMap'+eachRecContract);
                }
            }
           // Map<String, Object> eachRecCLI = pushEachRecordforCLI(cli);
           // childcli.add(eachRecCLI);
            cliIds.add(cli.SWAN_Service_Point__c);
             
            System.debug('childclisizeListsize'+cliIds.size());
        }
        if(cliIds.size() > 0)
                {
                    outputMap.put('ContractLine',cliIds);
                }
        else{
            
            Contract conId = [SELECT id,StartDate,EndDate,vlocity_cmt__QuoteId__c from Contract where Id =:contractID];
            Map<String, Object> eachRecContract  = new Map<String, Object>();
            eachRecContract.put('EndDate', conId.EndDate);
            eachRecContract.put('QuoteId', conId.vlocity_cmt__QuoteId__c);
            eachRecContract.put('Id', conId.Id);
            eachRecContract.put('StartDate', conId.StartDate);
            outputMap.put('Contract',eachRecContract);
            
        }       
        return true;
    }
        
    public Map<String, Object> pushEachRecordforContract(vlocity_cmt__ContractLineItem__c cli)
        {
            Map<String, Object> eachRecContract = new Map<String, Object>();
            eachRecContract.put('EndDate', cli.vlocity_cmt__ContractId__r.EndDate);
            eachRecContract.put('QuoteId', cli.vlocity_cmt__ContractId__r.vlocity_cmt__QuoteId__c);
            eachRecContract.put('Id', cli.vlocity_cmt__ContractId__c);
            eachRecContract.put('StartDate', cli.vlocity_cmt__ContractId__r.StartDate);
            return eachRecContract;
        }
        
   /* public Map<String, Object> pushEachRecordforCLI(vlocity_cmt__ContractLineItem__c cli)
        {
            Map<String, Object> eachRecCLI = new Map<String, Object>();
            eachRecCLI.put('Id', cli.Id);
            eachRecCLI.put('SWANServicePoint', cli.SWAN_Service_Point__c);
            return eachRecCLI;
        }*/
}