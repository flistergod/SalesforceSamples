/*
   @Author: André Cunha
   @CreatedDate: 10/07/2020
   @Description: Controller class for loyaltyProgramSetup component
 */
public class Loyalty_Ctrl_LoyaltyProgramSetup {
    
    /*
        @Description: method to get setupId
        @param1: loyalty program id
        @return: return the setupId
	*/
    @AuraEnabled
    public static Id getProgramSetupId(String programId){
        
        Id loyaltyProgramSetupId = [SELECT Id FROM Loyalty_Program_Setup__c WHERE Loyalty_Program__c = :programId AND Active__c = TRUE Limit 1].Id;

        return loyaltyProgramSetupId;
    }
    
    /*
        @Description: method to get program setup id and record type id
        @param1: loyalty program id
        @return: return the object with id and recordTypeId
	*/
    @AuraEnabled
    public static Loyalty_Program_Setup__c getProgramSetupRecordTypeId(String programId){
        
        return [SELECT Id, RecordTypeId FROM Loyalty_Program_Setup__c WHERE Loyalty_Program__c = :programId AND Active__c = TRUE Limit 1];
    }
}