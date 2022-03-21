global with sharing  class SWAN_GetOfferPackRelatedDataElec implements vlocity_cmt.VlocityOpenInterface {
    
    global Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {

        if (methodName == 'getTokenData') return getTokenData(inputMap, outputMap, options);  
       
        return true;
    }
    
    public Boolean getTokenData(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options)
    {
        String OfferPackId=inputMap.get('contextId')!=null?(string)inputMap.get('contextId'):null;
        string opportunityId;

        set<id>spids=new set<id>();
        
        set<id>MasterQtIds = new set<id>();
        if(OfferPackId!=null)
        {
            for(SWAN_Offer_Pack_Quote__c OPQ : [Select id,SWAN_Quote__c,SWAN_Offer_Pack__r.SWAN_Opportunity__c from SWAN_Offer_Pack_Quote__c where SWAN_Offer_Pack__c=:OfferPackId and SWAN_Quote__r.recordtype.developername='MasterQuote'])
            {
                MasterQtIds.add(OPQ.SWAN_Quote__c);
                opportunityId=OPQ.SWAN_Offer_Pack__r.SWAN_Opportunity__c;
            }
           
            for(OpportunityLineItem oli : [SELECT id,vlocity_cmt__ServicePointId__c, vlocity_cmt__JSONAttribute__c  FROM OpportunityLineItem WHERE OpportunityId = :opportunityId])
            {
                spids.add(oli.vlocity_cmt__ServicePointId__c);
                
            }
        }
       
        map<string,object>MasterQuoteMap=new Map<string,object>();        
        Map<string,object>FinalMap = new Map<string,object>();
        list<object>masterqtList=new list<object>();
        Map<id,object>ParentChildMap=new map<id,object>();
        for(Quote childqt : [SELECT id,vlocity_cmt__DefaultServicePointId__c,
                                    FORMAT(vlocity_cmt__ParentQuoteId__r.SWAN_Broker_Commission_Margin_p__c),
                                    vlocity_cmt__ParentQuoteId__r.swan_broker_commission_margin_pence_per__c,vlocity_cmt__ParentQuoteId__r.SWAN_Broker__c,
                                    vlocity_cmt__ParentQuoteId__r.SWAN_Offer_Duration__c ,vlocity_cmt__ParentQuoteId__r.SWAN_Offer_End_Date__c,vlocity_cmt__ParentQuoteId__r.SWAN_Offer_Start_Date__c,
                                    vlocity_cmt__ParentQuoteId__r.QuoteNumber,FORMAT(vlocity_cmt__ParentQuoteId__r.SWAN_Contract_Spend__c),FORMAT(vlocity_cmt__ParentQuoteId__r.SWAN_Annual_Spend__c),
                                    vlocity_cmt__ParentQuoteId__c, FORMAT(SWAN_Annual_Spend__c),FORMAT(SWAN_Contract_Spend__c),SWAN_Service_Point_Start_Date__c,
                                    vlocity_cmt__DefaultServicePointId__r.SWAN_Service_Point_Reference__c,vlocity_cmt__DefaultServicePointId__r.vlocity_cmt__servicepointnumber__c, vlocity_cmt__DefaultServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__PostalCode__c, vlocity_cmt__DefaultServicePointId__r.SWAN_Standard_Settlement_Config_Ovrd__c, vlocity_cmt__DefaultServicePointId__r.SWAN_Standard_Settlement_Configuration__c,
                                    vlocity_cmt__ParentQuoteId__r.SWAN_Quote_Renewable__c , vlocity_cmt__ParentQuoteId__r.SWAN_Renewable_Option__c, vlocity_cmt__ParentQuoteId__r.SWAN_Renewable__c,
                                    vlocity_cmt__ParentQuoteId__r.SWAN_Pricing_Structure__c , vlocity_cmt__DefaultServicePointId__r.SWAN_Measurement_Class__c, vlocity_cmt__DefaultServicePointId__r.SWAN_Measurement_Class_Ovrd__c,
                                    Annual_Volume__c ,vlocity_cmt__DefaultServicePointId__r.SWAN_Supply_Capacity__c,
                                    vlocity_cmt__ParentQuoteId__r.SWAN_Passthrough_Option__c, vlocity_cmt__ParentQuoteId__r.SWAN_Commodity__c, vlocity_cmt__ParentQuoteId__r.SWAN_Commission_Payment_Period__c,
                                    (SELECT id,Product2.vlocity_cmt__IsOrderable__c, Product2.Name, vlocity_cmt__UsageUnitPrice__c, 
                                    vlocity_cmt__RecurringCharge__c,vlocity_cmt__JSONAttribute__c, Product2.vlocity_cmt__SubType__c, Product2.vlocity_cmt__Type__c from QuoteLineItems order by Product2.vlocity_cmt__SubType__c, Product2.Name asc)
                                    FROM quote WHERE vlocity_cmt__ParentQuoteId__c in:MasterQtIds and recordtype.developername!='GroupCart' order by vlocity_cmt__ParentQuoteId__r.SWAN_Offer_End_Date__c, vlocity_cmt__ParentQuoteId__r.QuoteNumber asc])
        {
            //===========Master qt[START]===========
                if(!MasterQuoteMap.containskey(childqt.vlocity_cmt__ParentQuoteId__c)){
                    map<string,object>temp=new map<string,object>();
                    temp.put('EstContractSpend','£'+SWAN_GetOfferPackRelatedData.doFormatting(childqt.vlocity_cmt__ParentQuoteId__r.SWAN_Contract_Spend__c,0,',','.'));
                    temp.put('EstAnnualSpend','£'+SWAN_GetOfferPackRelatedData.doFormatting(childqt.vlocity_cmt__ParentQuoteId__r.SWAN_Annual_Spend__c,0,',','.'));
                    temp.put('QuoteNumber',childqt.vlocity_cmt__ParentQuoteId__r.QuoteNumber);
                    String tempdate = String.valueOf(childqt.vlocity_cmt__ParentQuoteId__r.SWAN_Offer_Start_Date__c.format());
                    temp.put('StartDate', tempdate.subString(0,6) + tempdate.subString(8,10));
                    tempdate = String.valueOf(childqt.vlocity_cmt__ParentQuoteId__r.SWAN_Offer_End_Date__c.format());
                    temp.put('EndDate', tempdate.subString(0,6) + tempdate.subString(8,10));
                    temp.put('Duration',childqt.vlocity_cmt__ParentQuoteId__r.SWAN_Offer_Duration__c );
                    temp.put('IF_Broker',childqt.vlocity_cmt__ParentQuoteId__r.SWAN_Broker__c!= null);
                    temp.put('BrokerCommissionpkWh', SWAN_GetOfferPackRelatedData.doFormatting(childqt.vlocity_cmt__ParentQuoteId__r.swan_broker_commission_margin_pence_per__c,3,',','.') + ' p/kWh');         
                    temp.put('IF_BrokerCommpkWhInc',(childqt.vlocity_cmt__ParentQuoteId__r.swan_broker_commission_margin_pence_per__c != null && childqt.vlocity_cmt__ParentQuoteId__r.swan_broker_commission_margin_pence_per__c > 0));
                    temp.put('IF_BrokerCommPoundsInc', (childqt.vlocity_cmt__ParentQuoteId__r.SWAN_Broker_Commission_Margin_p__c != NULL && childqt.vlocity_cmt__ParentQuoteId__r.SWAN_Broker_Commission_Margin_p__c > 0));
                    temp.put('BrokerCommissionPounds',('£'+SWAN_GetOfferPackRelatedData.doFormatting(childqt.vlocity_cmt__ParentQuoteId__r.SWAN_Broker_Commission_Margin_p__c,2,',','.')+'/meter/year'));
                    temp.put('RenewableOption', childqt.vlocity_cmt__ParentQuoteId__r.SWAN_Renewable__c + ' - ' + childqt.vlocity_cmt__ParentQuoteId__r.SWAN_Renewable_Option__c);
                    temp.put('RenewableOptions', (childqt.vlocity_cmt__ParentQuoteId__r.SWAN_Renewable__c != null && childqt.vlocity_cmt__ParentQuoteId__r.SWAN_Renewable_Option__c != null ? (childqt.vlocity_cmt__ParentQuoteId__r.SWAN_Renewable__c + ' - ' + childqt.vlocity_cmt__ParentQuoteId__r.SWAN_Renewable_Option__c) : ''));
                    
                    
                    MasterQuoteMap.put(childqt.vlocity_cmt__ParentQuoteId__c,temp);
                }
            //=========Master qt[ENd]========
          
            Map<string,object> AttributeMap = new Map<string,object>();
            List<Map<string,String>> priceMap = new List<Map<string,String>>();
            String rateStructure = null;
            Integer numberOfQLIs = 0;
            String measurementClass;

            for(QuoteLineItem qli : childqt.QuoteLineItems){
                
                if (qli.Product2.vlocity_cmt__Type__c != 'Electricity') {
                    Map<string,String> price = new Map<string,String>();
                    price.put('Name', qli.Product2.Name );
                    
                    if(qli.Product2.vlocity_cmt__SubType__c == 'Unit Rate' || qli.Product2.vlocity_cmt__SubType__c == 'Pass Through Price') {
                        price.put('Price', SWAN_GetOfferPackRelatedData.doFormatting(((qli.vlocity_cmt__UsageUnitPrice__c != null) ? qli.vlocity_cmt__UsageUnitPrice__c : 0),3,',','.') + ' p/kWh' );
                    } else if(qli.Product2.vlocity_cmt__SubType__c == 'Standing Charge') {
                        price.put('Price', SWAN_GetOfferPackRelatedData.doFormatting(((qli.vlocity_cmt__UsageUnitPrice__c != null) ? qli.vlocity_cmt__UsageUnitPrice__c : 0),3,',','.') + ' p/day' );
                    } else {
                        price.put('Price', SWAN_GetOfferPackRelatedData.doFormatting(((qli.vlocity_cmt__UsageUnitPrice__c != null) ? qli.vlocity_cmt__UsageUnitPrice__c : 0),3,',','.') + ' p/kVA/day' );
                    }
                    priceMap.add(price);
                    numberOfQLIs++;
                    
                } else {
                    String value = childqt.vlocity_cmt__DefaultServicePointId__r.SWAN_Measurement_Class__c;
                    String valueOvrd = childqt.vlocity_cmt__DefaultServicePointId__r.SWAN_Measurement_Class_Ovrd__c;
                    
                    measurementClass = (valueOvrd != null) ? valueOvrd : value;
                    
                    System.debug('measurementClass -> ' + measurementClass);
                    System.debug('QLI:Id -> ' + qli.Id);
                    
                    if (measurementClass == 'A' || measurementClass == 'B') {
                        value = childqt.vlocity_cmt__DefaultServicePointId__r.SWAN_Standard_Settlement_Configuration__c;
                        valueOvrd = childqt.vlocity_cmt__DefaultServicePointId__r.SWAN_Standard_Settlement_Config_Ovrd__c;
                        
                        rateStructure = 'NHH (' + ((valueOvrd != null) ? valueOvrd : value) + ')';
                    } else {
                        System.debug('In the For Loop!!');
                        for(object Attr : (List<object>) ((Map<String, Object>)JSON.deserializeUntyped(String.valueof(qli.vlocity_cmt__JSONAttribute__c))).get('SWAN_QUOTE_CONFIG_ATT_CAT')) {
                            String key = (string) ((map<string,object>)Attr).get('attributeuniquecode__c');
                            
                            System.debug('Inside the attribute: SWAN_QUOTE_CONFIG_ATT_CAT -> ' + key);
                            
                            if(key == 'SWAN_ATT_HH_RATE_STRUCT')
                            {
                                rateStructure = string.valueof(((MAP<string,object>)((MAP<string,object>)((map<string,object>)Attr).get('attributeRunTimeInfo')).get('selectedItem')).get('value'));
                                System.debug('Attr -> ' + Attr);
                                break;
                            }
                        }
                    }   
                }
            }
           
            AttributeMap.put('Prices',priceMap );
            AttributeMap.put('SiteRef',(childqt.vlocity_cmt__DefaultServicePointId__r.SWAN_Service_Point_Reference__c) != null ? childqt.vlocity_cmt__DefaultServicePointId__r.SWAN_Service_Point_Reference__c : childqt.vlocity_cmt__DefaultServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__PostalCode__c);
            String servicePointDt = String.valueOf(childqt.SWAN_Service_Point_Start_Date__c.format());
            AttributeMap.put('ServicePointStartDate', servicePointDt.subString(0,6) + servicePointDt.subString(8,10));
            AttributeMap.put('ServicePoint',childqt.vlocity_cmt__DefaultServicePointId__r.vlocity_cmt__servicepointnumber__c);
            AttributeMap.put('RateStructure',rateStructure);
            AttributeMap.put('EstAnnualSpend', '£'+SWAN_GetOfferPackRelatedData.doFormatting(childqt.SWAN_Annual_Spend__c,0,',','.'));
            AttributeMap.put('KVA', ( ( measurementClass =='C' || measurementClass =='E') ? SWAN_GetOfferPackRelatedData.doFormatting(childqt.vlocity_cmt__DefaultServicePointId__r.SWAN_Supply_Capacity__c ,0,',','.') : 'N/A' ));
            AttributeMap.put('EAC', (childqt.Annual_Volume__c != null ? (SWAN_GetOfferPackRelatedData.doFormatting(childqt.Annual_Volume__c,0,',','.') +  ' kWh') : '')  );
            // Set the conditional token that will be used to display the table in the site annexe for the service point
            AttributeMap.put('IF_ONE_RATE', (numberOfQLIs == 1) ? true : false);
            AttributeMap.put('IF_TWO_RATES', (numberOfQLIs == 2) ? true : false);
            AttributeMap.put('IF_THREE_RATES', (numberOfQLIs == 3) ? true : false);
            AttributeMap.put('IF_FOUR_RATES', (numberOfQLIs == 4) ? true : false);
            AttributeMap.put('IF_FIVE_RATES', (numberOfQLIs == 5) ? true : false);
            AttributeMap.put('IF_SIX_RATES', (numberOfQLIs == 6) ? true : false);
            AttributeMap.put('IF_SEVEN_RATES', (numberOfQLIs == 7) ? true : false);
            AttributeMap.put('IF_EIGHT_RATES', (numberOfQLIs == 8) ? true : false);
            AttributeMap.put('IF_NINE_RATES', (numberOfQLIs == 9) ? true : false);
            AttributeMap.put('IF_TEN_RATES', (numberOfQLIs == 10) ? true : false);
            AttributeMap.put('IF_ELEVEN_RATES', (numberOfQLIs == 11) ? true : false);
            AttributeMap.put('IF_TWELVE_RATES', (numberOfQLIs == 12) ? true : false);
            //System.debug('numberOfQLIs -> ' + numberOfQLIs);
            if(!ParentChildMap.containskey(childqt.vlocity_cmt__ParentQuoteId__c)){
                List<object>temp = new list<object>();
                temp.add(AttributeMap);
                ParentChildMap.put(childqt.vlocity_cmt__ParentQuoteId__c,temp);
           
            }else{

                List<object>temp = (List<object>)ParentChildMap.get(childqt.vlocity_cmt__ParentQuoteId__c);
                temp.add(AttributeMap);
                ParentChildMap.put(childqt.vlocity_cmt__ParentQuoteId__c,temp);    
            }
        }
        list<Object>lstMasterQuoteDetails=new list<object>();

        for(string masterid : MasterQuoteMap.keyset()){

            map<string,object> temp=new map<string,object>();
            temp = (map<string,object>)MasterQuoteMap.get(masterid);
            temp.put('ChildQuotes',ParentChildMap.get(masterid));
            lstMasterQuoteDetails.add(temp);
            masterqtList.add(temp);
        }
       
        
        map<string,string>DRinput=new Map<string,string>{'Id'=>OfferPackId,'FuelType'=>'Electricity'};
        string dataJson = JSON.serializePretty(DRinput, false);
        vlocity_cmt.DRProcessResult result = vlocity_cmt.DRGlobal.processObjectsJSON(dataJson, 'SWAN_ExtractOfferPackForApex');
        Map<String, Object> resultMap = result.convertToMap();
        
        FinalMap.putAll((map<string,object>)resultMap.get('returnResultsData'));
        FinalMap.put('Quotes',masterqtList.size()==1?masterqtList[0]:masterqtList);
        FinalMap.put('MasterQuoteDetails', lstMasterQuoteDetails);
        
        outputMap.put('tokenMap',FinalMap);
        //system.debug('outputMap==>\n'+JSON.serializepretty(outputMap));
        return true;
    }
}