global class SWAN_CustomFunctionImplementation implements vlocity_cmt.VlocityOpenInterface
{
    /*
        inputs - arguments - List<Object> of passed in arguments
        output - result - The result of the Function being called. Supports single Object values, List<Object> or Map<String, Object>
    */
    global Boolean invokeMethod(String methodName, Map<String, Object> inputs, Map<String, Object> output, Map<String, Object> options)
    {
        // formatNumber returns a number with formatting applied
        if (methodName == 'formatNumber') {
            List<Object> arguments = (List<Object>)inputs.get('arguments');
            output.put('result', formatNumber(arguments));
            return true;
        }else if (methodName == 'getQLIData'){
            getQLIData((List<Object>)inputs.get('arguments'), output);
            system.debug('output: '+output);
            return true;
        }else if(methodName == 'getCostBreakdown'){
            List<Object> arguments = (List<Object>)inputs.get('arguments');
            output.put('result', getCostBreakdown(arguments));
            return true;
        }
 
        return false;
    }
 
    String formatNumber(List<Object> arguments){
        return (arguments[0] != null ? ((Decimal)arguments[0]).format() : (String)arguments[0]);
    }

    Boolean getQLIData(List<Object> arguments, Map<String, Object> output){
        if(arguments == null || arguments.size() > 1 || arguments[0] == null || !(arguments[0] instanceOf String)){
            return false;
        }

        String contextId = (String)arguments[0];
        String subQuote = 'SubQuote';
        String productType = 'Cost%';

        List<QuoteLineItem> lstQLI = [Select Id, Product2.Name, vlocity_cmt__UsageUnitPrice__c, QuoteId, Quote.Name, 
            Quote.vlocity_cmt__ParentQuoteId__r.Id, Quote.vlocity_cmt__ParentQuoteId__r.Name, Quote.vlocity_cmt__ParentQuoteId__r.SWAN_Quote_for_Fuel_Type__c, 
            Quote.vlocity_cmt__ParentQuoteId__r.SWAN_Quote_Renewable__c, Quote.vlocity_cmt__ParentQuoteId__r.SWAN_Shaping_Premium_Frozen__c, SWAN_UsageUnitPriceNBP__c  
            from QuoteLineItem 
            where Quote.vlocity_cmt__ParentQuoteId__c = :contextId 
            AND Quote.RecordType.DeveloperName = :subQuote 
            AND Product2.vlocity_cmt__IsOrderable__c =false 
            AND (NOT product2.vlocity_cmt__type__c like :productType)];

        Map<String, Object> mapQLIByName = new Map<String, Object>();

        for(QuoteLineItem qli : lstQLI){
            Map<String, String> mapQLIDetails = new Map<String, String>();

            Decimal usageUnitPrice = qli.vlocity_cmt__UsageUnitPrice__c!=null?qli.vlocity_cmt__UsageUnitPrice__c:0.0;
            if(qli.Product2.Name.startsWithIgnoreCase('Shaping')){
                usageUnitPrice = qli.SWAN_UsageUnitPriceNBP__c!=null?qli.SWAN_UsageUnitPriceNBP__c:0.0;
            }
            mapQLIDetails.put('ID',qli.Id);
            mapQLIDetails.put('Amount',usageUnitPrice.setScale(3).toPlainString());
            mapQLIDetails.put('NewAmount','');
            mapQLIByName.put(qli.Product2.Name.replaceAll(' ',''),mapQLIDetails);
        }

        for(String s : mapQLIByName.keySet()){
            system.debug(s+' '+mapQLIByName.get(s));
        }

        output.put('result',mapQliByName);

        return true;
    }

    String getCostBreakdown(List<Object> arguments){
        return null;
    }
 
}