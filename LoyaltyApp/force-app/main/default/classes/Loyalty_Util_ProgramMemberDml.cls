/*
   @Author: João Almeida
   @CreatedDate: 11/09/2020
   @Description: Contains the CRUD methods for Loyalty_Program_Member__c SObject
 */
public with sharing class Loyalty_Util_ProgramMemberDml extends Loyalty_Util_GenericDML {
	private class LoyaltyProgramMemberDmlException extends Exception {}

	public Loyalty_Util_ProgramMemberDml() {
		super('Loyalty_Program_Member__c');
	}

	/*
	   @Description: gets program members records by account ID
	   @param1: account ID
	   @Return: the programs records related to the account ID
	   @Exception: thrown when there is no record related
	 */
	public List<Loyalty_Program_Member__c> getCustomerLoyaltyProgramsByAccountId(Id accountId) {
		List<Loyalty_Program_Member__c> programs = null;
		try {
			List<String> selectableFields = new List<String> {'Id','Member_Number__c', 'Member__r.Loyalty_Opportunity_Total_of_Purchases__c', 'Member__r.Loyalty_Oppty_Bought_Items_Quantity__c', 'Loyalty_Program__r.Id', 'Loyalty_Program__r.Type__c', 'Loyalty_Program__r.Program_Start_Date__c', 'Loyalty_Program__r.Program_End_Date__c'};
			List<String> orderBy = new List<String> {'Joining_Date__c'};
			List<String> whereClauses = new List<String> {'Member__c=\'' + accountId +'\'', 'and Loyalty_Program__r.Active__c=true'};
			programs = (Loyalty_Program_Member__c[])this.selectRecords(0, 0, null, null, selectableFields,whereClauses, orderBy, null, false, false);
			if (programs.isEmpty()) {
				throw new LoyaltyProgramMemberDmlException('getCustomerLoyaltyProgramsByAccountId Error: ' + 'no program member found for account Id ' + accountId);
			}
		}
		catch (Exception ex) {
			throw ex;
		}

		return programs;
	}

	/*
	   @Description: gets the member program types by account ID
	   @param1: account ID
	   @Return: the program types related to the account ID
	   @Exception: thrown when there is no record related
	 */
	public Set<String> getCustomerLoyaltyProgramTypesByAccountId(Id accountId) {
		Set<String> programTypes = new Set<String>();
		try {
			List<String> selectableFields = new List<String> {'Loyalty_Program__r.Type__c'};
			List<String> orderBy = new List<String> {'Joining_Date__c'};
			List<String> whereClauses = new List<String> {'Member__c=\'' + accountId +'\'', 'and Loyalty_Program__r.Active__c=true'};
			List<Loyalty_Program_Member__c> programs = (Loyalty_Program_Member__c[])this.selectRecords(1, 1, null, null, selectableFields,whereClauses, orderBy, null, false, false);
			if (programs.isEmpty()) {
				throw new LoyaltyProgramMemberDmlException('getCustomerLoyaltyProgramTypesByAccountId Error: ' + 'no program member found for account Id ' + accountId);
			}
			else {
				for (Loyalty_Program_Member__c member : programs) {
					programTypes.add(member.Loyalty_Program__r.Type__c);
				}
			}
		}
		catch (Exception ex) {
			throw ex;
		}

		return programTypes;
	}
	
	/*
	   @Description: gets the current loyalty level of the customer by account ID and loyalty program ID
	   @param1: account ID
	   @param2: loyalty program ID
	   @Return: the current loyalty level related to the account ID
	   @Exception: thrown when there is no record related
	 */
	public Loyalty_Program_Member__c getCurrentCustomerLoyaltyLevel(Id accountId, Id programId) {
		Loyalty_Program_Member__c programMemberLevel = null;
		try {
			List<String> selectableFields = new List<String> {'Id','Member_Number__c', 'Member__r.Loyalty_Opportunity_Total_of_Purchases__c', 'Member__r.Loyalty_Oppty_Bought_Items_Quantity__c', 'Loyalty_Level__r.Id', 'Loyalty_Level__r.Name'};
			List<String> orderBy = new List<String> {'Joining_Date__c'};
			List<String> whereClauses = new List<String> {'Member__c=\'' + accountId +'\'', 'and Is_Active__c=true'};
			if (programId != null && !String.isEmpty(programId)) {
				whereClauses.add('and Loyalty_Program__c=\'' + programId +'\'');
			}
			List<Loyalty_Program_Member__c> programs = (Loyalty_Program_Member__c[])this.selectRecords(0, 0, null, null, selectableFields,whereClauses, orderBy, null, false, false);
			if (programs != null && !programs.isEmpty()) {
				programMemberLevel = programs[0];
			}
			else {
				throw new LoyaltyProgramMemberDmlException('getCurrentCustomerLoyaltyLevel Error: ' + 'no program member found for account Id ' + accountId);
			}
		}
		catch (Exception ex) {
			throw ex;
		}

		return programMemberLevel;
	}

	/*
	   @Description: updates Program Member records
	   @param1: the updated Program Member records
	   @Return: the result message 'UPDATE SUCCESS' if success, any other else
	 */
	public string updateCustomerProgramMembers(List<Loyalty_Program_Member__c> updatedValues) {
		string resultMessage;
		if (updatedValues != null && !updatedValues.isEmpty()) {
			resultMessage = this.updateBulk(updatedValues);
        }
        else {
            resultMessage = 'The list of Loyalty_Program_Member__c must contain records to be updated';
        }

        return resultMessage;
	}
}