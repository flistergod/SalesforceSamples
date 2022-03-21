/*
   @Author: João Almeida
   @CreatedDate: 14/09/2020
   @Description: Contains the CRUD methods for Loyalty_Reward_Value__c SObject
 */
public with sharing class Loyalty_Util_RewardValueDml extends Loyalty_Util_GenericDML  {
	private class LoyaltyRewardValueDmlException extends Exception {}

	public Loyalty_Util_RewardValueDml() {
		super('Loyalty_Reward_Value__c');
    }

     
      /*
	    @Description: gets the reward values by pagination definitions
      @param1: current page number
      @param2: page size - quantity of records per page
      @param3: used for infinite loaders instead of pagination
      @param4: defines if it is to get recently added data
      @param5: optional search keyword value
	    @Return: reward value records
	 */
  public List<Loyalty_Reward_Value__c> getLoyaltyRewardValues(Integer pagenumber, Integer pageSize,
  
  Integer lastRecordPosition, Boolean isAddedData, String searchString, List<String> whereClauses, String orderByStr) {
    List<Loyalty_Reward_Value__c> rewardValues = null;
   
    try {
        List<String> orderBy = new List<String> {orderByStr};
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

        /*lookup fields:
        loyalty value: */

        List<String> selectableFields = new List<String> {
          //I dont know what fields are important, so, for now, lets put them all
          //loyalty Reward fields
          'Id',
          'Is_Delivered__c',
          'Loyalty_Reward_Value_Code__c',
          'Loyalty_Reward__c',
          'Loyalty_Value__c',
          'Loyalty_Value__r.Active__c',
          'Name', 
          'Reward_Type__c'
          

          /*Generic not ready for 3rd level fields
          //and listview don´t take 2nd and 3rd level fields

          //loyalty value fields
          'Loyalty_Reward__r.Name',
          'Loyalty_Value__r.Customer_Points__c',
          'Loyalty_Value__r.Customer_Spend_Points__c',
          'Loyalty_Value__r.Expiration_Date__c',
          'Loyalty_Value__r.Is_Points_Used__c',
          'Loyalty_Value__r.Name',
          'Loyalty_Value__r.Active__c',
          'Loyalty_Value__r.Program_Member__c'
           //program member fields
          'Loyalty_Value__r.Program_Member__r.Loyalty_Level__c'
          'Loyalty_Value__r.Program_Member__r.Is_Active__c',
          'Loyalty_Value__r.Program_Member__r.Joining_Date__c',
          'Loyalty_Value__r.Program_Member__r.Loyalty_Program__c',
          'Loyalty_Value__r.Program_Member__r.Member__c',
          'Loyalty_Value__r.Program_Member__r.Member_Code__c',
          'Loyalty_Value__r.Program_Member__r.Name',
          'Loyalty_Value__r.Program_Member__r.Member_Number__c',
          'Loyalty_Value__r.Program_Member__r.RecordTypeId',

          //loyalty level fields
          'Loyalty_Value__r.Program_Member__r.Loyalty_Level__r.Name',

          //loyalty program fields
          'Loyalty_Value__r.Program_Member__r.Loyalty_Program__r.Active__c',
          'Loyalty_Value__r.Program_Member__r.Loyalty_Program__r.Description__c',
          'Loyalty_Value__r.Program_Member__r.Loyalty_Program__r.Name',
          'Loyalty_Value__r.Program_Member__r.Loyalty_Program__r.Program_End_Date__c',
          'Loyalty_Value__r.Program_Member__r.Loyalty_Program__r.Program_Start_Date__c',
          'Loyalty_Value__r.Program_Member__r.Loyalty_Program__r.Type__c',
          'Loyalty_Value__r.Program_Member__r.Loyalty_Program__r.RecordTypeId'
          
          */
        };
        
        rewardValues = (Loyalty_Reward_Value__c[])this.selectRecords(newPageNumber, newOffset, searchString, null, selectableFields, whereClauses, orderBy, null, false, false);
    }
    catch (Exception ex) {
        throw ex;
    }

    return rewardValues;
}


    
    /*
  @Description: gets the list views related to Loyalty_Reward_Value__c SObject
  @Return: the list of listViews
*/
public List<ListView> getLoyaltyRewardValueListViews() {
    
    List<ListView> rewardValueListViews = [SELECT Id, DeveloperName, Name FROM ListView WHERE SObjectType = 'Loyalty_Reward_Value__c'];
    return rewardValueListViews;
}

/*
  @Description: gets the cont of Loyalty_Reward_Value__c SObject
  @Return: the count
*/
public integer getLoyaltyRewardValuesCount() {
    
    integer quantity = this.count(null, null, false, false);
    return quantity;
}


     /*
        @Description: gets the record given his Id
        @param1: record Id
        @return: return the record
	*/

    public List<Loyalty_Reward_Value__c> getRewardValueById(Id rewardValueId) {
        List<Loyalty_Reward_Value__c> rewardValue = null;
        try {
            List<String> selectableFields = new List<String> {'Id','Name', 'Is_Delivered__c', 'Loyalty_Reward__c', 'Loyalty_Reward_Value_Code__c', 'Loyalty_Value__c', 'Reward_Type__c'};
            List<String> orderBy = new List<String> {'Name'};
            List<String> whereClauses = new List<String>{ 'Id=\'' + rewardValueId + '\''};
            rewardValue = (Loyalty_Reward_Value__c[])this.selectRecords(0, 0, null, null, selectableFields,whereClauses, orderBy, null, false, false);
        }
        catch (Exception ex) {
            throw ex;
        }
    
        return rewardValue;
    }
    



	/*
	   @Description: inserts Loyalty Reward Value records
	   @param1: the Loyalty Reward Value records
	   @Return: the result message 'INSERT SUCCESS' if success
	 */
public string insertLoyaltyRewardValues(List<Loyalty_Reward_Value__c> rewardsValuesInsert) {
      
        string resultMessage;
       
        if (rewardsValuesInsert != null && !rewardsValuesInsert.isEmpty()) {
            resultMessage = this.insertBulk(rewardsValuesInsert);
        }
        else {
            resultMessage = 'The list of Loyalty_Reward_Value__c must contain records to be inserted';
        }

        return resultMessage;
  }



    /*
        @Description: creates a record
        @param1: value fields for the new record in JSON format
        @return: return the Name of the created record
	*/
public string insertRewardValue(Loyalty_Reward_Value__c newRewardValue) {
    List<Loyalty_Reward_Value__c> toInsert = new List<Loyalty_Reward_Value__c>();
    toInsert.add(newRewardValue);
    string result = this.insertBulk(toInsert);
    if (result != 'INSERT SUCCESS') {
        throw new LoyaltyRewardValueDmlException('insertRewardValue error: ' + result);
    }
    return result;
}

    /*
        @Description: updates a record field with a different value
        @param1: field to update
        @param2: new field value
        @param3: record Id
        @param4: search Name
        @return: returns a sucess message if the field was updated
	*/

    public String changeLoyaltyRewardValueField(
        String field, Object newFieldValue, String Id, String Name) {

        List<SObject> objectsToUpdate = new List<SObject>(); 
       
        SObject record= Database.query('SELECT Id, Name, '+field+
        ' FROM Loyalty_Reward_Value__c WHERE Id =: Id');

        record.put(field, newFieldValue);
        objectsToUpdate.add(record);
       return this.updateBulk(objectsToUpdate);
    }
 

   /*
        @Description: edits the field values of a record
        @param1: field values of the record to update
        @return: return the Name of the updated record
	*/
    public string updateRewardValue(Loyalty_Reward_Value__c editRewardValue) {
    
    List<Loyalty_Reward_Value__c> toUpdate = new List<Loyalty_Reward_Value__c>();
    toUpdate.add(editRewardValue);
    string result = this.updateBulk(toUpdate);
    
    if (result != 'UPDATE SUCCESS') {
        throw new LoyaltyRewardValueDmlException('updateRewardValue error: ' + result);
    }
    return result;
}


}