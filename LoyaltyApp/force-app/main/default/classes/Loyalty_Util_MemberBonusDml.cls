/*
   @Author: João Almeida
   @CreatedDate: 30/09/2020
   @Description: Contains the CRUD methods for Loyalty_Member_Bonus__c SObject
 */
public with sharing class Loyalty_Util_MemberBonusDml extends Loyalty_Util_GenericDML {
    public class LoyaltyMemberBonusDmlException extends Exception {}

    public Loyalty_Util_MemberBonusDml() {
		super('Loyalty_Member_Bonus__c');
    }

    /*
        @Description: gets loyalty member bonus record by account and bonus rule
        @param1: account id
        @param2: bonus rule id
        @Return: the member bonus records
    */
    public List<Loyalty_Member_Bonus__c> getLoyaltyMemberBonusByAccountAndBonusRule(Id accountId, Id bonusRuleId) {
      List<Loyalty_Member_Bonus__c> memberBonuses = null;
        try {
            List<String> selectableFields = new List<String>{'Id','Account__c', 'Bonus_Assigned_Date__c', 'Loyalty_Program_Setup_Rule__c', 'Loyalty_Value__c'};
            List<String> orderBy = new List<String>{'Bonus_Assigned_Date__c'};
            List<String> whereClauses = new List<String>{'Account__c=\'' + accountId +'\'','and Loyalty_Program_Setup_Rule__c=\'' + bonusRuleId + '\''};
            memberBonuses = (Loyalty_Member_Bonus__c[])this.selectRecords(0, 0, null, null, selectableFields,whereClauses, orderBy, null, false, false);
        }
        catch (Exception ex) {
            throw ex;
        }

        return memberBonuses;
    }
}