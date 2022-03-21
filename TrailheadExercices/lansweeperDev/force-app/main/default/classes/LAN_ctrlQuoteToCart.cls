public with sharing class LAN_ctrlQuoteToCart {
    private static final String QTC_KEY = 'URL';
    
    public static final String NAMED_CRED_QUOTE_TO_CART = 'callout:LAN_Quote_to_Cart';

    public class LAN_ctrlQuoteToCartNoResultException extends Exception {}

    // Pass in the record id of the Quote
    // Make a callout and return the URL
    /**
        Description: get the Quote-to-Cart URL for Cleverbridge based on the provided Quote Id
    */
    @AuraEnabled(cacheable=true)
    public static String getQtCUrl(String quoteId){
        LAN_clsRESTService req = new LAN_clsRESTService();
        req.setEndpoint(NAMED_CRED_QUOTE_TO_CART);
        req.setMethod('POST');
        req.setCustomHeader('cache-control', 'no-cache');
        req.setCustomHeader('Content-Type', 'text/plain');
        req.setAuthSubscriptionKey();
        req.setBodyAsString(getCalloutBody(quoteId));

        System.Debug('LAN_ctrlQuoteToCart:getQtCUrl:req -> ' + req);

        HttpResponse resp = req.invokeCallout();

        switch on resp.getStatusCode() {
            when 200, 201 {
                return returnURL(resp);
            } when 500 {
                throw new LAN_ctrlQuoteToCart.LAN_ctrlQuoteToCartNoResultException('We are not able to talk to Cleverbridge. Please contact your System Adminitrator (Status Code 500)');
            } when else {
                throw new LAN_ctrlQuoteToCart.LAN_ctrlQuoteToCartNoResultException('An unexpected issue happened. Please contact your System Adminitrator.');
            }
        }
    }

    private static String getCalloutBody(String quoteId) {
        System.Debug('LAN_ctrlQuoteToCart:getCalloutBody:quoteId -> ' + quoteId);
        QuoteWrapper w = new QuoteWrapper(new QuoteIdWrapper(quoteId));
        System.Debug(JSON.serialize(w));
        return JSON.serialize(w);
    }

    private static String returnURL(HttpResponse resp) {
        System.Debug('LAN_ctrlQuoteToCart:getQtCUrl:Response -> ' + resp.getBody());
        Map<String, Object> mapResult = (Map<String, Object>) JSON.deserializeUntyped(resp.getBody());
        System.Debug('LAN_ctrlQuoteToCart:getQtCUrl:Response Parsed -> ' + mapResult);

        if(!mapResult.containsKey(QTC_KEY)) {
            throw new LAN_ctrlQuoteToCart.LAN_ctrlQuoteToCartNoResultException();
        }

        return (String) mapResult.get(QTC_KEY);
    }

    /**
        Inner class
    */
    private class QuoteWrapper {
        private QuoteIdWrapper Quote;
        
        private QuoteWrapper(QuoteIdWrapper QuoteId) {
            this.Quote = QuoteId;
        }
    }

    private class QuoteIdWrapper {
        private String Id;

        private QuoteIdWrapper(String Id) {
            this.Id = Id;
        }
    }
}