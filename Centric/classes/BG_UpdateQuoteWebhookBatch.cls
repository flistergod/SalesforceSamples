global class BG_UpdateQuoteWebhookBatch implements Database.Batchable<sObject> {

    string QuoteStatus;
    string masterQuoteId;
    global BG_UpdateQuoteWebhookBatch(string masterQuoteId, string QuoteStatus) {
         this.masterQuoteId = masterQuoteId;
         this.QuoteStatus= QuoteStatus; 
     }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
         String query='SELECT id,status from quote where (id=\''+masterQuoteId+'\' or vlocity_cmt__ParentQuoteId__c=\''+masterQuoteId+'\') AND recordtype.developername!=\'GroupCart\'';
         return Database.getQueryLocator(query);
     }
     
     global void execute(Database.BatchableContext BC, List<Quote> quoteList){
         for(Quote qt : quoteList){
             qt.status=QuoteStatus;
         }
         update quoteList;
     }
     global void finish(Database.BatchableContext BC)
     {}
}