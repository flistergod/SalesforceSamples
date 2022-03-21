public class LAN_clsHandleCurrencyChange {
    @TestVisible private static SBQQ__Quote__c testQuote;
    
    @InvocableMethod(label='Quote - Handle Currency Change')
    public static void handleQuoteCurrencyChange(List<LAN_clsCurrencyChange> quotes) {
        if(quotes == null || quotes.size() == 0) throw new LAN_clsHandleCurrencyChange.LAN_clsHandleCurrencyChangeException('Mising required input parameter Quotes');

        // NOTE: process will only be run for 1 quote. Multiple quotes cannot use this process
        // Assumption was made to only fire this logic from a button
        System.Debug('LAN_clsHandleCurrencyChange: Incoming Parameters -> ' + quotes[0]);
        handleCurrencyChange(quotes[0]);
    }

    public static void verifyCurrencies(List<Id> lstUpdatedQuotes) {
        System.Debug('LAN_clsHandleCurrencyChange.verifyCurrencies -> START');
        if(lstUpdatedQuotes.size() > 0) {
            List<LAN_clsHandleCurrencyChange.LAN_clsCurrencyChange> lstQuotesToHandleCurrencyChange = new List<LAN_clsHandleCurrencyChange.LAN_clsCurrencyChange>();

            for(SBQQ__Quote__c q : [SELECT Id, LAN_Update_Currency__c, LAN_Quote_Event_Trigger__c, SBQQ__Opportunity2__c, SBQQ__Opportunity2__r.CurrencyIsoCode, LAN_Currency__c FROM SBQQ__Quote__c WHERE Id IN :lstUpdatedQuotes]) {
                // Due to event issue in CDC, workaround to set the values
                if(Test.isRunningTest()) {
                    q = testQuote;
                }
                System.Debug(q);
                if(q.LAN_Update_Currency__c) {
                    LAN_clsHandleCurrencyChange.LAN_clsCurrencyChange c = new LAN_clsHandleCurrencyChange.LAN_clsCurrencyChange();
                    c.quoteId = q.Id; 

                    if(q.SBQQ__Opportunity2__r.CurrencyIsoCode != q.LAN_Currency__c) {
                        c.opportunityId = q.SBQQ__Opportunity2__c;
                    }
                    c.currencyIsoCode = q.LAN_Currency__c;

                    lstQuotesToHandleCurrencyChange.add(c); 
                } else if(q.LAN_Quote_Event_Trigger__c == 'LAN_Currency_Change') {
                    LAN_clsHandleCurrencyChange.setPrimaryQuote(q.Id);
                }                      
            }

            if(lstQuotesToHandleCurrencyChange.size() > 0) {
                LAN_clsHandleCurrencyChange.handleQuoteCurrencyChange(lstQuotesToHandleCurrencyChange);
            }
        }
    }

    public static void handleQuoteOppty(LAN_clsHandleCurrencyChange.LAN_clsCurrencyChange quote) {
        System.Debug('LAN_clsHandleCurrencyChange.handleQuoteOppty -> START');
        // Check if there are primary quotes on the opportunity
        List<SBQQ__Quote__c> lstOriginalPrimaryQuotes = [SELECT Id, SBQQ__Primary__c, SBQQ__LineItemCount__c FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c = :quote.opportunityId];
        
        if(lstOriginalPrimaryQuotes != null && lstOriginalPrimaryQuotes.size() > 0) {
            for(SBQQ__Quote__c q : lstOriginalPrimaryQuotes) {
                q.SBQQ__Primary__c = false;
            }

            System.Debug('LAN_clsHandleCurrencyChange: Update Primary Quotes');
            update lstOriginalPrimaryQuotes;
        }

        // Remove any products on the Opportunity
        List<OpportunityLineItem> lstOpptyProducs = [SELECT Id FROM OpportunityLineItem WHERE opportunityId = :quote.opportunityId];
        if(lstOpptyProducs != null && lstOpptyProducs.size() > 0) {
            System.Debug('LAN_clsHandleCurrencyChange: Delete Opportunity Products');
            delete lstOpptyProducs;
        }

        // Change Currency on Opportunity toward the new currency
        Opportunity changedOppty = new Opportunity(Id = quote.opportunityId, currencyIsoCode = quote.currencyIsoCode);
        System.Debug('LAN_clsHandleCurrencyChange: Update Opportunity Currency');
        update changedOppty;
    }

    public static Boolean handlePrimaryQuote(LAN_clsHandleCurrencyChange.LAN_clsCurrencyChange quote) {
        System.Debug('LAN_clsHandleCurrencyChange.handlePrimaryQuote -> START');
        Boolean hasLineItems = false;
        List<SBQQ__Quote__c> lstOriginalPrimaryQuotes = [SELECT SBQQ__Primary__c, SBQQ__LineItemCount__c FROM SBQQ__Quote__c WHERE Id = :quote.quoteId];
        for(SBQQ__Quote__c q : lstOriginalPrimaryQuotes) {
            if(q.Id == quote.quoteId && q.SBQQ__LineItemCount__c > 0) {
                hasLineItems = true;
            }

            if(q.SBQQ__Primary__c) q.SBQQ__Primary__c = false;
        }

        update lstOriginalPrimaryQuotes;
        return hasLineItems;
    }

    public static void handleCurrencyChange(LAN_clsHandleCurrencyChange.LAN_clsCurrencyChange quote) {
        System.Debug('LAN_clsHandleCurrencyChange.handleCurrencyChange -> START');
        try {
            Boolean hasLineItems = false;
            List<SBQQ__QuoteLine__c> lstClonedQuoteLines = new List<SBQQ__QuoteLine__c>();

            if(quote.quoteId == null || quote.currencyIsoCode == null) {
                throw new LAN_clsHandleCurrencyChange.LAN_clsHandleCurrencyChangeException('Misssing required parameters');
            }

            if(quote.opportunityId != null) {
                handleQuoteOppty(quote);
            }

            hasLineItems = handlePrimaryQuote(quote);

            //TODO: If it's an existing quote, then remove the products and replace them with products from the right pricebook and currency
            if(hasLineItems) {
                Set<Id> productIds = new Set<Id>();
                Map<Id, Id> mapProductWithPBE = new Map<Id, Id>();
                List<SBQQ__QuoteLine__c> lstQuoteLinesToDelete = new List<SBQQ__QuoteLine__c>();
                Map<String, Schema.SObjectField> quoteLineFields = Schema.SObjectType.SBQQ__QuoteLine__c.fields.getMap();
                String queryLineItems = 'SELECT ' + String.join(new List<String>(quoteLineFields.keySet()), ',');
                System.Debug(queryLineItems);
                queryLineItems += ' FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = \'' + quote.quoteId + '\'';
                
                for(SBQQ__QuoteLine__c qli : Database.query(queryLineItems)) {
                    SBQQ__QuoteLine__c qliClone = qli.clone(false, false, false, false);
                    qliClone.CurrencyIsoCode = quote.currencyIsoCode;
                    lstClonedQuoteLines.add(qliClone);
                    lstQuoteLinesToDelete.add(qli);
                    productIds.add(qli.SBQQ__Product__c);
                }

                for(PricebookEntry pbe : [SELECT Id, Product2Id FROM PricebookEntry WHERE Product2Id IN :productIds AND CurrencyIsoCode = :quote.currencyIsoCode]) {
                    mapProductWithPBE.put(pbe.Product2Id, pbe.Id);
                }

                for(SBQQ__QuoteLine__c qli : lstClonedQuoteLines) {
                    qli.SBQQ__PriceBookEntryId__c = mapProductWithPBE.get(qli.SBQQ__Product__c);
                }

                delete lstQuoteLinesToDelete;
            }

            // Set the Quote to Primary
            SBQQ__Quote__c updatedQuote = new SBQQ__Quote__c(Id = quote.quoteId, currencyIsoCode = quote.currencyIsoCode, 
            LAN_Update_Currency__c = false, LAN_Quote_Event_Trigger__c = 'LAN_Currency_Change');
            System.Debug('LAN_clsHandleCurrencyChange: Update Quote currency');
            update updatedQuote;

            insert lstClonedQuoteLines;
        } catch(Exception e) {
            SBQQ__Quote__c updatedQuote = new SBQQ__Quote__c(Id = quote.quoteId, 
            LAN_Update_Currency__c = false, LAN_Quote_Event_Trigger__c = null);
            System.Debug('LAN_clsHandleCurrencyChange: Quote Currency Failed');
            update updatedQuote;
        }
    }

    public static void checkUpdateCurrencyFlag(List<String> quoteIds) {
        System.Debug('LAN_clsHandleCurrencyChange.checkUpdateCurrencyFlag -> START');
        if(quoteIds != null) {
            List<SBQQ__Quote__c> lstQuotes = new List<SBQQ__Quote__c>();

            for(SBQQ__Quote__c q : [SELECT LAN_Currency__c, CurrencyIsoCode, SBQQ__Opportunity2__r.CurrencyIsoCode FROM SBQQ__Quote__c WHERE Id IN :quoteIds]) {
                if(q.CurrencyIsoCode != q.SBQQ__Opportunity2__r.CurrencyIsoCode || q.LAN_Currency__c != q.SBQQ__Opportunity2__r.CurrencyIsoCode) {
                    lstQuotes.add(new SBQQ__Quote__c(Id = q.Id, LAN_Update_Currency__c = true));
                }
            }

            if(lstQuotes.size() > 0) update lstQuotes;
        }
    }

    public static void setPrimaryQuote(Id quoteId) {
        System.Debug('LAN_clsHandleCurrencyChange.setPrimaryQuote -> START');
        List<SBQQ__Quote__c> lstQuotes = new List<SBQQ__Quote__c>();
        lstQuotes.add(new SBQQ__Quote__c(Id = quoteId, SBQQ__Primary__c = true, LAN_Quote_Event_Trigger__c = null));

        if(lstQuotes.size() > 0) update lstQuotes;
    }

    public static void setUpdateCurrencyFlag(List<String> quoteIds) {
        System.Debug('LAN_clsHandleCurrencyChange.setUpdateCurrencyFlag -> START');
        if(quoteIds != null) {
            List<SBQQ__Quote__c> lstQuotes = new List<SBQQ__Quote__c>();
            for(String quoteId : quoteIds) {
                lstQuotes.add(new SBQQ__Quote__c(Id = quoteId, LAN_Update_Currency__c = true));
            }

            if(lstQuotes.size() > 0) update lstQuotes;
        }
    }

    public class LAN_clsCurrencyChange {
        @InvocableVariable(required=true)
        public Id quoteId;

        @InvocableVariable(required=true)
        public Id opportunityId;

        @InvocableVariable(required=true)
        public String currencyIsoCode;
    }

    public class LAN_clsHandleCurrencyChangeException extends Exception {}
}