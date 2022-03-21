/*
   @Author: João Almeida
   @CreatedDate: 24/09/2020
   @Description: Contains the CRUD methods for Opportunity SObject
 */
public with sharing class Loyalty_Util_OpportunityDml extends Loyalty_Util_GenericDML {
    private class LoyaltyOpportunityDmlException extends Exception {}

    public Loyalty_Util_OpportunityDml() {
        super('Opportunity');
    }

    /*
      @Description: gets the list of fields related to Opportunity SObject
      @Return: the list of fields
	 */
    public List<Loyalty_Util_GenericDML.GenericFieldMapper> getOpportunityFieldsList() {
        List<Loyalty_Util_GenericDML.GenericFieldMapper> fields = this.getSObjectFieldsList();

        return fields;
    }
}