@isTest
private class LAN_ConvertSubscriptionsByRateActionTest {
	@isTest
    private static void testConvertSubscriptions() {
        Exchange_Rate__c exchangeRate = new Exchange_Rate__c();
        exchangeRate.Rate_Update_Date__c = System.today();
        exchangeRate.From_Currency__c = 'USD';
        exchangeRate.To_Currency__c = 'EUR';
        exchangeRate.Rate_Value__c = 0.81;
        
        insert exchangeRate;
        
        SBQQ__Subscription__c subscription = new SBQQ__Subscription__c();
        subscription.CurrencyIsoCode='USD';
        subscription.SBQQ__SubscriptionType__c='Renewable';
        subscription.SBQQ__ProductSubscriptionType__c='Renewable';
        subscription.SBQQ__Quantity__c = 1000;
        subscription.SBQQ__NetPrice__c = 10.3;
        subscription.SBQQ__SpecialPrice__c = 10.3;
        subscription.SBQQ__RegularPrice__c = 10.3;
        subscription.SBQQ__RenewalPrice__c = 10.3;
        subscription.SBQQ__RenewalQuantity__c=70000.0;
        subscription.LAN_RenewalBase_Total__c=70000.0;
        //subscription.SBQQ__Product__c=01t1t000002KqxwAAC
        
        insert subscription;

        Test.startTest();
        
        LAN_SubscriptionsRateWrapper wrapper = new LAN_SubscriptionsRateWrapper();
        wrapper.FromCurrency = 'USD';
        wrapper.ToCurrency = 'EUR';
        wrapper.Subscriptions = new List<SBQQ__Subscription__c>{subscription};

        List<List<SBQQ__Subscription__c>> lstResult = LAN_ConvertSubscriptionsByRateAction.ConvertSubscriptions(new List<LAN_SubscriptionsRateWrapper>{wrapper});
        
        Test.stopTest();

        System.assertEquals(1, lstResult[0].size());
    }
    
    @isTest
    private static void testConvertSubscriptionsRateEmpty() {
        Test.startTest();
        LAN_SubscriptionsRateWrapper wrapper = new LAN_SubscriptionsRateWrapper();
        wrapper.FromCurrency = 'USD';
        wrapper.ToCurrency = 'EUR';
        wrapper.Subscriptions = new List<SBQQ__Subscription__c>();

        List<List<SBQQ__Subscription__c>> lstResult = LAN_ConvertSubscriptionsByRateAction.ConvertSubscriptions(new List<LAN_SubscriptionsRateWrapper>{wrapper});
        
        Test.stopTest();

        System.assertEquals(lstResult[0], null);
    }
}