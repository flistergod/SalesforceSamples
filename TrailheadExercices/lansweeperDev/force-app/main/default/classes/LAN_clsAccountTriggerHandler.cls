public with sharing class LAN_clsAccountTriggerHandler extends TriggerHandler {
    private List<Account> lstNew;
    private Map<Id,Account> lstNewMap;
    private Map<Id,Account> lstOldMap;

    public LAN_clsAccountTriggerHandler() {
        this.lstNew = (List<Account>) Trigger.new;
        this.lstNewMap = (Map<Id, Account>) Trigger.newMap;
        this.lstOldMap = (Map<Id, Account>) Trigger.oldMap;
    }

    public override void beforeInsert() {
        if(!clsTriggerHelpers.getTriggerRan('LAN_clsAccountTriggerHandler.beforeInsert')) {
            System.Debug('LAN_clsAccountTriggerHandler:beforeInsert');
            clsTriggerHelpers.setTriggerRan('LAN_clsAccountTriggerHandler.beforeInsert');
            this.checkVatNumber(true);
        }
    }

    public override void afterInsert() {
    }

    public override void beforeUpdate() {
        if(!clsTriggerHelpers.getTriggerRan('LAN_clsAccountTriggerHandler.beforeUpdate')) {
            System.Debug('LAN_clsAccountTriggerHandler:beforeUpdate');
            clsTriggerHelpers.setTriggerRan('LAN_clsAccountTriggerHandler.beforeUpdate');
            this.checkVatNumber(false);
        }
    }

    public override void afterUpdate() {
        if(!clsTriggerHelpers.getTriggerRan('LAN_clsAccountTriggerHandler.afterUpdate')) {
            System.Debug('LAN_clsAccountTriggerHandler:afterUpdate');
            this.recalculateAccountDiscounts();
        }
    }
    
    private void recalculateAccountDiscounts() {
        List<Batch_Queue__c> batchOpptyDiscountQueues = new List<Batch_Queue__c>();
        Set<Id> accountsDiscountChanged = new Set<Id>();
        clsTriggerHelpers.setTriggerRan('LAN_clsAccountTriggerHandler.afterUpdate');
        for (Account acc : lstNew) {
            if (String.isNotBlank(acc.LAN_Partner_Tier__c)) {
                if ((acc.LAN_EffectivePartnerDiscount_FirstYear__c != this.lstOldMap.get(acc.Id).LAN_EffectivePartnerDiscount_FirstYear__c && acc.LAN_EffectivePartnerDiscount_FirstYear__c == 0.1)
                	|| ((acc.LAN_EffectivePartnerDiscount_Renewal__c != this.lstOldMap.get(acc.Id).LAN_EffectivePartnerDiscount_Renewal__c) || (this.lstOldMap.get(acc.Id).LAN_EffectivePartnerDiscount_Renewal__c == 0 && acc.LAN_EffectivePartnerDiscount_Renewal__c == 0.12))
                    || (acc.LAN_Partner_Tier__c != this.lstOldMap.get(acc.Id).LAN_Partner_Tier__c)) {
                    accountsDiscountChanged.add(acc.Id);
                }
            }
        }
      
        if (!accountsDiscountChanged.isEmpty()) {
            Set<Id> opportunitiesToRecalculate = new Set<Id>();
			Set<Id> opportunitiesWithQueue = new Set<Id>();
            Set<String> quoteTypes = new Set<String>{ 'Renewal', 'Amendment' };
            //'LAN_Renewal_with_Up_Sell_Cross_Sell' is excluded because is related to Amend & Renew
            Set<String> possibleOpptyRecordTypes = new Set<String>{'LAN_Renewal','LAN_Renewal_with_Down_Sell', 'LAN_Delayed_Renewal','LAN_Renewal_with_Up_Sell_Cross_Sell','LAN_Up_Sell_Cross_Sell'};
            // assumption: EXCEPT Amend & Renew as we cannot recalculate the Credit
            // assumption: do not recalculate quotes that are near the renewal date - end date is less than 30 days from now
            Date todayPlus30days = System.today().addDays(30);
            List<SBQQ__Quote__c> quotes = [select Id, SBQQ__Status__c, SBQQ__Type__c, SBQQ__Opportunity2__c from SBQQ__Quote__c 
                                           where SBQQ__Opportunity2__r.LAN_Partner_Account__c in :accountsDiscountChanged
                                           		and SBQQ__Opportunity2__r.LAN_Has_Amendment_Contract_on_Renewal__c=false
                                                and SBQQ__Opportunity2__r.LAN_Opportunity_Record_Type_Dev_Name__c IN :possibleOpptyRecordTypes
                                           		and (SBQQ__Opportunity2__r.LAN_Renewal_Date__c =null or SBQQ__Opportunity2__r.LAN_Renewal_Date__c > :todayPlus30days) 
                                           		and SBQQ__Status__c='Draft' and SBQQ__Type__c in :quoteTypes];
            

            for (SBQQ__Quote__c quote : quotes) {
                opportunitiesToRecalculate.add(quote.SBQQ__Opportunity2__c);
            }
            
            // select opportunities without quotes
            List<Opportunity> accountOppties = [Select Id from Opportunity 
                                                	where LAN_Partner_Account__c in :accountsDiscountChanged
                                                		and Id not in :opportunitiesToRecalculate
                                                		and LAN_Opportunity_Record_Type_Dev_Name__c IN :possibleOpptyRecordTypes
                                               			and (LAN_Renewal_Date__c =null or LAN_Renewal_Date__c > :todayPlus30days) ];
            
            for (Opportunity oppty : accountOppties) {
                opportunitiesToRecalculate.add(oppty.Id);
            }
            
            Map<Id,Batch_Queue__c> alreadyExistingQueues = new Map<Id,Batch_Queue__c>([select Id, Opportunity__c, Status__c from Batch_Queue__c where Opportunity__c in :opportunitiesToRecalculate]);
            for (Batch_Queue__c existingQueue : alreadyExistingQueues.values()) {
                existingQueue.Status__c='To be recalculated';
                batchOpptyDiscountQueues.add(existingQueue);
                
                opportunitiesWithQueue.add(existingQueue.Opportunity__c);
            }
            opportunitiesToRecalculate.removeAll(opportunitiesWithQueue);
            for (Id opptyId : opportunitiesToRecalculate) {
                batchOpptyDiscountQueues.add(new Batch_Queue__c(Opportunity__c=opptyId, Status__c='To be recalculated', Type__c='Batch - Partner Discount'));
            }
            if (!batchOpptyDiscountQueues.isEmpty()) {
            	upsert batchOpptyDiscountQueues;
            }
        }
    }

    private void checkVatNumber(boolean isInsert) {
        system.debug('##### checkVatNumber #######');
        List<Account> accToCheck = new List<Account>();
        List<Account> newAccounts = isInsert ? this.lstNew : this.lstNewMap.values();
        for (Account newAccount : newAccounts) {
            if ((!isInsert && String.isNotBlank(newAccount.LAN_VAT_Number__c) && newAccount.LAN_VAT_Number__c != this.lstOldMap.get(newAccount.Id).LAN_VAT_Number__c)
                    || (isInsert && String.isNotBlank(newAccount.LAN_VAT_Number__c))) {
                accToCheck.add(newAccount);
            }
            //LAN_Shipping_Addressee_VAT__c
            //ShippingCountry

        system.debug('##### accToCheck #######');
        system.debug(newAccount.LAN_VAT_Number__c);
        if (!isInsert) {
            system.debug(this.lstOldMap.get(newAccount.Id).LAN_VAT_Number__c);
        }
        system.debug(accToCheck);
        }
        if (!accToCheck.isEmpty()) {
            externalValidateVatNumber(JSON.serialize(accToCheck));
        }
    }

    @future(callout=true)
    private static void externalValidateVatNumber(string accountsData) {
        system.debug('##### externalValidateVatNumber #######');
        List<Account> accounts = (List<Account>)JSON.deserialize(accountsData, List<Account>.class);
        List<Account> accountsToUpdate = new List<Account>();
        for (Account account : accounts) {
            system.debug(account.LAN_Country_Code__c);
            system.debug(account.LAN_VAT_Number__c);
    
            // String regex = '[a-zA-Z]{1,}|\\-';
            // String parsedVatNumber = account.LAN_VAT_Number__c.replaceAll(regex, '');
            boolean vatValid = false;
            try {
                ecEuropaEuTaxudViesServicesCheckva.checkVatPort vatChecker = new ecEuropaEuTaxudViesServicesCheckva.checkVatPort();
                ecEuropaEuTaxudViesServicesCheckva.checkVatResponse_element checkData = vatChecker.checkVat(account.LAN_Country_Code__c,account.LAN_VAT_Number__c);
                system.debug(checkData.valid);
                vatValid = checkData.valid;
                account.LAN_Check_VAT_Number_Response_JSON__c = JSON.serialize(checkData);
                account.LAN_VAT_Check_Status__c = !vatValid ? 'Checked - Not Valid' : 'Checked - Valid';
                accountsToUpdate.add(account);
            }
            catch (Exception ex) {
                ecEuropaEuTaxudViesServicesCheckva.checkVatResponse_error checkError = new ecEuropaEuTaxudViesServicesCheckva.checkVatResponse_error();
                checkError.vatNumber = account.LAN_VAT_Number__c;
                checkError.countryCode = account.LAN_Country_Code__c;
                checkError.requestDate = System.today();
                checkError.valid = false;
                checkError.error = ex.getMessage();
                account.LAN_Check_VAT_Number_Response_JSON__c = JSON.serialize(checkError);
                account.LAN_VAT_Check_Status__c = 'Check - Error';
                accountsToUpdate.add(account);
                system.debug('Check VAT number API exception: ' + checkError.error);
            }
            if (!vatValid) {
                // String vatError = Label.LAN_VAT_Number_is_Invalid.replace('$0', account.LAN_VAT_Number__c != null ? account.LAN_VAT_Number__c : '')
                //                     .replace('$1',account.LAN_Country_Code__c != null ? account.LAN_Country_Code__c : '');
                //account.addError(vatError);
            }
        }
        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }
}