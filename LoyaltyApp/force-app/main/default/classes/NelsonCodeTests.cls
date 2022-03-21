public class NelsonCodeTests {
    
     @AuraEnabled 
    public static void listListViews(){
        
         MetadataService.MetadataPort metadataservice = new MetadataService.MetadataPort();
	metadataservice.SessionHeader = new MetadataService.SessionHeader_element();
	metadataservice.SessionHeader.sessionId = UserInfo.getSessionId();
        
        List<MetadataService.ListMetadataQuery> queries = new List<MetadataService.ListMetadataQuery>();
        MetadataService.ListMetadataQuery listView = new MetadataService.ListMetadataQuery();
        listView.type_x = 'ListView';
        queries.add(listView);
        MetadataService.FileProperties[] fileProperties = metadataservice.listMetadata(queries, 25);
        for(MetadataService.FileProperties fileProperty : fileProperties)
            System.debug(fileProperty.fullName + 'fff '+fileProperty.fileName + 'fff '+ fileProperty.type_x);
        
    }
    
    public static void listListViews_simpleQury(){
        List<ListView> listview_labels= new List<ListView>();
        listview_labels=[SELECT Name FROM ListView WHERE SObjectType = 'Loyalty_Reward_Value__c'];
           List<String> listview_labels2= new List<String>();
        
        for(ListView o: listview_labels){
            listview_labels2.add(o.Name);
        }
        System.debug(listview_labels2);
        
    }
    
    
    
    @AuraEnabled
    public static void getListviewColumns(String objecttype, String devname){
        MetadataService.MetadataPort metadataservice = new MetadataService.MetadataPort();
	metadataservice.SessionHeader = new MetadataService.SessionHeader_element();
	metadataservice.SessionHeader.sessionId = UserInfo.getSessionId();
        
             // Read List View definition
        MetadataService.ListView listView =
            (MetadataService.ListView) metadataservice.readMetadata('ListView',
                new String[] { objecttype+'.'+devname }).getRecords()[0];
        if(listView.columns!=null)
            for(String column : listView.columns)
                System.debug('Column ' + column);
        if(listView.filters!=null)
            for(MetadataService.ListViewFilter filter : listView.filters)
                System.debug('Filter ' + filter.field + ' ' + filter.operation + ' ' + filter.value);
        
        
    }
    
    @AuraEnabled
    public static void createListview(){
        
        MetadataService.MetadataPort metadataservice = new MetadataService.MetadataPort();
	metadataservice.SessionHeader = new MetadataService.SessionHeader_element();
	metadataservice.SessionHeader.sessionId = UserInfo.getSessionId();
 
        
    List<MetadataService.ListViewFilter> filterListToAdd = new List<MetadataService.ListViewFilter>();
    MetadataService.ListViewFilter filter = new MetadataService.ListViewFilter();
        MetadataService.ListViewFilter filter2 = new MetadataService.ListViewFilter();
	MetadataService.ListView listView = new MetadataService.ListView();
	listView.fullName = 'Loyalty_Reward_Value__c.RecentlyViewedRewardValues';
    listView.label = 'Recently Viewed Reward Values';
    listView.filterScope = 'Everything';
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
          'Loyalty_Value__c',
          'Loyalty_Value__c.Active__c',
          'Loyalty_Value__c.Expiration_Date__c',
          'Loyalty_Value__c.Customer_Points__c',
          'Loyalty_Value__c.Is_Points_Used__c',
          'Loyalty_Value__c.Program_Member__c'

            };
       
    filter.field = 'UPDATEDBY_USER.ALIAS'; 
	filter.operation = 'equals';
	filter.value = 'jalmeida';
    filterListToAdd.add(filter);
        
    
        
   listView.filters= filterListToAdd;

    List<MetadataService.SaveResult> results =
            metadataservice.createMetadata(
                new MetadataService.Metadata[] { listView });
        handleSaveResults(results[0]);

}
    
     public static void deleteListView()
    {
      //  MetadataService.MetadataPort service = createService();
         MetadataService.MetadataPort metadataservice = new MetadataService.MetadataPort();
	metadataservice.SessionHeader = new MetadataService.SessionHeader_element();
	metadataservice.SessionHeader.sessionId = UserInfo.getSessionId();
        
        List<MetadataService.DeleteResult> results =
            metadataservice.deleteMetadata(
                'ListView', new String[] {  'Loyalty_Reward_Value__c.RecentlyViewedAccounts' });
        handleDeleteResults(results[0]);
    }
    
    
    public static void editListViewName(String Objecttype, String developerName){


         
	MetadataService.MetadataPort metadataservice = new MetadataService.MetadataPort();
	metadataservice.SessionHeader = new MetadataService.SessionHeader_element();
	metadataservice.SessionHeader.sessionId = UserInfo.getSessionId();
            
                 // Read List View definition
            MetadataService.ListView listView =
                (MetadataService.ListView) metadataservice.readMetadata('ListView',
                    new String[] { Objecttype+'.'+developerName}).getRecords()[0];
           
                    if(listView.columns!=null){
                        System.debug('boas');
						 listView.columns = new List<String> {
        //you can only go fields of the object, not fields of lookup field
       
          'NAME',
          'CREATEDBY_USER.ALIAS',
          'CREATED_DATE',
          'UPDATEDBY_USER.ALIAS',
          'LAST_UPDATE',
          'Is_Delivered__c',
          'Reward_Type__c',
          'Loyalty_Reward_Value_Code__c'
         
        
         

            };

						
                        List<MetadataService.SaveResult> results =
                         metadataservice.updateMetadata(
                        new MetadataService.Metadata[] { listView });
                        handleSaveResults(results[0]);

                    }
                    else{
                        //throw new MetadataServiceException('label of listView not defined');
                        System.debug('cant edit');
                    }


        }

    
   
	@AuraEnabled
    public static void handleSaveResults(MetadataService.SaveResult saveResult)
    {
        // Nothing to see?
        if(saveResult==null || saveResult.success)
            return;
        // Construct error message and throw an exception
        if(saveResult.errors!=null)
        {
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
                System.debug(String.join(messages, ' '));
                //throw new MetadataServiceException(String.join(messages, ' '));
        }
        if(!saveResult.success)
            System.debug('Request failed with no specified error.');
           // throw new MetadataServiceException('Request failed with no specified error.');
    }

 public static void handleDeleteResults(MetadataService.DeleteResult deleteResult)
    {
        // Nothing to see?
        if(deleteResult==null || deleteResult.success)
            return;
        // Construct error message and throw an exception
        if(deleteResult.errors!=null)
        {
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
                  System.debug(String.join(messages, ' '));
                //throw new MetadataServiceException(String.join(messages, ' '));
        }
        if(!deleteResult.success)
             System.debug('Request failed with no specified error.');
           // throw new MetadataServiceException('Request failed with no specified error.');
    }
    
    @AuraEnabled
    public static MetadataService.MetadataPort createMetadataService(){

    MetadataService.MetadataPort metadataservice = new MetadataService.MetadataPort();
	metadataservice.SessionHeader = new MetadataService.SessionHeader_element();
    metadataservice.SessionHeader.sessionId = UserInfo.getSessionId();
    return metadataservice;
    
    }
    
     @AuraEnabled
        public static String editistViewFilters(String ObjectType, String DeveloperName, String [] filters){

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
  

    
}