public class LAN_ConvertSubscriptionsByRateAction {
	@InvocableMethod(label='Convert Subscriptions with an Exchange Rate' description='Given a list of quote subscriptions and currencies for the convertion, converts them with the exchange rate defined.' category='Quote Subscriptions')
    public static List<List<SBQQ__Subscription__c>> ConvertSubscriptions(List<LAN_SubscriptionsRateWrapper> subscriptionsRateWrapper) {
        if (subscriptionsRateWrapper[0].Subscriptions != null) {
            Set<Id> mostUpdateExchangeRates = new Set<Id>();
            List<AggregateResult> exchangeRatesAggregated = [SELECT Id, MAX(Rate_Update_Date__c) from Exchange_Rate__c 
                                                             where From_Currency__c =:subscriptionsRateWrapper[0].FromCurrency and To_Currency__c=:subscriptionsRateWrapper[0].ToCurrency 
                                                             group by Id, To_Currency__c];
            for(AggregateResult ar : exchangeRatesAggregated) {
                mostUpdateExchangeRates.add((Id)ar.get('Id'));
            }
            List<Exchange_Rate__c> exchangeRates = [SELECT Id, From_Currency__c, To_Currency__c, Rate_Value__c, Rate_Update_Date__c from Exchange_Rate__c 
                                                    where Id IN :mostUpdateExchangeRates];
            if (exchangeRates != null && !exchangeRates.isEmpty()) {
                for(SBQQ__Subscription__c subscription : subscriptionsRateWrapper[0].Subscriptions) {
                    subscription.LAN_Currency_Conversion_Rate__c = exchangeRates[0].Rate_Value__c;
                    subscription.LAN_RenewalBase_Total__c *= exchangeRates[0].Rate_Value__c;
                    //subscription.LAN_Original_Quote_Line_Price__c *= exchangeRates[0].Rate_Value__c;
                    if (subscription.SBQQ__CustomerPrice__c != null) {
                        subscription.SBQQ__CustomerPrice__c *= exchangeRates[0].Rate_Value__c;
                    }
                    if (subscription.SBQQ__ListPrice__c != null) {
                        subscription.SBQQ__ListPrice__c *= exchangeRates[0].Rate_Value__c;
                    }
                    if (subscription.SBQQ__NetPrice__c != null) {
                        subscription.SBQQ__NetPrice__c *= exchangeRates[0].Rate_Value__c;
                    }
                    if (subscription.SBQQ__SpecialPrice__c != null) {
                        subscription.SBQQ__SpecialPrice__c *= exchangeRates[0].Rate_Value__c;
                    }
                    if (subscription.SBQQ__RegularPrice__c != null) {
                        subscription.SBQQ__RegularPrice__c *= exchangeRates[0].Rate_Value__c;
                    }
                    if (subscription.SBQQ__RenewalPrice__c != null) {
                        subscription.SBQQ__RenewalPrice__c *= exchangeRates[0].Rate_Value__c;
                    }
                }
        		return new List<List<SBQQ__Subscription__c>>{subscriptionsRateWrapper[0].Subscriptions};
            }
            else {
        		return new List<List<SBQQ__Subscription__c>>{null};
            }
        }
        else {
        	return new List<List<SBQQ__Subscription__c>>{null};
        }
    }
}