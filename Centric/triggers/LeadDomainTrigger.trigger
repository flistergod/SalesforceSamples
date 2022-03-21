/**
 * Lead domain trigger.
 */
trigger LeadDomainTrigger on Lead (after insert) {
    SObjectDomain.handleTrigger(LeadDomain.class);
}