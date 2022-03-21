/*
* ClassName - SWAN_QuoteLogicHandler
* Description - Class is being invoked from Quote Apex trigger
*               Functionality:
*               1.  Count all child Quotes and add the count on Master Quote(Method : calculateNumberOfSites)
*               2.  Check pricing flag on all Master Quotes added in Offer Pack and 
*/
public without sharing class SWAN_QuoteLogicHandler {
    
    /*
    * Method Name - calculateNumberOfSites
    * Description - Count all child Quotes and add the count on Master Quote. Executes on After Insert, After Update , After Delete trigger events.
    */
    public static void calculateNumberOfSites()
    {
        
        Set<Id> setParentQuoteId = new Set<Id>();   
        //  Get all Quote Ids for Insert and Update trigger from Trigger.new
        if(Trigger.isInsert)
        {
            system.debug('Quote list '+(list<Quote>)Trigger.new);
            
            for(Quote quo : (list<Quote>)Trigger.new) 
            {
                system.debug('quote '+quo);
                system.debug('quote Parent '+quo.vlocity_cmt__ParentQuoteId__c+' '+quo.RecordType.DeveloperName);
                if(quo.vlocity_cmt__ParentQuoteId__c != null )
                {
                    setParentQuoteId.add(quo.vlocity_cmt__ParentQuoteId__c);
                }
            }
        }
        
        //  Get all Quote Ids for Delete trigger from Trigger.old
        if(Trigger.isDelete)
        {
            for(Quote quo_Old : (list<Quote>)Trigger.old)
            {
                if(quo_Old.vlocity_cmt__ParentQuoteId__c!=null )
                {
                    setParentQuoteId.add(quo_Old.vlocity_cmt__ParentQuoteId__c);
                }
            }
        }
        system.debug('setParentQuoteId '+setParentQuoteId);
        
        Map<Id,Double> mapChildQuoteCount = new Map<Id,Double>();
        String loggedInUserId = UserInfo.getUserId();
        List<Task> tskList = new List<Task>();
        List<Quote> grpQtList = new List<Quote>();
        // Get all count of child quotes under the master quote
        if(!setParentQuoteId.isEmpty())
        {
            for(AggregateResult agg: [Select vlocity_cmt__ParentQuoteId__c, COUNT(id) from Quote where (vlocity_cmt__ParentQuoteId__c IN : setParentQuoteId AND Recordtype.DeveloperName != 'GroupCart' AND vlocity_cmt__QuoteGroupId__r.vlocity_cmt__MemberType__c != 'Business_Account' ) group by vlocity_cmt__ParentQuoteId__c ])
            {
                system.debug(agg);
                mapChildQuoteCount.put((Id)agg.get('vlocity_cmt__ParentQuoteId__c'),(Double)agg.get('expr0'));
            }
            system.debug('mapChildQuoteCount ' +mapChildQuoteCount);
            
            // Get all master Quotes to update the count
            List<Quote> listParentQuotesToUpdate = new List<Quote>();
            for(Quote quo : [Select Id, vlocity_cmt__ExternalPricingStatus__c, QuoteNumber, vlocity_cmt__ParentQuoteId__c, SWAN_Number_of_Service_Points__c, SWAN_Total_Service_Points__c,(Select id, vlocity_cmt__ExternalPricingStatus__c from vlocity_cmt__Quotes__r where recordType.DeveloperName = 'GroupCart') from Quote where Id IN :setParentQuoteId ])
            {
                Double numberOfChildQuotes = mapChildQuoteCount.get(quo.Id);
                if(trigger.isInsert && quo.SWAN_Total_Service_Points__c != null && quo.SWAN_Total_Service_Points__c >0 && quo.SWAN_Number_of_Service_Points__c!=numberOfChildQuotes && quo.SWAN_Total_Service_Points__c == numberOfChildQuotes)
                {
                    Task notify = new Task(OwnerId = loggedInUserId, Subject = 'Quote Created / Cloned / Amended Successfully', Status = 'Open', Priority = 'High', WhatId = quo.Id, ActivityDate=date.today(), Description='Quote #'+ quo.QuoteNumber + ' has been created / cloned /  amended successfully', IsReminderSet=true, ReminderDateTime=system.now().addSeconds(5));
                    tskList.add(notify);
                    
                    /*if(quo.vlocity_cmt__ExternalPricingStatus__c != 'Ready')
                        quo.vlocity_cmt__ExternalPricingStatus__c = 'Ready';
                    
                    if(quo.vlocity_cmt__Quotes__r != null && quo.vlocity_cmt__Quotes__r.size()>0)
                    {
                        for(Quote grpQt:quo.vlocity_cmt__Quotes__r)
                        {
                            if(grpQt.vlocity_cmt__ExternalPricingStatus__c != 'Ready')
                            {
                                grpQt.vlocity_cmt__ExternalPricingStatus__c = 'Ready';
                                grpQtList.add(grpQt);
                            }
                        }
                    }*/
                }

                if(quo.vlocity_cmt__ExternalPricingStatus__c=='Holding Status'){
                    quo.vlocity_cmt__ExternalPricingStatus__c='Not Ready';    
                }

                quo.SWAN_Number_of_Service_Points__c = numberOfChildQuotes ;
                listParentQuotesToUpdate.add(quo);
            }
            system.debug('===='+listParentQuotesToUpdate);
            if(tskList.size()>0)
                insert tskList;
            //update group quotes
            //if(grpQtList != null && grpQtList.size() > 0)
            //    update grpQtList;
                
            // update parent quote record
            if(listParentQuotesToUpdate !=null && listParentQuotesToUpdate.size()>0)
            {
             //   SWAN_Constants.QuoteTriggerExecuted = true;
                try
                {
                    if (Schema.sObjectType.Quote.isUpdateable()) {
                        update listParentQuotesToUpdate ;
                    }  
                }
                catch (Exception e)
                {
                    system.debug(e);
                }
            }
        }
    }

    /*
    *Method Name - pricingStatusUpdateOnOfferPack
    *Developer Name - Rushikesh Patil
    *Description - To update Offer pack with pricing status after reassessment
    */
    public static void pricingStatusUpdateOnOfferPack()
    {
        
        Set<Id> setOfferPackId = new Set<Id>();  
        Set<Id> setQuoteId = new Set<Id>();
        List<SWAN_Offer_Pack__c> offerPackList = new List<SWAN_Offer_Pack__c>();
        Boolean offerpackHasError = false;
        
        // get all quotes where Price Assessment flag is changed
        if(Trigger.isUpdate)
        {
            system.debug('Quote list '+(list<Quote>)Trigger.new);
            for(Quote quo : (list<Quote>)Trigger.new) 
            {
                Quote oldQuote = (Quote)trigger.oldmap.get(quo.id);
                if(oldQuote.SWAN_Price_out_of_Date__c != quo.SWAN_Price_out_of_Date__c)
                {
                    system.debug('quote '+quo);
                    setQuoteId.add(quo.Id);
                }
            }
        }
        
        // get all deleted quotes
        if(Trigger.isDelete)
        {
            for(Quote quo_Old : (list<Quote>)Trigger.old)
            {
                system.debug('quote '+quo_Old);
                setQuoteId.add(quo_Old.Id);
            }
        }
        
        if(!setQuoteId.isEmpty())
        {
            List<SWAN_Offer_Pack_Quote__c> listOfferPackQuote = new List<SWAN_Offer_Pack_Quote__c> ([SELECT id,SWAN_Offer_Pack__c,SWAN_Quote__c FROM SWAN_Offer_Pack_Quote__c WHERE SWAN_Quote__c IN:setQuoteId]);
            system.debug('listOfferPackQuote '+listOfferPackQuote);
            
            for(SWAN_Offer_Pack_Quote__c offerPackQuote : listOfferPackQuote)
            {
                setOfferPackId.add(offerPackQuote.SWAN_Offer_Pack__c);
            }
            
            // Fetch all offer Packs with all Offer pack Quotes under it
            for(SWAN_Offer_Pack__c offerPack :[SELECT Id,SWAN_Price_Valid__c,(SELECT id,SWAN_Quote__r.SWAN_Price_out_of_Date__c,SWAN_Quote__r.status FROM Offer_Pack_Quotes__r) FROM SWAN_Offer_Pack__c WHERE id IN :setOfferPackId ])
            {
                offerpackHasError = false;
                for(SWAN_Offer_Pack_Quote__c opq:offerPack.Offer_Pack_Quotes__r)
                {
                    if(opq.SWAN_Quote__r.SWAN_Price_out_of_Date__c && opq.SWAN_Quote__r.status != 'Submitted')
                    {
                        offerpackHasError = true;
                        offerPack.SWAN_Price_Valid__c = false;
                        offerPackList.add(offerPack);
                        break;
                    }
                }
                if(!offerpackHasError)
                {
                    offerPack.SWAN_Price_Valid__c = true;
                    offerPackList.add(offerPack);
                }
            }
            if(!offerPackList.isEmpty())
            {
                try
                {
                    if (Schema.sObjectType.SWAN_Offer_Pack__c.fields.SWAN_Price_Valid__c.isUpdateable()) {
                        update offerPackList ;
                    }
                }
                catch (Exception e)
                {
                    system.debug(e);
                }
            }
            
        }
    }
    
    /*
*Method Name - restrictQuoteDelete
*Developer Name - Neha Shaw pal
*Description - To restrict quote deletion(master quote, site addition quote and service point quote that are not submitted/ issued)
*/
    public static void restrictQuoteDelete()
    {  
        Map<Id,List<Quote>> parentChildQuoteMap = new Map<Id,List<Quote>>();
        Id subQuoteRecordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('Sub Quote').getRecordTypeId();
        Id groupCartQuoteRecordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('Group Cart').getRecordTypeId() ;

        set<Quote> parentQuoteSet = new Set<Quote>();
        List<String> statusList = label.QuoteRestrictedStatus.split(',');
        
        for(Quote quo_Old : (list<Quote>)Trigger.old)
        {
            if(quo_Old.recordTypeId != subQuoteRecordTypeId && quo_Old.recordTypeId != groupCartQuoteRecordTypeId ){
                quo_Old.addError(label.MasterQuoteundelete);
            }else{
                
                if(parentChildQuoteMap.containsKey(quo_Old.vlocity_cmt__ParentQuoteId__c)) {
                    List<Quote> tempList = parentChildQuoteMap.get(quo_Old.vlocity_cmt__ParentQuoteId__c);
                    tempList.add(quo_Old);
                    parentChildQuoteMap.put(quo_Old.vlocity_cmt__ParentQuoteId__c, tempList);
                } else {
                    parentChildQuoteMap.put(quo_Old.vlocity_cmt__ParentQuoteId__c, new List<Quote> { quo_Old });
                }
            }    
        }
        if(parentChildQuoteMap.size() > 0)
        {
            Map<Id, Quote> parentQuoteMap = new Map<Id, Quote>([select id, status, SWAN_Has_been_submitted__c from Quote where id in:parentChildQuoteMap.keyset()]);
            for(Id pId:parentChildQuoteMap.keyset())
            {
                for(Quote qt:parentChildQuoteMap.get(pId))
                {
                    if(parentQuoteMap != null && parentQuoteMap.containsKey(qt.vlocity_cmt__ParentQuoteId__c) && (parentQuoteMap.get(qt.vlocity_cmt__ParentQuoteId__c).SWAN_Has_been_submitted__c || statusList.contains(parentQuoteMap.get(qt.vlocity_cmt__ParentQuoteId__c).status))){
                        System.debug('parentQuoteMap :: ' + label.SiteAdditionQuoteUndelete );
                        qt.addError(label.SiteAdditionQuoteUndelete);
                    }else if(parentQuoteMap != null && parentQuoteMap.containsKey(qt.vlocity_cmt__ParentQuoteId__c) && parentQuoteMap.get(qt.vlocity_cmt__ParentQuoteId__c).status != 'Draft') // Added this check because in case of amend site ddition OS, there is already logic to uppdate status to draft. So to restrict update twice, the check is done.
                    {
                        Quote qt_updt = new Quote(Id=qt.vlocity_cmt__ParentQuoteId__c,status='Draft');
                        parentQuoteSet.add(qt_updt);  
                    }      
                }
            }
        }
        if(parentQuoteSet.size()>0)
        {
            List<Quote> quoteUpdateList = new List<Quote>(parentQuoteSet);
            if(quoteUpdateList != null && quoteUpdateList.size()>0)
                update quoteUpdateList;
        }
    }
    
    /*
* Method Name - generateBCRFile
* Description - generate BCR file for Accepted Site Addition Quote
*/
    public static void generateBCRFile()
    {
        Id recTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByName().get(label.QuoteSiteAdditionRecordType).getRecordTypeId();
        List<Id> quoteIdList = new List<Id>();
        List<Id> accountIdList = new List<Id>();
        //List<Id> userIds = new List<Id>();
        List<String> paymentTermList = new List<String>();
        Map<Id, Id> ownerMap = new Map<Id, Id>();
        Map<Id, String> fileNameMap = new Map<id, String>();
        
        for(Quote qt : (List<Quote>)Trigger.new)
        {
            Quote oldQt = (Quote)Trigger.oldmap.get(qt.id);
            system.debug('==='+qt.Name+'==='+qt.Status+'===='+qt.recordtypeId+'===='+recTypeId);
            if(qt.status == 'Accepted' && qt.status != oldQt.status && qt.recordTypeId==recTypeId)
            {
                quoteIdList.add(qt.id);
                accountIdList.add(qt.vlocity_cmt__OpportunityAccountId__c);
                //userIds.add(qt.OwnerId);
                paymentTermList.add(qt.SWAN_Payment_Term__c.Trim());
                ownerMap.put(qt.id, qt.OwnerId);
                fileNameMap.put(qt.id, 'Site Addition');
            }
        }
        BCR_File_Generation.generateFile(quoteIdList, accountIdList, paymentTermList, ownerMap, fileNameMap,null);
    }
    
    
    /*public static void enableCheckBoxPriceOutOfDate(){
        
        Set<Id> setIds = trigger.newMap.keySet();
        
        List<Contract> lstContract =[SELECT Id, Status,  vlocity_cmt__QuoteId__c FROM Contract  Where vlocity_cmt__QuoteId__c in : trigger.newMap.keySet()  ];
        
        for(Contract con : lstContract){
            
            Quote newQt = (Quote) trigger.newMap.get(con.vlocity_cmt__QuoteId__c);
            Quote oldQt = (Quote) trigger.oldMap.get(con.vlocity_cmt__QuoteId__c);
            
            if(con.Status != 'Reviewed Pricing'  && newQt.SWAN_Price_out_of_Date__c != oldQt.SWAN_Price_out_of_Date__c ){
                
                newQt.addError('Field  "Price out of Date" only available to edit when contract status is "Reviewed Pricing"  ' );
            }
            
        }
    }*/

    public static void priceAndValidateNotif()
    {
        List<Task> tskList = new List<Task>();
        String loggedInUserId = UserInfo.getUserId();
        for(Quote qt : (List<Quote>)Trigger.new)
        {
            if(qt.vlocity_cmt__ParentQuoteId__c == null && qt.vlocity_cmt__ExternalPricingStatus__c != trigger.oldMap.get(qt.Id).get('vlocity_cmt__ExternalPricingStatus__c') && qt.vlocity_cmt__ExternalPricingStatus__c == 'Ready')
            {
                Task notify = new Task(OwnerId = loggedInUserId, Subject = 'Quote Group(s) Validated Successfully', Status = 'Open', Priority = 'High', WhatId = qt.Id, ActivityDate=date.today(), Description='Quote Group(s) against the Quote #'+ qt.QuoteNumber + ' has been validated successfully', IsReminderSet=true, ReminderDateTime=system.now().addSeconds(5));
                tskList.add(notify);
            }    
        }
        if(tskList.size() > 0)
            insert tskList;
    }
    
    public static void beforeInsertMethod()
    {
        Id recordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('SubQuote').getRecordTypeId();
        for(Quote qt : (List<Quote>)Trigger.new)
        {
            if(qt.vlocity_cmt__ParentQuoteId__c != null && qt.vlocity_cmt__DefaultServicePointId__c != null && qt.RecordTypeId == recordTypeId)
            {
                qt.SWAN_Parent_Quote__c = qt.vlocity_cmt__ParentQuoteId__c;
                qt.SWAN_Service_Point__c = qt.vlocity_cmt__DefaultServicePointId__c;
            }    
        }   
    }
    
    /*
    * Method Name - checkValidatedSPs
    * Description -  Check if SPs validation has finished. 
    */
    public static void checkValidatedSPs(){
        
        Set<Id> setParentQuoteId = new Set<Id>();   
        //  Get all Quote Ids for Insert and Update trigger from Trigger.new
        if(Trigger.isUpdate){

            for(Quote quo : (list<Quote>)Trigger.new){
                if(quo.vlocity_cmt__ParentQuoteId__c != null ){
                    setParentQuoteId.add(quo.vlocity_cmt__ParentQuoteId__c);
                }
            }
        }
        
        //  Get all Quote Ids for Delete trigger from Trigger.old
        if(Trigger.isDelete)
        {
            for(Quote quo_Old : (list<Quote>)Trigger.old)
            {
                if(quo_Old.vlocity_cmt__ParentQuoteId__c!=null )
                {
                    setParentQuoteId.add(quo_Old.vlocity_cmt__ParentQuoteId__c);
                }
            }
        }
        
        Map<Id,Double> mapChildQuoteCount = new Map<Id,Double>();
        String loggedInUserId = UserInfo.getUserId();
        List<Task> tskList = new List<Task>();
        List<Quote> grpQtList = new List<Quote>();
        // Get all count of child quotes under the master quote
        if(!setParentQuoteId.isEmpty()){
            
            for(AggregateResult agg: [Select vlocity_cmt__ParentQuoteId__c, COUNT(id) from Quote where (vlocity_cmt__ParentQuoteId__c IN : setParentQuoteId AND Recordtype.DeveloperName != 'GroupCart' AND vlocity_cmt__IsValidated__c = false AND vlocity_cmt__DefaultServicePointId__c != null) group by vlocity_cmt__ParentQuoteId__c ])
            {

                mapChildQuoteCount.put((Id)agg.get('vlocity_cmt__ParentQuoteId__c'),(Double)agg.get('expr0'));
            }
            
            // Get all master Quotes to update the count
            List<Quote> listParentQuotesToUpdate = new List<Quote>();
            for(Quote quo : [Select Id, vlocity_cmt__ExternalPricingStatus__c, QuoteNumber, vlocity_cmt__ParentQuoteId__c, SWAN_Number_of_Service_Points__c, SWAN_Total_Service_Points__c,(Select id, vlocity_cmt__ExternalPricingStatus__c from vlocity_cmt__Quotes__r where recordType.DeveloperName = 'GroupCart') from Quote where Id IN :setParentQuoteId And vlocity_cmt__ExternalPricingStatus__c = 'Holding Status' ])
            {
                Double numberOfChildQuotes = mapChildQuoteCount.get(quo.Id);
                if( quo.SWAN_Total_Service_Points__c != null && quo.SWAN_Total_Service_Points__c >0 && quo.SWAN_Number_of_Service_Points__c == numberOfChildQuotes)
                { 
                    if(quo.SWAN_Total_Service_Points__c == quo.SWAN_Number_of_Service_Points__c){ 
                        Task notify = new Task(OwnerId = loggedInUserId, Subject = 'Quote Created/ Amended Successfully', Status = 'Open', Priority = 'High', WhatId = quo.Id, ActivityDate=date.today(), Description='Quote #'+ quo.QuoteNumber + ' has been created/ amended successfully', IsReminderSet=true, ReminderDateTime=system.now().addSeconds(5));
                        tskList.add(notify);
                    }
                    quo.vlocity_cmt__ExternalPricingStatus__c = 'Not Ready' ;
                    listParentQuotesToUpdate.add(quo);
                }
               
            }
            
            if(tskList.size()>0){
                insert tskList;
            }
            
            // update parent quote record
            if(listParentQuotesToUpdate !=null && listParentQuotesToUpdate.size()>0)
            {
                SWAN_Constants.QuoteTriggerExecuted = true;
                try
                {
                    if (Schema.sObjectType.Quote.isUpdateable()) {
                        update listParentQuotesToUpdate ;
                    }  
                }
                catch (Exception e)
                {
                    system.debug(e);
                }
            }
        }
    }
    
    
        public static void runFlexQuoteValidation2Time(){
            Set<Id> setParentQuoteId = new Set<Id>();   
            //  Get all Quote Ids for Insert and Update trigger from Trigger.new
            if(Trigger.isUpdate){
                
                for(Quote quo : (list<Quote>)Trigger.new){
                    if(quo.vlocity_cmt__ParentQuoteId__c != null ){
                        setParentQuoteId.add(quo.vlocity_cmt__ParentQuoteId__c);
                    }
                }
            }
            
            Map<Id,Double> mapChildQuoteCount = new Map<Id,Double>();
     
            // Get all count of child quotes under the master quote
            if(!setParentQuoteId.isEmpty()){
    
                String recTypeIdMasterQuote = [SELECT Id FROM RecordType WHERE DeveloperName='MasterQuote'].Id;  
                
                // Get all master Quotes to update the count
                List<Quote> listParentQuotesToUpdate = new List<Quote>();
                for(Quote quo : [SELECT Id, 
                                 vlocity_cmt__ExternalPricingStatus__c, 
                                 RecordTypeId,
                                 RecordType.DeveloperName, 
                                 (SELECT id, vlocity_cmt__ExternalPricingStatus__c, vlocity_cmt__IsValidated__c 
                                 FROM vlocity_cmt__Quotes__r 
                                 WHERE (recordType.DeveloperName = 'GroupCart' 
                                       AND vlocity_cmt__IsValidated__c= false ) OR (recordType.DeveloperName = 'SubQuote' 
                                       AND vlocity_cmt__IsValidated__c= false ) limit 1 ) 
                                 FROM Quote where Id IN :setParentQuoteId 
                                 AND vlocity_cmt__ExternalPricingStatus__c = 'Not Ready' 
                                 AND (Recordtype.DeveloperName  = 'MasterQuote' OR Recordtype.DeveloperName  = 'Site_Addition_Quote' ) ]){

                    //system.debug('+++' + quo.id + ' === ' + quo.vlocity_cmt__Quotes__r.size() + ' === ' + quo.vlocity_cmt__ExternalPricingStatus__c);
                     
                    
                    if(quo.vlocity_cmt__Quotes__r.size() == 0 && quo.vlocity_cmt__ExternalPricingStatus__c == 'Not Ready' ){      

                        quo.vlocity_cmt__ExternalPricingStatus__c = 'Ready';
                        quo.vlocity_cmt__ValidationStatus__c = 'Passed';
                        listParentQuotesToUpdate.add(quo);
                        /***********************************
                         * Due to the validate and price not completing bug 8078 was raised. 
                         * This requires commenting out the following statements. 
                         * Possibly will be reverted back in a later date.
                         ***********************************/
                        /* Initialize variables */
                        /*String procedureName = 'MultiService_ValidateAndUpdateExternalPricingStatusCustom';
                        Map <String, Object> ipInput = new Map <String, Object> ();
                        Map <String, Object> ipOutput = new Map <String, Object> ();*/

                        /* Populating input map for an Integration Procedure. Follow whatever structure your VIP expects */
                        /*ipInput.put('ContextId', quo.Id);
                        ipInput.put('RecordTypeIdSAQ', quo.RecordTypeId);
                        ipInput.put('RecordTypeDeveloperName', quo.RecordType.DeveloperName);
                        ipInput.put('RecordTypeIdMA', recTypeIdMasterQuote);
                        
                        system.debug('ipInput +++ ' + ipInput);*/
                        
                        /* Call the IP via runIntegrationService, and save the output to ipOutput */
                        //ipOutput = (Map <String, Object>) vlocity_cmt.IntegrationProcedureService.runIntegrationService(procedureName, ipInput, new Map<String, Object>());
                        
                        //system.debug('ipOutput +++ ' + ipOutput);
                        /*End of workaround comment out for bug 8078 */
                    }
                }
                update listParentQuotesToUpdate;
            }
        }

        public static boolean isCloned=false;
        public static void cloneQLIForCarbonQuote()
        {
            if(!isCloned || test.isRunningTest()) 
            {
                Set<Id> quoteIds = new Set<id>();
                Set<Id> originalQIds = new Set<id>();
                //Map<Id, List<QuoteLinetem>> qMap = new Map<Id, List<QuoteLineItem>>();
                Map<String, String> quoteSPMap = new Map<String, String>();
                Map<String, String> originalQuoteSPMap = new Map<String, String>();
                Map<String, String> quoteMap = new Map<String,String>();
                
                for(Quote quo : (list<Quote>)Trigger.new)
                {
                    Quote oldQuote = (Quote)trigger.oldmap.get(quo.id);
                    //system.debug(quo.id+'==='+quo.Swan_Original_Quote__c+'====='+oldQuote.SWAN_Number_of_Service_Points__c+'===='+quo.SWAN_Number_of_Service_Points__c+'===='+quo.SWAN_Total_Service_Points__c);
                    if(quo.Swan_Original_Quote__c != null && oldQuote.SWAN_Number_of_Service_Points__c != quo.SWAN_Number_of_Service_Points__c && quo.SWAN_Number_of_Service_Points__c == quo.SWAN_Total_Service_Points__c)
                    {
                        quoteIds.add(quo.Id);
                        originalQIds.add(quo.Swan_Original_Quote__c);
                        quoteMap.put(quo.Swan_Original_Quote__c,quo.Id);
                    }
                }
                if(quoteIds.size()>0)
                {
                    for(Quote qt:[Select id, SWAN_Business_Account__c, vlocity_cmt__QuoteGroupId__c, vlocity_cmt__QuoteGroupId__r.Name, vlocity_cmt__DefaultServicePointId__c, vlocity_cmt__ParentQuoteId__c From Quote where vlocity_cmt__ParentQuoteId__c IN:quoteIds OR vlocity_cmt__ParentQuoteId__c IN:originalQIds])
                    {
                        if(quoteIds.contains(qt.vlocity_cmt__ParentQuoteId__c))
                        {
                            if(qt.vlocity_cmt__DefaultServicePointId__c != null)
                                quoteSPMap.put(qt.vlocity_cmt__DefaultServicePointId__c,qt.Id);
                            else if(qt.SWAN_Business_Account__c != null)
                                quoteSPMap.put(qt.SWAN_Business_Account__c,qt.Id);
                            else if(qt.vlocity_cmt__QuoteGroupId__c != null)
                                quoteSPMap.put(qt.vlocity_cmt__QuoteGroupId__r.Name,qt.Id);
                        }
                        else
                        {
                            if(qt.vlocity_cmt__DefaultServicePointId__c != null)
                                originalQuoteSPMap.put(qt.vlocity_cmt__DefaultServicePointId__c,qt.Id);
                            else if(qt.SWAN_Business_Account__c != null)
                                originalQuoteSPMap.put(qt.SWAN_Business_Account__c,qt.Id);
                            else if(qt.vlocity_cmt__QuoteGroupId__c != null)
                                originalQuoteSPMap.put(qt.vlocity_cmt__QuoteGroupId__r.Name,qt.Id);
                        }
                    }
                    for(String tempId:quoteSPMap.keyset())
                    {
                        if(originalQuoteSPMap.containsKey(tempId))
                        {
                            quoteMap.put(originalQuoteSPMap.get(tempId),quoteSPMap.get(tempId));
                        }
                    }
                } 
                system.debug('====='+quoteMap);
                if(originalQIds.size()>0)
                {
                    
                    Map<String, Schema.SObjectField> QFields = Schema.getGlobalDescribe().get('QuoteLineItem').getDescribe().fields.getMap();
                    List<String> editableQFields = new List<String>();
                    List<sObject> qliList = new List<sObject>();
                    for(Schema.SObjectField fieldRef : QFields.values()) {
                        Schema.DescribeFieldResult fieldResult = fieldRef.getDescribe();
                        if(fieldResult.isCreateable()) {
                            editableQFields.add(fieldResult.getname());
                        }
                    }
                    String querystring ='SELECT ID,';
                    for(string api : editableQFields)
                    {
                        querystring+=api+',';
                    }
                    querystring=querystring.removeendignorecase(',')+' FROM QuoteLineItem WHERE (QuoteId IN:originalQIds OR Quote.vlocity_cmt__ParentQuoteId__c IN:originalQIds) ORDER BY LineNumber'; //Quote.RecordType.DeveloperName = \'SubQuote\' and 
                    //system.debug('==$$$$$$$$$$$$$$$\n'+querystring);
                    List<sObject> sObjList = Database.query(querystring);
                    //system.debug('==>>>>>>>>>>'+sObjList);
                    for(sObject sObj:sObjList)
                    {
                        sObject ClonedsObj = Schema.getGlobalDescribe().get('QuoteLineItem').newSObject();
                        ClonedsObj = sObj.clone(false, false, false, false);
                        String qId = sObj.get('QuoteId').toString();
                        if(quoteMap.containsKey(qId))
                            ClonedsObj.put('QuoteId',quoteMap.get(qId));
                        qliList.add(ClonedsObj);
                    }
                    if(qliList.size() > 0)
                        insert qliList;

                    isCloned=true;
                }/*
                for(Quote quo : (list<Quote>)Trigger.new)
                {
                    if(quoteIds.contains(quo.Id))
                        quo.Status = 'Priced';
                } */
                
            }
        }
        
        
        /*
        * Method Name - cloneChildQuotesForCarbonQuote
        * Description - Clones Carbon Copy Child Quotes as per the child Quotes of Original Quote. Executes on After Update events.
        */
        public static boolean iscarbonchildCloned=false;
        public static void cloneChildQuotesForCarbonQuote()
        {
            if(!iscarbonchildCloned || test.isRunningTest()) 
            {
                System.debug('In cloneChildQuotesForCarbonQuote start');
                Set<Id> quoteIds = new Set<id>();
                Set<Id> originalQIds = new Set<id>();
                Map<String, String> carbonquoteSPMap = new Map<String, String>();
                Map<String, String> og_Quote_SPMap = new Map<String, String>();
                Map<String, String> quoteMap = new Map<String,String>();
                for(Quote quo : (list<Quote>)Trigger.new)
                {
                    Quote oldQuote = (Quote)trigger.oldmap.get(quo.id);
                    if(quo.Swan_Original_Quote__c != null && oldQuote.SWAN_Number_of_Service_Points__c != quo.SWAN_Number_of_Service_Points__c && quo.SWAN_Number_of_Service_Points__c == quo.SWAN_Total_Service_Points__c)
                    {
                        quoteIds.add(quo.Id);
                        originalQIds.add(quo.Swan_Original_Quote__c);
                        quoteMap.put(quo.Swan_Original_Quote__c,quo.Id);
                        
                    }
                }
                if(quoteIds.size()>0)
                {
                    for(Quote qt:[Select id, SWAN_Business_Account__c, vlocity_cmt__QuoteGroupId__c, vlocity_cmt__QuoteGroupId__r.Name, vlocity_cmt__DefaultServicePointId__c, vlocity_cmt__ParentQuoteId__c From Quote where vlocity_cmt__ParentQuoteId__c IN:quoteIds OR vlocity_cmt__ParentQuoteId__c IN:originalQIds])
                    {
                        if(quoteIds.contains(qt.vlocity_cmt__ParentQuoteId__c))
                        {
                            if(qt.vlocity_cmt__DefaultServicePointId__c != null)
                                carbonquoteSPMap.put(qt.vlocity_cmt__DefaultServicePointId__c,qt.Id);
                        }
                        else
                        {
                            if(qt.vlocity_cmt__DefaultServicePointId__c != null)
                                og_Quote_SPMap.put(qt.vlocity_cmt__DefaultServicePointId__c,qt.Id);
                        }
                    }   
                    for(String tempId:carbonquoteSPMap.keyset())
                    {
                        if(og_Quote_SPMap.containsKey(tempId))
                        {
                            quoteMap.put(og_Quote_SPMap.get(tempId),carbonquoteSPMap.get(tempId));
                        }
                    }
                }       
                system.debug('====='+quoteMap);
                if(originalQIds.size()>0)
                {
                    Map<String, Schema.SObjectField> QFields = Schema.getGlobalDescribe().get('Quote').getDescribe().fields.getMap();
                    List<String> editableQFields = new List<String>();
                    List<sObject> carbon_child_List = new List<sObject>();
                    for(Schema.SObjectField fieldRef : QFields.values()) {
                        System.debug('fieldRef val'+fieldRef);
                        Schema.DescribeFieldResult fieldResult = fieldRef.getDescribe();
                        if(fieldResult.isCreateable()) {
                            System.debug('fieldResult.isCreateable() value'+fieldResult.isCreateable());
                            System.debug('fieldRef string'+(String.valueOf(fieldRef)));
                            editableQFields.add((String.valueOf(fieldRef)));
                        }
                    }
                    String querystring ='SELECT ID,';
                    for(string api : editableQFields)
                    {
                        querystring+=api+',';
                    }
                    querystring=querystring.removeendignorecase(',')+' FROM Quote WHERE (vlocity_cmt__ParentQuoteId__c = :originalQIds AND vlocity_cmt__DefaultServicePointId__c != null)';
                    system.debug('==$$$$$$$$$$$$$$$\n'+querystring);
                    List<sObject> sObjList = Database.query(querystring);
                    //system.debug('==>>>>>>>>>>'+sObjList);
                    for(sObject sObj:sObjList)
                    {
                        System.debug('sObj bhai'+sObj);
                        sObject ClonedsObj = Schema.getGlobalDescribe().get('Quote').newSObject();
                        ClonedsObj = sObj.clone(false, false, false, false);
                        String qId = sObj.get('Id').toString();
                        String parentId = sObj.get('vlocity_cmt__ParentQuoteId__c').toString();
                        System.debug('qqqqqqId'+qId);
                        if(quoteMap.containsKey(qId)){
                            ClonedsObj.put('Id',quoteMap.get(qId));
                            ClonedsObj.put('vlocity_cmt__ParentQuoteId__c',quoteMap.get(parentId));
                            ClonedsObj.put('SWAN_Parent_Quote__c',quoteMap.get(parentId));
                        }   
                        carbon_child_List.add(ClonedsObj);
                        system.debug('carbon_child_List in for loop'+carbon_child_List);
                    }
                    if(carbon_child_List.size() > 0){
                        update carbon_child_List;
                    }
                }
                iscarbonchildCloned=true;
            }   
        }
        
        /*
        *Method Name - restrictQuoteDelete
        *Developer Name - Neha Shaw pal
        *Description - To restrict quote deletion(master quote, site addition quote and service point quote that are not submitted/ issued)
        */
        public static void restrictDeleteForQuoteWithOfferPack()
        {  
            Set<Id> qIdSet = new Set<Id>();
            List<Id> qtList = new List<Id>();
            for(Quote quo_Old : (list<Quote>)Trigger.old)
                qIdSet.add(quo_Old.Id);
                
            for(SWAN_Offer_Pack_Quote__c offerPck : [select id, SWAN_Quote__c from SWAN_Offer_Pack_Quote__c where SWAN_Quote__c in : qIdSet])
            {
                qtList.add(offerPck.SWAN_Quote__c);
            }
            for(Quote quo_Old : (list<Quote>)Trigger.old)
            {
                if(qtList.contains(quo_Old.Id))
                    quo_Old.addError(label.Quote_With_Offer_Pack_Delete_Message);
            } 
        }
        
}