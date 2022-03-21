@isTest(IsParallel=false)
private with sharing class LAN_OpportunityLineItemHandlerTest {
    private static Account a {
        get {
            return [SELECT Id FROM Account WHERE Name = 'Test' AND RecordType.DeveloperName = 'LAN_Partner'];
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
    
    private static SBQQ__Quote__c quote {
        get {
            return [SELECT Id, SBQQ__Opportunity2__c FROM SBQQ__Quote__c LIMIT 1];
        }
    }
    
    private static PricebookEntry pe {
        get {
            return [SELECT Id FROM PricebookEntry LIMIT 1];
        }
    }
    
    private static Contract contract {
        get {
            return [SELECT Id FROM Contract LIMIT 1];
        }
    }
	
    @testSetup
    private static void setupTestData() {
        LAN_Partner_Tier__c partnerTierCertified = new LAN_Partner_Tier__c();
        partnerTierCertified.LAN_Partner_Type__c = 'Certified';
        partnerTierCertified.LAN_Active__c = true;
        partnerTierCertified.Name = 'Certified';
        insert partnerTierCertified;
        
        Product2 pLansweeper = new Product2(Name = 'Lansweeper', Family = 'Existing Business');
        insert pLansweeper;
        
        PricebookEntry priceEntry = new PricebookEntry();
	    priceEntry.pricebook2Id = Test.getStandardPricebookId();
	    priceEntry.product2id = pLansweeper.id;
	    priceEntry.unitprice = 1250.0;
	    priceEntry.isactive = true;
	    insert priceEntry;
        
        system.debug(priceEntry);
        
        Account a = new Account(Name='Test',RecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('LAN_Partner').getRecordTypeId(),
                                LAN_Enabled_as_partner__c=true,Type='Partner',
                                LAN_Partner_Tier__c=partnerTierCertified.Id, LAN_Account_Discount_Approved__c=true,LAN_Partner_Discount_Approved__c=true);
        insert a;
        
        Opportunity o = new Opportunity(AccountId = a.Id, RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('LAN_Renewal').getRecordTypeId(), 
                                       StageName = 'Qualify', Name = 'Oppty3', CloseDate = System.today().addDays(30), Pricebook2Id = Test.getStandardPricebookId(), 
                                        LAN_Cleverbridge_SubscriptionID__c='testSubscriptionId', LAN_Original_Reference_Number__c='46435354');
        insert o;
        
        Opportunity o1 = new Opportunity(AccountId = a.Id, RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('LAN_Renewal').getRecordTypeId(), 
                                       StageName = 'Qualify', Name = 'Oppty1', CloseDate = System.today().addDays(30), Pricebook2Id = Test.getStandardPricebookId(), 
                                        LAN_Cleverbridge_SubscriptionID__c='testSubscriptionId', LAN_Original_Reference_Number__c='46435354');
        insert o1;
        
        OpportunityLineItem ol1 = new OpportunityLineItem(OpportunityId = o1.Id, LAN_CB_Product_ID__c = 23543214, LAN_Running_No__c = 12454312,
                                                         Quantity=10, UnitPrice=9, PricebookEntryId=priceEntry.Id, LAN_Quote_Uncalculated__c=true);
        
        insert ol1;
        
        Contract c = new Contract(AccountId = a.Id, Status = 'Draft', StartDate = System.today(), ContractTerm  = 12);
        insert c;
        
        c.SBQQ__RenewalOpportunity__c = o.Id;
        c.SBQQ__Opportunity__c = o1.Id;
        update c;
        
        o.SBQQ__RenewedContract__c = c.Id;
        update o;
        
        SBQQ__Quote__c q = new SBQQ__Quote__c();
        q.SBQQ__Account__c = a.Id;
        q.SBQQ__Opportunity2__c  = o.Id;
        q.SBQQ__Type__c = 'Renewal';
        q.SBQQ__Status__c = 'Draft';
        
        insert q;
        
        Batch_Queue__c bQueue = new Batch_Queue__c(Type__c='Batch - Partner Discount', Status__c='To be recalculated',Opportunity__c=o.Id);
        insert bQueue;
    }
    
    @isTest
    private static void triggerOpptyProductPlatformEvent() {

        Test.startTest();
        
        List<SBQQ__QuoteLine__c> lstQuoteLines = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c ql2 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote.Id, SBQQ__Product__c = pLansweeper.Id, SBQQ__Quantity__c = 1000, LAN_Cleverbridge_ProductID__c = 23543214, LAN_Cleverbridge_RunningNo__c = 12454312,LAN_Quote_Uncalculated__c = false, LAN_Sales_Type2__c='', SBQQ__UpgradedSubscription__c = null);
		lstQuoteLines.add(ql2);
        insert lstQuoteLines;
        
        List<OpportunityLineItem> lstOpptyLines = new List<OpportunityLineItem>();
        OpportunityLineItem ol1 = new OpportunityLineItem(SBQQ__QuoteLine__c = ql2.Id, OpportunityId = o.Id, LAN_CB_Product_ID__c = 23543214, LAN_Running_No__c = 12454312,
                                                         Quantity=10, UnitPrice=9, PricebookEntryId=pe.Id, LAN_Quote_Uncalculated__c=true);
        lstOpptyLines.add(ol1);
        insert lstOpptyLines;
        
        clsTriggerHelpers.setTriggerRan('LAN_OpportunityLineItemTriggerHandler.afterUpdate', false);
        
        ol1.LAN_Quote_Uncalculated__c = false;
        update ol1;
        
        for(OpportunityLineItem ql : [SELECT Id, LAN_Quote_Uncalculated__c FROM OpportunityLineItem]) {
        	System.assertNotEquals(ql, null);
        }
        
        Test.stopTest();
    }
}