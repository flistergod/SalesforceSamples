/**
 * Opportunity domain trigger.
 */
trigger OpportunityDomainTrigger on Opportunity (after insert, before update) {
	SObjectDomain.handleTrigger(OpportunityDomain.class);
}