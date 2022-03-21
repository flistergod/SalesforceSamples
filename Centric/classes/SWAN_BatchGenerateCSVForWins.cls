public with sharing class SWAN_BatchGenerateCSVForWins implements Database.Batchable<sObject>, Database.Stateful{

    static final String NUL = '';
    static final String SEP = '","';
    String statuses = Label.SWAN_ContractStatusWINSReport;
    List<String> statusList = statuses.split(',');
    Segment_Values__c segmentVal = Segment_Values__c.getOrgDefaults();
    private static final Integer MAX_FILE_SIZE = 12000000; //Likely will need to change value to something lower due to heap size limit - 12MB (batchable is Async)
    private static final String REPORT_TYPE = 'WINS';
    private static final Datetime REPORT_RUN_TIME = System.now();
    private static final String REPORT_RUN_TIME_IN_STRING_FORMAT = REPORT_RUN_TIME.format('dd/MM/YYYY');
    private String fileName;
    private Integer numberOfFiles = 0;


    public SWAN_BatchGenerateCSVForWins() {
        fileName = 'BGB_WINS_REPORT_' + REPORT_RUN_TIME.format('YYYYMMddHHmmss');
        numberOfFiles = 0;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT id, vlocity_cmt__PriceListId__c, vlocity_cmt__PriceListId__r.Name, vlocity_cmt__QuoteId__r.vlocity_cmt__PriceListId__c, vlocity_cmt__QuoteId__r.vlocity_cmt__PriceListId__r.Name, 
                            CreatedDate,vlocity_cmt__QuoteId__c,vlocity_cmt__QuoteId__r.Account.Name,vlocity_cmt__QuoteId__r.SWAN_Contribution_Margin__c, vlocity_cmt__QuoteId__r.SWAN_Broker_Commission__c,
                            vlocity_cmt__QuoteId__r.SWAN_Gross_Margin__c,vlocity_cmt__QuoteId__r.SWAN_Contract_Spend__c,vlocity_cmt__QuoteId__r.QuoteNumber, 
                            vlocity_cmt__QuoteId__r.SWAN_Offer_Start_Date__c,vlocity_cmt__QuoteId__r.SWAN_Offer_End_Date__c,vlocity_cmt__QuoteId__r.Opportunity.Owner.Name,
                            vlocity_cmt__QuoteId__r.SWAN_Offer_Duration__c,vlocity_cmt__QuoteId__r.SWAN_Contract_Volume_KWh__c,vlocity_cmt__QuoteId__r.SWAN_Quote_for_Fuel_Type__c,vlocity_cmt__QuoteId__r.SWAN_Non_Commodity_Passthrough__c,vlocity_cmt__QuoteId__r.SWAN_Passthrough_Option__c,
                            SWAN_Payment_Method__c,SWAN_Payment_Term__c,vlocity_cmt__QuoteId__r.SWAN_Number_of_Service_Points__c, 
                            vlocity_cmt__OpportunityId__c, vlocity_cmt__OpportunityId__r.RecordTypeId, vlocity_cmt__QuoteId__r.SWAN_Broker__c, CompanySignedId, CompanySigned.Name, OwnerId, Owner.Name, 
                            vlocity_cmt__QuoteId__r.SWAN_Sales_Channel__c, vlocity_cmt__QuoteId__r.SWAN_Broker__r.Name FROM Contract WHERE Status IN :statusList AND vlocity_cmt__QuoteId__r.vlocity_cmt__ParentQuoteId__c = null]);

    }
    
    public void execute(Database.BatchableContext BC, List<Contract> lstContracts){
        String CSVData ='';
    
        Map<id,Contract> contractIdToContractMap = new  Map<id,Contract>();
        Map<id,DateTime> contractidToContractSignDate = new Map<id,DateTime>();
        Map<id,List<Id>> quoteidToServicePts = new Map<id,List<Id>>();
        Map<id,String> quoteProdMap = new Map<id,String>();
        List<Contract> liveContractList = new List<Contract>();
        Set<Id> quoteIds = new Set<Id>();
        Set<Id> servicePointIds = new Set<Id>();
        Id recTypeIdRenewal; Id recTypeIdUpgrade;
        Map<Id,Contract> mapContractsByQuoteId = new Map<Id, Contract>();
        Set<ID> contractIds = new Set<ID>(); 
        Map<Id,Quote> mapQuotesByServicePoint = new Map<Id,Quote>();

        Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Opportunity.getRecordTypeInfosByName();

        if(rtMapByName != null && rtMapByName.containskey(label.OptyRenewalRecordType)){
            recTypeIdRenewal =  rtMapByName.get(label.OptyRenewalRecordType).getRecordTypeId();
        }

        if(rtMapByName != null && rtMapByName.containskey(label.OptyUpgradeRecordType)){
            recTypeIdUpgrade =  rtMapByName.get(label.OptyUpgradeRecordType).getRecordTypeId();
        }
        
        for(Contract con : lstContracts){
            contractIdToContractMap.put(con.id,con);
            contractIds.add(con.id);
            mapContractsByQuoteId.put(con.vlocity_cmt__QuoteId__c, con);
        }  

        for(ContractHistory conH : [Select id , NewValue,CreatedDate,ContractId,Contract.vlocity_cmt__QuoteId__c from ContractHistory where ContractId in : contractIds AND CreatedDate = THIS_YEAR]){
            if(conH.Newvalue == 'Contract Signed' || Test.isRunningTest()){
                quoteIds.add(conH.Contract.vlocity_cmt__QuoteId__c);
                liveContractList.add(contractIdToContractMap.get(conH.ContractId));
                contractidToContractSignDate.put(conH.ContractId,ConH.CreatedDate);
            }
        }

        // START -- For Site Addition Quotes
        Map<id,DateTime> quoteIdToAcceptedDate = new Map<id,DateTime>();
        List<Quote> liveQuoteList = new List<Quote>();
        Set<Id> siteAddnQtIds = new Set<Id>();
        
        for(Quote siteAddnQt: [SELECT id,CreatedDate,Account.Name,SWAN_Contribution_Margin__c, SWAN_Broker_Commission__c, SWAN_Broker__c, 
        SWAN_Gross_Margin__c,SWAN_Contract_Spend__c,QuoteNumber, SWAN_Broker__r.Name, SWAN_Sales_Channel__c,
        SWAN_Offer_Start_Date__c,SWAN_Offer_End_Date__c,Opportunity.Owner.Name,SWAN_Quote_for_Fuel_Type__c,SWAN_Non_Commodity_Passthrough__c,SWAN_Passthrough_Option__c,
        SWAN_Offer_Duration__c,SWAN_Contract_Volume_KWh__c, SWAN_Site_Addition_Parent__c, 
        SWAN_Payment_Method__c,SWAN_Payment_Term__c,SWAN_Number_of_Service_Points__c,Owner.Name FROM Quote WHERE Status = 'Accepted' and recordType.Name=:label.QuoteSiteAdditionRecordType])
        {
            //contractIdToContractMap.put(con.id,con);
            liveQuoteList.add(siteAddnQt);
            siteAddnQtIds.add(siteAddnQt.id);
        }   
        system.debug('Site Addition Set: '+siteAddnQtIds);
        for(SWAN_Quote_Status_Tracking__c quoteH : [Select id , New_Status__c,Prior_Status__c,CreatedDate,SWAN_Quote__c from SWAN_Quote_Status_Tracking__c where SWAN_Quote__c in : siteAddnQtIds AND CreatedDate = THIS_YEAR]){
        if(quoteH.New_Status__c == 'Accepted' || Test.isRunningTest()){
                quoteIdToAcceptedDate.put(quoteH.SWAN_Quote__c,quoteH.CreatedDate);
            }
        }
        // End -- For Site Addition Quotes

        
        List<Annual_Volume_Bands__mdt> AnnualBandsList = new List<Annual_Volume_Bands__mdt>();
        for(Annual_Volume_Bands__mdt AnnualBand : [Select id ,Band__c,Annual_volume_kWh_To__c,Annual_volume_Kwh_From__c from Annual_Volume_Bands__mdt order by Annual_volume_Kwh_From__c]){
            AnnualBandsList.add(AnnualBand);
        }
        
        Datetime nowDate = Datetime.now();
        String nowString = nowDate.format('YYYYMMddhhmmss');

        if(!liveContractList.isEmpty()){
            for(Quote qt : [Select id , SWAN_Broker__c, SWAN_Sales_Channel__c, SWAN_Broker__r.Name,SWAN_Quote_for_Fuel_Type__c,SWAN_Non_Commodity_Passthrough__c, SWAN_Passthrough_Option__c, (select id,vlocity_cmt__DefaultServicePointId__c, vlocity_cmt__ParentQuoteId__r.SWAN_Passthrough_Option__c, SWAN_Parent_Quote__r.SWAN_Passthrough_Option__c, vlocity_cmt__ParentQuoteId__r.SWAN_Non_Commodity_Passthrough__c, SWAN_Parent_Quote__r.SWAN_Non_Commodity_Passthrough__c from vlocity_cmt__Quotes__r where Recordtype.Developername != 'GroupCart'), (Select id, Product2Id, Product2.Name, QuoteId From QuoteLineItems where Product2Id != null and Product2.vlocity_cmt__IsOrderable__c=true) from Quote where id in : quoteIds]){
                for(Quote childQuotes : qt.vlocity_cmt__Quotes__r){
                    servicePointIds.add(childQuotes.vlocity_cmt__DefaultServicePointId__c);
                    if(quoteidToServicePts.containsKey(qt.Id)){
                        quoteidToServicePts.get(qt.id).add(childQuotes.vlocity_cmt__DefaultServicePointId__c);
                        mapQuotesByServicePoint.put(childQuotes.vlocity_cmt__DefaultServicePointId__c,childQuotes);
                    }else{
                        List<ID> serPts = new List<ID>();
                        serPts.add(childQuotes.vlocity_cmt__DefaultServicePointId__c);
                        quoteidToServicePts.put(qt.ID,serPts);
                        mapQuotesByServicePoint.put(childQuotes.vlocity_cmt__DefaultServicePointId__c,childQuotes);
                    }
                    
                }
                for(QuoteLineItem qli: qt.QuoteLineItems){
                    quoteProdMap.put(qli.QuoteId, qli.Product2.Name);
                }
            }
        }

        // Start -- For Site Addition 
        if(liveQuoteList.size() > 0){
            for(Quote qt : [Select id , SWAN_Broker__c, SWAN_Sales_Channel__c, SWAN_Broker__r.Name,SWAN_Quote_for_Fuel_Type__c,vlocity_cmt__ParentQuoteId__r.SWAN_Non_Commodity_Passthrough__c, SWAN_Parent_Quote__r.SWAN_Passthrough_Option__c, (select id,vlocity_cmt__DefaultServicePointId__c, SWAN_Non_Commodity_Passthrough__c, vlocity_cmt__ParentQuoteId__r.SWAN_Passthrough_Option__c, SWAN_Parent_Quote__r.SWAN_Passthrough_Option__c, vlocity_cmt__ParentQuoteId__r.SWAN_Non_Commodity_Passthrough__c, SWAN_Parent_Quote__r.SWAN_Non_Commodity_Passthrough__c from vlocity_cmt__Quotes__r where Recordtype.Developername != 'GroupCart'), (Select id, Product2Id, Product2.Name, QuoteId From QuoteLineItems where Product2Id != null and Product2.vlocity_cmt__IsOrderable__c=true) from Quote where id in : siteAddnQtIds]){
                for(Quote childQuotes : qt.vlocity_cmt__Quotes__r){
                    servicePointIds.add(childQuotes.vlocity_cmt__DefaultServicePointId__c); 
                    if(quoteidToServicePts.containsKey(qt.Id)){
                        quoteidToServicePts.get(qt.id).add(childQuotes.vlocity_cmt__DefaultServicePointId__c);
                        mapQuotesByServicePoint.put(childQuotes.vlocity_cmt__DefaultServicePointId__c,childQuotes);
                    }else{
                        List<ID> serPts = new List<ID>();
                        serPts.add(childQuotes.vlocity_cmt__DefaultServicePointId__c);
                        quoteidToServicePts.put(qt.ID,serPts);
                        mapQuotesByServicePoint.put(childQuotes.vlocity_cmt__DefaultServicePointId__c,childQuotes);
                    }
                    
                }

                for(QuoteLineItem qli: qt.QuoteLineItems){
                    quoteProdMap.put(qli.QuoteId, qli.Product2.Name);
                }
            }
        }
        // End -- For Site Addition

        Map<id,vlocity_cmt__ServicePoint__c> servicePointMap; 
        if(servicePointIds.size()>0){
            servicePointMap = new Map<id,vlocity_cmt__ServicePoint__c>([Select id,SWAN_Product_Class__c,SWAN_Measurement_Class__c,SWAN_Measurement_Class_Ovrd__c,vlocity_cmt__ServiceType__c FROM vlocity_cmt__ServicePoint__c WHERE id IN :servicePointIds]);
        }

        if(!liveContractList.isEmpty() || liveQuoteList.size() > 0){
            system.debug('liveContractList: '+liveContractList);
            for(Contract cont :liveContractList){
                if(cont.vlocity_cmt__QuoteId__r.QuoteNumber == '00150706')
                system.debug('cont.Id '+cont.Id);
                String brokerName = '';

                if(cont.vlocity_cmt__QuoteId__r.SWAN_Sales_Channel__c == 'Broker' && cont.vlocity_cmt__QuoteId__r.SWAN_Broker__c != null){
                    brokerName = cont.vlocity_cmt__QuoteId__r.SWAN_Broker__r.Name;
                }else{
                    brokerName = 'Not Involved';
                }

                String prodName = '';

                if(quoteProdMap.size()>0 && quoteProdMap.containsKey(cont.vlocity_cmt__QuoteId__c)){
                    prodName = quoteProdMap.get(cont.vlocity_cmt__QuoteId__c);
                } 

                Integer offerDuration = 0;
                
                if(!String.isBlank(cont.vlocity_cmt__QuoteId__r.SWAN_Offer_Duration__c)){
                    String[] offerD = cont.vlocity_cmt__QuoteId__r.SWAN_Offer_Duration__c.split(' ');
                    
                    if(offerD[0].isNumeric()){
                        offerDuration = Integer.ValueOf(offerD[0]);
                    }
                }

                Decimal conVol = 0.0;

                if((cont.vlocity_cmt__QuoteId__r.SWAN_Contract_Volume_KWh__c != null)){
                    conVol = cont.vlocity_cmt__QuoteId__r.SWAN_Contract_Volume_KWh__c;
                }

                Date offerStartDate = cont.vlocity_cmt__QuoteId__r.SWAN_Offer_Start_Date__c;
                Date offerEndDate = cont.vlocity_cmt__QuoteId__r.SWAN_Offer_End_Date__c;
                Integer durVal = offerStartDate.daysBetween(offerEndDate) + 1;
                Integer AnnVol = MATH.round(((conVol) / (durVal))*365); 
                String AnnualVol = String.ValueOf(AnnVol);
                String VolBand = '';
                Decimal brokerCommission= 0;

                if(cont.vlocity_cmt__QuoteId__r.SWAN_Broker_Commission__c != null){
                    brokerCommission = cont.vlocity_cmt__QuoteId__r.SWAN_Broker_Commission__c;
                }

                Decimal conMar= 0.0;

                if(cont.vlocity_cmt__QuoteId__r.SWAN_Contribution_Margin__c != null){
                    conMar = cont.vlocity_cmt__QuoteId__r.SWAN_Contribution_Margin__c;
                }

                Decimal groMar = 0.0;

                if(cont.vlocity_cmt__QuoteId__r.SWAN_Gross_Margin__c != null) {
                    groMar = cont.vlocity_cmt__QuoteId__r.SWAN_Gross_Margin__c;
                }

                for(Annual_Volume_Bands__mdt band : AnnualBandsList){
                    
                    if(AnnVol >= band.Annual_volume_Kwh_From__c &&  band.Annual_volume_kWh_To__c != Null && AnnVol <= band.Annual_volume_kWh_To__c){
                        VolBand = band.Band__c;
                    }else if(AnnVol >= band.Annual_volume_Kwh_From__c && band.Annual_volume_kWh_To__c == null){
                        VolBand = band.Band__c;
                    }
                }
                
                String productClass= '';

                if(quoteidToServicePts.containsKey(cont.vlocity_cmt__QuoteId__c) && cont.vlocity_cmt__QuoteId__r.SWAN_Quote_for_Fuel_Type__c == 'Gas'){
                    for(Id serPts : quoteidToServicePts.get(cont.vlocity_cmt__QuoteId__c)){
                        if(servicePointMap != null && servicePointMap.containsKey(serPts)) {
                            if(servicePointMap.get(serPts).SWAN_Product_Class__c == '1' || servicePointMap.get(serPts).SWAN_Product_Class__c == '2'){
                                if(productClass == 'NDM'){ 
                                    productClass =''; break;
                                }
                                productClass = 'DM';
                            }
                            
                            if (servicePointMap.get(serPts).SWAN_Product_Class__c == '3' || servicePointMap.get(serPts).SWAN_Product_Class__c == '4'){
                                if(productClass == 'DM'){ 
                                    productClass =''; break;
                                }else {
                                    productClass = 'NDM';
                                }
                            }
                        }
                    }
                }
              // Start -- Set NHH or HH Product Class (Electricity)
              else if(quoteidToServicePts.containsKey(cont.vlocity_cmt__QuoteId__c) && cont.vlocity_cmt__QuoteId__r.SWAN_Quote_for_Fuel_Type__c == 'Electricity')
              {
                  for(Id serPts : quoteidToServicePts.get(cont.vlocity_cmt__QuoteId__c))
                  {   
                      if(servicePointMap != null && servicePointMap.containsKey(serPts) && servicePointMap.get(serPts).SWAN_Measurement_Class_Ovrd__c == null )
                      {
                          if(servicePointMap.get(serPts).vlocity_cmt__ServiceType__c == 'Electricity' && (servicePointMap.get(serPts).SWAN_Measurement_Class__c == 'C' || servicePointMap.get(serPts).SWAN_Measurement_Class__c == 'D' || servicePointMap.get(serPts).SWAN_Measurement_Class__c == 'E' || servicePointMap.get(serPts).SWAN_Measurement_Class__c == 'F' || servicePointMap.get(serPts).SWAN_Measurement_Class__c == 'G'))
                            {
                            productClass = 'HH'; break;}
                            else {productClass = 'NHH';}
                      }
               
                      else if(servicePointMap != null && servicePointMap.containsKey(serPts) && servicePointMap.get(serPts).SWAN_Measurement_Class_Ovrd__c != null )
                      {
                          if(servicePointMap.get(serPts).vlocity_cmt__ServiceType__c == 'Electricity' && (servicePointMap.get(serPts).SWAN_Measurement_Class_Ovrd__c == 'C' || servicePointMap.get(serPts).SWAN_Measurement_Class_Ovrd__c == 'D' || servicePointMap.get(serPts).SWAN_Measurement_Class_Ovrd__c == 'E' || servicePointMap.get(serPts).SWAN_Measurement_Class_Ovrd__c == 'F' || servicePointMap.get(serPts).SWAN_Measurement_Class_Ovrd__c == 'G'))
                            {
                            productClass = 'HH'; break;}
                            else {productClass = 'NHH';}
                      }
                 }
              }     
              // End -- -- Set NHH or HH Product Class (Electricity)     
             // Start -- -- Set Pass through options (Electricity)         
                Map<Id, Quote> mapQuotesByServicePointId = new Map<Id, Quote>();
                /*for(Quote q : [Select Id, SWAN_Non_Commodity_Passthrough__c, SWAN_Service_Point__c, SWAN_Passthrough_Option__c from Quote where SWAN_Service_Point__c in :mapQuotesByServicePoint]){
                    mapQuotesByServicePointId.put(q.SWAN_Service_Point__c, q);            
                }   */ 
                String AAHEDC_SAP_PASSTH;
                String BSUOS_HH_SAP_PASSTH;
                String DUOS_HH_UNIT_CHARGE_SAP_PASSTH;
                String FEED_IN_TARIFF_SAP_PASSTH;
                String REN_OBLIG_SAP_PASSTH;
                String CFD_SAP_PASSTH;
                String TNUOS_HH_SAP_PASSTH; 
                List<Id> lstSerPts = new List<Id>();
                if(cont.vlocity_cmt__QuoteId__c != null){
                    System.debug('quoteidToServicePts.get(cont.vlocity_cmt__QuoteId__c)' + quoteidToServicePts.get(cont.vlocity_cmt__QuoteId__c));
                    lstSerPts = new List<Id>(quoteidToServicePts.get(cont.vlocity_cmt__QuoteId__c));
                    System.debug('quoteidToServicePts.get(cont.vlocity_cmt__QuoteId__c)' + lstSerPts);
                    
                    
                }           
                 for(Id serPts : lstSerPts)      
                 {
                    if(serPts != null){  
                        if(servicePointMap.get(serPts).vlocity_cmt__ServiceType__c == 'Electricity' && (servicePointMap.get(serPts).SWAN_Measurement_Class__c != 'A' || servicePointMap.get(serPts).SWAN_Measurement_Class__c != 'B') && (mapQuotesByServicePoint.get(serPts).vlocity_cmt__ParentQuoteId__r.SWAN_Non_Commodity_Passthrough__c != null || mapQuotesByServicePoint.get(serPts).SWAN_Parent_Quote__r.SWAN_Non_Commodity_Passthrough__c != null))
                        {
                            
                            if(mapQuotesByServicePoint.get(serPts).vlocity_cmt__ParentQuoteId__r.SWAN_Non_Commodity_Passthrough__c  == 'Full Pass through' || mapQuotesByServicePoint.get(serPts).SWAN_Parent_Quote__r.SWAN_Non_Commodity_Passthrough__c  == 'Full Pass through')
                                {
                                    AAHEDC_SAP_PASSTH = 'TRUE';
                                    BSUOS_HH_SAP_PASSTH = 'TRUE';
                                    DUOS_HH_UNIT_CHARGE_SAP_PASSTH = 'TRUE';
                                    FEED_IN_TARIFF_SAP_PASSTH = 'TRUE';
                                    REN_OBLIG_SAP_PASSTH = 'TRUE';
                                    CFD_SAP_PASSTH = 'TRUE';
                                    TNUOS_HH_SAP_PASSTH = 'TRUE';
                                    break;
                                }               
                            else if(mapQuotesByServicePoint.get(serPts).vlocity_cmt__ParentQuoteId__r.SWAN_Non_Commodity_Passthrough__c  == 'Fixed' || mapQuotesByServicePoint.get(serPts).SWAN_Parent_Quote__r.SWAN_Non_Commodity_Passthrough__c  == 'Fixed')
                                {
                                    AAHEDC_SAP_PASSTH = 'FALSE';
                                    BSUOS_HH_SAP_PASSTH = 'FALSE';
                                    DUOS_HH_UNIT_CHARGE_SAP_PASSTH = 'FALSE';
                                    FEED_IN_TARIFF_SAP_PASSTH = 'FALSE';
                                    REN_OBLIG_SAP_PASSTH = 'FALSE';
                                    CFD_SAP_PASSTH = 'FALSE';
                                    TNUOS_HH_SAP_PASSTH = 'FALSE';
                                    break;
                                }
                            else if(mapQuotesByServicePoint.get(serPts).vlocity_cmt__ParentQuoteId__r.SWAN_Non_Commodity_Passthrough__c  == 'Pass Through' || mapQuotesByServicePoint.get(serPts).SWAN_Parent_Quote__r.SWAN_Non_Commodity_Passthrough__c  == 'Pass Through')
                                {
                                    AAHEDC_SAP_PASSTH = (productClass == 'HH' && (mapQuotesByServicePoint.get(serPts).vlocity_cmt__ParentQuoteId__r.SWAN_Passthrough_Option__c.contains('AAHEDC')||mapQuotesByServicePoint.get(serPts).SWAN_Parent_Quote__r.SWAN_Passthrough_Option__c.contains('AAHEDC'))) ? 'TRUE' : 'FALSE';
                                    BSUOS_HH_SAP_PASSTH = (productClass == 'HH' && (mapQuotesByServicePoint.get(serPts).vlocity_cmt__ParentQuoteId__r.SWAN_Passthrough_Option__c.contains('BSUoS + RCRC')||mapQuotesByServicePoint.get(serPts).SWAN_Parent_Quote__r.SWAN_Passthrough_Option__c.contains('BSUoS + RCRC'))) ? 'TRUE' : 'FALSE';
                                    DUOS_HH_UNIT_CHARGE_SAP_PASSTH = (productClass == 'HH' && (mapQuotesByServicePoint.get(serPts).vlocity_cmt__ParentQuoteId__r.SWAN_Passthrough_Option__c.contains('DUoS')||mapQuotesByServicePoint.get(serPts).SWAN_Parent_Quote__r.SWAN_Passthrough_Option__c.contains('DUoS'))) ? 'TRUE' : 'FALSE';
                                    FEED_IN_TARIFF_SAP_PASSTH = (productClass == 'HH' && (mapQuotesByServicePoint.get(serPts).vlocity_cmt__ParentQuoteId__r.SWAN_Passthrough_Option__c.contains('Feed in Tariff')||mapQuotesByServicePoint.get(serPts).SWAN_Parent_Quote__r.SWAN_Passthrough_Option__c.contains('Feed in Tariff'))) ? 'TRUE' : 'FALSE';
                                    REN_OBLIG_SAP_PASSTH = (productClass == 'HH' && (mapQuotesByServicePoint.get(serPts).vlocity_cmt__ParentQuoteId__r.SWAN_Passthrough_Option__c.contains('Renewable Obligation')||mapQuotesByServicePoint.get(serPts).SWAN_Parent_Quote__r.SWAN_Passthrough_Option__c.contains('Renewable Obligation'))) ? 'TRUE' : 'FALSE';
                                    CFD_SAP_PASSTH = (productClass == 'HH' && (mapQuotesByServicePoint.get(serPts).vlocity_cmt__ParentQuoteId__r.SWAN_Passthrough_Option__c.contains('Contracts for difference')||mapQuotesByServicePoint.get(serPts).SWAN_Parent_Quote__r.SWAN_Passthrough_Option__c.contains('Contracts for difference'))) ? 'TRUE' : 'FALSE';
                                    TNUOS_HH_SAP_PASSTH = (productClass == 'HH' && (mapQuotesByServicePoint.get(serPts).vlocity_cmt__ParentQuoteId__r.SWAN_Passthrough_Option__c.contains('TNUoS')||mapQuotesByServicePoint.get(serPts).SWAN_Parent_Quote__r.SWAN_Passthrough_Option__c.contains('TNUoS'))) ? 'TRUE' : 'FALSE';
                                    break;
                                }
                            else
                            {
                                    AAHEDC_SAP_PASSTH = 'FALSE';
                                    BSUOS_HH_SAP_PASSTH = 'FALSE';
                                    DUOS_HH_UNIT_CHARGE_SAP_PASSTH = 'FALSE';
                                    FEED_IN_TARIFF_SAP_PASSTH = 'FALSE';
                                    REN_OBLIG_SAP_PASSTH = 'FALSE';
                                    CFD_SAP_PASSTH = 'FALSE';
                                    TNUOS_HH_SAP_PASSTH = 'FALSE';
                                    break;
                                }
                        }
                        else if (servicePointMap.get(serPts).vlocity_cmt__ServiceType__c == 'Electricity' && (servicePointMap.get(serPts).SWAN_Measurement_Class__c == 'A' || servicePointMap.get(serPts).SWAN_Measurement_Class__c == 'B'))
                            {
                                    AAHEDC_SAP_PASSTH = 'FALSE';
                                    BSUOS_HH_SAP_PASSTH = 'FALSE';
                                    DUOS_HH_UNIT_CHARGE_SAP_PASSTH = 'FALSE';
                                    FEED_IN_TARIFF_SAP_PASSTH = 'FALSE';
                                    REN_OBLIG_SAP_PASSTH = 'FALSE';
                                    CFD_SAP_PASSTH = 'FALSE';
                                    TNUOS_HH_SAP_PASSTH = 'FALSE';
                                    break;
                                }   
                        else if (servicePointMap.get(serPts).vlocity_cmt__ServiceType__c == 'Gas')
                            {
                                    AAHEDC_SAP_PASSTH = '';
                                    BSUOS_HH_SAP_PASSTH = '';
                                    DUOS_HH_UNIT_CHARGE_SAP_PASSTH = '';
                                    FEED_IN_TARIFF_SAP_PASSTH = '';
                                    REN_OBLIG_SAP_PASSTH = '';
                                    CFD_SAP_PASSTH = '';
                                    TNUOS_HH_SAP_PASSTH = '';
                                    break;
                                }                        
                        else
                                {
                                        AAHEDC_SAP_PASSTH = 'FALSE';
                                        BSUOS_HH_SAP_PASSTH = 'FALSE';
                                        DUOS_HH_UNIT_CHARGE_SAP_PASSTH = 'FALSE';
                                        FEED_IN_TARIFF_SAP_PASSTH = 'FALSE';
                                        REN_OBLIG_SAP_PASSTH = 'FALSE';
                                        CFD_SAP_PASSTH = 'FALSE';
                                        TNUOS_HH_SAP_PASSTH = 'FALSE';
                                        break;
                                }
                    }                               
                 }                    
                    // End -- -- Set Pass through options (Electricity)                                                         
             
                Date curdate= system.today();
                Integer daysQuote = offerStartDate.daysBetween(offerEndDate) + 1;
                Decimal perDayCM= conMar / daysQuote;
                Decimal perDayGM= groMar / daysQuote;
                Map<Integer,String> mapIndexWithCM = new Map<Integer,String>();
                Map<Integer,String> mapIndexWithGM = new Map<Integer,String>();
                
                Decimal calGM = 0.0;
                Decimal calCM = 0.0;
                    
                for(Integer x=-1;x<=5;x++){
                    Date dateRange = curdate.addYears(x);
                    Date startDate = Date.newInstance(dateRange.year(), 1, 1);
                    Date endDate = Date.newInstance(dateRange.year(), 12, 31);
                    mapIndexWithCM.put(x,'0');
                    mapIndexWithGM.put(x,'0');
                    if(x != 5){
                        if(offerStartDate >= startDate && offerStartDate <= endDate && offerEndDate >= startDate && offerEndDate <= endDate){
                            calCM = calCM + (perDayCM*daysQuote).setScale(2);
                            calGM = calGM + (perDayGM*daysQuote).setScale(2);
                            mapIndexWithCM.put(x,String.valueOf((perDayCM*daysQuote).setScale(2)));
                            mapIndexWithGM.put(x,String.valueOf((perDayGM*daysQuote).setScale(2)));
                        }else if(offerStartDate>=startDate && offerStartDate <= endDate && offerEndDate >= endDate) {
                            Integer daysQuote1 = offerStartDate.daysBetween(endDate) + 1;
                            calCM = calCM + (perDayCM*daysQuote1).setScale(2);
                            calGM = calGM + (perDayGM*daysQuote1).setScale(2);
                            mapIndexWithCM.put(x,String.valueOf((perDayCM*daysQuote1).setScale(2)));
                            mapIndexWithGM.put(x,String.valueOf((perDayGM*daysQuote1).setScale(2)));
                        }else if(offerEndDate>=startDate && offerEndDate <= endDate && offerStartDate<= startDate) {
                            Integer daysQuote2 = startDate.daysBetween(offerEndDate) + 1;
                            calCM = calCM + (perDayCM*daysQuote2).setScale(2);
                            calGM = calGM + (perDayGM*daysQuote2).setScale(2);
                            mapIndexWithCM.put(x,String.valueOf((perDayCM*daysQuote2).setScale(2)));
                            mapIndexWithGM.put(x,String.valueOf((perDayGM*daysQuote2).setScale(2)));
                        }else if(offerEndDate >= endDate && offerStartDate<= startDate){
                            Integer daysQuote3 = startDate.daysBetween(endDate) + 1;
                            calCM = calCM + (perDayCM*daysQuote3).setScale(2);
                            calGM = calGM + (perDayGM*daysQuote3).setScale(2);
                            mapIndexWithCM.put(x,String.valueOf((perDayCM*daysQuote3).setScale(2)));
                            mapIndexWithGM.put(x,String.valueOf((perDayGM*daysQuote3).setScale(2)));
                        }

                        if(x == -1 && offerStartDate<= startDate){
                            Integer daysQuote4 = offerStartDate.daysBetween(startDate) + 1;
                            calCM = calCM + (perDayCM*daysQuote4).setScale(2);
                            calGM = calGM + (perDayGM*daysQuote4).setScale(2);
                            mapIndexWithCM.put(x,String.valueOf((perDayCM*daysQuote4).setScale(2)));
                            mapIndexWithGM.put(x,String.valueOf((perDayGM*daysQuote4).setScale(2)));
                        }
                    }else{
						system.debug('===startDate'+startDate+'=====offerStartDate'+offerStartDate+'===endDate'+endDate+'===offerEndDate'+offerEndDate);
						if((startDate >= offerStartDate && startDate <= offerEndDate && endDate >= offerStartDate && endDate <= offerEndDate )){
							System.debug('In else loop');
							system.debug('====qt: '+cont.vlocity_cmt__QuoteId__r.id+'==='+x+'=====conMar'+conMar+'===calCM'+calCM);
							system.debug('====qt: '+cont.vlocity_cmt__QuoteId__r.id+'==='+x+'=====groMar'+groMar+'===calCM'+calCM);
							//if((conMar - calCM).setScale(2) > 1.0)
							{
								mapIndexWithCM.put(x,String.valueOf((conMar - calCM).setScale(2)));
							}

							//if((groMar - calGM).setScale(2) > 1.0)
							{
								mapIndexWithGM.put(x,String.valueOf((groMar - calGM).setScale(2)));
							}
						}
                    }
                }

                String preYearCM = mapIndexWithCM.get(-1);
                String curYearCM=mapIndexWithCM.get(0);
                String curYearCMP1=mapIndexWithCM.get(1);
                String curYearCMP2=mapIndexWithCM.get(2);
                String curYearCMP3=mapIndexWithCM.get(3);
                String curYearCMP4=mapIndexWithCM.get(4);
                String curYearCMP5=mapIndexWithCM.get(5);
                String preYearGM = mapIndexWithGM.get(-1);
                String curYearGM=mapIndexWithGM.get(0);
                String curYearGMP1=mapIndexWithGM.get(1);
                String curYearGMP2=mapIndexWithGM.get(2);
                String curYearGMP3=mapIndexWithGM.get(3);
                String curYearGMP4=mapIndexWithGM.get(4);
                String curYearGMP5=mapIndexWithGM.get(5);

                String netMargin = (cont.vlocity_cmt__QuoteId__r.SWAN_Quote_for_Fuel_Type__c == 'Electricity'? String.ValueOf(conMar - (conVol/1000 * 1.03).setScale(2)) : String.ValueOf(conMar - (conVol/1000 * 0.34).setScale(2)));
                String ConVolume = String.ValueOf(conVol);
                
                String signdate = contractidToContractSignDate.get(cont.Id).format('dd/MM/YYYY');
                String weekNumber = contractidToContractSignDate.get(cont.Id).format('w');
                String monthNumber = String.ValueOf(contractidToContractSignDate.get(cont.Id).month());
                String UnitMargin = '0.0';

                if(conVol != 0){
                    UnitMargin = String.ValueOf((groMar / (conVol/1000)).setScale(2));
                }

                String payTerm = cont.SWAN_Payment_Term__c.split(' ')[0];
                String conSpend ='0';

                if(cont.vlocity_cmt__QuoteId__r.SWAN_Contract_Spend__c != null){
                    conSpend = String.ValueOf(cont.vlocity_cmt__QuoteId__r.SWAN_Contract_Spend__c);
                }

                String segment='';

                if(cont.vlocity_cmt__QuoteId__c != null && cont.vlocity_cmt__QuoteId__r.vlocity_cmt__PriceListId__c != null){

                    if(cont.vlocity_cmt__QuoteId__r.vlocity_cmt__PriceListId__r.Name == label.Swan_Enterprise_Price_List){
                        segment = segmentVal.Enterprise_Segment__c;
                    }else if(cont.vlocity_cmt__QuoteId__r.vlocity_cmt__PriceListId__r.Name == label.Swan_I_C_Price_List){
                        segment = segmentVal.WINS_I_C_Segment__c;
                    }
                }
                CSVData +='"'+String.ValueOf(cont.vlocity_cmt__QuoteId__r.QuoteNumber)+SEP+NUL+SEP+NUL+SEP+
                cont.vlocity_cmt__QuoteId__r.Account.Name+SEP+cont.vlocity_cmt__QuoteId__r.SWAN_Quote_for_Fuel_Type__c+
                SEP+productClass+SEP+signdate+SEP+offerStartDate.format()+SEP+offerEndDate.format()+SEP+(cont.vlocity_cmt__OpportunityId__c != null 
                && recTypeIdRenewal != null && 
                cont.vlocity_cmt__OpportunityId__r.RecordTypeId == recTypeIdRenewal?'Renewal':(cont.vlocity_cmt__OpportunityId__c != null && 
                recTypeIdUpgrade != null && cont.vlocity_cmt__OpportunityId__r.RecordTypeId == recTypeIdUpgrade?'Upgrade':'Acquisition'))+
                SEP+NUL+SEP+NUL+SEP+'0'+SEP+NUL+SEP+NUL+SEP+brokerName+SEP+NUL+SEP+cont.CompanySigned.Name+SEP+NUL+SEP+NUL+SEP+
                String.ValueOf(offerDuration)+SEP+ConVolume+SEP+AnnualVol+SEP+conSpend+SEP+netMargin+SEP+String.valueOf(brokerCommission)+SEP+
                weekNumber+SEP+monthNumber+SEP+VolBand+SEP+String.ValueOf(cont.vlocity_cmt__QuoteId__r.SWAN_Number_of_Service_Points__c)+SEP+NUL+SEP+
                'Salesforce'+SEP+NUL+SEP+NUL+SEP+UnitMargin+SEP+NUL+SEP+String.ValueOf(conMar)+SEP+preYearCM+SEP+curYearCM+SEP+curYearCMP1+SEP+
                curYearCMP2+SEP+curYearCMP3+SEP+curYearCMP4+SEP+curYearCMP5+SEP+String.ValueOf(groMar)+SEP+NUL+SEP+segment+SEP+NUL+SEP+NUL+SEP+
                NUL+SEP+NUL+SEP+NUL+SEP+NUL+SEP+'Secured Win'+SEP+NUL+SEP+NUL+SEP+NUL+SEP+NUL+SEP+NUL+SEP+NUL+SEP+String.ValueOf(groMar)+SEP+preYearGM+
                SEP+curYearGM+SEP+curYearGMP1+SEP+curYearGMP2+SEP+curYearGMP3+SEP+curYearGMP4+SEP+curYearGMP5+SEP+String.ValueOf(groMar)+SEP+
                AAHEDC_SAP_PASSTH+SEP+BSUOS_HH_SAP_PASSTH+SEP+DUOS_HH_UNIT_CHARGE_SAP_PASSTH+SEP+FEED_IN_TARIFF_SAP_PASSTH+SEP+REN_OBLIG_SAP_PASSTH+SEP+
                CFD_SAP_PASSTH+SEP+TNUOS_HH_SAP_PASSTH+SEP+cont.SWAN_Payment_Method__c+SEP+payTerm+SEP+prodName+'"\n'; 
            }

            // Start -- For Site Addition
            for(Quote qt :liveQuoteList){
                if(qt.SWAN_Site_Addition_Parent__c != null && mapContractsByQuoteId.containsKey(qt.SWAN_Site_Addition_Parent__c)) {
                    String brokerName = '';
                    if(qt.SWAN_Sales_Channel__c == 'Broker' && qt.SWAN_Broker__c != null){
                        brokerName = qt.SWAN_Broker__r.Name;
                    }else{
                        brokerName = 'Not Involved';
                    }
                        
                    String prodName = '';
                    if(quoteProdMap.size()>0 && quoteProdMap.containsKey(qt.Id)){
                        prodName = quoteProdMap.get(qt.Id);
                    }
                    
                    Integer offerDuration = 0;
                    if(!String.isBlank(qt.SWAN_Offer_Duration__c)){
                        String[] offerD = qt.SWAN_Offer_Duration__c.split(' ');
                        
                        if(offerD[0].isNumeric()){
                            offerDuration = Integer.ValueOf(offerD[0]);
                        }
                    }

                    Decimal qtVol = 0.0;
                    
                    if(qt.SWAN_Contract_Volume_KWh__c != null){
                        qtVol = qt.SWAN_Contract_Volume_KWh__c;
                    }

                    Date offerStartDate = qt.SWAN_Offer_Start_Date__c;
                    Date offerEndDate = qt.SWAN_Offer_End_Date__c;
                    Integer durVal = offerStartDate.daysBetween(offerEndDate) + 1;
                    Integer AnnVol = MATH.round(((qtVol) / (durVal))*365); 
                    String AnnualVol = String.ValueOf(AnnVol);
                    String VolBand = '';
                    Decimal qtMar= 0.0;
                    
                    if(qt.SWAN_Contribution_Margin__c != null){
                        qtMar = qt.SWAN_Contribution_Margin__c;
                    }

                    Decimal brokerCommission= 0;
                    
                    if(qt.SWAN_Broker_Commission__c != null){
                        brokerCommission = qt.SWAN_Broker_Commission__c;
                    }

                    Decimal groMar = 0.0;

                    if(qt.SWAN_Gross_Margin__c != null){
                        groMar = qt.SWAN_Gross_Margin__c;
                    }

                    for(Annual_Volume_Bands__mdt band : AnnualBandsList){
                        
                        if(AnnVol >= band.Annual_volume_Kwh_From__c &&  band.Annual_volume_kWh_To__c != Null && AnnVol <= band.Annual_volume_kWh_To__c){
                            VolBand = band.Band__c;
                        }else if(AnnVol >= band.Annual_volume_Kwh_From__c && band.Annual_volume_kWh_To__c == null){
                            VolBand = band.Band__c;
                        }
                    }
                    
                    String productClass= '';
                    if(quoteidToServicePts.containsKey(qt.Id) && qt.SWAN_Quote_for_Fuel_Type__c == 'Gas'){
                        for(Id serPts : quoteidToServicePts.get(qt.Id)){
                            if(servicePointMap.containsKey(serPts)){
                                if(servicePointMap.get(serPts).SWAN_Product_Class__c == '1' || servicePointMap.get(serPts).SWAN_Product_Class__c == '2'){
                                    if(productClass == 'NDM'){ 
                                        productClass =''; break;
                                    }
                                    
                                    productClass = 'DM';
                                }else if (servicePointMap.get(serPts).SWAN_Product_Class__c == '3' || servicePointMap.get(serPts).SWAN_Product_Class__c == '4'){
                                    if(productClass == 'DM'){ 
                                        productClass =''; break;
                                    }else {
                                        productClass = 'NDM';
                                    }
                                }
                            }
                        }
                    }
                  // Start -- Set NHH or HH Product Class (Electricity)
                  else if(quoteidToServicePts.containsKey(qt.Id) && qt.SWAN_Quote_for_Fuel_Type__c == 'Electricity')
                  {
                      for(Id serPts : quoteidToServicePts.get(qt.Id))
                      {
                          if(servicePointMap.containsKey(serPts))
                          {
                            if(servicePointMap != null && servicePointMap.containsKey(serPts) && servicePointMap.get(serPts).SWAN_Measurement_Class_Ovrd__c == null )
                                {
                                  if(servicePointMap.get(serPts).vlocity_cmt__ServiceType__c == 'Electricity' && (servicePointMap.get(serPts).SWAN_Measurement_Class__c == 'C' || servicePointMap.get(serPts).SWAN_Measurement_Class__c == 'D' || servicePointMap.get(serPts).SWAN_Measurement_Class__c == 'E' || servicePointMap.get(serPts).SWAN_Measurement_Class__c == 'F' || servicePointMap.get(serPts).SWAN_Measurement_Class__c == 'G'))
                                    {
                                    productClass = 'HH'; break;}
                                    else {productClass = 'NHH';}
                                }
                   
                          else if(servicePointMap != null && servicePointMap.containsKey(serPts) && servicePointMap.get(serPts).SWAN_Measurement_Class_Ovrd__c != null )
                          {
                              if(servicePointMap.get(serPts).vlocity_cmt__ServiceType__c == 'Electricity' && (servicePointMap.get(serPts).SWAN_Measurement_Class_Ovrd__c == 'C' || servicePointMap.get(serPts).SWAN_Measurement_Class_Ovrd__c == 'D' || servicePointMap.get(serPts).SWAN_Measurement_Class_Ovrd__c == 'E' || servicePointMap.get(serPts).SWAN_Measurement_Class_Ovrd__c == 'F' || servicePointMap.get(serPts).SWAN_Measurement_Class_Ovrd__c == 'G'))
                                {
                                productClass = 'HH'; break;}
                                else {productClass = 'NHH';}
                          }
                          }
                      }
                   }
                  // End -- -- Set NHH or HH Product Class (Electricity)                            
                 // Start -- -- Set Pass through options (Electricity)         
                    Map<Id, Quote> mapQuotesByServicePointId = new Map<Id, Quote>();
                    /*for(Quote q : [Select Id, SWAN_Non_Commodity_Passthrough__c, SWAN_Service_Point__c, SWAN_Passthrough_Option__c from Quote where SWAN_Service_Point__c in :mapQuotesByServicePoint]){
                        mapQuotesByServicePointId.put(q.SWAN_Service_Point__c, q);            
                    }   */ 
                    String AAHEDC_SAP_PASSTH;
                    String BSUOS_HH_SAP_PASSTH;
                    String DUOS_HH_UNIT_CHARGE_SAP_PASSTH;
                    String FEED_IN_TARIFF_SAP_PASSTH;
                    String REN_OBLIG_SAP_PASSTH;
                    String CFD_SAP_PASSTH;
                    String TNUOS_HH_SAP_PASSTH; 
                    List<Id> lstSerPts = new List<Id>();
                    if(qt.Id != null){
                        lstSerPts = new List<Id>(quoteidToServicePts.get(qt.Id));                       
                    }           
                     for(Id serPts : lstSerPts)      
                     {
                      if(servicePointMap.get(serPts).vlocity_cmt__ServiceType__c == 'Electricity' && (servicePointMap.get(serPts).SWAN_Measurement_Class__c != 'A' || servicePointMap.get(serPts).SWAN_Measurement_Class__c != 'B') && (mapQuotesByServicePoint.get(serPts).SWAN_Non_Commodity_Passthrough__c != null || mapQuotesByServicePoint.get(serPts).SWAN_Non_Commodity_Passthrough__c != null))
                      {
                          if(mapQuotesByServicePointId.get(serPts).SWAN_Non_Commodity_Passthrough__c == 'Full Pass through')
                            {
                                AAHEDC_SAP_PASSTH = 'TRUE';
                                BSUOS_HH_SAP_PASSTH = 'TRUE';
                                DUOS_HH_UNIT_CHARGE_SAP_PASSTH = 'TRUE';
                                FEED_IN_TARIFF_SAP_PASSTH = 'TRUE';
                                REN_OBLIG_SAP_PASSTH = 'TRUE';
                                CFD_SAP_PASSTH = 'TRUE';
                                TNUOS_HH_SAP_PASSTH = 'TRUE';
                                break;
                            }               
                           else if(mapQuotesByServicePointId.get(serPts).SWAN_Non_Commodity_Passthrough__c == 'Fixed')
                             {
                                AAHEDC_SAP_PASSTH = 'FALSE';
                                BSUOS_HH_SAP_PASSTH = 'FALSE';
                                DUOS_HH_UNIT_CHARGE_SAP_PASSTH = 'FALSE';
                                FEED_IN_TARIFF_SAP_PASSTH = 'FALSE';
                                REN_OBLIG_SAP_PASSTH = 'FALSE';
                                CFD_SAP_PASSTH = 'FALSE';
                                TNUOS_HH_SAP_PASSTH = 'FALSE';
                                break;
                            }
                           else if(mapQuotesByServicePointId.get(serPts).SWAN_Non_Commodity_Passthrough__c == 'Pass Through')
                             {
                                AAHEDC_SAP_PASSTH = (productClass == 'HH' && mapQuotesByServicePointId.get(serPts).SWAN_Passthrough_Option__c.contains('AAHEDC')) ? 'TRUE' : 'FALSE';
                                BSUOS_HH_SAP_PASSTH = (productClass == 'HH' && mapQuotesByServicePointId.get(serPts).SWAN_Passthrough_Option__c.contains('BSUoS + RCRC')) ? 'TRUE' : 'FALSE';
                                DUOS_HH_UNIT_CHARGE_SAP_PASSTH = (productClass == 'HH' && mapQuotesByServicePointId.get(serPts).SWAN_Passthrough_Option__c.contains('DUoS')) ? 'TRUE' : 'FALSE';
                                FEED_IN_TARIFF_SAP_PASSTH = (productClass == 'HH' && mapQuotesByServicePointId.get(serPts).SWAN_Passthrough_Option__c.contains('Feed in Tariff')) ? 'TRUE' : 'FALSE';
                                REN_OBLIG_SAP_PASSTH = (productClass == 'HH' && mapQuotesByServicePointId.get(serPts).SWAN_Passthrough_Option__c.contains('Renewable Obligation')) ? 'TRUE' : 'FALSE';
                                CFD_SAP_PASSTH = (productClass == 'HH' && mapQuotesByServicePointId.get(serPts).SWAN_Passthrough_Option__c.contains('Contracts for difference')) ? 'TRUE' : 'FALSE';
                                TNUOS_HH_SAP_PASSTH = (productClass == 'HH' && mapQuotesByServicePointId.get(serPts).SWAN_Passthrough_Option__c.contains('TNUoS')) ? 'TRUE' : 'FALSE';
                                break;
                            }
                           else
                           {
                                AAHEDC_SAP_PASSTH = 'FALSE';
                                BSUOS_HH_SAP_PASSTH = 'FALSE';
                                DUOS_HH_UNIT_CHARGE_SAP_PASSTH = 'FALSE';
                                FEED_IN_TARIFF_SAP_PASSTH = 'FALSE';
                                REN_OBLIG_SAP_PASSTH = 'FALSE';
                                CFD_SAP_PASSTH = 'FALSE';
                                TNUOS_HH_SAP_PASSTH = 'FALSE';
                                break;
                            }
                         }
                       else if (servicePointMap.get(serPts).vlocity_cmt__ServiceType__c == 'Electricity' && (servicePointMap.get(serPts).SWAN_Measurement_Class__c == 'A' || servicePointMap.get(serPts).SWAN_Measurement_Class__c == 'B'))
                        {
                                AAHEDC_SAP_PASSTH = 'FALSE';
                                BSUOS_HH_SAP_PASSTH = 'FALSE';
                                DUOS_HH_UNIT_CHARGE_SAP_PASSTH = 'FALSE';
                                FEED_IN_TARIFF_SAP_PASSTH = 'FALSE';
                                REN_OBLIG_SAP_PASSTH = 'FALSE';
                                CFD_SAP_PASSTH = 'FALSE';
                                TNUOS_HH_SAP_PASSTH = 'FALSE';
                                break;
                        }   
                       else if (servicePointMap.get(serPts).vlocity_cmt__ServiceType__c == 'Gas')
                        {
                                AAHEDC_SAP_PASSTH = '';
                                BSUOS_HH_SAP_PASSTH = '';
                                DUOS_HH_UNIT_CHARGE_SAP_PASSTH = '';
                                FEED_IN_TARIFF_SAP_PASSTH = '';
                                REN_OBLIG_SAP_PASSTH = '';
                                CFD_SAP_PASSTH = '';
                                TNUOS_HH_SAP_PASSTH = '';
                                break;
                         }  
                        else
                        {
                                AAHEDC_SAP_PASSTH = 'FALSE';
                                BSUOS_HH_SAP_PASSTH = 'FALSE';
                                DUOS_HH_UNIT_CHARGE_SAP_PASSTH = 'FALSE';
                                FEED_IN_TARIFF_SAP_PASSTH = 'FALSE';
                                REN_OBLIG_SAP_PASSTH = 'FALSE';
                                CFD_SAP_PASSTH = 'FALSE';
                                TNUOS_HH_SAP_PASSTH = 'FALSE';
                                break;
                        }   
                     }                                   
                    // End -- -- Set Pass through options (Electricity)
                                 
                    Date curdate= system.today();
                    Integer daysQuote = offerStartDate.daysBetween(offerEndDate) + 1;
                    Decimal perDayCM= qtMar / daysQuote;
                    Decimal perDayGM= groMar / daysQuote;
                    Map<Integer,String> mapIndexWithCM = new Map<Integer,String>();
                    Map<Integer,String> mapIndexWithGM = new Map<Integer,String>();
                    
                    Decimal calGM = 0.0;
                    Decimal calCM = 0.0;
                    
                    for(Integer x=-1;x<=5;x++){

                        Date dateRange = curdate.addYears(x);
                        Date startDate = Date.newInstance(dateRange.year(), 1, 1);
                        Date endDate = Date.newInstance(dateRange.year(), 12, 31);
                        mapIndexWithCM.put(x,'0');
                        mapIndexWithGM.put(x,'0');

                        if(x != 5){
                            if(offerStartDate >= startDate && offerStartDate <= endDate && offerEndDate >= startDate && offerEndDate <= endDate){
                                calCM = calCM + (perDayCM*daysQuote).setScale(2);
                                calGM = calGM + (perDayGM*daysQuote).setScale(2);
                                mapIndexWithCM.put(x,String.valueOf((perDayCM*daysQuote).setScale(2)));
                                mapIndexWithGM.put(x,String.valueOf((perDayGM*daysQuote).setScale(2)));
                            }else if(offerStartDate>=startDate && offerStartDate <= endDate && offerEndDate >= endDate){
                                Integer daysQuote1 = offerStartDate.daysBetween(endDate) + 1;
                                calCM = calCM + (perDayCM*daysQuote1).setScale(2);
                                calGM = calGM + (perDayGM*daysQuote1).setScale(2);
                                mapIndexWithCM.put(x,String.valueOf((perDayCM*daysQuote1).setScale(2)));
                                mapIndexWithGM.put(x,String.valueOf((perDayGM*daysQuote1).setScale(2)));
                            }else if(offerEndDate>=startDate && offerEndDate <= endDate && offerStartDate<= startDate){
                                Integer daysQuote2 = startDate.daysBetween(offerEndDate) + 1;
                                calCM = calCM + (perDayCM*daysQuote2).setScale(2);
                                calGM = calGM + (perDayGM*daysQuote2).setScale(2);
                                mapIndexWithCM.put(x,String.valueOf((perDayCM*daysQuote2).setScale(2)));
                                mapIndexWithGM.put(x,String.valueOf((perDayGM*daysQuote2).setScale(2)));
                            }else if(offerEndDate >= endDate && offerStartDate<= startDate){
                                calCM = calCM + (perDayCM*365).setScale(2);
                                calGM = calGM + (perDayGM*365).setScale(2);
                                mapIndexWithCM.put(x,String.valueOf((perDayCM*365).setScale(2)));
                                mapIndexWithGM.put(x,String.valueOf((perDayGM*365).setScale(2)));
                            }else if(x == -1 && offerStartDate<= startDate){
                                Integer daysQuote3 = offerStartDate.daysBetween(startDate) + 1;
                                calCM = calCM + (perDayCM*daysQuote3).setScale(2);
                                calGM = calGM + (perDayGM*daysQuote3).setScale(2);
                                mapIndexWithCM.put(x,String.valueOf((perDayCM*daysQuote3).setScale(2)));
                                mapIndexWithGM.put(x,String.valueOf((perDayGM*daysQuote3).setScale(2)));
                            }
                        }else{
							system.debug('===startDate'+startDate+'=====offerStartDate'+offerStartDate+'===endDate'+endDate+'===offerEndDate'+offerEndDate);
							if((startDate >= offerStartDate && startDate <= offerEndDate && endDate >= offerStartDate && endDate <= offerEndDate )){
								System.debug('In else loop');
								system.debug('====qt: '+qt.id+'==='+x+'=====qtMar'+qtMar+'===calCM'+calCM);
								system.debug('====qt: '+qt.id+'==='+x+'=====groMar'+groMar+'===calCM'+calCM);
								mapIndexWithCM.put(x,String.valueOf((qtMar - calCM).setScale(2)));
								mapIndexWithGM.put(x,String.valueOf((groMar - calGM).setScale(2)));
							}
                        }
                    }

                    String preYearCM = mapIndexWithCM.get(-1);
                    String curYearCM=mapIndexWithCM.get(0);
                    String curYearCMP1=mapIndexWithCM.get(1);
                    String curYearCMP2=mapIndexWithCM.get(2);
                    String curYearCMP3=mapIndexWithCM.get(3);
                    String curYearCMP4=mapIndexWithCM.get(4);
                    String curYearCMP5=mapIndexWithCM.get(5);
                    String preYearGM = mapIndexWithGM.get(-1);
                    String curYearGM=mapIndexWithGM.get(0);
                    String curYearGMP1=mapIndexWithGM.get(1);
                    String curYearGMP2=mapIndexWithGM.get(2);
                    String curYearGMP3=mapIndexWithGM.get(3);
                    String curYearGMP4=mapIndexWithGM.get(4);
                    String curYearGMP5=mapIndexWithGM.get(5);

                    String netMargin = (qt.SWAN_Quote_for_Fuel_Type__c == 'Electricity'? String.ValueOf(qtMar - (qtVol/1000 * 1.03).setScale(2)) : String.ValueOf(qtMar - (qtVol/1000 * 0.34).setScale(2)));
                    String qtVolume = String.ValueOf(qtVol);
                    
                    String signdate = '';
                    String weekNumber = '';
                    String monthNumber = '';

                    if(quoteIdToAcceptedDate.get(qt.Id) != null){
                        signdate = quoteIdToAcceptedDate.get(qt.Id).format('dd/MM/YYYY');
                        weekNumber = quoteIdToAcceptedDate.get(qt.Id).format('w');
                        monthNumber = String.ValueOf(quoteIdToAcceptedDate.get(qt.Id).month());
                    }

                    String UnitMargin = '0.0';

                    if(qtVol != 0){
                        UnitMargin = String.ValueOf((groMar / (qtVol/1000)).setScale(2));
                    }

                    String payTerm = qt.SWAN_Payment_Term__c.split(' ')[0];
                    String qtSpend ='0';

                    if(qt.SWAN_Contract_Spend__c != null){
                        qtSpend = String.ValueOf(qt.SWAN_Contract_Spend__c);
                    }
                    
                    String companySignedBy = '';
                    String segment='';
                    companySignedBy = mapContractsByQuoteId.get(qt.SWAN_Site_Addition_Parent__c).Owner.Name;
                    Contract c = mapContractsByQuoteId.get(qt.SWAN_Site_Addition_Parent__c); 
                    
                    if(c.vlocity_cmt__PriceListId__c != null){
                        if(c.vlocity_cmt__PriceListId__r.Name == label.Swan_Enterprise_Price_List){
                            segment = segmentVal.Enterprise_Segment__c;
                        } else if(c.vlocity_cmt__PriceListId__r.Name == label.Swan_I_C_Price_List){
                            segment = segmentVal.WINS_I_C_Segment__c;
                        }
                    }

                    CSVData +='"'+String.ValueOf(qt.QuoteNumber)+SEP+NUL+SEP+NUL+SEP+qt.Account.Name+SEP+qt.SWAN_Quote_for_Fuel_Type__c+SEP+productClass+SEP+signdate+SEP+offerStartDate.format()+SEP+offerEndDate.format()+SEP+'Site Addition'+SEP+NUL+SEP+NUL+SEP+'0'+SEP+NUL+SEP+NUL+SEP+brokername+SEP+NUL+SEP+companySignedBy+SEP+NUL+SEP+NUL+SEP+String.ValueOf(offerDuration)+SEP+qtVolume+SEP+AnnualVol+SEP+qtSpend+SEP+netMargin+SEP+String.valueOf(brokerCommission)+SEP+weekNumber+SEP+monthNumber+SEP+VolBand+SEP+String.ValueOf(qt.SWAN_Number_of_Service_Points__c)+SEP+NUL+SEP+'Salesforce'+SEP+NUL+SEP+NUL+SEP+UnitMargin+SEP+NUL+SEP+String.ValueOf(qtMar)+SEP+preYearCM+SEP+curYearCM+SEP+curYearCMP1+SEP+curYearCMP2+SEP+curYearCMP3+SEP+curYearCMP4+SEP+curYearCMP5+SEP+String.ValueOf(groMar)+SEP+NUL+SEP+segment+SEP+NUL+SEP+NUL+SEP+NUL+SEP+NUL+SEP+NUL+SEP+NUL+SEP+'Secured Win'+SEP+NUL+SEP+NUL+SEP+NUL+SEP+NUL+SEP+NUL+SEP+NUL+SEP+String.ValueOf(groMar)+SEP+preYearGM+SEP+curYearGM+SEP+curYearGMP1+SEP+curYearGMP2+SEP+curYearGMP3+SEP+curYearGMP4+SEP+curYearGMP5+SEP+String.ValueOf(groMar)+SEP+AAHEDC_SAP_PASSTH+SEP+BSUOS_HH_SAP_PASSTH+SEP+DUOS_HH_UNIT_CHARGE_SAP_PASSTH+SEP+FEED_IN_TARIFF_SAP_PASSTH+SEP+REN_OBLIG_SAP_PASSTH+SEP+CFD_SAP_PASSTH+SEP+TNUOS_HH_SAP_PASSTH+SEP+qt.SWAN_Payment_Method__c+SEP+payTerm+SEP+prodName+'"\n';
                }
            }
        }
        writeFileAttachment(CSVData);
    }
    
    public void finish(Database.BatchableContext BC){
        List<Attachment> lstAttachments = getAttachmentListOrderedByRecentFirst();

        if(lstAttachments!= null && lstAttachments.size() != 0){

            Attachment latestAttachment = lstAttachments.get(0);

            if(lstAttachments.size() == 1){
                latestAttachment.Name+='.CSV';
            }else{
                latestAttachment.Name+=' - Last File'+'.CSV';
            }

            update latestAttachment;

            Task userTask = new Task();
            userTask.OwnerId = latestAttachment.OwnerId;
            userTask.Subject = 'Wins Report Ready';
            userTask.priority= 'Normal';
            userTask.status = 'Open';
            userTask.ActivityDate = System.Today();
            insert userTask;
        }
        
    }


    //Fill final list with wrapper objects ready to be written to output XLS
    private void writeFileAttachment(String csvLines){

        List<Attachment> lstAttachments = getAttachmentListOrderedByRecentFirst();
        String header = SWAN_BatchGenerateCSVForWins.getHeader(); //Old way of getting the header with fixed values for years : Label.SWAN_WinsReportHeaderValues+'\n';

        if(lstAttachments == null || lstAttachments.size() == 0){
            createAttachment(header+csvLines);
        }else{
             
            Attachment latestAttachment = lstAttachments.get(0);
            
            if(latestAttachment.BodyLength+csvLines.length() < MAX_FILE_SIZE){
                latestAttachment.Body=Blob.valueOf(latestAttachment.Body.toString() + csvLines);
                update latestAttachment;
            }else{
                latestAttachment.Name = latestAttachment.Name+' - File ' + (++numberOfFiles) + '.CSV';
                update latestAttachment;
                createAttachment(header + csvLines);
            }
        }
    }

    private void createAttachment(String csvLines){
        SWAN_Custom_Report__c pipelineReport = new SWAN_Custom_Report__c(Name = fileName, SWAN_Report_Type__c = REPORT_TYPE);

        if (Schema.sObjectType.SWAN_Custom_Report__c.fields.SWAN_Report_Type__c.isCreateable()){
            insert pipelineReport;
        }
        
        try{
            if(Schema.sObjectType.Attachment.fields.Body.isCreateable()){
                insert new Attachment(Name = fileName, 
                                      ParentId = pipelineReport.Id, 
                                      Body = Blob.valueOf(csvLines)); 
            }
        }catch(Exception e){
            System.debug(e.getMessage());
        }        
    }

    private List<Attachment> getAttachmentListOrderedByRecentFirst(){
        String fileNameQueryFilter = fileName+'%';
        List<Attachment> lstAttachments = [SELECT id, Name, ParentId, OwnerId, Body, BodyLength FROM Attachment WHERE Name LIKE :fileNameQueryFilter ORDER BY CreatedDate DESC];
        if(lstAttachments.size() == 0){
            return null;
        }else {
            return lstAttachments;
        }
    }

    public static String getHeader(){
        String header = 'Offer_ID,Tender_ID,TenderGroupID,Customer,Fuel,Product,Date_Won,Start_Date,End_Date,Deal_Type,Historic?,Evergreen,Flex,Green_Prem_Method,Green_Prem_Percentage,Broker,Broker_Class,Salesperson,Sales_Team,Hub,Duration,Contract_Volume,Annual_Volume,Contract_Spend,Net_Margin,Broker_Commission,Week_Won,Month_Won,Volume_Band,Sites,This_Week?,Data_Source,Adjustment?,Contract_Returned,Unit Margin,LEC_Uplift,CM,<=';
        Integer currentYear = System.today().year();
        
        header+=(currentYear-1)+',';
        header+=currentYear+',';
        header+=(currentYear+1)+',';
        header+=(currentYear+2)+',';
        header+=(currentYear+3)+',';
        header+=(currentYear+4)+',';
        header+='>='+(currentYear+5)+',';
        header+= 'GM Plus VHM,Service Level,Segment,Description,Contract_Upload,Contract_Completed,Docusign_Status,DD_Mandate_Uploaded,PreRegistration,Win_Status,Status_Reason,Comments,VHM,FAF,WCM,WCM_2019,Gross_Margin,<=';
        
        header+=(currentYear-1)+'_GM,';
        header+=currentYear+'_GM,';
        header+=(currentYear+1)+'_GM,';
        header+=(currentYear+2)+'_GM,';
        header+=(currentYear+3)+'_GM,';
        header+=(currentYear+4)+'_GM,';
        header+='>='+(currentYear+5)+'_GM,';

        header+= 'GM_VHM_WarChest,AAHEDC_SAP_PASSTH,BSUOS_HH_SAP_PASSTH,DUOS_HH_UNIT_CHARGE_SAP_PASSTH,FEED_IN_TARIFF_SAP_PASSTH,REN_OBLIG_SAP_PASSTH,CFD_SAP_PASSTH,TNUOS_HH_SAP_PASSTH,PAYMENT_METHOD,PAYMENT_DAYS,PRODUCT_NAME\n';
        return header;
    }
}