global class CloneQuotes implements Database.Batchable<sObject> , Database.Stateful{
    
    global final String Query;
    global final String masterQuoteId;
    global List<Quote> masterClonedQuoteId;
    global Integer numberOfSQ ;
    global Date  swanOfferStartDate ;
    global Date  swanOfferEndDate ;
    global Quote clQuote ;
    global Map<String,String> mapMasterGroupsIds = new Map<String,String>();
    global Map<String, Map<String,String> > mapMasterGroupsJSONAttribute = new Map<String, Map<String,String>>();
    global Map<String,Map<String,Quote>> mapClonnedGroupsIds = new Map<String,Map<String,Quote>>();
    
    
    global CloneQuotes(String masterQuoteId,  List<Quote> masterClonedQuoteId){ //(String q, String e, String f, String v)
        this.masterQuoteId = masterQuoteId;
        this.masterClonedQuoteId = masterClonedQuoteId;
        this.numberOfSQ=0;

        this.clQuote = [Select Id,SWAN_Offer_End_Date__c, SWAN_Offer_Start_Date__c, vlocity_cmt__ExternalPricingStatus__c FROM Quote Where Id=:this.masterQuoteId];

        //get Groups  ids of master quote   
        for(Quote qtGRoup  : [Select Id, Name, vlocity_cmt__QuoteGroupId__c, (Select Id, vlocity_cmt__JSONAttribute__c, Product2Id  from QuotelineItems ) from Quote Where (SWAN_Parent_Quote__c =: this.masterQuoteId or vlocity_cmt__ParentQuoteId__c =: this.masterQuoteId ) and  RecordType.name ='Group Cart'] ){
            mapMasterGroupsIds.put(qtGRoup.vlocity_cmt__QuoteGroupId__c , qtGRoup.Name );
			
            //map groups with Product2Id by vlocity_cmt__JSONAttribute__c
            Map<String, String > grpByQLI = new Map<String, String>();
            for( QuotelineItem  qli :  qtGRoup.QuotelineItems){

                grpByQLI.put( qli.Product2Id , qli.vlocity_cmt__JSONAttribute__c  );
            }
            
            mapMasterGroupsJSONAttribute.put(qtGRoup.vlocity_cmt__QuoteGroupId__c, grpByQLI);
            
        }
      
        //get Groups  ids of clonned quote
        for(Quote qtClonnedGRoup  : [Select Id, Name, vlocity_cmt__QuoteGroupId__c, vlocity_cmt__ParentQuoteId__c, SWAN_Offer_End_Date__c, SWAN_Offer_Start_Date__c, SWAN_Service_Point_Start_Date__c  from Quote Where (SWAN_Parent_Quote__c IN :this.masterClonedQuoteId or vlocity_cmt__ParentQuoteId__c IN :this.masterClonedQuoteId ) and  RecordType.name ='Group Cart'] ){
           
            if(mapClonnedGroupsIds.get(qtClonnedGRoup.vlocity_cmt__ParentQuoteId__c)==null){
                Map<String,Quote> grpForClonnedQuote =  new Map<String,Quote>();
                grpForClonnedQuote.put(qtClonnedGRoup.Name, qtClonnedGRoup);
                mapClonnedGroupsIds.put(qtClonnedGRoup.vlocity_cmt__ParentQuoteId__c , grpForClonnedQuote );

            }else{
                Map<String,Quote> grpForClonnedQuote = mapClonnedGroupsIds.get(qtClonnedGRoup.vlocity_cmt__ParentQuoteId__c);
                grpForClonnedQuote.put(qtClonnedGRoup.Name , qtClonnedGRoup );
            }
        }
        
        
        this.swanOfferStartDate = clQuote.SWAN_Offer_Start_Date__c;
        this.swanOfferEndDate=  clQuote.SWAN_Offer_End_Date__c;

        this.Query = 'SELECT Id,  Name, SWAN_Offer_End_Date__c ,  RecordTypeId, Status, OpportunityId, SWAN_Service_Point_End_Date__c,  SWAN_Service_Point_Start_Date__c, Pricebook2Id, SWAN_Service_Point__c, vlocity_cmt__DefaultServicePointId__c,' +
            'SWAN_Parent_Quote__c, SWAN_Offer_Start_Date__c, vlocity_cmt__ParentQuoteId__c,  vlocity_cmt__QuoteGroupId__c, ' +  
            '(Select Id, Description, vlocity_cmt__JSONAttribute__c, LineNumber, PricebookEntryId, Product2Id, Quantity, SWAN_Service_Point__c, vlocity_cmt__ServicePointId__c, UnitPrice  from QuotelineItems )'+
            ' FROM Quote Where ( SWAN_Parent_Quote__c =  \'' + this.masterQuoteId + '\'  or  vlocity_cmt__ParentQuoteId__c = \'' + this.masterQuoteId + '\' ) and    RecordTypeId = \'' + Schema.SObjectType.Quote.getRecordTypeInfosByName().get('Sub Quote').getRecordTypeId() + '\'  ' ;
        //(Select Id, Description, vlocity_cmt__JSONAttribute__c, LineNumber, PricebookEntryId, Product2Id, Quantity, SWAN_Service_Point__c, UnitPrice  from QuotelineItems )
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(this.Query);
    }
    
    global void execute(Database.BatchableContext BC, List<Quote> lstServiceQuotes){
        

        List<Quote> lstNewServiceQuote = new List<Quote>();
        List<QuotelineItem> lstNewQuoteLineItem = new List<QuotelineItem>();
        Map<String, Quote> mapServiceQuotes = new Map<String, Quote>();
        
        this.numberOfSQ = this.numberOfSQ +  lstServiceQuotes.size();
        
        for(Quote masterClQuote : masterClonedQuoteId){
            
            for(Quote servicequote : lstServiceQuotes){

                Quote qt = new Quote( Name = servicequote.Name,
                                     SWAN_Offer_End_Date__c = mapClonnedGroupsIds.get(masterClQuote.Id).get(mapMasterGroupsIds.get(servicequote.vlocity_cmt__QuoteGroupId__c)).SWAN_Offer_End_Date__c  , //this.swanOfferEndDate
                                     SWAN_Offer_Start_Date__c = mapClonnedGroupsIds.get(masterClQuote.Id).get(mapMasterGroupsIds.get(servicequote.vlocity_cmt__QuoteGroupId__c)).SWAN_Offer_Start_Date__c , //this.swanOfferStartDate
                                     RecordTypeId = servicequote.RecordTypeId , 
                                     /*Status = servicequote.Status , */
                                     OpportunityId = servicequote.OpportunityId , 
                                     /*tSWAN_Service_Point_End_Date__c = servicequote.SWAN_Service_Point_End_Date__c,  */
                                     SWAN_Service_Point_Start_Date__c = mapClonnedGroupsIds.get(masterClQuote.Id).get(mapMasterGroupsIds.get(servicequote.vlocity_cmt__QuoteGroupId__c)).SWAN_Service_Point_Start_Date__c , //servicequote.SWAN_Service_Point_Start_Date__c 
                                     Pricebook2Id = servicequote.Pricebook2Id, 
                                     SWAN_Service_Point__c = servicequote.SWAN_Service_Point__c, 
                                     vlocity_cmt__DefaultServicePointId__c = servicequote.vlocity_cmt__DefaultServicePointId__c,
                                     SWAN_Parent_Quote__c = masterClQuote.Id,
                                     vlocity_cmt__ParentQuoteId__c = masterClQuote.Id,
                                     vlocity_cmt__QuoteGroupId__c =  mapClonnedGroupsIds.get(masterClQuote.Id).get(mapMasterGroupsIds.get(servicequote.vlocity_cmt__QuoteGroupId__c)).vlocity_cmt__QuoteGroupId__c  
                                    ); 
                
                lstNewServiceQuote.add(qt);
                mapServiceQuotes.put(qt.Name , servicequote);
                
            }
            
        }
        
        insert lstNewServiceQuote;
        
        for(Quote newQuoteService :lstNewServiceQuote){
            
            for(QuoteLineItem qli : (List<QuoteLineItem>)mapServiceQuotes.get(newQuoteService.name).QuotelineItems ){
               
                QuotelineItem  newQLI = new QuotelineItem(QuoteId = newQuoteService.Id, 
                                                          Description = qli.Description,
                                                          vlocity_cmt__JSONAttribute__c = mapMasterGroupsJSONAttribute.get(mapServiceQuotes.get(newQuoteService.name).vlocity_cmt__QuoteGroupId__c).get(qli.Product2Id), //qli.vlocity_cmt__JSONAttribute__c
                                                          /*LineNumber = qli.LineNumber,
                                                            ListPrice = qli.ListPrice,*/
                                                          PricebookEntryId =qli.PricebookEntryId,
                                                          Product2Id= qli.Product2Id,
                                                          Quantity = qli.Quantity,
                                                          SWAN_Start_Date__c  = newQuoteService.SWAN_Offer_Start_Date__c,
                                                          /*SWAN_End_Date__c = newQuoteService.SWAN_Offer_End_Date__c,*/
                                                          /*SWAN_Contract_Start_Date__c =qli.SWAN_Contract_Start_Date__c,*/
                                                          SWAN_Service_Point__c = qli.SWAN_Service_Point__c,
                                                          vlocity_cmt__ServicePointId__c = qli.vlocity_cmt__ServicePointId__c,
                                                          UnitPrice = qli.UnitPrice
                                                         ); 
                
                lstNewQuoteLineItem.add(newQLI);    
                
            }
            
        }
        
        insert lstNewQuoteLineItem;
        
        
    }
    
    global void finish(Database.BatchableContext BC){
        
        List<Task> lstTask = new List<Task>();
        
        List<Quote> getLstOfClonnedQuuotes = [Select Id,SWAN_Offer_End_Date__c, SWAN_Offer_Start_Date__c, vlocity_cmt__ExternalPricingStatus__c FROM Quote Where Id in : this.masterClonedQuoteId ];
        
        for( Quote qt : getLstOfClonnedQuuotes  ){
            
            Task notify = new Task(OwnerId = UserInfo.getUserId(), 
                                   Subject = 'Cloning Quote Finished', 
                                   Status = 'Open', 
                                   Priority = 'High', 
                                   WhatId = qt.Id, 
                                   ActivityDate=date.today(), 
                                   Description='Cloning Quote Finished',
                                   IsReminderSet=true, 
                                   ReminderDateTime=system.now().addSeconds(10)
                                  );
            
            lstTask.add(notify);
            
        }
        
        update getLstOfClonnedQuuotes;
        
        insert lstTask;
    }
}