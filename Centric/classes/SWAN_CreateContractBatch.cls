//Tested by calling classes. Check SWAN_ExtractSubQuoteCount
public class SWAN_CreateContractBatch implements Database.Batchable<sObject>,Database.Stateful{

    public string UserId;
    public string masterQuoteId;
    public Id con_id;
    public boolean hasErrors;
    
    public SWAN_CreateContractBatch (String masterQuoteId,string UserId)
    {
        this.masterQuoteId=masterQuoteId;
        this.UserId=UserId;
        this.hasErrors=false;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
    String query = 'Select id FROM Quote where Recordtype.DeveloperName != \'GroupCart\' AND vlocity_cmt__ParentQuoteId__c = :masterQuoteId';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Quote> scope) {
        system.debug('scope'+scope.size());
        List<ID> quoteids = new List<ID>();
        for(Quote q : scope){
            
            quoteids.add(q.Id);
        }
        system.debug('quoteids'+quoteids);
        system.debug('quoteids'+quoteids.size());
        List<Quote> childQuotes = [SELECT id,name,swan_contract_volume_kwh__c,swan_service_point_end_date__c,swan_service_point_start_date__c,swan_service_point__c,vlocity_cmt__DefaultServicePointId__c,(SELECT id,quoteid,product2id,description,discount,vlocity_cmt__jsonattribute__c,linenumber,listprice,pricebookentryid,quantity,vlocity_cmt__recurringcharge__c,swan_start_date__c,UnitPrice,SWAN_UnitRate__c,SWAN_UnitRateCalculatedPrice__c,SWAN_UnitRateDiscountPrice__c,SWAN_UnitRateEffectiveUsageTotal__c,SWAN_UnitRateManualDiscount__c,SWAN_UnitRateTotal__c,SWAN_UnitRateUOM__c, vlocity_cmt__UsageUnitPrice__c, vlocity_cmt__UsageMeasurementId__c FROM QuoteLineItems) FROM Quote WHERE Id IN :quoteids];
        system.debug('childQuotes'+childQuotes);
        
        List<vlocity_cmt__ContractLineItem__c> cli = new List<vlocity_cmt__ContractLineItem__c>();
        List<vlocity_cmt__ContractLineItem__c> child_Cli = new List<vlocity_cmt__ContractLineItem__c>();
        List<QuoteLineItem> qli_list = new List<QuoteLineItem>();
        //Map<Id,Quote> childQuotewithQLI = new Map<String,Quote>();
        List<Contract> contract_info = [Select id from Contract where vlocity_cmt__QuoteId__c =:masterQuoteId and Status ='Draft'];
        for(Contract con : contract_info){
            con_id = con.id;
        }
        
        try
        { 
            for(Quote childQuote : childQuotes)
            {
                vlocity_cmt__ContractLineItem__c cli_in_for = new vlocity_cmt__ContractLineItem__c();
                cli_in_for.SWAN_Contract_Volume__c = childQuote.swan_contract_volume_kwh__c;
                cli_in_for.SWAN_Quote__c  = childQuote.Id;
                cli_in_for.Name  = childQuote.name;
                String clidate = String.valueOf(childQuote.swan_service_point_end_date__c)+' 22:59:00';
                cli_in_for.vlocity_cmt__EffectiveEndDate__c  = DateTime.valueOfGMT(clidate);
                cli_in_for.SWAN_Service_Point_End_Date__c  = childQuote.swan_service_point_end_date__c;
                cli_in_for.vlocity_cmt__EffectiveStartDate__c  = childQuote.swan_service_point_start_date__c;
                cli_in_for.SWAN_Service_Point_Start_Date__c  = childQuote.swan_service_point_start_date__c;
                cli_in_for.SWAN_Service_Point__c  = childQuote.swan_service_point__c;
                cli_in_for.SWAN_Service_Point__c  = childQuote.vlocity_cmt__DefaultServicePointId__c;
                cli_in_for.vlocity_cmt__ContractId__c  = con_id;
                cli.add(cli_in_for);
                qli_list.addALL(childQuote.QuoteLineItems);
            }
            System.debug('CLI'+cli);
            System.debug('qli_list'+qli_list);
            
            insert cli;
        }
        catch(exception ex){
            system.debug('Exception!!!!!!'+ex);
           this.hasErrors =true;
        }

        System.debug('Inserted CLI'+cli);
        System.debug('Inserted CLI size'+cli.size());
        Map<String,vlocity_cmt__ContractLineItem__c> map_of_inserted_cli_and_QuoteId = new Map<String,vlocity_cmt__ContractLineItem__c>();
        Map<String,vlocity_cmt__ContractLineItem__c> map_of_inserted_cli_and_dates = new Map<String,vlocity_cmt__ContractLineItem__c>();
        Set<Id> inserted_parentcli_ids = new Set<Id>();
        
        for(vlocity_cmt__ContractLineItem__c cli_for_map : cli)
        {   
            map_of_inserted_cli_and_QuoteId.put(cli_for_map.SWAN_Quote__c,cli_for_map);
            map_of_inserted_cli_and_dates.put(cli_for_map.id,cli_for_map);
            inserted_parentcli_ids.add(cli_for_map.id);
        }
        
        List<vlocity_cmt__ContractLineItem__c> inserted_cli = [Select id,name,SWAN_Quote__c,vlocity_cmt__ContractId__c,vlocity_cmt__EffectiveStartDate__c,vlocity_cmt__EffectiveEndDate__c from vlocity_cmt__ContractLineItem__c where id IN :inserted_parentcli_ids];
        System.debug('insertedclidatabase'+inserted_cli);
        System.debug('map_of_inserted_cli_and_QuoteId'+map_of_inserted_cli_and_QuoteId);
        
        for(vlocity_cmt__ContractLineItem__c insertedparentcli : inserted_cli){
            insertedparentcli.vlocity_cmt__EffectiveEndDate__c = map_of_inserted_cli_and_QuoteId.get(insertedparentcli.SWAN_Quote__c).vlocity_cmt__EffectiveEndDate__c;
            insertedparentcli.vlocity_cmt__EffectiveStartDate__c = map_of_inserted_cli_and_QuoteId.get(insertedparentcli.SWAN_Quote__c).vlocity_cmt__EffectiveStartDate__c; 
        }
        
        System.debug('insertedclidatabaseafterupdate'+inserted_cli);
        
        try{ update inserted_cli; }
        catch(exception ex){
            system.debug('Exception!!!!!!'+ex);
            this.hasErrors =true;
        }
        
        System.debug('insertedclidatabaseafterupdateDatabase'+inserted_cli);
        
        try
        { 
            for(QuoteLineItem qli : qli_list)
            {
                vlocity_cmt__ContractLineItem__c child_cli_in_for = new vlocity_cmt__ContractLineItem__c();
                child_cli_in_for.vlocity_cmt__LineNumber__c = qli.linenumber;
                child_cli_in_for.SWAN_ListPrice__c  = qli.listprice;
                child_cli_in_for.vlocity_cmt__PricebookEntryId__c  = qli.pricebookentryid;
                child_cli_in_for.vlocity_cmt__Product2Id__c  = qli.product2id;
                child_cli_in_for.vlocity_cmt__Quantity__c  = qli.quantity;
                child_cli_in_for.vlocity_cmt__RecurringCharge__c  = qli.vlocity_cmt__recurringcharge__c;
                child_cli_in_for.vlocity_cmt__UnitPrice__c  = qli.UnitPrice;
                child_cli_in_for.SWAN_UnitRate__c  = qli.SWAN_UnitRate__c;
                child_cli_in_for.SWAN_UnitRateCalculatedPrice__c = qli.SWAN_UnitRateCalculatedPrice__c;
                child_cli_in_for.SWAN_UnitRateDiscountPrice__c = qli.SWAN_UnitRateDiscountPrice__c;
                child_cli_in_for.SWAN_UnitRateEffectiveUsageTotal__c  = qli.SWAN_UnitRateEffectiveUsageTotal__c;
                child_cli_in_for.SWAN_UnitRateManualDiscount__c  = qli.SWAN_UnitRateManualDiscount__c;
                child_cli_in_for.SWAN_UnitRateTotal__c  = qli.SWAN_UnitRateTotal__c;
                child_cli_in_for.SWAN_UnitRateUOM__c  = qli.SWAN_UnitRateUOM__c;
                child_cli_in_for.vlocity_cmt__ContractId__c  = con_id;
                child_cli_in_for.SWAN_UsageUnitPrice__c = qli.vlocity_cmt__UsageUnitPrice__c;
                child_cli_in_for.SWAN_UsageMeasurementId__c = qli.vlocity_cmt__UsageMeasurementId__c;
                child_cli_in_for.vlocity_cmt__AttributesData__c = qli.vlocity_cmt__JSONAttribute__c;
                
                if(qli.quoteid == map_of_inserted_cli_and_QuoteId.get(qli.quoteid).SWAN_Quote__c){
                    
                    child_cli_in_for.vlocity_cmt__OriginalLineItemId__c  = map_of_inserted_cli_and_QuoteId.get(qli.quoteid).id;
                    String clidate = String.valueof(map_of_inserted_cli_and_QuoteId.get(qli.quoteid).SWAN_Service_Point_End_Date__c)+' 21:59:00';
                    child_cli_in_for.vlocity_cmt__EffectiveEndDate__c  = DateTime.valueOfGMT(clidate);
                    System.debug('child_cli_in_for.vlocity_cmt__EffectiveEndDate__c'+child_cli_in_for.vlocity_cmt__EffectiveEndDate__c);
                    child_cli_in_for.vlocity_cmt__EffectiveStartDate__c  = map_of_inserted_cli_and_QuoteId.get(qli.quoteid).vlocity_cmt__EffectiveStartDate__c;
                    
                }
                child_Cli.add(child_cli_in_for);
            }
            System.debug('child_Cli'+child_Cli);
            insert child_Cli; 
        }
        catch(exception ex){
            system.debug('Exception!!!!!!'+ex);
            this.hasErrors =true;
        }
        
        System.debug('Inserted child_Cli'+child_Cli);
        System.debug('Inserted child_Cli size'+child_Cli.size());
        Set<Id> inserted_childcli_ids = new Set<Id>();
        
        for(vlocity_cmt__ContractLineItem__c childcli_for_map : child_Cli)
        {   
            inserted_childcli_ids.add(childcli_for_map.id);
        }
        
        List<vlocity_cmt__ContractLineItem__c> inserted_childcli = [Select id,vlocity_cmt__OriginalLineItemId__c,vlocity_cmt__EffectiveStartDate__c,vlocity_cmt__EffectiveEndDate__c from vlocity_cmt__ContractLineItem__c where id IN :inserted_childcli_ids];
        System.debug('inserted_childclidatabase'+inserted_childcli);
        
        for(vlocity_cmt__ContractLineItem__c insertedchildcli : inserted_childcli){
            insertedchildcli.vlocity_cmt__EffectiveEndDate__c = map_of_inserted_cli_and_dates.get(insertedchildcli.vlocity_cmt__OriginalLineItemId__c).vlocity_cmt__EffectiveEndDate__c;
            insertedchildcli.vlocity_cmt__EffectiveStartDate__c = map_of_inserted_cli_and_dates.get(insertedchildcli.vlocity_cmt__OriginalLineItemId__c).vlocity_cmt__EffectiveStartDate__c;
            
        }
        
        System.debug('insertedchildclidatabaseafterupdate'+inserted_childcli);
        
        try{ update inserted_childcli;}
        catch(exception ex){
            system.debug('Exception!!!!!!'+ex);
            this.hasErrors =true;
        }
        
        System.debug('insertedchildclidatabaseafterupdateDatabase'+inserted_childcli);
        system.debug('haserrors1'+this.hasErrors);
        

        /**
         * Sum up quotelineItems ignoring group carts and master quote (only subquotes)
         * Count of all the service points
         * Sum of 2 above is the total agains created CLI and child CLI
         * 
         */
        if(this.hasErrors == false && (childQuotes.size()+qli_list.size() != inserted_cli.size() + inserted_childcli.size())){
            //if((childQuotes.size()*4) != (inserted_cli.size() + inserted_childcli.size()))
                System.debug('In Child CLi missing scenario.Check the QLI for Child Quotes');
                this.hasErrors = true;  
        }
    }

    public void finish(Database.BatchableContext BC){
        try{
            system.debug('Finished');
            system.debug('haserrors2'+this.hasErrors);
            Task notify = new Task();
            notify.OwnerId = UserId;
            notify.Subject = (this.hasErrors?'Creation of Contract Line Items are partially succeeded':'Contract Line Items successfully created');
            notify.Status = 'Open';
            notify.Priority = 'High';
            notify.WhatId = con_id;
            notify.ActivityDate=date.today();
            notify.Description=(this.hasErrors?'Please check the prices with respective Contract Line Items created':'Contract Line Items successfully created');
            notify.IsReminderSet=true;
            notify.ReminderDateTime=system.now().addSeconds(10);
            insert notify;
            if(!this.hasErrors)
            {
                Contract con = [Select id,SWAN_Ready_For_Document__c from Contract where id =:con_id];
                con.SWAN_Ready_For_Document__c = true;
                update con;
                System.debug('Contract ready to be documented');
            }   
        }
        catch(exception ex){system.debug('Exception!!!!!!'+ex);}
    }
    
}