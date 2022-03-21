public with sharing class LAN_clsInvocableMergeRenewalSubsLines {
    @InvocableMethod
    public static List<List<SBQQ__QuoteLine__c>> mergeQuoteLines(List<List<SBQQ__QuoteLine__c>> lstDuplicateRenewedQuoteLines) {
        System.Debug('LAN_clsInvocableMergeRenewalSubsLines --> Incoming: ' + lstDuplicateRenewedQuoteLines);
        Map<Id, SBQQ__QuoteLine__c> mapQuotes = new Map<Id, SBQQ__QuoteLine__c>();

        for(SBQQ__QuoteLine__c q : lstDuplicateRenewedQuoteLines[0]) {
            System.Debug('LAN_clsInvocableMergeRenewalSubsLines --> Map: ' + mapQuotes);
            System.Debug('LAN_clsInvocableMergeRenewalSubsLines --> Q.Product: ' + q.SBQQ__Product__c);
            if(!mapQuotes.containsKey(q.SBQQ__Product__c)) {
                mapQuotes.put(q.SBQQ__Product__c, q);
            } else {
                mapQuotes.get(q.SBQQ__Product__c).SBQQ__Quantity__c += q.SBQQ__Quantity__c;
            }
        }

        System.Debug('LAN_clsInvocableMergeRenewalSubsLines --> Map: ' + mapQuotes);

        List<SBQQ__QuoteLine__c> lstResult = new List<SBQQ__QuoteLine__c>(mapQuotes.values());
        return new List<List<SBQQ__QuoteLine__c>>{lstResult};
    }
}