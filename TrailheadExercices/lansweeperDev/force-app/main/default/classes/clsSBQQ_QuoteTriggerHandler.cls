public with sharing class clsSBQQ_QuoteTriggerHandler extends TriggerHandler {
    private Map<Id, SBQQ__Quote__c> newQuoteMap;
    private Map<Id, SBQQ__Quote__c> oldQuoteMap;
    private List<SBQQ__Quote__c> newQuotes;
    private static final String SALES_TYPE_BYPASS_SFDC = 'BYPASS_SALES_TYPE_IN_SFDC';

    public static final String SALES_TYPE_RENEWAL = Label.LAN_Sales_Type_Renewal;
    public static final String SALES_TYPE_UPSELL = Label.LAN_Sales_Type_Up_Sell;
    public static final String SALES_TYPE_CROSSSEL = Label.LAN_Sales_Type_Cross_Sell;
    public static final String SALES_TYPE_DOWNSELL = Label.LAN_Sales_Type_Downsell;
    public static final String SALES_TYPE_NEWLOGO = Label.LAN_Sales_Type_New_New_Logo;
    public static final String SALES_TYPE_NEWEXPANSION = Label.LAN_Sales_Type_New_Account_Expansion;
    public static final String SALES_TYPE_NEWREACTIVATION = Label.LAN_Sales_Type_New_Account_Reactivation;
    public static final String SALES_TYPE_CLASSICTONEW = Label.LAN_Sales_Type_Classic_to_New;
    public static final String SALES_TYPE_MERGE = Label.LAN_Sales_Type_Merge;
	public static final String SALES_TYPE_SPLIT = Label.LAN_Sales_Type_Split;
    public static final String SALES_TYPE_DELAYEDRENEWAL = Label.LAN_Sales_Type_Delayed_Renewal;
    public static final String PRODUCT_FAMILY_LEGACY = 'Legacy Business';
    public static final String PRODUCT_NAME_LANSWEEPER = 'Lansweeper';
    public static final String SALES_TYPE_INCORRECT = 'INCORRECT_CALCULATION';

    public clsSBQQ_QuoteTriggerHandler() {
        this.newQuoteMap = (Map<Id, SBQQ__Quote__c>) Trigger.newMap;
        this.oldQuoteMap = (Map<Id, SBQQ__Quote__c>) Trigger.oldMap;
        this.newQuotes = (List<SBQQ__Quote__c>) Trigger.new;
    }
    
    public override void beforeInsert() {
        System.Debug('clsSBQQ_QuoteTriggerHandler.beforeInsert --> Trigger ran: ' + clsTriggerHelpers.getTriggerRan('clsSBQQ_QuoteTriggerHandler.beforeInsert'));
        if(!clsTriggerHelpers.getTriggerRan('clsSBQQ_QuoteTriggerHandler.beforeInsert')) {
            this.handleQuoteType();
        }
    }

    public override void afterInsert() {
        System.Debug('clsSBQQ_QuoteTriggerHandler.afterInsert --> Trigger ran: ' + clsTriggerHelpers.getTriggerRan('clsSBQQ_QuoteTriggerHandler.afterInsert'));
        if(!clsTriggerHelpers.getTriggerRan('clsSBQQ_QuoteTriggerHandler.afterInsert')) {
            this.onPartnerQuoteInsert();
        }
    }

    public override void beforeUpdate() {
        System.Debug('clsSBQQ_QuoteTriggerHandler.beforeUpdate --> Trigger ran: ' + clsTriggerHelpers.getTriggerRan('clsSBQQ_QuoteTriggerHandler.beforeUpdate'));
        if(!clsTriggerHelpers.getTriggerRan('clsSBQQ_QuoteTriggerHandler.beforeUpdate')) {
            this.handlePartnerQuote();
        }
    }

    public override void afterUpdate() {
        System.Debug('clsSBQQ_QuoteTriggerHandler.afterUpdate --> Trigger ran: ' + clsTriggerHelpers.getTriggerRan('clsSBQQ_QuoteTriggerHandler.afterUpdate'));
        if(!clsTriggerHelpers.getTriggerRan('clsSBQQ_QuoteTriggerHandler.afterUpdate')) {
            this.handleSalesTypes();
        }

        System.Debug('clsSBQQ_QuoteTriggerHandler.afterUpdateQuoteTemplate --> Trigger ran: ' + clsTriggerHelpers.getTriggerRan('clsSBQQ_QuoteTriggerHandler.afterUpdateQuoteTemplate'));
        if(!clsTriggerHelpers.getTriggerRan('clsSBQQ_QuoteTriggerHandler.afterUpdateQuoteTemplate')) {
            this.handleQuoteTemplate();
        }
    }

    private void handleSalesTypes() {
        List<SBQQ__QuoteLine__c> lstUpdatedLines = new List<SBQQ__QuoteLine__c>();

        for(SBQQ__Quote__c q : [SELECT Id, SBQQ__Uncalculated__c, LAN_Partner_Quote_Calculated__c, SBQQ__LastSavedOn__c, SBQQ__LastCalculatedOn__c, LAN_Opportunity_Record_Type__c, LAN_Contract_Restart_with_Up_Sell__c, (SELECT Id, LAN_Quote_Uncalculated__c, LAN_Bypass_Sales_Type_in_SFDC__c, SBQQ__StartDate__c, SBQQ__EffectiveStartDate__c, SBQQ__Quantity__c, SBQQ__Product__c, SBQQ__ProductName__c, SBQQ__RenewedSubscription__c, SBQQ__RenewedSubscription__r.SBQQ__EndDate__c, SBQQ__RenewedSubscription__r.SBQQ__StartDate__c, LAN_Original_Quantity__c, SBQQ__UpgradedSubscription__c, LAN_Sales_Type2__c, LAN_Original_Quote_Line_Sales_Type__c, SBQQ__Product__r.Family, SBQQ__UpgradedSubscription__r.SBQQ__QuoteLine__r.LAN_Sales_Type2__c FROM SBQQ__LineItems__r ORDER BY SBQQ__RenewedSubscription__c NULLS LAST, SBQQ__UpgradedSubscription__c NULLS LAST) FROM SBQQ__Quote__c WHERE Id IN :newQuoteMap.keySet()]) {
            System.Debug('clsSBQQ_QuoteTriggerHandler:handleSalesTypes:q -> ' + q);

            Map<String,SBQQ__QuoteLine__c> mapQuoteRenewedItems = new Map<String, SBQQ__QuoteLine__c>();
            Map<String,SBQQ__QuoteLine__c> mapQuoteAmendedItems = new Map<String, SBQQ__QuoteLine__c>();
            Map<String, SBQQ__QuoteLine__c> mapQuoteLegacyItems = new Map<String, SBQQ__QuoteLine__c>();

            for(SBQQ__QuoteLine__c ql : q.SBQQ__LineItems__r) {
                System.Debug('clsSBQQ_QuoteTriggerHandler:handleSalesTypes:ql-> ' + ql);

                if(ql.SBQQ__RenewedSubscription__c != null) {
                    mapQuoteRenewedItems.put(ql.SBQQ__Product__c, ql);
                }

                if(ql.SBQQ__UpgradedSubscription__c != null) {
                    mapQuoteAmendedItems.put(ql.SBQQ__Product__c, ql);
                }

                if(ql.SBQQ__Product__r.Family == PRODUCT_FAMILY_LEGACY) {
                    mapQuoteLegacyItems.put(ql.SBQQ__Product__c, ql);
                }
            }

            System.Debug('clsSBQQ_QuoteTriggerHandler:handleSalesTypes:mapQuoteRenewedItems -> ' + mapQuoteRenewedItems);
            System.Debug('clsSBQQ_QuoteTriggerHandler:handleSalesTypes:mapQuoteAmendedItems -> ' + mapQuoteAmendedItems);
            System.Debug('clsSBQQ_QuoteTriggerHandler:handleSalesTypes:mapQuoteLegacyItems -> ' + mapQuoteLegacyItems);

            for(SBQQ__QuoteLine__c ql : q.SBQQ__LineItems__r) {
                //TODO: simply
                System.Debug(ql);

                SBQQ__QuoteLine__c updateQL = new SBQQ__QuoteLine__c(Id = ql.Id);
                
                // SICCP-1013: if shadow quote, update quote lines
                Set<String> quoteTypes = new Set<String>{'LAN_New_Logo','LAN_New_Account_Expansion','LAN_New_Account_Reactivation','LAN_Classic_to_New'};
                system.debug('######################## quotetrigger ###########');
                system.debug(q.LAN_Opportunity_Record_Type__c);
                system.debug(ql.SBQQ__Product__r.Family);
                system.debug(ql.LAN_Quote_Uncalculated__c != q.SBQQ__Uncalculated__c);
                //  && quoteTypes.contains(q.LAN_Opportunity_Record_Type__c) && ql.SBQQ__Product__r.Family != PRODUCT_FAMILY_LEGACY
                if (ql.LAN_Quote_Uncalculated__c != q.SBQQ__Uncalculated__c) {
                    updateQL.LAN_Quote_Uncalculated__c = q.SBQQ__Uncalculated__c;
                }
                
                //TODO: if bypass is set, then set the sales type based on oppty type
                // NO Up-Sell/Cross-Sell
                // Add lookup towards Contract with filter on account
                if(q.LAN_Opportunity_Record_Type__c == 'LAN_New_Logo') {
                    updateQL.LAN_Sales_Type2__c = SALES_TYPE_NEWLOGO;
                } else if(q.LAN_Opportunity_Record_Type__c == 'LAN_New_Account_Expansion') {
                    updateQL.LAN_Sales_Type2__c = SALES_TYPE_NEWEXPANSION;
                } else if(q.LAN_Opportunity_Record_Type__c == 'LAN_New_Account_Reactivation') {
                    updateQL.LAN_Sales_Type2__c = SALES_TYPE_NEWREACTIVATION;
                } else if(q.LAN_Opportunity_Record_Type__c == 'LAN_Classic_to_New') {
                    if(ql.LAN_Bypass_Sales_Type_in_SFDC__c == SALES_TYPE_BYPASS_SFDC) {
                        updateQL.LAN_Sales_Type2__c = SALES_TYPE_CLASSICTONEW;
                    } else if(ql.SBQQ__UpgradedSubscription__c != null && ql.SBQQ__Product__r.Family == PRODUCT_FAMILY_LEGACY) {
                        updateQL.LAN_Sales_Type2__c = SALES_TYPE_CLASSICTONEW;
                    } else if(mapQuoteAmendedItems.containsKey(ql.SBQQ__Product__c) && ql.SBQQ__UpgradedSubscription__c != null) {
                        updateQL.LAN_Sales_Type2__c = ql.SBQQ__UpgradedSubscription__r.SBQQ__QuoteLine__r.LAN_Sales_Type2__c;
                    } else if(mapQuoteAmendedItems.containsKey(ql.SBQQ__Product__c) && ql.SBQQ__UpgradedSubscription__c == null) {
                        updateQL.LAN_Sales_Type2__c = SALES_TYPE_UPSELL;
                    } else if(mapQuoteAmendedItems.containsKey(ql.SBQQ__Product__c)) {
                        updateQL.LAN_Sales_Type2__c = SALES_TYPE_UPSELL;
                    } else if(!mapQuoteAmendedItems.containsKey(ql.SBQQ__Product__c) && ql.SBQQ__UpgradedSubscription__c == null) {
                        if(ql.SBQQ__ProductName__c == PRODUCT_NAME_LANSWEEPER) {
                            updateQL.LAN_Sales_Type2__c = SALES_TYPE_CLASSICTONEW;
                        } else {
                            updateQL.LAN_Sales_Type2__c = SALES_TYPE_CROSSSEL;
                        }
                    }
                } else if(q.LAN_Opportunity_Record_Type__c == 'LAN_Merge') {
                    updateQL.LAN_Sales_Type2__c = SALES_TYPE_MERGE;
                } else if(q.LAN_Opportunity_Record_Type__c == 'LAN_Split') {
                    updateQL.LAN_Sales_Type2__c = SALES_TYPE_SPLIT;
                } else if(ql.SBQQ__RenewedSubscription__c != null) {
                    // It's a Quote Line from a Renewal linked towards a subscription thus existin line
                    // Renewal w Upsell - Classic-to-New
                    if(ql.SBQQ__Product__r.Family == PRODUCT_FAMILY_LEGACY && q.LAN_Opportunity_Record_Type__c == 'LAN_Renewal_with_Up_Sell_Cross_Sell' && ql.SBQQ__Quantity__c > 0) {
                        updateQL.LAN_Sales_Type2__c = SALES_TYPE_CLASSICTONEW;
                    } else {
                        // Renewal - Renewal
                        // Set on lines linked to a subscription in a renewing contract, for which start date of renewal directly follows end date of expiring subscription
                        Date subscriptionEndDate = ql.SBQQ__RenewedSubscription__r.SBQQ__EndDate__c;
                        Date renewedDate = ql.SBQQ__EffectiveStartDate__c;

                        if(renewedDate == null) renewedDate = subscriptionEndDate.addDays(1);
                        Integer daysBetween = subscriptionEndDate.daysBetween(renewedDate);

                        if(daysBetween == 1) {
                            updateQL.LAN_Sales_Type2__c = SALES_TYPE_RENEWAL;
                        } else if(daysBetween <= 730) {
                            updateQL.LAN_Sales_Type2__c = SALES_TYPE_DELAYEDRENEWAL;
                        }
                    }                    
                } else if(q.LAN_Opportunity_Record_Type__c.equals('LAN_Delayed_Renewal') && ql.SBQQ__RenewedSubscription__c == null) {
                    // Delayed Renewal
                    updateQL.LAN_Sales_Type2__c = SALES_TYPE_DELAYEDRENEWAL;
                } else if(q.LAN_Opportunity_Record_Type__c.toLowerCase().contains('renewal') && ql.SBQQ__RenewedSubscription__c == null) {
                    // Up-sell
                    // Set on new lines (no link to existing subscription) with a product that is included on the renewing contract, 
                    // provided that the quantity of the renewal line for the product is greater than 0.
                    System.Debug(mapQuoteRenewedItems);
                    if(ql.LAN_Bypass_Sales_Type_in_SFDC__c == SALES_TYPE_BYPASS_SFDC) {
                        updateQL.LAN_Sales_Type2__c = SALES_TYPE_RENEWAL;
                    } else if(mapQuoteRenewedItems.containsKey(ql.SBQQ__Product__c)) {
                        if(ql.SBQQ__RenewedSubscription__c == null && mapQuoteRenewedItems.get(ql.SBQQ__Product__c).SBQQ__Quantity__c > 0 && ql.SBQQ__Quantity__c > 0) {
                            updateQL.LAN_Sales_Type2__c = SALES_TYPE_UPSELL;
                        } else if(ql.SBQQ__RenewedSubscription__c == null && mapQuoteRenewedItems.get(ql.SBQQ__Product__c).SBQQ__Quantity__c == 0 && ql.SBQQ__Quantity__c > 0 && q.LAN_Contract_Restart_with_Up_Sell__c) {
                            updateQL.LAN_Sales_Type2__c = SALES_TYPE_UPSELL;
                        } else if(ql.SBQQ__RenewedSubscription__c == null && mapQuoteRenewedItems.get(ql.SBQQ__Product__c).SBQQ__Quantity__c == 0 && ql.SBQQ__Quantity__c > 0) {
                            //Down-sell
                            // Set on new lines (no link to existing subscription) with a product that is included on the renewing contract, 
                            // but where the quantity of the renewal line for the product is 0.
                            updateQL.LAN_Sales_Type2__c = SALES_TYPE_DOWNSELL;
                        } else if(ql.SBQQ__RenewedSubscription__c != null) {
                            updateQL.LAN_Sales_Type2__c = ql.LAN_Original_Quote_Line_Sales_Type__c;
                        }
                    } else {
                        // Classic-to-new
                        if(mapQuoteLegacyItems.size() > 0 && ql.SBQQ__ProductName__c == PRODUCT_NAME_LANSWEEPER) {
                            updateQL.LAN_Sales_Type2__c = SALES_TYPE_CLASSICTONEW;
                        } else {
                            //Cross-sell
                            // Set on new lines (no link to existing subscription) with a product that is not included renewing contract
                            updateQL.LAN_Sales_Type2__c = SALES_TYPE_CROSSSEL;
                        }
                    }
                } else if(q.LAN_Opportunity_Record_Type__c == 'LAN_Up_Sell_Cross_Sell') {
                    System.debug(q);
                    // Amendment
                    // Up-sell
                    // Set on new lines with product that is included in amending contract
                    if(ql.LAN_Bypass_Sales_Type_in_SFDC__c == SALES_TYPE_BYPASS_SFDC) {
                        updateQL.LAN_Sales_Type2__c = SALES_TYPE_UPSELL;
                    } else if(mapQuoteAmendedItems.containsKey(ql.SBQQ__Product__c)) {
                        if(ql.SBQQ__UpgradedSubscription__c == null) {
                            updateQL.LAN_Sales_Type2__c =  SALES_TYPE_UPSELL;
                        } else {
                            updateQL.LAN_Sales_Type2__c = ql.LAN_Original_Quote_Line_Sales_Type__c;
                        }
                        
                    } else if(!mapQuoteAmendedItems.containsKey(ql.SBQQ__Product__c)) {
                        // Amendment
                        // Cross-sell
                        // Set on new lines with product that is not included in amending contract.
                        updateQL.LAN_Sales_Type2__c = SALES_TYPE_CROSSSEL;
                    }
                } else {
                    updateQL.LAN_Sales_Type2__c = 'INCORRECT_CALCULATION';
                }

                if(ql.LAN_Sales_Type2__c != updateQL.LAN_Sales_Type2__c || (!q.LAN_Partner_Quote_Calculated__c && ql.LAN_Quote_Uncalculated__c != q.SBQQ__Uncalculated__c)) {
                    lstUpdatedLines.add(updateQL);
                }
            }
        }
        
        System.Debug('clsSBQQ_QuoteTriggerHandler:handleSalesTypes:lstUpdatedLines -> ' + lstUpdatedLines);

        if(!lstUpdatedLines.isEmpty()) {
            update lstUpdatedLines;
        }
    }

    private void handleQuoteTemplate() {
        Map<String, Object> params = new Map<String, Object>();
        Set<Id> setChangedQuoteIds = new Set<Id>();

        for(SBQQ__Quote__c q : newQuoteMap.values()) {
            System.Debug('SBQQ__TotalCustomerDiscountAmount__c ' + q.SBQQ__TotalCustomerDiscountAmount__c);
            System.Debug('SBQQ__AdditionalDiscountAmount__c ' + q.SBQQ__AdditionalDiscountAmount__c);
            System.Debug('LAN_AppliedPerpetualAccountDiscount_f__c ' + q.LAN_AppliedPerpetualAccountDiscount_f__c);
            System.Debug('LAN_AppliedSalesChanDiscount_FirstYear__c ' + q.LAN_AppliedSalesChanDiscount_FirstYear__c);

            // TODO: Store the list of fields in a metadata setting
            if(oldQuoteMap.containsKey(q.Id)) {
                for(String s : LAN_clsStaticValues.lstDiscountFields) {
                    SBQQ__Quote__c oldQ = oldQuoteMap.get(q.Id);
                    if(q.get(s) != oldQ.get(s)) {
                        setChangedQuoteIds.add(q.Id);
                    }                        
                }
            }
        }

        System.Debug(setChangedQuoteIds);

        for(Id i : setChangedQuoteIds) {
            clsTriggerHelpers.setTriggerRan('clsSBQQ_QuoteTriggerHandler.afterUpdate');

            //NOTE: bad practice as Flows aren't compeletly bulkified
            params.put('recordId', i);
            Flow.Interview.LAN_Quote_Default_Quote_Template defaultQuoteTemplateFlow = new Flow.Interview.LAN_Quote_Default_Quote_Template(params);
            defaultQuoteTemplateFlow.start();
        }    
    }
    
    private void handleQuoteType() {
        system.debug('########## quote before insert ######');
        clsTriggerHelpers.setTriggerRan('clsSBQQ_QuoteTriggerHandler.beforeInsert');
        for (SBQQ__Quote__c newQuote : newQuotes) {
            system.debug(newQuote.SBQQ__Opportunity2__c);
            if (String.isNotBlank(newQuote.LAN_Partner_Subscription_terms_in_years__c)) {
                newQuote.LAN_Subscription_term_in_years__c = newQuote.LAN_Partner_Subscription_terms_in_years__c;
            }
            if (newQuote.SBQQ__Type__c == 'Quote' || newQuote.SBQQ__Type__c == 'Re-Quote') {
                List<Opportunity> oppty = [select Id, SBQQ__Renewal__c, SBQQ__AmendedContract__c, LAN_Partner_Tier__c from Opportunity where Id=:newQuote.SBQQ__Opportunity2__c];
                system.debug(oppty);
                if (!oppty.isEmpty() && oppty[0].SBQQ__Renewal__c == true) {
                    newQuote.SBQQ__Type__c = 'Renewal';
                    newQuote.LAN_Is_First_Quote__c = false;
                }
                else if (!oppty.isEmpty() && String.isNotBlank(oppty[0].SBQQ__AmendedContract__c)) {
                    List<Contract> amendedContract = [select Id, EndDate from Contract where Id=:oppty[0].SBQQ__AmendedContract__c];
                    newQuote.SBQQ__Type__c = 'Amendment';
                    newQuote.SBQQ__EndDate__c = amendedContract[0].EndDate;
                    newQuote.LAN_Is_First_Quote__c = false;
                }
            }
        }
    }

    private void handlePartnerQuote() {
        system.debug('########## quote before update ######');
        clsTriggerHelpers.setTriggerRan('clsSBQQ_QuoteTriggerHandler.beforeUpdate');
        for (SBQQ__Quote__c newQuote : newQuotes) {
            system.debug(newQuote.LAN_Opportunity_Direct__c);
            system.debug(newQuote.SBQQ__NetAmount__c);
            system.debug(newQuote.SBQQ__Status__c);
            system.debug(newQuote.LAN_SalesChannel__c);
            system.debug(newQuote.SBQQ__Type__c);
            system.debug(this.oldQuoteMap.get(newQuote.Id).LAN_Quote_to_Cart__c);
            system.debug(newQuote.LAN_Quote_to_Cart__c);

            // US SICCP 1012: if a quote QtC link was used, reject the other related quotes
            if (this.oldQuoteMap.get(newQuote.Id) != null && newQuote.LAN_SalesChannel__c == 'Partner'
                    && this.oldQuoteMap.get(newQuote.Id).SBQQ__Status__c != newQuote.SBQQ__Status__c && newQuote.SBQQ__Status__c == 'Accepted') {
                List<SBQQ__Quote__c> toExpireQuotes = [select Id, SBQQ__Status__c, LAN_Quote_to_Cart__c from SBQQ__Quote__c 
                                                    where SBQQ__Opportunity2__c =:newQuote.SBQQ__Opportunity2__c and Id != :newQuote.Id];
                for (SBQQ__Quote__c quoteToExpire : toExpireQuotes) {
                    quoteToExpire.SBQQ__Status__c = 'Rejected';
                    quoteToExpire.LAN_Quote_to_Cart__c = '';
                }
                update toExpireQuotes;
            }
        }
    }

    private void onPartnerQuoteInsert() {
        system.debug('########## quote after insert ######');
        clsTriggerHelpers.setTriggerRan('clsSBQQ_QuoteTriggerHandler.afterInsert');
        for (SBQQ__Quote__c newQuote : newQuotes) {
            system.debug(newQuote.SBQQ__Type__c);
            system.debug(newQuote.SBQQ__Opportunity2__c);

            // US SICCP 1012: generate the quote lines of a partner quote
            if (newQuote.LAN_SalesChannel__c == 'Partner' && (newQuote.SBQQ__Type__c == 'Quote' || newQuote.SBQQ__Type__c == 'Re-Quote')) {
                this.createPartnerQuoteLines(newQuote);
            }

            // US SICCP 1654: generate asset quote line
            if (newQuote.LAN_SalesChannel__c != 'Partner' && (newQuote.SBQQ__Type__c == 'Quote' || newQuote.SBQQ__Type__c == 'Re-Quote')) {
                createQuoteLines(newQuote);
            }
        }
    }

    private void createPartnerQuoteLines(SBQQ__Quote__c newQuote) {
        List<SBQQ__QuoteLine__c> partnerQuoteLines = new List<SBQQ__QuoteLine__c>();

        if (newQuote.LAN_Partner_Number_Agents__c > 0) {
            List<Product2> agentProduct = [select Id, SBQQ__SubscriptionPricing__c from Product2 where Name='Helpdesk Agent'];
            SBQQ__QuoteLine__c agentQuoteLine = new SBQQ__QuoteLine__c();
            agentQuoteLine.SBQQ__Quote__c = newQuote.Id;
            agentQuoteLine.SBQQ__SubscriptionScope__c = 'Quote';
            agentQuoteLine.SBQQ__SubscriptionPricing__c = agentProduct[0].SBQQ__SubscriptionPricing__c;
            agentQuoteLine.SBQQ__Product__c = agentProduct[0].Id;
            agentQuoteLine.SBQQ__ProductSubscriptionType__c = 'One-time';
            agentQuoteLine.SBQQ__Quantity__c = newQuote.LAN_Partner_Number_Agents__c;
            agentQuoteLine.SBQQ__StartDate__c = newQuote.SBQQ__StartDate__c;
            agentQuoteLine.SBQQ__SubscriptionType__c = 'One-time';

            partnerQuoteLines.add(agentQuoteLine);
        }
        if (String.isNotBlank(newQuote.LAN_Partner_Number_Assets__c) && Integer.valueof(newQuote.LAN_Partner_Number_Assets__c.trim()) > 0) {
            List<Product2> agentProduct = [select Id, SBQQ__SubscriptionPricing__c from Product2 where Name='Lansweeper' and SBQQ__SubscriptionPricing__c = 'Fixed Price'];
            SBQQ__QuoteLine__c assetQuoteLine = new SBQQ__QuoteLine__c();
            assetQuoteLine.SBQQ__Quote__c = newQuote.Id;
            assetQuoteLine.SBQQ__SubscriptionScope__c = 'Quote';
            assetQuoteLine.SBQQ__SubscriptionPricing__c = agentProduct[0].SBQQ__SubscriptionPricing__c;
            assetQuoteLine.SBQQ__Product__c = agentProduct[0].Id;
            assetQuoteLine.SBQQ__ProductSubscriptionType__c = 'One-time';
            assetQuoteLine.SBQQ__Quantity__c = Integer.valueof(newQuote.LAN_Partner_Number_Assets__c.trim());
            assetQuoteLine.SBQQ__StartDate__c = newQuote.SBQQ__StartDate__c;
            assetQuoteLine.SBQQ__SubscriptionType__c = 'One-time';

            partnerQuoteLines.add(assetQuoteLine);
        }
        insert partnerQuoteLines;
    }

    private void createQuoteLines(SBQQ__Quote__c newQuote) {
        List<SBQQ__QuoteLine__c> partnerQuoteLines = new List<SBQQ__QuoteLine__c>();

        List<Product2> agentProduct = [select Id, SBQQ__SubscriptionPricing__c from Product2 where Name='Lansweeper' and SBQQ__SubscriptionPricing__c = 'Fixed Price'];
        SBQQ__QuoteLine__c assetQuoteLine = new SBQQ__QuoteLine__c();
        assetQuoteLine.SBQQ__Quote__c = newQuote.Id;
        assetQuoteLine.SBQQ__SubscriptionScope__c = 'Quote';
        assetQuoteLine.SBQQ__SubscriptionPricing__c = agentProduct[0].SBQQ__SubscriptionPricing__c;
        assetQuoteLine.SBQQ__Product__c = agentProduct[0].Id;
        assetQuoteLine.SBQQ__ProductSubscriptionType__c = 'One-time';
        assetQuoteLine.SBQQ__Quantity__c = 500;
        assetQuoteLine.SBQQ__StartDate__c = newQuote.SBQQ__StartDate__c;
        assetQuoteLine.SBQQ__SubscriptionType__c = 'One-time';

        partnerQuoteLines.add(assetQuoteLine);
        insert partnerQuoteLines;
    }
}