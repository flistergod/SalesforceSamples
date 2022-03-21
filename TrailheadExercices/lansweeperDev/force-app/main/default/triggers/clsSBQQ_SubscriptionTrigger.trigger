trigger clsSBQQ_SubscriptionTrigger on SBQQ__Subscription__c (before insert, before update) {
    new clsSBQQ_SubscriptionTriggerHandler().run();
}