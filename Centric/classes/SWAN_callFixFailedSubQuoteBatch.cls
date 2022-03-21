global with sharing class SWAN_callFixFailedSubQuoteBatch implements vlocity_cmt.VlocityOpenInterface {

     global Boolean invokeMethod(String methodName,
                                Map < String, Object > input,
                                Map < String, Object > output,
                                Map < String, Object > options) {
                                
                                    if(methodName == 'callFixFailedSubQuote')
                                    {
                                        return callFixFailedSubQuote(input,output,options);
                                    }
                                    
                                    return false;
                                }
                                
        public boolean callFixFailedSubQuote(Map < String, Object > input,Map < String, Object > output,Map < String, Object > options){
        
            String masterQuoteId = (String) input.get('ContextId');
              
              FixFailedSubQuotes batchObj = new FixFailedSubQuotes(masterQuoteId);
              database.executeBatch(batchObj,20);
              
              return true;
        
        }
}