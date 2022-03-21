/*
   @Author: João Almeida
   @CreatedDate: 09/09/2020
   @Description: Contains the CRUD methods for Loyalty_Value__c SObject
 */
public with sharing class Loyalty_Util_LoyaltyValueDml extends Loyalty_Util_GenericDML {
    public class LoyaltyValueDmlException extends Exception{}

    public Loyalty_Util_LoyaltyValueDml() {
        super('Loyalty_Value__c');
	}
	
	/*
	    @Description: gets the next expiring loyalty value related to an account and an expiring date
	    @param1: the account ID
	    @param2: the next Expiring date
	    @Return: the Result data
	 */
	public List<Loyalty_Value__c> getLoyaltyMemberValueNextExpiring(Id accountId, Datetime nextExpiringDateTime) {
		List<Loyalty_Value__c> loyaltyValues = new List<Loyalty_Value__c>();

		List<String> selectableFields = new List<String> {'Customer_Points__c', 'Customer_Spend_Points__c'};
		List<String> whereClauses = new List<String> {'Program_Member__r.Member__c=\'' + accountId +'\'','and Expiration_Date__c=' + nextExpiringDateTime.format('yyyy-MM-dd')};
		List<String> orderBy = new List<String> {'Program_Member__r.Member__c'};

		loyaltyValues = (Loyalty_Value__c[])this.selectRecords(0, 0, null, null, selectableFields,whereClauses, orderBy, null, false, false);

		return loyaltyValues;
	}

	/*
	    @Description: gets the expired loyalty values related to an account
	    @param1: the account ID
	    @Return: the Result data
	 */
	public List<Loyalty_Value__c> getLoyaltyMemberValuesExpired(Id accountId) {
		List<Loyalty_Value__c> loyaltyValues = new List<Loyalty_Value__c>();

		List<String> expiredSelectableFields = new List<String> {'Customer_Points__c', 'Customer_Spend_Points__c'};
		List<String> expiredWhereClauses = new List<String> {'Program_Member__r.Member__c=\'' + accountId +'\'','and Active__c=false','and Is_Points_Used__c=false'};
        List<String> orderBy = new List<String> {'Program_Member__r.Member__c'};
        
		loyaltyValues = (Loyalty_Value__c[])this.selectRecords(0, 0, null, null, expiredSelectableFields,expiredWhereClauses, orderBy, null, false, false);

		return loyaltyValues;
    }
    
    /*
	    @Description: gets the already used loyalty values related to an account
	    @param1: the account ID
	    @Return: the Result data
	 */
	public List<Loyalty_Value__c> getLoyaltyMemberValuesAlreadyUsed(Id accountId) {
		List<Loyalty_Value__c> loyaltyValues = new List<Loyalty_Value__c>();

		List<String> usedSelectableFields = new List<String> {'Customer_Points__c', 'Customer_Spend_Points__c'};
		List<String> usedWhereClauses = new List<String> {'Program_Member__r.Member__c=\'' + accountId +'\'','and Is_Points_Used__c=true'};
        List<String> orderBy = new List<String> {'Program_Member__r.Member__c'};
        
		loyaltyValues = (Loyalty_Value__c[])this.selectRecords(0, 0, null, null, usedSelectableFields,usedWhereClauses, orderBy, null, false, false);

		return loyaltyValues;
	}

	/*
	   @Description: get loyalty values related to an account
	   TODO joaoalmeida: add the logic for the discounts
	   @param1: the account ID
	   @Return: the Result data
	   @Exception: thrown if there are no records for the account
	 */
	public LoyaltyWrappers.CustomerLoyaltyValuesSummary getLoyaltyMemberValues(Id accountId) {
		LoyaltyWrappers.CustomerLoyaltyValuesSummary summary = new LoyaltyWrappers.CustomerLoyaltyValuesSummary();
		List<Loyalty_Value__c> loyaltyValues = new List<Loyalty_Value__c>();

		try {
			List<String> aggregatedFields = new List<String> {'sum(Customer_Points__c)CustomerPoints', 'MIN(Expiration_Date__c)NextExpiringDate',
				                                          'sum(Customer_Spend_Points__c)CustomerSpendPoints'};
			List<String> orderBy = new List<String> {'Program_Member__c'};
			List<String> aggregateWhereClauses = new List<String> {'Program_Member__r.Member__c=\'' + accountId +'\'','and Active__c=true'};
			String groupByClauses = 'group by Program_Member__c';
			List<AggregateResult> aggregatedValues = (AggregateResult[])this.selectRecords(0, 0, null, null, aggregatedFields,aggregateWhereClauses, orderBy, groupByClauses, null, false, false);
			if (!aggregatedValues.isEmpty()) {
				decimal totalPoints = (decimal)aggregatedValues[0].get('CustomerPoints');
				summary.NextExpiringPointsDate = (Date)aggregatedValues[0].get('NextExpiringDate');
				decimal totalSpendPoints = (decimal)aggregatedValues[0].get('CustomerSpendPoints');
				summary.Points = totalPoints != null ? (integer)totalPoints : 0;
				summary.ExpiringPoints = 0;
				summary.ExpiredPoints = 0;
				summary.UsedPoints = 0;
				summary.SpendPoints = totalSpendPoints != null ? (integer)totalSpendPoints : 0;

				Datetime nextExpiringDateTime = datetime.newInstance(summary.NextExpiringPointsDate.year(), summary.NextExpiringPointsDate.month(),summary.NextExpiringPointsDate.day());

				List<Loyalty_Value__c> values = getLoyaltyMemberValueNextExpiring(accountId, nextExpiringDateTime);
				if (values != null && !values.isEmpty()) {
					for(Loyalty_Value__c value : values) {
						if (value.Customer_Points__c != null && value.Customer_Points__c > 0) {
							summary.ExpiringPoints += (integer)value.Customer_Points__c;
						}
						else if (value.Customer_Spend_Points__c != null && value.Customer_Spend_Points__c > 0) {
							summary.ExpiringPoints += (integer)value.Customer_Spend_Points__c;
						}
					}
				}

				List<Loyalty_Value__c> expiredValues = getLoyaltyMemberValuesExpired(accountId);
				if (expiredValues != null && !expiredValues.isEmpty()) {
					for(Loyalty_Value__c expiredValue : expiredValues) {
						if (expiredValue.Customer_Points__c != null) {
							summary.ExpiredPoints += (integer)expiredValue.Customer_Points__c;
						}
						else if (expiredValue.Customer_Spend_Points__c != null) {
							summary.ExpiredPoints += (integer)expiredValue.Customer_Spend_Points__c;
						}
					}
                }
                
                List<Loyalty_Value__c> usedValues = getLoyaltyMemberValuesAlreadyUsed(accountId);
				if (usedValues != null && !usedValues.isEmpty()) {
					for(Loyalty_Value__c usedValue : usedValues) {
						if (usedValue.Customer_Points__c != null) {
							summary.UsedPoints += (integer)usedValue.Customer_Points__c;
						}
						else if (usedValue.Customer_Spend_Points__c != null) {
							summary.UsedPoints += (integer)usedValue.Customer_Spend_Points__c;
						}
					}
				}
			}
			else {
				throw new LoyaltyValueDmlException('getLoyaltyMemberValues Error: ' + 'no loyalty values found for account ' + accountId);
			}
		}
		catch (Exception ex) {
			throw ex;
		}

		return summary;
	}

    /*
       @Description: inserts a new loyalty value record
       @param1: the record to insert
       @Return: the generated ID
       @Exception: thrown if the insert fails or if the record is null
	 */
    public string insertNewLoyaltyValue(Loyalty_Value__c toInsert) {
        string insertedId;
        List<Loyalty_Value__c> objectsToInsert = new List<Loyalty_Value__c>();

        objectsToInsert.add(toInsert);
        string resultMessage = this.insertBulk(objectsToInsert);
        if (resultMessage == 'INSERT SUCCESS') {
            insertedId = toInsert.Id;
        }

        return insertedId;
    }

    /*
       @Description: updates a loyalty value record
       @param1: the record to update
       @Return: the ID of the updated record
       @Exception: thrown if the update fails or if the record is null
	 */
    public string updateLoyaltyValue(Loyalty_Value__c toUpdate) {
        string updatedId;
        List<Loyalty_Value__c> objectsToUpdate = new List<Loyalty_Value__c>();

        objectsToUpdate.add(toUpdate);
        string resultMessage = this.updateBulk(objectsToUpdate);
        if (resultMessage == 'UPDATE SUCCESS') {
            updatedId = toUpdate.Id;
        }

        return updatedId;
    }

    /*
	   @Description: inserts or updates the customer loyalty points, depending on the duplicated rules
	   @param1: the loyalty values
	   @param2: the loyalty member bonuses asigned values
	   @param3: the new values expiration dates
	 */
	public void upsertCustomerLoyaltyPoints(List<Loyalty_Value__c> newValues, List<Loyalty_Member_Bonus__c> newMemberBonuses, Map<Id,Set<Date> > newExpireDates) {
		List<SObject> parentAndChild = new List<SObject>();
		List<Loyalty_Value__c> toUpdate = new List<Loyalty_Value__c>();

		List<Loyalty_Value__c> currentAccountsValues = [SELECT Program_Member__c, Name, Program_Member__r.Member__c, Id, Customer_Points__c, Customer_Spend_Points__c, Expiration_Date__c FROM Loyalty_Value__c WHERE Active__c = true and Program_Member__r.Member__c IN :newExpireDates.keySet()];
		for (Loyalty_Value__c member : currentAccountsValues) {
			if (newExpireDates.get(member.Program_Member__r.Member__c).contains(member.Expiration_Date__c)) {
				integer insertValueIndex = 0;
				integer insertValueSize = newValues.size();
				while (insertValueIndex < insertValueSize) {
					if (member.Name == newValues[insertValueIndex].Name && member.Expiration_Date__c == newValues[insertValueIndex].Expiration_Date__c) {
						if (member.Customer_Points__c != null) {
							member.Customer_Points__c += (newValues[insertValueIndex].Customer_Points__c != null ? newValues[insertValueIndex].Customer_Points__c : 0);
						}
						else {
							member.Customer_Points__c = 0;
						}
						if (member.Customer_Spend_Points__c != null) {
							member.Customer_Spend_Points__c += (newValues[insertValueIndex].Customer_Spend_Points__c != null ? newValues[insertValueIndex].Customer_Spend_Points__c : 0);
						}
						else {
							member.Customer_Spend_Points__c = 0;
						}
						integer insertBonusesIndex = 0;
						integer insertBonusesSize = newMemberBonuses.size();
						while (insertValueIndex < insertValueSize) {
							if (newValues[insertValueIndex].Name == newMemberBonuses[insertBonusesIndex].Loyalty_Value__r.Name) {
								newMemberBonuses[insertBonusesIndex].Loyalty_Value__r = member;
								break;
							}
							insertBonusesIndex++;
						}
						toUpdate.add(member);
						newValues.remove(insertValueIndex);
						break;
					}
					insertValueIndex++;
				}
			}
		}

		if (toUpdate != null && !toUpdate.isEmpty()) {
			Database.SaveResult[] updatedResults = Database.update(toUpdate);
		}

		parentAndChild.addAll(newValues);
		parentAndChild.addAll(newMemberBonuses);

		Database.SaveResult[] results = Database.insert(parentAndChild);
		for(Database.SaveResult result: results) {
			if(!result.success) {
				throw new LoyaltyValueDmlException(JSON.serialize(result.errors));
			}
		}
	}
}