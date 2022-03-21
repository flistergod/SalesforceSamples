/*
   @Author: João Almeida
   @CreatedDate: 11/09/2020
   @Description: Contains the CRUD methods for Loyalty_Level__c SObject
 */
public with sharing class Loyalty_Util_LoyaltyLevelDml extends Loyalty_Util_GenericDML {
    public class LoyaltyLevelDmlException extends Exception {}
    
    public Loyalty_Util_LoyaltyLevelDml() {
		super('Loyalty_Level__c');
    }
}