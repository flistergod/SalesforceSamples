public class LAN_AutomateQuoteLinkDocAction {
    @InvocableMethod(label='Quote Link Document Generation' description='Given a quote, it determines if belongs to a partner then gets the QtC link and generates the quote document' category='Quote')
    public static void QuoteLinkDocGeneration(List<SBQQ__Quote__c> partnerQuote) {
        List<String> validLinkQuoteTypes = new List<String>{'Quote', 'Re-Quote'};
        List<String> validDocQuoteTypes = new List<String>{'Quote', 'Re-Quote', 'Renewal'};
        List<String> partnerTiers = new List<String>{'Certified', 'Expert'};
        List<String> quoteStatus = new List<String>{'Draft', 'Approved', 'Presented'};
        SBQQ__Quote__c quote = partnerQuote[0];
        system.debug('#### LAN_AutomateQuoteLinkDocAction ####');
        system.debug(quote.LAN_Opportunity_Direct__c);
        system.debug(quote.SBQQ__NetAmount__c);
        system.debug(quote.SBQQ__Status__c);
        system.debug(quote.LAN_SalesChannel__c);
        system.debug(quote.SBQQ__Type__c);

        List<Opportunity> quoteOppty = [select LAN_Partner_Tier__c, LAN_Contract_Is_AmendRenew__c, SBQQ__RenewedContract__r.LAN_Renewal_Quote_Creation_Day__c from Opportunity where Id =:quote.SBQQ__Opportunity2__c];
        system.debug(quoteOppty);
        // US SICCP 1012: if (re)calculated, obtain the QtC link and generate the document
        if (quote.LAN_SalesChannel__c == 'Partner' && quoteStatus.contains(quote.SBQQ__Status__c)) {
            if (partnerTiers.contains(quoteOppty[0].LAN_Partner_Tier__c)) {
                // the QtC link is not for renewal quotes
                if (!quote.LAN_Partner_Quote_Calculated__c && String.isBlank(quote.LAN_Quote_to_Cart__c) && validLinkQuoteTypes.contains(quote.SBQQ__Type__c) 
                    && quote.SBQQ__NetAmount__c<= 10000 && quote.LAN_Opportunity_Direct__c != 'Direct')
                {
                    generateQuoteToCartLink(quote.Id);
                }
                // US SICCP 1012: if quote is renewal and generated 90 days before the day of renewal, the quote document should be auto. created
                // check the fields LAN_Days_before_End_Date_Renewal_Quote__c and SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.LAN_Renewal_Quote_Creation_Day__c of the renew contract
                else if (String.isBlank(quote.LAN_Main_Quote_Document_Id__c) && validDocQuoteTypes.contains(quote.SBQQ__Type__c)
                        && (quote.SBQQ__Type__c != 'Renewal' || quoteOppty[0].SBQQ__RenewedContract__r.LAN_Renewal_Quote_Creation_Day__c == date.newinstance(quote.CreatedDate.year(), quote.CreatedDate.month(), quote.CreatedDate.day()))) {
                    // US 1012: generate the quote document - the doc id will be stored through the quote document trigger
                    QuoteDocumentGeneration docGenerate = new QuoteDocumentGeneration();
                    docGenerate.generateQuoteDocument(quote.Id);
                }
            }
        }
    }
    
    @future(callout=true)
    private static void generateQuoteToCartLink(String quoteId) {
        String quoteToCartLink = '';
        try {
            quoteToCartLink = LAN_ctrlQuoteToCart.getQtCUrl(quoteId);
            system.debug(quoteToCartLink);
        }
        catch(Exception ex) {
            System.debug('generateQuoteToCartLinkException line '+ ex.getLineNumber() + ' at class: LAN_ctrlQuoteToCart');
            system.debug(ex);
            quoteToCartLink = '';
        }
        SBQQ__Quote__c quoteToUpdate = new SBQQ__Quote__c();
        quoteToUpdate.Id = quoteId;

        if (String.isNotBlank(quoteToCartLink)) {
            quoteToUpdate.LAN_Quote_to_Cart__c = quoteToCartLink;
        }
        quoteToUpdate.LAN_Partner_Quote_Calculated__c = true;
        update quoteToUpdate;
    }

    private without sharing class QuoteDocumentGeneration {
        public void generateQuoteDocument(string quoteId) {
            if(!test.isRunningTest()) {
                QuoteProposalModel context = new QuoteProposalModel(quoteId);
                String jobId=SBQQ.ServiceRouter.save('SBQQ.QuoteDocumentAPI.Save', JSON.serialize(context));
            }
        }
    }
}