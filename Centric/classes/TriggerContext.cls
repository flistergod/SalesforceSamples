/**
 * Wraps static trigger context variables in order to provide a mockable interface.
 *
 * By utilizing this class rather than built-in variables for trigger context, state can be mocked within unit tests.
 * This class also automatically avoids trigger recursion by filtering the records returned.
 *
 * Methods used to mock trigger context are only accessible from test context, as such mocking is only intended for
 * testing.
 */
public class TriggerContext {

	// Trigger context fields
	public Boolean isExecuting { get; private set; }
	public TriggerOperation operationType { get; private set; }
	public Boolean isInsert { get; private set; }
	public Boolean isUpdate { get; private set; }
	public Boolean isDelete { get; private set; }
	public Boolean isUndelete { get; private set; }
	public Boolean isBefore { get; private set; }
	public Boolean isAfter { get; private set; }
	public List<SObject> newList { get; private set; }
	public Map<Id, SObject> newMap { get; private set; }
	public List<SObject> oldList { get; private set; }
	public Map<Id, SObject> oldMap { get; private set; }
	public Integer size { get; private set; }


	// Mock trigger context
	private static TriggerContext mockTriggerContext = null;

	// Lists of records processed in the transaction, used to avoid trigger recursion
	private static Map<String, Set<Id>> processedRecords = new Map<String, Set<Id>>();


	/**
	 * Private constructor keeps TriggerContext instances from be create explicitly
	 */
	private TriggerContext(
		Boolean isExecuting,
		TriggerOperation operationType,
		Boolean isInsert,
		Boolean isUpdate,
		Boolean isDelete,
		Boolean isUndelete,
		Boolean isBefore,
		Boolean isAfter,
		List<SObject> newList,
		Map<Id, SObject> newMap,
		List<SObject> oldList,
		Map<Id, SObject> oldMap,
		Integer size
	) {
		this.isExecuting = isExecuting;
		this.operationType = operationType;
		this.isInsert = isInsert;
		this.isUpdate = isUpdate;
		this.isDelete = isDelete;
		this.isUndelete = isUndelete;
		this.isBefore = isBefore;
		this.isAfter = isAfter;
		this.newList = newList;
		this.newMap = newMap;
		this.oldList = oldList;
		this.oldMap = oldMap;
		this.size = size;
	}


	/**
	 * Retrieves the current trigger context.
	 * @return A mock trigger context if one has been set; the actual trigger context otherwise
	 */
	public static TriggerContext getTriggerContext() {
		// Return mocked trigger context if set
		if (mockTriggerContext != null) {
			return mockTriggerContext;
		}

		// Wrap the actual trigger context and return
		return new TriggerContext(
			Trigger.isExecuting,
			Trigger.operationType,
			Trigger.isInsert,
			Trigger.isUpdate,
			Trigger.isDelete,
			Trigger.isUndelete,
			Trigger.isBefore,
			Trigger.isAfter,
			Trigger.new,
			Trigger.newMap,
			Trigger.old,
			Trigger.oldMap,
			Trigger.size
		);
	}

	/**
	 * Retrieves the current trigger context. If a recursion filter is specified, all records processed by the trigger
	 * will be recorded and filtered out in subsequent trigger executions to avoid recursion.
	 * @param recursionFilterKey A unique string to identify the calling context - likely the calling class name
	 * @return A mock trigger context if one has been set; the actual trigger context otherwise
	 */
	public static TriggerContext getTriggerContext(String recursionFilterKey) {
		TriggerContext triggerContext = getTriggerContext();

		String recursionFilter = recursionFilterKey + '-' + triggerContext.operationType;

		// Construct filtered sets of records
		List<SObject> filteredNewList = filterProcessedRecords(triggerContext.newList, recursionFilter);
		Map<Id, SObject> filteredNewMap = filterProcessedRecords(triggerContext.newMap, recursionFilter);
		List<SObject> filteredOldList = filterProcessedRecords(triggerContext.oldList, recursionFilter);
		Map<Id, SObject> filteredOldMap = filterProcessedRecords(triggerContext.oldMap, recursionFilter);

		// Register processed records
		// These records won't be included in subsequent trigger executions
		// NOTE: If invoked outside of a trigger, all static variables will be null, so check this before processing
		Set<Id> recordIds = new Set<Id>();
		if (triggerContext.newMap != null) {
			recordIds.addAll(triggerContext.newMap.keySet());
		}
		if (triggerContext.oldMap != null) {
			recordIds.addAll(triggerContext.oldMap.keySet());
		}
		for (Id recordId : recordIds) {
			registerProcessedRecord(recordId, recursionFilter);
		}

		// Swap records for filtered sets
		triggerContext.newList = filteredNewList;
		triggerContext.newMap = filteredNewMap;
		triggerContext.oldList = filteredOldList;
		triggerContext.oldMap = filteredOldMap;

		return triggerContext;
	}

