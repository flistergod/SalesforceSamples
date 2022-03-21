@IsTest
public class SObjectDomainTest {
	private static Boolean noArgConstructorInvoked = false;

	private static Boolean beforeInsertInvoked = false;
	private static List<SObject> beforeInsertRecords;

	private static Boolean afterInsertInvoked = false;
	private static List<SObject> afterInsertRecords;

	private static Boolean beforeUpdateInvoked = false;
	private static List<SObject> beforeUpdateRecords;
	private static List<SObject> beforeUpdateExistingRecords = new List<SObject>();

	private static Boolean afterUpdateInvoked = false;
	private static List<SObject> afterUpdateRecords;
	private static List<SObject> afterUpdateExistingRecords = new List<SObject>();

	private static Boolean beforeDeleteInvoked = false;
	private static List<SObject> beforeDeleteRecords = new List<SObject>();

	private static Boolean afterDeleteInvoked = false;
	private static List<SObject> afterDeleteRecords = new List<SObject>();

	private static Boolean afterUndeleteInvoked = false;
	private static List<SObject> afterUndeleteRecords = new List<SObject>();
    
    public static void setNoArgConstructorInvoked(boolean val){
        noArgConstructorInvoked = val;
    }

	//==================================================================================================================
	// Test setup and utility
	//==================================================================================================================

	@TestSetup
	private static void setup() {
		insert getContacts();
	}

	private static List<Contact> getContacts() {
		return new List<Contact> {
			new Contact( FirstName = 'Bob', LastName = 'Barker', MailingStreet = 'street',MailingPostalCode = 'M4 4TG',
                        MailingCity = 'city',SWAN_Mailing_Building_Name__c='buildingName',SWAN_Mailing_Building_Number__c='buildingNumber'),
			new Contact( FirstName = 'John', LastName = 'Petrucci', MailingStreet = 'street',MailingPostalCode = 'M4 4TG',
                        MailingCity = 'city',SWAN_Mailing_Building_Name__c='buildingName',SWAN_Mailing_Building_Number__c='buildingNumber')
		};
	}

	private static List<Contact> getPersistedContacts() {
		return [SELECT FirstName, LastName FROM Contact];
	}


	//==================================================================================================================
	// Construction test cases
	//==================================================================================================================

	@IsTest
	private static void shouldIndicateSObjectType() {
		Test.startTest();
		Contacts domainInstance = new Contacts();
		SObjectType type = domainInstance.getSObjectType();
		Test.stopTest();

		System.assertEquals(Contact.SObjectType, type);
	}

	@IsTest
	private static void shouldInstantiateConcreteClassToHandleTrigger() {
		List<Contact> contacts = getContacts();

		Test.startTest();
		TriggerContext.setBeforeInsert(contacts);
		SObjectDomain.handleTrigger(SObjectDomainTest.Contacts.class);
		Test.stopTest();

		System.assert(noArgConstructorInvoked);
	}


	//==================================================================================================================
	// Trigger handler test cases
	//==================================================================================================================

	@IsTest
	private static void shouldInvokeTemplateMethod_beforeInsert() {
		List<Contact> contacts = getContacts();

		// Mock trigger context and simulate before-insert trigger
		Test.startTest();
		TriggerContext.setBeforeInsert(contacts);
		SObjectDomain.handleTrigger(SObjectDomainTest.Contacts.class);
		Test.stopTest();

		System.assert(beforeInsertInvoked);
	
	}

	@IsTest
	private static void shouldInvokeTemplateMethod_afterInsert() {
		List<Contact> contacts = getPersistedContacts();

		// Mock trigger context and simulate after-insert trigger
		Test.startTest();
		TriggerContext.setAfterInsert(contacts);
		SObjectDomain.handleTrigger(SObjectDomainTest.Contacts.class);
		Test.stopTest();

		System.assert(afterInsertInvoked);
		
	}

