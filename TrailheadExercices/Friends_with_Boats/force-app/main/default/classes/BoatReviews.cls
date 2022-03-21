/**
 * @description       : 
 * @author            : Flistergod
 * @group             : 
 * @last modified on  : 12-17-2020
 * @last modified by  : Flistergod
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   12-17-2020   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public class BoatReviews {

    @AuraEnabled
    public static ID saveReview(BoatReview__c review) {
        insert review;
        return review.Id;
    }
	
    @AuraEnabled
    public static List<BoatReview__c> getAll(ID boatId) {
        return [select Id,Name,Comment__c,Rating__c,LastModifiedDate,CreatedDate,CreatedBy.Name,CreatedBy.SmallPhotoUrl,CreatedBy.CompanyName from BoatReview__c where Boat__c = :boatId];
    }
}