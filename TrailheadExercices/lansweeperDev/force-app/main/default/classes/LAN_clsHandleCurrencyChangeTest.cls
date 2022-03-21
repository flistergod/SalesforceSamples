@isTest(IsParallel=false)
private with sharing class LAN_clsHandleCurrencyChangeTest {
    private static Account a {
        get {
            return [SELECT Id FROM Account WHERE Name = 'Test' AND RecordType.DeveloperName = 'LAN_Account'];
        }
    }
    
    private static Opportunity o {
        get {
            return [SELECT Id, CurrencyIsoCode, Pricebook2Id FROM Opportunity WHERE AccountId = :a.Id LIMIT 1];
        }
    }

    private static Product2 pLansweeper {
        get {
            return [SELECT Id, Name FROM Product2 WHERE Family = 'Existing Business' AND Name = 'Lansweeper' LIMIT 1];
        }
    }
    
    private static Product2 pAgent {
        get {
            return [SELECT Id, Name FROM Product2 WHERE Family = 'Existing Business' AND Name = 'Helpdesk Agent' LIMIT 1];
        }
    }

    private static Contract c {
        get {
            return [SELECT Id, SBQQ__RenewalOpportunity__c, (SELECT Id FROM SBQQ__Subscriptions__r) FROM Contract LIMIT 1];
        }
    }
	
    @testSetup
    private static void setupTestData() {
        clsTriggerHelpers.setTriggerRan('LAN_clsOpportunityTriggerHandler.beforeUpdate.handleParentPrimaryOpportunity', true);
        clsTriggerHelpers.setTriggerRan('clsSBQQ_QuoteTriggerHandler.afterUpdate', true);
        clsTriggerHelpers.setTriggerRan('LAN_clsOpportunityTriggerHandler.afterUpdate.handleRecordTypeChange', true);

        Pricebook2 pb = new Pricebook2(Id = Test.getStandardPricebookId(), isActive = true);
        //update pb;
        
        Product2 pLansweeper = new Product2(Name = 'Lansweeper', Family = 'Existing Business');
        insert pLansweeper;
        
        Product2 pAgent = new Product2(Name = 'Helpdesk Agent', Family = 'Existing Business');
        insert pAgent;
        
        Account a = new Account(Name='Test', RecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('LAN_Account').getRecordTypeId());
        insert a;
        
        Contract c = new Contract(AccountId = a.Id, Status = 'Draft', StartDate = System.today(), ContractTerm  = 12);
        insert c;
        
        SBQQ__Subscription__c s1 = new SBQQ__Subscription__c(SBQQ__Contract__c = c.Id, SBQQ__Account__c = a.Id, SBQQ__Product__c = pLansweeper.Id, SBQQ__Quantity__c = 500, SBQQ__CustomerPrice__c = 495, SBQQ__ListPrice__c = 1, SBQQ__ProductSubscriptionType__c = 'Renewable', SBQQ__PricingMethod__c = 'List', SBQQ__SubscriptionStartDate__c = System.today(), SBQQ__SubscriptionType__c = 'Renewable');
        insert s1;
        
        c.LAN_Days_before_End_Date_Renewal_Quote__c = 0;
        c.SBQQ__MasterContract__c = false;
        
        update c;

        c = [SELECT Id, SBQQ__RenewalOpportunity__c, (SELECT Id FROM SBQQ__Subscriptions__r) FROM Contract LIMIT 1];        
        Opportunity o = new Opportunity(AccountId = a.Id, RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('LAN_Classic_to_New').getRecordTypeId(), 
                                       StageName = 'Qualify', Name = 'Oppty', CloseDate = System.today().addDays(30), Pricebook2Id = Test.getStandardPricebookId(), CurrencyIsoCode = 'EUR');
        insert o;
        
        c.SBQQ__RenewalOpportunity__c = o.Id;
        update c;
    }

    @isTest
    private static void quoteCDC() {  
        Test.enableChangeDataCapture();
        

        SBQQ__Quote__c q = new SBQQ__Quote__c();
        q.SBQQ__Account__c = a.Id;
        q.SBQQ__Opportunity2__c  = o.Id;
        
        insert q;

        System.Debug('TEST.STARTTEST');
        Test.startTest();

        System.Debug('TEST:QUOTELINEINSERT');
        SBQQ__QuoteLine__c ql1 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = q.Id, SBQQ__Product__c = pLansweeper.Id, SBQQ__Quantity__c = 500, SBQQ__RenewedSubscription__c = c.SBQQ__Subscriptions__r[0].Id);
        insert ql1;

        // Performing Quick Action activities for changing currency
        SBQQ__Quote__c updatedQuote = new SBQQ__Quote__c(Id = q.Id);
        updatedQuote.SBQQ__Primary__c = false;
        updatedQuote.LAN_Update_Currency__c = true;
        updatedQuote.LAN_Currency__c = 'USD';
        updatedQuote.SBQQ__LastCalculatedOn__c = System.today();
        LAN_clsHandleCurrencyChange.testQuote = updatedQuote;
        update updatedQuote;

        Test.getEventBus().deliver();

        Test.stopTest();
    }

    @isTest
    private static void testQuoteCurrencyChange() {  
        SBQQ__Quote__c q = new SBQQ__Quote__c();
        q.SBQQ__Account__c = a.Id;
        q.SBQQ__Opportunity2__c  = o.Id;
        
        clsTriggerHelpers.setTriggerRan('clsSBQQ_QuoteTriggerHandler.afterUpdate');
        clsTriggerHelpers.setTriggerRan('clsSBQQ_QuoteLineTriggerHandler.afterUpdate');
        clsTriggerHelpers.setTriggerRan('clsSBQQ_QuoteLineTriggerHandler.afterInsert');

        insert q;
        System.Debug('START INSTERT QUOTE');

        SBQQ__QuoteLine__c ql1 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = q.Id, SBQQ__Product__c = pLansweeper.Id, SBQQ__Quantity__c = 500, SBQQ__RenewedSubscription__c = c.SBQQ__Subscriptions__r[0].Id);
        insert ql1;
        
        System.Debug('START INSERT QUOTE LINE');

        Test.startTest();

        // Performing Quick Action activities for changing currency
        SBQQ__Quote__c updatedQuote = new SBQQ__Quote__c(Id = q.Id);
        updatedQuote.SBQQ__Primary__c = false;
        updatedQuote.LAN_Update_Currency__c = true;
        updatedQuote.LAN_Currency__c = 'USD';
        updatedQuote.SBQQ__LastCalculatedOn__c = System.today();
        updatedQuote.SBQQ__Opportunity2__c = o.Id;
		
        System.Debug(o.CurrencyIsoCode);
        System.Debug('LAN_clsHandleCurrencyChangeTest --> Update Quote');
        update updatedQuote;
        
        LAN_clsHandleCurrencyChange.testQuote = updatedQuote;
        
        LAN_clsHandleCurrencyChange.checkUpdateCurrencyFlag(new List<Id>{q.Id});
        LAN_clsHandleCurrencyChange.verifyCurrencies(new List<Id>{q.Id});

        Test.stopTest();
        
        System.Debug([SELECT Id, CurrencyIsoCode, LAN_Update_Currency__c, LAN_Currency__c FROM SBQQ__Quote__c WHERE Id = :q.Id]);
        System.assert([SELECT Id, CurrencyIsoCode FROM SBQQ__Quote__c WHERE Id = :q.Id LIMIT 1][0].CurrencyIsoCode == 'USD');
    }
    
    @isTest
    private static void testQuotePrimary() {
        SBQQ__Quote__c q = new SBQQ__Quote__c();
        q.SBQQ__Account__c = a.Id;
        q.SBQQ__Opportunity2__c  = o.Id;
        
        insert q;

        Test.startTest();

        SBQQ__QuoteLine__c ql1 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = q.Id, SBQQ__Product__c = pLansweeper.Id, SBQQ__Quantity__c = 500, SBQQ__RenewedSubscription__c = c.SBQQ__Subscriptions__r[0].Id);
        insert ql1;
        
        LAN_clsHandleCurrencyChange.setPrimaryQuote(q.Id);
        
        Test.stopTest();
        
        System.assert([SELECT SBQQ__Primary__c FROM SBQQ__Quote__c WHERE Id = :q.Id LIMIT 1][0].SBQQ__Primary__c == true);
    }
    
    @isTest
    private static void testUpdateCurrencyFlag() {
        SBQQ__Quote__c q = new SBQQ__Quote__c();
        q.SBQQ__Account__c = a.Id;
        q.SBQQ__Opportunity2__c  = o.Id;
        
        insert q;

        Test.startTest();

        SBQQ__QuoteLine__c ql1 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = q.Id, SBQQ__Product__c = pLansweeper.Id, SBQQ__Quantity__c = 500, SBQQ__RenewedSubscription__c = c.SBQQ__Subscriptions__r[0].Id);
        insert ql1;
        
        LAN_clsHandleCurrencyChange.setUpdateCurrencyFlag(new List<Id>{q.Id});
        
        Test.stopTest();
        
        System.assert(q.SBQQ__Account__c == a.Id);
        System.assert([SELECT LAN_Update_Currency__c FROM SBQQ__Quote__c WHERE Id = :q.Id LIMIT 1][0].LAN_Update_Currency__c == true);
    }
}