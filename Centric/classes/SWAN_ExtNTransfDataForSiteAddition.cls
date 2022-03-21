global with sharing class SWAN_ExtNTransfDataForSiteAddition implements vlocity_cmt.VlocityOpenInterface2{
//0Q07E000001QlVdSAK
//0Q08E000001fmmnSAA
     /**
     * Message used when DataRaptor processing encountered any error
     */
    private static final String ERROR_DR_MESSAGE = 'Error encountered while processing request. Please check log for details.';
    
    /**
     * Message used when method name supplied is not 'getTokenData'
     */
    private static final String ERROR_UNSUPPORTED = 'Unsupported method. Only method [getTokenData] is supported.';

    //Standing Charge Product code
    private static final String STANDING_CHARGE_PRODUCT = 'BG_STD';

    //Unit Rate Product code
    private static final String UNIT_RATE_PRODUCT = 'BG_UNITRATE';

    private static final String PRICE_CURVE_DAILY = 'Daily/Bespoke';

    private static final Integer DEFAULT_PAGE_OFFSET = 100;
    private static final String COUNT_RECORD_LINES;

    //List of product codes
    private static final List<String> LIST_PRODUCT_CODES = new List<String> {STANDING_CHARGE_PRODUCT, UNIT_RATE_PRODUCT};

    /**
     * Specify the namespace prefix of deployed package
     */
    private static final String NAMESPACE_PREFIX = 'vlocity_cmt__';

    private static final String SUB_QUOTE_RT_DEV_NAME = 'SubQuote';

    private static final String QUERY_DRMAP_ITEM;

    static{

        COUNT_RECORD_LINES = 'SELECT count() FROM Quote where vlocity_cmt__ParentQuoteId__c=:recordId AND recordType.DeveloperName = \''+SUB_QUOTE_RT_DEV_NAME+'\'';

        String queryDrMapItem = 
            'SELECT Id, $nmspc$FilterValue__c ' +
            'FROM $nmspc$DRMapItem__c ' +
            'WHERE $nmspc$FilterOperator__c=\'LIMIT\' AND Name=:extractDR';
        
        QUERY_DRMAP_ITEM = queryDrMapItem.replace('$nmspc$', NAMESPACE_PREFIX);
    }

    global Object invokeMethod(String methodName, Map<String, Object> input, Map<String, Object> output, Map<String, Object> options){

        Boolean success = true;
        String jsonDRValue = '';

        //Purpose of this method is to replace the DataRaptor SWAN_ExtractOfferPackDetails 
        if (methodName == 'getTokenData' && !input.containsKey('tokenDataQueryInfo')) {
            return getSiteAdditionValuesFromDR(input, output, jsonDRValue);
        }else if(methodName == 'getTokenData' && input.containsKey('tokenDataQueryInfo')){
                return getQueryInfoAndSiteAddFromSOQL(input, output);
        }else{
            throw new CustomExtractAndTransformDataForOfferPackException(ERROR_UNSUPPORTED);
        }
    }

    private Boolean getSiteAdditionValuesFromDR(Map<String, Object> input, Map<String, Object> output, String outputJson){                
        
        Map<String, Object> drInput = new Map<String, Object>();        
        drInput.put('Id', (Id) input.get('contextId')); 

        List<Map<String, Object>> drInputs = new List<Map<String, Object>>();
        drInputs.add(drInput);
        
        vlocity_cmt.DRProcessResult drProcessResult = vlocity_cmt.DRGlobal.process(drInputs, 'SWAN_ExtractSiteAdditionQuoteDetailsForApex');
        
        
        if(drProcessResult.hasErrors()){
            return false;
        } else {
            //drProcessResult.toJson() returns a map<String, Object> representing a JSON where Key is the node name and Value is a Map<String, Object> 
            Map<String, Object> paginationInformation = initializePaginationInfo((Id) input.get('contextId'));
            Integer totalItems = (Integer) paginationInformation.get('totalItems');  
            output.put('hasMoreTokenData', totalItems > 0);
            output.put('tokenMap', drProcessResult.toJson());
            output.put('tokenDataQueryInfo',paginationInformation);
            return true;
        }
    }

    private boolean getQueryInfoAndSiteAddFromSOQL(Map<String, Object> input, Map<String, Object> output){
        Map<String, Object> paginationInformation = (Map<string,object>)(JSON.deserializeUntyped(String.valueof(input.get('tokenDataQueryInfo'))));

        Id parentQuoteId = (Id) input.get('contextId');
        Id lastItemId = (Id) paginationInformation.get('lastItemId');
        Integer recordNumber = (Integer) paginationInformation.get('recordNumber');
        Integer totalItems = (Integer) paginationInformation.get('totalItems');
        Integer pageOffset = (Integer) paginationInformation.get('pageOffset');
        
        Map<Id,Quote> mapChildQuotes = getSiteAddChildQuotes(parentQuoteId, lastItemId, pageOffset);
        getSiteAddValueFromSOQL(mapChildQuotes,output);
        
        List<Id> lstKeySet= new List<Id>(mapChildQuotes.keySet());
        lstKeySet.sort();
        
        paginationInformation.put('lastItemId', lstKeySet.get(0));
        recordNumber+=DEFAULT_PAGE_OFFSET;
        paginationInformation.put('recordNumber', recordNumber);
        system.debug('totalItems: '+totalItems+'\trecordNumber: '+recordNumber);
        
        output.put('tokenDataQueryInfo', paginationInformation);
        output.put('hasMoreTokenData', (totalItems > recordNumber ? true : false));
 
        return true;
    }

    private Map<Id,Quote> getSiteAddChildQuotes(Id parentQuoteId, Id lastItemId, Integer pageOffset){
         
        if (lastItemId == null){
            return new Map<Id,Quote>([SELECT id,vlocity_cmt__DefaultServicePointId__c,swan_parent_quote__c,accountid,contactid,ownerid,swan_site_addition_parent__c,opportunityid,swan_broker__c,swan_annual_spend__c,swan_sales_channel__c,swan_broker_commission__c,swan_contract_volume_kwh__c,swan_payment_method__c,swan_payment_term__c,billingcountry,billingpostalcode,billingstreet,billingcity,name,email,swan_broker__r.name,phone,swan_service_point_end_date__c,swan_service_point_start_date__c,swan_number_of_service_points__c,swan_pricing_structure__c,quotenumber,swan_offer_end_date__c,swan_offer_start_date__c FROM Quote WHERE vlocity_cmt__ParentQuoteId__c = :parentQuoteId AND recordType.DeveloperName = :SUB_QUOTE_RT_DEV_NAME ORDER BY ID LIMIT :pageOffset]);
        }else {
            return new Map<Id,Quote>([SELECT id,vlocity_cmt__DefaultServicePointId__c,swan_parent_quote__c,accountid,contactid,ownerid,swan_site_addition_parent__c,opportunityid,swan_broker__c,swan_annual_spend__c,swan_sales_channel__c,swan_broker_commission__c,swan_contract_volume_kwh__c,swan_payment_method__c,swan_payment_term__c,billingcountry,billingpostalcode,billingstreet,billingcity,name,email,swan_broker__r.name,phone,swan_service_point_end_date__c,swan_service_point_start_date__c,swan_number_of_service_points__c,swan_pricing_structure__c,quotenumber,swan_offer_end_date__c,swan_offer_start_date__c FROM Quote WHERE vlocity_cmt__ParentQuoteId__c = :parentQuoteId AND ID > :lastItemId AND recordType.DeveloperName = :SUB_QUOTE_RT_DEV_NAME ORDER BY Id LIMIT :pageOffset]);
        }
    }

    //Get all the object values through SOQL due to possible large volumes of data, limited to 50000 records per object
    private boolean getSiteAddValueFromSOQL(Map<Id,Quote> mapChildQuotes, Map<String, Object> output){

        Map<String, Object> tokenMap = new Map<String, Object>();
               
        List<Id> lstServicePointIdsFromChildQuotes = new List<Id>();
        for(Quote q : mapChildQuotes.values()){
            lstServicePointIdsFromChildQuotes.add(q.vlocity_cmt__DefaultServicePointId__c);
        }

        Map<Id, vlocity_cmt__ServicePoint__c> mapServicePoints = new Map<Id, vlocity_cmt__ServicePoint__c>([SELECT id, swan_formula_year_annual_quantity__c,swan_formula_year_offtake_quantity__c,name,createddate,vlocity_cmt__servicepointnumber__c,swan_service_point_reference__c FROM vlocity_cmt__ServicePoint__c WHERE Id in :lstServicePointIdsFromChildQuotes LIMIT 50000]);
        
        Map<Id, QuoteLineItem> mapChildQuoteLineItems = new Map<Id, QuoteLineItem>([SELECT id,swan_service_point__c,Quoteid,Quote.vlocity_cmt__DefaultServicePointId__c,product2id,product2.vlocity_cmt__isorderable__c,product2.Name,Product2.ProductCode,vlocity_cmt__jsonattribute__c,vlocity_cmt__recurringcharge__c,swan_unitrate__c FROM QuoteLineItem WHERE QuoteId in :mapChildQuotes.keySet() LIMIT 50000]);

        Map<Id, Decimal> mapQuoteLineItemsStandingChargeByQuoteId = new Map<Id, Decimal>();
        Map<Id, Decimal> mapQuoteLineItemsUnitRateByQuoteId = new Map<Id, Decimal>();
        Map<Id, QuoteLineItem> mapQuoteLineItemsOrderableByQuoteId = new Map<Id, QuoteLineItem>();
        Set<Id> setProductIds = new Set<Id>();
        String orderableProductName;
        Product2 orderableProduct;

        for(QuoteLineItem qli : mapChildQuoteLineItems.values()){

            setProductIds.add(qli.Product2Id);    

            if(qli.product2.vlocity_cmt__isorderable__c){
                orderableProductName = qli.product2.Name;
                orderableProduct = qli.product2;
                mapQuoteLineItemsOrderableByQuoteId.put(qli.QuoteId, qli);
            }

            if(qli.product2.ProductCode.equalsIgnoreCase(STANDING_CHARGE_PRODUCT)){
                mapQuoteLineItemsStandingChargeByQuoteId.put(qli.QuoteId, qli.vlocity_cmt__RecurringCharge__c);
            }
            
            if(qli.product2.ProductCode.equalsIgnoreCase(UNIT_RATE_PRODUCT)){
                mapQuoteLineItemsUnitRateByQuoteId.put(qli.QuoteId, qli.SWAN_UnitRate__c);
            }
        }


        Map<String,Object> mapChildQuotesTokens = new Map<String,Object>();
        List<Object> lstTokenChildQuotes = new List<Object>();

        for(Quote q : mapChildQuotes.values()){

            Map<String,Object> mapTokenSingleChildQuote = new Map<String,Object>();
            QuoteLineItem qli = mapQuoteLineItemsOrderableByQuoteId.get(q.Id);


            JSON2Apex jj = new JSON2Apex();
            Map<Id,List<JSON2Apex.SWAN_SP_ATT_CAT>> map_sp_Wrapper = new Map<Id,List<JSON2Apex.SWAN_SP_ATT_CAT>>();
            
            String json = (String)mapQuoteLineItemsOrderableByQuoteId.get(q.Id).vlocity_cmt__JSONAttribute__c;
            if(String.IsNotBlank(json)){
                jj = JSON2Apex.parse(json);        
                map_sp_Wrapper.put(qli.Quote.vlocity_cmt__DefaultServicePointId__c,jj.SWAN_SP_ATT_CAT);
            }            

            if(map_sp_Wrapper.containskey(q.vlocity_cmt__DefaultServicePointId__c)){

                String customerAQEffFromDate = null;
                Date customerAQEffFromDateValue = null;
                String customerAQEffToDate = null;
                Date customerAQEffToDateValue = null;
                String customerAQ = null;
                String customerSOQ = null;

                for(JSON2Apex.SWAN_SP_ATT_CAT qli_attb : map_sp_Wrapper.get(q.vlocity_cmt__DefaultServicePointId__c)){
                    //system.debug('customerAQEffFromDate: '+qli_attb+'\t q.vlocity_cmt__DefaultServicePointId__c: '+q.vlocity_cmt__DefaultServicePointId__c+'\tQ: '+q.Id);
                    if(qli_attb.attributedisplayname == 'Customer AQ Effective From Date' && String.isNotBlank(qli_attb.value)){
                        customerAQEffFromDate = qli_attb.value;
                        customerAQEffFromDateValue= ((customerAQEffFromDate!=null && customerAQEffFromDate!='')?date.valueOf((customerAQEffFromDate).contains('T')?(customerAQEffFromDate).substring(0,(customerAQEffFromDate).indexOf('T')):customerAQEffFromDate):null);
                        //customerAQEffFromDateValue = Date.parse(customerAQEffFromDate);
                    }else if(qli_attb.attributedisplayname == 'Customer AQ Effective To Date' && String.isNotBlank(qli_attb.value)){
                        customerAQEffToDate = qli_attb.value;
                        customerAQEffToDateValue= ((customerAQEffToDate!=null && customerAQEffToDate!='')?date.valueOf((customerAQEffToDate).contains('T')?(customerAQEffToDate).substring(0,(customerAQEffToDate).indexOf('T')):customerAQEffToDate):null);
                        //customerAQEffToDateValue = Date.parse(customerAQEffToDate);
                    }else if(qli_attb.attributedisplayname == 'Customer AQ'){
                        customerAQ = qli_attb.value;
                    }else if(qli_attb.attributedisplayname == 'Customer SOQ'){
                        customerSOQ = qli_attb.value;
                    }
                }

     
                if(((customerAQEffFromDate == null && customerAQEffToDate == null || customerAQEffFromDate != null && customerAQEffToDate == null 
                     && customerAQEffFromDateValue.daysBetween(q.SWAN_Service_Point_End_Date__c) > 0)
                    || (customerAQEffToDate != null && customerAQEffFromDateValue == null && customerAQEffToDateValue.daysBetween(q.SWAN_Service_Point_Start_Date__c) <= 0)
                    || (customerAQEffFromDate != null && customerAQEffToDate != null && customerAQEffFromDateValue.daysBetween(q.SWAN_Service_Point_End_Date__c) >= 0 && customerAQEffToDateValue.daysBetween(q.SWAN_Service_Point_Start_Date__c) <= 0))
                   && customerAQ != null && customerSOQ!= null){     
                       
                       mapTokenSingleChildQuote.put('FYAQ', customerAQ);  
                       mapTokenSingleChildQuote.put('FYSOQ', customerSOQ);
                       
                   } 
            }

            if(!mapTokenSingleChildQuote.containsKey('FYAQ')){
                mapTokenSingleChildQuote.put('FYAQ', mapServicePoints.get(q.vlocity_cmt__DefaultServicePointId__c).SWAN_Formula_Year_Annual_Quantity__c);
            }

            if(!mapTokenSingleChildQuote.containsKey('FYSOQ')){
                mapTokenSingleChildQuote.put('FYSOQ',mapServicePoints.get(q.vlocity_cmt__DefaultServicePointId__c).SWAN_Formula_Year_Offtake_Quantity__c);
            }
            
            String standingCharge = null;
            
            try{
                standingCharge = String.valueOf(mapQuoteLineItemsStandingChargeByQuoteId.get(q.Id).format());
                String tempValue = (standingCharge.indexOf('.')) == -1 ? standingCharge + '.000' : standingCharge + '000';
                standingCharge = tempValue.substring(0,tempValue.indexOf('.') + 4);
                mapTokenSingleChildQuote.put('StandingCharge', tempValue.substring(0,tempValue.indexOf('.') + 4));
            }catch(Exception ex){
                mapTokenSingleChildQuote.put('StandingCharge', '0.000');
            }

            String unitRate = null;
            
            try{
                unitRate = String.valueOf(mapQuoteLineItemsUnitRateByQuoteId.get(q.Id).format()); 
                String tempValue = (unitRate.indexOf('.')) == -1 ? unitRate + '.000' : unitRate + '000';
                mapTokenSingleChildQuote.put('UnitRate', tempValue.substring(0,tempValue.indexOf('.') + 4));
            }catch(Exception ex) {
                mapTokenSingleChildQuote.put('UnitRate', '0.000');
            }
                        
            String referenceName = mapServicePoints.get(q.vlocity_cmt__DefaultServicePointId__c).SWAN_Service_Point_Reference__c;
            mapTokenSingleChildQuote.put('Reference', (String.isNotBlank(referenceName) ? referenceName:mapServicePoints.get(q.vlocity_cmt__DefaultServicePointId__c).vlocity_cmt__servicepointnumber__c));
            mapTokenSingleChildQuote.put('ServicePointNumber', mapServicePoints.get(q.vlocity_cmt__DefaultServicePointId__c).vlocity_cmt__servicepointnumber__c);
            mapTokenSingleChildQuote.put('ServicePointStartDate', DateFormatter(q.SWAN_Service_Point_Start_Date__c));
            mapTokenSingleChildQuote.put('EstConsumption', q.SWAN_Contract_Volume_KWh__c);
            mapTokenSingleChildQuote.put('EstAnnualSpend', '£'+q.SWAN_Annual_Spend__c);

            lstTokenChildQuotes.add(mapTokenSingleChildQuote);
        }

        mapChildQuotesTokens.put('ChildQuotes',lstTokenChildQuotes);
        
        tokenMap.putAll(mapChildQuotesTokens);
        output.put('tokenMap', tokenMap);
        
        return true;
    }

    private void updatePageOffset(Map<String, Object> pageInfo) {
        Integer pageOffset = (Integer) pageInfo.get('pageOffset');
        Integer recordNumber = (Integer) pageInfo.get('recordNumber');
        
        Integer nextPageOffset = recordNumber + pageOffset;
        
        pageInfo.put('recordNumber', nextPageOffset);
    } 

    private Map<String, Object> initializePaginationInfo(Id recordId) { 
        Integer totalItems = countRecordItems(recordId);
            
        Map<String, Object> paginationInformation = new Map<String, Object>();
        paginationInformation.put('queryHeader', true);
        paginationInformation.put('queryLine', true);
        paginationInformation.put('recordNumber', 0);
        paginationInformation.put('pageOffset', DEFAULT_PAGE_OFFSET);
        paginationInformation.put('totalItems', totalItems);
        
        return paginationInformation;
    }

    private Integer getPageOffset(String extractDR) {
        vlocity_cmt__DRMapItem__c mapItem = Database.query(QUERY_DRMAP_ITEM);
        return Integer.valueOf(mapItem.get(NAMESPACE_PREFIX + 'FilterValue__c'));

    }

    private Integer countRecordItems(Id recordId) {
        return Database.countQuery(COUNT_RECORD_LINES);
    }

    private String DateFormatter(Date dateToBeFormatted) {
        return DateTime.newInstance(dateToBeFormatted, Time.newInstance(3, 3, 3, 0)).format('dd/MM/YYYY');
    }
     class CustomExtractAndTransformDataForOfferPackException extends Exception {
        
    }

}