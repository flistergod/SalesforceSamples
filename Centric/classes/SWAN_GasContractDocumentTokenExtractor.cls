global with sharing class SWAN_GasContractDocumentTokenExtractor implements vlocity_cmt.VlocityOpenInterface2 
{   
    /**
     *
     */
    private static final Integer DEFAULT_PAGE_OFFSET = 500;
    
    /**
     * Message used when DataRaptor processing encountered any error
     */
    private static final String ERROR_DR_MESSAGE = 'Error encountered while processing request. Please check log for details.';

    /**
     * Message used when method name supplied is not 'getTokenData'
     */
    private static final String ERROR_UNSUPPORTED = 'Unsupported method. Only method [getTokenData] is supported.';

    /**
     * Specify the DataRaptor Extractor for header data
     */
    //private static final String DR_EXTRACT_HEADER = 'Custom Class Docx Header Extract';
    private static final String DR_EXTRACT_HEADER = 'SWAN_ExtractContractAndAccount';

    /**
     * Specify the Fuel Type for the DataRaptor Extractor for header data
     */
    private static final String DR_FUEL_TYPE = 'Gas';

    /**
     * Specify the namespace prefix of deployed package
     */
    private static final String NAMESPACE_PREFIX = 'vlocity_cmt__';

    /**
     * Project prefix
     */
    private static final String PROJECT_PREFIX = 'SWAN_';

    /**
     * Standing charge product code
     */
    private static final String STD_CHRG = 'BG_STD';

    /**
     * Unit Rate product code
     */
    private static final String UNIT_RATE = 'BG_UNITRATE';
    
    /**
     * 
     */
    private static final String COUNT_CONTRACT_LINES;

    /**
     * 
     */
    private static final String QUERY_INITIAL_CONTRACT_LINES;
    
    /**
     * 
     */
    private static final String QUERY_SUCCEEDING_CONTRACT_LINES; 

    /**
     * 
     */
    private static final String QUERY_OPPORTUNITY_LINE_ITEMS; 

    /**
     * 
     */
    private static final String QUERY_QUOTE_LINE_ITEMS; 

    /**
     * 
     */
    private static final String QUERY_DRMAP_ITEM;
     
    /**
     * Initialize queries to be used to include namespace prefix
     */
    
    static

    {

        String queryCountContractLines = 
            'SELECT count() ' +
            'FROM $nmspc$contractlineitem__c ' +
            'WHERE $nmspc$ContractId__c = :contractId AND $nmspc$OriginalLineItemId__c = null';
        
        COUNT_CONTRACT_LINES = queryCountContractLines.replace('$nmspc$', NAMESPACE_PREFIX);

        String queryContractLines =
            'SELECT Id, $nmspc$ContractId__c, $prjprfx$Quote__c, (SELECT $prjprfx$UnitRate__c, $nmspc$RecurringCharge__c, $nmspc$ProductCode__c ' +
            'FROM $nmspc$Contract_Line_Items__r WHERE $nmspc$ProductCode__c = :UNIT_RATE OR $nmspc$ProductCode__c = :STD_CHRG), ' +
            '$prjprfx$Service_Point__c, FORMAT($prjprfx$Service_Point_Start_Date__c), FORMAT($prjprfx$Contract_Volume__c), FORMAT($prjprfx$Service_Point_End_Date__c), ' +
            'FORMAT($prjprfx$Service_Point__r.$prjprfx$Formula_Year_Offtake_Quantity__c), ' +
            '$prjprfx$Service_Point__r.$nmspc$ServicePointNumber__c, $prjprfx$Service_Point__r.$nmspc$PremisesId__r.$prjprfx$House_Name__c,' +
            '$prjprfx$Service_Point__r.$nmspc$PremisesId__r.$prjprfx$House_Number__c, $prjprfx$Service_Point__r.$nmspc$PremisesId__r.$nmspc$City__c,' + 
            '$prjprfx$Service_Point__r.$nmspc$PremisesId__r.$nmspc$PostalCode__c, $prjprfx$Service_Point__r.$nmspc$PremisesId__r.$nmspc$State__c,' +
            '$prjprfx$Service_Point__r.$nmspc$PremisesId__r.$nmspc$StreetAddress__c ' +
            'FROM $nmspc$contractlineitem__c ' +
            'WHERE $nmspc$ContractId__c = :contractId AND $nmspc$OriginalLineItemId__c = null ' +
            'ORDER BY Id, $prjprfx$Service_Point__c ' +
            'LIMIT :pageOffset';

        QUERY_INITIAL_CONTRACT_LINES = (queryContractLines.replace('$nmspc$', NAMESPACE_PREFIX)).replace('$prjprfx$', PROJECT_PREFIX);

        String querySucceedingContractLines = 
            'SELECT Id, $nmspc$ContractId__c, $prjprfx$Quote__c, (SELECT $prjprfx$UnitRate__c, $nmspc$RecurringCharge__c, $nmspc$ProductCode__c ' +
            'FROM $nmspc$Contract_Line_Items__r WHERE $nmspc$ProductCode__c = :UNIT_RATE OR $nmspc$ProductCode__c = :STD_CHRG),' +
            '$prjprfx$Service_Point__c, FORMAT($prjprfx$Service_Point_Start_Date__c), FORMAT($prjprfx$Contract_Volume__c), FORMAT($prjprfx$Service_Point_End_Date__c), ' +
            'FORMAT($prjprfx$Service_Point__r.$prjprfx$Formula_Year_Offtake_Quantity__c), ' +
            '$prjprfx$Service_Point__r.$nmspc$ServicePointNumber__c, $prjprfx$Service_Point__r.$nmspc$PremisesId__r.$prjprfx$House_Name__c,' +
            '$prjprfx$Service_Point__r.$nmspc$PremisesId__r.$prjprfx$House_Number__c, $prjprfx$Service_Point__r.$nmspc$PremisesId__r.$nmspc$City__c,' + 
            '$prjprfx$Service_Point__r.$nmspc$PremisesId__r.$nmspc$PostalCode__c, $prjprfx$Service_Point__r.$nmspc$PremisesId__r.$nmspc$State__c,' +
            '$prjprfx$Service_Point__r.$nmspc$PremisesId__r.$nmspc$StreetAddress__c ' +
            'FROM $nmspc$contractlineitem__c ' +
            'WHERE $nmspc$ContractId__c = :contractId AND $nmspc$OriginalLineItemId__c = null AND Id >: lastItemId ' +
            'ORDER BY Id, $prjprfx$Service_Point__c ' +
            'LIMIT :pageOffset';

        QUERY_SUCCEEDING_CONTRACT_LINES = (querySucceedingContractLines.replace('$nmspc$', NAMESPACE_PREFIX)).replace('$prjprfx$', PROJECT_PREFIX);

        String queryOpportunityLineItems = 
            'SELECT $nmspc$ServicePointId__c ' + 
            'FROM OpportunityLineItem ' +
            'WHERE OpportunityId = :opportunityId';

        QUERY_OPPORTUNITY_LINE_ITEMS = (queryOpportunityLineItems.replace('$nmspc$', NAMESPACE_PREFIX));

        String queryQuoteLineItems = 
            'SELECT Id, Quote.vlocity_cmt__DefaultServicePointId__c, vlocity_cmt__JSONAttribute__c ' +
            'FROM QuoteLineItem ' +
            'WHERE Quote.vlocity_cmt__ParentQuoteId__c = :quoteId ' +
            'AND Quote.vlocity_cmt__DefaultServicePointId__c IN :lstServicePointIds';

        QUERY_QUOTE_LINE_ITEMS = (queryQuoteLineItems.replace('$nmspc$', NAMESPACE_PREFIX)).replace('$prjprfx$', PROJECT_PREFIX);

    }
    
    /**
     * Invoke the methd sspecified in the input map
     */
    global Object invokeMethod(
        String methodName, 
        Map<String, Object> input,
        Map<String, Object> output, 
        Map<String, Object> options) 
    {
        Boolean success = false;
            
        System.debug('invokeMethod:methodName -> ' + methodName);
        System.debug('invokeMethod:input-> ' + input);
        
        if (methodName == 'getTokenData') 
        {
            success = getTokenData(input, output, options);
        } 
        else 
        {
            throw new SWAN_GasContractDocumentTokenExtractorException(ERROR_UNSUPPORTED);
        }

        //System.debug('invokeMethod:output -> ' + output);
        System.debug('invokeMethod:success -> ' + success);
        return success;
    }

    /**
     * Retrieve the token data for the document template
     */
    public Boolean getTokenData(
        Map<String, Object> input, 
        Map<String, Object> output, 
        Map<String, Object> options)
    {        
        Boolean success = false;
        
        Id contractId = (Id) input.get('contextId');
                
        if (!input.containsKey('tokenDataQueryInfo')) 
        {
            // Retrieve contract and account data
            success = getContractTokenData(input, output, options);
        } 
        else 
        {
            // Retrieve contract line item data
            success = getContractItemsTokenData(input, output, options);
        }
        
        System.debug('getTokenData:success -> ' + success);
        return success;
    }
    
    /**
     * Retrieve contract and account data by invoking a DataRaptor
     * Initialise pagination information
     */
    public Boolean getContractTokenData(
        Map<String, Object> input, 
        Map<String, Object> output, 
        Map<String, Object> options)
    { 
        Boolean success = false;
        
        Id contractId = (Id) input.get('contextId');
        
        List<Map<String, Object>> DRinputs = new List<Map<String, Object>>();
        Map<String, Object> DRinput = new Map<String, Object>();
        
        DRinput.put('Id', contractId); 
        DRinput.put('FuelType', DR_FUEL_TYPE);
        DRinputs.add(DRinput);
        System.debug('DRinputs->' + DRinputs);
        System.debug('DR_EXTRACT_HEADER->' + DR_EXTRACT_HEADER);
        vlocity_cmt.DRProcessResult drProcessResult = vlocity_cmt.DRGlobal.process(DRInputs, DR_EXTRACT_HEADER);
        System.debug('drProcessResult ->' + drProcessResult);
        Map<String, Object> resultMap = drProcessResult.convertToMap();
        Id opportunityId = (Id) (((Map<String,Object>)resultMap.get('returnResultsData')).get('OpportunityId'));
        System.debug('getContractTokenData:opportunityId ->' + opportunityId);
        Id quoteId = (Id) (((Map<String,Object>)resultMap.get('returnResultsData')).get('QuoteId'));
        System.debug('getContractTokenData:quoteId ->' + quoteId);
        
        System.debug('getContractTokenData:resultMap ->' + resultMap);
        
        if (!drProcessResult.hasErrors())
        {
            Map<String, Object> paginationInformation = initializePaginationInfo(contractId, opportunityId, quoteId);
            Integer totalItems = (Integer) paginationInformation.get('totalItems');  
            output.put('hasMoreTokenData', totalItems > 0);
            output.put('tokenMap', (Map<String,Object>)resultMap.get('returnResultsData'));
            output.put('tokenDataQueryInfo', paginationInformation);

            success = true;
        }
        else 
        {
            throw new SWAN_GasContractDocumentTokenExtractorException(ERROR_DR_MESSAGE);
        }
        
        System.debug('getContractTokenData:output -> ' + output);
        System.debug('getContractTokenData:success -> ' + success);
        return success;
    }
    
    /**
     * Retrieve the contract line item data
     */
    private Boolean getContractItemsTokenData(
        Map<String, Object> input, 
        Map<String, Object> output, 
        Map<String, Object> options)
    { 
        Boolean success = true;

        //System.debug((MAP<string,object>)(JSON.deserializeUntyped(String.valueof(input.get('tokenDataQueryInfo'))))+'\n===ret');
        Map<String, Object> paginationInformation;
        if(!Test.IsRunningTest()){
            paginationInformation = (MAP<string,object>)(JSON.deserializeUntyped(String.valueof(input.get('tokenDataQueryInfo'))));
        }
        if(Test.IsRunningTest()){
            paginationInformation = (MAP<string,object>)input.get('tokenDataQueryInfo');
        }
        //Id contractId = (Id) paginationInformation.get('contractId');
        Id contractId = (Id) input.get('contextId');
        Id lastItemId = (Id) paginationInformation.get('lastItemId');
        Integer recordNumber = (Integer) paginationInformation.get('recordNumber');
        Integer totalItems = (Integer) paginationInformation.get('totalItems');
        Integer pageOffset = (Integer) paginationInformation.get('pageOffset');
        
        List<vlocity_cmt__ContractLineItem__c> lineItems = getContractLineItems(contractId, lastItemId, pageOffset);
        
        vlocity_cmt__ContractLineItem__c lastItem = lineItems.get(lineItems.size()-1);
        paginationInformation.put('lastItemId', lastItem.Id);
        paginationInformation.put('recordNumber', recordNumber += pageOffset);
        
        output.put('tokenMap', extractContractLineItemDetails(lineItems, paginationInformation));
        output.put('tokenDataQueryInfo', paginationInformation);
        output.put('hasMoreTokenData', (totalItems > recordNumber ? true : false));
        
        System.debug('getContractItemsTokenData:output -> ' + output);
        System.debug('getContractItemsTokenData:success -> ' + success);
        return success;
    }
    
    /**
     * Retrieve the contract line data by running the queries defined to do so
     */
    private List<vlocity_cmt__ContractLineItem__c> getContractLineItems(Id contractId, Id lastItemId, Integer pageOffset)
    {
        List<vlocity_cmt__ContractLineItem__c> lineItems = null;
        if (lastItemId == null)
        {
            System.debug('getContractLineItems() QUERY_INITIAL_CONTRACT_LINES -> ' + QUERY_INITIAL_CONTRACT_LINES);
            lineItems = Database.query(QUERY_INITIAL_CONTRACT_LINES);
        }
        else 
        {
            lineItems = Database.query(QUERY_SUCCEEDING_CONTRACT_LINES);
        }

        System.debug('getContractLineItems() lineItems -> ' + lineItems);           
        return lineItems;
    }
    
    /**
     * Retrieve data items to place into the token map.  This method also handles any formatting requirements.
     */
    private Map<String, Object> extractContractLineItemDetails(List<vlocity_cmt__ContractLineItem__c> lineItems, Map<String, Object> paginationInformation) 
    {
        // Retrieve the Quote Line Items from paginationInformation
        Map<String, Object> quoteLineItems = (MAP<String, Object>)(paginationInformation.get('quoteLineItems'));
 
        List<Map<String, Object>> lineItemDetails = new List<Map<String, Object>>();  
        
        for (vlocity_cmt__ContractLineItem__c lineItem : lineItems)
        {
            
            String servicePointNumber = String.valueOf(lineItem.getSobject(PROJECT_PREFIX + 'Service_Point__r').get(NAMESPACE_PREFIX + 'ServicePointNumber__c'));
            String servicePointHouseName = String.valueOf(lineItem.getSobject(PROJECT_PREFIX + 'Service_Point__r').getSobject(NAMESPACE_PREFIX + 'PremisesId__r').get(PROJECT_PREFIX + 'House_Name__c'));
            String servicePointHouseNumber = String.valueOf(lineItem.getSobject(PROJECT_PREFIX + 'Service_Point__r').getSobject(NAMESPACE_PREFIX + 'PremisesId__r').get(PROJECT_PREFIX + 'House_Number__c'));
            String servicePointCity = String.valueOf(lineItem.getSobject(PROJECT_PREFIX + 'Service_Point__r').getSobject(NAMESPACE_PREFIX + 'PremisesId__r').get(NAMESPACE_PREFIX + 'City__c'));
            String servicePointPostalCode = String.valueOf(lineItem.getSobject(PROJECT_PREFIX + 'Service_Point__r').getSobject(NAMESPACE_PREFIX + 'PremisesId__r').get(NAMESPACE_PREFIX + 'PostalCode__c'));
            String servicePointState = String.valueOf(lineItem.getSobject(PROJECT_PREFIX + 'Service_Point__r').getSobject(NAMESPACE_PREFIX + 'PremisesId__r').get(NAMESPACE_PREFIX + 'State__c'));
            String servicePointStreet = String.valueOf(lineItem.getSobject(PROJECT_PREFIX + 'Service_Point__r').getSobject(NAMESPACE_PREFIX + 'PremisesId__r').get(NAMESPACE_PREFIX + 'StreetAddress__c'));
            String servicePointFYSOQ = String.valueOf(lineItem.getSobject(PROJECT_PREFIX + 'Service_Point__r').get(PROJECT_PREFIX + 'Formula_Year_Offtake_Quantity__c'));
            String servicePointVolume = String.valueOf(lineItem.get(PROJECT_PREFIX + 'Contract_Volume__c'));
            String servicePointDt = String.valueOf(lineItem.get(PROJECT_PREFIX + 'Service_Point_Start_Date__c'));
            String servicePointStartDate = '';
            Date servicePointDate;
            If (servicePointDt != null) {
                servicePointDate = Date.parse(servicePointDt);
                servicePointStartDate = DateTime.newInstance(servicePointDate.year(),servicePointDate.month(),servicePointDate.day()).format('dd MMM YYYY');
            }
            String servicePointEndDt = String.valueOf(lineItem.get(PROJECT_PREFIX + 'Service_Point_End_Date__c'));
            Date servicePointEndDate;
            If (servicePointEndDt != null) {
                servicePointEndDate = Date.parse(servicePointEndDt);
                //servicePointEndDate = DateTime.newInstance(servicePointEndDate.year(),servicePointEndDate.month(),servicePointEndDate.day()).format('dd MMM YYYY');
            }
            // Declare variables that will be set in the inner loop
            String standingCharge = null;
            String unitRate = null;

            for(vlocity_cmt__contractlineitem__c childCLI : lineItem.vlocity_cmt__Contract_Line_Items__r)
            {
                String tempValue; 
                // Standing charge
                If (String.valueOf(childCLI.get(NAMESPACE_PREFIX + 'ProductCode__c')) == STD_CHRG) {
                    standingCharge = String.valueOf(childCLI.get(NAMESPACE_PREFIX + 'RecurringCharge__c'));

                    // Check if the standing charge is null
                    If (standingCharge != null) {
                        standingCharge = String.valueOf(decimal.valueOf(standingCharge).format());
                        tempValue = (standingCharge.indexOf('.')) == -1 ? standingCharge + '.000' : standingCharge + '000';
                        standingCharge = tempValue.substring(0,tempValue.indexOf('.') + 4);
                    }
                    
                }
                // Unit rate
                If (String.valueOf(childCLI.get(NAMESPACE_PREFIX + 'ProductCode__c')) == UNIT_RATE) {
                    unitRate = String.valueOf(childCLI.get(PROJECT_PREFIX + 'UnitRate__c'));

                    // Check if the unit rate is null
                    If (unitRate != null) {
                        unitRate = String.valueOf(decimal.valueOf(unitRate).format()); 
                        tempValue = (unitRate.indexOf('.')) == -1 ? unitRate + '.000' : unitRate + '000';
                        unitRate = tempValue.substring(0,tempValue.indexOf('.') + 4); 
                    }
                    
                }
            }

            String customerSOQValue = null;
            String servicePointId = String.valueOf(lineItem.get(PROJECT_PREFIX + 'Service_Point__c'));

            // Check if this service point has customer AQ
            If (quoteLineItems.size() > 0 && quoteLineItems.containsKey(servicePointId)) {
                String customerSOQ;
                Date customerAQEffFromDateValue;
                Date customerAQEffToDateValue;

                System.debug('In the quote line item attribute check -> '); //System.debug('quoteLineItems.get(servicePointId) --> ' + quoteLineItems.get(servicePointId));

                for(object Attr : (List<object>) ((Map<String, Object>)JSON.deserializeUntyped(String.valueof(quoteLineItems.get(servicePointId)))).get('SWAN_SP_ATT_CAT'))
                {
                    String key = (string) ((map<string,object>)Attr).get('attributeuniquecode__c');
                    
                    if(key == 'SWAN_ATT_CUST_SOQ')
                    {
                        customerSOQ = string.valueof(((MAP<string,object>)((map<string,object>)Attr).get('attributeRunTimeInfo')).get('value'));
                    }
                    else if(key == 'SWAN_ATT_CUST_EFF_FROM')
                    {
                        object value = ((MAP<string,object>)((map<string,object>)Attr).get('attributeRunTimeInfo')).get('value');
                        customerAQEffFromDateValue= ((value!=null && (String.isNotBlank((String)value)))?date.valueOf(((string)value).contains('T')?((string)value).substring(0,((string)value).indexOf('T')):(string)value):null);
                        //system.debug(value +'<=fromdate=>'+customerAQEffFromDateValue);
                    }
                    else if(key == 'SWAN_ATT_CUST_EFF_TO')
                    {
                        object value = ((MAP<string,object>)((map<string,object>)Attr).get('attributeRunTimeInfo')).get('value');
                        customerAQEffToDateValue= ((value!=null && (String.isNotBlank((String)value)))?date.valueOf(((string)value).contains('T')?((string)value).substring(0,((string)value).indexOf('T')):(string)value):null);
                        //system.debug(value +'<=todate=>'+customerAQEffFromDateValue);
                    }
                }

                //System.debug('customerSOQ --> ' + customerSOQ + 'customerAQEffFromDateValue --> ' + customerAQEffFromDateValue + ' customerAQEffToDateValue --> ' + customerAQEffToDateValue + ' servicePointEndDate --> ' + servicePointEndDate 
                //            + ' customerAQEffFromDateValue.daysBetween(servicePointEndDate) --> ' + customerAQEffFromDateValue.daysBetween(servicePointEndDate) 
                //            + ' customerAQEffToDateValue.daysBetween(servicePointEndDate) --> ' + customerAQEffToDateValue.daysBetween(servicePointEndDate));
                
                if(((customerAQEffFromDateValue== null && customerAQEffToDateValue== null || customerAQEffFromDateValue!= null && customerAQEffToDateValue== null 
                && customerAQEffFromDateValue.daysBetween(servicePointEndDate) > 0)
                || (customerAQEffToDateValue!= null && customerAQEffFromDateValue == null && customerAQEffToDateValue.daysBetween(servicePointDate) <= 0)
                || (customerAQEffFromDateValue!= null && customerAQEffToDateValue!= null && customerAQEffFromDateValue.daysBetween(servicePointEndDate) >= 0 
                && customerAQEffToDateValue.daysBetween(servicePointDate) <= 0))
                && customerSOQ != null) {
                    List<String> args = new String[]{'0','number','#,###'};
                    customerSOQValue = String.format((decimal.valueof(customerSOQ)).format(), args);
                }
            }
            
            Map<String, Object> lineItemDetail = new Map<String, Object>();
            lineItemDetail.put('ServicePointNumber', servicePointNumber);
            lineItemDetail.put('ServicePointStartDate', servicePointStartDate);
            // Address fields
            lineItemDetail.put('SPHouseName', (servicePointHouseName == null) ? '' : servicePointHouseName);
            lineItemDetail.put('IF_SPHouseName', (servicePointHouseName == null) ? false : true);
            lineItemDetail.put('SPHouseNo', (servicePointHouseNumber == null) ? '' : servicePointHouseNumber);
            lineItemDetail.put('IF_SPHouseNum', (servicePointHouseNumber == null) ? false : true);
            lineItemDetail.put('SPCity', (servicePointCity == null) ? '' : servicePointCity);
            lineItemDetail.put('SPPostCode', (servicePointPostalCode == null) ? '' : servicePointPostalCode);
            lineItemDetail.put('SPState', (servicePointState == null) ? '' : servicePointState);
            lineItemDetail.put('SPStreet', (servicePointStreet == null) ? '' : servicePointStreet);
            // Consumption and SOQ
            lineItemDetail.put('EstimatedConsumption', servicePointVolume);
            lineItemDetail.put('FYSOQ', (customerSOQValue != null) ? customerSOQValue : servicePointFYSOQ);
            // Prices
            lineItemDetail.put('StandingCharge', (standingCharge == null) ? '0.000' : standingCharge);
            lineItemDetail.put('UnitRate', (unitRate == null) ? '0.000' : unitRate);
            // Add the line item
            lineItemDetails.add(lineItemDetail);
        }
        
        Map<String, Object> tokenData = new Map<String, Object>();
        tokenData.put('ServicePoints', lineItemDetails);
        
        return tokenData;
    }
    
    /**
     * Determine if there is more data to retrieve as pagination is utilised to retrieve the data
     */
    private Boolean updateHasMoreData(Map<String, Object> pageInfo) 
    {
        Integer totalItems = (Integer) pageInfo.get('totalItems');
        Integer recordNumber = (Integer) pageInfo.get('recordNumber');
        
        Boolean hasMoreData = totalItems > recordNumber ? true : false;
        
        //System.debug('updateHasMoreData:hasMoreData -> ' + hasMoreData);
        return hasMoreData;
    }
    
    /**
     * Determine the page offset.  This is a parameter used when retrieving the data from the sObject(s)
     */
    private void updatePageOffset(Map<String, Object> pageInfo) 
    {
        Integer pageOffset = (Integer) pageInfo.get('pageOffset');
        Integer recordNumber = (Integer) pageInfo.get('recordNumber');
        
        Integer nextPageOffset = recordNumber + pageOffset;
        
        //System.debug('updatePageOffset:nextPageOffset -> ' + nextPageOffset);
        pageInfo.put('recordNumber', nextPageOffset);
    } 
    
    /**
     * Initialise pagination information by storing items suchh as number of records, contract id, etc
     */
    @TestVisible private Map<String, Object> initializePaginationInfo(Id contractId, Id opportunityId, Id quoteId) 
    { 
        Integer totalItems = countContractItems(contractId);

        // Get the list of service points that have customer AQ (OLIs)
        List<Id> lstServicePointIds = getOppLineItemServicePointIds(opportunityId);

        // Get the QLIs
        Map<String, Object> quoteLineItems = getQuoteLineItems(quoteId, lstServicePointIds);
            
        Map<String, Object> paginationInformation = new Map<String, Object>();
        //paginationInformation.put('contractId', contractId);
        paginationInformation.put('queryHeader', true);
        paginationInformation.put('queryLine', true);
        paginationInformation.put('recordNumber', 0);
        paginationInformation.put('pageOffset', DEFAULT_PAGE_OFFSET);
        paginationInformation.put('totalItems', totalItems);
        paginationInformation.put('quoteLineItems', quoteLineItems);
        //paginationInformation.put('oppLineItemServicePoints', lstServicePointIds);
        
        //System.debug('initializePaginationInfo:paginationInformation -> ' + paginationInformation);
        return paginationInformation;
    }

    /**
     * Retrieve the the Quote Line Items of the service points that may have customer AQ
     */
    @TestVisible private Map<String, Object> getQuoteLineItems(Id quoteId, List<Id> lstServicePointIds) 
    {
        // Get the quote line items for this quote and the previously selected service points
        List<QuoteLineItem> quoteLineItems = new List<QuoteLineItem>();
  
        quoteLineItems = Database.query(QUERY_QUOTE_LINE_ITEMS);
        System.debug('getQuoteLineItems:quoteLineItems -> ' + quoteLineItems);

        Map<String, Object> quoteLineItemMap = new Map<String, Object> ();

        for (QuoteLineItem qli : quoteLineItems) {
            if (qli.get('vlocity_cmt__JSONAttribute__c') != null) {
                quoteLineItemMap.put(String.valueOf(qli.getSobject('Quote').get('vlocity_cmt__DefaultServicePointId__c')), qli.get('vlocity_cmt__JSONAttribute__c'));
            }            
        }

        System.debug('getQuoteLineItems:quoteLineItemMap -> ' + quoteLineItemMap);

        return quoteLineItemMap;
    }

    /**
     * Retrieve the the Ids of the service points that have Opportunity Line Items
     */
    @TestVisible private List<Id> getOppLineItemServicePointIds(Id opportunityId) 
    {
        List<OpportunityLineItem> oppLineItems = null;
        oppLineItems = Database.query(QUERY_OPPORTUNITY_LINE_ITEMS);

        List <Id> servicePointIds = new List <Id> ();

        for (OpportunityLineItem oppLineItem : oppLineItems)  {
            servicePointIds.add(oppLineItem.vlocity_cmt__ServicePointId__c);
        }
        
        System.debug('getOppLineItemServicePointIds:oppLineItems -> ' + oppLineItems);

        return servicePointIds;
    }

    
    /**
     * Retrieve the number of contract line items
     */
    @TestVisible private Integer countContractItems(Id contractId) 
    {
        Integer contractItems = Database.countQuery(COUNT_CONTRACT_LINES);
        
        //System.debug('countContractItems:contractItems -> ' + contractItems);
        return contractItems;
    }

    /**
     * Exception handling
     */
    class SWAN_GasContractDocumentTokenExtractorException extends Exception {
        
    }
}