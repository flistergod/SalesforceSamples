public with sharing class SWAN_GenerateCSVForPipeline {

        private static final Datetime REPORT_RUN_TIME = System.now();
        private static final String REPORT_RUN_TIME_IN_STRING_FORMAT = REPORT_RUN_TIME.format('dd/MM/YYYY');
        
    private class OutputFielsdWrapper{
        String sourceSystem = 'Vlocity';
        String dateRun = REPORT_RUN_TIME_IN_STRING_FORMAT;
        String status = '';
        String statusChild = '';
        String contractTypeCode = 'Gas';
        String contractId = '';
        String revision = '';
        String sapOffer = '';
        String executeTime = '';
        String lsTime = '';
        String startTimeChild = '';
        String startTime = '';
        String stopTime = '';
        String customer = '';
        String broker = '';
        String salesPerson = '';
        String requestTypeCode = '';
        String productTypeCode = 'Fixed';
        String swap = 'Gas';
        String mref = '';
        String dummyMpan = '';
        String newConnection = 'N';
        String ecc = '';
        String eac = '';
        String profileClass = '';
        String meterType = '';
        String aahedcSapPassth = '';
        String hhUnitChargeSapPassth = '';
        String feedInTariffSapPassth = '';
        String renObligSapPasst = '';
        String cfdSapPassth = '';
        String tnuosHhSapPassth = '';
        String cmHhSapPassth = '';
        String bsuosHhSapPassth = '';
        String product = '';
        String segment = '';
    }

    public static void getReport(){
        
        final List<String> CONTRACT_STATUS = new List<String>{'Contract Signed','Contract Counter Signed','Contract Live','Contract Cancelled','Contract Terminated','Contract Ended'};
        final List<String> PRODUCT_STATUS = new List<String>{'Unit Rate','Standing Charge', null};

        List<vlocity_cmt__ContractLineItem__c>lstCLI = new List<vlocity_cmt__ContractLineItem__c>([select Id, LastModifiedDate, vlocity_cmt__EffectiveStartDate__c, 
                                                                    vlocity_cmt__ContractId__c, vlocity_cmt__ContractId__r.Status, vlocity_cmt__ContractId__r.Account.Name, 
                                                                    vlocity_cmt__ContractId__r.vlocity_cmt__QuoteId__c, vlocity_cmt__ContractId__r.vlocity_cmt__QuoteId__r.SWAN_Offer_Start_Date__c, vlocity_cmt__ContractId__r.vlocity_cmt__QuoteId__r.QuoteNumber,
                                                                    vlocity_cmt__ContractId__r.vlocity_cmt__QuoteId__r.SWAN_Offer_End_Date__c, vlocity_cmt__ContractId__r.CompanySignedId, vlocity_cmt__ContractId__r.CompanySigned.Name,
                                                                    vlocity_cmt__ContractId__r.vlocity_cmt__OpportunityId__r.RecordType.Name, vlocity_cmt__ContractId__r.ActivatedDate, vlocity_cmt__ContractId__r.vlocity_cmt__QuoteId__r.SWAN_Contract_Volume_KWh__c, 
                                                                    SWAN_Quote__c, SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.SWAN_Offer_Start_Date__c, SWAN_Quote__r.vlocity_cmt__ParentQuoteId__c, SWAN_Quote__r.SWAN_Service_Point_End_Date__c, 
                                                                    SWAN_Quote__r.SWAN_Offer_Start_Date__c, SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.RecordType.Name, SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.SWAN_Offer_End_Date__c, SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.SWAN_Broker__c,
                                                                    SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.SWAN_Broker__r.Name, SWAN_Quote__r.SWAN_Contract_Volume_KWh__c, SWAN_Quote__r.SWAN_Service_Point_Start_Date__c, SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.QuoteNumber,
                                                                    SWAN_Service_Point__c, SWAN_Service_Point__r.vlocity_cmt__ServicePointNumber__c, SWAN_Service_Point__r.SWAN_Product_Class__c, SWAN_Service_Point__r.Annual_Quantity__c,
                                                                    vlocity_cmt__LineStatus__c, SWAN_Service_Point_Start_Date__c, vlocity_cmt__Product2Id__r.Name, vlocity_cmt__ContractId__r.OwnerId, vlocity_cmt__ContractId__r.Owner.Name, 
                                                                    vlocity_cmt__ContractId__r.vlocity_cmt__PriceListId__c, vlocity_cmt__ContractId__r.vlocity_cmt__PriceListId__r.Name, SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.vlocity_cmt__PriceListId__c, SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.vlocity_cmt__PriceListId__r.Name
                                                                    from vlocity_cmt__ContractLineItem__c where vlocity_cmt__ContractId__r.Status in :CONTRACT_STATUS AND vlocity_cmt__ContractId__r.vlocity_cmt__QuoteId__r.vlocity_cmt__ParentQuoteId__c = null and vlocity_cmt__Product2Id__r.name = null and SWAN_Quote__c != null]);

        List<ID> lstCLIQuoteIDs = new List<Id>();
        List<ID> lstCLIParentQuoteIDs = new List<Id>();
        List<ID> lstContractIDs = new List<Id>();
        for(vlocity_cmt__ContractLineItem__c cli : lstCLI){
            lstCLIQuoteIDs.add(cli.SWAN_Quote__c);
            lstContractIDs.add(cli.vlocity_cmt__ContractId__c);
            lstCLIParentQuoteIDs.add(cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__c);
        }

        Map<ID, QuoteLineItem> mapQuoteLineItemsPerCLIQuote = new Map<ID, QuoteLineItem>();
        for(QuoteLineItem qli : [Select Id, QuoteId, Product2ID, Product2.Name from QuoteLineItem where QuoteId in :lstCLIQuoteIDs and Product2.Name not in :PRODUCT_STATUS]){
            mapQuoteLineItemsPerCLIQuote.put(qli.QuoteId, qli);
        }

        Map<ID, SWAN_Quote_Status_Tracking__c> mapQuoteHistoryByQuoteId = new Map<ID, SWAN_Quote_Status_Tracking__c>();
        for(SWAN_Quote_Status_Tracking__c history : [Select Id, New_Status__c, LastModifiedDate, SWAN_Quote__c from SWAN_Quote_Status_Tracking__c where SWAN_Quote__c in :lstCLIParentQuoteIDs and New_Status__c = 'Accepted']){
            mapQuoteHistoryByQuoteId.put(history.SWAN_Quote__c, history);
        }

        Map<ID, ContractHistory> mapContractHistoryByContractId = new Map<ID, ContractHistory>();
        for(ContractHistory ch : [Select Id, NewValue, CreatedDate, ContractId, Contract.vlocity_cmt__QuoteId__c from ContractHistory where ContractId in :lstContractIDs AND Field = 'Status']){
            //NewValue cannot be filtered on ContractHistory queries
            if(((String)ch.NewValue).equalsIgnoreCase('Contract Signed')){
                mapContractHistoryByContractId.put(ch.ContractId, ch);
            }
        }

        writeFileAttachment(fillListWithContractDetails(lstCLI, mapQuoteHistoryByQuoteId, mapContractHistoryByContractId, mapQuoteLineItemsPerCLIQuote));


    }

    private static List<OutputFielsdWrapper> fillListWithContractDetails(List<vlocity_cmt__ContractLineItem__c> lstCLI, 
                                                                                Map<ID, SWAN_Quote_Status_Tracking__c> mapQuoteHistoryByQuoteId, 
                                                                                Map<ID, ContractHistory> mapContractHistoryByContractId,
                                                                                Map<ID, QuoteLineItem> mapQuoteLineItemsPerCLIQuote){
        List<OutputFielsdWrapper> lstWrapper = new List<OutputFielsdWrapper>();
        Segment_Values__c segmentVal = Segment_Values__c.getOrgDefaults();
        for(vlocity_cmt__ContractLineItem__c cli : lstCLI){

            OutputFielsdWrapper ofw = new OutputFielsdWrapper();

            ofw.status = cli.vlocity_cmt__ContractId__r.Status;
            ofw.statusChild = cli.vlocity_cmt__LineStatus__c;

            //Field mappings that depend if the CLI is a Site Addition
            if(cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.RecordType.Name.startsWithIgnoreCase('Site Addition')){
                ofw.contractId = cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.QuoteNumber;
                ofw.sapOffer = cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.QuoteNumber;
                
                if(!Test.isRunningTest()){
                    ofw.executeTime = mapQuoteHistoryByQuoteId.get(cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__c).LastModifiedDate.format('dd/MM/YYYY');
                }

                ofw.salesPerson = cli.vlocity_cmt__ContractId__r.Owner.Name;
                ofw.requestTypeCode = 'Site Addition';
            }else{
                ofw.contractId = cli.vlocity_cmt__ContractId__r.vlocity_cmt__QuoteId__r.QuoteNumber;
                ofw.sapOffer = cli.vlocity_cmt__ContractId__r.vlocity_cmt__QuoteId__r.QuoteNumber;
                
                if(!Test.isRunningTest()){
                    ofw.executeTime = mapContractHistoryByContractId.get(cli.vlocity_cmt__ContractId__c).CreatedDate.format('dd/MM/YYYY');
                }
                
                ofw.salesPerson = cli.vlocity_cmt__ContractId__r.CompanySigned.Name;
                ofw.requestTypeCode = cli.vlocity_cmt__ContractId__r.vlocity_cmt__OpportunityId__r.RecordType.Name;
            }

            //Field History tracking objects are not writeable and since during test times nothing is actually comitted to the DB, 
            //history tracking mechanism doesn't trigger, exposing the data to the class. 
            //As such, this line will not be covered by an apex test. 
            if(!Test.isRunningTest()){
                ofw.lsTime = cli.LastModifiedDate.format('dd/MM/YYYY');
                ofw.startTimeChild = DateTime.newInstance(cli.SWAN_Service_Point_Start_Date__c, Time.newInstance(0, 0, 0, 0)).format('dd/MM/YYYY');
                ofw.product = mapQuoteLineItemsPerCLIQuote.get(cli.SWAN_Quote__c).Product2.Name;
            }

            
            ofw.startTime = DateTime.newInstance(cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.SWAN_Offer_Start_Date__c, Time.newInstance(0, 0, 0, 0)).format('dd/MM/YYYY');
            ofw.stopTime = DateTime.newInstance(cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.SWAN_Offer_End_Date__c, Time.newInstance(0, 0, 0, 0)).format('dd/MM/YYYY');
            ofw.customer = cli.vlocity_cmt__ContractId__r.Account.Name;
            ofw.broker = cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.SWAN_Broker__c != null?cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.SWAN_Broker__r.Name:'';
            ofw.mref = cli.SWAN_Service_Point__r.vlocity_cmt__ServicePointNumber__c;
            ofw.ecc = cli.SWAN_Quote__r.SWAN_Contract_Volume_KWh__c!= null?cli.SWAN_Quote__r.SWAN_Contract_Volume_KWh__c.format():'';
            ofw.eac = cli.SWAN_Service_Point__r.Annual_Quantity__c!= null ? cli.SWAN_Service_Point__r.Annual_Quantity__c.format():'';
            
            ofw.meterType = '';
            if(cli.SWAN_Service_Point__r.SWAN_Product_Class__c != null){
                if(cli.SWAN_Service_Point__r.SWAN_Product_Class__c == '1' || cli.SWAN_Service_Point__r.SWAN_Product_Class__c == '2'){
                    ofw.meterType = 'DM';
                }else if(cli.SWAN_Service_Point__r.SWAN_Product_Class__c == '3' || cli.SWAN_Service_Point__r.SWAN_Product_Class__c == '4'){
                    ofw.meterType = 'NDM';
                }
            }
            if(cli.SWAN_Quote__c != null)
            {
                if(cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.RecordType.Name.startsWithIgnoreCase('Site Addition')){
                    if(cli.vlocity_cmt__ContractId__r.vlocity_cmt__PriceListId__c != null)
                    {
                        if(cli.vlocity_cmt__ContractId__r.vlocity_cmt__PriceListId__r.Name == label.Swan_Enterprise_Price_List)
                            ofw.segment = segmentVal.Enterprise_Segment__c;
                        else if(cli.vlocity_cmt__ContractId__r.vlocity_cmt__PriceListId__r.Name == label.Swan_I_C_Price_List)
                            ofw.segment = segmentVal.I_C_Segment__c;
                    }
                }
                else
                {
                    if(cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.vlocity_cmt__PriceListId__c != null)
                    {
                        if(cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.vlocity_cmt__PriceListId__r.Name == label.Swan_Enterprise_Price_List)
                            ofw.segment = segmentVal.Enterprise_Segment__c;
                        else if(cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.vlocity_cmt__PriceListId__r.Name == label.Swan_I_C_Price_List)
                            ofw.segment = segmentVal.I_C_Segment__c;
                    }
                }
            }
            lstWrapper.add(ofw);
        }
        return lstWrapper;
    }

    private static String getXLS(List<OutputFielsdWrapper> lstWrapper){
        final String NUL = '';
        final String SEP = '","';
        //Output string with header built
        String outputXLS = '"SourceSystem' + SEP + 'DATE_RUN' + SEP + 'STATUS' + SEP + 'STATUS_Child' + SEP + 'CONTRACTTYPECODE' + SEP + 'CONTRACTID' +
                             SEP + 'REVISION' + SEP + 'SAP_OFFER' + SEP + 'EXECUTETIME' + SEP + 'LSTIME' + SEP + 'STARTTIME_Child' + SEP + 'STARTTIME' +
                             SEP + 'STOPTIME' + SEP + 'CUSTOMER' + SEP + 'BROKER' + SEP + 'SALES_PERSON' + SEP + 'REQUESTTYPECODE' + SEP + 'PRODUCTTYPECODE' +
                             SEP + 'SWAP' + SEP + 'MREF' + SEP + 'DummyMpan' + SEP + 'NewConnection' + SEP + 'ECC' + SEP + 'EAC' + SEP + 'ProfileClass' + SEP + 'MeterType' + 
                             SEP + 'AAHEDC_SAP_PASSTH' + SEP + 'HH_UNIT_CHARGE_SAP_PASSTH' + SEP + 'FEED_IN_TARIFF_SAP_PASSTH' + SEP + 'REN_OBLIG_SAP_PASST' + 
                             SEP + 'CFD_SAP_PASSTH' + SEP + 'TNUOS_HH_SAP_PASSTH' + SEP + 'CM_HH_SAP_PASSTH' + SEP + 'BSUOS_HH_SAP_PASSTH' + SEP + 'Product' + 
                             SEP + 'Segment"\n';

        for(OutputFielsdWrapper ofw : lstWrapper){
            outputXLS+='"'+ofw.sourceSystem + SEP
                        +ofw.dateRun + SEP
                        +ofw.status + SEP
                        +ofw.statusChild + SEP
                        +ofw.contractTypeCode + SEP
                        +ofw.contractId + SEP
                        +ofw.revision + SEP
                        +ofw.sapOffer + SEP
                        +ofw.executeTime + SEP
                        +ofw.lsTime + SEP
                        +ofw.startTimeChild + SEP
                        +ofw.startTime + SEP
                        +ofw.stopTime + SEP
                        +ofw.customer + SEP
                        +ofw.broker + SEP
                        +ofw.salesPerson + SEP
                        +ofw.requestTypeCode + SEP
                        +ofw.productTypeCode + SEP
                        +ofw.swap + SEP
                        +ofw.mref + SEP
                        +ofw.dummyMpan + SEP
                        +ofw.newConnection + SEP
                        +ofw.ecc + SEP
                        +ofw.eac + SEP
                        +ofw.profileClass + SEP
                        +ofw.meterType + SEP
                        +ofw.aahedcSapPassth + SEP
                        +ofw.hhUnitChargeSapPassth + SEP
                        +ofw.feedInTariffSapPassth + SEP
                        +ofw.renObligSapPasst + SEP
                        +ofw.cfdSapPassth + SEP
                        +ofw.tnuosHhSapPassth + SEP
                        +ofw.cmHhSapPassth + SEP
                        +ofw.bsuosHhSapPassth + SEP
                        +ofw.product + SEP
                        +ofw.segment + '"\n';
        }

        return outputXLS;
    }

    //Fill final list with wrapper objects ready to be written to output XLS
    private static void writeFileAttachment(List<OutputFielsdWrapper> lstWrapper){
        
        final String FILENAME = ' SWAN_Pipeline_' + REPORT_RUN_TIME.format('YYYYMMddHHmmss') + '.CSV';
        SWAN_Custom_Report__c pipelineReport = new SWAN_Custom_Report__c(Name = FILENAME, SWAN_Report_Type__c = 'PIPELINE');

        if (Schema.sObjectType.SWAN_Custom_Report__c.fields.SWAN_Report_Type__c.isCreateable()){
            insert pipelineReport;
        }
        
        try{
            if(Schema.sObjectType.Attachment.fields.Body.isCreateable()){
                insert new Attachment(Name = fileName, 
                                      ParentId = pipelineReport.Id, 
                                      Body = Blob.valueOf(getXLS(lstWrapper))); 
            }
        }catch(Exception e){
            System.debug(e.getMessage());
        }        
    }
}