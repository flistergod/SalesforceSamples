global with sharing class SWAN_GetDataForQuoteNegotiation implements vlocity_cmt.VlocityOpenInterface{

    private static final String BAG = 'Business Account Group';
    private static final String ELEC = 'Electricity';

    global SWAN_GetDataForQuoteNegotiation() {

    }

    global Boolean invokeMethod(String methodName,
                                Map < String, Object > input,
                                Map < String, Object > output,
                                Map < String, Object > options) {
        switch on methodName{
            when 'GetData'{
                return getData(input, output, options);
            }
            when 'SetData'{
                return setData(input, output, options);
            }
        }
        return false;
    }

    private Boolean getData(Map<String, Object> input, Map<String, Object> output, Map<String, Object> options){

        String contextId = (String)input.get('ContextId');

        List<QuoteLineItem> lstQLI = [Select Id, Product2.Name, vlocity_cmt__UsageUnitPrice__c, QuoteId, Quote.Name, 
        Quote.vlocity_cmt__ParentQuoteId__r.Id, Quote.vlocity_cmt__ParentQuoteId__r.Name, Quote.vlocity_cmt__ParentQuoteId__r.SWAN_Quote_for_Fuel_Type__c, 
        Quote.vlocity_cmt__ParentQuoteId__r.SWAN_Quote_Renewable__c, Quote.vlocity_cmt__ParentQuoteId__r.SWAN_Shaping_Premium_Frozen__c 
        from QuoteLineItem 
        where Quote.vlocity_cmt__ParentQuoteId__c = :contextId and Quote.Name = :BAG];

        Map<String, String> mapMasterQuote = new Map<String, String>();
        Map<String, String> mapChildQuote = new Map<String, String>();
        Map<String, Object> mapQLIByName = new Map<String, Object>();
        Boolean isElec = false;
        Boolean isRenewable = false;

        for(QuoteLineItem qli : lstQLI){
            mapMasterQuote.put('Id', qli.Quote.vlocity_cmt__ParentQuoteId__r.Id);
            mapMasterQuote.put('Name', qli.Quote.vlocity_cmt__ParentQuoteId__r.Name);
            mapMasterQuote.put('SWAN_Quote_for_Fuel_Type__c', qli.Quote.vlocity_cmt__ParentQuoteId__r.SWAN_Quote_for_Fuel_Type__c);
            mapMasterQuote.put('SWAN_Quote_Renewable__c', String.valueOf(qli.Quote.vlocity_cmt__ParentQuoteId__r.SWAN_Quote_Renewable__c));
            mapMasterQuote.put('SWAN_Shaping_Premium_Frozen__c', String.valueOf(qli.Quote.vlocity_cmt__ParentQuoteId__r.SWAN_Shaping_Premium_Frozen__c));

            isElec = qli.Quote.vlocity_cmt__ParentQuoteId__r.SWAN_Quote_for_Fuel_Type__c.equalsIgnoreCase(ELEC);
            isRenewable = qli.Quote.vlocity_cmt__ParentQuoteId__r.SWAN_Quote_Renewable__c;

            mapChildQuote.put('Id',qli.QuoteId);
            mapChildQuote.put('Name',qli.Quote.Name);

            Map<String, String> mapQLIDetails = new Map<String, String>();

            Decimal usageUnitPrice = qli.vlocity_cmt__UsageUnitPrice__c!=null?qli.vlocity_cmt__UsageUnitPrice__c:0.0;
            mapQLIDetails.put('ID',qli.Id);
            mapQLIDetails.put('Amount',usageUnitPrice.stripTrailingZeros().toPlainString());
            mapQLIByName.put(qli.Product2.Name.replaceAll(' ',''),mapQLIDetails);
        }

        output.put('MasterQuote',mapMasterQuote);
        output.put('ChildQuote',mapChildQuote);
        output.put('QLI',mapQliByName);
        output.put('isElec',isElec);
        output.put('isRenewable',isRenewable);

        return true;
    }

    private Boolean setData(Map<String, Object> input, Map<String, Object> output, Map<String, Object> options){

        List<QuoteLineItem> lstQLIToUpdate = new List<QuoteLineItem>();
        Quote masterQuote = new Quote(ID = (String)((Map<String,Object>)((Map<String,Object>)input.get('QLI')).get('MasterQuote')).get('ID'));

		try{
            
            Boolean oldShapingFrozen = (Boolean)((Map<String,Object>)((Map<String,Object>)input.get('QLI')).get('MasterQuote')).get('ShapingFrozen');
            Boolean newShapingFrozen = (Boolean)((Map<String,Object>)((Map<String,Object>)input.get('QLI')).get('MasterQuote')).get('ShapingFrozenNew'); 

            if(newShapingFrozen!=oldShapingFrozen){
                masterQuote.SWAN_Shaping_Premium_Frozen__c = Boolean.valueOf(newShapingFrozen);
                masterQuote.SWAN_Price_out_of_Date__c = true;
            }
        } catch (Exception e){
            system.debug(e);
        }

        ((Map<String,Object>)((Map<String,Object>)input.get('QLI'))).remove('MasterQuote');

        for(String s : ((Map<String,Object>)input.get('QLI')).keySet()){

            Map<String,Object> productDetails = (Map<String,Object>)((Map<String,Object>)input.get('QLI')).get(s);
                    
            try{ 
                if(s.startsWithIgnoreCase('Shaping')){
                    lstQLIToUpdate.add(new QuoteLineItem(Id = (String)productDetails.get('ID'), SWAN_UsageUnitPriceNBP__c=(Decimal)productDetails.get('NewAmount')));
                }else{
                    lstQLIToUpdate.add(new QuoteLineItem(Id = (String)productDetails.get('ID'), vlocity_cmt__UsageUnitPrice__c=(Decimal)productDetails.get('NewAmount')));
                }
                
                masterQuote.SWAN_Price_out_of_Date__c = true;
            } catch (Exception e){
                system.debug(e);
            }
        }
        
        update lstQLIToUpdate;
        update masterQuote;

        return true;
    }
}
