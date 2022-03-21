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
public interface Loyalty_I_GenericListviewDml {
    

    String getSessionIdFromVFPage(PageReference visualforcePage);
    MetadataService.MetadataPort createMetadataService();
    List<String> getListviewsLabels(String ObjectType);
    void createListview(String ObjectType, String DeveloperName, String Name, 
    String filterScope, String [] columns, String [] filters);
        
    void deleteListView(String ObjectType, String DeveloperName);
    String[] getListviewColumns(String ObjectType, String DeveloperName);
    MetadataService.ListViewFilter[] getListviewFilters(String ObjectType, 
    String DeveloperName);
     
    void editListViewName(String ObjectType, String DeveloperName, String Name);
    void editListViewSharingSettings(String ObjectType, String DeveloperName, 
    String [] sharedToArray, String onlyMe, String allUsers );
        
    String editListViewFilters(String ObjectType, String DeveloperName, 
    String [] filters);

    void editListViewFields(String ObjectType, String DeveloperName, 
    String [] columns);

    void handleSaveResults(MetadataService.SaveResult saveResult);
    void handleDeleteResults(MetadataService.DeleteResult deleteResult);
}