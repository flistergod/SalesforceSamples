global with sharing class SWAN_GetOfferPackRelatedData implements vlocity_cmt.VlocityOpenInterface {

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
           
            for(OpportunityLineItem oli : [SELECT id,vlocity_cmt__ServicePointId__c FROM OpportunityLineItem WHERE OpportunityId = :opportunityId])
            {
                spids.add(oli.vlocity_cmt__ServicePointId__c);
            }
        }
       
        map<string,object>MasterQuoteMap=new Map<string,object>();        
        Map<string,object>FinalMap = new Map<string,object>();
        list<object>masterqtList=new list<object>();
        Map<id,object>ParentChildMap=new map<id,object>();
        for(Quote childqt : [SELECT id,vlocity_cmt__DefaultServicePointId__c,vlocity_cmt__DefaultServicePointId__r.SWAN_Formula_Year_Annual_Quantity__c,
                                    vlocity_cmt__DefaultServicePointId__r.SWAN_Formula_Year_Offtake_Quantity__c,FORMAT(vlocity_cmt__ParentQuoteId__r.SWAN_Broker_Commission_Margin_p__c),
                                    vlocity_cmt__ParentQuoteId__r.swan_broker_commission_margin_pence_per__c,vlocity_cmt__ParentQuoteId__r.SWAN_Broker__c,
                                    vlocity_cmt__ParentQuoteId__r.SWAN_Offer_Duration__c ,vlocity_cmt__ParentQuoteId__r.SWAN_Offer_End_Date__c,vlocity_cmt__ParentQuoteId__r.SWAN_Offer_Start_Date__c,
                                    vlocity_cmt__ParentQuoteId__r.QuoteNumber,FORMAT(vlocity_cmt__ParentQuoteId__r.SWAN_Contract_Spend__c),FORMAT(vlocity_cmt__ParentQuoteId__r.SWAN_Annual_Spend__c),
                                    vlocity_cmt__ParentQuoteId__c,FORMAT(SWAN_Annual_Spend__c),FORMAT(SWAN_Contract_Spend__c),SWAN_Service_Point_Start_Date__c,
                                    vlocity_cmt__DefaultServicePointId__r.SWAN_Service_Point_Reference__c,vlocity_cmt__DefaultServicePointId__r.vlocity_cmt__servicepointnumber__c,
                                    SWAN_Contract_Volume_KWh__c,SWAN_Service_Point_End_Date__c,(SELECT id,product2.ProductCode,Product2.vlocity_cmt__IsOrderable__c,
                                    SWAN_UnitRate__c,vlocity_cmt__RecurringCharge__c,vlocity_cmt__JSONAttribute__c from QuoteLineItems)
                                    FROM quote WHERE vlocity_cmt__ParentQuoteId__c in:MasterQtIds and recordtype.developername!='GroupCart'order by vlocity_cmt__ParentQuoteId__r.SWAN_Offer_End_Date__c, vlocity_cmt__ParentQuoteId__r.QuoteNumber asc])
        {
            //===========Master qt[START]===========
                if(!MasterQuoteMap.containskey(childqt.vlocity_cmt__ParentQuoteId__c)){
                    map<string,object>temp=new map<string,object>();
                    //decimal.valueOf(standingCharge).format()
                    temp.put('EstContractSpend','£'+doFormatting(childqt.vlocity_cmt__ParentQuoteId__r.SWAN_Contract_Spend__c,0,',','.'));
                    temp.put('EstAnnualSpend','£'+doFormatting(childqt.vlocity_cmt__ParentQuoteId__r.SWAN_Annual_Spend__c,0,',','.'));
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
                    MasterQuoteMap.put(childqt.vlocity_cmt__ParentQuoteId__c,temp);
                }
            //=========Master qt[ENd]========
           
            Map<string,object> AttributeMap = new Map<string,object>();
            for(QuoteLineItem qli : childqt.QuoteLineItems)
            {
                if(!String.isblank(qli.vlocity_cmt__JSONAttribute__c) && qli.Product2.vlocity_cmt__IsOrderable__c)
                {
                    if(spids.size()>0 && spids.contains(childqt.vlocity_cmt__DefaultServicePointId__c))
                    {
                        Date customerAQEffFromDateValue;
                        Date customerAQEffToDateValue;
                        String customerAQ;
                        String customerSOQ;
                        for(object Attr : (List<object>) ((Map<String, Object>)JSON.deserializeUntyped(qli.vlocity_cmt__JSONAttribute__c)).get('SWAN_SP_ATT_CAT'))
                        {
                            String key = (string) ((map<string,object>)Attr).get('attributeuniquecode__c');
                           
                            if(key == 'SWAN_ATT_CUST_AQ')
                            {
                                customerAQ = string.valueof(((MAP<string,object>)((map<string,object>)Attr).get('attributeRunTimeInfo')).get('value'));
                            }
                            else if(key == 'SWAN_ATT_CUST_SOQ')
                            {
                                customerSOQ= string.valueof( ((MAP<string,object>)((map<string,object>)Attr).get('attributeRunTimeInfo')).get('value'));
                            }
                            else if(key == 'SWAN_ATT_CUST_EFF_FROM')
                            {
                                object value = ((MAP<string,object>)((map<string,object>)Attr).get('attributeRunTimeInfo')).get('value');
                                customerAQEffFromDateValue= ((value!=null && Value != '')?date.valueOf(((string)value).contains('T')?((string)value).substring(0,((string)value).indexOf('T')):(string)value):null);
                                //system.debug(value +'<=fromdate=>'+customerAQEffFromDateValue);
                            }
                            else if(key == 'SWAN_ATT_CUST_EFF_TO')
                            {
                                object value = ((MAP<string,object>)((map<string,object>)Attr).get('attributeRunTimeInfo')).get('value');
                                customerAQEffToDateValue= ((value!=null && value!='')?date.valueOf(((string)value).contains('T')?((string)value).substring(0,((string)value).indexOf('T')):(string)value):null);
                                //system.debug(value +'<=todate=>'+customerAQEffFromDateValue);
                            }
                        }
                       
                        if(((customerAQEffFromDateValue== null && customerAQEffToDateValue== null || customerAQEffFromDateValue!= null && customerAQEffToDateValue== null && customerAQEffFromDateValue.daysBetween(childqt.SWAN_Service_Point_End_Date__c) > 0)
                        || (customerAQEffToDateValue!= null && customerAQEffFromDateValue == null && customerAQEffToDateValue.daysBetween(childqt.SWAN_Service_Point_Start_Date__c) <= 0)
                        || (customerAQEffFromDateValue!= null && customerAQEffToDateValue!= null && customerAQEffFromDateValue.daysBetween(childqt.SWAN_Service_Point_End_Date__c) >= 0 && customerAQEffToDateValue.daysBetween(childqt.SWAN_Service_Point_Start_Date__c) <= 0))
                        && customerAQ != null && customerSOQ!= null){
                           
                            AttributeMap.put('FYAQ', doFormatting(decimal.valueof(customerAQ),0,',','.'));    
                            AttributeMap.put('FYSOQ', doFormatting(decimal.valueof(customerSOQ),0,',','.'));
                        }
                        else
                        {
                            //from child quote service point related data
                            AttributeMap.put('FYAQ', doFormatting(childqt.vlocity_cmt__DefaultServicePointId__r.SWAN_Formula_Year_Annual_Quantity__c,0,',','.'));
                            AttributeMap.put('FYSOQ', doFormatting(childqt.vlocity_cmt__DefaultServicePointId__r.SWAN_Formula_Year_Offtake_Quantity__c,0,',','.'));
                        }
                    }
                    else
                    {
                        //from child quote service point related data
                        AttributeMap.put('FYAQ', doFormatting(childqt.vlocity_cmt__DefaultServicePointId__r.SWAN_Formula_Year_Annual_Quantity__c,0,',','.'));
                        AttributeMap.put('FYSOQ', doFormatting(childqt.vlocity_cmt__DefaultServicePointId__r.SWAN_Formula_Year_Offtake_Quantity__c,0,',','.'));
                    }

                }
                else if(qli.product2.ProductCode=='BG_STD')
                {
                    String stdCharge = '0.000';
                    if(qli.vlocity_cmt__RecurringCharge__c != null)
                    {
                        string temp = string.valueOf(qli.vlocity_cmt__RecurringCharge__c);
                        stdCharge = doFormatting(decimal.valueof(temp),3,',','.');
                    }
                   
                    AttributeMap.put('StandingCharge',stdCharge);//qli.vlocity_cmt__RecurringCharge__c
                }
                else if(qli.product2.ProductCode=='BG_UNITRATE')
                {
                    String unitRate = '0.000';
                    if(qli.SWAN_UnitRate__c!= null)
                    {
                        string temp = string.valueOf(qli.SWAN_UnitRate__c);
                        unitRate = doFormatting(decimal.valueof(temp),3,',','.');
                    }
                    AttributeMap.put('UnitRate',unitRate);//qli.SWAN_UnitRate__c
                }
            }
            AttributeMap.put('Reference',childqt.vlocity_cmt__DefaultServicePointId__r.SWAN_Service_Point_Reference__c);
            AttributeMap.put('EstAnnualSpend','£'+doFormatting(childqt.SWAN_Annual_Spend__c,0,',','.'));
            AttributeMap.put('EstContractSpend','£'+doFormatting(childqt.SWAN_Contract_Spend__c,0,',','.'));
            AttributeMap.put('ServicePointNumber',childqt.vlocity_cmt__DefaultServicePointId__r.vlocity_cmt__servicepointnumber__c);
            AttributeMap.put('EstConsumption',doFormatting(childqt.SWAN_Contract_Volume_KWh__c,0,',','.'));
            String tempdate = String.valueOf(childqt.SWAN_Service_Point_Start_Date__c.format());
            AttributeMap.put('ServicePointStartDate', tempdate.subString(0,6) + tempdate.subString(8,10));
            //Childqtlist.add(AttributeMap);
            if(!ParentChildMap.containskey(childqt.vlocity_cmt__ParentQuoteId__c)){
                List<object>temp = new list<object>();
                temp.add(AttributeMap);
                ParentChildMap.put(childqt.vlocity_cmt__ParentQuoteId__c,temp);
            }
            else{
                List<object>temp = (List<object>)ParentChildMap.get(childqt.vlocity_cmt__ParentQuoteId__c);
                temp.add(AttributeMap);
                ParentChildMap.put(childqt.vlocity_cmt__ParentQuoteId__c,temp);    
            }
        }
       
        for(string masterid : MasterQuoteMap.keyset())
        {
            map<string,object> temp=new map<string,object>();
            temp = (map<string,object>)MasterQuoteMap.get(masterid);
            temp.put('ChildQuotes',ParentChildMap.get(masterid));  
            masterqtList.add(temp);
        }
       
         
        map<string,string>DRinput=new Map<string,string>{'Id'=>OfferPackId,'FuelType'=>'Gas'};
        string dataJson = JSON.serializePretty(DRinput, false);
        vlocity_cmt.DRProcessResult result = vlocity_cmt.DRGlobal.processObjectsJSON(dataJson, 'SWAN_ExtractOfferPackForApex');
        Map<String, Object> resultMap = result.convertToMap();
        FinalMap.putAll((map<string,object>)resultMap.get('returnResultsData'));
        //outputMap=(map<string,object>)resultMap.get('returnResultsData');
        FinalMap.put('Quotes',masterqtList.size()==1?masterqtList[0]:masterqtList);
        //outputMap.put('Quotes',masterqtList.size()==1?masterqtList[0]:masterqtList);
        //FinalMap.put('Quotes',masterqtList);
        //outputMap.put('Quotes',masterqtList);
       
       
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
