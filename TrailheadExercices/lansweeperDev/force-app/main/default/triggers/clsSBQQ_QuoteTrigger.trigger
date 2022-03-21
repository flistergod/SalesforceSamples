trigger clsSBQQ_QuoteTrigger on SBQQ__Quote__c (before insert, after insert, before update, after update) {
    new clsSBQQ_QuoteTriggerHandler().run();
}