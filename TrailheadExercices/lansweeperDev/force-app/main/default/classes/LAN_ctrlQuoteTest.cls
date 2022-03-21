@isTest
public class LAN_ctrlQuoteTest {

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
    private static void testGetOpptyQuotes() {
        Test.startTest();

        String opptyQuotesJson = LAN_ctrlQuote.getOpptyQuotes((String) o.Id, 1, 10, 0, '');

        Test.stopTest();

        System.assertNotEquals(opptyQuotesJson, null);
    }

    @isTest
    private static void testGetOpptyQuotesCount() {
        Test.startTest();

        integer opptyQuotesCount = LAN_ctrlQuote.getOpptyQuotesCount((String) o.Id,'');

        Test.stopTest();

        System.assertEquals(opptyQuotesCount, 1);
    }
}