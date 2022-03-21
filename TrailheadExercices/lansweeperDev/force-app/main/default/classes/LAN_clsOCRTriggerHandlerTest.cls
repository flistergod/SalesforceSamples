@isTest
private with sharing class LAN_clsOCRTriggerHandlerTest {
    private static Contact c {
        get {
            return [SELECT Id FROM Contact WHERE AccountId = :a.Id LIMIT 1];
        }
    }

    private static Account a {
        get {
            return [SELECT Id FROM Account LIMIT 1];
        }
    }

    private static Opportunity o {
        get {
            return [SELECT Id FROM Opportunity WHERE AccountId = :a.Id LIMIT 1];
        }
    }

    @TestSetup
    private static void setupTestData(){
        Account a = new Account(Name='Test', RecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('LAN_Account').getRecordTypeId());
        insert a;

        Opportunity o = new Opportunity(AccountId = a.Id, RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('LAN_Renewal').getRecordTypeId(), 
                                       StageName = 'Qualify', Name = 'Oppty', CloseDate = System.today().addDays(365), Pricebook2Id = Test.getStandardPricebookId());
        insert o;

        Contact c = new Contact(AccountId = a.Id, LastName = 'ACBD', Email = 'test@invalid.com');
        insert c;
    }

    @isTest
    private static void testOCR() {
        Test.startTest();

        OpportunityContactRole ocr = new OpportunityContactRole(OpportunityId = o.Id, ContactId = c.Id, IsPrimary = true);
        insert ocr;

        Test.stopTest();

        Opportunity oResult = [SELECT Id, LAN_Contact_Name__c FROM Opportunity WHERE Id = :o.Id LIMIT 1];
        System.assertEquals(c.Id, oResult.LAN_Contact_Name__c);
    }

    @isTest
    private static void testOCRNonPrimary() {
        Test.startTest();

        OpportunityContactRole ocr = new OpportunityContactRole(OpportunityId = o.Id, ContactId = c.Id, IsPrimary = false);
        insert ocr;

        Test.stopTest();

        Opportunity oResult = [SELECT Id, LAN_Contact_Name__c FROM Opportunity WHERE Id = :o.Id LIMIT 1];
        System.assertEquals(null, oResult.LAN_Contact_Name__c);
    }
}