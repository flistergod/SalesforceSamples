/**
 * @description       : 
 * @author            : Flistergod
 * @group             : 
 * @last modified on  : 12-21-2020
 * @last modified by  : Flistergod
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   12-21-2020   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public with sharing class BoatSearchResults{
    @AuraEnabled(cacheable=true)
    public static List<Boat__c> getBoats(String boatTypeId)
    {
        String query = 'SELECT Name, BoatType__c, Contact__c, ' +
                               'Description__c, Geolocation__latitude__s, Geolocation__longitude__s, '+
                               'Length__c, Year_Built__c, Picture__c, Price__c, Contact__r.Name ' +
                       'FROM   Boat__c ';
        if (!String.isEmpty(boatTypeId))
        {
            query += 'WHERE BoatType__c = :boatTypeId ';
        }
        query += 'LIMIT 50000';

        return Database.query(query);
    }
}