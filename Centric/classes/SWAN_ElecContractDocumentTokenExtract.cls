global with sharing class SWAN_ElecContractDocumentTokenExtract implements vlocity_cmt.VlocityOpenInterface2 
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
    private static final String DR_FUEL_TYPE = 'Electricity';

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
    private static final String STD_CHRG = 'Standing Charge';

    /**
     * Unit Rate product code
     */
    private static final String UNIT_RATE = 'Unit Rate';
    
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
    private static final String QUERY_DRMAP_ITEM;
     
    /**
     * Initialize queries to be used to include namespace prefix
     */
    
    static

    {

        String queryCountContractLines = 
            'SELECT count() ' +
            'FROM vlocity_cmt__contractlineitem__c ' +
            'WHERE vlocity_cmt__ContractId__c = :contractId AND vlocity_cmt__OriginalLineItemId__c = null';
        
        COUNT_CONTRACT_LINES = queryCountContractLines;

        String queryContractLines =
            'SELECT Id, vlocity_cmt__ContractId__c, SWAN_Quote__c, (SELECT Id, SWAN_UsageUnitPrice__c, vlocity_cmt__AttributesData__c, ' + 'vlocity_cmt__ProductCode__c, vlocity_cmt__Product2Id__r.Name, vlocity_cmt__Product2Id__r.vlocity_cmt__SubType__c, ' + 'vlocity_cmt__Product2Id__r.vlocity_cmt__Type__c  ' +
            'FROM vlocity_cmt__Contract_Line_Items__r WHERE vlocity_cmt__OriginalLineItemId__c != null Order By vlocity_cmt__Product2Id__r.vlocity_cmt__SubType__c, vlocity_cmt__Product2Id__r.Name asc ), ' +
            'SWAN_Service_Point__c, FORMAT(SWAN_Service_Point_Start_Date__c), FORMAT(SWAN_Quote__r.Annual_Volume__c), FORMAT(SWAN_Service_Point_End_Date__c), ' +
            'SWAN_Service_Point__r.SWAN_Standard_Settlement_Config_Ovrd__c, SWAN_Service_Point__r.SWAN_Standard_Settlement_Configuration__c, ' +
            'FORMAT(SWAN_Service_Point__r.SWAN_Supply_Capacity__c), FORMAT(SWAN_Quote__r.SWAN_Annual_Spend__c), SWAN_Service_Point__r.SWAN_Service_Point_Reference__c, ' +
            'SWAN_Service_Point__r.SWAN_Measurement_Class__c, SWAN_Service_Point__r.SWAN_Measurement_Class_Ovrd__c, ' +
            'SWAN_Service_Point__r.vlocity_cmt__ServicePointNumber__c, SWAN_Service_Point__r.vlocity_cmt__PremisesId__r.SWAN_House_Name__c,' +
            'SWAN_Service_Point__r.vlocity_cmt__PremisesId__r.SWAN_House_Number__c, SWAN_Service_Point__r.vlocity_cmt__PremisesId__r.vlocity_cmt__City__c,' + 
            'SWAN_Service_Point__r.vlocity_cmt__PremisesId__r.vlocity_cmt__PostalCode__c, SWAN_Service_Point__r.vlocity_cmt__PremisesId__r.vlocity_cmt__State__c,' +
            'SWAN_Service_Point__r.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c ' +
            'FROM vlocity_cmt__contractlineitem__c ';

        QUERY_INITIAL_CONTRACT_LINES = queryContractLines +
            'WHERE vlocity_cmt__ContractId__c = :contractId AND vlocity_cmt__OriginalLineItemId__c = null ' +
            'ORDER BY Id, SWAN_Service_Point__c ' + 'LIMIT :pageOffset';            

        QUERY_SUCCEEDING_CONTRACT_LINES = queryContractLines + 
            'WHERE vlocity_cmt__ContractId__c = :contractId AND vlocity_cmt__OriginalLineItemId__c = null AND Id >: lastItemId ' + 'ORDER BY Id, SWAN_Service_Point__c ' + 'LIMIT :pageOffset';
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
            throw new SWAN_ElecContractDocumentTokenExtractorException(ERROR_UNSUPPORTED);
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
        
        System.debug('getContractTokenData:resultMap ->' + resultMap);
        
        if (!drProcessResult.hasErrors())
        {
            Map<String, Object> paginationInformation = initializePaginationInfo(contractId);
            Integer totalItems = (Integer) paginationInformation.get('totalItems');  
            output.put('hasMoreTokenData', totalItems > 0);
            output.put('tokenMap', (Map<String,Object>)resultMap.get('returnResultsData'));
            output.put('tokenDataQueryInfo', paginationInformation);

            success = true;
        }
        else 
        {
            throw new SWAN_ElecContractDocumentTokenExtractorException(ERROR_DR_MESSAGE);
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
            
            String servicePointNumber = String.valueOf(lineItem.getSobject('SWAN_Service_Point__r').get('vlocity_cmt__ServicePointNumber__c'));
            String siteReference = String.valueOf(lineItem.getSobject('SWAN_Service_Point__r').get('SWAN_Service_Point_Reference__c'));
            String servicePointHouseName = String.valueOf(lineItem.getSobject('SWAN_Service_Point__r').getSobject('vlocity_cmt__PremisesId__r').get('SWAN_House_Name__c'));
            String servicePointHouseNumber = String.valueOf(lineItem.getSobject('SWAN_Service_Point__r').getSobject('vlocity_cmt__PremisesId__r').get('SWAN_House_Number__c'));
            String servicePointCity = String.valueOf(lineItem.getSobject('SWAN_Service_Point__r').getSobject('vlocity_cmt__PremisesId__r').get('vlocity_cmt__City__c'));
            String servicePointPostalCode = String.valueOf(lineItem.getSobject('SWAN_Service_Point__r').getSobject('vlocity_cmt__PremisesId__r').get('vlocity_cmt__PostalCode__c'));
            String servicePointState = String.valueOf(lineItem.getSobject('SWAN_Service_Point__r').getSobject('vlocity_cmt__PremisesId__r').get('vlocity_cmt__State__c'));
            String servicePointStreet = String.valueOf(lineItem.getSobject('SWAN_Service_Point__r').getSobject('vlocity_cmt__PremisesId__r').get('vlocity_cmt__StreetAddress__c'));
            String servicePointVolume = String.valueOf(lineItem.getSobject('SWAN_Quote__r').get('Annual_Volume__c'));            
            String supplyCapacity = String.valueOf(lineItem.getSobject('SWAN_Service_Point__r').get('SWAN_Supply_Capacity__c'));
            String annualSpend = String.valueOf(lineItem.getSobject('SWAN_Quote__r').get('SWAN_Annual_Spend__c'));
            String servicePointDt = String.valueOf(lineItem.get('SWAN_Service_Point_Start_Date__c'));
            String servicePointStartDate = '';
            Date servicePointDate;
            If (servicePointDt != null) {
                servicePointDate = Date.parse(servicePointDt);
                servicePointStartDate = DateTime.newInstance(servicePointDate.year(),servicePointDate.month(),servicePointDate.day()).format('dd MMM YYYY');
            }
            // Retrieve the prices and place them into a map
            List<Map<string,String>> priceMap = new List<Map<string,String>>();
            String rateStructure = null;
            Integer numberOfCLIs = 0;
            String measurementClass;
            for(vlocity_cmt__contractlineitem__c childCLI : lineItem.vlocity_cmt__Contract_Line_Items__r)
            {   
                if (childCLI.vlocity_cmt__Product2Id__r.vlocity_cmt__Type__c != DR_FUEL_TYPE) {
                    Map<string,String> price = new Map<string,String>();
                    price.put('Name', childCLI.vlocity_cmt__Product2Id__r.Name);
                    
                    if(childCLI.vlocity_cmt__Product2Id__r.vlocity_cmt__SubType__c == 'Unit Rate') {
                        price.put('Price', SWAN_GetOfferPackRelatedData.doFormatting(((childCLI.SWAN_UsageUnitPrice__c != null) ? childCLI.SWAN_UsageUnitPrice__c : 0),3,',','.') + ' p/kWh' );
                    } else if(childCLI.vlocity_cmt__Product2Id__r.vlocity_cmt__SubType__c == 'Standing Charge') {
                        price.put('Price', SWAN_GetOfferPackRelatedData.doFormatting(((childCLI.SWAN_UsageUnitPrice__c != null) ? childCLI.SWAN_UsageUnitPrice__c : 0),3,',','.') + ' p/day' );
                    } else {
                        price.put('Price', SWAN_GetOfferPackRelatedData.doFormatting(((childCLI.SWAN_UsageUnitPrice__c != null) ? childCLI.SWAN_UsageUnitPrice__c : 0),3,',','.') + ' p/kVA/day' );
                    }
                    priceMap.add(price);
                    numberOfCLIs++;
                    
                } else {
                    String value = String.valueOf(lineItem.getSobject('SWAN_Service_Point__r').get('SWAN_Measurement_Class__c'));
                    String valueOvrd = String.valueOf(lineItem.getSobject('SWAN_Service_Point__r').get('SWAN_Measurement_Class_Ovrd__c'));
                    
                    measurementClass = (valueOvrd != null) ? valueOvrd : value;
                    
                    System.debug('measurementClass -> ' + measurementClass);
                    System.debug('CLI:Id -> ' + childCLI.Id);
                    
                    if (measurementClass == 'A' || measurementClass == 'B') {
                        value = String.valueOf(lineItem.getSobject('SWAN_Service_Point__r').get('SWAN_Standard_Settlement_Configuration__c'));
                        valueOvrd = String.valueOf(lineItem.getSobject('SWAN_Service_Point__r').get('SWAN_Standard_Settlement_Config_Ovrd__c'));
                        
                        rateStructure = 'NHH (' + ((valueOvrd != null) ? valueOvrd : value) + ')';
                    } else {
                        System.debug('In the For Loop!!');
                        for(object Attr : (List<object>) ((Map<String, Object>)JSON.deserializeUntyped(String.valueof(childCLI.vlocity_cmt__AttributesData__c))).get('SWAN_QUOTE_CONFIG_ATT_CAT')) {
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
            /*{{#IF_SPHouseName}}{{SPHouseName}}, {{/IF_SPHouseName}}{{#IF_SPHouseNum}}{{SPHouseNo}}, {{/IF_SPHouseNum}}{{SPStreet}}, {{SPCity}}, {{SPState}}, {{SPPostCode}}*/
            String addressToken = ((servicePointHouseName == null) ? '' : servicePointHouseName + ', ') +
                                   ((servicePointHouseNumber == null) ? '' : servicePointHouseNumber + ', ') +
                                   ((servicePointStreet == null) ? '' : servicePointStreet + ', ') +
                                   ((servicePointCity == null) ? '' : servicePointCity + ', ') +
                                   ((servicePointState == null) ? '' : servicePointState + ', ') +
                                   ((servicePointPostalCode == null) ? '' : servicePointPostalCode);
            
            Map<String, Object> lineItemDetail = new Map<String, Object>();
            // Service point start date, number and rate structure
            lineItemDetail.put('ServicePointNumber', servicePointNumber);
            lineItemDetail.put('SiteRef', (siteReference != null) ? siteReference : servicePointPostalCode);
            lineItemDetail.put('ServicePointStartDate', servicePointStartDate);
            lineItemDetail.put('RateStructure', rateStructure);
            // Address fields
            lineItemDetail.put('ServicePointAddress', (addressToken == null) ? '' : addressToken);
            // Set the conditional token that will be used to display the table in the site annexe for the service point
            lineItemDetail.put('IF_ONE_RATE', (numberOfCLIs == 1) ? true : false);
            lineItemDetail.put('IF_TWO_RATES', (numberOfCLIs == 2) ? true : false);
            lineItemDetail.put('IF_THREE_RATES', (numberOfCLIs == 3) ? true : false);
            lineItemDetail.put('IF_FOUR_RATES', (numberOfCLIs == 4) ? true : false);
            lineItemDetail.put('IF_FIVE_RATES', (numberOfCLIs == 5) ? true : false);
            lineItemDetail.put('IF_SIX_RATES', (numberOfCLIs == 6) ? true : false);
            lineItemDetail.put('IF_SEVEN_RATES', (numberOfCLIs == 7) ? true : false);
            lineItemDetail.put('IF_EIGHT_RATES', (numberOfCLIs == 8) ? true : false);
            lineItemDetail.put('IF_NINE_RATES', (numberOfCLIs == 9) ? true : false);
            lineItemDetail.put('IF_TEN_RATES', (numberOfCLIs == 10) ? true : false);
            lineItemDetail.put('IF_ELEVEN_RATES', (numberOfCLIs == 11) ? true : false);
            lineItemDetail.put('IF_TWELVE_RATES', (numberOfCLIs == 12) ? true : false);
            // Consumption, supply capacity and annual spend
            lineItemDetail.put('EAC', servicePointVolume + ' kWh');
            lineItemDetail.put('EstAnnualSpend', annualSpend);
            lineItemDetail.put('KVA', (supplyCapacity != null && (measurementClass == 'C' || measurementClass == 'E') ? supplyCapacity : 'N/A'));
            // Prices
            lineItemDetail.put('Prices', priceMap);
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
    @TestVisible private Map<String, Object> initializePaginationInfo(Id contractId) 
    { 
        Integer totalItems = countContractItems(contractId);
            
        Map<String, Object> paginationInformation = new Map<String, Object>();
        //paginationInformation.put('contractId', contractId);
        paginationInformation.put('queryHeader', true);
        paginationInformation.put('queryLine', true);
        paginationInformation.put('recordNumber', 0);
        paginationInformation.put('pageOffset', DEFAULT_PAGE_OFFSET);
        paginationInformation.put('totalItems', totalItems);
        
        //System.debug('initializePaginationInfo:paginationInformation -> ' + paginationInformation);
        return paginationInformation;
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
    class SWAN_ElecContractDocumentTokenExtractorException extends Exception {
        
    }
}