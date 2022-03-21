public class LAN_ctrlSubscription {
    
    @AuraEnabled(Cacheable=true)
    public static String getOpptySubscriptions(string opptyId, Integer pagenumber, Integer pageSize, Integer lastRecordPosition, String searchString) {
        try {
            List<Opportunity> oppty = [select Id, SBQQ__RenewedContract__c, SBQQ__AmendedContract__c from Opportunity where Id =:opptyId];
            List<SBQQ__Subscription__c> opptySubscriptions = [select Id, Name, SBQQ__ProductName__c, SBQQ__StartDate__c, SBQQ__EndDate__c, LAN_License_Key_Location__c from SBQQ__Subscription__c 
                                                                where SBQQ__Contract__c = :oppty[0].SBQQ__RenewedContract__c or SBQQ__Contract__c = :oppty[0].SBQQ__AmendedContract__c or LAN_Opportunity_Id__c =:oppty[0].Id];
            return JSON.serialize(opptySubscriptions);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(Cacheable=true)
    public static integer getOpptySubscriptionsCount(string opptyId, string searchString) {
        integer subscriptionsCount = 0;
        try {
            List<Opportunity> oppty = [select Id, SBQQ__RenewedContract__c, SBQQ__AmendedContract__c from Opportunity where Id =:opptyId];
            List<AggregateResult> opptySubscriptions = [select count(Id)countIDs from SBQQ__Subscription__c 
                                                            where SBQQ__Contract__c = :oppty[0].SBQQ__RenewedContract__c or SBQQ__Contract__c = :oppty[0].SBQQ__AmendedContract__c or LAN_Opportunity_Id__c =:oppty[0].Id];
            if (!opptySubscriptions.isEmpty()) {
                subscriptionsCount = (Integer)opptySubscriptions[0].get('countIDs');
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return subscriptionsCount;
    }
}