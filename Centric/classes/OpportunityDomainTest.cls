@IsTest
public class OpportunityDomainTest { 
    private static Boolean noArgConstructorInvoked = false;
    
	private static Boolean afterInsertInvoked = false;
	private static List<SObject> afterInsertRecords;

    private static final Map<String, RecordTypeInfo> RT_OPPORTUNITYOBJECT = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName();
    private static final Id RT_OPPORTUNITYEV = RT_OPPORTUNITYOBJECT.get('EV_ACQUISITION').getRecordTypeId();
    
    public static void setNoArgConstructorInvoked(boolean val){
        noArgConstructorInvoked = val;
    }
	//==================================================================================================================
	// Test setup and utility
	//==================================================================================================================

	@TestSetup
	private static void setup() {
		setOpportunities();
	}

	private static void setOpportunities() {
        List<Opportunity> mockOpportunities = new List<Opportunity>();
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
        	Alias = 'MsUser',
            Email='master.user@testorg.com',
            EmailEncodingKey='UTF-8',
            LastName='Testing',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            ProfileId = pMaster.Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName=uniqueMasterUserName
        );
        Id PriceListId = CreatePriceList();
		Date closeDate = Date.newInstance(2022,1,1);
        System.debug(PriceListId);
        System.runAs(EvUser){
            System.debug('Create EV Opportunity');
            mockOpportunities.add(new Opportunity(Name = 'EV Opportunity 1', vlocity_cmt__PriceListId__c = PriceListId, StageName = 'Proposal', CloseDate = closeDate, RecordTypeId = RT_OPPORTUNITYEV));
            System.debug('mockOpportunities ' + mockOpportunities);
            insert mockOpportunities;
        }
	}

	private static List<Opportunity> getPersistedOpportunities() {
		return [SELECT Id,OpportunityAutoNumber__c, UniqueReferenceNumber__c, RecordTypeId FROM Opportunity];
	}
    
    private static Id CreatePriceList(){
        vlocity_cmt__PriceList__c mockPriceList = new vlocity_cmt__PriceList__c(Name = 'Mock', vlocity_cmt__Code__c	 = '666');
        insert mockPriceList;
        List<vlocity_cmt__PriceList__c> PriceList = [SELECT Id, Name FROM vlocity_cmt__PriceList__c WHERE Name = 'Mock'];
        System.debug(PriceList);
		return PriceList[0].Id;
    }
    
    //==================================================================================================================
	// Construction test cases
	//==================================================================================================================

	@IsTest
	private static void shouldIndicateSObjectType() {
		Test.startTest();
		Opportunity domainInstance = new Opportunity();
		SObjectType type = domainInstance.getSObjectType();
		Test.stopTest();

		System.assertEquals(Opportunity.SObjectType, type);
	}

	@IsTest
	private static void shouldInstantiateConcreteClassToHandleTrigger() {
		
		Test.startTest();
		List<Opportunity> Opportunities = [SELECT Id, Name, UniqueReferenceNumber__c FROM Opportunity];
        TriggerContext.setAfterInsert(Opportunities);
		SObjectDomain.handleTrigger(OpportunityDomainTest.Opportunities.class);
		Test.stopTest();

		System.assert(noArgConstructorInvoked);
	}
    
    
    @IsTest
    private static void shouldObtainmentOpportunityType(){
        OpportunityDomain od = new OpportunityDomain();
        SObjectType result = od.getSObjectType();
        System.assertEquals(Opportunity.SObjectType, result);
    }
    
    //==================================================================================================================
	// Test Auxiliar Methods
	//==================================================================================================================
    
    @IsTest
    private static void verifyUniqueReferenceNumber(){
		Test.startTest();
        List<Opportunity> persistedOpportunities = getPersistedOpportunities();
        System.debug(persistedOpportunities);
        
        List<Opportunity> opportunitiesEv = [SELECT Id, Name, RecordTypeId, UniqueReferenceNumber__c FROM Opportunity WHERE Name = 'EV Opportunity 1'];
        System.assertNotEquals(null, opportunitiesEv[0].UniqueReferenceNumber__c);

		Test.stopTest();
    }
    
    //==================================================================================================================
	// Trigger handler test cases
	//==================================================================================================================

    @IsTest
	private static void shouldInvokeTemplateMethod_afterInsert() {
		List<Opportunity> opportunities = getPersistedOpportunities();
        
        // Mock trigger context and simulate after-insert trigger
		Test.startTest();
		TriggerContext.setAfterInsert(opportunities);
        SObjectDomain.handleTrigger(OpportunityDomainTest.Opportunities.class);
        Test.stopTest();

		System.assert(afterInsertInvoked);
	
	}
    
    //==============================================================================================================
	// Inner Types
	//==============================================================================================================

	/**
	 * Concrete SObjectDomain class with minimum template method overrides, used for testing.
	 */
	private class BenignOpportunities extends SObjectDomain {
		public override SObjectType getSObjectType() {
			return Opportunity.SObjectType;
		}
	}

	/**
	 * Concrete SObjectDomain class used for testing.
	 */
	private class Opportunities extends SObjectDomain {

		public Opportunities() {
			super();
			setNoArgConstructorInvoked(true);
		}


		public override SObjectType getSObjectType() {
			return Opportunity.SObjectType;
		}

		protected override void afterInsert(Map<Id, SObject> records) {
			afterInsertInvoked = true;
			afterInsertRecords = records.values();
		}
    }
}