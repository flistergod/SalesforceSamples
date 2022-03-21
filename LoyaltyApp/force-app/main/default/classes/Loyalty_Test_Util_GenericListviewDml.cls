/**
 * @description       : 
 * @author            : Nelson Andrade
 * @group             : 
 * @last modified on  : 02-02-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   02-01-2021   Nelson Andrade                       Initial Version
**/
@isTest
public with sharing class Loyalty_Test_Util_GenericListviewDml {

    private static Loyalty_Util_GenericListviewDmlWrapper mockGenericListview;
    private static String ObjectType='';
    private static String DeveloperName='';

    static void populateMockData() {

         ObjectType='Loyalty_Reward_Value__c';
         DeveloperName='ListviewUnitTest';

         mockGenericListview =(Loyalty_Util_GenericListviewDmlWrapper)Test.createStub(
            Loyalty_Util_GenericListviewDmlWrapper.class, 
            new Loyalty_Test_Mock_GenericListviewDml()
            );
    }

     
    @IsTest static void getSessionIdFromVFPage() {
      

        Pagereference pageref = new Pagereference('/apexLoyalty_VFP_GetSessionId');
        
        Test.startTest();
        populateMockData();   
        
        String result= mockGenericListview.getSessionIdFromVFPage(pageref);

        System.assertNotEquals(null, result);     
        Test.stopTest();
        
    }

     
    @IsTest static void createMetadataService() {
      
        Test.startTest();
        populateMockData();   
        
        MetadataService.MetadataPort result= mockGenericListview.createMetadataService();

        System.assertNotEquals(null, result);   
        Test.stopTest();
    }

     
    @IsTest static void getListviewFilters() {
      
        Test.startTest();
        populateMockData();   
        
        List<MetadataService.ListViewFilter> result= 
        mockGenericListview.getListviewFilters(ObjectType, DeveloperName);

        System.assertNotEquals(null, result);      
        Test.stopTest();
    }

    @IsTest static void getListviewsLabels() {
      
        Test.startTest();
        populateMockData();   
        
        List<String> result= mockGenericListview.getListviewsLabels('Loyalty_Reward_Value__c');

        System.assertNotEquals(null, result);      
        Test.stopTest();
    }



     
    @IsTest static void createListview() {
      
        String Name='Listview Unit Test';
        String filterScope='Everything';
        List<String> columns=new List<String> {
            'NAME',
            'CREATEDBY_USER.ALIAS',
            'CREATED_DATE',
            'UPDATEDBY_USER.ALIAS',
            'LAST_UPDATE',
            'Is_Delivered__c',
            'Reward_Type__c',
            'Loyalty_Reward_Value_Code__c',
            'Loyalty_Reward__c',
            'Loyalty_Value__c'
        };

        List<String> filters=new List<String> {
            'LAST_UPDATE lessOrEqual 01/28/2021',
            'LAST_UPDATE greaterOrEqual 01/18/2021',
            'LoyaltyCreatedDateNotEqualToLastModified__c equals 1'
        }; 

        Test.startTest();
        populateMockData(); 
        
        String result= mockGenericListview.createListview(ObjectType, DeveloperName, Name, filterScope,
         columns, filters);

         System.assertNotEquals(null, result);     
        Test.stopTest();
    }

     
    @IsTest static void deleteListView() {

        Test.startTest();
        populateMockData();   
        
        String result= mockGenericListview.deleteListView(ObjectType, DeveloperName);

        System.assertNotEquals(null, result);     
        Test.stopTest();
    }

     
    @IsTest static void getListviewColumns() {
      
        Test.startTest();
        populateMockData();   
        
        List<String> result= mockGenericListview.getListviewColumns(ObjectType, DeveloperName);

        System.assertNotEquals(null, result);     
        Test.stopTest();
    }

     
    @IsTest static void editListViewName() {
      
        String Name='NewListviewName';

        Test.startTest();
        populateMockData();   
        
        String result= mockGenericListview.editListViewName(ObjectType, DeveloperName, Name);
      
        System.assertNotEquals(null, result);     
        Test.stopTest();
    }

    
    @IsTest static void editistViewSharingSettings() {
      
        String onlyMe=null;
        String allUsers=null;
        List<String> sharedToArray =new List<String> {
                            'role',
                            'roles',
                            'queue',
                            'groups',
                            'managers',
                            'territory',
                            'groupNames',
                            'portalRole',
                            'territories',
                            'allPartnerUsers',
                            'allInternalUsers',
                            'managerSubordinates',
                            'channelProgramGroup',
                            'roleAndSubordinates',
                            'channelProgramGroups',
                            'rolesAndSubordinates',
                            'allCustomerPortalUsers',
                            'territoryAndSubordinates',
                            'portalRoleAndSubordinates',
                            'territoriesAndSubordinates',
                            'roleAndSubordinatesInternal'
        };

        Test.startTest();
        populateMockData();   
        
        String result= mockGenericListview.editListViewSharingSettings(ObjectType, DeveloperName, 
        sharedToArray, onlyMe, allUsers);

        System.assertNotEquals(null, result);       
        Test.stopTest();
    }
    
     
    @IsTest static void editistViewFilters() {
      
        List<String> filters=new List<String> {
            'LAST_UPDATE lessOrEqual 01/28/2021',
            'LAST_UPDATE greaterOrEqual 01/18/2021',
            'LoyaltyCreatedDateNotEqualToLastModified__c equals 1'
          };

        Test.startTest();
        populateMockData();   
        
        String result= mockGenericListview.editListViewFilters(ObjectType, DeveloperName, filters);

        System.assertNotEquals(null, result);       
        Test.stopTest();
    }

     
    @IsTest static void editistViewFields() {
      
        List<String> columns=new List<String> {
            'NAME',
            'CREATEDBY_USER.ALIAS',
            'CREATED_DATE',
            'UPDATEDBY_USER.ALIAS',
            'LAST_UPDATE',
            'Is_Delivered__c',
            'Reward_Type__c',
            'Loyalty_Reward_Value_Code__c',
            'Loyalty_Reward__c',
            'Loyalty_Value__c'
        };

        Test.startTest();
        populateMockData();   
        
        String result= mockGenericListview.editListViewFields(ObjectType, DeveloperName, columns);

        System.assertNotEquals(null, result);        
        Test.stopTest();
    }

     
    @IsTest static void handleSaveResults() {
      
        MetadataService.SaveResult saveResult=null;

        Test.startTest();
        populateMockData();   
        
        String result= mockGenericListview.handleSaveResults(saveResult);

        System.assertNotEquals(null, result);      
        Test.stopTest();
    }

     
    @IsTest static void handleDeleteResults() {
      
        MetadataService.DeleteResult deleteResult=null;

        Test.startTest();
        populateMockData();   
        
        String result= mockGenericListview.handleDeleteResults(deleteResult);

        System.assertNotEquals(null, result);      
        Test.stopTest();
    }
  
}