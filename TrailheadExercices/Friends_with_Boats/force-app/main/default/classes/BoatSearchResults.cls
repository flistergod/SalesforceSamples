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
public class BoatSearchResults {
    
    @AuraEnabled
    public static List<Boat__c> getBoats(String boatTypeId) {
        if(String.isNotBlank(boatTypeId)) {
            return [select Id,Name,Contact__r.Name,Picture__c,BoatType__c,Geolocation__latitude__s,Geolocation__longitude__s from Boat__c where BoatType__c = :boatTypeId];
        }
        return [select Id,Name,Contact__r.Name,Picture__c,BoatType__c,Geolocation__latitude__s,Geolocation__longitude__s from Boat__c];
    }

    @AuraEnabled
    public static Boat__c getBoatById(String boatId) {
        return [select Id,Name,Description__c,Price__c,Length__c,Contact__r.Name,Contact__r.Email,Contact__r.HomePhone,BoatType__r.Name,Picture__c from Boat__c where Id = :boatId];
    }
}