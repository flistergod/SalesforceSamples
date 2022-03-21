public with sharing class LAN_clsOpportunityTriggerHandler extends TriggerHandler {
    private Map<Id, Opportunity> mapNewOpp;
    private Map<Id, Opportunity> mapOldOpp;
    private List<Opportunity> lstUpdateOppties;
    private List<SBQQ__Quote__c> lstUpdateQuotes;

    public LAN_clsOpportunityTriggerHandler() {
        this.mapNewOpp = (Map<Id, Opportunity>) Trigger.newMap;
        this.lstUpdateQuotes = new List<SBQQ__Quote__c>();
        this.lstUpdateOppties= new List<Opportunity>();
    }

    public override void beforeInsert() {
        handleParentPrimaryOpportunity();
        handleUniquePrimary();
    }

    public override void beforeUpdate() {
        System.Debug('LAN_clsOpportunityTriggerHandler.beforeUpdate --> Trigger ran: ' + clsTriggerHelpers.getTriggerRan('LAN_clsOpportunityTriggerHandler.beforeUpdate.handleParentPrimaryOpportunity'));
        if(!clsTriggerHelpers.getTriggerRan('LAN_clsOpportunityTriggerHandler.beforeUpdate.handleParentPrimaryOpportunity')){
            handleParentPrimaryOpportunity();
            handleUniquePrimary();
            

            if(lstUpdateOppties.size() > 0) {
                System.Debug('LAN_clsOpportunityTriggerHandler -> update');
                System.Debug('LAN_clsOpportunityTriggerHandler:lstUpdateOppties  -> ' + lstUpdateOppties);
                clsTriggerHelpers.setTriggerRan('LAN_clsOpportunityTriggerHandler.beforeUpdate.handleParentPrimaryOpportunity');
                update lstUpdateOppties;
            }
        }
    }

    public override void afterUpdate() {
        System.Debug('LAN_clsOpportunityTriggerHandler.afterUpdate.handleRecordTypeChange --> Trigger ran: ' + clsTriggerHelpers.getTriggerRan('LAN_clsOpportunityTriggerHandler.afterUpdate.handleRecordTypeChange'));
        if(!clsTriggerHelpers.getTriggerRan('LAN_clsOpportunityTriggerHandler.afterUpdate.handleRecordTypeChange')) {
            mapOldOpp = (Map<Id, Opportunity>) Trigger.oldMap;
            handleRecordTypeChange();

            if(lstUpdateQuotes.size() > 0) {
                System.Debug('LAN_clsOpportunityTriggerHandler -> Update Quotes');
                System.Debug('LAN_clsOpportunityTriggerHandler:lstUpdateQuotes -> ' + lstUpdateQuotes);
                clsTriggerHelpers.setTriggerRan('clsSBQQ_QuoteTriggerHandler.afterUpdate', false);
                clsTriggerHelpers.setTriggerRan('LAN_clsOpportunityTriggerHandler.afterUpdate.handleRecordTypeChange');
                update lstUpdateQuotes;
            }

            
        }
    }


    /**
        Handle the Primary logic of Parent with it's child opportunities. There should only be 1 Child Primary Opportunity. The
        Primary Child Opportunity should be populated within the Parent lookup holding the Primary Opportunity
    */
    private void handleParentPrimaryOpportunity() {
        if(mapNewOpp != null) {
            Map<Id, Id> mapParentToChildPrimaryOppty = new Map<Id, Id>();
            // Check if it's a child opportunity which has been marked a Primary and that it's not a Parent RT
            for(Opportunity o : mapNewOpp.values()) {
                if(o.RecordTypeId != LAN_clsStaticValues.OPPORTUNITY_RT_ID_PARENT && o.LAN_Primary__c && o.LAN_Parent_Opportunity__c != null) {
                    lstUpdateOppties.add(new Opportunity(
                        Id = o.LAN_Parent_Opportunity__c, LAN_Primary_Opportunity__c = o.Id, Amount = o.Amount,
                        CloseDate = o.CloseDate, StageName = o.StageName, Probability = o.Probability, TotalOpportunityQuantity = o.TotalOpportunityQuantity,
                        LAN_Invoice_Date__c = o.LAN_Invoice_Date__c, LAN_License_Reference_Number__c = o.LAN_License_Reference_Number__c,
                        LAN_Loss_Reason__c = o.LAN_Loss_Reason__c, LAN_Loss_Reason_Description__c = o.LAN_Loss_Reason_Description__c,
                        CurrencyIsoCode = o.CurrencyIsoCode, LAN_Competitor__c = o.LAN_Competitor__c,
                        LAN_Payment_Method__c = o.LAN_Payment_Method__c, LAN_Direct__c = o.LAN_Direct__c, LAN_Payment_Date__c = o.LAN_Payment_Date__c,
                        LAN_Billing_Contact_Name__c = o.LAN_Billing_Contact_Name__c, LAN_Billing_Contact_Email__c = o.LAN_Billing_Contact_Email__c,
                        LAN_Shipping_Information__c = o.LAN_Shipping_Information__c, LAN_Invoice_Number__c = o.LAN_Invoice_Number__c
                    ));
                }
            }
        }
    }

    /**
        Logic allowing only 1 Primary Opportunity on Parent Account
    */
    private void handleUniquePrimary() {
        Map<Id, Id> mapParents = new Map<Id, Id>();

        if(mapNewOpp != null) {
            for(Opportunity o : mapNewOpp.values()) {
                if(o.RecordTypeId != LAN_clsStaticValues.OPPORTUNITY_RT_ID_PARENT && o.LAN_Parent_Opportunity__c != null && o.LAN_Primary__c == true) {
                    // Fetch all Primary Oppties on the Parent Oppty who are set as Parent but should not be parent, based on the lookup information
                    if(!mapParents.containsKey(o.Id)) {
                        mapParents.put(o.Id, o.LAN_Parent_Opportunity__c);
                    }
                }
            }

            System.Debug('LAN_clsOpportunityTriggerHandler:handleUniquePrimary -> ' + mapParents);

            if(mapParents.size() > 0) {
                List<Opportunity> lstUpdates = new List<Opportunity>();

                for(Opportunity o : [SELECT Id, LAN_Parent_Opportunity__c FROM Opportunity WHERE LAN_Parent_Opportunity__c IN :mapParents.values() AND LAN_Primary__c = TRUE ORDER BY LAN_Parent_Opportunity__c ASC]) {
                    System.Debug(o);
                    if(!mapParents.containsKey(o.Id)) {
                        lstUpdateOppties.add(new Opportunity(Id = o.Id, LAN_Primary__c = false));
                    }
                }               
            }
        }
    }

    private void handleRecordTypeChange() {
        if(mapNewOpp != null && mapOldOpp != null) {
            List<Id> lstOpportunitiesWithChangesRTs = new List<Id>();
            for(Opportunity o : mapNewOpp.values()) {
                if(mapOldOpp.containsKey(o.Id) && o.RecordTypeId != mapOldOpp.get(o.Id).RecordTypeId) {
                    // Record Type changed from Opportunity. Fetch the Quote's and update them to recalculate the Quote's Sales Types
                    lstOpportunitiesWithChangesRTs.add(o.Id);
                }
            }

            if(lstOpportunitiesWithChangesRTs.size() > 0) {
                lstUpdateQuotes.addAll([SELECT Id FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c IN :lstOpportunitiesWithChangesRTs]);
            }
        }
    }
}