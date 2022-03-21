global with sharing class  SWAN_CreateServiceQuotes implements vlocity_cmt.VlocityOpenInterface {
    
    
    
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
            if (methodName.equals('createServiceQuotes')) {
                
                createServiceQuotes(inputMap,outputMap,options);
                
            }else if(methodName.equals('checkQuoteName')){
                
                checkQuoteName(inputMap,outputMap,options);
               
            }else{
                result = false;
                
            }   
            
        }catch(Exception e){
            
            System.debug('SWAN_FetchQuotes:invokeMethod -> exception: '+e);
            result = false;
        }
        
        return result;
    
    }
    
    private Boolean createServiceQuotes(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
        
        String MasterQuoteId = String.ValueOf(inputMap.get('MasterQuoteId'));
        String ClonnedMasterQuoteId = String.ValueOf(inputMap.get('ClonnedMasterQuoteId'));
        List<Quote> lstClonnedQuotes =   (List<Quote>)JSON.deserialize(JSON.serialize(inputMap.get('ClonnedMasterQuoteId')), List<Quote>.class) ;
      
        

        
        try{           
            Database.executeBatch(new CloneQuotes(MasterQuoteId, lstClonnedQuotes));
        }catch(Exception e) {
            
            String er =e.getMessage();
            outputMap.put('ErrorClonningServiceQuotes ' ,er );
          
        }
        
        return true;
    }
    
    
   private Boolean checkQuoteName(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
        
       List<String> NewQuoteName = (List<String>)JSON.deserialize(JSON.serialize(inputMap.get('NewQuoteName')) , List<String>.class );

       List<Quote> lstQuote = [Select Name from Quote Where Name in : NewQuoteName  ];
       
       if(lstQuote.size() > 0 ){
           
        	outputMap.put('error' ,'true' );
            outputMap.put('lstInvalidNames' , lstQuote );
       }else{
           outputMap.put('error' ,'false' );
       }
       
       return true;
    }
    
 
}