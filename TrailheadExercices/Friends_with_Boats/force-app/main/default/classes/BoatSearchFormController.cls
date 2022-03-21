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
public with sharing class BoatSearchFormController {
   	
    @AuraEnabled
    public static List<BoatType__c> getAllBoatTypes() {
        return [select Id,Name from BoatType__c];
    }
}