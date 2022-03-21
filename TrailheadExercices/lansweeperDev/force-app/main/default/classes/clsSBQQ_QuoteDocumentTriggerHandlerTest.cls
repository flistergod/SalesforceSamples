@isTest
public class clsSBQQ_QuoteDocumentTriggerHandlerTest {

    @isTest
    private static void testOnQuoteDocumentInsert() {
        Test.startTest();
        
        Pricebook2 pb = new Pricebook2(Id = Test.getStandardPricebookId(), isActive = true);
        
        Account a = new Account(Name='Test', RecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('LAN_Account').getRecordTypeId());
        insert a;

        Opportunity o = new Opportunity(AccountId = a.Id, RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('LAN_Renewal').getRecordTypeId(), 
                                       StageName = 'Qualify', Name = 'Oppty', CloseDate = System.today().addDays(365), Pricebook2Id = Test.getStandardPricebookId());
        insert o;

        
        SBQQ__QuoteTemplate__c template= new SBQQ__QuoteTemplate__c(Name='No Discount');
        insert template;
        
        SBQQ__Quote__c q = new SBQQ__Quote__c();
        q.SBQQ__Account__c = a.Id;
        q.SBQQ__Opportunity2__c  = o.Id;
        q.SBQQ__StartDate__c = System.today();
        q.LAN_Main_Quote_Document_Id__c=null;
        q.SBQQ__QuoteTemplateId__c=template.Id;
        insert q;

    SBQQ__QuoteDocument__c doc= new SBQQ__QuoteDocument__c();
        doc.SBQQ__Quote__c=q.Id;
        doc.Name=q.Name+'_Document';
        doc.SBQQ__QuoteTemplate__c=template.Id;
        insert doc;
        
        

        Test.stopTest();

        q=[select Id, LAN_Main_Quote_Document_Id__c from SBQQ__Quote__c where Id=:q.Id];

        System.assertNotEquals(q.LAN_Main_Quote_Document_Id__c, null);
        System.assertEquals(q.LAN_Main_Quote_Document_Id__c, doc.Id);
    }
}