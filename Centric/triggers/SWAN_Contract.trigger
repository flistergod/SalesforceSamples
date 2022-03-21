trigger SWAN_Contract on Contract ( after update ) {
	
	if(!SWAN_Constants.QuoteTriggerExecuted && Trigger.isUpdate && Trigger.isAfter)
	{
		SWAN_ContractLogicHandler.generateBCRFile();	
	}
}