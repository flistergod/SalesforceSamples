trigger LAN_clsOpportunityTrigger on Opportunity (before insert, before update, after update) {
    new LAN_clsOpportunityTriggerHandler().run();
}