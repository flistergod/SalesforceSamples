trigger clsSBQQ_QuoteDocumentTrigger on SBQQ__QuoteDocument__c (after insert) {
    new clsSBQQ_QuoteDocumentTriggerHandler().run();
}