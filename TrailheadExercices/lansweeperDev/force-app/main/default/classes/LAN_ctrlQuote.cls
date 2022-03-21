public class LAN_ctrlQuote {
    
    @AuraEnabled
    public static String getOpptyQuotes(string opptyId, Integer pagenumber, Integer pageSize, Integer lastRecordPosition, String searchString) {
        try {
            List<SBQQ__Quote__c> opptyQuotes = [select Id, LAN_Quote_Number__c, SBQQ__ListAmount__c, SBQQ__PartnerDiscount__c, SBQQ__NetAmount__c, LAN_Subscription_term_in_years__c, SBQQ__ExpirationDate__c, LAN_Quote_to_Cart__c, LAN_Main_Quote_Document_Id__c from SBQQ__Quote__c where SBQQ__Opportunity2__c = :opptyId];

            return JSON.serialize(opptyQuotes);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(Cacheable=true)
    public static integer getOpptyQuotesCount(string opptyId, string searchString) {
        integer quotesCount = 0;
        try {
            List<AggregateResult> opptyQuotes = [select count(Id)countIDs from SBQQ__Quote__c where SBQQ__Opportunity2__c = :opptyId];
            if (!opptyQuotes.isEmpty()) {
                quotesCount = (Integer)opptyQuotes[0].get('countIDs');
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return quotesCount;
    }
}