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
@isTest
public class GenerateDataTests {

    static void test() {
		GenerateData.initData();
        List<Boat__c> boats = [Select id from Boat__c];
        System.assert(boats.size() > 0, 'Boats found');
    } 

    @isTest
    static void test_initialization_works() {
        Test.startTest();
            GenerateData.init();
        Test.stopTest();

        // The following simple counts are fine
        System.assert([SELECT count() from Boat__c] > 0, 'No Boat__c were found');
        System.assert([SELECT count() from BoatType__c] > 0, 'No BoatType__c were found');
        System.assert([SELECT count() from Account] == 1, 'No Account was found');
        System.assert([SELECT count() from Contact] > 0, 'No Contacts found');
    }
    
    @isTest
    static void test_getLengthForBoatType_NoType(){
        Integer boatLength = GenerateData.getLengthForBoatType('');
        System.assertEquals(20, boatLength, 'The boat length was calculated wrongly.');
    }
    @isTest
    static void test_getPriceForBoatType_NoType(){
        Integer boatPrice = GenerateData.getPriceForBoatType('');
        System.assertEquals(15000, boatPrice, 'The boat price was calculated wrongly.');
    }


}