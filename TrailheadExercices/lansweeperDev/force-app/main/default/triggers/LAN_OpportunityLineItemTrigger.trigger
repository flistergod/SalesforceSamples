trigger LAN_OpportunityLineItemTrigger on OpportunityLineItem (before insert, after insert, before update, after update) {
    new LAN_OpportunityLineItemTriggerHandler().run();
}