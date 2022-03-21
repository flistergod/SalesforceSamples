/*
   @Author: André Cunha
   @CreatedDate: 07/07/2020
   @Description: Trigger Handler Interface to define old and new maps
 */
public interface LoyaltyTriggerInterface {
    Map<Id,SObject> getNewMap();
    Map<Id,SObject> getOldMap();
}