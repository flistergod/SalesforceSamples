/*
   @Author: João Almeida
   @CreatedDate: 16/09/2020
   @Description: Contains the CRUD methods for OrderItem SObject
 */
public with sharing class Loyalty_Util_OrderItemDml {
    private class OrderItemDmlException extends Exception {}

    public Loyalty_Util_OrderItemDml() {

    }

    /*
	   @Description: gets formated order line items records by order ID
	   @param1: order ID
	   @Return: the product items records formated related to the order ID
	   @Exception: thrown when the order ID is invalid
	 */
    public List<LoyaltyWrappers.LoyaltyProductItem> getOrderItemsByOrderId(Id orderId) {
        List<LoyaltyWrappers.LoyaltyProductItem> loyaltyProductItems = new List<LoyaltyWrappers.LoyaltyProductItem>();

        if (orderId != null && !String.isEmpty(orderId)) {
            list<OrderItem> orderProducts =[SELECT Id, OrderId, Quantity,UnitPrice, TotalPrice, OrderItemNumber,PricebookEntry.Id, PricebookEntry.Name, 
                                                    PricebookEntry.Product2.Family, PricebookEntry.Product2.Name,PricebookEntry.Product2.id
                                                    FROM OrderItem WHERE OrderId = :orderId];
    
            for (OrderItem item : orderProducts) {
                LoyaltyWrappers.LoyaltyProductItem productItem = new LoyaltyWrappers.LoyaltyProductItem();

                productItem.IsFromOpportunity = false;
                productItem.IsFromOrder = true;
                productItem.OrderId = item.OrderId;
                productItem.OrderItemId = item.Id;
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
            throw new OrderItemDmlException('getOrderItemsByOrderId Error: ' + 'the order Id is invalid: ' + orderId);
        }
        return loyaltyProductItems;
    }
}