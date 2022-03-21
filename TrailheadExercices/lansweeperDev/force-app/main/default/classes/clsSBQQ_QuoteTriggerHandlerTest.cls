@isTest(IsParallel=false)
private with sharing class clsSBQQ_QuoteTriggerHandlerTest {
    
    private static Account a {
        get {
            return [SELECT Id FROM Account WHERE Name = 'Test' AND RecordType.DeveloperName = 'LAN_Account'];
        }
    }
    
    private static Opportunity o {
        get {
            return [SELECT Id FROM Opportunity WHERE AccountId = :a.Id LIMIT 1];
        }
    }

    private static Product2 pLansweeper {
        get {
            return [SELECT Id, Name, SBQQ__SubscriptionPricing__c FROM Product2 WHERE Family = 'Existing Business' AND Name = 'Lansweeper' LIMIT 1];
        }
    }
    
    private static Product2 pAgent {
        get {
            return [SELECT Id, Name, SBQQ__SubscriptionPricing__c FROM Product2 WHERE Family = 'Existing Business' AND Name = 'Helpdesk Agent' LIMIT 1];
        }
    }

    private static Product2 pPremium {
        get {
            return [SELECT Id, Name FROM Product2 WHERE Family = :clsSBQQ_QuoteTriggerHandler.PRODUCT_FAMILY_LEGACY LIMIT 1];
        }
    }

    private static SBQQ__Subscription__c s1 {
        get {
            return [SELECT Id FROM SBQQ__Subscription__c LIMIT 1];
        }
    }
	
    @testSetup
    private static void setupTestData() {
        Pricebook2 pb = new Pricebook2(Id = Test.getStandardPricebookId(), isActive = true);
        //update pb;
        
        Product2 pLansweeper = new Product2(Name = 'Lansweeper', SBQQ__SubscriptionPricing__c='Fixed Price', Family = 'Existing Business');
        insert pLansweeper;
        
        Product2 pAgent = new Product2(Name = 'Helpdesk Agent', SBQQ__SubscriptionPricing__c='Fixed Price', Family = 'Existing Business');
        insert pAgent;

        Product2 pPremium = new Product2(Name = 'Premium', Family = clsSBQQ_QuoteTriggerHandler.PRODUCT_FAMILY_LEGACY);
        insert pPremium;
        
        Account a = new Account(Name='Test', RecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('LAN_Account').getRecordTypeId());
        insert a;
        
        Contract c = new Contract(AccountId = a.Id, Status = 'Draft', StartDate = System.today(), ContractTerm  = 12);
        insert c;
        
        List<SBQQ__Subscription__c> lstSubscriptions = new List<SBQQ__Subscription__c>();
        SBQQ__Subscription__c s1 = new SBQQ__Subscription__c(SBQQ__Contract__c = c.Id, SBQQ__Account__c = a.Id, SBQQ__Product__c = pLansweeper.Id, SBQQ__Quantity__c = 500, SBQQ__CustomerPrice__c = 495, SBQQ__ListPrice__c = 1, SBQQ__ProductSubscriptionType__c = 'Renewable', SBQQ__PricingMethod__c = 'List', SBQQ__SubscriptionStartDate__c = System.today(), SBQQ__SubscriptionType__c = 'Renewable');
        lstSubscriptions.add(s1);
        SBQQ__Subscription__c s2 = new SBQQ__Subscription__c(SBQQ__Contract__c = c.Id, SBQQ__Account__c = a.Id, SBQQ__Product__c = pPremium.Id, SBQQ__Quantity__c = 1, SBQQ__CustomerPrice__c = 995, SBQQ__ListPrice__c = 995, SBQQ__ProductSubscriptionType__c = 'Renewable', SBQQ__PricingMethod__c = 'List', SBQQ__SubscriptionStartDate__c = System.today(), SBQQ__SubscriptionType__c = 'Renewable');
        lstSubscriptions.add(s2);
        SBQQ__Subscription__c s3 = new SBQQ__Subscription__c(SBQQ__Contract__c = c.Id, SBQQ__Account__c = a.Id, SBQQ__Product__c = pAgent.Id, SBQQ__Quantity__c = 1, SBQQ__CustomerPrice__c = 500, SBQQ__ListPrice__c = 500, SBQQ__ProductSubscriptionType__c = 'Renewable', SBQQ__PricingMethod__c = 'List', SBQQ__SubscriptionStartDate__c = System.today(), SBQQ__SubscriptionType__c = 'Renewable');
        lstSubscriptions.add(s3);

        insert lstSubscriptions;
        
        c.LAN_Days_before_End_Date_Renewal_Quote__c = 0;
        c.SBQQ__MasterContract__c = false;
        
        update c;
    }
    @isTest
    private static void salesTypeRenewal() {    
        Contract c = [SELECT Id, SBQQ__RenewalOpportunity__c, EndDate, (SELECT Id FROM SBQQ__Subscriptions__r WHERE SBQQ__Product__c = :pLansweeper.Id) FROM Contract LIMIT 1];
        System.debug(c);
        System.Debug(c.SBQQ__Subscriptions__r);
        
        Opportunity o = new Opportunity(AccountId = a.Id, RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('LAN_Renewal').getRecordTypeId(), 
                                       StageName = 'Qualify', Name = 'Oppty', CloseDate = System.today().addDays(365), Pricebook2Id = Test.getStandardPricebookId());
        insert o;
        
        c.SBQQ__RenewalOpportunity__c = o.Id;
        update c;
        
        SBQQ__Quote__c q = new SBQQ__Quote__c();
        q.SBQQ__Account__c = a.Id;
        q.SBQQ__Opportunity2__c  = o.Id;
        
        insert q;

        Test.startTest();

        SBQQ__QuoteLine__c ql1 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = q.Id, SBQQ__Product__c = pLansweeper.Id, SBQQ__Quantity__c = 500, SBQQ__RenewedSubscription__c = c.SBQQ__Subscriptions__r[0].Id);
        clsTriggerHelpers.setTriggerRan('clsSBQQ_QuoteTriggerHandler.afterUpdate', false);
        insert ql1;
        
        Test.stopTest();
        
        System.assert([SELECT Id, LAN_Sales_Type2__c FROM SBQQ__QuoteLine__c LIMIT 1][0].LAN_Sales_Type2__c == clsSBQQ_QuoteTriggerHandler.SALES_TYPE_RENEWAL);
    }
    
    @isTest
    private static void salesTypeUpsell() {    
        Contract c = [SELECT Id, SBQQ__RenewalOpportunity__c, (SELECT Id FROM SBQQ__Subscriptions__r WHERE SBQQ__Product__c = :pLansweeper.Id) FROM Contract LIMIT 1];
        System.debug(c);
        System.Debug(c.SBQQ__Subscriptions__r);
        
        Opportunity o = new Opportunity(AccountId = a.Id, RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('LAN_Renewal').getRecordTypeId(), 
                                       StageName = 'Qualify', Name = 'Oppty', CloseDate = System.today().addDays(30), Pricebook2Id = Test.getStandardPricebookId());
        insert o;
        
        c.SBQQ__RenewalOpportunity__c = o.Id;
        update c;
        
        SBQQ__Quote__c q = new SBQQ__Quote__c();
        q.SBQQ__Account__c = a.Id;
        q.SBQQ__Opportunity2__c  = o.Id;
        
        insert q;

        Test.startTest();

        List<SBQQ__QuoteLine__c> lstLines = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c ql0 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = q.Id, SBQQ__RenewedSubscription__c = c.SBQQ__Subscriptions__r[0].Id, SBQQ__Quantity__c = 1000, SBQQ__Product__c = pLansweeper.Id);
        lstLines.add(ql0);

        SBQQ__QuoteLine__c ql1 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = q.Id, SBQQ__Product__c = pLansweeper.Id, SBQQ__Quantity__c = 500);
        clsTriggerHelpers.setTriggerRan('clsSBQQ_QuoteTriggerHandler.afterUpdate', false);
        lstLines.add(ql1);
        insert lstLines;
        
        Test.stopTest();
        System.assert([SELECT Id, LAN_Sales_Type2__c FROM SBQQ__QuoteLine__c WHERE Id = :ql1.Id LIMIT 1][0].LAN_Sales_Type2__c == clsSBQQ_QuoteTriggerHandler.SALES_TYPE_UPSELL);
    }
    
    @isTest
    private static void salesTypeDownsell() {    
        Contract c = [SELECT Id, SBQQ__RenewalOpportunity__c, (SELECT Id FROM SBQQ__Subscriptions__r WHERE SBQQ__Product__c = :pLansweeper.Id) FROM Contract LIMIT 1];
        System.debug(c);
        System.Debug(c.SBQQ__Subscriptions__r);
        
        Opportunity o = new Opportunity(AccountId = a.Id, RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('LAN_Renewal').getRecordTypeId(), 
                                       StageName = 'Qualify', Name = 'Oppty', CloseDate = System.today().addDays(30), Pricebook2Id = Test.getStandardPricebookId());
        insert o;
        
        c.SBQQ__RenewalOpportunity__c = o.Id;
        update c;
        
        SBQQ__Quote__c q = new SBQQ__Quote__c();
        q.SBQQ__Account__c = a.Id;
        q.SBQQ__Opportunity2__c  = o.Id;
        
        insert q;

        Test.startTest();

        List<SBQQ__QuoteLine__c> lstLines = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c ql0 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = q.Id, SBQQ__RenewedSubscription__c = c.SBQQ__Subscriptions__r[0].Id, SBQQ__Quantity__c = 0, SBQQ__Product__c = pLansweeper.Id);
        lstLines.add(ql0);

        SBQQ__QuoteLine__c ql1 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = q.Id, SBQQ__Product__c = pLansweeper.Id, SBQQ__Quantity__c = 500);
        clsTriggerHelpers.setTriggerRan('clsSBQQ_QuoteTriggerHandler.afterUpdate', false);
        lstLines.add(ql1);
        insert lstLines;
        
        Test.stopTest();
        
        System.assert([SELECT Id, LAN_Sales_Type2__c FROM SBQQ__QuoteLine__c WHERE Id = :ql1.Id LIMIT 1][0].LAN_Sales_Type2__c == clsSBQQ_QuoteTriggerHandler.SALES_TYPE_DOWNSELL);
    }
    
    @isTest
    private static void salesTypeUpsellNewLine() {    
        Contract c = [SELECT Id, SBQQ__RenewalOpportunity__c, (SELECT Id FROM SBQQ__Subscriptions__r WHERE SBQQ__Product__c = :pLansweeper.Id) FROM Contract LIMIT 1];
        System.debug(c);
        System.Debug(c.SBQQ__Subscriptions__r);
        
        Opportunity o = new Opportunity(AccountId = a.Id, RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('LAN_Renewal').getRecordTypeId(), 
                                       StageName = 'Qualify', Name = 'Oppty', CloseDate = System.today().addDays(30), Pricebook2Id = Test.getStandardPricebookId());
        insert o;
        
        c.SBQQ__RenewalOpportunity__c = o.Id;
        update c;
        
        SBQQ__Quote__c q = new SBQQ__Quote__c();
        q.SBQQ__Account__c = a.Id;
        q.SBQQ__Opportunity2__c  = o.Id;
        
        insert q;

        Test.startTest();
		
        List<SBQQ__QuoteLine__c> lstLines = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c ql1 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = q.Id, SBQQ__Product__c = pLansweeper.Id, SBQQ__Quantity__c = 500, SBQQ__RenewedSubscription__c = c.SBQQ__Subscriptions__r[0].Id,
                                                       LAN_Original_Quantity__c = 100);
        lstLines.add(ql1);
        
        SBQQ__QuoteLine__c ql2 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = q.Id, SBQQ__Product__c = pLansweeper.Id, SBQQ__Quantity__c = 500,
                                                       LAN_Original_Quantity__c = 100);
        lstLines.add(ql2);
        clsTriggerHelpers.setTriggerRan('clsSBQQ_QuoteTriggerHandler.afterUpdate', false);
        insert lstLines;
        
        Test.stopTest();
        
        System.assert([SELECT Id, LAN_Sales_Type2__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Product__c = :pLansweeper.Id AND SBQQ__RenewedSubscription__c = null LIMIT 1][0].LAN_Sales_Type2__c == clsSBQQ_QuoteTriggerHandler.SALES_TYPE_UPSELL);
    }
    
    @isTest
    private static void salesTypeCrossSell() {    
        Contract c = [SELECT Id, SBQQ__RenewalOpportunity__c, (SELECT Id FROM SBQQ__Subscriptions__r WHERE SBQQ__Product__c = :pLansweeper.Id) FROM Contract LIMIT 1];
        System.debug(c);
        System.Debug(c.SBQQ__Subscriptions__r);
        
        Opportunity o = new Opportunity(AccountId = a.Id, RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('LAN_Renewal').getRecordTypeId(), 
                                       StageName = 'Qualify', Name = 'Oppty', CloseDate = System.today().addDays(30), Pricebook2Id = Test.getStandardPricebookId());
        insert o;
        
        c.SBQQ__RenewalOpportunity__c = o.Id;
        update c;
        
        SBQQ__Quote__c q = new SBQQ__Quote__c();
        q.SBQQ__Account__c = a.Id;
        q.SBQQ__Opportunity2__c  = o.Id;
        
        insert q;

        Test.startTest();

        List<SBQQ__QuoteLine__c> lstQL = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c ql1 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = q.Id, SBQQ__Product__c = pLansweeper.Id, SBQQ__Quantity__c = 500, SBQQ__RenewedSubscription__c = c.SBQQ__Subscriptions__r[0].Id,
                                                       LAN_Original_Quantity__c = 100);
        lstQL.add(ql1);
        
        SBQQ__QuoteLine__c ql2 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = q.Id, SBQQ__Product__c = pAgent.Id, SBQQ__Quantity__c = 500);
        lstQL.add(ql2);
        
        clsTriggerHelpers.setTriggerRan('clsSBQQ_QuoteTriggerHandler.afterUpdate', false);
        insert lstQL;
        
        Test.stopTest();
        
        System.assert([SELECT Id, LAN_Sales_Type2__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Product__c = :pAgent.Id LIMIT 1][0].LAN_Sales_Type2__c == clsSBQQ_QuoteTriggerHandler.SALES_TYPE_CROSSSEL);
    }
    
    @isTest
    private static void salesTypeNewLogo() {    
        Contract c = [SELECT Id, SBQQ__RenewalOpportunity__c, (SELECT Id FROM SBQQ__Subscriptions__r WHERE SBQQ__Product__c = :pLansweeper.Id) FROM Contract LIMIT 1];
        System.debug(c);
        System.Debug(c.SBQQ__Subscriptions__r);
        
        Opportunity o = new Opportunity(AccountId = a.Id, RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('LAN_New_Logo').getRecordTypeId(), 
                                       StageName = 'Qualify', Name = 'Oppty', CloseDate = System.today().addDays(30), Pricebook2Id = Test.getStandardPricebookId());
        insert o;
        
        c.SBQQ__RenewalOpportunity__c = o.Id;
        update c;
        
        SBQQ__Quote__c q = new SBQQ__Quote__c();
        q.SBQQ__Account__c = a.Id;
        q.SBQQ__Opportunity2__c  = o.Id;
        
        insert q;

        Test.startTest();

        SBQQ__QuoteLine__c ql1 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = q.Id, SBQQ__Product__c = pLansweeper.Id, SBQQ__Quantity__c = 500, SBQQ__RenewedSubscription__c = c.SBQQ__Subscriptions__r[0].Id);
        clsTriggerHelpers.setTriggerRan('clsSBQQ_QuoteTriggerHandler.afterUpdate', false);
        insert ql1;
        
        Test.stopTest();
        
        System.assert([SELECT Id, LAN_Sales_Type2__c FROM SBQQ__QuoteLine__c LIMIT 1][0].LAN_Sales_Type2__c == clsSBQQ_QuoteTriggerHandler.SALES_TYPE_NEWLOGO);
    }
    
    @isTest
    private static void salesTypeAccountExpansion() {    
        Contract c = [SELECT Id, SBQQ__RenewalOpportunity__c, (SELECT Id FROM SBQQ__Subscriptions__r WHERE SBQQ__Product__c = :pLansweeper.Id) FROM Contract LIMIT 1];
        System.debug(c);
        System.Debug(c.SBQQ__Subscriptions__r);
        
        Opportunity o = new Opportunity(AccountId = a.Id, RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('LAN_New_Account_Expansion').getRecordTypeId(), 
                                       StageName = 'Qualify', Name = 'Oppty', CloseDate = System.today().addDays(30), Pricebook2Id = Test.getStandardPricebookId());
        insert o;
        
        c.SBQQ__RenewalOpportunity__c = o.Id;
        update c;
        
        SBQQ__Quote__c q = new SBQQ__Quote__c();
        q.SBQQ__Account__c = a.Id;
        q.SBQQ__Opportunity2__c  = o.Id;
        
        insert q;

        Test.startTest();

        SBQQ__QuoteLine__c ql1 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = q.Id, SBQQ__Product__c = pLansweeper.Id, SBQQ__Quantity__c = 500, SBQQ__RenewedSubscription__c = c.SBQQ__Subscriptions__r[0].Id);
        clsTriggerHelpers.setTriggerRan('clsSBQQ_QuoteTriggerHandler.afterUpdate', false);
        insert ql1;
        
        Test.stopTest();
        
        System.assert([SELECT Id, LAN_Sales_Type2__c FROM SBQQ__QuoteLine__c LIMIT 1][0].LAN_Sales_Type2__c == clsSBQQ_QuoteTriggerHandler.SALES_TYPE_NEWEXPANSION);
    }
    
    @isTest
    private static void salesTypeAccountReactivation() {    
        Contract c = [SELECT Id, SBQQ__RenewalOpportunity__c, (SELECT Id FROM SBQQ__Subscriptions__r WHERE SBQQ__Product__c = :pLansweeper.Id) FROM Contract LIMIT 1];
        System.debug(c);
        System.Debug(c.SBQQ__Subscriptions__r);
        
        Opportunity o = new Opportunity(AccountId = a.Id, RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('LAN_New_Account_Reactivation').getRecordTypeId(), 
                                       StageName = 'Qualify', Name = 'Oppty', CloseDate = System.today().addDays(30), Pricebook2Id = Test.getStandardPricebookId());
        insert o;
        
        c.SBQQ__RenewalOpportunity__c = o.Id;
        update c;
        
        SBQQ__Quote__c q = new SBQQ__Quote__c();
        q.SBQQ__Account__c = a.Id;
        q.SBQQ__Opportunity2__c  = o.Id;
        
        insert q;

        Test.startTest();

        SBQQ__QuoteLine__c ql1 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = q.Id, SBQQ__Product__c = pLansweeper.Id, SBQQ__Quantity__c = 500, SBQQ__RenewedSubscription__c = c.SBQQ__Subscriptions__r[0].Id);
        clsTriggerHelpers.setTriggerRan('clsSBQQ_QuoteTriggerHandler.afterUpdate', false);
        insert ql1;
        
        Test.stopTest();
        
        System.assert([SELECT Id, LAN_Sales_Type2__c FROM SBQQ__QuoteLine__c LIMIT 1][0].LAN_Sales_Type2__c == clsSBQQ_QuoteTriggerHandler.SALES_TYPE_NEWREACTIVATION);
    }
    
    @isTest
    private static void salesTypeClassicToNew() {    
        Contract c = [SELECT Id, SBQQ__RenewalOpportunity__c, (SELECT Id, SBQQ__Product__c FROM SBQQ__Subscriptions__r) FROM Contract LIMIT 1];
        System.debug(c);
        System.Debug(c.SBQQ__Subscriptions__r);
        
        Opportunity o = new Opportunity(AccountId = a.Id, RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('LAN_Classic_to_New').getRecordTypeId(), 
                                       StageName = 'Qualify', Name = 'Oppty', CloseDate = System.today().addDays(30), Pricebook2Id = Test.getStandardPricebookId());
        insert o;
        
        c.SBQQ__RenewalOpportunity__c = o.Id;
        update c;
        
        SBQQ__Quote__c q = new SBQQ__Quote__c();
        q.SBQQ__Account__c = a.Id;
        q.SBQQ__Opportunity2__c  = o.Id;
        
        insert q;

        Test.startTest();

        List<SBQQ__QuoteLine__c> lstQuoteLines = new List<SBQQ__QuoteLine__c>();
        for(SBQQ__Subscription__c s : c.SBQQ__Subscriptions__r) {
            if(s.SBQQ__Product__c == pAgent.Id) {
                SBQQ__QuoteLine__c ql = new SBQQ__QuoteLine__c(SBQQ__Quote__c = q.Id, SBQQ__Product__c = pAgent.Id, SBQQ__Quantity__c = 500, SBQQ__UpgradedSubscription__c = s.Id);
                lstQuoteLines.add(ql);
            } else if(s.SBQQ__Product__c == pPremium.Id) {
                SBQQ__QuoteLine__c ql1 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = q.Id, SBQQ__Product__c = pPremium.Id, SBQQ__Quantity__c = 0, SBQQ__UpgradedSubscription__c = s.Id);
                lstQuoteLines.add(ql1);
                SBQQ__QuoteLine__c ql2 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = q.Id, SBQQ__Product__c = pLansweeper.Id, SBQQ__Quantity__c = 1000, SBQQ__UpgradedSubscription__c = null);
                lstQuoteLines.add(ql2);
            }
        }

        clsTriggerHelpers.setTriggerRan('clsSBQQ_QuoteTriggerHandler.afterUpdate', false);
        insert lstQuoteLines;
        
        Test.stopTest();
        
        for(SBQQ__QuoteLine__c ql : [SELECT Id, LAN_Sales_Type2__c, SBQQ__Product__c FROM SBQQ__QuoteLine__c]) {
            if(ql.SBQQ__Product__c == pPremium.Id) {
                System.assertEquals(clsSBQQ_QuoteTriggerHandler.SALES_TYPE_CLASSICTONEW, ql.LAN_Sales_Type2__c, 'Premium should have Sales Type Classic To New.');
            } else if(ql.SBQQ__Product__c == pLansweeper.Id) {
                System.assertEquals(clsSBQQ_QuoteTriggerHandler.SALES_TYPE_CLASSICTONEW, ql.LAN_Sales_Type2__c, 'Lansweeper shoudl have Sales Type Classic To New.');
            }
        }
    }
    
    @isTest
    private static void salesTypeMerge() {    
        Contract c = [SELECT Id, SBQQ__RenewalOpportunity__c, (SELECT Id FROM SBQQ__Subscriptions__r WHERE SBQQ__Product__c = :pLansweeper.Id) FROM Contract LIMIT 1];
        System.debug(c);
        System.Debug(c.SBQQ__Subscriptions__r);
        
        Opportunity o = new Opportunity(AccountId = a.Id, RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('LAN_Merge').getRecordTypeId(), 
                                       StageName = 'Qualify', Name = 'Oppty', CloseDate = System.today().addDays(30), Pricebook2Id = Test.getStandardPricebookId());
        insert o;
        
        c.SBQQ__RenewalOpportunity__c = o.Id;
        update c;
        
        SBQQ__Quote__c q = new SBQQ__Quote__c();
        q.SBQQ__Account__c = a.Id;
        q.SBQQ__Opportunity2__c  = o.Id;
        
        insert q;

        Test.startTest();

        SBQQ__QuoteLine__c ql1 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = q.Id, SBQQ__Product__c = pLansweeper.Id, SBQQ__Quantity__c = 500, SBQQ__RenewedSubscription__c = c.SBQQ__Subscriptions__r[0].Id);
        clsTriggerHelpers.setTriggerRan('clsSBQQ_QuoteTriggerHandler.afterUpdate', false);
        insert ql1;
        
        Test.stopTest();
        
        System.assert([SELECT Id, LAN_Sales_Type2__c FROM SBQQ__QuoteLine__c LIMIT 1][0].LAN_Sales_Type2__c == clsSBQQ_QuoteTriggerHandler.SALES_TYPE_MERGE);
    }
    
    @isTest
    private static void salesTypeSplit() {    
        Contract c = [SELECT Id, SBQQ__RenewalOpportunity__c, (SELECT Id FROM SBQQ__Subscriptions__r WHERE SBQQ__Product__c = :pLansweeper.Id) FROM Contract LIMIT 1];
        System.debug(c);
        System.Debug(c.SBQQ__Subscriptions__r);
        
        Opportunity o = new Opportunity(AccountId = a.Id, RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('LAN_Split').getRecordTypeId(), 
                                       StageName = 'Qualify', Name = 'Oppty', CloseDate = System.today().addDays(30), Pricebook2Id = Test.getStandardPricebookId());
        insert o;
        
        c.SBQQ__RenewalOpportunity__c = o.Id;
        update c;
        
        SBQQ__Quote__c q = new SBQQ__Quote__c();
        q.SBQQ__Account__c = a.Id;
        q.SBQQ__Opportunity2__c  = o.Id;
        
        insert q;

        Test.startTest();

        SBQQ__QuoteLine__c ql1 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = q.Id, SBQQ__Product__c = pLansweeper.Id, SBQQ__Quantity__c = 500, SBQQ__RenewedSubscription__c = c.SBQQ__Subscriptions__r[0].Id);
        clsTriggerHelpers.setTriggerRan('clsSBQQ_QuoteTriggerHandler.afterUpdate', false);
        insert ql1;
        
        Test.stopTest();
        
        System.assert([SELECT LAN_Opportunity_Record_Type__c FROM SBQQ__Quote__c LIMIT 1].LAN_Opportunity_Record_Type__c == 'LAN_Split');
        System.assertEquals(clsSBQQ_QuoteTriggerHandler.SALES_TYPE_SPLIT, [SELECT Id, LAN_Sales_Type2__c FROM SBQQ__QuoteLine__c LIMIT 1][0].LAN_Sales_Type2__c);
    }

    @isTest
    private static void salesTypeDelayedRenewal() {    
        Contract c = [SELECT Id, SBQQ__RenewalOpportunity__c, (SELECT Id FROM SBQQ__Subscriptions__r WHERE SBQQ__Product__c = :pLansweeper.Id) FROM Contract LIMIT 1];
        System.debug(c);
        System.Debug(c.SBQQ__Subscriptions__r);
        
        Opportunity o = new Opportunity(AccountId = a.Id, RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('LAN_Delayed_Renewal').getRecordTypeId(), 
                                       StageName = 'Qualify', Name = 'Oppty', CloseDate = System.today().addDays(30), Pricebook2Id = Test.getStandardPricebookId());
        insert o;
        
        c.SBQQ__RenewalOpportunity__c = o.Id;
        update c;
        
        SBQQ__Quote__c q = new SBQQ__Quote__c();
        q.SBQQ__Account__c = a.Id;
        q.SBQQ__Opportunity2__c  = o.Id;
        
        insert q;

        Test.startTest();

        SBQQ__QuoteLine__c ql1 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = q.Id, SBQQ__Product__c = pLansweeper.Id, SBQQ__Quantity__c = 500, 
            SBQQ__RenewedSubscription__c = c.SBQQ__Subscriptions__r[0].Id,
            SBQQ__StartDate__c = System.today().addDays(900));
        clsTriggerHelpers.setTriggerRan('clsSBQQ_QuoteTriggerHandler.afterUpdate', false);
        insert ql1;
        
        Test.stopTest();
        
        System.assert([SELECT LAN_Opportunity_Record_Type__c FROM SBQQ__Quote__c LIMIT 1].LAN_Opportunity_Record_Type__c == 'LAN_Delayed_Renewal');
        System.assertEquals(clsSBQQ_QuoteTriggerHandler.SALES_TYPE_DELAYEDRENEWAL, [SELECT Id, LAN_Sales_Type2__c FROM SBQQ__QuoteLine__c LIMIT 1][0].LAN_Sales_Type2__c);
    }

    @isTest
    private static void salesTypeAmendmentUpsell() {
        Contract c = [SELECT Id, SBQQ__RenewalOpportunity__c, (SELECT Id FROM SBQQ__Subscriptions__r WHERE SBQQ__Product__c = :pLansweeper.Id) FROM Contract LIMIT 1];
        System.debug(c);
        System.Debug(c.SBQQ__Subscriptions__r);
        
        Opportunity o = new Opportunity(AccountId = a.Id, RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('LAN_Up_Sell_Cross_Sell').getRecordTypeId(), 
                                       StageName = 'Qualify', Name = 'Oppty', CloseDate = System.today().addDays(30), Pricebook2Id = Test.getStandardPricebookId(),
                                       SBQQ__AmendedContract__c = c.Id);
        insert o;
        
        SBQQ__Quote__c q = new SBQQ__Quote__c();
        q.SBQQ__Account__c = a.Id;
        q.SBQQ__Opportunity2__c  = o.Id;
        
        insert q;

        Test.startTest();

        List<SBQQ__QuoteLine__c> lstQL = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c ql1 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = q.Id, SBQQ__Product__c = pLansweeper.Id, SBQQ__Quantity__c = 500, 
                                                       SBQQ__UpgradedSubscription__c = s1.Id, LAN_Original_Quantity__c = 100);
        lstQL.add(ql1);
        
        SBQQ__QuoteLine__c ql2 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = q.Id, SBQQ__Product__c = pLansweeper.Id, SBQQ__Quantity__c = 500);
        lstQL.add(ql2);
        
        clsTriggerHelpers.setTriggerRan('clsSBQQ_QuoteTriggerHandler.afterUpdate', false);
        insert lstQL;
        
        Test.stopTest();
        
        System.assert([SELECT Id, LAN_Sales_Type2__c FROM SBQQ__QuoteLine__c WHERE Id = :ql2.Id LIMIT 1][0].LAN_Sales_Type2__c == clsSBQQ_QuoteTriggerHandler.SALES_TYPE_UPSELL);
    }

    @isTest
    private static void salesTypeAmendmentCrossSell() {
        Contract c = [SELECT Id, SBQQ__RenewalOpportunity__c, (SELECT Id FROM SBQQ__Subscriptions__r WHERE SBQQ__Product__c = :pLansweeper.Id) FROM Contract LIMIT 1];
        System.debug(c);
        System.Debug(c.SBQQ__Subscriptions__r);
        
        Opportunity o = new Opportunity(AccountId = a.Id, RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('LAN_Up_Sell_Cross_Sell').getRecordTypeId(), 
                                       StageName = 'Qualify', Name = 'Oppty', CloseDate = System.today().addDays(30), Pricebook2Id = Test.getStandardPricebookId(),
                                       SBQQ__AmendedContract__c = c.Id);
        insert o;
        
        SBQQ__Quote__c q = new SBQQ__Quote__c();
        q.SBQQ__Account__c = a.Id;
        q.SBQQ__Opportunity2__c  = o.Id;
        
        insert q;

        Test.startTest();

        List<SBQQ__QuoteLine__c> lstQL = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c ql1 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = q.Id, SBQQ__Product__c = pLansweeper.Id, SBQQ__Quantity__c = 500, 
                                                       SBQQ__UpgradedSubscription__c = s1.Id, LAN_Original_Quantity__c = 100);
        lstQL.add(ql1);
        
        SBQQ__QuoteLine__c ql2 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = q.Id, SBQQ__Product__c = pAgent.Id, SBQQ__Quantity__c = 500);
        lstQL.add(ql2);
        
        clsTriggerHelpers.setTriggerRan('clsSBQQ_QuoteTriggerHandler.afterUpdate', false);
        insert lstQL;
        
        Test.stopTest();
        
        System.assert([SELECT Id, LAN_Sales_Type2__c FROM SBQQ__QuoteLine__c WHERE Id = :ql2.Id LIMIT 1][0].LAN_Sales_Type2__c == clsSBQQ_QuoteTriggerHandler.SALES_TYPE_CROSSSEL);
    }
    
    @isTest
    private static void quoteUncalculatedChange() {    
        Opportunity o = new Opportunity(AccountId = a.Id, RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('LAN_Classic_to_New').getRecordTypeId(), 
                                       StageName = 'Qualify', Name = 'Oppty', CloseDate = System.today().addDays(30), Pricebook2Id = Test.getStandardPricebookId());
        insert o;
        
        SBQQ__Quote__c q = new SBQQ__Quote__c();
        q.SBQQ__Account__c = a.Id;
        q.SBQQ__Opportunity2__c  = o.Id;
        
        insert q;

        Test.startTest();
        
        clsTriggerHelpers.setTriggerRan('clsSBQQ_QuoteTriggerHandler.afterUpdateQuoteUncalculated', false);
        
        q.SBQQ__LastCalculatedOn__c = system.today().addDays(1);
        update q;
        
        Test.stopTest();
        
        for(SBQQ__QuoteLine__c ql : [SELECT Id, LAN_Quote_Uncalculated__c FROM SBQQ__QuoteLine__c]) {
        	System.assertEquals(ql.LAN_Quote_Uncalculated__c, false);
        }
    }

    @isTest
    private static void testPartnerQuoteCreateAndChange() {    
        LAN_Partner_Tier__c partnerTierCertified = new LAN_Partner_Tier__c();
        partnerTierCertified.LAN_Partner_Type__c = 'Certified';
        partnerTierCertified.LAN_Active__c = true;
        partnerTierCertified.Name = 'Certified';
        insert partnerTierCertified;

        Account partnerAccount = new Account(Name='Test',RecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('LAN_Partner').getRecordTypeId(),
                                LAN_Enabled_as_partner__c=true,Type='Partner',
                                LAN_Partner_Tier__c=partnerTierCertified.Id, LAN_Account_Discount_Approved__c=true,LAN_Partner_Discount_Approved__c=true);
        insert partnerAccount;
        
        Opportunity partnerOppty = new Opportunity(AccountId = a.Id, LAN_Partner_Account__c = partnerAccount.Id, RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('LAN_Renewal').getRecordTypeId(), 
                                       StageName = 'Qualify', Name = 'Oppty3', CloseDate = System.today().addDays(30), Pricebook2Id = Test.getStandardPricebookId(), 
                                        LAN_Cleverbridge_SubscriptionID__c='testSubscriptionId', LAN_Original_Reference_Number__c='46435354');
        insert partnerOppty;

        SBQQ__Quote__c q1 = new SBQQ__Quote__c();
        q1.SBQQ__Account__c = partnerAccount.Id;
        q1.SBQQ__Opportunity2__c  = partnerOppty.Id;
        q1.SBQQ__Status__c = 'Draft';
        
        insert q1;

        Test.startTest();
        
        SBQQ__Quote__c q = new SBQQ__Quote__c();
        q.SBQQ__Account__c = partnerAccount.Id;
        q.SBQQ__Opportunity2__c  = partnerOppty.Id;
        q.SBQQ__Status__c = 'Draft';
        q.LAN_Partner_Number_Agents__c = 1;
        q.LAN_Partner_Number_Assets__c = '500';
        q.SBQQ__StartDate__c = system.today();
        
        insert q;
        
        clsTriggerHelpers.setTriggerRan('clsSBQQ_QuoteTriggerHandler.beforeUpdate', false);

        q.SBQQ__Status__c = 'Accepted';
        update q;

        Test.stopTest();

        List<SBQQ__QuoteLine__c> qLines = [select Id from SBQQ__QuoteLine__c where SBQQ__Quote__c =:q.Id];
        system.debug(qLines);
        System.assertNotEquals(qLines.isEmpty(), false);

        List<SBQQ__Quote__c> expiredQuotes = [select Id, SBQQ__Status__c, LAN_Quote_to_Cart__c from SBQQ__Quote__c where Id =:q1.Id];
        system.debug(expiredQuotes);
        System.assertEquals(expiredQuotes[0].SBQQ__Status__c, 'Rejected');
    }
}