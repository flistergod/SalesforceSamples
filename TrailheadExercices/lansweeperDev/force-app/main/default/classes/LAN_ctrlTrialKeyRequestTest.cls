@isTest
private with sharing class LAN_ctrlTrialKeyRequestTest {
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

    private static LAN_License_Key__c k {
        get {
            return [SELECT Id, LAN_License_Key_Location__c FROM LAN_License_Key__c WHERE LAN_Account__c = :a.Id LIMIT 1];
        }
    }

    @testSetup
    private static void setupTestData() {
        Account a = new Account(Name='Test', RecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('LAN_Account').getRecordTypeId());
        insert a;

        Opportunity o = new Opportunity(AccountId = a.Id, RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('LAN_Renewal').getRecordTypeId(), 
                                       StageName = 'Qualify', Name = 'Oppty', CloseDate = System.today().addDays(365), Pricebook2Id = Test.getStandardPricebookId());
        insert o;
    }

    @isTest
    private static void testSuccess() {
        Test.setMock(HttpCalloutMock.class, new LAN_ctrlTrialKeyMock(LAN_ctrlTrialKeyMock.MOCK_TYPE.SUCCESS));
        LAN_License_Key__c k = new LAN_License_Key__c(LAN_Account__c = a.Id, LAN_Opportunity__c = o.Id, LAN_Status__c = 'In Review');
        insert k;

        User u = new User(Id = UserInfo.getUserId());

        Test.startTest();

        System.runAs(u) {
            LAN_ctrlTrialKeyRequest.LAN_TrialKeyRequestClass r = new LAN_ctrlTrialKeyRequest.LAN_TrialKeyRequestClass(k.Id, 20, 'test@test.com', 'Salesforce', 'testUser@test.com', false);
            r.type = 'Inventory';

            LAN_clsQueueTrialKeyCallout t = new LAN_clsQueueTrialKeyCallout(new List<LAN_ctrlTrialKeyRequest.LAN_TrialKeyRequestClass>{r});
            t.execute(null);
        }

        LAN_License_Key__c validateKey = [SELECT Id, LAN_License_Key_Location__c FROM LAN_License_Key__c WHERE LAN_Account__c = :a.Id LIMIT 1];
        System.assertEquals(LAN_ctrlTrialKeyMock.MOCK_URL, validateKey.LAN_License_Key_Location__c);

        Test.stopTest();
    }

    @isTest
    private static void testHelpdeskSuccess() {
        Test.setMock(HttpCalloutMock.class, new LAN_ctrlTrialKeyMock(LAN_ctrlTrialKeyMock.MOCK_TYPE.SUCCESS));
        LAN_License_Key__c k = new LAN_License_Key__c(LAN_Account__c = a.Id, LAN_Opportunity__c = o.Id);
        insert k;

        Test.startTest();

        LAN_ctrlTrialKeyRequest.LAN_TrialKeyRequestClass r = new LAN_ctrlTrialKeyRequest.LAN_TrialKeyRequestClass(k.Id, 20, 'test@test.com', 'Salesforce', 'testUser@test.com', 200);
        r.type = 'Helpdesk';

        LAN_clsQueueTrialKeyCallout t = new LAN_clsQueueTrialKeyCallout(new List<LAN_ctrlTrialKeyRequest.LAN_TrialKeyRequestClass>{r});
        t.execute(null);

        Test.stopTest();

        LAN_License_Key__c validateKey = [SELECT Id, LAN_License_Key_Location__c FROM LAN_License_Key__c WHERE LAN_Account__c = :a.Id LIMIT 1];
        System.assertEquals(LAN_ctrlTrialKeyMock.MOCK_URL, validateKey.LAN_License_Key_Location__c);
    }

    @isTest
    private static void testFail() {
        Test.setMock(HttpCalloutMock.class, new LAN_ctrlTrialKeyMock(LAN_ctrlTrialKeyMock.MOCK_TYPE.FAIL));
        LAN_License_Key__c k = new LAN_License_Key__c(LAN_Account__c = a.Id, LAN_Opportunity__c = o.Id);
        insert k;

        Test.startTest();

        LAN_ctrlTrialKeyRequest.LAN_TrialKeyRequestClass r = new LAN_ctrlTrialKeyRequest.LAN_TrialKeyRequestClass(k.ID, 20, 'test@test.com', 'Salesforce', 'testUser@test.com', false);
        
        try {
            LAN_clsQueueTrialKeyCallout t = new LAN_clsQueueTrialKeyCallout(new List<LAN_ctrlTrialKeyRequest.LAN_TrialKeyRequestClass>{r});
            t.execute(null);
        } catch(Exception e) {
            System.assertEquals('LAN_clsQueueTrialKeyCallout.LAN_ctrlTrialKeyRequestException', e.getTypeName());
            System.assert(e.getMessage().contains('could not connect'));
        }
        
        Test.stopTest();
    }
}