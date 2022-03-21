trigger IndicativeQuotePriceMatrixDomainTrigger on IndicativeQuotePriceMatrix__c (before insert, before update, after update) {
    SObjectDomain.handleTrigger(IndicativeQuotePriceMatrixDomain.class);
    
}