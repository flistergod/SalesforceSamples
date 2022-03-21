public without sharing class SWAN_BatchGenerateCSVForPipeline implements Database.Batchable<sObject>, Database.Stateful{
    
    private static final List<String> CONTRACT_STATUS = new List<String>{'Contract Signed','Contract Counter Signed','Contract Live','Contract Cancelled','Contract Terminated','Contract Ended'};
    private static final List<String> PRODUCT_STATUS = new List<String>{'Unit Rate','Standing Charge', null};
    private static final Integer MAX_FILE_SIZE = 1200000; //Likely will need to change value to something lower due to heap size limit - 12MB (batchable is Async)
    private static final String REPORT_TYPE = 'PIPELINE'; 
    private static final Datetime REPORT_RUN_TIME = System.now();
    private static final String REPORT_RUN_TIME_IN_STRING_FORMAT = REPORT_RUN_TIME.format('dd/MM/YYYY');
    private String fileName;
    private Integer numberOfFiles = 0;
        
    
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
        String productTypeCode = '';
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
        String meterenddate = '';
        String contractnumber = '';
        String duosHhPassth = '';
        String gsp = '';
        String dno = '';
        String mtc = '';
        String llfc = '';
        String measurementClass = '';
        String AAHEDCRefPrice = '';
        String BSUoSRefPrice = '';
    }
    
    public SWAN_BatchGenerateCSVForPipeline() {
        fileName = 'SWAN_Pipeline_' + REPORT_RUN_TIME.format('YYYYMMddHHmmss');
        numberOfFiles = 0;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id, LastModifiedDate, 
                                        vlocity_cmt__EffectiveStartDate__c,
                                        vlocity_cmt__ContractId__c, vlocity_cmt__ContractId__r.Status, 
                                        vlocity_cmt__ContractId__r.Account.Name, 
                                        vlocity_cmt__ContractId__r.vlocity_cmt__QuoteId__c, 
                                        vlocity_cmt__ContractId__r.vlocity_cmt__QuoteId__r.SWAN_Offer_Start_Date__c, 
                                        vlocity_cmt__ContractId__r.vlocity_cmt__QuoteId__r.QuoteNumber,
                                        vlocity_cmt__ContractId__r.vlocity_cmt__QuoteId__r.SWAN_Offer_End_Date__c,
                                        vlocity_cmt__ContractId__r.vlocity_cmt__QuoteId__r.SWAN_Quote_Type__c,
                                        vlocity_cmt__ContractId__r.CompanySignedId, 
                                        vlocity_cmt__ContractId__r.CompanySigned.Name,
                                        vlocity_cmt__ContractId__r.vlocity_cmt__OpportunityId__r.RecordType.Name, 
                                        vlocity_cmt__ContractId__r.ActivatedDate, 
                                        vlocity_cmt__ContractId__r.vlocity_cmt__QuoteId__r.SWAN_Contract_Volume_KWh__c, 
                                        vlocity_cmt__ContractId__r.vlocity_cmt__OpportunityId__r.SWAN_Fuel_Type__c,
                                        vlocity_cmt__ContractId__r.ContractNumber,
                                        vlocity_cmt__LineStatus__c, 
                                        vlocity_cmt__EffectiveEndDate__c,
                                        SWAN_UsageUnitPrice__c,
                                        SWAN_Quote__c, 
                                        SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.SWAN_Offer_Start_Date__c, 
                                        SWAN_Quote__r.vlocity_cmt__ParentQuoteId__c, 
                                        SWAN_Quote__r.SWAN_Service_Point_End_Date__c, 
                                        SWAN_Quote__r.SWAN_Offer_Start_Date__c, 
                                        SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.RecordType.Name, 
                                        SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.SWAN_Offer_End_Date__c, 
                                        SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.SWAN_Broker__c,
                                        SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.SWAN_Broker__r.Name, 
                                        SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.SWAN_Passthrough_Option__c,
                                        SWAN_Quote__r.SWAN_Contract_Volume_KWh__c, 
                                        SWAN_Quote__r.SWAN_Service_Point_Start_Date__c, 
                                        SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.QuoteNumber,
                                        SWAN_Service_Point__c,vlocity_cmt__ContractId__r.SWAN_Signed_Date__c,
                                        SWAN_Service_Point__r.vlocity_cmt__ServicePointNumber__c, 
                                        SWAN_Service_Point__r.SWAN_Product_Class__c, 
                                        SWAN_Service_Point__r.Annual_Quantity__c,
                                        SWAN_Service_Point__r.SWAN_Measurement_Class__c,
                                        SWAN_Service_Point__r.SWAN_Measurement_Class_Ovrd__c, 
                                        SWAN_Service_Point__r.SWAN_Profile_Class__c,
                                        SWAN_Service_Point__r.SWAN_Grid_Supply_Point__c,
                                        SWAN_Service_Point__r.SWAN_Grid_Supply_Point_Group_Id_Ovrd__c,
                                        SWAN_Service_Point__r.SWAN_Distributor_Id__c,
                                        SWAN_Service_Point__r.SWAN_Distributor_ID_Ovrd__c,
                                        SWAN_Service_Point__r.SWAN_Meter_Time_Switch_Code__c,
                                        SWAN_Service_Point__r.SWAN_Meter_Time_switch_Class_Ovrd__c,
                                        SWAN_Service_Point__r.SWAN_Line_Loss_Factor_Class__c,
                                        SWAN_Service_Point__r.SWAN_Line_Loss_Factor_Class_Ovrd__c,
                                        SWAN_Service_Point_Start_Date__c, 
                                        vlocity_cmt__Product2Id__r.Name, 
                                        vlocity_cmt__Product2Id__r.ProductCode, 
                                        vlocity_cmt__ContractId__r.OwnerId, 
                                        vlocity_cmt__ContractId__r.Owner.Name, 
                                        vlocity_cmt__ContractId__r.vlocity_cmt__PriceListId__c, 
                                        vlocity_cmt__ContractId__r.vlocity_cmt__PriceListId__r.Name, 
                                        SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.vlocity_cmt__PriceListId__c, 
                                        SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.vlocity_cmt__PriceListId__r.Name,

                                        SWAN_Quote__r.Annual_Volume__c,
                                        (SELECT vlocity_cmt__Product2Id__r.Name, vlocity_cmt__Product2Id__r.ProductCode, SWAN_UsageUnitPrice__c FROM vlocity_cmt__Contract_Line_Items__r )

                                        FROM vlocity_cmt__ContractLineItem__c 
                                        WHERE vlocity_cmt__ContractId__r.Status in :CONTRACT_STATUS
                                        AND vlocity_cmt__ContractId__r.vlocity_cmt__QuoteId__r.vlocity_cmt__ParentQuoteId__c = null 
                                        AND SWAN_Service_Point__r.vlocity_cmt__ServicePointNumber__c != null
                                        AND SWAN_Quote__c != null
                                        AND SWAN_Quote__r.vlocity_cmt__ParentQuoteId__c != null]);
    }

    public void execute(Database.BatchableContext BC, List<vlocity_cmt__ContractLineItem__c> lstCLI){
        List<ID> lstCLIQuoteIDs = new List<Id>();
        List<ID> lstCLIParentQuoteIDs = new List<Id>();
        List<ID> lstContractIDs = new List<Id>();
        Map<ID, DateTime> mapContractHistoryByContractId = new Map<ID, DateTime>();

        for(vlocity_cmt__ContractLineItem__c cli : lstCLI){
            lstCLIQuoteIDs.add(cli.SWAN_Quote__c);
            lstContractIDs.add(cli.vlocity_cmt__ContractId__c);
            lstCLIParentQuoteIDs.add(cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__c);

            mapContractHistoryByContractId.put(cli.vlocity_cmt__ContractId__c,cli.vlocity_cmt__ContractId__r.SWAN_Signed_Date__c);

        }

        Map<ID, QuoteLineItem> mapQuoteLineItemsPerCLIQuote = new Map<ID, QuoteLineItem>();
        
        for(QuoteLineItem qli : [Select Id, QuoteId, Product2ID, Product2.Name from QuoteLineItem where QuoteId in :lstCLIQuoteIDs and Product2.Name not in :PRODUCT_STATUS and Product2.vlocity_cmt__IsOrderable__c=true]){
            mapQuoteLineItemsPerCLIQuote.put(qli.QuoteId, qli);
        }

        Map<ID, SWAN_Quote_Status_Tracking__c> mapQuoteHistoryByQuoteId = new Map<ID, SWAN_Quote_Status_Tracking__c>();
        for(SWAN_Quote_Status_Tracking__c history : [Select Id, New_Status__c, LastModifiedDate, SWAN_Quote__c from SWAN_Quote_Status_Tracking__c where SWAN_Quote__c in :lstCLIParentQuoteIDs and New_Status__c = 'Accepted']){
            mapQuoteHistoryByQuoteId.put(history.SWAN_Quote__c, history);
        }

       /* Map<ID, ContractHistory> mapContractHistoryByContractId = new Map<ID, ContractHistory>();
        for(ContractHistory ch : [Select Id, NewValue, CreatedDate, ContractId, Contract.vlocity_cmt__QuoteId__c from ContractHistory where ContractId in :lstContractIDs AND Field = 'Status']){
            //NewValue cannot be filtered on ContractHistory queries
            if(((String)ch.NewValue).equalsIgnoreCase('Contract Signed')){
                mapContractHistoryByContractId.put(ch.ContractId, ch);
            }
        }*/
        writeFileAttachment(fillListWithContractDetails(lstCLI, mapQuoteHistoryByQuoteId, mapContractHistoryByContractId, mapQuoteLineItemsPerCLIQuote));
    }

    public void finish(Database.BatchableContext BC){
        List<Attachment> lstAttachments = getAttachmentListOrderedByRecentFirst();

        if(lstAttachments != null && lstAttachments.size() != 0){
            Attachment latestAttachment = lstAttachments.get(0);

            if(lstAttachments.size() == 1){
                latestAttachment.Name+='.CSV';
            }else{
                latestAttachment.Name+=' - Last File'+'.CSV';
            }

            update latestAttachment;
            
            Task userTask = new Task();
            
            userTask.OwnerId = latestAttachment.OwnerId;
            userTask.Subject = 'Pipeline Report Ready';
            userTask.priority= 'Normal';
            userTask.status = 'Open';
            userTask.ActivityDate = System.Today();
            
            insert userTask;
        }
    }

    //Fill final list with wrapper objects ready to be written to output XLS
    private void writeFileAttachment(List<OutputFielsdWrapper> lstWrapper){
        List<Attachment> lstAttachments = getAttachmentListOrderedByRecentFirst();

        if(lstAttachments == null || lstAttachments.size() == 0){
            createAttachment(lstWrapper);
        }else{
            String newValuesToAdd = getXLS(lstWrapper);
            Attachment latestAttachment = lstAttachments.get(0);

            if(latestAttachment.BodyLength+newValuesToAdd.length() < MAX_FILE_SIZE){
                latestAttachment.Body=Blob.valueOf(latestAttachment.Body.toString() + newValuesToAdd);
                update latestAttachment;
            }else{
                latestAttachment.Name = latestAttachment.Name+' - File ' + (++numberOfFiles) + '.CSV';
                update latestAttachment;
                createAttachment(lstWrapper);
            }
        }
    }

    private void createAttachment(List<OutputFielsdWrapper> lstWrapper){
        SWAN_Custom_Report__c pipelineReport = new SWAN_Custom_Report__c(Name = fileName, SWAN_Report_Type__c = REPORT_TYPE);

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
            System.debug('An exception has occurred during attachment creation. Here is the exception message: '+e.getMessage()+'\nAnd here is the exception stack trace: '+e.getStackTraceString());
        }        
    }

    private List<Attachment> getAttachmentListOrderedByRecentFirst(){
        String fileNameQueryFilter = fileName+'%';
        return [SELECT id, Name, ParentId, OwnerId, Body, BodyLength FROM Attachment WHERE Name LIKE :fileNameQueryFilter ORDER BY CreatedDate DESC];
    }

    private List<OutputFielsdWrapper> fillListWithContractDetails(List<vlocity_cmt__ContractLineItem__c> lstCLI, 
                                                                                Map<ID, SWAN_Quote_Status_Tracking__c> mapQuoteHistoryByQuoteId, 

                                                                                Map<ID, DateTime> mapContractHistoryByContractId,

                                                                                Map<ID, QuoteLineItem> mapQuoteLineItemsPerCLIQuote){

        List<OutputFielsdWrapper> lstWrapper = new List<OutputFielsdWrapper>();
        Segment_Values__c segmentVal = Segment_Values__c.getOrgDefaults();

        for(vlocity_cmt__ContractLineItem__c cli : lstCLI){

            OutputFielsdWrapper ofw = new OutputFielsdWrapper();

            ofw.status = cli.vlocity_cmt__ContractId__r.Status;
            ofw.statusChild = cli.vlocity_cmt__LineStatus__c;
            ofw.contractnumber = cli.vlocity_cmt__ContractId__r.ContractNumber;
            
            ofw.productTypeCode = cli.vlocity_cmt__ContractId__r.vlocity_cmt__QuoteId__r.SWAN_Quote_Type__c;
            if(ofw.productTypeCode.equalsIgnoreCase('flex')){
                ofw.productTypeCode = 'Flexible';
            }

            //Field mappings that depend if the CLI is a Site Addition
            if(cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.RecordType.Name.startsWithIgnoreCase('Site Addition')){
                ofw.contractId = cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.QuoteNumber;
                ofw.sapOffer = cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.QuoteNumber;
                
                //Field History tracking objects are not writeable and since during test times nothing is actually comitted to the DB, 
                //history tracking mechanism doesn't trigger, exposing the data to the class. 
                //As such, this line will not be covered by an apex test. 
                if(!Test.isRunningTest() && mapQuoteHistoryByQuoteId.containsKey(cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__c)){
                    ofw.executeTime = mapQuoteHistoryByQuoteId.get(cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__c).LastModifiedDate.format('dd/MM/YYYY');
                }

                ofw.salesPerson = cli.vlocity_cmt__ContractId__r.Owner.Name;
                ofw.requestTypeCode = 'Site Addition';
            }else{
                ofw.contractId = cli.vlocity_cmt__ContractId__r.vlocity_cmt__QuoteId__r.QuoteNumber;
                ofw.sapOffer = cli.vlocity_cmt__ContractId__r.vlocity_cmt__QuoteId__r.QuoteNumber;
                

                
                if(!Test.isRunningTest() && mapContractHistoryByContractId.containsKey(cli.vlocity_cmt__ContractId__c)){
                    ofw.executeTime = mapContractHistoryByContractId.get(cli.vlocity_cmt__ContractId__c).format('dd/MM/YYYY');

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
                if(mapQuoteLineItemsPerCLIQuote.containsKey(cli.SWAN_Quote__c)){
                    ofw.product = mapQuoteLineItemsPerCLIQuote.get(cli.SWAN_Quote__c).Product2.Name;   
                }                   
            }

            ofw.meterenddate = cli.vlocity_cmt__EffectiveEndDate__c != null ? cli.vlocity_cmt__EffectiveEndDate__c.format('dd/MM/YYYY') : '';
            ofw.startTime = DateTime.newInstance(cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.SWAN_Offer_Start_Date__c, Time.newInstance(0, 0, 0, 0)).format('dd/MM/YYYY');
            ofw.stopTime = DateTime.newInstance(cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.SWAN_Offer_End_Date__c, Time.newInstance(0, 0, 0, 0)).format('dd/MM/YYYY');
            ofw.customer = cli.vlocity_cmt__ContractId__r.Account.Name;
            ofw.broker = cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.SWAN_Broker__c != null?cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.SWAN_Broker__r.Name:'';
            ofw.mref = (cli.SWAN_Service_Point__r.vlocity_cmt__ServicePointNumber__c != null ? cli.SWAN_Service_Point__r.vlocity_cmt__ServicePointNumber__c : '');
            ofw.ecc = cli.SWAN_Quote__r.SWAN_Contract_Volume_KWh__c!= null?cli.SWAN_Quote__r.SWAN_Contract_Volume_KWh__c.format():'';
            ofw.eac = (cli.vlocity_cmt__ContractId__r.vlocity_cmt__OpportunityId__r.SWAN_Fuel_Type__c=='Gas' ?(cli.SWAN_Service_Point__r.Annual_Quantity__c!= null ? cli.SWAN_Service_Point__r.Annual_Quantity__c.format():''):(cli.SWAN_Quote__r.Annual_Volume__c!=null?cli.SWAN_Quote__r.Annual_Volume__c.format():''));

            //5092
            ofw.contractTypeCode = cli.vlocity_cmt__ContractId__r.vlocity_cmt__OpportunityId__r.SWAN_Fuel_Type__c=='Gas' ? ofw.contractTypeCode : 'Elec' ;
            ofw.swap = cli.vlocity_cmt__ContractId__r.vlocity_cmt__OpportunityId__r.SWAN_Fuel_Type__c=='Gas' ?  ofw.swap : 'Elec' ;
            ofw.gsp = cli.SWAN_Service_Point__r.SWAN_Grid_Supply_Point_Group_Id_Ovrd__c == null ? (cli.SWAN_Service_Point__r.SWAN_Grid_Supply_Point__c == null ? '' : cli.SWAN_Service_Point__r.SWAN_Grid_Supply_Point__c) : cli.SWAN_Service_Point__r.SWAN_Grid_Supply_Point_Group_Id_Ovrd__c;
            ofw.mtc = cli.SWAN_Service_Point__r.SWAN_Meter_Time_switch_Class_Ovrd__c == null ? (cli.SWAN_Service_Point__r.SWAN_Meter_Time_Switch_Code__c == null ? '' : cli.SWAN_Service_Point__r.SWAN_Meter_Time_Switch_Code__c) : cli.SWAN_Service_Point__r.SWAN_Meter_Time_switch_Class_Ovrd__c;
            ofw.llfc = cli.SWAN_Service_Point__r.SWAN_Line_Loss_Factor_Class_Ovrd__c == null ? (cli.SWAN_Service_Point__r.SWAN_Line_Loss_Factor_Class__c == null ? '' : cli.SWAN_Service_Point__r.SWAN_Line_Loss_Factor_Class__c ) : cli.SWAN_Service_Point__r.SWAN_Line_Loss_Factor_Class_Ovrd__c;
            ofw.measurementClass = cli.SWAN_Service_Point__r.SWAN_Measurement_Class_Ovrd__c == null ? (cli.SWAN_Service_Point__r.SWAN_Measurement_Class__c == null ? '' : cli.SWAN_Service_Point__r.SWAN_Measurement_Class__c ) : cli.SWAN_Service_Point__r.SWAN_Measurement_Class_Ovrd__c;

            if(cli.vlocity_cmt__ContractId__r.vlocity_cmt__OpportunityId__r.SWAN_Fuel_Type__c == 'Electricity'){
                ofw.dno = cli.SWAN_Service_Point__r.SWAN_Distributor_ID_Ovrd__c == null ? (cli.SWAN_Service_Point__r.SWAN_Distributor_Id__c == null ? '' : String.valueOf(cli.SWAN_Service_Point__r.SWAN_Distributor_Id__c)) : String.valueOf(cli.SWAN_Service_Point__r.SWAN_Distributor_ID_Ovrd__c);

                ofw.profileClass = (cli.SWAN_Service_Point__r.SWAN_Profile_Class__c != null ? cli.SWAN_Service_Point__r.SWAN_Profile_Class__c : '');

                // IF SWAN_Service_Point__r.SWAN_Product_Class__c = (A || B) THEN NHH
                String measurementClass = (cli.SWAN_Service_Point__r.SWAN_Measurement_Class_Ovrd__c == null ? (cli.SWAN_Service_Point__r.SWAN_Measurement_Class__c == null ? '' : cli.SWAN_Service_Point__r.SWAN_Measurement_Class__c) : cli.SWAN_Service_Point__r.SWAN_Measurement_Class_Ovrd__c );
                String passThrough = (cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.SWAN_Passthrough_Option__c == null ? '': cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.SWAN_Passthrough_Option__c ); 
                Boolean HH = ( (measurementClass == 'C' || measurementClass == 'D' || measurementClass == 'E' || measurementClass == 'F' || measurementClass == 'G' ) ? true : false );

                ofw.aahedcSapPassth = ( HH && (passThrough.indexOf('AAHEDC') != -1) ? 'True' : 'False' );
                ofw.feedInTariffSapPassth = ( HH && (passThrough.indexOf('Feed in Tariff') != -1) ? 'True' : 'False' );
                ofw.renObligSapPasst = ( HH && (passThrough.indexOf('Renewable Obligation') != -1) ? 'True' : 'False' );
                ofw.cfdSapPassth = ( HH && (passThrough.indexOf('Contracts for Difference') != -1) ? 'True' : 'False' );
                ofw.tnuosHhSapPassth = ( HH && (passThrough.indexOf('TNUoS') != -1) ? 'True' : 'False' );
                ofw.cmHhSapPassth = ( HH && (passThrough.indexOf('Capacity Market') != -1) ? 'True' : 'False' );
                ofw.bsuosHhSapPassth = ( HH && (passThrough.indexOf('BSUoS + RCRC') != -1) ? 'True' : 'False' );
                ofw.duosHhPassth = ( HH && (passThrough.indexOf('DUoS') != -1) ? 'True' : 'False' );
                ofw.meterType = (HH ? 'HH' :'NHH');
                
                getUsageUnitPrice(ofw, cli.vlocity_cmt__Contract_Line_Items__r);
            } 

            if(cli.vlocity_cmt__ContractId__r.vlocity_cmt__OpportunityId__r.SWAN_Fuel_Type__c=='Gas' && cli.SWAN_Service_Point__r.SWAN_Product_Class__c != null){
                if(cli.SWAN_Service_Point__r.SWAN_Product_Class__c == '1' || cli.SWAN_Service_Point__r.SWAN_Product_Class__c == '2'){
                    ofw.meterType = 'DM';
                }else if(cli.SWAN_Service_Point__r.SWAN_Product_Class__c == '3' || cli.SWAN_Service_Point__r.SWAN_Product_Class__c == '4'){
                    ofw.meterType = 'NDM';
                }
            }

            if(cli.SWAN_Quote__c != null){
                if(cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.RecordType.Name.startsWithIgnoreCase('Site Addition')){
                    if(cli.vlocity_cmt__ContractId__r.vlocity_cmt__PriceListId__c != null){
                        if(cli.vlocity_cmt__ContractId__r.vlocity_cmt__PriceListId__r.Name == label.Swan_Enterprise_Price_List){
                            ofw.segment = segmentVal.Pipeline_Enterprise_Segment__c;
                        } else if(cli.vlocity_cmt__ContractId__r.vlocity_cmt__PriceListId__r.Name == label.Swan_I_C_Price_List){
                            ofw.segment = segmentVal.Pipeline_I_C_Segment__c;
                        }
                    }
                }else {
                    if(cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.vlocity_cmt__PriceListId__c != null){
                        if(cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.vlocity_cmt__PriceListId__r.Name == label.Swan_Enterprise_Price_List){
                            ofw.segment = segmentVal.Pipeline_Enterprise_Segment__c;
                        } else if(cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.vlocity_cmt__PriceListId__r.Name == label.Swan_I_C_Price_List){
                            ofw.segment = segmentVal.Pipeline_I_C_Segment__c;
                        }
                    }
                }
            }
            lstWrapper.add(ofw);
        }
        return lstWrapper;
    }

    private void getUsageUnitPrice(OutputFielsdWrapper ofw, List<vlocity_cmt__ContractLineItem__c> lstCLI) {
        for(vlocity_cmt__ContractLineItem__c cli : lstCLI) {
            if(cli.vlocity_cmt__Product2Id__r.ProductCode.equalsIgnoreCase('BG_BSUOS_PASS_THROUGH_PRICE') && ofw.BSUoSRefPrice.equalsIgnoreCase('')) {
                ofw.BSUoSRefPrice = (cli.SWAN_UsageUnitPrice__c != null ? String.valueOf(cli.SWAN_UsageUnitPrice__c) : '');
            }

            if(cli.vlocity_cmt__Product2Id__r.ProductCode.equalsIgnoreCase('BG_AAHEDC_PASS_THROUGH_PRICE') && ofw.AAHEDCRefPrice.equalsIgnoreCase('')) {
                ofw.AAHEDCRefPrice = (cli.SWAN_UsageUnitPrice__c != null ? String.valueOf(cli.SWAN_UsageUnitPrice__c) : '');
            }
        }
    }

    private String getXLS(List<OutputFielsdWrapper> lstWrapper){
        final String NUL = '';
        final String SEP = '","';
        
        //Output string with header built
        String outputXLS = '"SourceSystem' + SEP + 'DATE_RUN' + SEP + 'STATUS' + SEP + 'STATUS_Child' + SEP + 'CONTRACTTYPECODE' + SEP + 'CONTRACTID' +
                             SEP + 'REVISION' + SEP + 'SAP_OFFER' + SEP + 'EXECUTETIME' + SEP + 'LSTIME' + SEP + 'STARTTIME_Child' + SEP + 'STARTTIME' +
                             SEP + 'STOPTIME' + SEP + 'CUSTOMER' + SEP + 'BROKER' + SEP + 'SALES_PERSON' + SEP + 'REQUESTTYPECODE' + SEP + 'PRODUCTTYPECODE' +
                             SEP + 'SWAP' + SEP + 'MREF' + SEP + 'DummyMpan' + SEP + 'NewConnection' + SEP + 'ECC' + SEP + 'EAC' + SEP + 'ProfileClass' + SEP + 'MeterType' + 
                             SEP + 'AAHEDC_SAP_PASSTH' + SEP + 'HH_UNIT_CHARGE_SAP_PASSTH' + SEP + 'FEED_IN_TARIFF_SAP_PASSTH' + SEP + 'REN_OBLIG_SAP_PASST' + 
                             SEP + 'CFD_SAP_PASSTH' + SEP + 'TNUOS_HH_SAP_PASSTH' + SEP + 'CM_HH_SAP_PASSTH' + SEP + 'BSUOS_HH_SAP_PASSTH' + SEP + 'Product' + 
                             SEP + 'Segment' + SEP + 'MeterEndDate' + SEP + 'CONTRACTNUMBER' + SEP + 'DUOS_HH_PASSTH' + SEP + 'GSP' + SEP + 'DNO' + SEP + 'MTC' + SEP + 'LLFC' +
                             SEP + 'MeasurementClass' + SEP + 'AAHEDCRefPrice' + SEP + 'BSUoSRefPrice'+'"\n';

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
                        +ofw.segment + SEP
                        +ofw.meterenddate + SEP
                        +ofw.contractnumber + SEP
                        +ofw.duosHhPassth + SEP
                        +ofw.gsp + SEP
                        +ofw.dno + SEP
                        +ofw.mtc + SEP
                        +ofw.llfc + SEP
                        +ofw.measurementClass + SEP
                        +ofw.AAHEDCRefPrice + SEP
                        +ofw.BSUoSRefPrice + '"\n';
        }

        return outputXLS;
    }

}