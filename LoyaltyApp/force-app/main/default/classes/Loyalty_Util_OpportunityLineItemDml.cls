/*
   @Author: João Almeida
   @CreatedDate: 16/09/2020
   @Description: Contains the CRUD methods for OpportunityLineItem SObject
 */
public with sharing class Loyalty_Util_OpportunityLineItemDml {
    private class OpportunityLineItemDmlException extends Exception {}
    
    public Loyalty_Util_OpportunityLineItemDml() {

    }

    /*
	   @Description: gets formated opportunity line items records by opportunity ID
	   @param1: opportunity ID
	   @Return: the product items records formated related to the opportunity ID
	   @Exception: thrown when the opportunity ID is invalid
	 */
    public List<LoyaltyWrappers.LoyaltyProductItem> getOpptyLineItemsByOpptyId(Id opptyId) {
        List<LoyaltyWrappers.LoyaltyProductItem> loyaltyProductItems = new List<LoyaltyWrappers.LoyaltyProductItem>();

        if (opptyId != null && !String.isEmpty(opptyId)) {
            list<OpportunityLineItem> opptyProducts =[SELECT Id,OpportunityId,Quantity, UnitPrice, TotalPrice, ProductCode, PricebookEntry.Id, PricebookEntry.Name, 
                                                        PricebookEntry.Product2.Family, PricebookEntry.Product2.Name,PricebookEntry.Product2.id
                                                        FROM OpportunityLineItem WHERE OpportunityId = :opptyId];
    
            for (OpportunityLineItem item : opptyProducts) {
                LoyaltyWrappers.LoyaltyProductItem productItem = new LoyaltyWrappers.LoyaltyProductItem();

                productItem.IsFromOpportunity = true;
                productItem.IsFromOrder = false;
                productItem.OpportunityId = item.OpportunityId;
                productItem.OpportunityLineItemId = item.Id;
                productItem.PricebookEntryId = item.PricebookEntry.Id;
                productItem.PricebookEntryName = item.PricebookEntry.Name;
                productItem.ProductFamily = item.PricebookEntry.Product2.Family;
                productItem.ProductId = item.PricebookEntry.Product2.Id;
                productItem.ProductName = item.PricebookEntry.Product2.Name;
                productItem.Quantity = item.Quantity;
                productItem.TotalPrice = item.TotalPrice;
                productItem.UnitPrice = item.UnitPrice;
    
                loyaltyProductItems.add(productItem);
            }
        }
        else {
            throw new OpportunityLineItemDmlException('getOpptyLineItemsByOpptyId Error: ' + 'the opportunity Id is invalid: ' + opptyId);
        }
        return loyaltyProductItems;
    }
}