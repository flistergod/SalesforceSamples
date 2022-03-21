@isTest
public class LAN_ctrlQuoteDocumentTest {

    private static SBQQ__QuoteDocument__c quoteDoc {
        get {
            return [SELECT Id FROM SBQQ__QuoteDocument__c LIMIT 1];
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

        Document document = new Document();
        document.Body = Blob.valueOf('Some Text');
        document.ContentType = 'application/pdf';
        document.DeveloperName = 'my_document';
        document.IsPublic = true;
        document.Name = 'My Document';
        document.FolderId = UserInfo.getUserId();

        insert document;

        SBQQ__QuoteDocument__c qDoc = new SBQQ__QuoteDocument__c();
        qDoc.SBQQ__Quote__c = q.Id;
        qDoc.SBQQ__DocumentId__c  = document.Id;
        
        insert qDoc;
    }

    @isTest
    private static void testGetQuoteDocument() {
        Test.startTest();

        String docJson = LAN_ctrlQuoteDocument.getQuoteDocument(quoteDoc.Id);

        Test.stopTest();

        System.assertNotEquals(docJson, 'NOT_FOUND');
    }

    @isTest
    private static void testGetQuoteDocumentNotExists() {
        Test.startTest();

        String docJson = LAN_ctrlQuoteDocument.getQuoteDocument('');

        Test.stopTest();

        System.assertEquals(docJson, 'NOT_FOUND');
    }
}