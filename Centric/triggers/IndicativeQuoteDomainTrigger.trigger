trigger IndicativeQuoteDomainTrigger on IndicativeQuote__c (after insert) {
	SObjectDomain.handleTrigger(IndicativeQuoteDomain.class);
}