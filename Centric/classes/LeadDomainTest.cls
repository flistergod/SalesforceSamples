@IsTest
public class LeadDomainTest {
    private static Boolean noArgConstructorInvoked = false;
    
	private static Boolean afterInsertInvoked = false;
	private static List<SObject> afterInsertRecords;

    private static final Map<String, RecordTypeInfo> RT_LEADOBJECT = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName();
    private static final Id RT_LEADEV = RT_LEADOBJECT.get('EV').getRecordTypeId();
    private static final Id RT_LEAD_MASTER = RT_LEADOBJECT.get('Master').getRecordTypeId();
    
    public static void setNoArgConstructorInvoked(boolean val){
        noArgConstructorInvoked = val;
    }
	//==================================================================================================================
	// Test setup and utility
	//==================================================================================================================

	@TestSetup
	private static void setup() {
		setLeads();
	}

	private static void setLeads() {
        List<Lead> mockLeads = new List<Lead>();
        Profile pEv = [SELECT Id, Name FROM Profile WHERE Name = 'Centrica EV User'];
        Profile pMaster = [SELECT Id, Name FROM Profile WHERE Name = 'Centrica I&C User'];
        String uniqueEvUserName = 'evuser'+DateTime.now().getTime()+'@mock.com';
        String uniqueMasterUserName = 'masteruser'+DateTime.now().getTime()+'@mock.com';
        User EvUser = new User(
        	Alias = 'EvUser',
            Email='ev.user@testorg.com',
            EmailEncodingKey='UTF-8',
            LastName='Testing',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            ProfileId = pEv.Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName=uniqueEvUserName
        );
        User MasterUser = new User(
        	Alias = 'MUser',
            Email='master.user@testorg.com',
            EmailEncodingKey='UTF-8',
            LastName='Testing',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            ProfileId = pMaster.Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName=uniqueMasterUserName
        );
        System.debug(MasterUser);
        System.runAs(EvUser){
            System.debug('Create EV Leads');
            mockLeads.add(new Lead( FirstName = 'EvUser', LastName = 'Lead1',RecordTypeId = RT_LEADEV, Company = 'Centrica EV User', Status = 'New',  Email = 'lead1.ev@mail.com',SWAN_Customer_Segment__c = 'I&C', SWAN_Micro_Business_Selection__c = 'Non_Micro_Business', LeadSource='Advertisement'));
            mockLeads.add(new Lead( FirstName = 'EvUser', LastName = 'Lead2',RecordTypeId = RT_LEADEV, Company = 'Centrica EV User', Status = 'Working', Email = 'lead2.ev@mail.com', SWAN_Customer_Segment__c = 'I&C', SWAN_Micro_Business_Selection__c = 'Non_Micro_Business', LeadSource='Advertisement'));
            mockLeads.add(new Lead( FirstName = 'EvUser', LastName = 'Lead3',RecordTypeId = RT_LEADEV, Company = 'Centrica EV User', Status = 'Qualified', Email = 'lead3.ev@mail.com', SWAN_Customer_Segment__c = 'I&C', SWAN_Micro_Business_Selection__c = 'Non_Micro_Business', LeadSource='Advertisement'));
            mockLeads.add(new Lead( FirstName = 'EvUser', LastName = 'Lead4',RecordTypeId = RT_LEADEV, Company = 'Centrica EV User', Status = 'Unqualified', StatusReason__c='Too Expensive', Email = 'lead4.ev@mail.com',SWAN_Customer_Segment__c = 'I&C', SWAN_Micro_Business_Selection__c = 'Non_Micro_Business', LeadSource='Advertisement'));
            System.debug(mockLeads);
            insert mockLeads;
        }
        mockLeads.clear();
        System.runAs(MasterUser){
            System.debug('Create Master Leads');
            mockLeads.add(new Lead( FirstName = 'MasterUser', LastName = 'Lead1', Company = 'Centrica I&C User', Status = 'New', Email = 'lead1.master@mail.com', SWAN_Customer_Segment__c = 'I&C', SWAN_Micro_Business_Selection__c = 'Non_Micro_Business', LeadSource='Advertisement'));
            mockLeads.add(new Lead( FirstName = 'MasterUser', LastName = 'Lead2', Company = 'Centrica I&C User', Status = 'Working', Email = 'lead2.master@mail.com', SWAN_Customer_Segment__c = 'I&C', SWAN_Micro_Business_Selection__c = 'Non_Micro_Business', LeadSource='Advertisement'));
            mockLeads.add(new Lead( FirstName = 'MasterUser', LastName = 'Lead3', Company = 'Centrica I&C User', Status = 'Qualified', Email = 'lead3.master@mail.com', SWAN_Customer_Segment__c = 'I&C', SWAN_Micro_Business_Selection__c = 'Non_Micro_Business', LeadSource='Advertisement'));
            mockLeads.add(new Lead( FirstName = 'MasterUser', LastName = 'Lead4', Company = 'Centrica I&C User', Status = 'Unqualified', StatusReason__c='Too Expensive', Email = 'lead4.master@mail.com', SWAN_Customer_Segment__c = 'I&C', SWAN_Micro_Business_Selection__c = 'Non_Micro_Business', LeadSource='Advertisement'));
            System.debug(mockLeads);
            insert mockLeads;
        }
	}

