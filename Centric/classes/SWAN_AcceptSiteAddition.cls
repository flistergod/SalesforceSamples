global with sharing class  SWAN_AcceptSiteAddition implements vlocity_cmt.VlocityOpenInterface {
    
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
        try{
            if (methodName.equals('acceptSiteAddition')) {
                
                acceptSiteAddition(inputMap,outputMap,options);
                
            }else{
                
                result = false;
            }   
            
        }catch(Exception e){
            
            System.debug('SWAN_FetchQuotes:invokeMethod -> exception: '+e);
            result = false;
        }
        
        return result;
    
    }
    
    private Boolean acceptSiteAddition(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
        
        
        
        String MasterQuoteId = String.ValueOf(inputMap.get('ContextId'));
        String IsExpired = String.ValueOf(inputMap.get('IsExpired'));
        String ContractId = String.ValueOf(inputMap.get('ContractId')); //ClonnedMasterQuoteId.substring(1, ClonnedMasterQuoteId.length()-1);
             
        try{
            
            Database.executeBatch(new SWAN_AcceptSiteAdditionBacth(MasterQuoteId , ContractId, IsExpired));
            
        }catch(Exception e) {
            
            String er =e.getMessage();
            outputMap.put('ErrorClonningServiceQuotes ' ,er );
          
        }
		        
        return true;

    }
    
    
    

}