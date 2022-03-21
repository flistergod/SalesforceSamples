global with sharing class AWSS3csvFileReader1 implements vlocity_cmt.VlocityOpenInterface2 {
    

    global Boolean invokeMethod(String methodName, Map < String, Object > input, Map < String, Object > output,  Map < String, Object > options) {
        return false;
    }
    
    public static Boolean AWSParseFileClone (Map < String, Object > input,Map < String, Object > output,Map < String, Object > options) {
        
        //String sUploadedCSVData = (string)input.get('strUploadedCSV');
        String sTypeCalculations = (string)input.get('strDataComponentName');
        System.debug('sTypeCalculations :: ' + sTypeCalculations);
        String sCalculationId = (string)input.get('strCalculationId');
        System.debug('sCalculationId :: ' + sCalculationId);
        List<Quote> listQuote = [select Id,Status from Quote where SWAN_Pricing_Calculation_Id__c =: sCalculationId OR SWAN_ReAssess_Calculation_Id__c = :sCalculationId];
        if(listQuote != null && listQuote.size()>0) {
            input.put('MasterQuoteId',listQuote[0].Id);
            if(sTypeCalculations == 'Offer summary'){
                calculateOfferSummary(input,output,options);
            }
            else if(sTypeCalculations == 'Meter level results'){
                calculateMeterLevelSummary(input,output,options);
            }
            else if(sTypeCalculations == 'Quote level results'){
                calculateOfferSummaryElec(input,output,options);
            }
            else if(sTypeCalculations == 'Volume Summary'){
                calculateVolumeSummary(input,output,options);
            }    
            else if(sTypeCalculations == 'Gas Cost Summary'){
                calculateGasCostSummary(input,output,options);
            } 
            else if(sTypeCalculations == 'Elec Meter level results'){
                calculateElecMeterLevelSummary(input,output,options);
            }
            return true;
        }
        else
            return false;
    }
    
    public static Boolean calculateOfferSummary(Map < String, Object > input,Map < String, Object > output,Map < String, Object > options) {
        try{
        map<String,Object> sUploadedCSVDataNode = (map<String,Object>)input.get('UploadData');
        String sUploadedCSVData = (string)sUploadedCSVDataNode.get('strUploadedCSVContract');
        
        //system.debug('%%%%%%%'+sUploadedCSVData);
        
        Set<Object> distinctRows = new Set<Object>();
        CSVUtils obj = new CSVUtils();
        distinctRows.addAll(obj.processContent(sUploadedCSVData));//obj.decode(
        //system.debug('$$$$$$'+distinctRows);
        Map<string,map<string,string>>CSVdataMap=new Map<string,map<string,string>>();
        for(object eachrow : distinctRows){
            Map<string,object> eachrowMap = (Map<string,object>)eachrow;
            Map<string,string>temp = new map<string,string>();
            for(string key : eachrowMap.keyset()){
                if(key!='cost_component')
                    temp.put(key,string.valueof(eachrowMap.get(key)));
            }
            CSVdataMap.put(string.valueof(eachrowMap.get('cost_component')),temp);    
        }
        //system.debug('#####'+CSVdataMap);
        if(CSVdataMap.size() > 0)
        {
            String sMasterQuoteId = (string)input.get('MasterQuoteId');
            Quote masterQuote = new Quote(Id = sMasterQuoteId);
            //Quote masterQuote = [Select id ,SWAN_Quote_for_Fuel_Type__c from Quote where id=:sMasterQuoteId limit 1];
            
            for(String key:CSVdataMap.keyset())
            {
                if(key == 'Contribution Margin') {
                    masterQuote.SWAN_Contribution_Margin__c = ((CSVdataMap.get(key).get('pounds')!=null && CSVdataMap.get(key).get('pounds')!='')?Decimal.valueOf(CSVdataMap.get(key).get('pounds')):null);
                    masterQuote.SWAN_Contribution_Margin_pc__c = ((CSVdataMap.get(key).get('percentage_of_spend')!=null && CSVdataMap.get(key).get('percentage_of_spend')!='')?Decimal.valueOf(CSVdataMap.get(key).get('percentage_of_spend')):null);
                    
                }
                else if(key == 'Commodity') {
                    masterQuote.SWAN_Commodity__c = ((CSVdataMap.get(key).get('pounds')!=null && CSVdataMap.get(key).get('pounds')!='')?Decimal.valueOf(CSVdataMap.get(key).get('pounds')):null);
                    masterQuote.SWAN_Commodity_as_pc__c = ((CSVdataMap.get(key).get('percentage_of_spend')!=null && CSVdataMap.get(key).get('percentage_of_spend')!='')?Decimal.valueOf(CSVdataMap.get(key).get('percentage_of_spend')):null);
                }
                else if(key == 'Cost to Serve') {
                    
                    Double costServe = ((CSVdataMap.get(key).get('pounds')!=null && CSVdataMap.get(key).get('pounds')!='')?Decimal.valueOf(CSVdataMap.get(key).get('pounds')):null);
                    Double costServePer = ((CSVdataMap.get(key).get('percentage_of_spend')!=null && CSVdataMap.get(key).get('percentage_of_spend')!='')?Decimal.valueOf(CSVdataMap.get(key).get('percentage_of_spend')):null);
                    
                        masterQuote.SWAN_Gross_Margin__c = costServe;
                        masterQuote.SWAN_Cost_to_Serve__c  = costServe;
                        masterQuote.SWAN_Cost_to_Serve_as_pc__c  = costServePer;
                        masterQuote.SWAN_Gross_Margin_pc__c  = costServePer;
                }
                else if(key == 'Metering') {
                    masterQuote.SWAN_Metering__c = ((CSVdataMap.get(key).get('pounds')!=null && CSVdataMap.get(key).get('pounds')!='')?Decimal.valueOf(CSVdataMap.get(key).get('pounds')):null);
                    masterQuote.SWAN_Metering_as_pc__c = ((CSVdataMap.get(key).get('percentage_of_spend')!=null && CSVdataMap.get(key).get('percentage_of_spend')!='')?Decimal.valueOf(CSVdataMap.get(key).get('percentage_of_spend')):null);
                }
                else if(key == 'Other External') {
                    masterQuote.SWAN_Other_External_Costs__c = ((CSVdataMap.get(key).get('pounds')!=null && CSVdataMap.get(key).get('pounds')!='')?Decimal.valueOf(CSVdataMap.get(key).get('pounds')):null);
                    masterQuote.SWAN_Other_External_Costs_as__c = ((CSVdataMap.get(key).get('percentage_of_spend')!=null && CSVdataMap.get(key).get('percentage_of_spend')!='')?Decimal.valueOf(CSVdataMap.get(key).get('percentage_of_spend')):null);
                }
                else if(key == 'Other Internal') {
                    masterQuote.SWAN_Other_Internal_Costs__c = ((CSVdataMap.get(key).get('pounds')!=null && CSVdataMap.get(key).get('pounds')!='')?Decimal.valueOf(CSVdataMap.get(key).get('pounds')):null);
                    masterQuote.SWAN_Other_Internal_Costs_as__c= ((CSVdataMap.get(key).get('percentage_of_spend')!=null && CSVdataMap.get(key).get('percentage_of_spend')!='')?Decimal.valueOf(CSVdataMap.get(key).get('percentage_of_spend')):null);
                }
                else if(key == 'Transportation') {
                    masterQuote.SWAN_Transportation__c = ((CSVdataMap.get(key).get('pounds')!=null && CSVdataMap.get(key).get('pounds')!='')?Decimal.valueOf(CSVdataMap.get(key).get('pounds')):null);
                    masterQuote.SWAN_Transportation_as_pc__c = ((CSVdataMap.get(key).get('percentage_of_spend')!=null && CSVdataMap.get(key).get('percentage_of_spend')!='')?Decimal.valueOf(CSVdataMap.get(key).get('percentage_of_spend')):null);
                }
                else if(key == 'Unidentified Gas Cost') {
                    masterQuote.SWAN_Unidentified_Gas_Cost__c = ((CSVdataMap.get(key).get('pounds')!=null && CSVdataMap.get(key).get('pounds')!='')?Decimal.valueOf(CSVdataMap.get(key).get('pounds')):null);
                    masterQuote.SWAN_Unidentified_Gas_Cost_as__c = ((CSVdataMap.get(key).get('percentage_of_spend')!=null && CSVdataMap.get(key).get('percentage_of_spend')!='')?Decimal.valueOf(CSVdataMap.get(key).get('percentage_of_spend')):null);
                }
                else if(key == 'Standing Charge') {
                    masterQuote.SWAN_Standing_Charge_as_split__c = ((CSVdataMap.get(key).get('percentage_of_spend')!=null && CSVdataMap.get(key).get('percentage_of_spend')!='')?Decimal.valueOf(CSVdataMap.get(key).get('percentage_of_spend')):null);
                }
                else if(key == 'Unit Rate') {
                    masterQuote.SWAN_Contract_Volume_KWh__c = ((CSVdataMap.get(key).get('kwh')!=null && CSVdataMap.get(key).get('kwh')!='')?Decimal.valueOf(CSVdataMap.get(key).get('kwh')):null);
                    masterQuote.SWAN_Unit_Rate_as_split__c = ((CSVdataMap.get(key).get('percentage_of_spend')!=null && CSVdataMap.get(key).get('percentage_of_spend')!='')?Decimal.valueOf(CSVdataMap.get(key).get('percentage_of_spend')):null);
                }
                else if(key == 'Annual Spend') {
                    masterQuote.SWAN_Annual_Spend__c = ((CSVdataMap.get(key).get('pounds')!=null && CSVdataMap.get(key).get('pounds')!='')?Decimal.valueOf(CSVdataMap.get(key).get('pounds')):null);
                }
                else if(key == 'Contract Spend') {
                    masterQuote.SWAN_Contract_Spend__c = ((CSVdataMap.get(key).get('pounds')!=null && CSVdataMap.get(key).get('pounds')!='')?Decimal.valueOf(CSVdataMap.get(key).get('pounds')):null);
                }
                else if(key == 'Broker Commission'){
                    masterQuote.SWAN_Broker_Commission__c=((CSVdataMap.get(key).get('pounds')!=null && CSVdataMap.get(key).get('pounds')!='')?Decimal.valueOf(CSVdataMap.get(key).get('pounds')):null);
                    masterQuote.SWAN_Broker_Commission_as_pc__c=((CSVdataMap.get(key).get('percentage_of_spend')!=null && CSVdataMap.get(key).get('percentage_of_spend')!='')?Decimal.valueOf(CSVdataMap.get(key).get('percentage_of_spend')):null);
                }
                else if(key == 'Non-Commodity'){
                    masterQuote.SWAN_Non_Commodity_as_pc__c=((CSVdataMap.get(key).get('percentage_of_spend')!=null && CSVdataMap.get(key).get('percentage_of_spend')!='')?Decimal.valueOf(CSVdataMap.get(key).get('percentage_of_spend')):null);
                    masterQuote.SWAN_Non_Commodity__c=((CSVdataMap.get(key).get('pounds')!=null && CSVdataMap.get(key).get('pounds')!='')?Decimal.valueOf(CSVdataMap.get(key).get('pounds')):null);
                }
                else if(key == 'AAHEDC')
                {
                    masterQuote.AAHEDC__c = ((CSVdataMap.get(key).get('pounds')!=null && CSVdataMap.get(key).get('pounds')!='')?Decimal.valueOf(CSVdataMap.get(key).get('pounds')):null);
                    masterQuote.AAHEDC_pc__c = ((CSVdataMap.get(key).get('percentage_of_spend')!=null && CSVdataMap.get(key).get('percentage_of_spend')!='')?Decimal.valueOf(CSVdataMap.get(key).get('percentage_of_spend')):null);
                }
                else if(key == 'BSUoS + RCRC')
                {
                    masterQuote.BSUoS_RCRC__c = ((CSVdataMap.get(key).get('pounds')!=null && CSVdataMap.get(key).get('pounds')!='')?Decimal.valueOf(CSVdataMap.get(key).get('pounds')):null);
                    masterQuote.BSUoS_RCRC_pc__c = ((CSVdataMap.get(key).get('percentage_of_spend')!=null && CSVdataMap.get(key).get('percentage_of_spend')!='')?Decimal.valueOf(CSVdataMap.get(key).get('percentage_of_spend')):null);
                }
                else if(key == 'Balance + Imbalance')
                {
                    masterQuote.Balance_Imbalance__c = ((CSVdataMap.get(key).get('pounds')!=null && CSVdataMap.get(key).get('pounds')!='')?Decimal.valueOf(CSVdataMap.get(key).get('pounds')):null);
                    masterQuote.Balance_Imbalance_pc__c = ((CSVdataMap.get(key).get('percentage_of_spend')!=null && CSVdataMap.get(key).get('percentage_of_spend')!='')?Decimal.valueOf(CSVdataMap.get(key).get('percentage_of_spend')):null);
                }
                else if(key == 'Capacity Market')
                {
                    masterQuote.Capacity_Market__c = ((CSVdataMap.get(key).get('pounds')!=null && CSVdataMap.get(key).get('pounds')!='')?Decimal.valueOf(CSVdataMap.get(key).get('pounds')):null);
                    masterQuote.Capacity_Market_pc__c = ((CSVdataMap.get(key).get('percentage_of_spend')!=null && CSVdataMap.get(key).get('percentage_of_spend')!='')?Decimal.valueOf(CSVdataMap.get(key).get('percentage_of_spend')):null);
                }
                else if(key == 'Contracts for Difference')
                {
                    masterQuote.Contracts_for_Difference__c = ((CSVdataMap.get(key).get('pounds')!=null && CSVdataMap.get(key).get('pounds')!='')?Decimal.valueOf(CSVdataMap.get(key).get('pounds')):null);
                    masterQuote.Contracts_for_Difference_pc__c = ((CSVdataMap.get(key).get('percentage_of_spend')!=null && CSVdataMap.get(key).get('percentage_of_spend')!='')?Decimal.valueOf(CSVdataMap.get(key).get('percentage_of_spend')):null);
                }
                else if(key == 'DUoS')
                {
                    masterQuote.DUoS__c = ((CSVdataMap.get(key).get('pounds')!=null && CSVdataMap.get(key).get('pounds')!='')?Decimal.valueOf(CSVdataMap.get(key).get('pounds')):null);
                    masterQuote.DUoS_pc__c = ((CSVdataMap.get(key).get('percentage_of_spend')!=null && CSVdataMap.get(key).get('percentage_of_spend')!='')?Decimal.valueOf(CSVdataMap.get(key).get('percentage_of_spend')):null);
                }
                else if(key == 'Feed in Tariff')
                {
                    masterQuote.Feed_in_Tariff__c = ((CSVdataMap.get(key).get('pounds')!=null && CSVdataMap.get(key).get('pounds')!='')?Decimal.valueOf(CSVdataMap.get(key).get('pounds')):null);
                    masterQuote.Feed_in_Tariff_pc__c = ((CSVdataMap.get(key).get('percentage_of_spend')!=null && CSVdataMap.get(key).get('percentage_of_spend')!='')?Decimal.valueOf(CSVdataMap.get(key).get('percentage_of_spend')):null);
                }
                else if(key == 'Other')
                {
                    masterQuote.SWAN_Other__c = ((CSVdataMap.get(key).get('pounds')!=null && CSVdataMap.get(key).get('pounds')!='')?Decimal.valueOf(CSVdataMap.get(key).get('pounds')):null);
                    masterQuote.SWAN_Other_as__c = ((CSVdataMap.get(key).get('percentage_of_spend')!=null && CSVdataMap.get(key).get('percentage_of_spend')!='')?Decimal.valueOf(CSVdataMap.get(key).get('percentage_of_spend')):null);
                }
                else if(key == 'Renewable Obligation')
                {
                    masterQuote.Renewable_Obligation__c = ((CSVdataMap.get(key).get('pounds')!=null && CSVdataMap.get(key).get('pounds')!='')?Decimal.valueOf(CSVdataMap.get(key).get('pounds')):null);
                    masterQuote.Renewable_Obligation_pc__c = ((CSVdataMap.get(key).get('percentage_of_spend')!=null && CSVdataMap.get(key).get('percentage_of_spend')!='')?Decimal.valueOf(CSVdataMap.get(key).get('percentage_of_spend')):null);
                }
                else if(key == 'TNUoS')
                {
                    masterQuote.TNUoS__c = ((CSVdataMap.get(key).get('pounds')!=null && CSVdataMap.get(key).get('pounds')!='')?Decimal.valueOf(CSVdataMap.get(key).get('pounds')):null);
                    masterQuote.TNUoS_pc__c = ((CSVdataMap.get(key).get('percentage_of_spend')!=null && CSVdataMap.get(key).get('percentage_of_spend')!='')?Decimal.valueOf(CSVdataMap.get(key).get('percentage_of_spend')):null);
                }
                
            }
            update masterQuote;
            return true;
        }
        else
            return false;
        }
        catch(Exception ex){
            input.put('exceptionOccur',true);
            //output.put('exceptionOccur',true);
            //system.debug('Exception ::'+ex.getmessage());
            return false;
        }
    }
    

    public static Boolean calculateOfferSummaryElec(Map < String, Object > input,Map < String, Object > output,Map < String, Object > options) {
        system.debug('calculateOfferSummaryElec quoteID: '+input.get('MasterQuoteId'));
        system.debug('uploaddate: '+input.get('UploadData'));
        try{
            map<String,Object> sUploadedCSVDataNode = (map<String,Object>)input.get('UploadData');
            String sUploadedCSVData;
            if(sUploadedCSVDataNode.containsKey('strUploadedCSVContract')){
                sUploadedCSVData = (string)sUploadedCSVDataNode.get('strUploadedCSVContract');
            }else{
                input.put('exceptionOccur',true);
                return false;
            }
            
            Set<Object> distinctRows = new Set<Object>();
            CSVUtils obj = new CSVUtils();
            distinctRows.addAll(obj.processContent(sUploadedCSVData));//obj.decode(

            Map<string,map<string,string>>CSVdataMap=new Map<string,map<string,string>>();
            
            for(object eachrow : distinctRows){
                Map<string,object> eachrowMap = (Map<string,object>)eachrow;
                Map<string,string>temp = new map<string,string>();
                
                for(string key : eachrowMap.keyset()){
                    if(key!='cost_component')
                        temp.put(key,string.valueof(eachrowMap.get(key)));
                }
                CSVdataMap.put(string.valueof(eachrowMap.get('cost_component')),temp);    
            }

            if(CSVdataMap.size() > 0){
                
                String sMasterQuoteId = (string)input.get('MasterQuoteId');
                Quote masterQuote = new Quote(Id = sMasterQuoteId);
                for(String key:CSVdataMap.keyset())
                {
                    if(key == 'Contribution Margin') {
                        masterQuote.SWAN_Contribution_Margin__c = ((CSVdataMap.get(key).get('pounds')!=null && CSVdataMap.get(key).get('pounds')!='')?Decimal.valueOf(CSVdataMap.get(key).get('pounds')):null);
                        masterQuote.SWAN_Contribution_Margin_pc__c = ((CSVdataMap.get(key).get('percentage_of_spend')!=null && CSVdataMap.get(key).get('percentage_of_spend')!='')?Decimal.valueOf(CSVdataMap.get(key).get('percentage_of_spend')):null);
                    }
                    else if(key == 'Broker Commission'){
                        masterQuote.SWAN_Broker_Commission__c=((CSVdataMap.get(key).get('pounds')!=null && CSVdataMap.get(key).get('pounds')!='')?Decimal.valueOf(CSVdataMap.get(key).get('pounds')):null);
                        masterQuote.SWAN_Broker_Commission_as_pc__c=((CSVdataMap.get(key).get('percentage_of_spend')!=null && CSVdataMap.get(key).get('percentage_of_spend')!='')?Decimal.valueOf(CSVdataMap.get(key).get('percentage_of_spend')):null);
                    }
                    else if(key == 'Commodity') {
                        masterQuote.SWAN_Commodity__c = ((CSVdataMap.get(key).get('pounds')!=null && CSVdataMap.get(key).get('pounds')!='')?Decimal.valueOf(CSVdataMap.get(key).get('pounds')):null);
                        masterQuote.SWAN_Commodity_as_pc__c = ((CSVdataMap.get(key).get('percentage_of_spend')!=null && CSVdataMap.get(key).get('percentage_of_spend')!='')?Decimal.valueOf(CSVdataMap.get(key).get('percentage_of_spend')):null);
                    }
                    else if(key == 'Cost to Serve') {
                        masterQuote.SWAN_Gross_Margin__c = ((CSVdataMap.get(key).get('pounds')!=null && CSVdataMap.get(key).get('pounds')!='')?Decimal.valueOf(CSVdataMap.get(key).get('pounds')):null);
                        masterQuote.SWAN_Cost_to_Serve__c = ((CSVdataMap.get(key).get('pounds')!=null && CSVdataMap.get(key).get('pounds')!='')?Decimal.valueOf(CSVdataMap.get(key).get('pounds')):null);
                        masterQuote.SWAN_Cost_to_Serve_as_pc__c = ((CSVdataMap.get(key).get('percentage_of_spend')!=null && CSVdataMap.get(key).get('percentage_of_spend')!='')?Decimal.valueOf(CSVdataMap.get(key).get('percentage_of_spend')):null);
                        masterQuote.SWAN_Gross_Margin_pc__c = ((CSVdataMap.get(key).get('percentage_of_spend')!=null && CSVdataMap.get(key).get('percentage_of_spend')!='')?Decimal.valueOf(CSVdataMap.get(key).get('percentage_of_spend')):null);
                    }
                    else if(key == 'AAHEDC') {
                        masterQuote.AAHEDC__c = ((CSVdataMap.get(key).get('pounds')!=null && CSVdataMap.get(key).get('pounds')!='')?Decimal.valueOf(CSVdataMap.get(key).get('pounds')):null);
                        masterQuote.AAHEDC_pc__c = ((CSVdataMap.get(key).get('percentage_of_spend')!=null && CSVdataMap.get(key).get('percentage_of_spend')!='')?Decimal.valueOf(CSVdataMap.get(key).get('percentage_of_spend')):null);
                        
                    }
                    else if(key == 'BSUoS + RCRC') {
                        masterQuote.BSUoS_RCRC__c = ((CSVdataMap.get(key).get('pounds')!=null && CSVdataMap.get(key).get('pounds')!='')?Decimal.valueOf(CSVdataMap.get(key).get('pounds')):null);
                        masterQuote.BSUoS_RCRC_pc__c = ((CSVdataMap.get(key).get('percentage_of_spend')!=null && CSVdataMap.get(key).get('percentage_of_spend')!='')?Decimal.valueOf(CSVdataMap.get(key).get('percentage_of_spend')):null);
                        
                    }
                    else if(key == 'Contracts for Difference') {
                        masterQuote.Contracts_for_Difference__c = ((CSVdataMap.get(key).get('pounds')!=null && CSVdataMap.get(key).get('pounds')!='')?Decimal.valueOf(CSVdataMap.get(key).get('pounds')):null);
                        masterQuote.Contracts_for_Difference_pc__c = ((CSVdataMap.get(key).get('percentage_of_spend')!=null && CSVdataMap.get(key).get('percentage_of_spend')!='')?Decimal.valueOf(CSVdataMap.get(key).get('percentage_of_spend')):null);
                        
                    }
                    else if(key == 'Capacity Market') {
                        masterQuote.Capacity_Market__c = ((CSVdataMap.get(key).get('pounds')!=null && CSVdataMap.get(key).get('pounds')!='')?Decimal.valueOf(CSVdataMap.get(key).get('pounds')):null);
                        masterQuote.Capacity_Market_pc__c = ((CSVdataMap.get(key).get('percentage_of_spend')!=null && CSVdataMap.get(key).get('percentage_of_spend')!='')?Decimal.valueOf(CSVdataMap.get(key).get('percentage_of_spend')):null);
                        
                    }
                    else if(key == 'DUoS') {
                        masterQuote.DUoS__c = ((CSVdataMap.get(key).get('pounds')!=null && CSVdataMap.get(key).get('pounds')!='')?Decimal.valueOf(CSVdataMap.get(key).get('pounds')):null);
                        masterQuote.DUoS_pc__c = ((CSVdataMap.get(key).get('percentage_of_spend')!=null && CSVdataMap.get(key).get('percentage_of_spend')!='')?Decimal.valueOf(CSVdataMap.get(key).get('percentage_of_spend')):null);
                        
                    }
                    else if(key == 'Feed in Tariff') {
                        masterQuote.Feed_in_Tariff__c = ((CSVdataMap.get(key).get('pounds')!=null && CSVdataMap.get(key).get('pounds')!='')?Decimal.valueOf(CSVdataMap.get(key).get('pounds')):null);
                        masterQuote.Feed_in_Tariff_pc__c = ((CSVdataMap.get(key).get('percentage_of_spend')!=null && CSVdataMap.get(key).get('percentage_of_spend')!='')?Decimal.valueOf(CSVdataMap.get(key).get('percentage_of_spend')):null);
                        
                    }
                    else if(key == 'Balance + Imbalance') {
                        masterQuote.Balance_Imbalance__c = ((CSVdataMap.get(key).get('pounds')!=null && CSVdataMap.get(key).get('pounds')!='')?Decimal.valueOf(CSVdataMap.get(key).get('pounds')):null);
                        masterQuote.Balance_Imbalance_pc__c = ((CSVdataMap.get(key).get('percentage_of_spend')!=null && CSVdataMap.get(key).get('percentage_of_spend')!='')?Decimal.valueOf(CSVdataMap.get(key).get('percentage_of_spend')):null);
                        
                    }
                    else if(key == 'Renewable Obligation') {
                        masterQuote.Renewable_Obligation__c = ((CSVdataMap.get(key).get('pounds')!=null && CSVdataMap.get(key).get('pounds')!='')?Decimal.valueOf(CSVdataMap.get(key).get('pounds')):null);
                        masterQuote.Renewable_Obligation_pc__c = ((CSVdataMap.get(key).get('percentage_of_spend')!=null && CSVdataMap.get(key).get('percentage_of_spend')!='')?Decimal.valueOf(CSVdataMap.get(key).get('percentage_of_spend')):null);
                        
                    }
                    else if(key == 'TNUoS') {
                        masterQuote.TNUoS__c = ((CSVdataMap.get(key).get('pounds')!=null && CSVdataMap.get(key).get('pounds')!='')?Decimal.valueOf(CSVdataMap.get(key).get('pounds')):null);
                        masterQuote.TNUoS_pc__c = ((CSVdataMap.get(key).get('percentage_of_spend')!=null && CSVdataMap.get(key).get('percentage_of_spend')!='')?Decimal.valueOf(CSVdataMap.get(key).get('percentage_of_spend')):null);
                    }
                    else if(key == 'Renewable Supply') {
                        masterQuote.Renewable_Supply__c = ((CSVdataMap.get(key).get('pounds')!=null && CSVdataMap.get(key).get('pounds')!='')?Decimal.valueOf(CSVdataMap.get(key).get('pounds')):null);
                        masterQuote.Renewable_Supply_pc__c = ((CSVdataMap.get(key).get('percentage_of_spend')!=null && CSVdataMap.get(key).get('percentage_of_spend')!='')?Decimal.valueOf(CSVdataMap.get(key).get('percentage_of_spend')):null);
                        
                    }
                    else if(key == 'Annual Spend') {
                        masterQuote.SWAN_Annual_Spend__c = ((CSVdataMap.get(key).get('pounds')!=null && CSVdataMap.get(key).get('pounds')!='')?Decimal.valueOf(CSVdataMap.get(key).get('pounds')):null);
                    }
                    else if(key == 'Contract Spend') {
                        masterQuote.SWAN_Contract_Spend__c = ((CSVdataMap.get(key).get('pounds')!=null && CSVdataMap.get(key).get('pounds')!='')?Decimal.valueOf(CSVdataMap.get(key).get('pounds')):null);
                        masterQuote.SWAN_Contract_Spend_Electricity__c = ((CSVdataMap.get(key).get('pounds')!=null && CSVdataMap.get(key).get('pounds')!='')?Decimal.valueOf(CSVdataMap.get(key).get('pounds')):null);
                    }
                    else if(key == 'Contract Volume') {
                        masterQuote.SWAN_Contract_Volume_KWh__c = ((CSVdataMap.get(key).get('kwh')!=null && CSVdataMap.get(key).get('kwh')!='')?Decimal.valueOf(CSVdataMap.get(key).get('kwh')):null);
                    }
                    else if(key == 'Annual Volume') {
                        masterQuote.Annual_Volume__c = ((CSVdataMap.get(key).get('kwh')!=null && CSVdataMap.get(key).get('kwh')!='')?Decimal.valueOf(CSVdataMap.get(key).get('kwh')):null);
                    }
                    else if(key == 'Metering'){
                        masterQuote.SWAN_Metering__c = ((CSVdataMap.get(key).get('pounds')!=null && CSVdataMap.get(key).get('pounds')!='')?Decimal.valueOf(CSVdataMap.get(key).get('pounds')):null);
                        masterQuote.SWAN_Metering_as_pc__c = ((CSVdataMap.get(key).get('percentage_of_spend')!=null && CSVdataMap.get(key).get('percentage_of_spend')!='')?Decimal.valueOf(CSVdataMap.get(key).get('percentage_of_spend')):null);
                    }
                    else if(key == 'Other'){
                        masterQuote.SWAN_Other__c = ((CSVdataMap.get(key).get('pounds')!=null && CSVdataMap.get(key).get('pounds')!='')?Decimal.valueOf(CSVdataMap.get(key).get('pounds')):null);
                        masterQuote.SWAN_Other_as__c = ((CSVdataMap.get(key).get('percentage_of_spend')!=null && CSVdataMap.get(key).get('percentage_of_spend')!='')?Decimal.valueOf(CSVdataMap.get(key).get('percentage_of_spend')):null);
                    }
                    else if(key == 'Contract Spend Excluding Pass Through') {
                        masterQuote.SWAN_Contract_Spend_Excluding_Pass_Thru__c = ((CSVdataMap.get(key).get('pounds')!=null && CSVdataMap.get(key).get('pounds')!='')?Decimal.valueOf(CSVdataMap.get(key).get('pounds')):null);
                    }
                }
                masterQuote.SWAN_Price_out_of_Date__c = false;
                update masterQuote;
                return true;
            }else{
                return false;
            }

        } catch(Exception ex){
            input.put('exceptionOccur',true);
            return false;
        }
    }
    
    public static Boolean calculateMeterLevelSummary(Map < String, Object > input,Map < String, Object > output,Map < String, Object > options) {
        try{
            //map<String,Object> sUploadedCSVDataNode = (map<String,Object>)input.get('UploadData');
            String sUploadedCSVData = (string)input.get('strUploadedCSV');
            Boolean isException = (input.get('exceptionOccur')!=null?(Boolean)input.get('exceptionOccur'):false);
            
            String sMasterQuoteId = (string)input.get('MasterQuoteId');
            List<AggregateResult> results = [Select count(Id) from Quote where vlocity_cmt__ParentQuoteId__c=:sMasterQuoteId AND Recordtype.DeveloperName != 'GroupCart'];
            Integer count = Integer.valueOf(results[0].get('expr0'));
            
            if(!isException)
            {
                Set<Object> distinctRows = new Set<Object>();
                CSVUtils obj = new CSVUtils();
                distinctRows.addAll(obj.SWAN_processContent(sUploadedCSVData));//obj.decode(
                //system.debug('====='+sUploadedCSVData+'distinctRowssssssss'+distinctRows.size());
                Map<string, Object>meterCSVdataMap=new Map<string,Object>();
                for(object eachrow : distinctRows){
                    Map<string,object> eachrowMap = (Map<string,object>)eachrow;         
                    if(!meterCSVdataMap.containskey(string.valueof(eachrowMap.get('mprn'))))
                    {
                        List<object>temp = new list<object>();
                        temp.add(eachrow);
                        meterCSVdataMap.put(string.valueof(eachrowMap.get('mprn')),temp);    
                    }
                    else
                    {
                        List<object>temp = (List<object>)meterCSVdataMap.get(string.valueof(eachrowMap.get('mprn')));
                        temp.add(eachrow);
                        meterCSVdataMap.put(string.valueof(eachrowMap.get('mprn')),temp);    
                    }
                }
                
                Map<string,object>FinalMap = new map<string,object>();
                //system.debug('#######'+meterCSVdataMap.size());
                for(string mprnkey : meterCSVdataMap.keyset())
                {
                    Map<string,map<string,string>>CSVdataMap=new Map<string,map<string,string>>();
                    for(object eachrow1 : (List<object>)meterCSVdataMap.get(mprnkey))
                    {
                        
                        Map<string,object> eachrowMap1 = (Map<string,object>)eachrow1;
                        Map<string,string>temp = new map<string,string>();
                        for(string key : eachrowMap1.keyset()){
                            if(key!='cost_component')
                                temp.put(key,string.valueof(eachrowMap1.get(key)));
                        }
                        CSVdataMap.put(string.valueof(eachrowMap1.get('cost_component')),temp); 
                    }
                    FinalMap.put(mprnkey,CSVdataMap);
                }
                //system.debug(count+'count===\n'+FinalMap.get('9907007')+'FinalMap#######'+FinalMap.size());
                if(count<=50)
                {
                    //Sync process
                    List<Quote> ChildQuote = [SELECT id,
                                              vlocity_cmt__ParentQuoteId__c,
                                              vlocity_cmt__ParentQuoteId__r.status,
                                              vlocity_cmt__ParentQuoteId__r.SWAN_Quote_Type__c,
                                              status,vlocity_cmt__DefaultServicePointId__c,
                                              SWAN_Contract_Volume_KWh__c,
                                              vlocity_cmt__DefaultServicePointId__r.vlocity_cmt__ServicePointNumber__c, 
                                              SWAN_Contract_Spend__c, SWAN_Annual_Spend__c,SWAN_Broker_Commission__c,
                                              (SELECT Id, QuoteId, SWAN_UnitRate__c, vlocity_cmt__RecurringCharge__c, Product2.ProductCode FROM
                                               QuoteLineItems) 
                                              FROM Quote 
                                              WHERE vlocity_cmt__ParentQuoteId__c=:sMasterQuoteId 
                                              AND Recordtype.DeveloperName !='GroupCart'];
                    
                    processMeterLevelData(ChildQuote,JSON.serializePretty(FinalMap),false);
                }
                else{ //Batch Process
                    //system.debug('===>ExecuteBatch');
                    //Database.executeBatch(new SWAN_UpdateMeterLevelBatch(sMasterQuoteId,JSON.serializePretty(FinalMap),false),200);
                    Database.executeBatch(new SWAN_UpdateMeterLevelBatch(sMasterQuoteId,FinalMap,false,'GAS'),200);
                }
                return true;
            }
            else
            {
                if(count<=50) 
                {
                    List<Quote> failedQList = new List<Quote>();
                    for(Quote qt:[SELECT id,status FROM Quote WHERE (vlocity_cmt__ParentQuoteId__c=:sMasterQuoteId AND Recordtype.DeveloperName !='GroupCart') OR Id=:sMasterQuoteId])
                    {
                        qt.Status = 'Failed Pricing';
                        failedQList.add(qt);
                    }
                    if(failedQList.size() > 0)
                        update failedQList;
                }
                else 
                    Database.executeBatch(new SWAN_UpdateMeterLevelBatch(sMasterQuoteId,null,true,'GAS'),200);
                
                output.put('exceptionOccur',true);    
                return false;
            }
        }
        catch(exception ex){
            //system.debug('Exception ::'+ex.getmessage());
            output.put('exceptionOccur',true);
            return false;
        }
    }
    
    public static string processMeterLevelData(List<Quote> childQList,String jsonCSV,boolean isAsync)
    {
        Map<string,object> MeterVScsvData = (Map<string,object>)JSON.deserializeUntyped(jsonCSV);
        //system.debug(MeterVScsvData +'\n******\n'+jsonCSV);
        
        List<Quote> qList = new List<quote>();
        Quote MasterQuote;
        string masterQuotestatus;
        List<Quotelineitem> qliList = new List<quotelineitem>();
        for(Quote q : childQList)
        {
            //system.debug('SP number==>'+q.vlocity_cmt__DefaultServicePointId__r.vlocity_cmt__ServicePointNumber__c);
            if(MeterVScsvData.containskey(q.vlocity_cmt__DefaultServicePointId__r.vlocity_cmt__ServicePointNumber__c))
            {
                Map<string,object>MPRNCsvdetails = (Map<string,object>)MeterVScsvData.get(q.vlocity_cmt__DefaultServicePointId__r.vlocity_cmt__ServicePointNumber__c);
                boolean isChildQuoteChanged=false;
                for(String key : MPRNCsvdetails.keyset())
                {
                    if(key == 'Unit Rate' || key == 'Standing Charge' || key == 'Total Broker Commission') 
                    {
                        for(QuotelineItem qli : q.quotelineitems)
                        {
                            if(qli.Product2.ProductCode=='BG_UNITRATE' && key == 'Unit Rate')
                            {
                                qli.SWAN_UnitRate__c = ((((Map<string,object>)MPRNCsvdetails.get(key)).get('pence_per_kwh')!=null && ((Map<string,object>)MPRNCsvdetails.get(key)).get('pence_per_kwh')!='')?Decimal.valueOf(string.valueof(((Map<string,object>)MPRNCsvdetails.get(key)).get('pence_per_kwh'))):null);
                                qliList.add(qli);
                            }
                            else if(qli.Product2.ProductCode=='BG_STD' && key == 'Standing Charge')
                            {
                                qli.vlocity_cmt__RecurringCharge__c=((((Map<string,object>)MPRNCsvdetails.get(key)).get('pence_per_day')!=null && ((Map<string,object>)MPRNCsvdetails.get(key)).get('pence_per_day')!='')?Decimal.valueOf(string.valueof(((Map<string,object>)MPRNCsvdetails.get(key)).get('pence_per_day'))):null);
                                qliList.add(qli);
                            }
                        }
                        if(key == 'Unit Rate')
                        {
                            q.SWAN_Contract_Volume_KWh__c = ((((Map<string,object>)MPRNCsvdetails.get(key)).get('kwh')!=null && ((Map<string,object>)MPRNCsvdetails.get(key)).get('kwh')!='')?Decimal.valueOf(string.valueof(((Map<string,object>)MPRNCsvdetails.get(key)).get('kwh'))):null);
                            isChildQuoteChanged=true;
                        }
                        if(key == 'Total Broker Commission')
                        {
                            q.SWAN_Broker_Commission__c = ((((Map<string,object>)MPRNCsvdetails.get(key)).get('contract_spend')!=null && ((Map<string,object>)MPRNCsvdetails.get(key)).get('contract_spend')!='')?Decimal.valueOf(string.valueof(((Map<string,object>)MPRNCsvdetails.get(key)).get('contract_spend'))):null);
                            isChildQuoteChanged=true;
                        } 
                        if(q.status!='Failed Pricing')
                        {
                            q.status='Priced';
                            isChildQuoteChanged=true;
                        }
                    }
                    else if(key == 'Total Revenue')
                    {
                        q.SWAN_Contract_Spend__c = ((((Map<string,object>)MPRNCsvdetails.get(key)).get('contract_spend')!=null && ((Map<string,object>)MPRNCsvdetails.get(key)).get('contract_spend')!='')?Decimal.valueOf(string.valueof(((Map<string,object>)MPRNCsvdetails.get(key)).get('contract_spend'))):null);
                        if(q.vlocity_cmt__ParentQuoteId__r.SWAN_Quote_Type__c == 'Flex')
                        q.SWAN_Contract_Volume_KWh__c = ((((Map<string,object>)MPRNCsvdetails.get(key)).get('volume')!=null && ((Map<string,object>)MPRNCsvdetails.get(key)).get('volume')!='')?Decimal.valueOf(string.valueof(((Map<string,object>)MPRNCsvdetails.get(key)).get('volume'))):null);
                        q.SWAN_Annual_Spend__c = ((((Map<string,object>)MPRNCsvdetails.get(key)).get('annual_spend')!=null && ((Map<string,object>)MPRNCsvdetails.get(key)).get('annual_spend')!='')?Decimal.valueOf(string.valueof(((Map<string,object>)MPRNCsvdetails.get(key)).get('annual_spend'))):null);
                        isChildQuoteChanged=true;
                        if(q.status!='Failed Pricing' && q.vlocity_cmt__ParentQuoteId__r.SWAN_Quote_Type__c == 'Flex')
                        {
                            q.status='Priced';
                            isChildQuoteChanged=true;
                        }
                    }
                    else if (key == 'Error')
                    {   
                        q.status = 'Failed Pricing';
                        isChildQuoteChanged=true;
                        masterQuotestatus = 'Failed Pricing';
                        MasterQuote = new Quote(id=q.vlocity_cmt__ParentQuoteId__c,status='Failed Pricing');
                    }
                }
                
                if(isChildQuoteChanged)
                    qList.add(q);
            }
        }
        //system.debug(isAsync +'=='+masterQuotestatus+'=='+childQList[0].vlocity_cmt__ParentQuoteId__r.status);
        if(!isAsync)
        {
            if(MasterQuote != null)
                qList.add(MasterQuote);
            else if(childQList[0].vlocity_cmt__ParentQuoteId__r.status=='Draft')
                qList.add(new Quote(id=childQList[0].vlocity_cmt__ParentQuoteId__c,status='Priced'));            
        }
        else if(isAsync && masterQuotestatus!='Failed Pricing' && childQList[0].vlocity_cmt__ParentQuoteId__r.status=='Draft')
        {    
            masterQuotestatus = 'Priced';
        }
        
        if(qliList.size()>0)
            update qliList;
            
        if(qList.size() > 0)
            update qList;
        //system.debug('Finalllll masterQuotestatussss::'+masterQuotestatus);
        return masterQuotestatus;
    }
    
    public static Boolean calculateElecMeterLevelSummary(Map < String, Object > input,Map < String, Object > output,Map < String, Object > options) {
        system.debug('calculateElecMeterLevelSummary strUploadedCSV: '+input.get('strUploadedCSV'));
        try{
            //map<String,Object> sUploadedCSVDataNode = (map<String,Object>)input.get('UploadData');
            String sUploadedCSVData = (string)input.get('strUploadedCSV');
            Boolean isException = (input.get('exceptionOccur')!=null?(Boolean)input.get('exceptionOccur'):false);
            
            String sMasterQuoteId = (string)input.get('MasterQuoteId');
            List<AggregateResult> results = [Select count(Id) from Quote where vlocity_cmt__ParentQuoteId__c=:sMasterQuoteId AND Recordtype.DeveloperName != 'GroupCart'];
            Integer count = Integer.valueOf(results[0].get('expr0'));
            
            if(!isException)
            {
                Set<Object> distinctRows = new Set<Object>();
                CSVUtils obj = new CSVUtils();
                distinctRows.addAll(obj.SWAN_processContent(sUploadedCSVData));//obj.decode(
                //system.debug('distinctRowssssssss'+distinctRows.size());
                Map<string, Object>meterCSVdataMap=new Map<string,Object>();
                for(object eachrow : distinctRows){
                    Map<string,object> eachrowMap = (Map<string,object>)eachrow;         
                    if(!meterCSVdataMap.containskey(string.valueof(eachrowMap.get('mpan'))))
                    {
                        List<object>temp = new list<object>();
                        temp.add(eachrow);
                        meterCSVdataMap.put(string.valueof(eachrowMap.get('mpan')),temp);    
                    }
                    else
                    {
                        List<object>temp = (List<object>)meterCSVdataMap.get(string.valueof(eachrowMap.get('mpan')));
                        temp.add(eachrow);
                        meterCSVdataMap.put(string.valueof(eachrowMap.get('mpan')),temp);    
                    }
                }
                
                Map<string,object>FinalMap = new map<string,object>();
                //system.debug('#######'+meterCSVdataMap.size());
                for(string mpankey : meterCSVdataMap.keyset())
                {
                    Map<string,map<string,string>>CSVdataMap=new Map<string,map<string,string>>();
                    for(object eachrow1 : (List<object>)meterCSVdataMap.get(mpankey))
                    {
                        
                        Map<string,object> eachrowMap1 = (Map<string,object>)eachrow1;
                        Map<string,string>temp = new map<string,string>();
                        for(string key : eachrowMap1.keyset()){
                            if(key!='output')
                                temp.put(key,string.valueof(eachrowMap1.get(key)));
                        }
                        CSVdataMap.put(string.valueof(eachrowMap1.get('output')),temp); 
                    }
                    FinalMap.put(mpankey,CSVdataMap);
                }
                //system.debug(count+'count===\n'+FinalMap.get('9907007')+'FinalMap#######'+FinalMap.size());
                if(count<=50)
                {
                    //Sync process
                    List<Quote> ChildQuote = [SELECT id,
                                              vlocity_cmt__ParentQuoteId__c,
                                              vlocity_cmt__ParentQuoteId__r.status,
                                              status,vlocity_cmt__DefaultServicePointId__c,
                                              SWAN_Contract_Volume_KWh__c,
                                              vlocity_cmt__DefaultServicePointId__r.vlocity_cmt__ServicePointNumber__c, 
                                              SWAN_Contract_Spend__c, SWAN_Annual_Spend__c,SWAN_Broker_Commission__c,
                                              vlocity_cmt__ParentQuoteId__r.SWAN_Quote_Type__c,
                                              (SELECT Id,QuoteId, SWAN_UnitRate__c, vlocity_cmt__RecurringCharge__c,
                                               Product2.ProductCode , Product2.Name 
                                               FROM
                                               QuoteLineItems) 
                                              FROM Quote 
                                              WHERE vlocity_cmt__ParentQuoteId__c=:sMasterQuoteId 
                                              AND Recordtype.DeveloperName !='GroupCart'  
                                              AND vlocity_cmt__QuoteGroupId__r.vlocity_cmt__MemberType__c!='Business_Account'];
                    
                    processElecMeterLevelData(ChildQuote,JSON.serializePretty(FinalMap),false);
                }
                else{ //Batch Process
                    //system.debug('===>ExecuteBatch');
                    //Database.executeBatch(new SWAN_UpdateMeterLevelBatch(sMasterQuoteId,JSON.serializePretty(FinalMap),false),200);
                    Database.executeBatch(new SWAN_UpdateMeterLevelBatch(sMasterQuoteId,FinalMap,false,'Elec'),200);
                }
                return true;
            }
            else
            {
                if(count<=50) 
                {
                    List<Quote> failedQList = new List<Quote>();
                    for(Quote qt:[SELECT id,status FROM Quote WHERE (vlocity_cmt__ParentQuoteId__c=:sMasterQuoteId AND Recordtype.DeveloperName !='GroupCart') OR Id=:sMasterQuoteId])
                    {
                        qt.Status = 'Failed Pricing';
                        failedQList.add(qt);
                    }
                    if(failedQList.size() > 0)
                        update failedQList;
                }
                else 
                    Database.executeBatch(new SWAN_UpdateMeterLevelBatch(sMasterQuoteId,null,true,'Elec'),200);
                
                output.put('exceptionOccur',true);    
                return false;
            }
        }
        catch(exception ex){
            //system.debug('Exception ::'+ex.getmessage());
            output.put('exceptionOccur',true);
            return false;
        }
    }
    
    public static string processElecMeterLevelData(List<Quote> childQList,String jsonCSV,boolean isAsync)
    {
        Map<string,object> MeterVScsvData = (Map<string,object>)JSON.deserializeUntyped(jsonCSV);
        SWAN_Elec_Products__c elecProd = SWAN_Elec_Products__c.getInstance();
        //system.debug(MeterVScsvData +'\n******\n'+jsonCSV);
        
        List<Quote> qList = new List<quote>();
        Quote MasterQuote;
        string masterQuotestatus;
        List<Quotelineitem> qliList = new List<quotelineitem>();
        for(Quote q : childQList)
        {
            boolean isChildQuoteChanged=false;
            //system.debug('SP number==>'+q.vlocity_cmt__DefaultServicePointId__r.vlocity_cmt__ServicePointNumber__c);
            System.debug('q.vlocity_cmt__DefaultServicePointId__r.vlocity_cmt__ServicePointNumber__c ::: ' + q.vlocity_cmt__DefaultServicePointId__r.vlocity_cmt__ServicePointNumber__c);
            System.debug('MeterVScsvData.containskey(q.vlocity_cmt__DefaultServicePointId__r.vlocity_cmt__ServicePointNumber__c) ::: ' + MeterVScsvData.containskey(q.vlocity_cmt__DefaultServicePointId__r.vlocity_cmt__ServicePointNumber__c));
            
            if(MeterVScsvData.containskey(q.vlocity_cmt__DefaultServicePointId__r.vlocity_cmt__ServicePointNumber__c))
            {
                Map<string,object>MPANCsvdetails = (Map<string,object>)MeterVScsvData.get(q.vlocity_cmt__DefaultServicePointId__r.vlocity_cmt__ServicePointNumber__c);
                if(MPANCsvdetails != null)
                {
                    for(String key : MPANCsvdetails.keyset())
                    {//system.debug('===='+key);
                        if( ((Map<string,object>)MPANCsvdetails.get(key)).get('price_type') == 'Standing Charge' || ((Map<string,object>)MPANCsvdetails.get(key)).get('price_type') == 'Unit Charge' || ((Map<string,object>)MPANCsvdetails.get(key)).get('price_type') == 'Availability Charge')  //key.contains('Unit Charge') || key.contains('Standing Charge'))
                        {
                            for(QuotelineItem qli : q.quotelineitems)
                            {
                                if( (key == qli.Product2.Name) )
                                {
                                    qli.SWAN_UnitRate__c = ((((Map<string,object>)MPANCsvdetails.get(key)).get('price')!=null && ((Map<string,object>)MPANCsvdetails.get(key)).get('price')!='')?Decimal.valueOf(string.valueof(((Map<string,object>)MPANCsvdetails.get(key)).get('price'))):null);
                                    qli.vlocity_cmt__UsageUnitPrice__c = qli.SWAN_UnitRate__c;
                                    qliList.add(qli);
                                }
                                else if(qli.Product2.ProductCode==elecProd.Availability_Charge_Code__c && key == elecProd.Availability_Charge_Key__c)
                                {
                                    qli.vlocity_cmt__UsageUnitPrice__c = ((((Map<string,object>)MPANCsvdetails.get(key)).get('price')!=null && ((Map<string,object>)MPANCsvdetails.get(key)).get('price')!='')?Decimal.valueOf(string.valueof(((Map<string,object>)MPANCsvdetails.get(key)).get('price'))):null);
                                    qliList.add(qli);
                                }
                                else if(qli.Product2.ProductCode==elecProd.Standing_Charge_Code__c && key == elecProd.Standing_Charge_Key__c)
                                {
                                    qli.vlocity_cmt__RecurringCharge__c = ((((Map<string,object>)MPANCsvdetails.get(key)).get('price')!=null && ((Map<string,object>)MPANCsvdetails.get(key)).get('price')!='')?Decimal.valueOf(string.valueof(((Map<string,object>)MPANCsvdetails.get(key)).get('price'))):null);
                                    qli.vlocity_cmt__UsageUnitPrice__c = qli.vlocity_cmt__RecurringCharge__c;
                                    qliList.add(qli);
                                }
                            }
                            if(q.status!='Failed Pricing')
                            {
                                q.status='Priced';
                                isChildQuoteChanged=true;
                            }
                        }
                        else if(key == 'Broker Commission')
                        {
                            q.SWAN_Broker_Commission__c = ((((Map<string,object>)MPANCsvdetails.get(key)).get('pounds')!=null && ((Map<string,object>)MPANCsvdetails.get(key)).get('pounds')!='')?Decimal.valueOf(string.valueof(((Map<string,object>)MPANCsvdetails.get(key)).get('pounds'))):null);
                            isChildQuoteChanged=true;
                        }
                        else if(key == 'Contract Spend')
                        {
                            q.SWAN_Contract_Spend__c = ((((Map<string,object>)MPANCsvdetails.get(key)).get('pounds')!=null && ((Map<string,object>)MPANCsvdetails.get(key)).get('pounds')!='')?Decimal.valueOf(string.valueof(((Map<string,object>)MPANCsvdetails.get(key)).get('pounds'))):null);
                            isChildQuoteChanged=true;
                        }
                        else if(key == 'Annual Spend')
                        {
                            q.SWAN_Annual_Spend__c = ((((Map<string,object>)MPANCsvdetails.get(key)).get('pounds')!=null && ((Map<string,object>)MPANCsvdetails.get(key)).get('pounds')!='')?Decimal.valueOf(string.valueof(((Map<string,object>)MPANCsvdetails.get(key)).get('pounds'))):null);
                            isChildQuoteChanged=true;
                        }
                        else if(key == 'Contract kWh')
                        {
                            q.SWAN_Contract_Volume_KWh__c = ((((Map<string,object>)MPANCsvdetails.get(key)).get('usage')!=null && ((Map<string,object>)MPANCsvdetails.get(key)).get('usage')!='')?Decimal.valueOf(string.valueof(((Map<string,object>)MPANCsvdetails.get(key)).get('usage'))):null);
                            isChildQuoteChanged=true;
                        }
                        else if(key == 'Annual kWh')
                        {
                            q.Annual_Volume__c = ((((Map<string,object>)MPANCsvdetails.get(key)).get('usage')!=null && ((Map<string,object>)MPANCsvdetails.get(key)).get('usage')!='')?Decimal.valueOf(string.valueof(((Map<string,object>)MPANCsvdetails.get(key)).get('usage'))):null);
                            isChildQuoteChanged=true;
                        }
						else if(key == 'AAHEDC Pass Through Price' || key == 'BSUoS Pass Through Price')
                        {
                            for(QuotelineItem qli : q.quotelineitems)
                            {
                                if((key == qli.Product2.Name))
                                {
                                    qli.SWAN_UnitRate__c = ((((Map<string,object>)MPANCsvdetails.get(key)).get('price')!=null && ((Map<string,object>)MPANCsvdetails.get(key)).get('price')!='')?Decimal.valueOf(string.valueof(((Map<string,object>)MPANCsvdetails.get(key)).get('price'))):null);
                                    qli.vlocity_cmt__UsageUnitPrice__c = qli.SWAN_UnitRate__c;
                                    qliList.add(qli);
                                }
                            }
                        }
                        else if(key == 'Error')
                        {   
                            q.status = 'Failed Pricing';
                            isChildQuoteChanged=true;
                            masterQuotestatus = 'Failed Pricing';
                            MasterQuote = new Quote(id=q.vlocity_cmt__ParentQuoteId__c,status='Failed Pricing');
                        }
                    }
                }
                else {
                    q.status = 'Failed Pricing';
                    isChildQuoteChanged=true;
                    masterQuotestatus = 'Failed Pricing';
                    MasterQuote = new Quote(id=q.vlocity_cmt__ParentQuoteId__c,status='Failed Pricing');
                }  
            }
            else
            {
                q.status = 'Failed Pricing';
                isChildQuoteChanged=true;
                masterQuotestatus = 'Failed Pricing';
                MasterQuote = new Quote(id=q.vlocity_cmt__ParentQuoteId__c,status='Failed Pricing');
            }
            if(isChildQuoteChanged)
            {
                if(q.vlocity_cmt__ParentQuoteId__r.SWAN_Quote_Type__c.startsWithIgnoreCase('Flex') && q.status!='Failed Pricing')
                    q.status='Priced';
                qList.add(q);
            }
        }
        //system.debug(isAsync +'=='+masterQuotestatus+'=='+childQList[0].vlocity_cmt__ParentQuoteId__r.status);
        if(!isAsync)
        {
            if(MasterQuote != null)
                qList.add(MasterQuote);
            else if(childQList[0].vlocity_cmt__ParentQuoteId__r.status=='Draft')
                qList.add(new Quote(id=childQList[0].vlocity_cmt__ParentQuoteId__c,status='Priced'));            
        }
        else if(isAsync && masterQuotestatus!='Failed Pricing' && childQList[0].vlocity_cmt__ParentQuoteId__r.status=='Draft')
        {    
            masterQuotestatus = 'Priced';
        }
        
        if(qliList.size()>0)
            update qliList;
            
        if(qList.size() > 0)
            update qList;
        //system.debug('Finalllll masterQuotestatussss::'+masterQuotestatus);
        return masterQuotestatus;
    }
    
    public static Boolean calculateVolumeSummary(Map < String, Object > input,Map < String, Object > output,Map < String, Object > options) {
        try{
            String sUploadedCSVData = (string)input.get('strUploadedCSV');
            system.debug('%%%%%%%volume'+sUploadedCSVData);
            
            Set<Object> distinctRows = new Set<Object>();
            CSVUtils obj = new CSVUtils();
            //distinctRows.addAll(obj.processContent(sUploadedCSVData));//obj.decode(
            distinctRows.addAll(obj.SWAN_processContent(sUploadedCSVData));//obj.decode(
            system.debug('$$$$$$volume'+distinctRows);
            Map<string,map<string,string>>CSVdataMap=new Map<string,map<string,string>>();
            for(object eachrow : distinctRows){
                Map<string,object> eachrowMap = (Map<string,object>)eachrow;
                Map<string,string>temp = new map<string,string>();
                for(string key : eachrowMap.keyset()){
                    if(key!='order')
                        temp.put(key,string.valueof(eachrowMap.get(key)));
                }
                CSVdataMap.put(string.valueof(eachrowMap.get('order')),temp);    
            }
            system.debug('#####volume'+CSVdataMap);
            if(CSVdataMap.size() > 0)
            {
                String sMasterQuoteId = (string)input.get('MasterQuoteId');
                Quote childQuote = [SELECT id,name FROM Quote WHERE RecordType.DeveloperName = 'SubQuote' AND vlocity_cmt__ParentQuoteId__c = :sMasterQuoteId AND vlocity_cmt__QuoteGroupId__r.vlocity_cmt__MemberType__c = 'Business_Account' Limit 1];

                List<QuoteLineItem> masterQuote_QLI = [SELECT id,product2.vlocity_cmt__type__c,quoteid,product2.name,LineNumber, Quote.vlocity_cmt__ParentQuoteId__r.SWAN_Quote_for_Fuel_Type__c, 
                    product2.vlocity_cmt__SubType__c, Product2Id, Product2.ProductCode FROM QuoteLineItem WHERE (Product2.vlocity_cmt__Type__c = 'Volume Summary' AND QuoteId =:childQuote.Id) order by LineNumber];

                Map<String,String> order_LineNumber_Map = new Map<String,String>();
                
                for(Integer i=0;i < masterQuote_QLI.size();i++){
                    if(i == 0){
                        order_LineNumber_Map.put(masterQuote_QLI[i].LineNumber,'Total');
                    }
                    else{
                         order_LineNumber_Map.put(masterQuote_QLI[i].LineNumber,String.valueOf(i));
                    }
                }
                system.debug('#####order_LineNumber_Map'+order_LineNumber_Map);
                for(QuoteLineItem qlitem : masterQuote_QLI){
                    system.debug('Type: '+qlitem.product2.vlocity_cmt__Type__c+' Sub-Type: '+qlitem.product2.vlocity_cmt__SubType__c);
                    String season;
                    String quarter;
                    String month;
                    String kwh;
                    String mwh;
                    String therms;
                    String tradable_clips_therms_per_day;
                    String total_kwh;
                    String total_therms;
                    String average_tradable_clips_therm;
                    //fields for elec
                    String baseload_clip_mw;
                    String baseload_volume_mwh;
                    String peak_clip_mw;
                    String peak_volume_mwh;
                    String residual_sell_mwh;
                    String residual_buy_mwh;
                    String residual_total_mwh;
                    String total_mwh;

                    String baseload_reference_price_pounds_mwh;
                    String peak_reference_price_pounds_mwh;
                    
                    String BaseLoad_Clip_Average_MW;
                    String Peak_Clip_Average_MW;
                    String BaseLoad_Volume_MWh_Percentage;
                    String Peak_Volume_MWh_Percentage;
                    String Residual_Sell_MWh_Percentage;
                    String Residual_Buy_MWh_Percentage;
                    String Residual_Total_MWh_Percentage;
                    String Total_MWh_Percentage;
                    String Total_Volume_MSP_MWh;
                    String Total_Volume_GSP_MWh;
                    String Total_Volume_NBP_MWh;
                    String Distribution_Losses;
                    String Transmission_Losses;
                    String Peak_Volume_Percentage;

                    //If our QLI is Elec and is the Summary Total
                    if(!qlitem.Quote.vlocity_cmt__ParentQuoteId__r.SWAN_Quote_for_Fuel_Type__c.equalsIgnoreCase('Gas') && qlitem.product2.vlocity_cmt__SubType__c.equalsIgnoreCase('Summary Total')){
                        
                        String averageKey = 'Average';
                        String totalKey = 'Total';
                        String percentageKey = 'Percentage';
                        String summaryKey = 'Summary';
                        map<string,string>DRinput=new Map<string,string>();
                        //Items from average row
                        BaseLoad_Clip_Average_MW = ((CSVdataMap.get(averageKey).get('baseload_clip_mw')!=null && CSVdataMap.get(averageKey).get('baseload_clip_mw')!='')?String.valueOf(CSVdataMap.get(averageKey).get('baseload_clip_mw')):null);
                        DRinput.put('BaseLoad_Clip_Average_MW',BaseLoad_Clip_Average_MW);
                        Peak_Clip_Average_MW = ((CSVdataMap.get(averageKey).get('peak_clip_mw')!=null && CSVdataMap.get(averageKey).get('peak_clip_mw')!='')?String.valueOf(CSVdataMap.get(averageKey).get('peak_clip_mw')):null);
                        DRinput.put('Peak_Clip_Average_MW',Peak_Clip_Average_MW);
                        baseload_reference_price_pounds_mwh = ((CSVdataMap.get(averageKey).get('baseload_reference_price_pounds_mwh')!=null && CSVdataMap.get(averageKey).get('baseload_reference_price_pounds_mwh')!='')?String.valueOf(CSVdataMap.get(averageKey).get('baseload_reference_price_pounds_mwh')):null);
                        DRinput.put('Peak_Clip_Average_MW',Peak_Clip_Average_MW);
                        peak_reference_price_pounds_mwh = ((CSVdataMap.get(averageKey).get('peak_reference_price_pounds_mwh')!=null && CSVdataMap.get(averageKey).get('peak_reference_price_pounds_mwh')!='')?String.valueOf(CSVdataMap.get(averageKey).get('peak_reference_price_pounds_mwh')):null);
                        DRinput.put('peak_reference_price_pounds_mwh',peak_reference_price_pounds_mwh);

                        //Items from total row
                        baseload_volume_mwh = ((CSVdataMap.get(totalKey).get('baseload_volume_mwh')!=null && CSVdataMap.get(totalKey).get('baseload_volume_mwh')!='')?String.valueOf(CSVdataMap.get(totalKey).get('baseload_volume_mwh')):null);
                        DRinput.put('baseload_volume_mwh',baseload_volume_mwh);
                        peak_volume_mwh = ((CSVdataMap.get(totalKey).get('peak_volume_mwh')!=null && CSVdataMap.get(totalKey).get('peak_volume_mwh')!='')?String.valueOf(CSVdataMap.get(totalKey).get('peak_volume_mwh')):null);
                        DRinput.put('peak_volume_mwh',peak_volume_mwh);
                        residual_sell_mwh = ((CSVdataMap.get(totalKey).get('residual_sell_mwh')!=null && CSVdataMap.get(totalKey).get('residual_sell_mwh')!='')?String.valueOf(CSVdataMap.get(totalKey).get('residual_sell_mwh')):null);
                        DRinput.put('residual_sell_mwh',residual_sell_mwh);
                        residual_buy_mwh = ((CSVdataMap.get(totalKey).get('residual_buy_mwh')!=null && CSVdataMap.get(totalKey).get('residual_buy_mwh')!='')?String.valueOf(CSVdataMap.get(totalKey).get('residual_buy_mwh')):null);
                        DRinput.put('residual_buy_mwh',residual_buy_mwh);
                        residual_total_mwh = ((CSVdataMap.get(totalKey).get('residual_total_mwh')!=null && CSVdataMap.get(totalKey).get('residual_total_mwh')!='')?String.valueOf(CSVdataMap.get(totalKey).get('residual_total_mwh')):null);
                        DRinput.put('residual_total_mwh',residual_total_mwh);
                        total_mwh = ((CSVdataMap.get(totalKey).get('total_mwh')!=null && CSVdataMap.get(totalKey).get('total_mwh')!='')?String.valueOf(CSVdataMap.get(totalKey).get('total_mwh')):null);
                        DRinput.put('total_mwh',total_mwh);

                        //Items from percentage key
                        BaseLoad_Volume_MWh_Percentage = ((CSVdataMap.get(percentageKey).get('baseload_volume_mwh')!=null && CSVdataMap.get(percentageKey).get('baseload_volume_mwh')!='')?String.valueOf(CSVdataMap.get(percentageKey).get('baseload_volume_mwh')):null);
                        Drinput.put('BaseLoad_Volume_MWh_Percentage',BaseLoad_Volume_MWh_Percentage);
                        Peak_Volume_MWh_Percentage = ((CSVdataMap.get(percentageKey).get('peak_volume_mwh')!=null && CSVdataMap.get(percentageKey).get('peak_volume_mwh')!='')?String.valueOf(CSVdataMap.get(percentageKey).get('peak_volume_mwh')):null);
                        DRinput.put('Peak_Volume_MWh_Percentage',Peak_Volume_MWh_Percentage);
                        Residual_Sell_MWh_Percentage = ((CSVdataMap.get(percentageKey).get('residual_sell_mwh')!=null && CSVdataMap.get(percentageKey).get('residual_sell_mwh')!='')?String.valueOf(CSVdataMap.get(percentageKey).get('residual_sell_mwh')):null);
                        DRinput.put('Residual_Sell_MWh_Percentage',Residual_Sell_MWh_Percentage);
                        Residual_Buy_MWh_Percentage = ((CSVdataMap.get(percentageKey).get('residual_buy_mwh')!=null && CSVdataMap.get(percentageKey).get('residual_buy_mwh')!='')?String.valueOf(CSVdataMap.get(percentageKey).get('residual_buy_mwh')):null);
                        Drinput.put('Residual_Buy_MWh_Percentage',Residual_Buy_MWh_Percentage);
                        Residual_Total_MWh_Percentage = ((CSVdataMap.get(percentageKey).get('residual_total_mwh')!=null && CSVdataMap.get(percentageKey).get('residual_total_mwh')!='')?String.valueOf(CSVdataMap.get(percentageKey).get('residual_total_mwh')):null);
                        DRinput.put('Residual_Total_MWh_Percentage',Residual_Total_MWh_Percentage);
                        Total_MWh_Percentage = ((CSVdataMap.get(percentageKey).get('total_mwh')!=null && CSVdataMap.get(percentageKey).get('total_mwh')!='')?String.valueOf(CSVdataMap.get(percentageKey).get('total_mwh')):null);
                        DRinput.put('Total_MWh_Percentage',Total_MWh_Percentage);

                        //Item from Summary key
                        Total_Volume_MSP_MWh = ((CSVdataMap.get(summaryKey).get('total_msp_volume_mwh')!=null && CSVdataMap.get(summaryKey).get('total_msp_volume_mwh')!='')?String.valueOf(CSVdataMap.get(summaryKey).get('total_msp_volume_mwh')):null);
                        DRinput.put('Total_Volume_MSP_MWh',Total_Volume_MSP_MWh);
                        Total_Volume_GSP_MWh = ((CSVdataMap.get(summaryKey).get('total_gsp_volume_mwh')!=null && CSVdataMap.get(summaryKey).get('total_gsp_volume_mwh')!='')?String.valueOf(CSVdataMap.get(summaryKey).get('total_gsp_volume_mwh')):null);
                        Drinput.put('Total_Volume_GSP_MWh',Total_Volume_GSP_MWh);
                        Total_Volume_NBP_MWh = ((CSVdataMap.get(summaryKey).get('total_nbp_volume_mwh')!=null && CSVdataMap.get(summaryKey).get('total_nbp_volume_mwh')!='')?String.valueOf(CSVdataMap.get(summaryKey).get('total_nbp_volume_mwh')):null);
                        DRinput.put('Total_Volume_NBP_MWh',Total_Volume_NBP_MWh);
                        Distribution_Losses = ((CSVdataMap.get(summaryKey).get('distribution_losses')!=null && CSVdataMap.get(summaryKey).get('distribution_losses')!='')?String.valueOf(CSVdataMap.get(summaryKey).get('distribution_losses')):null);
                        DRinput.put('Distribution_Losses',Distribution_Losses);
                        Transmission_Losses = ((CSVdataMap.get(summaryKey).get('transmission_losses')!=null && CSVdataMap.get(summaryKey).get('transmission_losses')!='')?String.valueOf(CSVdataMap.get(summaryKey).get('transmission_losses')):null);
                        DRinput.put('Transmission_Losses',Transmission_Losses);
                        Peak_Volume_Percentage = ((CSVdataMap.get(summaryKey).get('peak_volume_percentage')!=null && CSVdataMap.get(summaryKey).get('peak_volume_percentage')!='')?String.valueOf(CSVdataMap.get(summaryKey).get('peak_volume_percentage')):null);
                        DRinput.put('Peak_Volume_Percentage',Peak_Volume_Percentage);

                        //QLI ID
                        DRinput.put('Id',((String)qlitem.id));

                        //Serialize JSON and assign to variable so we can debug without serializing twice as it's a processing heavy operation
                        string dataJson = JSON.serializePretty(DRinput, false);
                        system.debug('#####dataJson '+dataJson );
                        
                        //Send to dataraptor to execute
                        vlocity_cmt.DRProcessResult result = vlocity_cmt.DRGlobal.processObjectsJSON(dataJson, 'SWAN_LoadVolumeSummaryQLIAttributesElecV2');
                    }

                    for(String key:CSVdataMap.keyset())
                    {
                        system.debug('calculateVolumeSummary key: '+key);
                        if(qlitem.Quote.vlocity_cmt__ParentQuoteId__r.SWAN_Quote_for_Fuel_Type__c.equalsIgnoreCase('Gas')){
                            if(key == String.valueOf(order_LineNumber_Map.get(qlitem.LineNumber))) {
                                season = ((CSVdataMap.get(key).get('season')!=null && CSVdataMap.get(key).get('season')!='')?String.valueOf(CSVdataMap.get(key).get('season')):null);
                                quarter = ((CSVdataMap.get(key).get('quarter')!=null && CSVdataMap.get(key).get('quarter')!='')?String.valueOf(CSVdataMap.get(key).get('quarter')):null);
                                month = ((CSVdataMap.get(key).get('month')!=null && CSVdataMap.get(key).get('month')!='')?String.valueOf(CSVdataMap.get(key).get('month')):null);
                                kwh = ((CSVdataMap.get(key).get('kwh')!=null && CSVdataMap.get(key).get('kwh')!='')?String.valueOf(CSVdataMap.get(key).get('kwh')):null);
                                mwh = ((CSVdataMap.get(key).get('mwh')!=null && CSVdataMap.get(key).get('mwh')!='')?String.valueOf(CSVdataMap.get(key).get('mwh')):null);
                                therms = ((CSVdataMap.get(key).get('therms')!=null && CSVdataMap.get(key).get('therms')!='')?String.valueOf(CSVdataMap.get(key).get('therms')):null);
                                tradable_clips_therms_per_day = ((CSVdataMap.get(key).get('tradable_clips_therms_per_day')!=null && CSVdataMap.get(key).get('tradable_clips_therms_per_day')!='')?String.valueOf(CSVdataMap.get(key).get('tradable_clips_therms_per_day')):null);
                                total_kwh = ((CSVdataMap.get(key).get('total_kwh')!=null && CSVdataMap.get(key).get('total_kwh')!='')?String.valueOf(CSVdataMap.get(key).get('total_kwh')):null);
                                total_therms = ((CSVdataMap.get(key).get('total_therms')!=null && CSVdataMap.get(key).get('total_therms')!='')?String.valueOf(CSVdataMap.get(key).get('total_therms')):null);
                                average_tradable_clips_therm = ((CSVdataMap.get(key).get('average_tradable_clip_therm')!=null && CSVdataMap.get(key).get('average_tradable_clip_therm')!='')?String.valueOf(CSVdataMap.get(key).get('average_tradable_clip_therm')):null);
                            }
                        }else{
                           if(key == String.valueOf(order_LineNumber_Map.get(qlitem.LineNumber)) && !qlitem.product2.vlocity_cmt__SubType__c.equalsIgnoreCase('Summary Total')) {
                                season = ((CSVdataMap.get(key).get('season')!=null && CSVdataMap.get(key).get('season')!='')?String.valueOf(CSVdataMap.get(key).get('season')):null);
                                quarter = ((CSVdataMap.get(key).get('quarter')!=null && CSVdataMap.get(key).get('quarter')!='')?String.valueOf(CSVdataMap.get(key).get('quarter')):null);
                                month = ((CSVdataMap.get(key).get('month')!=null && CSVdataMap.get(key).get('month')!='')?String.valueOf(CSVdataMap.get(key).get('month')):null);
                                baseload_clip_mw = ((CSVdataMap.get(key).get('baseload_clip_mw')!=null && CSVdataMap.get(key).get('baseload_clip_mw')!='')?String.valueOf(CSVdataMap.get(key).get('baseload_clip_mw')):null);
                                baseload_volume_mwh = ((CSVdataMap.get(key).get('baseload_volume_mwh')!=null && CSVdataMap.get(key).get('baseload_volume_mwh')!='')?String.valueOf(CSVdataMap.get(key).get('baseload_volume_mwh')):null);
                                peak_clip_mw = ((CSVdataMap.get(key).get('peak_clip_mw')!=null && CSVdataMap.get(key).get('peak_clip_mw')!='')?String.valueOf(CSVdataMap.get(key).get('peak_clip_mw')):null);
                                peak_volume_mwh = ((CSVdataMap.get(key).get('peak_volume_mwh')!=null && CSVdataMap.get(key).get('peak_volume_mwh')!='')?String.valueOf(CSVdataMap.get(key).get('peak_volume_mwh')):null);
                                residual_sell_mwh = ((CSVdataMap.get(key).get('residual_sell_mwh')!=null && CSVdataMap.get(key).get('residual_sell_mwh')!='')?String.valueOf(CSVdataMap.get(key).get('residual_sell_mwh')):null);
                                residual_buy_mwh = ((CSVdataMap.get(key).get('residual_buy_mwh')!=null && CSVdataMap.get(key).get('residual_buy_mwh')!='')?String.valueOf(CSVdataMap.get(key).get('residual_buy_mwh')):null);
                                residual_total_mwh = ((CSVdataMap.get(key).get('residual_total_mwh')!=null && CSVdataMap.get(key).get('residual_total_mwh')!='')?String.valueOf(CSVdataMap.get(key).get('residual_total_mwh')):null);
                                total_mwh = ((CSVdataMap.get(key).get('total_mwh')!=null && CSVdataMap.get(key).get('total_mwh')!='')?String.valueOf(CSVdataMap.get(key).get('total_mwh')):null);
                                baseload_reference_price_pounds_mwh = ((CSVdataMap.get(key).get('baseload_reference_price_pounds_mwh')!=null && CSVdataMap.get(key).get('baseload_reference_price_pounds_mwh')!='')?String.valueOf(CSVdataMap.get(key).get('baseload_reference_price_pounds_mwh')):null);
                                peak_reference_price_pounds_mwh = ((CSVdataMap.get(key).get('peak_reference_price_pounds_mwh')!=null && CSVdataMap.get(key).get('peak_reference_price_pounds_mwh')!='')?String.valueOf(CSVdataMap.get(key).get('peak_reference_price_pounds_mwh')):null);

                                map<string,string>DRinput=new Map<string,string>{'Id'=>((String)qlitem.id),'Season'=>season,'Quarter'=>quarter,'Month'=>month,'baseload_clip_mw'=>baseload_clip_mw,'baseload_volume_mwh'=>baseload_volume_mwh,'peak_clip_mw'=>peak_clip_mw,'peak_volume_mwh'=>peak_volume_mwh,'residual_sell_mwh'=>residual_sell_mwh,'residual_buy_mwh'=>residual_buy_mwh,'residual_total_mwh'=>residual_total_mwh,'total_mwh'=>total_mwh,'baseload_reference_price_pounds_mwh'=>baseload_reference_price_pounds_mwh,'peak_reference_price_pounds_mwh'=>peak_reference_price_pounds_mwh,'testValue'=>'testValue'};
                                string dataJson = JSON.serializePretty(DRinput, false);
                                system.debug('#####dataJson '+dataJson );
                                vlocity_cmt.DRProcessResult result = vlocity_cmt.DRGlobal.processObjectsJSON(dataJson, 'SWAN_LoadVolumeSummaryQLIAttributesElecV2');
                            } 
                        }
                    }
                    if(qlitem.Quote.vlocity_cmt__ParentQuoteId__r.SWAN_Quote_for_Fuel_Type__c.equalsIgnoreCase('Gas')){
                        map<string,string>DRinput=new Map<string,string>{'Id'=>((String)qlitem.id),'Season'=>season,'Quarter'=>quarter,'Month'=>month,'Therms'=>therms,'Kwh'=>kwh,'Mwh'=>mwh,'Tradable_clips_therms_per_day'=>tradable_clips_therms_per_day,'Total_kwh'=>total_kwh,'Total_therms'=>total_therms,'Average_tradable_clips_therm'=>average_tradable_clips_therm};
                        string dataJson = JSON.serializePretty(DRinput, false);
                        system.debug('#####dataJson '+dataJson );
                        vlocity_cmt.DRProcessResult result = vlocity_cmt.DRGlobal.processObjectsJSON(dataJson, 'SWAN_LoadVolumeSummaryQLIAttributes');
                    }
                }
                //update masterQuote;
                return true;
            }
            else
                return false;
        }
        catch(Exception ex){
            input.put('exceptionOccur',true);
            //output.put('exceptionOccur',true);
            //system.debug('Exception ::'+ex.getmessage());
            return false;
        }
    }
    
    public static Boolean processFlexSummary(Map < String, Object > input,Map < String, Object > output,Map < String, Object > options){
        system.debug('System Debug processFlexSummary strUploadedCSVURL: '+(string)input.get('strUploadedCSVURL')+'\ninput: '+input);
        String sUploadedCSVData = (string)input.get('strUploadedCSVURL');
        String strCalculationId = (string)input.get('strCalculationId');

        Map<String, QuoteLineItem> mapQLIByProductName = new Map<String, QuoteLineItem>();
        List<QuoteLineItem> lstFlexPriceSummary = new List<QuoteLineItem>();
        
        for( QuoteLineItem qli : [SELECT Id, 
                                  vlocity_cmt__OneTimeCost__c, 
                                  vlocity_cmt__UsageUnitPrice__c, 
                                  SWAN_UsageUnitPriceGSP__c, 
                                  SWAN_UsageUnitPriceNBP__c,
                                  Quote.SWAN_Quote_for_Fuel_Type__c, 
                                  Product2Id, 
                                  Product2.Name
                                  FROM QuoteLineItem 
                                  WHERE Product2.vlocity_cmt__IsOrderable__c = false
                                  AND QuoteId IN ( SELECT Id FROM Quote  WHERE (vlocity_cmt__ParentQuoteId__r.SWAN_Pricing_Calculation_Id__c =: strCalculationId OR vlocity_cmt__ParentQuoteId__r.SWAN_ReAssess_Calculation_Id__c = :strCalculationId)
                                                  AND RecordType.DeveloperName='SubQuote'  
                                                  AND vlocity_cmt__QuoteGroupId__r.vlocity_cmt__MemberType__c='Business_Account')]){
                                                      
            mapQLIByProductName.put(qli.Product2.Name, qli);
        }

        List<String> tableRows = new List<String>();
        tableRows = sUploadedCSVData.split('\n');
        Integer indexCategory=0;
        Integer indexComponent=0;
        Integer indexPounds=0;
        Integer indexPrice_at_msp_pound_per_mwh=0;
        Integer indexPrice_at_gsp_pound_per_mwh=0;
        Integer indexPrice_at_nbp_pound_per_mwh=0;
        system.debug('tableRows size: '+tableRows.size());
        for( Integer i = 0 ;  i < tableRows.size() ; i++ ){
            system.debug('tableRows size: '+tableRows.size());
            List<String> cells = new List<String>();
            cells = tableRows[i].split(',');
            system.debug('cells size: '+cells.size());
            system.debug('ROW: '+tableRows[i]);
            //if index 0, register header index 
            for( Integer j=0 ; j <  cells.size() && i == 0 ; j++ ){
                
                if( i == 0){
                    if(cells[j] =='category'){
                        indexCategory=j;
                    }else if(cells[j] =='component'){
                        indexComponent=j;
                    }else if(cells[j] =='pounds'){
                        indexPounds=j;
                    }else if(cells[j] =='price_at_msp_pound_per_mwh'){
                        indexPrice_at_msp_pound_per_mwh=j;
                    }else if(cells[j] =='price_at_gsp_pound_per_mwh'){
                        indexPrice_at_gsp_pound_per_mwh=j;
                    }else if(cells[j] =='price_at_nbp_pound_per_mwh'){
                        indexPrice_at_nbp_pound_per_mwh=j;
                    }
                } 
            }
            //start map csv fields into QLIs
             if( i > 0 && cells[indexComponent] != 'TOTAL' &&  mapQLIByProductName.get(cells[indexComponent]) != NULL){
                
                Integer  rowSize = cells.size();
                QuoteLineItem qli =mapQLIByProductName.get(cells[indexComponent]);
                //system.debug('cells[indexPrice_at_msp_pound_per_mwh]='+cells[indexPrice_at_msp_pound_per_mwh]);
                qli.vlocity_cmt__OneTimeCost__c = ( rowSize <= indexPounds ? null : cells[indexPounds] != null && cells[indexPounds] != '' ? Decimal.valueOf(cells[indexPounds]) : null );
                qli.vlocity_cmt__UsageUnitPrice__c = ( rowSize <= indexPrice_at_msp_pound_per_mwh ? null: cells[indexPrice_at_msp_pound_per_mwh] != null && cells[indexPrice_at_msp_pound_per_mwh] != '' ? Decimal.valueOf(cells[indexPrice_at_msp_pound_per_mwh]) : null );
                qli.SWAN_UsageUnitPriceGSP__c = ( rowSize <= indexPrice_at_gsp_pound_per_mwh ? null: cells[indexPrice_at_gsp_pound_per_mwh] != null && cells[indexPrice_at_gsp_pound_per_mwh] != '' ? Decimal.valueOf(cells[indexPrice_at_gsp_pound_per_mwh]) : null );
                qli.SWAN_UsageUnitPriceNBP__c = ( rowSize <= indexPrice_at_nbp_pound_per_mwh ? null: cells[indexPrice_at_nbp_pound_per_mwh] != null && cells[indexPrice_at_nbp_pound_per_mwh] != '' ? Decimal.valueOf(cells[indexPrice_at_nbp_pound_per_mwh]) : null );
                
                lstFlexPriceSummary.add(qli);

            }else if(i > 0 && cells[indexComponent] == 'TOTAL' &&  mapQLIByProductName.get(cells[indexCategory]) != NULL){
                
                Integer  rowSize = cells.size();
                QuoteLineItem qli =mapQLIByProductName.get(cells[indexCategory]);
                
                qli.vlocity_cmt__OneTimeCost__c = ( rowSize <= indexPounds ? null : Decimal.valueOf(cells[indexPounds]) );
                qli.vlocity_cmt__UsageUnitPrice__c = ( rowSize <= indexPrice_at_msp_pound_per_mwh ? null: cells[indexPrice_at_msp_pound_per_mwh] != null && cells[indexPrice_at_msp_pound_per_mwh] != '' ? Decimal.valueOf(cells[indexPrice_at_msp_pound_per_mwh]) : null);
                qli.SWAN_UsageUnitPriceGSP__c = ( rowSize <= indexPrice_at_gsp_pound_per_mwh ? null: cells[indexPrice_at_gsp_pound_per_mwh] != null && cells[indexPrice_at_gsp_pound_per_mwh] != '' ? Decimal.valueOf(cells[indexPrice_at_gsp_pound_per_mwh]) : null );
                qli.SWAN_UsageUnitPriceNBP__c = ( rowSize <= indexPrice_at_nbp_pound_per_mwh ? null: cells[indexPrice_at_nbp_pound_per_mwh] != null && cells[indexPrice_at_nbp_pound_per_mwh] != '' ? Decimal.valueOf(cells[indexPrice_at_nbp_pound_per_mwh]) : null );

                lstFlexPriceSummary.add(qli);

            }
        }
        system.debug('lstFlexPriceSummary: '+lstFlexPriceSummary+'\tmapQLIByProductName: '+mapQLIByProductName);
        try {
            if(mapQLIByProductName.size() > 0 ){
                Database.SaveResult [] results = Database.update(lstFlexPriceSummary, false);
            }
            return true;   
            
        } catch (DmlException e) {
            // Process exception here
            system.debug('processFlexPriceSummary Exception: ' + e.getMessage());
            return false;
        }
    }
    
        public static Boolean calculateGasCostSummary(Map < String, Object > input,Map < String, Object > output,Map < String, Object > options){
        
        String sUploadedCSVData = (string)input.get('strUploadedCSVURL');
        String strCalculationId = (string)input.get('strCalculationId');

        Map<String, QuoteLineItem> mapQLIByProductName = new Map<String, QuoteLineItem>();
        Map<String, QuoteLineItem> mapQLIByProductType = new Map<String, QuoteLineItem>();
        List<QuoteLineItem> lstGasCostSummary = new List<QuoteLineItem>();
        
        for( QuoteLineItem qli : [SELECT Id, 
                                  vlocity_cmt__OneTimeCost__c, 
                                  SWAN_Cost_Recovery__c,
                                  SWAN_UnitRate__c,
                                  SWAN_Unit_Rate_Therms__c,
                                  vlocity_cmt__RecurringCharge__c,
                                  vlocity_cmt__UsageUnitPrice__c,
                                  Quote.SWAN_Quote_for_Fuel_Type__c, 
                                  Product2Id, 
                                  Product2.vlocity_cmt__Type__c,
                                  Product2.Name
                                  FROM QuoteLineItem 
                                  WHERE Product2.vlocity_cmt__IsOrderable__c = false
                                  AND QuoteId IN ( SELECT Id FROM Quote  WHERE 
                                                  (vlocity_cmt__ParentQuoteId__r.SWAN_Pricing_Calculation_Id__c =: strCalculationId OR vlocity_cmt__ParentQuoteId__r.SWAN_ReAssess_Calculation_Id__c =: strCalculationId)
                                                  AND RecordType.DeveloperName='SubQuote'  
                                                  AND vlocity_cmt__QuoteGroupId__r.vlocity_cmt__MemberType__c='Business_Account') ]){
                                                      
            mapQLIByProductName.put(qli.Product2.Name, qli);
            mapQLIByProductType.put(qli.Product2.vlocity_cmt__Type__c, qli);
        }

        List<String> tableRows = new List<String>();
        tableRows = sUploadedCSVData.split('\n');
        Integer indexComponent=0;
        Integer indexRecovery=0;
        Integer indexPounds=0;
        Integer indexPound_per_mwh=0;
        Integer indexPence_per_kwh=0;
        Integer indexPence_per_therm=0;
        Integer indexPence_per_day=0;
        
        for( Integer i = 0 ;  i < tableRows.size() ; i++ ){
            
            List<String> cells = new List<String>();
            cells = tableRows[i].split(',');
            //if index 0, register header index 
            for( Integer j=0 ; j <  cells.size() && i == 0 ; j++ ){
                
                if( i == 0){
                    if(cells[j] =='component'){
                        indexComponent=j;
                    }else if(cells[j] =='recovery'){
                        indexRecovery=j;
                    }else if(cells[j] =='pounds'){
                        indexPounds=j;
                    }else if(cells[j] =='pound_per_mwh'){
                        indexPound_per_mwh=j;
                    }else if(cells[j] =='pence_per_kwh'){
                        indexPence_per_kwh=j;
                    }else if(cells[j] =='pence_per_therm'){
                        indexPence_per_therm=j;
                    }else if(cells[j] =='pence_per_day'){
                        indexPence_per_day=j;
                    }
                } 
            }
            //start map csv fields into QLIs
            if( i > 0 && cells[indexRecovery] == 'Fixed' &&  mapQLIByProductName.get(cells[indexComponent]) != NULL){
                
                Integer  rowSize = cells.size();
                QuoteLineItem qli =mapQLIByProductName.get(cells[indexComponent]);
                
                qli.SWAN_Cost_Recovery__c = ( rowSize <= indexRecovery ? null : String.valueOf(cells[indexRecovery]) );
                qli.vlocity_cmt__OneTimeCost__c = ( rowSize <= indexPounds ? null : Decimal.valueOf(cells[indexPounds]) );
                qli.vlocity_cmt__RecurringCharge__c = ( rowSize <= indexPence_per_day ? null: Decimal.valueOf(cells[indexPence_per_day]) );
                
                lstGasCostSummary.add(qli);

            }else if(i > 0 && cells[indexRecovery] == 'Variable' &&  mapQLIByProductName.get(cells[indexComponent]) != NULL){
                
                Integer  rowSize = cells.size();
                QuoteLineItem qli =mapQLIByProductName.get(cells[indexComponent]);
                
                qli.SWAN_Cost_Recovery__c = ( rowSize <= indexRecovery ? null : String.valueOf(cells[indexRecovery]) );
                qli.vlocity_cmt__OneTimeCost__c = ( rowSize <= indexPounds ? null : Decimal.valueOf(cells[indexPounds]) );
                qli.vlocity_cmt__UsageUnitPrice__c = ( rowSize <= indexPound_per_mwh ? null : Decimal.valueOf(cells[indexPound_per_mwh]) );
                qli.SWAN_UnitRate__c = ( rowSize <= indexPence_per_kwh ? null: Decimal.valueOf(cells[indexPence_per_kwh]) );
                qli.SWAN_Unit_Rate_Therms__c = ( rowSize <= indexPence_per_therm ? null: Decimal.valueOf(cells[indexPence_per_therm]) );

                lstGasCostSummary.add(qli);

            }else if(i > 0 && cells[indexRecovery] == ''){
                
                Integer  rowSize = cells.size();
                QuoteLineItem qli =mapQLIByProductType.get('Cost Flex');
                
                qli.vlocity_cmt__RecurringCharge__c = ( rowSize <= indexPence_per_day ? null: Decimal.valueOf(cells[indexPence_per_day]) );
                qli.vlocity_cmt__OneTimeCost__c = ( rowSize <= indexPounds ? null : Decimal.valueOf(cells[indexPounds]) );
                qli.vlocity_cmt__UsageUnitPrice__c = ( rowSize <= indexPound_per_mwh ? null : Decimal.valueOf(cells[indexPound_per_mwh]) );
                qli.SWAN_UnitRate__c = ( rowSize <= indexPence_per_kwh ? null: Decimal.valueOf(cells[indexPence_per_kwh]) );
                qli.SWAN_Unit_Rate_Therms__c = ( rowSize <= indexPence_per_therm ? null: Decimal.valueOf(cells[indexPence_per_therm]) );

                lstGasCostSummary.add(qli);

            }
            
        }
        
        try {
            if(mapQLIByProductName.size() > 0 ){
                Database.SaveResult [] results = Database.update(lstGasCostSummary, false);
            }
            return true;   
            
        } catch (DmlException e) {
            // Process exception here
            system.debug('calculateGasCostSummary Exception: ' + e.getMessage());
            return false;
        }
    }
}