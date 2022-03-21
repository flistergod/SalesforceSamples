@isTest
private with sharing class LAN_ctrlQuoteToCartTest {
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

    private static SBQQ__Quote__c q {
        get {
            return [SElECT Id FROM SBQQ__Quote__c WHERE SBQQ__Account__c = :a.Id LIMIT 1];
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

        Opportunity o = new Opportunity(AccountId = a.Id, RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('LAN_Renewal').getRecordTypeId(), 
                                       StageName = 'Qualify', Name = 'Oppty', CloseDate = System.today().addDays(365), Pricebook2Id = Test.getStandardPricebookId());
        insert o;
        
        SBQQ__Quote__c q = new SBQQ__Quote__c();
        q.SBQQ__Account__c = a.Id;
        q.SBQQ__Opportunity2__c  = o.Id;
        q.SBQQ__StartDate__c = System.today();
        
        insert q;
    }

    @isTest
    private static void testQTCSuccess() {
        Test.setMock(HttpCalloutMock.class, new LAN_ctrlQuoteToCartMock(LAN_ctrlQuoteToCartMock.MOCK_TYPE.SUCCESS));

        Test.startTest();

        String respURL = LAN_ctrlQuoteToCart.getQtCUrl((String) q.Id);

        Test.stopTest();

        System.assertEquals(LAN_ctrlQuoteToCartMock.MOCK_URL, respURL);
    }

    @isTest
    private static void testQTCFail() {
        Test.setMock(HttpCalloutMock.class, new LAN_ctrlQuoteToCartMock(LAN_ctrlQuoteToCartMock.MOCK_TYPE.FAIL));

        Test.startTest();

        try {
            String respURL = LAN_ctrlQuoteToCart.getQtCUrl((String) q.Id);
        } catch (Exception e) {
            System.assertEquals('LAN_ctrlQuoteToCart.LAN_ctrlQuoteToCartNoResultException', e.getTypeName());
            System.assert(e.getMessage().contains('We are not able to talk to Cleverbridge'));
        }

        Test.stopTest();
    }
}