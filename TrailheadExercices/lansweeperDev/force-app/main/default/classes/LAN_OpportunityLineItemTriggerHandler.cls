public with sharing class LAN_OpportunityLineItemTriggerHandler extends TriggerHandler {
	private Map<Id, OpportunityLineItem> newLinesMap;
	private Map<Id, OpportunityLineItem> oldLinesMap;
    private List<OpportunityLineItem> newLinesInsert;

    public LAN_OpportunityLineItemTriggerHandler() {
        this.newLinesInsert = Trigger.new;
        this.newLinesMap = (Map<Id, OpportunityLineItem>) Trigger.newMap;
        this.oldLinesMap = (Map<Id, OpportunityLineItem>) Trigger.oldMap;
    }
    
    public override void afterUpdate() {
        if(!clsTriggerHelpers.getTriggerRan('LAN_OpportunityLineItemTriggerHandler.afterUpdate')) {
            System.Debug('LAN_OpportunityLineItemTriggerHandler:afterUpdate');
            this.triggerOpptyProductPlatformEvent(false);
        }        
    }
    
    public override void afterInsert() {
        if(!clsTriggerHelpers.getTriggerRan('LAN_OpportunityLineItemTriggerHandler.afterInsert')) {
            System.Debug('LAN_OpportunityLineItemTriggerHandler:afterInsert');
            this.triggerOpptyProductPlatformEvent(true);
        }
    }
    
    private void triggerOpptyProductPlatformEvent(boolean isInsert) {
        if (isInsert) {
            clsTriggerHelpers.setTriggerRan('LAN_OpportunityLineItemTriggerHandler.afterInsert');
        }
        else {
            clsTriggerHelpers.setTriggerRan('LAN_OpportunityLineItemTriggerHandler.afterUpdate');
        }
        Map<Id,List<OpportunityLineItem>> mapShadowOpptiesWithTriggerLineItems = new Map<Id,List<OpportunityLineItem>>();
        Map<Id,List<OpportunityLineItem>> triggeredOpptiesLineItems = new Map<Id,List<OpportunityLineItem>>();
        Map<Id,Opportunity> mapOriginalOppties = new Map<Id,Opportunity>();
        
        for (OpportunityLineItem lineItem : isInsert ? this.newLinesInsert : newLinesMap.values()) {
            if (triggeredOpptiesLineItems.get(lineItem.OpportunityId) != null) {
                triggeredOpptiesLineItems.get(lineItem.OpportunityId).add(lineItem);
            }
            else {
                triggeredOpptiesLineItems.put(lineItem.OpportunityId,new List<OpportunityLineItem>{lineItem});
            }
        }
        
        
        //do not publish event for opportunities already recalculated
        List<Batch_Queue__c> batchOpptyCalculatedQueues = [select Id, Opportunity__c, Status__c from Batch_Queue__c Where Type__c = 'Batch - Partner Discount' and Status__c = 'To be recalculated' and Opportunity__c in :triggeredOpptiesLineItems.keySet()];
        Map<Id,Batch_Queue__c> opptyIdBatchQueueToUpdate = new Map<Id,Batch_Queue__c>();
        system.debug('############## oppties to be recalculated on batch queue #################');
        system.debug(batchOpptyCalculatedQueues);
        if (!batchOpptyCalculatedQueues.isEmpty()) {
            for (Batch_Queue__c batchOppty : batchOpptyCalculatedQueues) {
                opptyIdBatchQueueToUpdate.put(batchOppty.Opportunity__c,batchOppty);
            }
            
            //process the platform events only for opportunities to be recalculated
            if (!opptyIdBatchQueueToUpdate.isEmpty()) {
            	List<Opportunity> triggeredlineItemsOppties = [select Id, SBQQ__RenewedContract__r.SBQQ__Opportunity__c, SBQQ__RenewedContract__r.SBQQ__Opportunity__r.LAN_Cleverbridge_SubscriptionID__c, SBQQ__RenewedContract__r.SBQQ__Opportunity__r.SBQQ__PrimaryQuote__c, 
                                                                  	SBQQ__RenewedContract__r.SBQQ__Opportunity__r.LAN_Original_Reference_Number__c, SBQQ__RenewedContract__r.SBQQ__Opportunity__r.CurrencyIsoCode,
                                                                    SBQQ__AmendedContract__r.SBQQ__Opportunity__c, SBQQ__AmendedContract__r.SBQQ__Opportunity__r.LAN_Cleverbridge_SubscriptionID__c, SBQQ__AmendedContract__r.SBQQ__Opportunity__r.SBQQ__PrimaryQuote__c,
                                                                  	SBQQ__AmendedContract__r.SBQQ__Opportunity__r.LAN_Original_Reference_Number__c, SBQQ__AmendedContract__r.SBQQ__Opportunity__r.CurrencyIsoCode,
                                                                    LAN_Original_Contract__r.SBQQ__Opportunity__c, LAN_Original_Contract__r.SBQQ__Opportunity__r.LAN_Cleverbridge_SubscriptionID__c, LAN_Original_Contract__r.SBQQ__Opportunity__r.SBQQ__PrimaryQuote__c,
                                                                 	LAN_Original_Contract__r.SBQQ__Opportunity__r.LAN_Original_Reference_Number__c, LAN_Original_Contract__r.SBQQ__Opportunity__r.CurrencyIsoCode
                                                                  from Opportunity where Id in:opptyIdBatchQueueToUpdate.keySet()];
                
        
                for (Opportunity oppty : triggeredlineItemsOppties) {
                    Opportunity originalOppty = oppty.SBQQ__RenewedContract__r.SBQQ__Opportunity__c != null ? oppty.SBQQ__RenewedContract__r.SBQQ__Opportunity__r : (oppty.SBQQ__AmendedContract__r.SBQQ__Opportunity__c != null ? oppty.SBQQ__AmendedContract__r.SBQQ__Opportunity__r : oppty.LAN_Original_Contract__r.SBQQ__Opportunity__r);
                    if (originalOppty != null) {
                        mapOriginalOppties.put(originalOppty.Id,originalOppty);
                        mapShadowOpptiesWithTriggerLineItems.put(originalOppty.Id, triggeredOpptiesLineItems.get(oppty.Id));
                    }
                }
        
                Map<Id,OpportunityLineItem> originalOpptyLineItems = new Map<Id,OpportunityLineItem>([select Id, OpportunityId, Product2Id, LAN_Quote_Uncalculated__c, LAN_QuoteLine_Uncalculated__c,
                                                                                                     SBQQ__QuoteLine__c, SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Status__c,
                                                                                                     LAN_QuoteLine_CB_ProductID__c,LAN_QuoteLine_CB_Running_No__c, ListPrice,Quantity,UnitPrice
                                                                                                     FROM OpportunityLineItem where OpportunityId in :mapOriginalOppties.keySet()]);
                //Map<Id,SBQQ__QuoteLine__c> quoteLines = new Map<Id,SBQQ__QuoteLine__c>([select Id, LAN_Quote_Uncalculated__c, SBQQ__Quote__r.SBQQ__Type__c, SBQQ__Quote__r.SBQQ__Status__c,
                //                                                                        	SBQQ__Quote__r.SBQQ__Opportunity2__c, SBQQ__Quote__r.SBQQ__Opportunity2__r.LAN_Cleverbridge_SubscriptionID__c, SBQQ__Quote__r.SBQQ__Opportunity2__r.LAN_Original_Reference_Number__c, SBQQ__Quote__r.SBQQ__Opportunity2__r.CurrencyIsoCode
                //                                                                        	from SBQQ__QuoteLine__c where SBQQ__Quote__r.SBQQ__Opportunity2__c in :mapOriginalOppties.keySet()]);
                //                                                                        	
        
                system.debug('############## original oppty lines (using shadow quote) ###############');
                system.debug(originalOpptyLineItems);
                system.debug('############## new oppty lines ###############');
                system.debug(mapShadowOpptiesWithTriggerLineItems);
                this.sendPlatformEvents(opptyIdBatchQueueToUpdate, mapOriginalOppties, originalOpptyLineItems, mapShadowOpptiesWithTriggerLineItems);
            }
        }
    }
    
    private void sendPlatformEvents(Map<Id,Batch_Queue__c> opptyIdBatchQueueToUpdate, Map<Id,Opportunity> mapOriginalOppties, Map<Id,OpportunityLineItem> originalOpptyLineItems, Map<Id,List<OpportunityLineItem>> mapShadowOpptiesWithTriggerLineItems) {
        Map<String,Opportunity_Product_Calculation__e> opptyProductCalcEvents = new Map<String,Opportunity_Product_Calculation__e>();
        Set<Id> platformEventsOpptyIds = new Set<Id>();
        List<String> quoteTypes = new List<String>{'Renewal'};
            
        for (OpportunityLineItem lineItem : originalOpptyLineItems.values()) {
            List<OpportunityLineItem> triggeredOpptyLineItems = mapShadowOpptiesWithTriggerLineItems.get(lineItem.OpportunityId);
            OpportunityLineItem triggeredOpptyLineItem = null;
            for (OpportunityLineItem opptyLine : triggeredOpptyLineItems) {
                if (lineItem.Product2Id == opptyLine.Product2Id) {
                    triggeredOpptyLineItem = opptyLine;
                    break;
                }
            }
            
            if (triggeredOpptyLineItem != null) {
                system.debug('############## triggeredOpptyLineItem ###############');
                system.debug(triggeredOpptyLineItem);
                if (opptyProductCalcEvents.get(triggeredOpptyLineItem.OpportunityId) == null) {
                    Opportunity quoteOppty = mapOriginalOppties.get(lineItem.OpportunityId);
                    system.debug('########################### opptylineitens: quote line data ################');
                    system.debug(lineItem.SBQQ__QuoteLine__c);
                    system.debug(lineItem.OpportunityId);
                    system.debug(lineItem.LAN_Quote_Uncalculated__c);
                    system.debug(lineItem.LAN_QuoteLine_Uncalculated__c);
                    system.debug(lineItem.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Status__c);
                    system.debug(quoteOppty.LAN_Cleverbridge_SubscriptionID__c);
                    if (!lineItem.LAN_QuoteLine_Uncalculated__c) {
                        // conditions to publish event
                        //  && quoteTypes.contains(quoteLines.get(lineItem.SBQQ__QuoteLine__c).SBQQ__Quote__r.SBQQ__Type__c)
                        //  (isInsert || (!isInsert && oldLinesMap != null && oldLinesMap.get(lineItem.Id) != null && oldLinesMap.get(lineItem.Id).LAN_Quote_Uncalculated__c != lineItem.LAN_Quote_Uncalculated__c)) &&
                        //  && lineItem.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Status__c=='Draft'
                        if (String.isNotBlank(quoteOppty.LAN_Cleverbridge_SubscriptionID__c)) {
                            if (opptyProductCalcEvents.get(triggeredOpptyLineItem.OpportunityId) == null) {
                                
                                Opportunity_Product_Calculation__e opptyCalcEvent = new Opportunity_Product_Calculation__e();
                                opptyCalcEvent.LAN_CB_Product_ID__c = lineItem.LAN_QuoteLine_CB_ProductID__c;
                                opptyCalcEvent.LAN_CB_Running_No__c = lineItem.LAN_QuoteLine_CB_Running_No__c;
                                opptyCalcEvent.LAN_CB_Subscription_ID__c = quoteOppty.LAN_Cleverbridge_SubscriptionID__c;
                                opptyCalcEvent.LAN_Original_Reference_Number__c = quoteOppty.LAN_Original_Reference_Number__c;
                                opptyCalcEvent.Opportunity_CurrencyIsoCode__c = quoteOppty.CurrencyIsoCode;
                                opptyCalcEvent.List_Price__c = triggeredOpptyLineItem.ListPrice;
                                opptyCalcEvent.Quantity__c = triggeredOpptyLineItem.Quantity;
                                opptyCalcEvent.Sales_Price__c = triggeredOpptyLineItem.UnitPrice;
                                opptyCalcEvent.Opportunity_Line_Item_Id__c = triggeredOpptyLineItem.Id;
        
                                opptyProductCalcEvents.put(triggeredOpptyLineItem.OpportunityId, opptyCalcEvent);
                            }
                        }
                        platformEventsOpptyIds.add(triggeredOpptyLineItem.OpportunityId);
                		opptyIdBatchQueueToUpdate.get(triggeredOpptyLineItem.OpportunityId).Status__c = 'Recalculated';
                    }
                }
            }
        }
        
        
        if (!platformEventsOpptyIds.isEmpty()) {
            system.debug('############## new oppty calculation events ###############');
            system.debug(opptyProductCalcEvents);
            if (!opptyProductCalcEvents.isEmpty()) {
                // Call method to publish events
                List<Database.SaveResult> sr = EventBus.publish(opptyProductCalcEvents.values());
                // Inspect publishing result
                if (sr[0].isSuccess()) {
                    System.debug('Successfully published Opportunity calculation event.');
                } else {
                    for(Database.Error err : sr[0].getErrors()) {
                        System.debug('Error returned: ' +err.getStatusCode() +' - ' + err.getMessage());
                    }
                }
            }
            system.debug('############## batch queues to update ###############');
            system.debug(opptyIdBatchQueueToUpdate);
            if (!opptyIdBatchQueueToUpdate.isEmpty()) {
            	update opptyIdBatchQueueToUpdate.values();
            }
        }
    }
}