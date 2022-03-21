@isTest(IsParallel=false)
private with sharing class clsSBQQ_SubscriptionTriggerHandlerTest {
    private static Account a {
        get {
            return [SELECT Id FROM Account WHERE Name = 'Test' AND Recordtype.DeveloperName = 'LAN_Account'];
        }
    }
    
    private static Opportunity o {
        get {
            return [SELECT Id FROM Opportunity WHERE AccountId = :a.Id LIMIT 1];
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
	
    @testSetup
    private static void setupTestData() {
        Pricebook2 pb = new Pricebook2(Id = Test.getStandardPricebookId(), isActive = true);
        update pb;
        
        Product2 pLansweeper = new Product2(Name = 'Lansweeper', Family = 'Existing Business');
        insert pLansweeper;
        
        Product2 pAgent = new Product2(Name = 'Helpdesk Agent', Family = 'Existing Business');
        insert pAgent;
        
        Account a = new Account(Name='Test', RecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('LAN_Account').getRecordTypeId());
        insert a;
        
        Contract c = new Contract(AccountId = a.Id, Status = 'Draft', StartDate = System.today(), ContractTerm  = 12);
        insert c;
        
        SBQQ__Subscription__c s1 = new SBQQ__Subscription__c(SBQQ__Contract__c = c.Id, SBQQ__Account__c = a.Id, SBQQ__Product__c = pLansweeper.Id, SBQQ__Quantity__c = 500, SBQQ__CustomerPrice__c = 495, SBQQ__RegularPrice__c = 495, SBQQ__ListPrice__c = 1, SBQQ__ProductSubscriptionType__c = 'Renewable', SBQQ__PricingMethod__c = 'List', SBQQ__SubscriptionStartDate__c = System.today(), SBQQ__SubscriptionType__c = 'Renewable');
        insert s1;
        
        c.LAN_Days_before_End_Date_Renewal_Quote__c = 0;
        c.SBQQ__MasterContract__c = false;
        
        update c;
    }

    @isTest
    private static void qouteOneTimeDiscount() {    
        Contract c = [SELECT Id, SBQQ__RenewalOpportunity__c, (SELECT Id, SBQQ__RegularPrice__c, SBQQ__CustomerPrice__c FROM SBQQ__Subscriptions__r) FROM Contract LIMIT 1];
        System.debug(c);
        System.Debug(c.SBQQ__Subscriptions__r);

        for(SBQQ__Subscription__c s : c.SBQQ__Subscriptions__r) {
            s.SBQQ__Discount__c = 0.20;
            s.SBQQ__CustomerPrice__c = 396;
        }

        update c.SBQQ__Subscriptions__r;
        c = [SELECT Id, SBQQ__RenewalOpportunity__c, (SELECT Id, SBQQ__RegularPrice__c, SBQQ__CustomerPrice__c, SBQQ__Discount__c FROM SBQQ__Subscriptions__r) FROM Contract LIMIT 1];

        for(SBQQ__Subscription__c s : c.SBQQ__Subscriptions__r) {
            System.assertEquals(null, s.SBQQ__Discount__c);
            System.assertEquals(s.SBQQ__RegularPrice__c, s.SBQQ__CustomerPrice__c);
        }
        
        Opportunity o = new Opportunity(AccountId = a.Id, RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('LAN_Renewal').getRecordTypeId(), 
                                       StageName = 'Qualify', Name = 'Oppty', CloseDate = System.today().addDays(30), Pricebook2Id = Test.getStandardPricebookId());
        insert o;
        
        c.SBQQ__RenewalOpportunity__c = o.Id;
        update c;
        
        Test.startTest();

        SBQQ__Quote__c q = new SBQQ__Quote__c();
        q.SBQQ__Account__c = a.Id;
        q.SBQQ__Opportunity2__c  = o.Id;
        
        insert q;

        SBQQ__QuoteLine__c ql1 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = q.Id, SBQQ__Product__c = pLansweeper.Id, SBQQ__Quantity__c = 500, SBQQ__RenewedSubscription__c = c.SBQQ__Subscriptions__r[0].Id);
        insert ql1;
        
        Test.stopTest();
    }

    @isTest
    private static void qouteOneTimeDiscountAmount() {    
        Contract c = [SELECT Id, SBQQ__RenewalOpportunity__c, (SELECT Id, SBQQ__RegularPrice__c, SBQQ__CustomerPrice__c, SBQQ__AdditionalDiscountAmount__c FROM SBQQ__Subscriptions__r) FROM Contract LIMIT 1];
        System.debug(c);
        System.Debug(c.SBQQ__Subscriptions__r);

        for(SBQQ__Subscription__c s : c.SBQQ__Subscriptions__r) {
            s.SBQQ__AdditionalDiscountAmount__c = 0.20;
            s.SBQQ__CustomerPrice__c = 396;
        }

        update c.SBQQ__Subscriptions__r;
        c = [SELECT Id, SBQQ__RenewalOpportunity__c, (SELECT Id, SBQQ__RegularPrice__c, SBQQ__CustomerPrice__c, SBQQ__Discount__c, SBQQ__AdditionalDiscountAmount__c FROM SBQQ__Subscriptions__r) FROM Contract LIMIT 1];

        for(SBQQ__Subscription__c s : c.SBQQ__Subscriptions__r) {
            System.assertEquals(s.SBQQ__AdditionalDiscountAmount__c, s.SBQQ__AdditionalDiscountAmount__c);
            System.assertEquals(s.SBQQ__RegularPrice__c, s.SBQQ__CustomerPrice__c);
        }
        
        Opportunity o = new Opportunity(AccountId = a.Id, RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('LAN_Renewal').getRecordTypeId(), 
                                       StageName = 'Qualify', Name = 'Oppty', CloseDate = System.today().addDays(30), Pricebook2Id = Test.getStandardPricebookId());
        insert o;
        
        c.SBQQ__RenewalOpportunity__c = o.Id;
        update c;

        Test.startTest();
        
        SBQQ__Quote__c q = new SBQQ__Quote__c();
        q.SBQQ__Account__c = a.Id;
        q.SBQQ__Opportunity2__c  = o.Id;
        
        insert q;

        SBQQ__QuoteLine__c ql1 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = q.Id, SBQQ__Product__c = pLansweeper.Id, SBQQ__Quantity__c = 500, SBQQ__RenewedSubscription__c = c.SBQQ__Subscriptions__r[0].Id);
        insert ql1;
        
        Test.stopTest();
    }
}