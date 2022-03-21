@IsTest
public class IndicativeQuoteDomainTest { 
    private static Boolean noArgConstructorInvoked = false;
    
	private static Boolean afterInsertInvoked = false;
	private static List<SObject> afterInsertRecords;

    private static final Map<String, RecordTypeInfo> RT_LEADOBJECT = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName();
    private static final Id RT_LEADEV = RT_LEADOBJECT.get('EV').getRecordTypeId();
    
    public static void setNoArgConstructorInvoked(boolean val){
        noArgConstructorInvoked = val;
    }
	//==================================================================================================================
	// Test setup and utility
	//==================================================================================================================

	@TestSetup
	private static void setup() {
		setQuote();
	}

	private static void setQuote() {
        List<Lead> mockLeads = new List<Lead>();
        List<IndicativeQuote__c> mockQuotes = new List<IndicativeQuote__c>();
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

        System.runAs(EvUser){
            System.debug('Create EV Leads');
            mockLeads.add(new Lead( FirstName = 'EvUser', LastName = 'Lead1', Company = 'Centrica EV User', Status = 'New',  Email = 'lead1.ev@mail.com', SWAN_Customer_Segment__c = 'I&C', SWAN_Micro_Business_Selection__c = 'Non_Micro_Business', LeadSource='Advertisement'));
			
            System.debug(mockLeads);
            insert mockLeads;
            List<Lead> newLead = [SELECT Id from Lead WHERE Email = 'lead1.ev@mail.com'];
            Id leadId = newLead[0].Id;
            mockQuotes.add(new IndicativeQuote__c(Lead__c = leadId));
            insert mockQuotes;
        }
	}

	private static List<IndicativeQuote__c> getPersistedQuotes() {
		return [SELECT Id, QuoteAutoNumber__c, UniqueReferenceNumber__c FROM IndicativeQuote__c];
	}
    
    //==================================================================================================================
	// Construction test cases
	//==================================================================================================================

	@IsTest
	private static void shouldIndicateSObjectType() {
		Test.startTest();
		Quotes domainInstance = new Quotes();
		SObjectType type = domainInstance.getSObjectType();
		Test.stopTest();

		System.assertEquals(IndicativeQuote__c.SObjectType, type);
	}

	@IsTest
	private static void shouldInstantiateConcreteClassToHandleTrigger() {
		
		Test.startTest();
		List<IndicativeQuote__c> quotes = [SELECT Id, UniqueReferenceNumber__c FROM IndicativeQuote__c];
        TriggerContext.setAfterInsert(quotes);
		SObjectDomain.handleTrigger(IndicativeQuoteDomainTest.Quotes.class);
		Test.stopTest();

		System.assert(noArgConstructorInvoked);
	}
    
    
    @IsTest
    private static void shouldObtainmentQuoteType(){
        IndicativeQuoteDomain qd = new IndicativeQuoteDomain();
        SObjectType result = qd.getSObjectType();
        System.assertEquals(IndicativeQuote__c.SObjectType, result);
    }
    
    //==================================================================================================================
	// Test Auxiliar Methods
	//==================================================================================================================
    
    @IsTest
    private static void verifyUniqueReferenceNumber(){
		Test.startTest();
        List<IndicativeQuote__c> quotes = [SELECT Id, QuoteAutoNumber__c, UniqueReferenceNumber__c FROM IndicativeQuote__c];
        IndicativeQuoteDomain qd = new IndicativeQuoteDomain();
        Id validId;
        System.debug(quotes);
        System.assertNotEquals(null, quotes[0].UniqueReferenceNumber__c);

		Test.stopTest();
    }
    
    //==================================================================================================================
	// Trigger handler test cases
	//==================================================================================================================

    @IsTest
	private static void shouldInvokeTemplateMethod_afterInsert() {
		List<IndicativeQuote__c> quotes = getPersistedQuotes();
        
        // Mock trigger context and simulate after-insert trigger
		Test.startTest();
		TriggerContext.setAfterInsert(quotes);
        SObjectDomain.handleTrigger(IndicativeQuoteDomainTest.Quotes.class);
        Test.stopTest();

		System.assert(afterInsertInvoked);
	
	}
    
    //==============================================================================================================
	// Inner Types
	//==============================================================================================================

	/**
	 * Concrete SObjectDomain class with minimum template method overrides, used for testing.
	 */
	private class BenignQuotes extends SObjectDomain {
		public override SObjectType getSObjectType() {
			return IndicativeQuote__c.SObjectType;
		}
	}

	/**
	 * Concrete SObjectDomain class used for testing.
	 */
	private class Quotes extends SObjectDomain {

		public Quotes() {
			super();
			setNoArgConstructorInvoked(true);
		}


		public override SObjectType getSObjectType() {
			return IndicativeQuote__c.SObjectType;
		}

		protected override void afterInsert(Map<Id, SObject> records) {
			afterInsertInvoked = true;
			afterInsertRecords = records.values();
		}
    }
}