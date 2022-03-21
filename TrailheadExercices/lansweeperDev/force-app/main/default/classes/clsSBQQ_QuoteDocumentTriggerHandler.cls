public with sharing class clsSBQQ_QuoteDocumentTriggerHandler extends TriggerHandler {
    private Map<Id, SBQQ__QuoteDocument__c> newQuoteDocMap;
    private Map<Id, SBQQ__QuoteDocument__c> oldQuoteDocMap;
    private List<SBQQ__QuoteDocument__c> newQuoteDocs;
  
    
    
    public clsSBQQ_QuoteDocumentTriggerHandler() {
        this.newQuoteDocMap = (Map<Id, SBQQ__QuoteDocument__c>) Trigger.newMap;
        this.oldQuoteDocMap = (Map<Id, SBQQ__QuoteDocument__c>) Trigger.oldMap;
        this.newQuoteDocs = (List<SBQQ__QuoteDocument__c>) Trigger.new;
    }

    public override void afterInsert() {
        System.Debug('clsSBQQ_QuoteDocumentTriggerHandler.afterInsert --> Trigger ran: ' + clsTriggerHelpers.getTriggerRan('clsSBQQ_QuoteDocumentTriggerHandler.afterInsert'));
        if(!clsTriggerHelpers.getTriggerRan('clsSBQQ_QuoteDocumentTriggerHandler.afterInsert')) {
            this.onQuoteDocumentInsert();
        }
    }

    private void onQuoteDocumentInsert() {
        clsTriggerHelpers.setTriggerRan('clsSBQQ_QuoteDocumentTriggerHandler.afterInsert');
        
        List<SBQQ__Quote__c> quotes= new List<SBQQ__Quote__c>();
        
        for(SBQQ__QuoteDocument__c doc: newQuoteDocs){
            
            SBQQ__Quote__c quote= [select Id, LAN_Main_Quote_Document_Id__c from SBQQ__Quote__c where Id=:doc.SBQQ__Quote__c];
            quote.LAN_Main_Quote_Document_Id__c=doc.Id;
            quote.LAN_Partner_Quote_Calculated__c = true;
            
            quotes.add(quote);           
        }
        update quotes;
    }
}