@isTest
public class LAN_ctrlSubscriptionTest {
    private static Opportunity o {
        get {
            return [SELECT Id FROM Opportunity LIMIT 1];
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
        
        Account a = new Account(Name='Test', RecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('LAN_Account').getRecordTypeId());
        insert a;

        Contract c = new Contract(AccountId = a.Id, Status = 'Draft', StartDate = System.today().addDays(-350), ContractTerm  = 12, SBQQ__RenewalPricebookId__c = Test.getStandardPricebookId());
        insert c;
        
        SBQQ__Subscription__c s1 = new SBQQ__Subscription__c(SBQQ__Contract__c = c.Id, SBQQ__Account__c = a.Id, SBQQ__Product__c = pLansweeper.Id, SBQQ__Quantity__c = 500, 
        SBQQ__CustomerPrice__c = 495, SBQQ__RegularPrice__c = 495, SBQQ__ListPrice__c = 1, SBQQ__NetPrice__c = 1, SBQQ__ProductSubscriptionType__c = 'Renewable', 
        SBQQ__PricingMethod__c = 'List', SBQQ__SubscriptionStartDate__c = System.today().addDays(-350), SBQQ__SubscriptionType__c = 'Renewable', SBQQ__Number__c = 1);
        insert s1;

        Opportunity o = new Opportunity(AccountId = a.Id, RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('LAN_Renewal').getRecordTypeId(), 
                                       SBQQ__RenewedContract__c = c.Id, StageName = 'Qualify', Name = 'Oppty', CloseDate = System.today().addDays(365), Pricebook2Id = Test.getStandardPricebookId());
        insert o;
        
        SBQQ__Quote__c q = new SBQQ__Quote__c();
        q.SBQQ__Account__c = a.Id;
        q.SBQQ__Opportunity2__c  = o.Id;
        q.SBQQ__StartDate__c = System.today();
        
        insert q;
    }

    @isTest
    private static void testGetOpptySubscriptions() {
        Test.startTest();

        String opptySubscriptionsJson = LAN_ctrlSubscription.getOpptySubscriptions((String) o.Id, 1, 10, 0, '');

        Test.stopTest();

        System.assertNotEquals(opptySubscriptionsJson, null);
    }

    @isTest
    private static void testGetOpptySubscriptionsCount() {
        Test.startTest();

        integer opptySubscriptionsCount = LAN_ctrlSubscription.getOpptySubscriptionsCount((String) o.Id,'');

        Test.stopTest();

        System.assertEquals(opptySubscriptionsCount, 1);
    }
}