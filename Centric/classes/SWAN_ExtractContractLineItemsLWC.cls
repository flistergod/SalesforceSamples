//Test class: SWAN_ExtractContractLineItemsLWCTest
global with sharing class SWAN_ExtractContractLineItemsLWC implements vlocity_cmt.VlocityOpenInterface{
     
    /*
     * Top level call by a Vlocity Remote Action
     *
     * @param inputMap  - The input provided to the Remote Action
     * @param outputMap - Any output to be provided back to the Remote Action
     * @param options   - Any options to aid in the execution of this class
     *
     * @returns true if the method completes successfully, false otherwise
     */ 
    global Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {

        Boolean result = true;
        try
        {
            if (methodName.equals('getContractLineItemsInfo'))
            {
                getContractLineItemsInfo(inputMap,outputMap,options);
            }
            else 
            {
                result = false;
            }   
        } 
        catch(Exception e)
        {System.debug('SWAN_ExtractSubQuoteCount:invokeMethod -> exception: '+e);
            result = false;}
        
        return result;
    
    }

    global Boolean getContractLineItemsInfo(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
        List<Object> parentCLI= new List<Object>();
        String contractID = String.ValueOf(inputMap.get('ContextId'));
        String contractQuoteForFuelType = '';
        for(vlocity_cmt__ContractLineItem__c cli : [SELECT id,vlocity_cmt__LineStatus__c,SWAN_Service_Point_Start_Date__c,SWAN_Service_Point_End_Date__c, vlocity_cmt__ContractId__r.SWAN_Quote_for_Fuel_Type__c, 
                                                    vlocity_cmt__EffectiveEndDate__c,vlocity_cmt__ContractId__r.vlocity_cmt__OpportunityId__r.Recordtype.Name,SWAN_Quote__r.vlocity_cmt__ParentQuoteId__c,
                                                    SWAN_Quote__r.SWAN_Site_Addition_Parent__c,SWAN_Service_Point__r.vlocity_cmt__ServicePointNumber__c, vlocity_cmt__Product2Id__r.Name, SWAN_Quote__c, SWAN_Quote__r.SWAN_Annual_Spend__c, 
                                                    SWAN_Quote__r.SWAN_Contract_Spend__c, SWAN_Quote__r.SWAN_Contract_Volume_KWh__c, 
                                                    vlocity_cmt__EffectiveStartDate__c,SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.SWAN_Site_Addition_Parent__c, SWAN_UsageUnitPrice__c, SWAN_UnitRate__c, 
                                                    vlocity_cmt__Product2Id__r.ProductCode, vlocity_cmt__RecurringCharge__c, 
                                                    (select id,SWAN_UnitRate__c,vlocity_cmt__RecurringCharge__c, vlocity_cmt__Product2Id__c, vlocity_cmt__Product2Id__r.Name, 
                                                    vlocity_cmt__Product2Id__r.ProductCode, SWAN_UsageUnitPrice__c  
                                                    from vlocity_cmt__Contract_Line_Items__r where vlocity_cmt__Product2Id__r.vlocity_cmt__IsOrderable__c=false)
                                                    from vlocity_cmt__ContractLineItem__c 
                                                    where vlocity_cmt__ContractId__c =:contractID AND SWAN_Service_Point__c != null])
        {
            system.debug('cli'+cli);
            Map<String, Object> eachRec = pushEachRecord(cli);
            parentCLI.add(eachRec);
            System.debug('Size Parent cli'+parentCLI.size());
            contractQuoteForFuelType = cli.vlocity_cmt__ContractId__r.SWAN_Quote_for_Fuel_Type__c;
        }   

        if(parentCLI.size()>0)
        {
            Map<String, Object> mapOutput = new Map<String, Object>();
            mapOutput.put('CLI',parentCLI);
            outputMap.put('ParentCLI',mapOutput);
            outputMap.put('FuelType',contractQuoteForFuelType);
            system.debug('outputMapNinad'+outputMap);
        }

        return true;
    }
        
    public Map<String, Object> pushEachRecord(vlocity_cmt__ContractLineItem__c cli){
        Map<String, Object> eachRec = new Map<String, Object>();

        eachRec.put('Prices',getPrices(cli, eachRec));  

        for(vlocity_cmt__ContractLineItem__c  childcli : cli.vlocity_cmt__Contract_Line_Items__r){
                if(childcli.SWAN_UnitRate__c != null)
                {   
                    String unitrate = '0.000';
                    if(childcli.SWAN_UnitRate__c == 0){
                        unitrate = '0.000';
                    }else{
                        unitrate = String.valueOf(childcli.SWAN_UnitRate__c);
                    }

                    if(unitrate.indexOf('.') == -1){
                        unitrate += '.000 p/kWh'; ////SUBSTRING(unitrate+"000",0,STRINGINDEXOF(unitrate+"000",".")+4)
                    }
                    else{
                        String unitratedef = unitrate + '000';
                        Integer num = (unitratedef.indexOf('.')+4);
                        unitrate = unitratedef.substring(0,num)+' p/kWh';
                    }   

                    eachRec.put('UnitCharge',unitrate);
                }
                if(childcli.vlocity_cmt__RecurringCharge__c != null)
                {
                    String standing_charge = '0.000';
                    if(childcli.vlocity_cmt__RecurringCharge__c == 0){
                        standing_charge = '0.000';
                    }else{
                        standing_charge = String.valueOf(childcli.vlocity_cmt__RecurringCharge__c);
                    }

                    if(standing_charge.indexOf('.') == -1){
                        standing_charge += '.000 p/day';////SUBSTRING(standing_charge+"000",0,STRINGINDEXOF(standing_charge+"000",".")+4)
                    }else{
                        String standing_charge_def = String.valueOf(standing_charge) + '000';
                        Integer num = (standing_charge_def.indexOf('.')+4);
                        standing_charge = standing_charge_def.substring(0,num)+' p/day';
                    }

                    eachRec.put('StandingCharge',standing_charge);
                }   
            }


        if(cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.SWAN_Site_Addition_Parent__c == null){
            eachRec.put('DealType', cli.vlocity_cmt__ContractId__r.vlocity_cmt__OpportunityId__r.Recordtype.Name);
        }else{
            String siteAddition = 'Site Addition';
            eachRec.put('DealType',(Object)siteAddition);
        }   


        try{
            eachRec.put('AnnualSpend', '£ '+cli.SWAN_Quote__r.SWAN_Annual_Spend__c.format()); // currRounded
            eachRec.put('ContractSpend', '£ '+cli.SWAN_Quote__r.SWAN_Contract_Spend__c.format()); // currRounded
            eachRec.put('Consumption', cli.SWAN_Quote__r.SWAN_Contract_Volume_KWh__c.format()+' kWh');
        }catch(Exception ex){
            system.debug('Issue with Quote, Annual Spend, Contract Spend or Consumption. Please check the values.');
        }

        eachRec.put('Id', cli.Id);
        eachRec.put('ViewRecord', cli.Id);
        eachRec.put('EffectiveToDate', Date.valueOf(cli.vlocity_cmt__EffectiveEndDate__c));
        eachRec.put('EffectiveFromDate', Date.valueOf(cli.vlocity_cmt__EffectiveStartDate__c));
        eachRec.put('Status', cli.vlocity_cmt__LineStatus__c);
        eachRec.put('ServicePointStartDate', cli.SWAN_Service_Point_Start_Date__c);
        eachRec.put('ServicePointNumber', cli.SWAN_Service_Point__r.vlocity_cmt__ServicePointNumber__c);         
        eachRec.put('FuelType',cli.vlocity_cmt__ContractId__r.SWAN_Quote_for_Fuel_Type__c);     
        return eachRec;
    }


    private List<Object> getPrices(vlocity_cmt__ContractLineItem__c cli, Map<String, Object> eachRec){
        
        List<Object> prices = new List<Object>();


        for(vlocity_cmt__ContractLineItem__c  childcli : cli.vlocity_cmt__Contract_Line_Items__r){
           if(childcli.vlocity_cmt__Product2Id__r.ProductCode == 'BG_STD')
                {
                    String stdCharge = '0.000';
                    if(childcli.SWAN_UnitRate__c != null){
                        
                        string temp = string.valueOf(childcli.SWAN_UnitRate__c.format());
                        stdCharge = (!temp.contains('.')? (temp + '.000'):(temp+'000').substring(0,((temp+'000').indexOf('.'))+4));
                        
                    }
                    
                    eachRec.put('StandingCharge', stdCharge +  ' p/day');
                    Map<String, Object> eachPrice = new Map<String, Object>();
                    eachPrice.put('Price', stdCharge +  ' p/day');
                    eachPrice.put('PriceName','Standing Charge');
                    Prices.add(eachPrice);
                }
                else if(childcli.vlocity_cmt__Product2Id__r.ProductCode == 'BG_UNITRATE')
                {
                    String unitCharge = '0.000';
                    if(childcli.SWAN_UnitRate__c != null)
                    {
                        string temp = string.valueOf(childcli.SWAN_UnitRate__c.format());
                        unitCharge = (!temp.contains('.')? (temp + '.000'):(temp+'000').substring(0,((temp+'000').indexOf('.'))+4));
                    }
                    eachRec.put('UnitCharge', unitCharge + ' p/kWh');
                }
                else if(childcli.vlocity_cmt__Product2Id__r.ProductCode == 'BG_AVAILABILITY_CHARGE')
                {
                    String unitCharge = '0.000';
                    if(childcli.SWAN_UnitRate__c != null)
                {
                        string temp = string.valueOf(childcli.SWAN_UnitRate__c.format());
                        unitCharge = (!temp.contains('.')? (temp + '.000'):(temp+'000').substring(0,((temp+'000').indexOf('.'))+4));
                    }
                    Map<String, Object> eachPrice = new Map<String, Object>();
                    eachPrice.put('Price', unitCharge + ' p/kVA/day');
                    eachPrice.put('PriceName','Availability Charge');
                    Prices.add(eachPrice);
                }
                else
                {    
                    String unitCharge = '0.000';
                    if(childcli.SWAN_UnitRate__c != null)
                    {
                        string temp = string.valueOf(childcli.SWAN_UnitRate__c.format());
                        unitCharge = (!temp.contains('.')? (temp + '.000'):(temp+'000').substring(0,((temp+'000').indexOf('.'))+4));
                    }
                    Map<String, Object> eachPrice = new Map<String, Object>();
                    eachPrice.put('Price', unitCharge + ' p/kWh');
                    eachPrice.put('PriceName',childcli.vlocity_cmt__Product2Id__r.Name);
                    Prices.add(eachPrice);
                }             
        }
        system.debug(prices);
        return prices;
    }
}
