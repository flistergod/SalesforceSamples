global class SWAN_UpdateMeterLevelBatch implements Database.Batchable<sObject>, database.Stateful {
    String masterQuoteId = '';
    //String fullJson = '';
    Map<string,object> fullJson;
    Boolean isException = false;
    global string MasterQuoteStatus;
    String fuelType = '';
   
     global SWAN_UpdateMeterLevelBatch(string masterQuoteId, Map<string,object> fullJson, boolean isException, string fuelType) {
         this.masterQuoteId = masterQuoteId;
         this.fullJson = fullJson;
         this.isException = isException;
         this.MasterQuoteStatus='';
         this.fuelType = fuelType;
     }
     
     global Database.QueryLocator start(Database.BatchableContext BC) {
         String query='SELECT id,status,vlocity_cmt__ParentQuoteId__c,vlocity_cmt__ParentQuoteId__r.status, vlocity_cmt__ParentQuoteId__r.SWAN_Quote_Type__c, vlocity_cmt__DefaultServicePointId__c,SWAN_Contract_Volume_KWh__c,SWAN_Contract_Spend__c,SWAN_Broker_Commission__c,SWAN_Annual_Spend__c, vlocity_cmt__DefaultServicePointId__r.vlocity_cmt__ServicePointNumber__c, '+
                      '(select Id,QuoteId, SWAN_UnitRate__c, vlocity_cmt__RecurringCharge__c,Product2.Name, Product2.ProductCode FROM '+
                      'QuoteLineItems) FROM Quote WHERE vlocity_cmt__ParentQuoteId__c=\''+MasterQuoteId+'\' AND Recordtype.DeveloperName !=\'GroupCart\' AND vlocity_cmt__QuoteGroupId__r.vlocity_cmt__MemberType__c!=\'Business_Account\'';
         return Database.getQueryLocator(query);
     }
     
     global void execute(Database.BatchableContext BC, List<Quote> quoteList){
         if(!isException) {
             try {
                 Map<string,object>CompactMap=new map<string,object>();
                 for(quote cq : quoteList){
                     if(fullJson.containskey(cq.vlocity_cmt__DefaultServicePointId__r.vlocity_cmt__ServicePointNumber__c)!=null)
                         CompactMap.put(cq.vlocity_cmt__DefaultServicePointId__r.vlocity_cmt__ServicePointNumber__c,fullJson.get(cq.vlocity_cmt__DefaultServicePointId__r.vlocity_cmt__ServicePointNumber__c));    
                 }
                 String currentstatus = '';
                 if(fuelType == 'Elec')
                     currentstatus = AWSS3csvFileReader1.processElecMeterLevelData(quoteList,JSON.serializePretty(CompactMap),true);
                 else
                     currentstatus = AWSS3csvFileReader1.processMeterLevelData(quoteList,JSON.serializePretty(CompactMap),true);
                 //system.debug('currentstatusssssssss '+currentstatus );
                 if(currentstatus!=null && currentstatus!='' && MasterQuoteStatus!='Failed Pricing')MasterQuoteStatus=currentstatus;
                 //system.debug('MasterQuoteStatus '+MasterQuoteStatus);
             } catch(Exception ex) {
                 MasterQuoteStatus='Failed Pricing';
                 //system.debug('Exception ::'+ex.getmessage());
                 for(Quote qt:quoteList)
                    qt.Status = 'Failed Pricing';
                 update quoteList;
             }
         }
         else {
             MasterQuoteStatus='Failed Pricing';
             for(Quote qt:quoteList)
                qt.Status = 'Failed Pricing';
             update quoteList;
         }
     }
     
     global void finish(Database.BatchableContext BC){
         
         if(string.ISNOTblank(MasterQuoteStatus))
             update new Quote(Id=masterQuoteId, Status = MasterQuoteStatus);    
     }
}