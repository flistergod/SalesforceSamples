@isTest(IsParallel=false)
private with sharing class LAN_clsSBQQ_QuoteLineTriggerHandlerTest {
	private static Account a {
        get {
            return [SELECT Id FROM Account WHERE Name = 'Test' AND RecordType.DeveloperName = 'LAN_Account'];
        }
    }
    
    private static Product2 pLansweeper {
        get {
            return [SELECT Id, Name FROM Product2 WHERE Family = 'Existing Business' AND Name = 'Lansweeper' LIMIT 1];
        }
    }
    
    @testSetup
    private static void setupTestData() {
        Account a = new Account(Name='Test', RecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('LAN_Account').getRecordTypeId());
        insert a;
        
        Product2 pLansweeper = new Product2(Name = 'Lansweeper', Family = 'Existing Business');
        insert pLansweeper;
    }
    
    @isTest
    private static void testQuoteLineTrigger() {    
        Opportunity o = new Opportunity(AccountId = a.Id, RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('LAN_Classic_to_New').getRecordTypeId(), 
                                       StageName = 'Qualify', Name = 'Oppty', CloseDate = System.today().addDays(30), Pricebook2Id = Test.getStandardPricebookId());
        insert o;
        
        SBQQ__Quote__c q = new SBQQ__Quote__c();
        q.SBQQ__Account__c = a.Id;
        q.SBQQ__Opportunity2__c  = o.Id;
        q.SBQQ__LastCalculatedOn__c = system.today().addDays(2);
        q.SBQQ__LastSavedOn__c = system.today();
        
        insert q;

        Test.startTest();
        
        clsTriggerHelpers.setTriggerRan('clsSBQQ_QuoteLineTriggerHandler.afterInsert', false);

        List<SBQQ__QuoteLine__c> lstQuoteLines = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c ql2 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = q.Id, SBQQ__Product__c = pLansweeper.Id, SBQQ__Quantity__c = 1000,LAN_Quote_Uncalculated__c = false, 
                                                        LAN_Cleverbridge_ProductID__c=4675, LAN_Cleverbridge_RunningNo__c=345, LAN_Sales_Type2__c='', SBQQ__UpgradedSubscription__c = null);
		lstQuoteLines.add(ql2);
        insert lstQuoteLines;
        
        Test.stopTest();
        
        for(SBQQ__QuoteLine__c ql : [SELECT Id, LAN_Sales_Type2__c FROM SBQQ__QuoteLine__c]) {
        	System.assertEquals(ql.LAN_Sales_Type2__c, 'Classic-to-New');
        }
    }
}