	/**
	 * Registers a record as processed in the current transaction and trigger context. In doing so, this record will be
	 * excluded from future trigger executions within the same transaction. The recursion filter key is used to identify
	 * the specific trigger in which the record was processed - the record will only be excluded from triggers
	 * identified with the same key.
	 * @param recordId ID of the record to exclude from future processing
	 * @param recursionFilter Recursion filter identifying the trigger event for which to exclude the record
	 */
	private static void registerProcessedRecord(Id recordId, String recursionFilter) {
		Set<Id> processedRecordIds = getProcessedRecordIds(recursionFilter);
		processedRecordIds.add(recordId);
	}

	/**
	 * Returns the IDs of each record registered as processed, using a given filter key.
	 * @param recursionFilter Recursion filter identifying the trigger event for which the records were processed
	 * @return Set of IDs of each record processed by a trigger using the given filter key
	 */
	private static Set<Id> getProcessedRecordIds(String recursionFilter) {
		if (!processedRecords.containsKey(recursionFilter)) {
			processedRecords.put(recursionFilter, new Set<Id>());
		}
		return processedRecords.get(recursionFilter);
	}

	/**
	 * Filters a given list of sObjects to it contains only records that have NOT been processed in the current
	 * transaction.
	 * @param records List of sObject records
	 * @param recursionFilter A unique string to identifying the calling context
	 * @return A filtered list of sObject records, excluding any records already processed in the current transaction
	 */
	private static List<SObject> filterProcessedRecords(List<SObject> records, String recursionFilter) {
		// Short-circuit if null
		if (records == null) {
			return records;
		}

		// Get set of processed record IDs
		Set<Id> processedRecordIds = getProcessedRecordIds(recursionFilter);

		// Create new set of records, excluding those already processed
		List<SObject> filteredRecords = records.clone(); // Clone to ensure consistent SObject list type
		filteredRecords.clear();
		for (SObject record : records) {
			if (!processedRecordIds.contains(record.Id)) {
				filteredRecords.add(record);
			}
		}
		return filteredRecords;
	}

	/**
	 * Filters a given map of sObjects to it contains only records that have NOT been processed in the current
	 * transaction.
	 * @param records Map of sObject records
	 * @param recursionFilter A unique string to identifying the calling context
	 * @return A filtered map of sObject records, excluding any records already processed in the current transaction
	 */
	private static Map<Id, SObject> filterProcessedRecords(Map<Id, SObject> records, String recursionFilter) {
		// Short-circuit if null
		if (records == null) {
			return records;
		}

		// Get set of processed record IDs
		Set<Id> processedRecordIds = getProcessedRecordIds(recursionFilter);

		Map<Id, SObject> filteredRecords = records.clone(); // Clone to ensure consistent SObject map type
		for (Id recordId : records.keySet()) {
			if (processedRecordIds.contains(recordId)) {
				filteredRecords.remove(recordId);
			}
		}
		return filteredRecords;
	}


	//==================================================================================================================
	// Mocking
	//==================================================================================================================

