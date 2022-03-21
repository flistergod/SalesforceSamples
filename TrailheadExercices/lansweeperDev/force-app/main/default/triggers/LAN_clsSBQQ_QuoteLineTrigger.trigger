trigger LAN_clsSBQQ_QuoteLineTrigger on SBQQ__QuoteLine__c (before insert, after insert, before update, after update) {
    new LAN_clsSBQQ_QuoteLineTriggerHandler().run();
}