@isTest
private with sharing class LAN_clsOpportunityTriggerHandlerTest {
    private static Account a {
        get {
            return [SELECT Id FROM Account WHERE Name = 'Test' AND RecordType.DeveloperName = 'LAN_Account'];
        }
    }
    
    private static List<Opportunity> lstO {
        get {
            return [SELECT Id, CurrencyIsoCode, Pricebook2Id FROM Opportunity WHERE AccountId = :a.Id AND RecordTypeId = :LAN_clsStaticValues.OPPORTUNITY_RT_ID_NEWLOGO];
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

    private static Opportunity parentO {
        get {
            return [SELECT Id, LAN_Primary_Opportunity__c FROM Opportunity WHERE AccountId = :a.Id AND RecordTypeId = :LAN_clsStaticValues.OPPORTUNITY_RT_ID_PARENT];
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
        
        List<Opportunity> lstO = new List<Opportunity>();
        Opportunity oParent = new Opportunity(AccountId = a.Id, RecordTypeId = LAN_clsStaticValues.OPPORTUNITY_RT_ID_PARENT, StageName = 'Qualify',
                                                Name = 'Parent', CloseDate = System.today().addDays(30), Pricebook2Id = Test.getStandardPricebookId(),
                                                CurrencyIsoCode= 'EUR');
        insert oParent;

        Opportunity oChild1 = new Opportunity(AccountId = a.Id, RecordTypeId = LAN_clsStaticValues.OPPORTUNITY_RT_ID_NEWLOGO, LAN_Primary__c = false,
                                       StageName = 'Qualify', Name = 'Oppty', CloseDate = System.today().addDays(30), Pricebook2Id = Test.getStandardPricebookId(), 
                                       CurrencyIsoCode = 'EUR', LAN_Parent_Opportunity__c = oParent.Id);
        lstO.add(oChild1);

        Opportunity oChild2 = new Opportunity(AccountId = a.Id, RecordTypeId = LAN_clsStaticValues.OPPORTUNITY_RT_ID_NEWLOGO, LAN_Primary__c = false,
                                       StageName = 'Qualify', Name = 'Oppty', CloseDate = System.today().addDays(30), Pricebook2Id = Test.getStandardPricebookId(), 
                                       CurrencyIsoCode = 'EUR', LAN_Parent_Opportunity__c = oParent.Id);
        lstO.add(oChild2);

        insert lstO;
    }

    @isTest
    private static void testParentPrimaryLookup() {
        Test.startTest();

        System.assertEquals(null, parentO.LAN_Primary_Opportunity__c, 'Primary Opportunity should still be null');

        Opportunity childPrimary = new Opportunity(Id = lstO[0].Id, LAN_Primary__c = true);
        update childPrimary;

        Test.stopTest();

        Opportunity parentAfter = [SELECT Id, LAN_Primary_Opportunity__c FROM Opportunity WHERE Id = :parentO.Id];
        System.assertEquals(lstO[0].Id, parentAfter.LAN_Primary_Opportunity__c, 'Primary Opportunity is not the expected on Parent Opportunity');
    }

    @isTest
    private static void testUniquePrimary() {
        System.assertEquals(null, parentO.LAN_Primary_Opportunity__c, 'Primary Opportunity should still be null');

        Opportunity childPrimary = new Opportunity(Id = lstO[0].Id, LAN_Primary__c = true);
        update childPrimary;

        Test.startTest();

        childPrimary = new Opportunity(Id = lstO[1].Id, LAN_Primary__c = true);
        clsTriggerHelpers.setTriggerRan('LAN_clsOpportunityTriggerHandler.beforeUpdate.handleParentPrimaryOpportunity', false);
        update childPrimary;

        Test.stopTest();

        System.assertEquals(1, [SELECT Id, LAN_Primary_Opportunity__c FROM Opportunity WHERE LAN_Primary__c = true].size(), 'There should only be 1 Primary Opportunity');
    }
}