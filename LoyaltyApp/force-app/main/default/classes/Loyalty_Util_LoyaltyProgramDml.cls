/*
   @Author: João Almeida
   @CreatedDate: 08/09/2020
   @Description: Contains the CRUD methods for Loyalty_Program__c SObject
 */
public with sharing class Loyalty_Util_LoyaltyProgramDml extends Loyalty_Util_GenericDML {
    public class LoyaltyProgramDmlException extends Exception{}
    
    public Loyalty_Util_LoyaltyProgramDml() {
        super('Loyalty_Program__c');
    }

    /*
       @Description: gets loyalty program record by the record type name
       @param1: Api name of the record type
       @Return: the loyalty program record related to the record type name
       @Exception: thrown when there is no record related or if there is more than 1 record related
	 */
    public Loyalty_Program__c getLoyaltyProgramByType(string recordTypeName) {
        Loyalty_Program__c getById = null;
        try {
            List<String> selectableFields = new List<String>{'Id','Active__c', 'Program_Start_Date__c', 'Program_End_Date__c'};
            List<String> orderBy = new List<String>{'Program_End_Date__c'};
            List<String> whereClauses = new List<String>{'RecordType.Name=\'' + recordTypeName +'\'','and Active__c=true'};
            List<Loyalty_Program__c> programs = (Loyalty_Program__c[])this.selectRecords(1, 1, null, null, selectableFields,whereClauses, orderBy, null, false, false);
            if (!programs.isEmpty()) {
                if (programs.size() == 1) {
                    getById = programs[0];
                }
                else {
                    throw new LoyaltyProgramDmlException('getLoyaltyProgramByType Error: ' + 'more than 1 program found for type ' + recordTypeName);
                }
            }
            else {
                throw new LoyaltyProgramDmlException('getLoyaltyProgramByType Error: ' + 'no program found for type ' + recordTypeName);
            }
        }
        catch (Exception ex) {
            throw ex;
        }

        return getById;
    }

    /*
       @Description: gets the type__c picklist options
       @Return: the list of options
	 */
	public List<String> getTypePickListValuesList() {
		List<String> pickListValuesList= new List<String>();
		Schema.DescribeFieldResult fieldResult = Loyalty_Program__c.Type__c.getDescribe();
		List<Schema.PicklistEntry> plEntries = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : plEntries) {
			pickListValuesList.add(pickListVal.getLabel());
		}
		return pickListValuesList;
	}
}