global with sharing class SWAN_CallCheckCommodity implements vlocity_cmt.VlocityOpenInterface {

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

        if (methodName == 'callIntegration') return callIntegration(inputMap, outputMap, options);  
        
        return false;
    }
    
    /**
     * This method will attempt to call integration procedure of commodity check
     *
     * @param inputMap  - The input provided to the Remote Action
     * @param outputMap - The output map provided to the Remote Action
     * @param options   - Any options to aid in the execution of this class
     *
     * @returns true if this method completes successfully, false otherwise
     */
    private Boolean callIntegration(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
       
            Boolean bHasExpiredQuote = false;
       
       try{
          system.debug('Begin SWANCheckOfferCommodity:CheckOfferCommodity'+inputMap.get('OfferPackId'));
          
          /* Initialize variables */
          String VIPprocedureName = 'BGGorillaPricingEngine_BGCheckCommotity';
          Map <String, Object> ipInput = new Map <String, Object> ();
          Map <String, Object> ipOutput = new Map <String, Object> ();
          Map <String, Object> ipOptions = new Map <String, Object> ();
          String strOfferId= String.ValueOf(inputMap.get('OfferPackId'));

          // Loop through all Master quotes within the Offer Pack 
          // in order to check the validity of the commodity curve
          if (!Schema.sObjectType.SWAN_Offer_Pack_Quote__c.fields.SWAN_Quote__c.isAccessible()) {
              return false;
          }
          List<SWAN_Offer_Pack_Quote__c> listQuote = [select SWAN_Quote__c from SWAN_Offer_Pack_Quote__c where SWAN_Offer_Pack__c =: strOfferId];
          
          List<Quote> listMasterQuote = new List<Quote>();
          //Boolean bHasExpiredQuote = false;

          system.debug('SWANCheckOfferCommodity:CheckOfferCommodity Number of Master Quotes: ' + listQuote.size());
       
          for(Integer iQuoteIndex = 0; iQuoteIndex < listQuote.size();iQuoteIndex++){
      
             String strCurrentMasterQuoteId = listQuote.get(iQuoteIndex).SWAN_Quote__c;
             ipInput.put('ContextId', strCurrentMasterQuoteId);
             ipInput.put('SkipUpdate', 'Y');
             ipInput.put('CommodityObject','');
             system.debug('SWANCheckOfferCommodity:CheckOfferCommodity Master Quotes Id: ' + strCurrentMasterQuoteId);
         
             // Call the IP via runIntegrationService
             ipOutput = (Map <String, Object>) vlocity_cmt.IntegrationProcedureService.runIntegrationService(VIPprocedureName, ipInput, ipOptions);
         
             system.debug('SWANCheckOfferCommodity:CheckOfferCommodity Master Quotes Expired: ' + ipOutput.get('IsExpired'));
             system.debug('SWANCheckOfferCommodity:CheckOfferCommodity Response: ' + ipOutput.get('res'));
                      
             if(ipOutput.get('IsExpired') == true)
             {            
                //if(listMasterQuote.size() > 0){
                 Quote qt = new Quote(Id = strCurrentMasterQuoteId,SWAN_Price_out_of_Date__c=true);
                    listMasterQuote.add(qt); bHasExpiredQuote = true;
                    system.debug('SWANCheckOfferCommodity:CheckOfferCommodity Update Expired: ' + ipOutput.get('IsExpired')+'quote='+qt);
               // }
             }
          }
            if(!listMasterQuote.isEmpty())
            {
             if (!Schema.sObjectType.Quote.isUpdateable()) {
                 return false;   }
                update listMasterQuote;
            }
            outputMap.put('expired',bHasExpiredQuote);
          system.debug('End SWANCheckOfferCommodity:CheckOfferCommodity'+bHasExpiredQuote);
             
      }
      catch(Exception e){
         system.debug('SWANCheckOfferCommodity:CheckOfferCommodity Exception: ' + e.getMessage());
         system.debug('SWANCheckOfferCommodity:CheckOfferCommodity Exception: ' + e.getStackTraceString());
      }
      return bHasExpiredQuote;
    }
}