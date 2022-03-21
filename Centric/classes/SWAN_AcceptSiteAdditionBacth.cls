global class SWAN_AcceptSiteAdditionBacth implements Database.Batchable<sObject> , Database.Stateful{
    
    
    global final String Query;
    global final String masterQuoteId;
    global final String contractId;
    global final String masterClonedQuoteId;
    
    //global final String ContractId;
    global Integer numberOfSQ ;
    global Date  swanOfferStartDate ;
    global Date  swanOfferEndDate ;
    
    
    
    global SWAN_AcceptSiteAdditionBacth(String masterQuoteId, String contractId , String isExpired){ //(String q, String e, String f, String v)
        
        this.masterQuoteId = masterQuoteId; //'0Q07E000001QlIfSAK'
               
        List<Contract>   lst = new  List<Contract>([Select Id from Contract Where vlocity_cmt__QuoteId__c in ( Select  SWAN_Site_Addition_Parent__c from quote Where Id=:this.masterQuoteId ) and Status!='' limit 1 ]);

        
        if(lst.size() > 0 ){
            this.contractId = lst.get(0).Id;
        }
               
        this.Query ='SELECT QuoteNumber, Id,  Name, OpportunityId,  Pricebook2Id, SWAN_Offer_End_Date__c ,  RecordTypeId, Status,SWAN_Contract_Volume_KWh__c, SWAN_Service_Point__c, SWAN_Service_Point__r.vlocity_cmt__PremisesId__c,  SWAN_Service_Point_End_Date__c,'+
            ' SWAN_Service_Point_Start_Date__c,vlocity_cmt__PriceListId__c , AccountId, (Select Id, Description, Discount, LineNumber, PricebookEntryId,  Product2Id, Quantity,  SWAN_Start_Date__c,  ListPrice,   UnitPrice , SWAN_UnitRate__c,'+
            ' SWAN_UnitRateCalculatedPrice__c, SWAN_UnitRateDiscountPrice__c, SWAN_UnitRateEffectiveUsageTotal__c, SWAN_UnitRateManualDiscount__c, SWAN_UnitRateTotal__c, SWAN_UnitRateUOM__c, ' +
            ' vlocity_cmt__RecurringCharge__c from QuotelineItems )  FROM Quote Where RecordType.name= \'Sub Quote\' and   ( SWAN_Parent_Quote__c =  \'' + this.masterQuoteId + '\'  Or vlocity_cmt__ParentQuoteId__c =  \'' + this.masterQuoteId + '\' )  ' ; 
        
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(this.Query);
    }
    
    global void execute(Database.BatchableContext BC, List<Quote> lstServiceQuotes){
        
        List<vlocity_cmt__ContractLineItem__c> lstCLI = new List<vlocity_cmt__ContractLineItem__c>();
        Map<String, Quote> mapSQ = new Map<String, Quote>();
        Map<String, vlocity_cmt__ContractLineItem__c> mapSQwCLI = new Map<String, vlocity_cmt__ContractLineItem__c>();
        Set<String> SWANServicePointIds = new  Set<String>();
        
        
        // create contract to child quotes
        for(Quote servicequote : lstServiceQuotes){
                        
            vlocity_cmt__ContractLineItem__c cli  = new vlocity_cmt__ContractLineItem__c(vlocity_cmt__ContractId__c = this.contractId,
                                                                                         SWAN_Contract_Volume__c = servicequote.SWAN_Contract_Volume_KWh__c,
                                                                                         SWAN_Quote__c  = servicequote.Id,
                                                                                         Name =servicequote.Name,
                                                                                         vlocity_cmt__EffectiveEndDate__c = DateTime.valueOfGMT(String.valueOf(servicequote.swan_service_point_end_date__c)+' 22:59:00'), //servicequote.SWAN_Service_Point_End_Date__c,
                                                                                         SWAN_Service_Point_End_Date__c = servicequote.SWAN_Service_Point_End_Date__c,
                                                                                         vlocity_cmt__EffectiveStartDate__c = servicequote.SWAN_Service_Point_Start_Date__c,
                                                                                         SWAN_Service_Point_Start_Date__c= servicequote.SWAN_Service_Point_Start_Date__c,
                                                                                         SWAN_Service_Point__c = servicequote.SWAN_Service_Point__c,
                                                                                         vlocity_cmt__ServicePointId__c = servicequote.SWAN_Service_Point__c 
                                                                                        );
            
            
            lstCLI.add(cli);
            
            mapSQ.put(servicequote.QuoteNumber, servicequote );
            mapSQwCLI.put(servicequote.QuoteNumber, cli );
            
            // acumulate service points ids to query
            SWANServicePointIds.add(servicequote.SWAN_Service_Point__c);

        }   
        
        insert lstCLI;
        system.debug('lstCLI'+lstCLI);
        Set<Id> inserted_parentcli_ids = new Set<Id>();
        Map<String,vlocity_cmt__ContractLineItem__c> map_of_inserted_cli_and_dates = new Map<String,vlocity_cmt__ContractLineItem__c>();
        for(vlocity_cmt__ContractLineItem__c cli_id : lstCLI)
        {   
            inserted_parentcli_ids.add(cli_id.id);
            map_of_inserted_cli_and_dates.put(cli_id.id,cli_id);
        }
        List<vlocity_cmt__ContractLineItem__c> con_lineitem = [Select id,vlocity_cmt__EffectiveEndDate__c,vlocity_cmt__EffectiveStartDate__c,SWAN_Service_Point_End_Date__c,SWAN_Service_Point_Start_Date__c from vlocity_cmt__ContractLineItem__c where Id IN :inserted_parentcli_ids];
        System.debug('con_lineitem'+con_lineitem);
        for(Quote servicequote : lstServiceQuotes){
            for(vlocity_cmt__ContractLineItem__c insertedparentcli : con_lineitem){
                if(mapSQwCLI.get(servicequote.QuoteNumber).Id == insertedparentcli.Id){
                    insertedparentcli.vlocity_cmt__EffectiveEndDate__c = mapSQwCLI.get(servicequote.QuoteNumber).vlocity_cmt__EffectiveEndDate__c;
                    insertedparentcli.vlocity_cmt__EffectiveStartDate__c = mapSQwCLI.get(servicequote.QuoteNumber).vlocity_cmt__EffectiveStartDate__c; 
                }
            }
        }   
        System.debug('con_lineitemafterupdate'+con_lineitem);
        update con_lineitem;
        // Get Assets by Parent to see whitch assets will created  and the one's that will be created  
        Map<String, String> mapAssetToParentCLI = new Map<String, String>();
       	List<Asset> findAssetsToUpsert = new List<Asset>([Select Id, SWAN_Contract_Line__c from Asset Where SWAN_Contract_Line__c in :  (new Map<Id,SObject>(lstCLI)).keySet() ]);
       
        for(Asset assIteration : findAssetsToUpsert ){
            mapAssetToParentCLI.put(assIteration.SWAN_Contract_Line__c, assIteration.Id );
        }
        
        // create contracts for  child quotes
        List<vlocity_cmt__ContractLineItem__c> lstCLIForQuotelineItems = new List<vlocity_cmt__ContractLineItem__c>();
        
        // create or update assets 
        List<Asset> lstAss =  new List<Asset>();

        for(Quote servicequote : lstServiceQuotes){
            
            for(QuoteLineItem qli : (List<QuoteLineItem>)mapSQ.get(servicequote.QuoteNumber).QuotelineItems ){
                
               
                                vlocity_cmt__ContractLineItem__c cli  = new vlocity_cmt__ContractLineItem__c(vlocity_cmt__ContractId__c = this.contractId,
                                                                                             Name = mapSQwCLI.get(servicequote.QuoteNumber).Name, 
                                                                                             vlocity_cmt__EffectiveEndDate__c = DateTime.valueOfGMT(String.valueOf(mapSQwCLI.get(servicequote.QuoteNumber).swan_service_point_end_date__c)+' 22:59:00') ,// newCLI.SWAN_Service_Point_End_Date__c,
                                                                                             vlocity_cmt__EffectiveStartDate__c = mapSQwCLI.get(servicequote.QuoteNumber).SWAN_Service_Point_Start_Date__c,
                                                                                             vlocity_cmt__LineNumber__c = qli.LineNumber,
                                                                                             SWAN_ListPrice__c = qli.ListPrice,
                                                                                             vlocity_cmt__PricebookEntryId__c =  qli.PricebookEntryId,
                                                                                             vlocity_cmt__Product2Id__c = qli.Product2Id,
                                                                                             vlocity_cmt__Quantity__c = qli.Quantity, 
                                                                                             vlocity_cmt__RecurringCharge__c= qli.vlocity_cmt__RecurringCharge__c,
                                                                                             vlocity_cmt__UnitPrice__c =qli.UnitPrice,
                                                                                             SWAN_UnitRate__c=qli.SWAN_UnitRate__c,
                                                                                             SWAN_UnitRateCalculatedPrice__c = qli.SWAN_UnitRateCalculatedPrice__c, 
                                                                                             SWAN_UnitRateDiscountPrice__c = qli.SWAN_UnitRateDiscountPrice__c,
                                                                                             SWAN_UnitRateEffectiveUsageTotal__c  = qli.SWAN_UnitRateEffectiveUsageTotal__c,
                                                                                             SWAN_UnitRateManualDiscount__c =qli.SWAN_UnitRateManualDiscount__c,
                                                                                             SWAN_UnitRateTotal__c = qli.SWAN_UnitRateTotal__c,
                                                                                             SWAN_UnitRateUOM__c = qli.SWAN_UnitRateUOM__c,
                                                                                             vlocity_cmt__OriginalLineItemId__c = mapSQwCLI.get(servicequote.QuoteNumber).Id // newCLI.Id
                                                                                             
                                                                                            );
                
                lstCLIForQuotelineItems.add(cli);
            }

            
            vlocity_cmt__ContractLineItem__c parentCLI = (vlocity_cmt__ContractLineItem__c)mapSQwCLI.get(servicequote.QuoteNumber); 
            
            
            Asset ass = new Asset(AccountId = mapSQ.get(servicequote.QuoteNumber).AccountId,
                                  Name = parentCLI.Name,
                                  SWAN_Contract_Line__c = parentCLI.Id,
                                  vlocity_cmt__PremisesId__c = parentCLI.SWAN_Service_Point__r.vlocity_cmt__PremisesId__c,
                                  SWAN_Quote__c = parentCLI.SWAN_Quote__c,
                                  vlocity_cmt__ServicePointId__c = ( parentCLI.SWAN_Service_Point__c == null ? parentCLI.SWAN_Service_Point__c : parentCLI.vlocity_cmt__ServicePointId__c ),
                                  vlocity_cmt__ContractId__c =  parentCLI.vlocity_cmt__ContractId__c,
                                  UsageEndDate = (parentCLI.vlocity_cmt__EffectiveEndDate__c == null) ? null : parentCLI.vlocity_cmt__EffectiveEndDate__c.date(), 
                                  vlocity_cmt__ActivationDate__c = (parentCLI.vlocity_cmt__EffectiveStartDate__c == null) ? null : parentCLI.vlocity_cmt__EffectiveStartDate__c.date(),
                                  Status  = 'Inactive' // default value vlocity_cmt__LineStatus__c When   vlocity_cmt__ContractLineItem__c  is created  
                                 ); 
            
            
            if(mapAssetToParentCLI.get(parentCLI.Id) != null ){
                ass.Id = mapAssetToParentCLI.get(parentCLI.Id);
            }
       
            lstAss.add(ass); 
            
        }
        
        // insert contracts for QLI
        insert lstCLIForQuotelineItems; 
        Set<Id> inserted_childcli_ids = new Set<Id>();
        for(vlocity_cmt__ContractLineItem__c childcli_for_map : lstCLIForQuotelineItems)
        {   
            inserted_childcli_ids.add(childcli_for_map.id);
        }
        List<vlocity_cmt__ContractLineItem__c> inserted_childcli = [Select id,vlocity_cmt__EffectiveEndDate__c,vlocity_cmt__EffectiveStartDate__c,vlocity_cmt__OriginalLineItemId__c,SWAN_Service_Point_End_Date__c,SWAN_Service_Point_Start_Date__c from vlocity_cmt__ContractLineItem__c where Id IN :inserted_childcli_ids];
        System.debug('inserted_childclidatabase'+inserted_childcli);
        for(Quote servicequote : lstServiceQuotes){
            for(vlocity_cmt__ContractLineItem__c insertedchildcli : inserted_childcli){
                insertedchildcli.vlocity_cmt__EffectiveEndDate__c = map_of_inserted_cli_and_dates.get(insertedchildcli.vlocity_cmt__OriginalLineItemId__c).vlocity_cmt__EffectiveEndDate__c;
                insertedchildcli.vlocity_cmt__EffectiveStartDate__c = map_of_inserted_cli_and_dates.get(insertedchildcli.vlocity_cmt__OriginalLineItemId__c).vlocity_cmt__EffectiveStartDate__c;
            }
        }   
        update inserted_childcli;
        //update 
        upsert lstAss;
    }
    
    global void finish(Database.BatchableContext BC){
        
        Task notify = new Task(OwnerId = UserInfo.getUserId(), 
                               Subject = 'Accept Site Addition Finished', 
                               Status = 'Open', 
                               Priority = 'High', 
                               WhatId = this.masterQuoteId, 
                               ActivityDate=date.today(), 
                               Description='Accept Site Addition Finished',
                               IsReminderSet=true, 
                               ReminderDateTime=system.now().addSeconds(10)
                              );
        
        insert notify;
      
    }
    
}