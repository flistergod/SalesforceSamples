public with sharing class LAN_clsOCRTriggerHandler extends TriggerHandler {
    private List<OpportunityContactRole> lstNew;

    public LAN_clsOCRTriggerHandler() {
        this.lstNew = (List<OpportunityContactRole>) Trigger.new;
    }

    public override void beforeInsert() {
        System.Debug('LAN_clsOCRTriggerHandler:beforeInsert:handlePrimaryOpptyContact --> ' + clsTriggerHelpers.getTriggerRan('LAN_clsOCRTriggerHandler:beforeInsert:handlePrimaryOpptyContact'));
        if(!clsTriggerHelpers.getTriggerRan('LAN_clsOCRTriggerHandler:beforeInsert:handlePrimaryOpptyContact')) {
            clsTriggerHelpers.setTriggerRan('LAN_clsOCRTriggerHandler:beforeInsert:handlePrimaryOpptyContact');
            this.handlePrimaryOpptyContact();
        }
    }

    public override void beforeUpdate() {
        System.Debug('LAN_clsOCRTriggerHandler:beforeUpdate:handlePrimaryOpptyContact --> ' + clsTriggerHelpers.getTriggerRan('LAN_clsOCRTriggerHandler:beforeUpdate:handlePrimaryOpptyContact'));
        if(!clsTriggerHelpers.getTriggerRan('LAN_clsOCRTriggerHandler:beforeUpdate:handlePrimaryOpptyContact')) {
            clsTriggerHelpers.setTriggerRan('LAN_clsOCRTriggerHandler:beforeUpdate:handlePrimaryOpptyContact');
            this.handlePrimaryOpptyContact();
        }
    }

    private void handlePrimaryOpptyContact() {
        List<Opportunity> lstUpdates = new List<Opportunity>();

        for(OpportunityContactRole ocr : lstNew) {
            if(ocr.IsPrimary == true) {
                lstUpdates.add(new Opportunity(Id = ocr.OpportunityId, LAN_Contact_Name__c = ocr.ContactId));
            }
        }

        if(lstUpdates.size() > 0) {
            update lstUpdates;
        }
    }
}