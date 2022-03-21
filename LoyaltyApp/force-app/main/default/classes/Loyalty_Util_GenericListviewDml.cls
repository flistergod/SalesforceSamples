/*
* @author Nelson Andrade
* @CreatedDate 2021
*
* @group Generics
* @group-content 
*
* @description Generic DML class for CRUD operations on ListViews
*/
public with sharing class Loyalty_Util_GenericListviewDml   implements Loyalty_I_GenericListviewDml{
    public class MetaDataServiceException extends Exception {}

    public Loyalty_Util_GenericListviewDml() {}

    /*******************************************************************************************************
    * @description Metadata Service needs a session Id. We use a visualforce page to get that Id
      @param1 visualforce page unique url
      returns the session Id.  
    */

    public static String getSessionIdFromVFPage(PageReference visualforcePage){
        String content = visualforcePage.getContent().toString();
        Integer s = content.indexOf('Start_Of_Session_Id') + 'Start_Of_Session_Id'.length(),
                e = content.indexOf('End_Of_Session_Id');
        return content.substring(s, e);
    }


    /*******************************************************************************************************
    * @description To make crud operations with Listview, we need to inicialize a metaDataService
    object.
    */

    @AuraEnabled
    public static MetadataService.MetadataPort createMetadataService(){

    MetadataService.MetadataPort metadataservice = new MetadataService.MetadataPort();
    metadataservice.SessionHeader = new MetadataService.SessionHeader_element();
    Pagereference pageref = new Pagereference('/apex/Loyalty_VFP_GetSessionId');
    metadataservice.SessionHeader.sessionId = getSessionIdFromVFPage(pageref);
    return metadataservice;
    
    }

    /*******************************************************************************************************
    * @description Returns every Name of listviews of a given object type
      @param ObjectType type of object of the listview 
    */

    @AuraEnabled
    public static List<String> getListviewsLabels(String ObjectType){

      
            List<ListView> listviews= new List<ListView>();
            List<String> listviews_labels= new List<String>();
            listviews=[SELECT Name, DeveloperName FROM ListView WHERE SObjectType =:ObjectType];
           
            for(ListView listview: listviews){
                listviews_labels.add(listview.Name+'.'+listview.DeveloperName);
            }

            return listviews_labels;
    }

    /*******************************************************************************************************
    * @description Creates a listivew of a given Object Type
    * @param ObjectType the object to look up
    * @param DeveloperName the API name to give to the listview
    * @param Name the name to give to the listview
    * @param filterScope the filtering criteria for the records
    * @param columns  list of fields in the list view
    * @param filters the list of filter line items.
    */

    @AuraEnabled
    public static void createListview(String ObjectType, String DeveloperName, String Name, String filterScope, String [] columns, String [] filters){
        
    MetadataService.MetadataPort metadataservice = createMetadataService();
    List<MetadataService.ListViewFilter> filterListToAdd = new List<MetadataService.ListViewFilter>();
    MetadataService.ListViewFilter filter = new MetadataService.ListViewFilter();
    MetadataService.ListView listView = new MetadataService.ListView();
    List<String> filter_properties=new List<String>();
    
	listView.fullName = ObjectType+'.'+DeveloperName;
    listView.label = Name;
    if(filterScope==null){
    listView.filterScope = 'Everything';
    }
    else{
        listView.filterScope=filterScope;
    }
    
    if(columns!=null){
        listView.columns = columns;
    }
    else{
        listView.columns = new List<String> {
            //you can only go to second degree of lookup
           
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
    }
    

    if(filters!=null){

    for(String str: filters){

        filter_properties=str.split(' ');
        filter.field = filter_properties[0]; 
	    filter.operation = filter_properties[1];
	    filter.value = filter_properties[2];
        filterListToAdd.add(filter);

    }

    listView.filters= filterListToAdd;
}

    List<MetadataService.SaveResult> results =
            metadataservice.createMetadata(
                new MetadataService.Metadata[] { listView });
        handleSaveResults(results[0]);

}

/*******************************************************************************************************
    * @description Deletes a listiview giving her object type and her api name
    * @param ObjectType the object to look up
    * @param DeveloperName the API name given to the listview
    */
@AuraEnabled
public static void deleteListView(String ObjectType, String DeveloperName){
      
    MetadataService.MetadataPort metadataservice = createMetadataService();
         
        
        List<MetadataService.DeleteResult> results =
            metadataservice.deleteMetadata(
                'ListView', new String[] {ObjectType+'.'+DeveloperName});
        handleDeleteResults(results[0]);
    }


    /*******************************************************************************************************
    * @description returns the column fields of the listview
    * @param ObjectType the object to look up
    * @param DeveloperName the API name to give to the listview
    */
    @AuraEnabled
    public static String[] getListviewColumns(String ObjectType, String DeveloperName){
     
    String [] columns;
    MetadataService.MetadataPort metadataservice = createMetadataService();
        
        MetadataService.ListView listView =
            (MetadataService.ListView) metadataservice.readMetadata('ListView',
                new String[] { ObjectType+'.'+DeveloperName}).getRecords()[0];
       
                if(listView.columns!=null){
            columns= listView.columns;
        }

        List<Integer>positions = new List<Integer>(); 
        
        for(integer i=0;i<columns.size();i++){

            columns[i]= columns[i].substring(0,1).toUpperCase()+columns[i].substring(1,columns[i].length()).toLowerCase();
           

            for(Integer j=0;j<columns[i].length();j++){

                if(columns[i].substring(j,j+1)=='.'){
               
                    positions.add(j+1);
                }
                if(columns[i].substring(j,j+1)=='_' && 
                columns[i].substring(j+1,j+2)=='_' && columns[i].substring(j+2,j+3)=='c'  ){
               
                    break;
                }
                else if(columns[i].substring(j,j+1)=='_'){positions.add(j+1);}
                
            }


            for(Integer j=0;j<positions.size();j++){
              
                columns[i]= columns[i].left(positions[j])+columns[i].substring(positions[j],positions[j]+1).toUpperCase()+
                columns[i].right(columns[i].length()-positions[j]-1);
         
            }
            positions.clear(); 

            if(columns[i].contains('.')){
                
                columns[i]= columns[i].replace('.','');
            }
            
        }

      return columns;
    }
        
    

    /*******************************************************************************************************
    * @description gets the filters of  a listivew of a given Object Type
    * @param ObjectType the object to look up
    * @param DeveloperName the API name to give to the listview
    */
    @AuraEnabled
    public static MetadataService.ListViewFilter[] getListviewFilters(String ObjectType, String DeveloperName){
     
        MetadataService.ListViewFilter [] filtersArray;
        MetadataService.MetadataPort metadataservice = createMetadataService();
            
            MetadataService.ListView listView =
                (MetadataService.ListView) metadataservice.readMetadata('ListView',
                    new String[] { ObjectType+'.'+DeveloperName}).getRecords()[0];
           
                    if(listView.filters!=null){
                        filtersArray= listView.filters;
                    }

          return filtersArray;
            
        }


        /*******************************************************************************************************
    * @description edits the Name of  a listivew of a given Object Type
    * @param ObjectType the object to look up
    * @param DeveloperName the API name to give to the listview
     @param Name the new Name of the Listview
    */
        @AuraEnabled
    public static void editListViewName(String ObjectType, String DeveloperName, String Name){

        MetadataService.MetadataPort metadataservice = createMetadataService();
            
            MetadataService.ListView listView =
                (MetadataService.ListView) metadataservice.readMetadata('ListView',
                    new String[] { ObjectType+'.'+DeveloperName}).getRecords()[0];
           
                    if(listView.label!=null){
                        listView.label=Name;

                        List<MetadataService.SaveResult> results =
                         metadataservice.updateMetadata(
                        new MetadataService.Metadata[] { listView });
                        handleSaveResults(results[0]);

                    }
                    else{
                        throw new MetadataServiceException('label of listView not defined');
                    }
        }


           /*******************************************************************************************************
    * @description edits the Sharing properties of  a listivew of a given Object Type. (incomplete)
    * @param ObjectType the object to look up
    * @param DeveloperName the API name to give to the listview
      @param sharedToArray specific groups of users and roles to share the listview with
      @param onlyMe property to make the listview only accessable tot the owner of the listview
      @param allUsers all groups of users and roles to share the listview with
    */

        @AuraEnabled
        public static void editListViewSharingSettings(String ObjectType, 
        String DeveloperName, String [] sharedToArray, String onlyMe, String allUsers ){
        
        /*
            MetadataService.ListView listView =
            (MetadataService.ListView) metadataservice.readMetadata('ListView',
                new String[] { ObjectType+'.'+DeveloperName}).getRecords()[0];
       
               
                    if(allUsers!=null && sharedToArray.size()==0 && onlyMe==null){
                        listview.sharedTo = null;
                    }
                   
                    else if(allUsers==null && sharedToArray.size()!=0 && onlyMe==null){

                        /*
                        listview.sharedTo = new SharedTo(
                            role = null,
                            roles = null,
                            queue = null,
                            groups = null,
                            managers = null,
                            territory = null,
                            groupNames = null,
                            portalRole = null,
                            territories = null,
                            allPartnerUsers = null,
                            allInternalUsers = null,
                            managerSubordinates = null,
                            channelProgramGroup = null,
                            roleAndSubordinates = null,
                            channelProgramGroups = null,
                            rolesAndSubordinates = null,
                            allCustomerPortalUsers = null,
                            territoryAndSubordinates = null,
                            portalRoleAndSubordinates = null,
                            territoriesAndSubordinates = null,
                            roleAndSubordinatesInternal = null
                            );
                            
                    
                    else if(allUsers!=null && sharedToArray.size()==0 && onlyMe==null){listview.sharedTo = null}

                    List<MetadataService.SaveResult> results =
                     metadataservice.updateMetadata(
                    new MetadataService.Metadata[] { listView });
                    handleSaveResults(results[0]);
                    */
        }

       
                /*******************************************************************************************************
    * @description edits the Sharing properties of  a listivew of a given Object Type
    * @param ObjectType the object to look up
    * @param DeveloperName the API name to give to the listview
      @param filters the filters to give to the listview 
    */

        @AuraEnabled
        public static String editListViewFilters(String ObjectType, String DeveloperName, String [] filters){

          
            MetadataService.MetadataPort metadataservice = createMetadataService();
            List<MetadataService.ListViewFilter> filterListToAdd = new List<MetadataService.ListViewFilter>();

            MetadataService.ListView listView =
            (MetadataService.ListView) metadataservice.readMetadata('ListView',
                       new String[] { ObjectType+'.'+DeveloperName}).getRecords()[0];
               

                 if(filters.size()!=0){
                                
                     for(String str: filters){
                            
                        List<String> filter_properties=str.split('-');
 						MetadataService.ListViewFilter filter = new MetadataService.ListViewFilter();                                    
                          
                        filter.field = filter_properties[0]; 
                        filter.operation = filter_properties[1];
                        filter.value = filter_properties[2];
                        filterListToAdd.add(filter);
                         }
                           
                         if(listview.filters!=null){
                             listview.filters.clear();
                             }
                          
                         listView.filters= filterListToAdd; 
                            
                        }
                              
             if(filters.size()==0 && listview.filters!=null){
                   listview.filters.clear();
               }
              
                           
               List<MetadataService.SaveResult> results =metadataservice.updateMetadata(
                           new MetadataService.Metadata[] { listView });
                           handleSaveResults(results[0]);
   
              return 'Success';

        }

         
        /*******************************************************************************************************
    * @description edits the fields (max 15 fields, and some fields names are different from salesforce) 
        of  a listivew of a given Object Type. 
    * @param ObjectType the object to look up
    * @param DeveloperName the API name to give to the listview
      @param columns the filters to give to the listview 
    */


        @AuraEnabled
        public static void editListViewFields(String ObjectType, String DeveloperName, String [] columns){
           

            MetadataService.MetadataPort metadataservice = createMetadataService();
         

            MetadataService.ListView listView = new MetadataService.ListView();
            listView.fullName = 'Loyalty_Reward_Value__c.RecentlyViewedRewardValues';
            listView.label = 'Recently Viewed Reward Values';
            listView.filterScope = 'Everything';


            if(columns.size()!=0){
                listView.columns=columns;
            }
            else{

            listView.columns = new List<String> {
            
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
                }

        
            List<MetadataService.SaveResult> results =
                    metadataservice.createMetadata(
                        new MetadataService.Metadata[] { listView });
                handleSaveResults(results[0]);
        
        }


        
        /*******************************************************************************************************
    * @description verifies if the method action (create or update) was done successfully
    * @param saveResult result of the method action 
    */
        
    @AuraEnabled
    public static void handleSaveResults(MetadataService.SaveResult saveResult){
        
        if(saveResult==null || saveResult.success)
            return;

        if(saveResult.errors!=null){
            List<String> messages = new List<String>();
            
            messages.add(
                (saveResult.errors.size()==1 ? 'Error ' : 'Errors ') +
                    'occured processing component ' + saveResult.fullName + '.');

            for(MetadataService.Error error : saveResult.errors)
                messages.add(
                    error.message + ' (' + error.statusCode + ').' +
                    ( error.fields!=null && error.fields.size()>0 ?
                    ' Fields ' + String.join(error.fields, ',') + '.' : '' ) );
            if(messages.size()>0)
               // System.debug(String.join(messages, ' '));
                throw new MetadataServiceException(String.join(messages, ' '));
        }
        if(!saveResult.success)
           // System.debug('Request failed with no specified error.');
            throw new MetadataServiceException('Request failed with no specified error.');
    }

    
 /*******************************************************************************************************
    * @description verifies if the method action (delete) was done successfully
    * @param deleteResult result of the method action 
    */

@AuraEnabled
 public static void handleDeleteResults(MetadataService.DeleteResult deleteResult){

       if(deleteResult==null || deleteResult.success)
            return;
        // Construct error message and throw an exception
        if(deleteResult.errors!=null){
           
            List<String> messages = new List<String>();
           
            messages.add(
                (deleteResult.errors.size()==1 ? 'Error ' : 'Errors ') +
                'occured processing component ' + deleteResult.fullName + '.');
            for(MetadataService.Error error : deleteResult.errors)
                messages.add(
                    error.message + ' (' + error.statusCode + ').' +
                    ( error.fields!=null && error.fields.size()>0 ?
                    ' Fields ' + String.join(error.fields, ',') + '.' : '' ) );
            if(messages.size()>0)
                 // System.debug(String.join(messages, ' '));
                throw new MetadataServiceException(String.join(messages, ' '));
        }
        if(!deleteResult.success)
             //System.debug('Request failed with no specified error.');
            throw new MetadataServiceException('Request failed with no specified error.');
    }  


}