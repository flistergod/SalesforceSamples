/*
   @Author: João Almeida
   @CreatedDate: 18/09/2020
   @Description: Contains the CRUD methods for Loyalty_Program_Setup_Rules__c SObject
 */
public with sharing class Loyalty_Util_ProgramSetupRuleDml extends Loyalty_Util_GenericDML {
    public class LoyaltyProgramSetupRuleException extends Exception {}
    
    public Loyalty_Util_ProgramSetupRuleDml() {
		    super('Loyalty_Program_Setup_Rules__c');
    }

    /*
	    @Description: gets the program setup rules by pagination definitions
      @param1: current page number
      @param2: page size - quantity of records per page
      @param3: used for infinite loaders instead of pagination
      @param4: defines if it is to get recently added data
      @param5: optional search keyword value
	    @Return: program setup rule records
	 */
	  public List<Loyalty_Program_Setup_Rules__c> getProgramSetupRules(Integer pagenumber, Integer pageSize, Integer lastRecordPosition, Boolean isAddedData, String searchString) {
        List<Loyalty_Program_Setup_Rules__c> programSetupRules = null;
        try {
            List<String> orderBy = new List<String> {'Name'};
            // deal with offset of an infinite loader
            integer newOffset= pageSize;
            integer newPageNumber= pagenumber;
            Integer newPageSize = (lastRecordPosition == null ? 0 : lastRecordPosition) - pageSize;
            if (newPageSize > 0) {
                newOffset = ((pagenumber * pageSize) + newPageSize) - pageSize;
                newPageNumber = 2;
                if (isAddedData == true) {
                    orderBy = new List<String> {'Id'};
                }
            }

            List<String> selectableFields = new List<String> {'Id','Name', 'Active__c', 'Rule_Status__c', 'Loyalty_Program_Setup__c', 'Loyalty_Program_Setup__r.Loyalty_Program__c',
                                                               'Loyalty_Program_Setup__r.Loyalty_Program__r.Name', 'Loyalty_Program_Setup__r.Points_Per_Value_Spent__c',
                                                                'Assign_Points__c','Assign_Points_Factor__c','Assign_Points_Factor_Operator__c', 'Assign_Points_Factor_Type__c', 'Object_Rules__c',
                                                                'Assign_Points_Factor_Type_Value__c', 'Assign_Points_Field_Value_Name__c', 'Customer_Behaviour_Count__c', 'Customer_Behaviour_Factor__c',
                                                                'Valid_From__c', 'Valid_To__c'};
            
            programSetupRules = (Loyalty_Program_Setup_Rules__c[])this.selectRecords(newPageNumber, newOffset, searchString, null, selectableFields,null, orderBy, null, false, false);
        }
        catch (Exception ex) {
            throw ex;
        }

        return programSetupRules;
    }

    /*
	  @Description: get the program setup rule by id
      @param1: setup rule id
	  @Return: program setup rule record
	 */
	  public Loyalty_Program_Setup_Rules__c getProgramSetupRuleById(Id setupRuleId) {
        Loyalty_Program_Setup_Rules__c programSetupRule = null;
        try {
            List<Loyalty_Program_Setup_Rules__c> setupRules = (Loyalty_Program_Setup_Rules__c[])this.selectById(setupRuleId,null, false, false);
            if (!setupRules.isEmpty()) {
                if (setupRules.size() == 1) {
                    programSetupRule = setupRules[0];
                }
                else {
                    throw new LoyaltyProgramSetupRuleException('getProgramSetupRuleById Error: ' + 'more than 1 setup rule found for Id ' + setupRuleId);
                }
            }
            else {
                throw new LoyaltyProgramSetupRuleException('getProgramSetupRuleById Error: ' + 'no setup rule found for Id ' + setupRuleId);
            }
        }
        catch (Exception ex) {
            throw ex;
        }

        return programSetupRule;
    }

    /*
	  @Description: gets the program setup rules by program setup id
      @param1: program setup id
      @param2: active rules
	  @Return: program setup rule records
	 */
	  public List<Loyalty_Program_Setup_Rules__c> getProgramSetupRulesByProgramSetupId(Id programSetupId, boolean activeRules) {
        List<Loyalty_Program_Setup_Rules__c> programSetupRules = null;
        try {
            List<String> selectableFields = new List<String> {'Id','Name', 'Active__c', 'Rule_Status__c', 'Assign_Points__c', 'Assign_Points_Factor__c', 'Loyalty_Program_Setup__c',
                                                               'Customer_Behaviour_Count__c', 'Customer_Behaviour_Factor__c', 'Object_Rules__c', 'Valid_From__c', 'Valid_To__c',
                                                                'Assign_Points_Factor_Operator__c', 'Assign_Points_Factor_Type__c', 'Assign_Points_Factor_Type_Value__c', 'Assign_Points_Field_Value_Name__c'};
            List<String> orderBy = new List<String> {'Name'};
            List<String> whereClauses = new List<String>{ 'Loyalty_Program_Setup__c=\'' + programSetupId + '\'', 'and Active__c=' + activeRules };
            programSetupRules = (Loyalty_Program_Setup_Rules__c[])this.selectRecords(0, 0, null, null, selectableFields,whereClauses, orderBy, null, false, false);
        }
        catch (Exception ex) {
            throw ex;
        }

        return programSetupRules;
    }
    
    /*
      @Description: gets the list views related to Loyalty_Program_Setup_Rule__c SObject
      @Return: the list of listViews
	 */
    public List<ListView> getLoyaltyProgramSetupRuleListViews() {
        List<ListView> programSetupRuleListViews = [SELECT Id, DeveloperName, Name FROM ListView WHERE SObjectType = 'Loyalty_Program_Setup_Rule__c'];

        return programSetupRuleListViews;
    }

    /*
      @Description: gets the cont of Loyalty_Program_Setup_Rule__c SObject
      @Return: the count
	 */
    public integer getLoyaltyProgramSetupRulesCount() {
        integer quantity = this.count(null, null, false, false);

        return quantity;
    }

    /*
      @Description: gets the list of fields related to Loyalty_Program_Setup_Rule__c SObject
      @Return: the list of fields
	 */
    public List<Loyalty_Util_GenericDML.GenericFieldMapper> getLoyaltyProgramSetupRuleFieldsList() {
        List<Loyalty_Util_GenericDML.GenericFieldMapper> fields = this.getSObjectFieldsList();

        return fields;
    }

    /*
      @Description: inserts a new Program Setup Rule on database
      @param1: the record to insert
      @Return: the result message
	 */
    public string insertProgramSetupRule(Loyalty_Program_Setup_Rules__c newSetupBonusRule) {
        List<Loyalty_Program_Setup_Rules__c> toInsert = new List<Loyalty_Program_Setup_Rules__c>();
        toInsert.add(newSetupBonusRule);
        string result = this.insertBulk(toInsert);
        if (result != 'INSERT SUCCESS') {
            throw new LoyaltyProgramSetupRuleException('insertProgramSetupRule error: ' + result);
        }
        return result;
    }

    /*
      @Description: updates a Program Setup Rule on database
      @param1: the record to update
      @Return: the result message
	 */
    public string updateProgramSetupRule(Loyalty_Program_Setup_Rules__c editSetupBonusRule) {
        List<Loyalty_Program_Setup_Rules__c> toUpdate = new List<Loyalty_Program_Setup_Rules__c>();
        toUpdate.add(editSetupBonusRule);
        string result = this.updateBulk(toUpdate);
        if (result != 'UPDATE SUCCESS') {
            throw new LoyaltyProgramSetupRuleException('updateProgramSetupRule error: ' + result);
        }
        return result;
    }
}