	/**
	 * Mocks the trigger context to represent a before-insert trigger.
	 * @param newRecords List of sObject records being inserted
	 */
	@TestVisible
	private static void setBeforeInsert(List<SObject> newRecords) {
		mockTriggerContext = new TriggerContext(
			true,
			TriggerOperation.BEFORE_INSERT,
			true,
			false,
			false,
			false,
			true,
			false,
			newRecords,
			null,
			null,
			null,
			newRecords.size()
		);
	}

	/**
	 * Mocks the trigger context to represent an after-insert trigger.
	 * @param newRecords List of sObject records being inserted
	 */
	@TestVisible
	private static void setAfterInsert(List<SObject> newRecords) {
		mockTriggerContext = new TriggerContext(
			true,
			TriggerOperation.AFTER_INSERT,
			true,
			false,
			false,
			false,
			false,
			true,
			newRecords,
			mapById(newRecords),
			null,
			null,
			newRecords.size()
		);
	}

	/**
	 * Mocks the trigger context to represent a before-update trigger.
	 * @param oldRecords List of sObject records being updated, in their original state
	 * @param newRecords List of sObject records being updated, in their updated state
	 */
	@TestVisible
	private static void setBeforeUpdate(List<SObject> oldRecords, List<SObject> newRecords) {
		mockTriggerContext = new TriggerContext(
			true,
			TriggerOperation.BEFORE_UPDATE,
			false,
			true,
			false,
			false,
			true,
			false,
			newRecords,
			mapById(newRecords),
			oldRecords,
			mapById(oldRecords),
			newRecords.size() + oldRecords.size()
		);
	}

	/**
	 * Mocks the trigger context to represent an after-update trigger.
	 * @param oldRecords List of sObject records being updated, in their original state
	 * @param newRecords List of sObject records being updated, in their updated state
	 */
	@TestVisible
	private static void setAfterUpdate(List<SObject> oldRecords, List<SObject> newRecords) {
		mockTriggerContext = new TriggerContext(
			true,
			TriggerOperation.AFTER_UPDATE,
			false,
			true,
			false,
			false,
			false,
			true,
			newRecords,
			mapById(newRecords),
			oldRecords,
			mapById(oldRecords),
			newRecords.size() + oldRecords.size()
		);
	}

	/**
	 * Mocks the trigger context to represent a before-delete trigger.
	 * @param oldRecords List of sObject records being updated, in their original state
	 */
	@TestVisible
	private static void setBeforeDelete(List<SObject> oldRecords) {
		mockTriggerContext = new TriggerContext(
			true,
			TriggerOperation.BEFORE_DELETE,
			false,
			false,
			true,
			false,
			true,
			false,
			null,
			null,
			oldRecords,
			mapById(oldRecords),
			oldRecords.size()
		);
	}

	/**
	 * Mocks the trigger context to represent a after-delete trigger.
	 * @param oldRecords List of sObject records being updated, in their original state
	 */
	@TestVisible
	private static void setAfterDelete(List<SObject> oldRecords) {
		mockTriggerContext = new TriggerContext(
			true,
			TriggerOperation.AFTER_DELETE,
			false,
			false,
			true,
			false,
			false,
			true,
			null,
			null,
			oldRecords,
			mapById(oldRecords),
			oldRecords.size()
		);
	}

	/**
	 * Mocks the trigger context to represent a after-undelete trigger.
	 * @param newRecords List of sObject records being updated, in their new state
	 */
	@TestVisible
	private static void setAfterUndelete(List<SObject> newRecords) {
		mockTriggerContext = new TriggerContext(
			true,
			TriggerOperation.AFTER_UNDELETE,
			false,
			false,
			false,
			true,
			false,
			true,
			newRecords,
			mapById(newRecords),
			null,
			null,
			newRecords.size()
		);
	}


	//==================================================================================================================
	// Private Utility
	//==================================================================================================================

	/**
	 * Creates a map containing all given sObject records, keyed by ID.
	 * @param records List of sObject records to include in map
	 * @return Map of sObject records, keyed by ID
	 */
	private static Map<Id, SObject> mapById(List<SObject> records) {
		Map<Id, SObject> recordsById = new Map<Id, SObject>();
		for (SObject record : records) {
			recordsById.put(record.Id, record);
		}
		return recordsById;
	}
}