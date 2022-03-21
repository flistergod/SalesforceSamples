/*
   @Author: João Almeida
   @CreatedDate: 08/09/2020
   @Description: Manage Loyalty Value Interface to define it's data processing methods
 */
public interface Loyalty_I_ManageLoyaltyValue {
    void processCustomerOpptyLoyaltyValues(List<Opportunity> opptiesWon);
    void processCustomerOrderLoyaltyValues(List<Order> orders);
}