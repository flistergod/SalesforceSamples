@isTest
private with sharing class LAN_clsInvocableMergeRenewalSubsLTest {
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
            return [SELECT Id, Name FROM Product2 WHERE Family = 'Existing Business' AND Name = 'Lansweeper' LIMIT 1];
        }
    }
    
    private static Product2 pAgent {
        get {
            return [SELECT Id, Name FROM Product2 WHERE Family = 'Existing Business' AND Name = 'Helpdesk Agent' LIMIT 1];
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
        
        Product2 pLansweeper = new Product2(Name = 'Lansweeper', Family = 'Existing Business');
        insert pLansweeper;
        
        Product2 pAgent = new Product2(Name = 'Helpdesk Agent', Family = 'Existing Business');
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
        SBQQ__Subscription__c s2 = new SBQQ__Subscription__c(SBQQ__Contract__c = c.Id, SBQQ__Account__c = a.Id, SBQQ__Product__c = pLansweeper.Id, SBQQ__Quantity__c = 500, SBQQ__CustomerPrice__c = 495, SBQQ__ListPrice__c = 1, SBQQ__ProductSubscriptionType__c = 'Renewable', SBQQ__PricingMethod__c = 'List', SBQQ__SubscriptionStartDate__c = System.today(), SBQQ__SubscriptionType__c = 'Renewable');
        lstSubscriptions.add(s2);
        SBQQ__Subscription__c s3 = new SBQQ__Subscription__c(SBQQ__Contract__c = c.Id, SBQQ__Account__c = a.Id, SBQQ__Product__c = pAgent.Id, SBQQ__Quantity__c = 1, SBQQ__CustomerPrice__c = 500, SBQQ__ListPrice__c = 500, SBQQ__ProductSubscriptionType__c = 'Renewable', SBQQ__PricingMethod__c = 'List', SBQQ__SubscriptionStartDate__c = System.today(), SBQQ__SubscriptionType__c = 'Renewable');
        lstSubscriptions.add(s3);

        insert lstSubscriptions;
        
        c.LAN_Days_before_End_Date_Renewal_Quote__c = 0;
        c.SBQQ__MasterContract__c = false;
        
        update c;
    }

    @isTest
    private static void testInvocableMergeSubs() {
        Contract c = [SELECT Id, SBQQ__RenewalOpportunity__c, EndDate, (SELECT Id FROM SBQQ__Subscriptions__r WHERE SBQQ__Product__c = :pLansweeper.Id) FROM Contract LIMIT 1];
        
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
        SBQQ__QuoteLine__c ql2 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = q.Id, SBQQ__Product__c = pLansweeper.Id, SBQQ__Quantity__c = 500, SBQQ__RenewedSubscription__c = c.SBQQ__Subscriptions__r[1].Id);
        List<SBQQ__QuoteLine__c> lstQ = new List<SBQQ__QuoteLine__c>();
        lstQ.add(ql1);
        lstQ.add(ql2);
        List<List<SBQQ__QuoteLine__c>> lstTest = new List<List<SBQQ__QuoteLine__c>>{lstQ};
        List<List<SBQQ__QuoteLine__c>> lstResult = LAN_clsInvocableMergeRenewalSubsLines.mergeQuoteLines(lstTest);
        
        Test.stopTest();

        System.assertEquals(1, lstResult[0].size());
    }
}