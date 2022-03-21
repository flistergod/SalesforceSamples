/**
* IndicativeQuote Domain
*/
public without sharing class IndicativeQuoteDomain extends SObjectDomain {
    
    //==================================================================================================================
    // Core
    //==================================================================================================================
    
    public override SObjectType getSObjectType() {
        return IndicativeQuote__c.SObjectType; 
    }
    
    //==================================================================================================================
    // Event Handlers
    //==================================================================================================================
    
    //Trigger context goes here
    /*
    protected override void beforeInsert(List<SObject> records) {

         
    }
       
    
    protected override void beforeUpdate(Map<Id, SObject> updatedRecords, Map<Id, SObject> oldRecords) {
       
    }
    */
    protected override void afterInsert(Map<Id, SObject> records) {        
        System.debug('After Insert');
        setQuoteUniqueReferenceNumber(records.keyset());
    }    
    /*
    protected override void afterUpdate(Map<Id, SObject> updatedRecords, Map<Id, SObject> oldRecords) {        
        
    }
    */
    
    //==================================================================================================================
    // Automation
    //==================================================================================================================
    
    //Logic Methods go here
    
    //==================================================================================================================
    // Auxiliar Methods
    //==================================================================================================================
    
    // US 7589
    private void setQuoteUniqueReferenceNumber(Set<Id> setIdsQuotes){
        System.debug('After');
        List<IndicativeQuote__c> listQuotes = [Select Id, RecordTypeId, QuoteAutoNumber__c, UniqueReferenceNumber__c FROM IndicativeQuote__c WHERE Id IN :setIdsQuotes];
        final String[] chars = new String[]{'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z'};
        
        String[] arr = new String[3];
        Integer idx;
        List<IndicativeQuote__c> updatedQuotes = new List<IndicativeQuote__c>();
        for(IndicativeQuote__c varQuote : listQuotes){
            System.debug(varQuote);
            arr[0] = chars[(Integer)(Math.random()*(chars.size()-1))];
            arr[1] = chars[(Integer)(Math.random()*(chars.size()-1))];
            arr[2] = chars[(Integer)(Math.random()*(chars.size()-1))];
            String autonumber = varQuote.QuoteAutoNumber__c;
            System.debug(autonumber);
            varQuote.UniqueReferenceNumber__c = arr[0]+arr[1]+autonumber+arr[2];
            System.debug(varQuote);
            updatedQuotes.add(varQuote);
        }
        System.debug('updatedQuotes');
        if(updatedQuotes.size() > 0){
            update updatedQuotes;
        }
        
    }
}