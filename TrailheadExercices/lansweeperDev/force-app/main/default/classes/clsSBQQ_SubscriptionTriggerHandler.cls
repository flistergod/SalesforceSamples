public with sharing class clsSBQQ_SubscriptionTriggerHandler extends TriggerHandler {
    private List<SBQQ__Subscription__c> lstNewSubscriptions;

    public clsSBQQ_SubscriptionTriggerHandler() {
        this.lstNewSubscriptions = (List<SBQQ__Subscription__c>) Trigger.new;
    }

    public override void beforeInsert() {
        handleRenewalOneTimeDiscounts();
    }

    public override void beforeUpdate() {
        handleRenewalOneTimeDiscounts();
    }

    private void handleRenewalOneTimeDiscounts() {
        // Remove the SBQQ__Discount field and set Customer Price towards Regular Price
        // Needed for Renewals in order to remove the one-time discounts

        for(SBQQ__Subscription__c s : lstNewSubscriptions) {
            System.Debug(s);
            if(s.SBQQ__Discount__c != null) {
                s.SBQQ__Discount__c = null;
                s.SBQQ__CustomerPrice__c = s.SBQQ__RegularPrice__c;
                System.Debug(s);
            }

            if(s.SBQQ__AdditionalDiscountAmount__c != null) {
                s.SBQQ__AdditionalDiscountAmount__c = null;
                s.SBQQ__CustomerPrice__c = s.SBQQ__RegularPrice__c;
                System.Debug(s);
            }
        }
    }
}