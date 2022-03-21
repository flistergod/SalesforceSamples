/*
   @Author: João Almeida
   @CreatedDate: 17/09/2020
   @Description: Controller class for ProgramSetupRulesList web component
 */
public with sharing class Loyalty_Ctrl_ProgramSetupRulesList {
	public Loyalty_Ctrl_ProgramSetupRulesList() {

    }

    /*
        @Description: method to get the list views of the program setup rule SObject
        @return: return the list views as a list
	*/
    @AuraEnabled(cacheable = true)
	public static List<ListView> getProgramSetupRuleListViews() {
        Loyalty_Util_ProgramSetupRuleDml loyaltyProgramSetupDml = new Loyalty_Util_ProgramSetupRuleDml();
        return loyaltyProgramSetupDml.getLoyaltyProgramSetupRuleListViews();
    }

    /*
        @Description: method to get the list of fields related to loyalty program setup rule
        @param1: the SObject name where to get the fields
        @return: return the list of fields
	*/
    @AuraEnabled(cacheable = true)
	public static String getProgramSetupRuleFields(String objectName) {
        List<Loyalty_Util_GenericDML.GenericFieldMapper> fields = new List<Loyalty_Util_GenericDML.GenericFieldMapper>();
        if (objectName == 'Opportunity') {
            Loyalty_Util_OpportunityDml opptyDml = new Loyalty_Util_OpportunityDml();
            fields = opptyDml.getOpportunityFieldsList();
        }
        else if (objectName == 'Order') {
            Loyalty_Util_OrderDml orderDml = new Loyalty_Util_OrderDml();
            fields = orderDml.getOrderFieldsList();
        }
        System.debug(fields);
        return JSON.serialize(fields);
    }
    
    /*
        @Description: method to get program setup rule records
        @param1: current page number
        @param2: items per page
        @param3: quantity of records already queried
        @param4: defines if it is to get recently added data
        @param5: search by keyword
        @return: return the list of program setup rule record
	*/
	@AuraEnabled
	public static List<Loyalty_Program_Setup_Rules__c> getProgramSetupRules(Integer pagenumber, Integer pageSize, Integer lastRecordPosition, Boolean isAddedData, String searchString) {
        Loyalty_Util_ProgramSetupRuleDml loyaltyProgramSetupDml = new Loyalty_Util_ProgramSetupRuleDml();

        List<Loyalty_Program_Setup_Rules__c> programSetups = loyaltyProgramSetupDml.getProgramSetupRules(pagenumber, pageSize, lastRecordPosition, isAddedData, searchString);

        return programSetups;
    }
    
    /*
        @Description: gets the total quantity of program setup rule records
        @param1: search by keyword
        @return: return the count of records
	*/
	@AuraEnabled(cacheable = true)
	public static Integer getProgramSetupRulesCount(String searchString) {
        Loyalty_Util_ProgramSetupRuleDml loyaltyProgramSetupDml = new Loyalty_Util_ProgramSetupRuleDml();
		return loyaltyProgramSetupDml.getLoyaltyProgramSetupRulesCount();
    }

    @AuraEnabled
    public static Loyalty_Program_Setup_Rules__c getProgramSetupRuleData(Id setupRuleId) {
        Loyalty_Util_ProgramSetupRuleDml loyaltyProgramSetupDml = new Loyalty_Util_ProgramSetupRuleDml();
        return loyaltyProgramSetupDml.getProgramSetupRuleById(setupRuleId);
    }
    
    /*
        @Description: creates a new program setup rule record
        @param1: serialized record data
        @return: return the name of the record created
    */
    @AuraEnabled
	public static String createProgramSetupRule(String programSetupRuleJson) {
        Loyalty_Util_ProgramSetupRuleDml loyaltyProgramSetupDml = new Loyalty_Util_ProgramSetupRuleDml();
        Loyalty_Program_Setup_Rules__c newSetupRule = (Loyalty_Program_Setup_Rules__c)JSON.deserialize(programSetupRuleJson, Loyalty_Program_Setup_Rules__c.class);
        System.debug(newSetupRule);
        loyaltyProgramSetupDml.insertProgramSetupRule(newSetupRule);
		return newSetupRule.Name;
    }
    
    /*
        @Description: edit a program setup rule record
        @param1: serialized record data
        @return: return the name of the record edited
    */
    @AuraEnabled
    public static String editProgramSetupRule(String programSetupRuleJson) {
        Loyalty_Util_ProgramSetupRuleDml loyaltyProgramSetupDml = new Loyalty_Util_ProgramSetupRuleDml();
        Loyalty_Program_Setup_Rules__c editSetupRule = (Loyalty_Program_Setup_Rules__c)JSON.deserialize(programSetupRuleJson, Loyalty_Program_Setup_Rules__c.class);
        System.debug(editSetupRule);
        loyaltyProgramSetupDml.updateProgramSetupRule(editSetupRule);
		return editSetupRule.Name;
    }
}