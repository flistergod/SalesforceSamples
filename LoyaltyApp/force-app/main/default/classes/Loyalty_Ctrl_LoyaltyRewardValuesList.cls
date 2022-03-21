/*
   @Author: Nelson Andrade
   @CreatedDate: 22/12/2020
   @Description: Controller class for RewardValuesList web component
 */
public with sharing class Loyalty_Ctrl_LoyaltyRewardValuesList {
    public Loyalty_Ctrl_LoyaltyRewardValuesList() {}
    

     /*
        @Description: method to get the list views of the Reward value SObject
        @return: return the list views as a list
	*/
    @AuraEnabled(cacheable = true)
	public static List<ListView> getLoyaltyRewardValueListViews() {
        
        Loyalty_Util_RewardValueDml loyaltyRewardValueDml = new Loyalty_Util_RewardValueDml();
        return loyaltyRewardValueDml.getLoyaltyRewardValueListViews();
    }

     
    /*
        @Description: method to get reward value records
        @param1: current page number
        @param2: items per page
        @param3: quantity of records already queried
        @param4: defines if it is to get recently added data
        @param5: search by keyword
        @return: return the list of reward value record
	*/
	@AuraEnabled
    public static List<Loyalty_Reward_Value__c> 
    getLoyaltyRewardValues(Integer pagenumber, Integer pageSize, 
    Integer lastRecordPosition, Boolean isAddedData, String searchString, List<String> whereClauses, String orderByStr) {
       
        Loyalty_Util_RewardValueDml loyaltyRewardValueDml = new Loyalty_Util_RewardValueDml();
        List<Loyalty_Reward_Value__c> rewardValues = loyaltyRewardValueDml.getLoyaltyRewardValues(
            pagenumber, pageSize, lastRecordPosition, isAddedData, searchString, whereClauses, orderByStr);
      
            return rewardValues;
    }
    
    /*
        @Description: gets the total quantity of program setup rule records
        @param1: search by keyword
        @return: return the count of records
	*/
	@AuraEnabled(cacheable = true)
	public static Integer getLoyaltyRewardValuesCount(String searchString) {
        
        Loyalty_Util_RewardValueDml loyaltyRewardValueDml = new Loyalty_Util_RewardValueDml();
		return loyaltyRewardValueDml.getLoyaltyRewardValuesCount();
    }


    /*
        @Description: gets the record given his Id
        @param1: record Id
        @return: return the record
	*/
    @AuraEnabled
    public static Loyalty_Reward_Value__c getRewardValueData(Id rewardValueId) {
       
        Loyalty_Util_RewardValueDml loyaltyRewardValueDml = new Loyalty_Util_RewardValueDml();
        loyaltyRewardValueDml.getRewardValueById(rewardValueId);
        return   loyaltyRewardValueDml.getRewardValueById(rewardValueId)[0];
    }

    
    /*
        @Description: creates a record
        @param1: value fields for the new record in JSON format
        @return: return the Name of the created record
	*/
    @AuraEnabled
	public static String createRewardValue(String rewardValueJson) {
        
        Loyalty_Util_RewardValueDml loyaltyRewardValueDml = new Loyalty_Util_RewardValueDml();
        Loyalty_Reward_Value__c newRewardValue = (Loyalty_Reward_Value__c)JSON.deserialize(rewardValueJson, Loyalty_Reward_Value__c.class);
        System.debug(newRewardValue);
        loyaltyRewardValueDml.insertRewardValue(newRewardValue);
        return newRewardValue.Name;
    }
    

    /*
        @Description: edits the field values of a record
        @param1: field values of the record to update
        @return: return the Name of the updated record
	*/
    @AuraEnabled
    public static String editRewardValue(String rewardValueJson) {
       
        Loyalty_Util_RewardValueDml loyaltyRewardValueDml = new Loyalty_Util_RewardValueDml();
        Loyalty_Reward_Value__c editRewardValue = (Loyalty_Reward_Value__c)JSON.deserialize(rewardValueJson, Loyalty_Reward_Value__c.class);
        System.debug(editRewardValue);
        String result=loyaltyRewardValueDml.updateRewardValue(editRewardValue);
    	return editRewardValue.Name;
    
    }


    /*
        @Description: updates a record field with a different value
        @param1: field to update
        @param2: new field value
        @param3: record Id
        @param4: search Name
        @return: returns a sucess message if the field was updated
	*/
    @AuraEnabled
	public static String changeLoyaltyRewardValueField(String field, Object  newFieldValue, String Id, String Name) {
        
        Loyalty_Util_RewardValueDml loyaltyRewardValueDml = new Loyalty_Util_RewardValueDml();
        return loyaltyRewardValueDml.changeLoyaltyRewardValueField(
            field, newFieldValue, Id,  Name);
    }
}