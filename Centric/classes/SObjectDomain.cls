public abstract class SObjectDomain {
    //==================================================================================================================
	// Trigger handlers
	//==================================================================================================================

	/**
	 * Processes a trigger context for a given domain.
	 * @param domainClass A concrete SObjectDomain class associated with the sObject for which a trigger event has fired
	 */
	public static void handleTrigger(Type domainClass) {
		TriggerContext triggerContext = TriggerContext.getTriggerContext(getClassName());

		// Verify invoked from trigger context
		if (!triggerContext.isExecuting) {
			throw new TriggerContextException('Trigger handler invoked outside trigger context - SObjectDomain trigger handler should only be invoked from triggers');
		}

		// Ignore if no records were processed (can result from flow-based processes)
		if ((triggerContext.newList == null || triggerContext.newList.size() < 1) &&
			(triggerContext.oldList == null || triggerContext.oldList.size() < 1)) {
			return;
		}

		// Create empty domain instance
		SObjectDomain domain;
		try {
			domain = (SObjectDomain) domainClass.newInstance();
		} catch (TypeException e) {
			Exception wrappedException = new InvalidDomainClassException('Invalid domain class - expected subclass of SObjectDomain, found: ' + domainClass);
			wrappedException.initCause(e);
			throw wrappedException;
		}


		// Depending on the specific trigger context,
		// inject the appropriate records and invoke proper handler method
		if (triggerContext.isBefore) {
			if (triggerContext.isInsert) {
				domain.handleBeforeInsert(triggerContext.newList);
			} else if (triggerContext.isUpdate) {
				domain.handleBeforeUpdate(triggerContext.newMap, triggerContext.oldMap);
			} else if (triggerContext.isDelete) {
				domain.handleBeforeDelete(triggerContext.oldMap);
			}
		} else {
			if (triggerContext.isInsert) {
				domain.handleAfterInsert(triggerContext.newMap);
			} else if (triggerContext.isUpdate) {
				domain.handleAfterUpdate(triggerContext.newMap, triggerContext.oldMap);
			} else if (triggerContext.isDelete) {
				domain.handleAfterDelete(triggerContext.oldMap);
			} else if (triggerContext.isUndelete) {
				domain.handleAfterUndelete(triggerContext.newMap);
			}
		}
	}

    /**
	 * Handles a before-insert trigger event.
	 * @param records A list of SObject records about to be inserted
	 */
	private void handleBeforeInsert(List<SObject> records) {
		for (SObject record : records) {
		}
		beforeInsert(records);
	}

	/**
	 * Handles a before-update trigger event.
	 * @param updatedRecords A map of the records to be updated, keyed by ID, in their updated state
	 * @param oldRecords A map of the records to be updated, keyed by ID, in their current state
	 */
	private void handleBeforeUpdate(Map<Id, SObject> updatedRecords, Map<Id, SObject> oldRecords) {
		beforeUpdate(updatedRecords, oldRecords);
	}

	/**
	 * Handles a before-delete trigger event.
	 * @param records A map of the records to be deleted, keyed by ID
	 */
	private void handleBeforeDelete(Map<Id, SObject> records) {
		beforeDelete(records);
	}

	/**
	 * Handles an after-insert trigger event.
	 * @param records A map of the records that were just inserted, keyed by ID
	 */
	private void handleAfterInsert(Map<Id, SObject> records) {
		//assertCreatable();
		afterInsert(records);
	}

	/**
	 * Handles an after-update trigger event.
	 * @param updatedRecords A map of the updated records, keyed by ID, in their updated state
	 * @param oldRecords A map of the updated records, keyed by ID, in their previous state
	 */
	private void handleAfterUpdate(Map<Id, SObject> updatedRecords, Map<Id, SObject> oldRecords) {
		//assertUpdateable();
		afterUpdate(updatedRecords, oldRecords);
	}

	/**
	 * Handles an after-delete trigger event.
	 * @param records A map of the deleted records, keyed by ID
	 */
	private void handleAfterDelete(Map<Id, SObject> records) {
		assertDeletable();
		afterDelete(records);
	}

	/**
	 * Handles an after-undelete trigger event.
	 * @param records A map of the undeleted records, keyed by ID
	 */
	private void handleAfterUndelete(Map<Id, SObject> records) {
		assertUndeletable();
		afterUndelete(records);
	}


	//==================================================================================================================
	// Private utility
	//==================================================================================================================

	/**
	 * Returns the sObject describe result for the domain sObject records.
	 * @return sObject describe result for the domain records
	 */
	private DescribeSObjectResult getDescribe() {
		return getSObjectType().getDescribe();
	}

	/**
	 * Verifies that the records are creatable in the current context, throwing an exception if not.
	 */
	/*private void assertCreatable() {
		if (!getDescribe().isCreateable()) {
			throw new PermissionException('Permission to create ' + getDescribe().getName() + ' denied');
		}
	}*/

	/**
	 * Verifies that the records are updateable in the current context, throwing an exception if not.
	 */
	/*private void assertUpdateable() {
		if (!getDescribe().isUpdateable()) {
			throw new PermissionException('Permission to update ' + getDescribe().getName() + ' denied');
		}
	}*/

	/**
	 * Verifies that the records are deletable in the current context, throwing an exception if not.
	 */
	private void assertDeletable() {
		if (!getDescribe().isDeletable()) {
			throw new PermissionException('Permission to delete ' + getDescribe().getName() + ' denied');
		}
	}

	/**
	 * Verifies that the records are undeletable in the current context, throwing an exception if not.
	 */
	private void assertUndeletable() {
		if (!getDescribe().isUndeletable()) {
			throw new PermissionException('Permission to undelete ' + getDescribe().getName() + ' denied');
		}
	}


	//==================================================================================================================
	// Abstract / template methods
	//==================================================================================================================

	/**
	 * Should be implemented by concrete domain classes to identify the sObject type managed.
	 * @return An sObject type, indicating the type of sObjects represented and managed by the domain class
	 */
	public abstract SObjectType getSObjectType();

	/**
	 * Can be overridden to perform processing during the before-insert phase.
	 * @param records A list of SObject records about to be inserted
	 */
	protected virtual void beforeInsert(List<SObject> records) {}

	/**
	 * Can be overridden to perform processing during the before-update phase.
	 * @param updatedRecords A map of the records to be updated, keyed by ID, in their updated state
	 * @param oldRecords A map of the records to be updated, keyed by ID, in their current state
	 */
	protected virtual void beforeUpdate(Map<Id, SObject> updatedRecords, Map<Id, SObject> oldRecords) {}

	/**
	 * Can be overridden to perform processing during the before-delete phase.
	 * @param records A map of the records to be deleted, keyed by ID
	 */
	protected virtual void beforeDelete(Map<Id, SObject> records) {}

	/**
	 * Can be overridden to perform processing during the after-insert phase.
	 * @param records A map of the records that were just inserted, keyed by ID
	 */
	protected virtual void afterInsert(Map<Id, SObject> records) {}

	/**
	 * Can be overridden to perform processing during the after-update phase.
	 * @param updatedRecords A map of the updated records, keyed by ID, in their updated state
	 * @param oldRecords A map of the updated records, keyed by ID, in their previous state
	 */
	protected virtual void afterUpdate(Map<Id, SObject> updatedRecords, Map<Id, SObject> oldRecords) {}

	/**
	 * Can be overridden to perform processing during the after-delete phase.
	 * @param records A map of the deleted records, keyed by ID
	 */
	protected virtual void afterDelete(Map<Id, SObject> records) {}

	/**
	 * Can be overridden to perform processing during the after-undelete phase.
	 * @param records A map of the undeleted records, keyed by ID
	 */
	protected virtual void afterUndelete(Map<Id, SObject> records) {}


	//==================================================================================================================
	// Exceptions
	//==================================================================================================================

	// Thrown when an action performed is not permitted
	public class PermissionException extends Exception {}

	// Thrown when handleTrigger() is invoked with an invalid class type
	public class InvalidDomainClassException extends Exception {}

	// Thrown when handleTrigger() is invoked from outside of a trigger
	public class TriggerContextException extends Exception {}
   
    //==================================================================================================================
	// Utils
	//==================================================================================================================
	
    /**
    * Get the name of the calling class.
    * @return The name of the class that invoked this method
    */
    public static String getClassName() {
        return new MathException()
            .getStackTraceString()
            .substringAfter('\n')
            .substringAfter('Class.')
            .substringBefore(':')
            .substringBeforeLast('.');
    }    
}