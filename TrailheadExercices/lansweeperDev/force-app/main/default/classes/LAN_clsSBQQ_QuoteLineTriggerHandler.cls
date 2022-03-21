public with sharing class LAN_clsSBQQ_QuoteLineTriggerHandler extends TriggerHandler {
    private Map<Id, SBQQ__QuoteLine__c> newLinesMap;
    private List<SBQQ__QuoteLine__c> newLinesInsert;

    public LAN_clsSBQQ_QuoteLineTriggerHandler() {
        this.newLinesInsert = Trigger.new;
        this.newLinesMap = (Map<Id, SBQQ__QuoteLine__c>) Trigger.newMap;
    }
    
    public override void beforeUpdate() {
        if(!clsTriggerHelpers.getTriggerRan('clsSBQQ_QuoteLineTriggerHandler.beforeUpdate')) {
            System.Debug('LAN_clsSBQQ_QuoteLineTriggerHandler:beforeUpdate');
        }        
    }

    public override void afterUpdate() {
        if(!clsTriggerHelpers.getTriggerRan('clsSBQQ_QuoteLineTriggerHandler.afterUpdate')) {
            System.Debug('LAN_clsSBQQ_QuoteLineTriggerHandler:afterUpdate');
            this.verifySalesTypes();
        }        
    }
    
    public override void beforeInsert() {
        if(!clsTriggerHelpers.getTriggerRan('clsSBQQ_QuoteLineTriggerHandler.beforeInsert')) {
            System.Debug('LAN_clsSBQQ_QuoteLineTriggerHandler:beforeInsert');
        }
    }

    public override void afterInsert() {
        if(!clsTriggerHelpers.getTriggerRan('clsSBQQ_QuoteLineTriggerHandler.afterInsert')) {
            System.Debug('LAN_clsSBQQ_QuoteLineTriggerHandler:afterInsert');
            this.verifySalesTypes();
        }
    }

    private void verifySalesTypes() {
        for(SBQQ__QuoteLine__c ql : newLinesMap.values()) {
            System.Debug('LAN_clsSBQQ_QuoteLineTriggerHandler:verifySalesTypes:ql -> ' + ql.Id + ql.LAN_Sales_Type2__c);
            if(ql.LAN_Sales_Type2__c == null) {
                clsTriggerHelpers.setTriggerRan('clsSBQQ_QuoteTriggerHandler.afterUpdate', false);
            }
        }
    }
}