	@IsTest
	private static void shouldInvokeTemplateMethod_beforeUpdate() {
		List<Contact> contacts = getPersistedContacts();
		List<Contact> updatedContacts = getPersistedContacts();
		for (Contact contact : updatedContacts) {
			contact.Description = 'Host of The Price is Right';
		}

		// Mock trigger context and simulate before-update trigger
		Test.startTest();
		TriggerContext.setBeforeUpdate(contacts, updatedContacts);
		SObjectDomain.handleTrigger(SObjectDomainTest.Contacts.class);
		Test.stopTest();

		System.assert(beforeUpdateInvoked);
		
	}

	@IsTest
	private static void shouldInvokeTemplateMethod_afterUpdate() {
		List<Contact> contacts = getPersistedContacts();
		List<Contact> updatedContacts = getPersistedContacts();
		for (Contact contact : updatedContacts) {
			contact.Description = 'Host of The Price is Right';
		}

		// Mock trigger context and simulate after-update trigger
		Test.startTest();
		TriggerContext.setAfterUpdate(contacts, updatedContacts);
		SObjectDomain.handleTrigger(SObjectDomainTest.Contacts.class);
		Test.stopTest();

		System.assert(afterUpdateInvoked);
		
	}

	@IsTest
	private static void shouldInvokeTemplateMethod_beforeDelete() {
		List<Contact> contacts = getPersistedContacts();

		// Mock trigger context and simulate before-delete trigger
		Test.startTest();
		TriggerContext.setBeforeDelete(contacts);
		SObjectDomain.handleTrigger(SObjectDomainTest.Contacts.class);
		Test.stopTest();

		System.assert(beforeDeleteInvoked);
	}

	@IsTest
	private static void shouldInvokeTemplateMethod_afterDelete() {
		List<Contact> contacts = getPersistedContacts();

		// Mock trigger context and simulate after-delete trigger
		Test.startTest();
		TriggerContext.setAfterDelete(contacts);
		SObjectDomain.handleTrigger(SObjectDomainTest.Contacts.class);
		Test.stopTest();

		System.assert(afterDeleteInvoked);
	}

	@IsTest
	private static void shouldInvokeTemplateMethod_afterUndelete() {
		List<Contact> contacts = getPersistedContacts();

		// Mock trigger context and simulate after-undelete trigger
		Test.startTest();
		TriggerContext.setAfterUndelete(contacts);
		SObjectDomain.handleTrigger(SObjectDomainTest.Contacts.class);
		Test.stopTest();

		System.assert(afterUndeleteInvoked);
	}

	
	//==============================================================================================================
	// Inner Types
	//==============================================================================================================

	/**
	 * Concrete SObjectDomain class with minimum template method overrides, used for testing.
	 */
	private class BenignContacts extends SObjectDomain {
		public override SObjectType getSObjectType() {
			return Contact.SObjectType;
		}
	}

	/**
	 * Concrete SObjectDomain class used for testing.
	 */
	private class Contacts extends SObjectDomain {

		public Contacts() {
			super();
			setNoArgConstructorInvoked(true);
		}


		public override SObjectType getSObjectType() {
			return Contact.SObjectType;
		}

		protected override void beforeInsert(List<SObject> records) {
			beforeInsertInvoked = true;
			beforeInsertRecords = records;
		}

		protected override void beforeUpdate(Map<Id, SObject> updatedRecords, Map<Id, SObject> oldRecords) {
			beforeUpdateInvoked = true;
			beforeUpdateRecords = updatedRecords.values();
			beforeUpdateExistingRecords = oldRecords.values();
		}

		protected override void beforeDelete(Map<Id, SObject> records) {
			beforeDeleteInvoked = true;
			beforeDeleteRecords = records.values();
		}

		protected override void afterInsert(Map<Id, SObject> records) {
			afterInsertInvoked = true;
			afterInsertRecords = records.values();
		}

		protected override void afterUpdate(Map<Id, SObject> updatedRecords, Map<Id, SObject> oldRecords) {
			afterUpdateInvoked = true;
			afterUpdateRecords = updatedRecords.values();
			afterUpdateExistingRecords = oldRecords.values();
		}

		protected override void afterDelete(Map<Id, SObject> records) {
			afterDeleteInvoked = true;
			afterDeleteRecords = records.values();
		}

		protected override void afterUndelete(Map<Id, SObject> records) {
			afterUndeleteInvoked = true;
			afterUndeleteRecords = records.values();
		}
	}
}