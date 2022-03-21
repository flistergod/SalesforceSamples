global class SWAN_ClearPrices implements Database.Batchable<sObject>, Database.AllowsCallouts{

   String MasterQuoteId = '';
   String CreateDataComponent = '';
   String OpportunityId = '';
   String GorillaAuthorizationHostName = '';
   String GorillaSecret = '';
   String fuelTypeval ='';
   String GorillaHostName = '';
   String ProductId = '';
    
    global SWAN_ClearPrices(string mastQuoteId, String dataComp, String optyId, String authHostName, String secret, String hostName , string fuelType, string ProductIdVal){
        MasterQuoteId = mastQuoteId;
        CreateDataComponent = dataComp;
        OpportunityId = optyId;
        GorillaAuthorizationHostName = authHostName;
        GorillaSecret = secret;
        GorillaHostName = hostName;
        fuelTypeval = fueltype;
        ProductId = ProductIdVal; 
    }
   global Database.QueryLocator start(Database.BatchableContext BC){
      string query = 'select id,SWAN_Price_out_of_Date__c,SWAN_Annual_Spend__c,Swan_Unidentified_Gas_Cost_as__c,Swan_Unidentified_Gas_Cost__c,'+
      'Swan_Other_Internal_Costs__c,Swan_Other_External_Costs_as__c,Swan_Other_External_Costs__c,SWAN_Unit_Rate_as_split__c,SWAN_Transportation_as_pc__c,'+
      'SWAN_Transportation__c,SWAN_Standing_Charge_as_split__c,SWAN_Broker_Commission__c,SWAN_Broker_Commission_as_pc__c,SWAN_Calculation_Commodity_Id__c,'+
      'SWAN_Calculation_Commodity_Version__c,SWAN_Commodity__c,SWAN_Commodity_as_pc__c,SWAN_Contract_Spend__c,SWAN_Contract_Volume_KWh__c,'+
      'SWAN_Contribution_Margin__c,SWAN_Contribution_Margin_pc__c,SWAN_Cost_to_Serve__c,SWAN_Cost_to_Serve_as_pc__c,SWAN_Gross_Margin__c,'+
      'SWAN_Gross_Margin_pc__c,SWAN_Metering__c,SWAN_Metering_as_pc__c,SWAN_Non_Commodity__c,SWAN_Non_Commodity_as_pc__c,SWAN_Other_Internal_Costs_as__c,SWAN_ReAssess_Calculation_Id__c,'+
      'vlocity_cmt__ParentQuoteId__r.SWAN_Quote_Type__c,SWAN_Business_Account__c,'+
      'SWAN_Pricing_Calculation_Id__c,status,SWAN_Pricing_User__c, (Select id , vlocity_cmt__RecurringCharge__c,SWAN_UnitRate__c, '+
      'Product2.vlocity_cmt__IsOrderable__c,Product2.vlocity_cmt__Type__c,SWAN_Cost_Recovery__c,SWAN_Unit_Rate_Therms__c,SWAN_UsageUnitPriceGSP__c,'+
      'SWAN_UsageUnitPriceNBP__c,vlocity_cmt__OneTimeCost__c,vlocity_cmt__UsageUnitPrice__c from QuoteLineItems) from Quote where id = \''+MasterQuoteId+'\' OR vlocity_cmt__ParentQuoteId__c=\''+MasterQuoteId+'\'';
      
      return Database.getQueryLocator(query);
   }

   global void execute(Database.BatchableContext BC, List<Quote> quoteList){
     List<QuoteLineItem> qliList = new List<QuoteLineItem>();
     for(Quote qt : quoteList){
         
         if(qt.Id == MasterQuoteId)
         {
             qt.SWAN_Price_out_of_Date__c = false;
             qt.SWAN_Annual_Spend__c = null;
             qt.Swan_Unidentified_Gas_Cost_as__c = null;
             qt.status = 'Draft';
             qt.Swan_Unidentified_Gas_Cost__c = null;
             qt.Swan_Other_Internal_Costs__c = null;
             qt.Swan_Other_External_Costs_as__c = null;
             qt.Swan_Other_External_Costs__c = null;
             qt.SWAN_Unit_Rate_as_split__c = null;
             qt.SWAN_Transportation_as_pc__c = null;
             qt.SWAN_Transportation__c = null;
             qt.SWAN_Standing_Charge_as_split__c = null;
             qt.SWAN_Broker_Commission__c = null;
             qt.SWAN_Broker_Commission_as_pc__c = null;
             //qt.SWAN_Calculation_Commodity_Id__c = null;
             qt.SWAN_Calculation_Commodity_Version__c = null;
             qt.SWAN_ReAssess_Calculation_Id__c = null;
             qt.SWAN_Commodity__c = null;
             qt.SWAN_Commodity_as_pc__c = null;
             qt.SWAN_Contract_Spend__c = null;
             qt.SWAN_Contract_Volume_KWh__c = null;
             qt.SWAN_Contribution_Margin__c = null;
             qt.SWAN_Contribution_Margin_pc__c = null;
             qt.SWAN_Cost_to_Serve__c = null;
             qt.SWAN_Cost_to_Serve_as_pc__c = null;
             qt.SWAN_Gross_Margin__c = null;
             qt.SWAN_Gross_Margin_pc__c = null;
             qt.SWAN_Metering__c = null;
             qt.SWAN_Metering_as_pc__c = null;
             qt.SWAN_Non_Commodity__c = null;
             qt.SWAN_Non_Commodity_as_pc__c = null;
             qt.SWAN_Other_Internal_Costs_as__c = null;
             qt.SWAN_Pricing_Calculation_Id__c = null;
             qt.SWAN_Pricing_User__c = userinfo.getUserId();
             qt.AAHEDC__c  = null;
             qt.AAHEDC_pc__c  = null;
             qt.BSUoS_RCRC__c  = null;
             qt.BSUoS_RCRC_pc__c  = null;
             qt.Contracts_for_Difference__c  = null;
             qt.Contracts_for_Difference_pc__c  = null;
             qt.Capacity_Market__c  = null;
             qt.Capacity_Market_pc__c  = null;
             qt.DUoS__c  = null;
             qt.DUoS_pc__c  = null;
             qt.Feed_in_Tariff__c  = null;
             qt.Feed_in_Tariff_pc__c  = null;
             qt.Balance_Imbalance__c  = null;
             qt.Balance_Imbalance_pc__c = null;
             qt.Renewable_Obligation__c = null;
             qt.Renewable_Obligation_pc__c  = null;
             qt.TNUoS__c  = null;
             qt.TNUoS_pc__c  = null;
             qt.Renewable_Supply__c = null;
             qt.Renewable_Supply_pc__c = null;
             qt.Annual_Volume__c = null;
             qt.SWAN_Other__c = null;
             qt.SWAN_Other_as__c = null;
             
         }
         else{
             qt.SWAN_Contract_Volume_KWh__c = null;
             qt.SWAN_Price_out_of_Date__c = false;
             qt.SWAN_Annual_Spend__c = null;
             qt.SWAN_Contract_Spend__c = null;
             qt.Annual_Volume__c = null;
             qt.SWAN_Broker_Commission__c = null;
             qt.Status = 'Draft';
         }
     
        for(QuoteLineItem qli : qt.QuoteLineItems)
        {
            qli.vlocity_cmt__RecurringCharge__c = null;
            qli.SWAN_UnitRate__c = null;
            qli.vlocity_cmt__UsageUnitPrice__c = null;
             //if(qt.vlocity_cmt__ParentQuoteId__c!=null && qt.vlocity_cmt__ParentQuoteId__r.SWAN_Quote_Type__c=='Flex' && qt.SWAN_Business_Account__c!=null && !qli.Product2.vlocity_cmt__IsOrderable__c)
            {                
                qli.SWAN_Cost_Recovery__c=null;
                qli.SWAN_Unit_Rate_Therms__c=null;
                qli.SWAN_UsageUnitPriceGSP__c=null;
                qli.SWAN_UsageUnitPriceNBP__c=null;
                qli.vlocity_cmt__OneTimeCost__c=null;
            }
            qliList.add(qli);
        }
     }
     
     update quoteList;
     if(!qliList.isEmpty())
     {
         update qliList;
     }
     
    }

   global void finish(Database.BatchableContext BC){
       Map<String, Object> mInput = new Map<String, Object>();
       mInput.put('CreateDataComponent',(Map<String, Object>)JSON.deserializeUntyped(CreateDataComponent));
       mInput.put('OpportunityId',OpportunityId);
       mInput.put('QuoteId',MasterQuoteId);
       mInput.put('GorillaAuthorizationHostName',GorillaAuthorizationHostName);
       mInput.put('GorillaSecret',GorillaSecret);
       mInput.put('GorillaHostName',GorillaHostName);
       mInput.put('FuelType', fuelTypeVal);
       mInput.put('BaseProductId', ProductId);
       system.debug('===========json - '+JSON.serializepretty(mInput));
       CallVIPService('BG-UploadPricingData_UploadMeterList',mInput);
   }
   
   private static boolean CallVIPService(string IPname,Map<String, Object> ipInput) {
        
        Map<String, Object> ipOutput = new Map<String, Object> ();
                
        /* Call the IP via runIntegrationService, 
        and save the output to ipOutput */
        try{
            if(!test.isRunningTest())
                ipOutput = (Map<String, Object>) vlocity_cmt.IntegrationProcedureService.runIntegrationService(IPname, ipInput, new Map<String, Object>());
            return true;
        }
        catch(Exception ex)
        {
            system.debug('===>'+ex);
            return false;
        }
    }  
}