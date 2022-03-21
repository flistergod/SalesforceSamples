@isTest
private with sharing class LAN_clsAccountTriggerHandlerTest {
    private static Account a {
        get {
            return [SELECT Id, LAN_Bypass_Duplicate_mgmt__c, LAN_VAT_Number__c, LAN_Country_Code__c FROM Account WHERE Name = 'Test' AND RecordType.DeveloperName = 'LAN_Partner'];
        }
    }
    
    private static Opportunity o {
        get {
            return [SELECT Id FROM Opportunity WHERE AccountId = :a.Id LIMIT 1];
        }
    }
    
    private static Contact c {
        get {
            return [SELECT Id FROM Contact WHERE AccountId = :a.Id LIMIT 1];
        }
    }
    
    private static LAN_Partner_Tier__c partnerTierCertified {
        get {
            return [SELECT Id FROM LAN_Partner_Tier__c WHERE LAN_Partner_Type__c = 'Certified'];
        }
    }

    @testSetup
    private static void setupTestData() {   
        
        LAN_Partner_Tier__c partnerTier = new LAN_Partner_Tier__c();
        partnerTier.LAN_Partner_Type__c = 'Registered';
        partnerTier.LAN_Active__c = true;
        partnerTier.Name = 'Registered';
        insert partnerTier;
        
        LAN_Partner_Tier__c partnerTierCertified = new LAN_Partner_Tier__c();
        partnerTierCertified.LAN_Partner_Type__c = 'Certified';
        partnerTierCertified.LAN_Active__c = true;
        partnerTierCertified.Name = 'Certified';
        insert partnerTierCertified;
        
        Account endAccount = new Account(Name='AccountTest', RecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('LAN_Account').getRecordTypeId(),
                                LAN_Account_Discount_Approved__c=true,LAN_Partner_Discount_Approved__c=true);
        
        insert endAccount;
        
        Account a = new Account(Name='Test', RecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('LAN_Partner').getRecordTypeId(),
                                LAN_Enabled_as_partner__c=true,Type='Partner', LAN_ApprovedPartnerDiscount_FirstYear__c=0.3,
                                LAN_VAT_Number__c = '515815454', LAN_Country_Code__c = 'PT',
                                LAN_Partner_Tier__c=partnerTier.Id, LAN_Account_Discount_Approved__c=true,LAN_Partner_Discount_Approved__c=true);
        insert a;
        
    	/*Partner AP2 = new Partner(
		 AccountToId = a.Id,
		 AccountFromId = endAccount.Id,
		 Role = 'Partner User'
		);
		insert AP2;*/
    
    	Contact c = New Contact(Email='test' + math.random() + '@test.com', LastName = 'Test', AccountID = a.id);
        insert c;
        
        Opportunity o = new Opportunity(AccountId=endAccount.Id,LAN_Partner_Account__c = a.Id, RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('LAN_Renewal').getRecordTypeId(), 
                                        StageName = 'Qualify', Name = 'Oppty', CloseDate = System.today().addDays(365), Pricebook2Id = Test.getStandardPricebookId());
        insert o;
        
        SBQQ__Quote__c q = new SBQQ__Quote__c();
        q.SBQQ__Account__c = a.Id;
        q.SBQQ__Opportunity2__c  = o.Id;
        
        insert q;
        
    }

	private static user createPartnerUser(ID cId){
        Profile p = [Select ID, Name from Profile Where Name = 'LAN_Partner_Community_User' limit 1];
    	UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        user u = New User(
            UserName = 'test_' + math.random() + '@test.com',
            FirstName = 'Test-First',
            LastName = 'Test-Last',
            Alias = 'test',
            email = 'test' + math.random() + '@test.com',
            CommunityNickName = string.valueOf(math.random()).substring(0,6),
            ProfileID = p.id,
            TimeZoneSidKey = 'America/New_York', 
            LocaleSidKey = 'en_US', 
            EmailEncodingKey = 'UTF-8', 
            LanguageLocaleKey = 'en_US',
            ContactID = cId
            );

        insert u;
    
        return u;
    
    
    }

    @isTest
    private static void quoteCDC() {
        Test.startTest();

        a.LAN_Bypass_Duplicate_mgmt__c = true;
        update a;

        Test.stopTest();
    }
    
    @isTest
    private static void recalculatePartnerDiscounts() {
        /*Profile profile1 = [Select Id from Profile where name = 'LAN_Partner_Program_Manager'];
       System.debug('What is the profile id ' + profile1);*/
        
        Test.startTest();
        
        User newUser = createPartnerUser(c.id);
            
        clsTriggerHelpers.setTriggerRan('LAN_clsAccountTriggerHandler.afterUpdate', false);
        a.LAN_ApprovedPartnerDiscount_FirstYear__c = 0.1;
        a.LAN_Partner_Tier__c = partnerTierCertified.Id;
        update a;
        //system.runAs(u) {
        //}
        system.debug([select id, LAN_Partner_Tier__c from Account]);
        
        system.debug([select id, Opportunity__c, Status__c from Batch_Queue__c]);
        
        Test.stopTest();
    }

    @isTest
    private static void checkAccountVatNumber() {
        Test.setMock(WebServiceMock.class, new ecEuropaEuTaxudViesServicesMock('SyncValid'));
        Test.startTest();
        
        a.LAN_VAT_Number__c = '5013453334';
        a.LAN_Country_Code__c = 'PT';
        update a;
        
        Test.stopTest();

        List<Account> account = [select Id, LAN_VAT_Number__c, LAN_Check_VAT_Number_Response_JSON__c from Account where Id=:a.Id];
        system.debug(account);
        system.assertNotEquals(account[0].LAN_VAT_Number__c, null);
    }
}