	private static List<Lead> getPersistedLeads() {
		return [SELECT LastName, Company, Status FROM Lead];
	}
    
    //==================================================================================================================
	// Construction test cases
	//==================================================================================================================

	@IsTest
	private static void shouldIndicateSObjectType() {
		Test.startTest();
		Leads domainInstance = new Leads();
		SObjectType type = domainInstance.getSObjectType();
		Test.stopTest();

		System.assertEquals(Lead.SObjectType, type);
	}

	@IsTest
	private static void shouldInstantiateConcreteClassToHandleTrigger() {
		
		Test.startTest();
		List<Lead> leads = [SELECT Id, Name, Company, Status, Email, RecordTypeId FROM Lead];
        TriggerContext.setAfterInsert(leads);
		SObjectDomain.handleTrigger(LeadDomainTest.Leads.class);
		Test.stopTest();

		System.assert(noArgConstructorInvoked);
	}
    
    
    @IsTest
    private static void shouldObtainmentLeadType(){
        LeadDomain ld = new LeadDomain();
        SObjectType result = ld.getSObjectType();
        System.assertEquals(Lead.SObjectType, result);
    }
    
    //==================================================================================================================
	// Test Auxiliar Methods
	//==================================================================================================================
    
    @IsTest
    private static void testExistingValidLead(){
		Test.startTest();
        List<Lead> leads = [SELECT Id, Name, Company, Status, Email, RecordTypeId FROM Lead];
        LeadDomain ld = new LeadDomain();
        Id validId;
        
        // EV User Leads
        validId = ld.existingLead('lead1.ev@mail.com');
		System.assertNotEquals(null, validId);
        validId = ld.existingLead('lead2.ev@mail.com');
		System.assertNotEquals(null, validId);
        validId = ld.existingLead('lead3.ev@mail.com');
		System.assertEquals(null, validId,'Lead EV 3 is Qualified');
        validId = ld.existingLead('lead4.ev@mail.com');
        System.assertEquals(null, validId,'Lead EV 4 is Unqualified');
        
        // Unexisting Lead 
        validId = ld.existingLead('lead5@mail.com');
        System.assertEquals(null, validId,'Lead 5 does not exist');
        
        // Master User Leads
        validId = ld.existingLead('lead1.master@mail.com');
		System.assertEquals(null, validId,'Lead 1 has Status=New but RecordTypeId=Master');
        validId = ld.existingLead('lead2.master@mail.com');
		System.assertEquals(null, validId,'Lead 2 has Status=Working but RecordTypeId=Master');
        validId = ld.existingLead('lead3.master@mail.com');
		System.assertEquals(null, validId,'Lead 3 has Status=Qualified and RecordTypeId=Master');
        validId = ld.existingLead('lead4.master@mail.com');
        System.assertEquals(null, validId,'Lead 4 has Status=Unqualified and RecordTypeId=Master');
		Test.stopTest();
    }
    
    //==================================================================================================================
	// Trigger handler test cases
	//==================================================================================================================

    @IsTest
	private static void shouldInvokeTemplateMethod_afterInsert() {
		List<Lead> leads = getPersistedLeads();
        
        // Mock trigger context and simulate after-insert trigger
		Test.startTest();
		TriggerContext.setAfterInsert(leads);
        SObjectDomain.handleTrigger(LeadDomainTest.Leads.class);
        Test.stopTest();

		System.assert(afterInsertInvoked);
	
	}
    
    //==============================================================================================================
	// Inner Types
	//==============================================================================================================

	/**
	 * Concrete SObjectDomain class with minimum template method overrides, used for testing.
	 */
	private class BenignLeads extends SObjectDomain {
		public override SObjectType getSObjectType() {
			return Lead.SObjectType;
		}
	}

	/**
	 * Concrete SObjectDomain class used for testing.
	 */
	private class Leads extends SObjectDomain {

		public Leads() {
			super();
			setNoArgConstructorInvoked(true);
		}


		public override SObjectType getSObjectType() {
			return Lead.SObjectType;
		}

		protected override void afterInsert(Map<Id, SObject> records) {
			afterInsertInvoked = true;
			afterInsertRecords = records.values();
		}
    }
}