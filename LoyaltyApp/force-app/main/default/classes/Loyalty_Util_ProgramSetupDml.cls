/*
   @Author: João Almeida
   @CreatedDate: 08/09/2020
   @Description: Contains the CRUD methods for Loyalty_Program_Setup__c SObject
 */
public with sharing class Loyalty_Util_ProgramSetupDml extends Loyalty_Util_GenericDML {
    public class LoyaltyProgramSetupDmlException extends Exception{}
    
    public Loyalty_Util_ProgramSetupDml() {
        super('Loyalty_Program_Setup__c');
    }

    /*
       @Description: gets loyalty program setup record by ID
       @param1: the record ID
       @Return: the loyalty program setup record related to the ID
       @Exception: thrown when there is no record related or if there is more than 1 record related
	 */
    public Loyalty_Program_Setup__c getLoyaltyProgramSetupById(Id programSetupId) {
        Loyalty_Program_Setup__c getById = null;
        try {
            List<Loyalty_Program_Setup__c> setups = (Loyalty_Program_Setup__c[])this.selectById(programSetupId,null, false, false);
            if (!setups.isEmpty()) {
                if (setups.size() == 1) {
                    getById = setups[0];
                }
                else {
                    throw new LoyaltyProgramSetupDmlException('getLoyaltyProgramSetupById Error: ' + 'more than 1 setup found for Id ' + programSetupId);
                }
            }
            else {
                throw new LoyaltyProgramSetupDmlException('getLoyaltyProgramSetupById Error: ' + 'no setup found for Id ' + programSetupId);
            }
        }
        catch (Exception ex) {
            throw ex;
        }

        return getById;
    }

    /*
       @Description: gets loyalty program setup record by loyalty program ID
       @param1: loyalty program ID
       @Return: the loyalty program setup record related to loyalty program ID
       @Exception: thrown when there is no record related or if there is more than 1 record related
	 */
    public Loyalty_Program_Setup__c getLoyaltyProgramSetupByProgramId(Id programId) {
        Loyalty_Program_Setup__c getById = null;
        try {
            List<String> selectableFields = new List<String>{'Id','Active__c', 'Loyalty_Program__c', 'Points_Per_Value_Spent__c', 'Points_Validity_Days__c', 'Value_Spent__c'};
            List<String> orderBy = new List<String>{'Active__c'};
            List<String> whereClauses = new List<String>{'Loyalty_Program__c=\'' + programId +'\'','and Active__c=true'};
            List<Loyalty_Program_Setup__c> setups = (Loyalty_Program_Setup__c[])this.selectRecords(1, 1, null, null, selectableFields,whereClauses, orderBy, null, false, false);
            if (!setups.isEmpty()) {
                if (setups.size() == 1) {
                    getById = setups[0];
                }
                else {
                    throw new LoyaltyProgramSetupDmlException('getLoyaltyProgramSetupByProgramId Error: ' + 'more than 1 setup found for program Id ' + programId);
                }
            }
            else {
                throw new LoyaltyProgramSetupDmlException('getLoyaltyProgramSetupByProgramId Error: ' + 'no setup found for program Id ' + programId);
            }
        }
        catch (Exception ex) {
            throw ex;
        }

        return getById;
    }

    /*
       @Description: gets loyalty program setups by pagination definitions
       @param1: current page number
       @param2: page size - quantity of records per page
       @param3: optional search keyword value
       @Return: the loyalty program setup records
	 */
    public List<Loyalty_Program_Setup__c> getLoyaltyProgramSetups(Integer pagenumber, Integer pageSize, String searchString) {
        List<Loyalty_Program_Setup__c> setups = null;
        try {
            List<String> selectableFields = new List<String>{'Id','Active__c', 'Loyalty_Program__c','Loyalty_Program__r.Name', 'Points_Per_Value_Spent__c', 'Points_Validity_Days__c', 'Value_Spent__c'};
            List<String> orderBy = new List<String>{'Active__c'};
            //List<String> whereClauses = new List<String>{'Loyalty_Program__c=\'' + programId +'\'','and Active__c=true'};
            setups = (Loyalty_Program_Setup__c[])this.selectRecords(pagenumber, pageSize, searchString, null, selectableFields,null, orderBy, null, false, false);
        }
        catch (Exception ex) {
            throw ex;
        }

        return setups;
    }

    /*
       @Description: gets the list views related to Loyalty_Program_Setup__c SObject
       @Return: the list of listViews
	 */
    public List<ListView> getLoyaltyProgramSetupListViews() {
        List<ListView> programSetupListViews = [SELECT Id, DeveloperName, Name FROM ListView WHERE SObjectType = 'Loyalty_Program_Setup__c'];

        return programSetupListViews;
    }
}