trigger clsSBQQ_QuoteCDCTrigger on SBQQ__Quote__ChangeEvent (after insert) {
    List<Id> lstUpdatedQuotes = new List<Id>();
    private static DateTime lastCalculatedOn;

    for(SBQQ__Quote__ChangeEvent e : Trigger.new) {
        System.Debug('clsSBQQ_QuoteCDCTrigger --> ' + e);

        // Check if SBQQ__LastCalculatedOn__c is returned
        // Query the Quote to see if currency needs to change
        EventBus.ChangeEventHeader header = e.ChangeEventHeader;
        System.Debug('Change Type: ' + header.changeType);
        System.Debug('Last Calculated ON: ' + e.SBQQ__LastCalculatedOn__c);
        if(e.SBQQ__LastCalculatedOn__c != null) {
            lastCalculatedOn = e.SBQQ__LastCalculatedOn__c;
        } else if(e.SBQQ__LastCalculatedOn__c == null && Test.isRunningTest()) {
            lastCalculatedOn = System.now();
        }

        // Bypassing for tunning test class, since bug in test classes where event bus isn't capturing the UPDATE CDC
        if((header.changeType == 'UPDATE' && lastCalculatedOn != null)) {
            LAN_clsHandleCurrencyChange.verifyCurrencies(header.recordids);
        }

        if(header.changetype == 'CREATE' && e.CurrencyIsoCode != null && e.LAN_Currency__c != null && e.CurrencyIsoCode != e.LAN_Currency__c) {
            LAN_clsHandleCurrencyChange.setUpdateCurrencyFlag(header.recordids);
        }
    }
}