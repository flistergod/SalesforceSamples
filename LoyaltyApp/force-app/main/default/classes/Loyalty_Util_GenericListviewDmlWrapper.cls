/**
 * @description       : 
 * @author            : Nelson Andrade
 * @group             : 
 * @last modified on  : 02-02-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   02-02-2021   Nelson Andrade                       Initial Version
**/
public with sharing class Loyalty_Util_GenericListviewDmlWrapper {
    public class MetaDataServiceException extends Exception {}
    
    public Loyalty_Util_GenericListviewDmlWrapper() {}

    
     /*******************************************************************************************************
    *                        Wrapper methods for the Loyalty_Test_Util_GenericListviewDml test class          
    /*******************************************************************************************************
    */

    public  String getSessionIdFromVFPage(PageReference visualforcePage){
        return Loyalty_Util_GenericListviewDml.getSessionIdFromVFPage(visualforcePage);
    }



    public  MetadataService.MetadataPort createMetadataService(){
    return Loyalty_Util_GenericListviewDml.createMetadataService();
    }


    public  List<String> getListviewsLabels(String ObjectType){
        return Loyalty_Util_GenericListviewDml.getListviewsLabels(ObjectType);
    }

 
    public  String createListview(String ObjectType, String DeveloperName, String Name, 
    String filterScope, String [] columns, String [] filters){
        Loyalty_Util_GenericListviewDml.createListview(ObjectType, DeveloperName, Name, filterScope, columns, filters);
        return 'Success';
    }


    public  String deleteListView(String ObjectType, String DeveloperName){
        Loyalty_Util_GenericListviewDml.deleteListView(ObjectType, DeveloperName);
        return 'Success';
    }


    public  String[] getListviewColumns(String ObjectType, String DeveloperName){
        return Loyalty_Util_GenericListviewDml.getListviewColumns(ObjectType, DeveloperName);
    }
        
    
    public  MetadataService.ListViewFilter[] getListviewFilters(String ObjectType, String DeveloperName){
        return Loyalty_Util_GenericListviewDml.getListviewFilters(ObjectType, DeveloperName);
    }


    public  String editListViewName(String ObjectType, String DeveloperName, String Name){
        Loyalty_Util_GenericListviewDml.editListViewName(ObjectType, DeveloperName, Name);
        return 'Success';
    }


    public  String editListViewSharingSettings(String ObjectType, String DeveloperName, String [] sharedToArray, 
    String onlyMe, String allUsers ){
        Loyalty_Util_GenericListviewDml.editListViewSharingSettings(ObjectType, DeveloperName, sharedToArray, onlyMe, allUsers);
        return 'Success';
    }

   
    public  String editListViewFilters(String ObjectType, String DeveloperName, String [] filters){
        return Loyalty_Util_GenericListviewDml.editListViewFilters(ObjectType, DeveloperName, filters);
    }

         
    
    public  String editListViewFields(String ObjectType, String DeveloperName, String [] columns){
        Loyalty_Util_GenericListviewDml.editListViewFields(ObjectType, DeveloperName, columns);
        return 'Success';
    }


    public  String handleSaveResults(MetadataService.SaveResult saveResult){
        Loyalty_Util_GenericListviewDml.handleSaveResults(saveResult);  
        return 'Success';
    }

    
    public  String handleDeleteResults(MetadataService.DeleteResult deleteResult){
        Loyalty_Util_GenericListviewDml.handleDeleteResults(deleteResult);
        return 'Success';
    }

}

