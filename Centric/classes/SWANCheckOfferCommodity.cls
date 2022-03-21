public with sharing class SWANCheckOfferCommodity {
   /* 
    public Boolean CheckOfferCommodity(String strOfferId) {
    
       Boolean bHasExpiredQuote = false;
       
       try{
          system.debug('Begin SWANCheckOfferCommodity:CheckOfferCommodity');
       
          // Initialize variables 
          String VIPprocedureName = 'BGGorillaPricingEngine_BGCheckCommotity';
          Map <String, Object> ipInput = new Map <String, Object> ();
          Map <String, Object> ipOutput = new Map <String, Object> ();
          Map <String, Object> ipOptions = new Map <String, Object> ();

          // Loop through all Master quotes within the Offer Pack 
          // in order to check the validity of the commodity curve

          List<SWAN_Offer_Pack_Quote__c> listQuote = [select SWAN_Quote__c from SWAN_Offer_Pack_Quote__c where SWAN_Offer_Pack__c =: strOfferId];
      
          //Boolean bHasExpiredQuote = false;

          system.debug('SWANCheckOfferCommodity:CheckOfferCommodity Number of Master Quotes: ' + listQuote.size());
       
          for(Integer iQuoteIndex = 0; iQuoteIndex < listQuote.size();iQuoteIndex++){
      
             String strCurrentMasterQuoteId = listQuote.get(iQuoteIndex).SWAN_Quote__c;
             ipInput.put('ContextId', strCurrentMasterQuoteId);
             ipInput.put('SkipUpdate', 'Y');
             system.debug('SWANCheckOfferCommodity:CheckOfferCommodity Master Quotes Id: ' + strCurrentMasterQuoteId);
         
             // Call the IP via runIntegrationService
             ipOutput = (Map <String, Object>) vlocity_cmt.IntegrationProcedureService.runIntegrationService(VIPprocedureName, ipInput, ipOptions);
         
             system.debug('SWANCheckOfferCommodity:CheckOfferCommodity Master Quotes Expired: ' + ipOutput.get('IsExpired'));
             system.debug('SWANCheckOfferCommodity:CheckOfferCommodity Response: ' + ipOutput.get('res'));
                      
             if(ipOutput.get('IsExpired') == true){            
                List<Quote> listMasterQuote = [select SWAN_Is_Commodity_Curve_Expired__c from Quote where Id =: strCurrentMasterQuoteId];
                if(listMasterQuote.size() > 0){
                   listMasterQuote.get(0).SWAN_Price_out_of_Date__c = true;
                   update listMasterQuote;
                   bHasExpiredQuote = true;
                   system.debug('SWANCheckOfferCommodity:CheckOfferCommodity Update Expired: ' + ipOutput.get('IsExpired'));
                }
             }
          }
      
          system.debug('End SWANCheckOfferCommodity:CheckOfferCommodity');
             
      }
      catch(System.CalloutException e){
         system.debug('SWANCheckOfferCommodity:CheckOfferCommodity Service Callout Exception: ' + e.getMessage());
         system.debug('SWANCheckOfferCommodity:CheckOfferCommodity Service Callout Exception: ' + e.getCause());
         system.debug('SWANCheckOfferCommodity:Exception: ' + e.getStackTraceString());
      }
      catch(Exception e){
         system.debug('SWANCheckOfferCommodity:CheckOfferCommodity Exception: ' + e.getMessage());
         system.debug('SWANCheckOfferCommodity:CheckOfferCommodity Exception: ' + e.getStackTraceString());
      }
      return bHasExpiredQuote;   
    }*/
}