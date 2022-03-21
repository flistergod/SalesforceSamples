global with sharing  class SWAN_GetContractDataElec implements vlocity_cmt.VlocityOpenInterface {
    
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
        /*if(OfferPackId!=null)
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
        }*/
       
        map<string,object>MasterQuoteMap=new Map<string,object>();        
        Map<string,object>FinalMap = new Map<string,object>();
        list<object>masterqtList=new list<object>();
        Map<id,object>ParentChildMap=new map<id,object>();
        for(Quote childqt : [SELECT id,vlocity_cmt__DefaultServicePointId__c,
                                    FORMAT(vlocity_cmt__ParentQuoteId__r.SWAN_Broker_Commission_Margin_p__c),
                                    vlocity_cmt__ParentQuoteId__r.swan_broker_commission_margin_pence_per__c,vlocity_cmt__ParentQuoteId__r.SWAN_Broker__c,
                                    vlocity_cmt__ParentQuoteId__r.SWAN_Offer_Duration__c ,vlocity_cmt__ParentQuoteId__r.SWAN_Offer_End_Date__c,vlocity_cmt__ParentQuoteId__r.SWAN_Offer_Start_Date__c,
                                    vlocity_cmt__ParentQuoteId__r.QuoteNumber,FORMAT(vlocity_cmt__ParentQuoteId__r.SWAN_Contract_Spend__c),FORMAT(vlocity_cmt__ParentQuoteId__r.SWAN_Annual_Spend__c),
                                    vlocity_cmt__ParentQuoteId__c,FORMAT(SWAN_Annual_Spend__c),FORMAT(SWAN_Contract_Spend__c),SWAN_Service_Point_Start_Date__c,
                                    vlocity_cmt__DefaultServicePointId__r.SWAN_Service_Point_Reference__c,vlocity_cmt__DefaultServicePointId__r.vlocity_cmt__servicepointnumber__c,
                                    vlocity_cmt__ParentQuoteId__r.SWAN_Quote_Renewable__c ,
                                    vlocity_cmt__ParentQuoteId__r.SWAN_Pricing_Structure__c , vlocity_cmt__DefaultServicePointId__r.SWAN_Measurement_Class__c,
                                    Annual_Volume__c ,vlocity_cmt__DefaultServicePointId__r.SWAN_Supply_Capacity__c,
                                    vlocity_cmt__ParentQuoteId__r.SWAN_Passthrough_Option__c, vlocity_cmt__ParentQuoteId__r.SWAN_Commodity__c, vlocity_cmt__ParentQuoteId__r.SWAN_Commission_Payment_Period__c,
                                    (SELECT id,Product2.vlocity_cmt__IsOrderable__c, Product2.Name, vlocity_cmt__UsageUnitPrice__c, 
                                    vlocity_cmt__RecurringCharge__c,vlocity_cmt__JSONAttribute__c, Product2.vlocity_cmt__SubType__c from QuoteLineItems order by Product2.vlocity_cmt__SubType__c   )
                                    FROM quote WHERE vlocity_cmt__ParentQuoteId__c in (SELECT vlocity_cmt__QuoteId__c FROM Contract Where  Id=:OfferPackId) and recordtype.developername!='GroupCart'])
        {
            //===========Master qt[START]===========
                if(!MasterQuoteMap.containskey(childqt.vlocity_cmt__ParentQuoteId__c)){
                    map<string,object>temp=new map<string,object>();
                    temp.put('EstContractSpend','£'+doFormatting(childqt.vlocity_cmt__ParentQuoteId__r.SWAN_Contract_Spend__c,0,',','.'));
                    temp.put('QuoteNumber',childqt.vlocity_cmt__ParentQuoteId__r.QuoteNumber);
                    String tempdate = String.valueOf(childqt.vlocity_cmt__ParentQuoteId__r.SWAN_Offer_Start_Date__c.format());
                    temp.put('StartDate', tempdate.subString(0,6) + tempdate.subString(8,10));
                    tempdate = String.valueOf(childqt.vlocity_cmt__ParentQuoteId__r.SWAN_Offer_End_Date__c.format());
                    temp.put('EndDate', tempdate.subString(0,6) + tempdate.subString(8,10));
                    temp.put('Duration',childqt.vlocity_cmt__ParentQuoteId__r.SWAN_Offer_Duration__c );
                    temp.put('IF_Broker',childqt.vlocity_cmt__ParentQuoteId__r.SWAN_Broker__c!= null);
                    temp.put('BrokerCommissionpkWh', doFormatting(childqt.vlocity_cmt__ParentQuoteId__r.swan_broker_commission_margin_pence_per__c,3,',','.') + ' p/kWh');         
                    temp.put('IF_BrokerCommpkWhInc',(childqt.vlocity_cmt__ParentQuoteId__r.swan_broker_commission_margin_pence_per__c != null && childqt.vlocity_cmt__ParentQuoteId__r.swan_broker_commission_margin_pence_per__c > 0));
                    temp.put('IF_BrokerCommPoundsInc', (childqt.vlocity_cmt__ParentQuoteId__r.SWAN_Broker_Commission_Margin_p__c != NULL && childqt.vlocity_cmt__ParentQuoteId__r.SWAN_Broker_Commission_Margin_p__c > 0));
                    temp.put('BrokerCommissionPounds',('£'+doFormatting(childqt.vlocity_cmt__ParentQuoteId__r.SWAN_Broker_Commission_Margin_p__c,2,',','.')+'/meter/year'));
                   
                    
                    String passThroughOption = childqt.vlocity_cmt__ParentQuoteId__r.SWAN_Passthrough_Option__c !=null ? childqt.vlocity_cmt__ParentQuoteId__r.SWAN_Passthrough_Option__c :'';
                    
                    temp.put('IF_DUoS_PT', ( passThroughOption.indexOf('DUoS') != -1 ? true : false) );
                    temp.put('IF_BSUoS_RCRC_PT',  (passThroughOption.indexOf('BSUoS + RCRC') != -1 ? true :  false) );
                    temp.put('IF_TNUoS_PT', (passThroughOption.indexOf('TNUoS') != -1 ? true : false) );
                    temp.put('IF_CfD_PT', (passThroughOption.indexOf('Contracts for difference') != -1 ? true : false) );
                    temp.put('IF_FiT_PT', (passThroughOption.indexOf('Feed in Tariff') != -1 ? true : false) );
                    temp.put('IF_RO_PT', (passThroughOption.indexOf('Renewable Obligation') != -1 ? true : false)  );
                    temp.put('IF_AAHEDC_PT',(passThroughOption.indexOf('AAHEDC') != -1 ? true : false)  );
                    temp.put('IF_Capacity_Market_PT', (passThroughOption.indexOf('Capacity Market') != -1 ? true : false) );
                    temp.put('IF_Commodity', childqt.vlocity_cmt__ParentQuoteId__r.SWAN_Commodity__c != null ? true : false );
                    temp.put('IF_Commission _PT', childqt.vlocity_cmt__ParentQuoteId__r.SWAN_Commission_Payment_Period__c != null ? true : false );
                    temp.put('IF_Renewable_PT', childqt.vlocity_cmt__ParentQuoteId__r.SWAN_Quote_Renewable__c );
                   
                    
                    temp.put('IF_HH4_RSW', childqt.vlocity_cmt__ParentQuoteId__r.SWAN_Pricing_Structure__c == 'HH 4 Rate Summer Winter' ? true : false );
                    temp.put('IF_HH2_R', childqt.vlocity_cmt__ParentQuoteId__r.SWAN_Pricing_Structure__c == 'HH 2 Rate' ? true : false );
                    temp.put('IF_HH3_REW', childqt.vlocity_cmt__ParentQuoteId__r.SWAN_Pricing_Structure__c == 'HH 3 Rate EW' ? true : false );
                    temp.put('IF_HH4_RwP', childqt.vlocity_cmt__ParentQuoteId__r.SWAN_Pricing_Structure__c == 'HH 4 Rate with Peak' ? true : false );
                    temp.put('IF_HH5_RSWwP', childqt.vlocity_cmt__ParentQuoteId__r.SWAN_Pricing_Structure__c == 'HH 5 Rate Summer winter with peak' ? true : false );
                    temp.put('IF_HH5_RwPaPS', childqt.vlocity_cmt__ParentQuoteId__r.SWAN_Pricing_Structure__c == 'HH 5 Rate with Peak and Peak Shoulder' ? true : false );
                    temp.put('IF_HH6_RSWwPaS', childqt.vlocity_cmt__ParentQuoteId__r.SWAN_Pricing_Structure__c == 'HH 6 Rate Summer winter with peak and Peak Shoulder' ? true : false );
                    temp.put('IF_HH7_RSWwPaSW', childqt.vlocity_cmt__ParentQuoteId__r.SWAN_Pricing_Structure__c == 'HH 7 Rate Summer winter with Peak and Peak Shoulder and Weekends' ? true : false );
                    
                    MasterQuoteMap.put(childqt.vlocity_cmt__ParentQuoteId__c,temp);
                    System.debug('THIAGO'+temp);
                }
            //=========Master qt[ENd]========
          
            Map<string,object> AttributeMap = new Map<string,object>();
            List<Map<string,String>> priceMap = new List<Map<string,String>>();
            
            for(QuoteLineItem qli : childqt.QuoteLineItems){
               
                Map<string,String> price = new Map<string,String>();
                price.put('Name', qli.Product2.Name );
                
                if(qli.Product2.vlocity_cmt__SubType__c == 'Unit Rate' && qli.vlocity_cmt__UsageUnitPrice__c != null){
                    price.put('Price', doFormatting(qli.vlocity_cmt__UsageUnitPrice__c,3,',','.') + ' p/kWh' );
                }else if(qli.Product2.vlocity_cmt__SubType__c == 'Standing Charge' && qli.vlocity_cmt__UsageUnitPrice__c != null ){
                    price.put('Price', doFormatting(qli.vlocity_cmt__UsageUnitPrice__c,3,',','.') + ' p/day' );
                }else if(qli.vlocity_cmt__UsageUnitPrice__c != null){
                    price.put('Price', doFormatting(qli.vlocity_cmt__UsageUnitPrice__c,3,',','.') + ' p/kVA/day' );
                }
                priceMap.add(price);
                
            }
           
            AttributeMap.put('Prices',priceMap );
            AttributeMap.put('SiteRef',childqt.vlocity_cmt__DefaultServicePointId__r.SWAN_Service_Point_Reference__c);
            AttributeMap.put('ServicePoint',childqt.vlocity_cmt__DefaultServicePointId__r.vlocity_cmt__servicepointnumber__c);
            AttributeMap.put('RateStructure',childqt.vlocity_cmt__ParentQuoteId__r.SWAN_Pricing_Structure__c);
            AttributeMap.put('EstAnnualSpend', '£'+doFormatting(childqt.SWAN_Contract_Spend__c,0,',','.'));
            String eac = childqt.vlocity_cmt__DefaultServicePointId__r.SWAN_Measurement_Class__c ;
            AttributeMap.put('KVA', ( ( eac =='C' || eac =='E') ? doFormatting(childqt.vlocity_cmt__DefaultServicePointId__r.SWAN_Supply_Capacity__c ,0,',','.') : 'N/A' ));
            //AttributeMap.put('IF_KVA', ( ( eac =='C' || eac =='E') ? true : false ));
            AttributeMap.put('EAC', (childqt.Annual_Volume__c!=null ? (childqt.Annual_Volume__c +  ' kWh') : '')  );
            System.debug('THIAGO'+AttributeMap);
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
        vlocity_cmt.DRProcessResult result = vlocity_cmt.DRGlobal.processObjectsJSON(dataJson, 'SWAN_ExtractContractAndAccount');
        Map<String, Object> resultMap = result.convertToMap();
        
        FinalMap.putAll((map<string,object>)resultMap.get('returnResultsData'));
        FinalMap.put('Quotes',masterqtList.size()==1?masterqtList[0]:masterqtList);
        FinalMap.put('MasterQuoteDetails', lstMasterQuoteDetails);
       
        outputMap.put('tokenMap',FinalMap);
        //system.debug('outputMap==>\n'+JSON.serializepretty(outputMap));
        return true;
    }
    
    public static String doFormatting(Decimal val, integer dec, String tSep, String dSep) {
        String s, tmp;
        Integer i = 4 + dec;
     
        // If the number of decimals is zero (0)... prevents the first 1000s seperator from being set at the 4th.
        if(dec==0){
            i--;
        }
        if(val!=null){     
            s = val.setScale(dec).toPlainString().replace(tSep, dSep);
            while(s.length() > i) {
                tmp = s.substring(0, s.length() - i) + tSep + s.substring(s.length() - i);
                s = tmp;
                i += 4;
            }
         
            // If the number is negative and has a number non-decimal digits divisible by 3, it prevents putting a comma before the 1st digit (ex -300,000.00  comes out -,300,000.00)
            if (s.substring(0,1) == '-') {
                if (s.substring(1,2) == tSep) {
                    s = '-' + s.substring(2);
                }
            }
        }else{s=null;} 
        return s;
    }
}