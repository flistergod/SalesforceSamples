@isTest
public class LAN_AutomateQuoteLinkDocActionTest {
    
    private static Account pAccount {
        get {
            return [SELECT Id FROM Account WHERE Name = 'Partner Test' AND RecordType.DeveloperName = 'LAN_Partner'];
        }
    }
    
    private static Opportunity pOppty {
        get {
            return [SELECT Id FROM Opportunity WHERE LAN_Partner_Account__c = :pAccount.Id LIMIT 1];
        }
    }

    @testSetup
    private static void setupTestData() {
        LAN_Partner_Tier__c partnerTierCertified = new LAN_Partner_Tier__c();
        partnerTierCertified.LAN_Partner_Type__c = 'Certified';
        partnerTierCertified.LAN_Active__c = true;
        partnerTierCertified.Name = 'Certified';
        insert partnerTierCertified;

        Account a = new Account(Name='Test', RecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('LAN_Account').getRecordTypeId());
        insert a;

        Account partnerAccount = new Account(Name='Partner Test',RecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('LAN_Partner').getRecordTypeId(),
                                LAN_Enabled_as_partner__c=true,Type='Partner',
                                LAN_Partner_Tier__c=partnerTierCertified.Id, LAN_Account_Discount_Approved__c=true,LAN_Partner_Discount_Approved__c=true);
        insert partnerAccount;
        
        Opportunity partnerOppty = new Opportunity(AccountId = a.Id, LAN_Partner_Account__c = partnerAccount.Id, RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('LAN_Renewal').getRecordTypeId(), 
                                       StageName = 'Qualify', Name = 'Oppty3', CloseDate = System.today().addDays(30), Pricebook2Id = Test.getStandardPricebookId(), 
                                        LAN_Cleverbridge_SubscriptionID__c='testSubscriptionId', LAN_Original_Reference_Number__c='46435354');
        insert partnerOppty;

        SBQQ__QuoteTemplate__c   template= new SBQQ__QuoteTemplate__c(Name='No Discount', SBQQ__Default__c=true);
        insert template;
    }

    @isTest
    private static void testPartnerQtCLinkGeneration() {

        SBQQ__Quote__c q = new SBQQ__Quote__c();
        q.SBQQ__Account__c = pAccount.Id;
        q.SBQQ__Opportunity2__c  = pOppty.Id;
        q.SBQQ__Status__c = 'Draft';
        q.SBQQ__StartDate__c = system.today();
        
        insert q;

        Test.setMock(HttpCalloutMock.class, new LAN_ctrlQuoteToCartMock(LAN_ctrlQuoteToCartMock.MOCK_TYPE.SUCCESS));
        Test.startTest();

        
        QuoteProposalModel context = new QuoteProposalModel(q.Id);
        context.name = 'testquote';
        context.language = 'EN';
        context.outputFormat = 'PDF';
        context.paperSize = 'A4';

        q.SBQQ__LastCalculatedOn__c = system.today();

        update q;

        Test.stopTest();
        
        List<SBQQ__Quote__c> approvedQuotes = [select Id, SBQQ__Status__c, LAN_Quote_to_Cart__c from SBQQ__Quote__c where Id =:q.Id];
        system.debug(approvedQuotes);
        System.assertNotEquals(approvedQuotes[0], null);
    }
}