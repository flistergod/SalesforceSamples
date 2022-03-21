trigger LAN_clsOCRTrigger on OpportunityContactRole (before insert, before update) {
    new LAN_clsOCRTriggerHandler().run();
}