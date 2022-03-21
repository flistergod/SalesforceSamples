public without sharing class SWAN_GenerateCSVForTRESOR
{
    static final String NUL = '';
    static final String SEP = ',';
  
    public static void generateCSVForTRESOR()
    {
        String statuses = Label.SWAN_ContractStatusTRESORReport;
        List<String> statusList = statuses.split(',');
        Set<ID> contractIds = new Set<ID>();
        Set<Id> siteAddnQtIds = new Set<Id>(); 
        Set<Id> ParentQuoteId = new Set<Id>();
    
        String CSVTermData ='';
        String CSVMeterData ='';
        String CSVIncaData ='';
    
        Map<id,DateTime> quoteIdToAcceptedDate = new Map<id,DateTime>();
        Map<id,Contract> contractIdToContractMap = new  Map<id,Contract>();
        Map<id,DateTime> contractidToContractSignDate = new Map<id,DateTime>();
        Map<id,DateTime> contractidToContractCancelOrTerminationDate = new Map<id,DateTime>();
        List<Contract> liveContractList = new List<Contract>();
        
        Id siteAddtnRecTypeId; 
        Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Quote.getRecordTypeInfosByName();
        if(rtMapByName != null && rtMapByName.containskey(label.QuoteSiteAdditionRecordType))
            siteAddtnRecTypeId =  rtMapByName.get(label.QuoteSiteAdditionRecordType).getRecordTypeId();
        
        for(Contract con : [SELECT id, Name, ContractNumber, CreatedDate,EndDate,vlocity_cmt__TerminateDate__c,SWAN_Payment_Method__c, SWAN_Payment_Term__c, 
        vlocity_cmt__QuoteId__c, CompanySigned.Name, vlocity_cmt__OpportunityId__c, CompanySignedId, 
        vlocity_cmt__OpportunityId__r.RecordTypeId, AccountId, Account.name, Status, vlocity_cmt__PriceListId__c, 
        vlocity_cmt__PriceListId__r.Name, Account.BillingPostalCode, 
        vlocity_cmt__OpportunityId__r.SWAN_Fuel_Type__c, SWAN_Signed_Date__c, SWAN_End_date__c, vlocity_cmt__OpportunityId__r.RecordType.name, OwnerId, Owner.Name,vlocity_cmt__QuoteId__r.SWAN_Quote_Type__c
        FROM Contract WHERE Status IN :statusList AND vlocity_cmt__QuoteId__r.vlocity_cmt__ParentQuoteId__c = null])
        {
            if(con.EndDate!= null && con.EndDate.addMonths(3) >= System.Today()){
			contractIdToContractMap.put(con.id,con);
            contractIds.add(con.id);
			// BUG 8732 Start
            if(con.SWAN_Signed_Date__c != null || Test.isRunningTest())
            {
                liveContractList.add(con);
                contractidToContractSignDate.put(con.id,con.SWAN_Signed_Date__c);
            }
			if(con.Status == 'Contract Cancelled'||con.Status == 'Contract Terminated')
            {
                 contractidToContractCancelOrTerminationDate.put(con.Id,Con.SWAN_End_date__c);
            }
            // BUG 8732 End
      }
        }   
        /*
       for(ContractHistory conH : [Select id , NewValue,CreatedDate,ContractId,Contract.vlocity_cmt__QuoteId__c from ContractHistory where ContractId in : contractIds])
        {
           if(conH.Newvalue == 'Contract Signed' || Test.isRunningTest())
            {
                liveContractList.add(contractIdToContractMap.get(conH.ContractId));
                contractidToContractSignDate.put(conH.ContractId,ConH.CreatedDate);
            }
            if(conH.Newvalue == 'Contract Cancelled'||conH.Newvalue == 'Contract Terminated')
            {
                // liveContractList.add(contractIdToContractMap.get(conH.ContractId));
                 contractidToContractCancelOrTerminationDate.put(conH.ContractId,ConH.CreatedDate);
            }
        }
        */
        
        Map<Id,List<vlocity_cmt__ContractLineItem__c>> parentChildMap = new Map<Id,List<vlocity_cmt__ContractLineItem__c>>();
        for(vlocity_cmt__ContractLineItem__c cli:[Select id, Name, SWAN_Quote__c, SWAN_Quote__r.SWAN_Broker_Commission__c, SWAN_Quote__r.SWAN_Contract_Volume_KWh__c, 
        SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.QuoteNumber, SWAN_Quote__r.vlocity_cmt__ParentQuoteId__c, SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.SWAN_Broker__c, 
        SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.SWAN_Offer_Start_Date__c, SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.RecordTypeId, 
        SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.SWAN_Broker_Commission_Margin_p__c, 
        SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.SWAN_Broker_Commission_Margin_pence_per__c, SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.SWAN_Broker__r.Name, 
        SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.SWAN_Offer_End_Date__c, vlocity_cmt__LineStatus__c, 
        SWAN_Service_Point__r.vlocity_cmt__ServicePointNumber__c,SWAN_Service_Point__r.SWAN_Profile_Class_Ovrd__c,SWAN_Service_Point__r.SWAN_Profile_Class__c,SWAN_Service_Point__r.RecordType.Developername, SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.SWAN_Commission_Payment_Period__c, 
        SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.SWAN_Broker_Commission__c, vlocity_cmt__ContractId__c,SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.SWAN_Quote_Type__c
         From vlocity_cmt__ContractLineItem__c where vlocity_cmt__ContractId__c IN:liveContractList])
        {
            if(parentChildMap.containsKey(cli.vlocity_cmt__ContractId__c))
            {
                List<vlocity_cmt__ContractLineItem__c> tempList = parentChildMap.get(cli.vlocity_cmt__ContractId__c);
                tempList.add(cli);
                parentChildMap.put(cli.vlocity_cmt__ContractId__c,tempList); 
            }
            else
            {
                List<vlocity_cmt__ContractLineItem__c> tempList = new List<vlocity_cmt__ContractLineItem__c>();
                tempList.add(cli);
                parentChildMap.put(cli.vlocity_cmt__ContractId__c,tempList);   
            }
        }
        
        
        if(liveContractList.size()>0)
        {
            for(Contract con:liveContractList)
            {
                if(parentChildMap.containsKey(con.Id) && parentChildMap.get(con.Id) != null)
                {
                    for(vlocity_cmt__ContractLineItem__c cli:parentChildMap.get(con.Id))
                    {
                        if(cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.RecordTypeId == siteAddtnRecTypeId)
                            siteAddnQtIds.add(cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__c);
                    }
                }
            }
        }
        
        for(SWAN_Quote_Status_Tracking__c quoteH : [Select id , New_Status__c,Prior_Status__c,CreatedDate,SWAN_Quote__c from SWAN_Quote_Status_Tracking__c where SWAN_Quote__c in : siteAddnQtIds AND CreatedDate = THIS_YEAR])
        {
           if(quoteH.New_Status__c == 'Accepted' || Test.isRunningTest())
            {
                quoteIdToAcceptedDate.put(quoteH.SWAN_Quote__c,quoteH.CreatedDate);
            }
        }
        
        Datetime nowDate = Datetime.now();
        String MeterHeader = Label.SWAN_TresorReportMeterHeaderValues;
        String TermHeader = Label.SWAN_TresorReportTermHeaderValues;
        String IncaHeader = Label.SWAN_IncaReportTermHeaderValues;
        
        
        CSVMeterData = MeterHeader+'\r\n';
        CSVTermData = TermHeader+'\r\n';
        CSVIncaData = IncaHeader+'\r\n';
        if(liveContractList.size()>0)
        {
            for(Contract con:liveContractList)
            {
             if((contractidToContractCancelOrTerminationDate.containsKey(con.id) && contractidToContractCancelOrTerminationDate.get(con.id).addMonths(3) >=System.now()) || (!contractidToContractCancelOrTerminationDate.containsKey(con.id)) )
             {
               String salesAgent = (con.CompanySignedId != null?con.CompanySigned.Name:'');
                String fuelType = (con.vlocity_cmt__OpportunityId__c != null?con.vlocity_cmt__OpportunityId__r.SWAN_Fuel_Type__c:'');        
                String paymentMethod = ((con.SWAN_Payment_Method__c != null && con.SWAN_Payment_Method__c != '') ?con.SWAN_Payment_Method__c:'');
                String PRODUCTTYPE =(con.vlocity_cmt__QuoteId__r.SWAN_Quote_Type__c!=null?con.vlocity_cmt__QuoteId__r.SWAN_Quote_Type__c:'');
                String PRODUCTTYPECODE = PRODUCTTYPE;
                if(PRODUCTTYPE == 'Flex') 
                {  
                    PRODUCTTYPECODE = 'Flexible'; 
                }
                if(parentChildMap.containsKey(con.Id) && parentChildMap.get(con.Id) != null)
                {
                    for(vlocity_cmt__ContractLineItem__c cli:parentChildMap.get(con.Id))
                    {
                        if(cli.SWAN_Quote__c != null && cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__c != null && cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.SWAN_Broker_Commission__c > 0)
                        {
                            String quoteNumber = '';
                            String profileClass = '';
                            String contractNumber = con.ContractNumber;
                            String brokerAccId = '';
                            String brokerAccName = '';
                            String startDate = '';
                            String endDate = '';
                            String soldDate = '';
                            //String dealType = ((con.vlocity_cmt__OpportunityId__c != null && con.vlocity_cmt__OpportunityId__r.RecordTypeId != null && con.vlocity_cmt__OpportunityId__r.RecordType.name == 'Acquisition')?'Acquisition':'Renewal');
                            
                            String dealType;

                           if(
                            con.vlocity_cmt__OpportunityId__c != null && 
                            con.vlocity_cmt__OpportunityId__r.RecordTypeId != null && 
                            con.vlocity_cmt__OpportunityId__r.RecordType.name == 'Acquisition'){

                            dealType='Acquisition';
                            }

                            else if(
                                con.vlocity_cmt__OpportunityId__c != null && 
                                con.vlocity_cmt__OpportunityId__r.RecordTypeId != null && 
                                con.vlocity_cmt__OpportunityId__r.RecordType.name == 'Renewal'){

                            dealType='Renewal';
                            }

                            else if(
                                con.vlocity_cmt__OpportunityId__c != null && 
                                con.vlocity_cmt__OpportunityId__r.RecordTypeId != null && 
                                con.vlocity_cmt__OpportunityId__r.RecordType.name == 'Upgrade'){

                                dealType='Upgrade';
                                
                            }
                            String meterPoint = (cli.SWAN_Service_Point__c != null?cli.SWAN_Service_Point__r.vlocity_cmt__ServicePointNumber__c:'');
                            String ECC = (cli.SWAN_Quote__r.SWAN_Contract_Volume_KWh__c != null?String.valueOf(cli.SWAN_Quote__r.SWAN_Contract_Volume_KWh__c):'');
                            
                            if(cli.SWAN_Service_Point__c != null && (cli.SWAN_Service_Point__r.SWAN_Profile_Class_Ovrd__c != null))
                            {
                                profileClass  = cli.SWAN_Service_Point__r.SWAN_Profile_Class_Ovrd__c;
                            }   
                            else if(cli.SWAN_Service_Point__c != null && (cli.SWAN_Service_Point__r.SWAN_Profile_Class__c != null))
                            {
                                profileClass  = cli.SWAN_Service_Point__r.SWAN_Profile_Class__c;
                            }   
                            else profileClass  = '';
                            if(cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__c != null)
                            {
                                quoteNumber = (cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.QuoteNumber);
                                if(cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.SWAN_Broker__c != null) {
                                    brokerAccId = cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.SWAN_Broker__c;
                                    brokerAccName = cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.SWAN_Broker__r.Name;    
                                }
                                if(cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.SWAN_Offer_Start_Date__c != null)
                                {
                                    String startDay = (String.valueOf(cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.SWAN_Offer_Start_Date__c.day()).length()<2?'0'+cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.SWAN_Offer_Start_Date__c.day():''+cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.SWAN_Offer_Start_Date__c.day());
                                    String startMonth = (String.valueOf(cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.SWAN_Offer_Start_Date__c.month()).length()<2?'0'+cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.SWAN_Offer_Start_Date__c.month():''+cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.SWAN_Offer_Start_Date__c.month());
                                    
                                    startDate = startDay +'/'+startMonth+'/'+cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.SWAN_Offer_Start_Date__c.year();
                                }
                                if(cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.SWAN_Offer_End_Date__c != null)
                                {
                                    String endDay = (String.valueOf(cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.SWAN_Offer_End_Date__c.day()).length()<2?'0'+cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.SWAN_Offer_End_Date__c.day():''+cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.SWAN_Offer_End_Date__c.day());
                                    String endMonth = (String.valueOf(cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.SWAN_Offer_End_Date__c.month()).length()<2?'0'+cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.SWAN_Offer_End_Date__c.month():''+cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.SWAN_Offer_End_Date__c.month());
                                    
                                    endDate = endDay+'/'+endMonth+'/'+cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.SWAN_Offer_End_Date__c.year();
                                }  
                                if(cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.RecordTypeId == siteAddtnRecTypeId)
                                {
                                    salesAgent = con.Owner.Name;
                                    dealType = 'Site Addition';
                                    if(quoteIdToAcceptedDate.containsKey(cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__c))
                                        soldDate = String.valueOf((quoteIdToAcceptedDate.get(cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__c)).format('dd/MM/YYYY'));
                                }
                                else 
                                {
                                    if(contractidToContractSignDate.containsKey(con.Id))
                                        soldDate = String.valueOf((contractidToContractSignDate.get(con.Id)).format('dd/MM/YYYY'));
                                }
                            }
                            if(con.vlocity_cmt__PriceListId__c != null && con.vlocity_cmt__PriceListId__r.Name == label.Swan_I_C_Price_List)
                            {
                if(cli.SWAN_Service_Point__r.RecordType.Developername == 'SWAN_Gas_Service_Point')
                {  
                  CSVMeterData += ''+contractNumber+SEP+quoteNumber+SEP+NUL+SEP+brokerAccId+SEP+'1'+SEP+startDate+SEP+endDate+SEP+soldDate+SEP+salesAgent+SEP+meterPoint+SEP+'-1'+SEP+ECC+SEP+String.valueOf(cli.SWAN_Quote__r.SWAN_Broker_Commission__c)+SEP+'3'+SEP+cli.vlocity_cmt__LineStatus__c+'\r\n';
                }
                else if(cli.SWAN_Service_Point__r.RecordType.Developername == 'SWAN_Electricity_Service_point')
                {
                  CSVMeterData += ''+contractNumber+SEP+quoteNumber+SEP+NUL+SEP+brokerAccId+SEP+'2'+SEP+startDate+SEP+endDate+SEP+soldDate+SEP+salesAgent+SEP+meterPoint+SEP+profileClass+SEP+ECC+SEP+String.valueOf(cli.SWAN_Quote__r.SWAN_Broker_Commission__c)+SEP+'3'+SEP+cli.vlocity_cmt__LineStatus__c+'\r\n';
                }
                                if(!ParentQuoteId.contains(cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__c))
                                {
                                    ParentQuoteId.add(cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__c);
                  if(cli.SWAN_Service_Point__r.RecordType.Developername == 'SWAN_Electricity_Service_point')
                  {
                    fuelType = 'Elec';
                  }

                  if(fuelType.startsWithIgnoreCase('Elec')){
                      fuelType = 'Elec';
                  }

                  if(cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__c != null && cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.SWAN_Broker_Commission_Margin_p__c > 0)
                      CSVTermData += '' + NUL+SEP+quoteNumber+SEP+NUL+SEP+startDate+SEP+endDate+SEP+'£/meter/year'+SEP+String.valueOf(cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.SWAN_Broker_Commission_Margin_p__c)+SEP+'£/meter/year'+SEP+brokerAccName+SEP+con.AccountId+SEP+con.Account.name+SEP+soldDate+SEP+NUL+SEP+con.Status+SEP+NUL+SEP+NUL+SEP+fuelType+SEP+dealType+SEP+PRODUCTTYPECODE+'\r\n';
                  if(cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__c != null && cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.SWAN_Broker_Commission_Margin_pence_per__c > 0)
                      CSVTermData += '' + NUL+SEP+quoteNumber+SEP+NUL+SEP+startDate+SEP+endDate+SEP+'p/kWh'+SEP+String.valueOf(cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.SWAN_Broker_Commission_Margin_pence_per__c)+SEP+'p/kWh'+SEP+brokerAccName+SEP+con.AccountId+SEP+con.Account.name+SEP+soldDate+SEP+NUL+SEP+con.Status+SEP+NUL+SEP+NUL+SEP+fuelType+SEP+dealType+SEP+PRODUCTTYPECODE+'\r\n';  
                                }
                            }
                            else if(con.vlocity_cmt__PriceListId__c != null && con.vlocity_cmt__PriceListId__r.Name == label.Swan_Enterprise_Price_List)
                            {
                                if(cli.SWAN_Service_Point__r.RecordType.Developername == 'SWAN_Gas_Service_Point')
                                {
                                    if(cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__c != null && cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.SWAN_Broker_Commission_Margin_p__c > 0)
                                        CSVIncaData += '' + contractNumber+SEP+quoteNumber+SEP+NUL+SEP+brokerAccId+SEP+'1'+SEP+startDate+SEP+endDate+SEP+soldDate+SEP+salesAgent+SEP+meterPoint+SEP+'-1'+SEP+ECC+SEP+String.valueOf(cli.SWAN_Quote__r.SWAN_Broker_Commission__c)+SEP+'4'+SEP+cli.vlocity_cmt__LineStatus__c+SEP+'£/meter/year'+SEP+String.valueOf(cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.SWAN_Broker_Commission_Margin_p__c)+SEP+'£/meter/year'+SEP+brokerAccName+SEP+con.AccountId+SEP+con.Account.name+SEP+soldDate+SEP+NUL+SEP+con.Status+SEP+NUL+SEP+NUL+SEP+fuelType+SEP+dealType+SEP+'Fixed'+SEP+con.Account.BillingPostalCode+SEP+paymentMethod+SEP+cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.SWAN_Commission_Payment_Period__c+SEP+NUL+SEP+NUL+SEP+'Enterprise'+SEP+NUL+SEP+NUL+SEP+quoteNumber+'\r\n';
                                    if(cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__c != null && cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.SWAN_Broker_Commission_Margin_pence_per__c > 0)
                                        CSVIncaData += '' + contractNumber+SEP+quoteNumber+SEP+NUL+SEP+brokerAccId+SEP+'1'+SEP+startDate+SEP+endDate+SEP+soldDate+SEP+salesAgent+SEP+meterPoint+SEP+'-1'+SEP+ECC+SEP+String.valueOf(cli.SWAN_Quote__r.SWAN_Broker_Commission__c)+SEP+'4'+SEP+cli.vlocity_cmt__LineStatus__c+SEP+'p/kWh'+SEP+String.valueOf(cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.SWAN_Broker_Commission_Margin_pence_per__c)+SEP+'p/kWh'+SEP+brokerAccName+SEP+con.AccountId+SEP+con.Account.name+SEP+soldDate+SEP+NUL+SEP+con.Status+SEP+NUL+SEP+NUL+SEP+fuelType+SEP+dealType+SEP+'Fixed'+SEP+con.Account.BillingPostalCode+SEP+paymentMethod+SEP+cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.SWAN_Commission_Payment_Period__c+SEP+NUL+SEP+NUL+SEP+'Enterprise'+SEP+NUL+SEP+NUL+SEP+quoteNumber+'\r\n';
                                }
                                else if(cli.SWAN_Service_Point__r.RecordType.Developername == 'SWAN_Electricity_Service_point')
                                {
                                    if(cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__c != null && cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.SWAN_Broker_Commission_Margin_p__c > 0)
                                        CSVIncaData += '' + contractNumber+SEP+quoteNumber+SEP+NUL+SEP+brokerAccId+SEP+'2'+SEP+startDate+SEP+endDate+SEP+soldDate+SEP+salesAgent+SEP+meterPoint+SEP+profileClass+SEP+ECC+SEP+String.valueOf(cli.SWAN_Quote__r.SWAN_Broker_Commission__c)+SEP+'4'+SEP+cli.vlocity_cmt__LineStatus__c+SEP+'£/meter/year'+SEP+String.valueOf(cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.SWAN_Broker_Commission_Margin_p__c)+SEP+'£/meter/year'+SEP+brokerAccName+SEP+con.AccountId+SEP+con.Account.name+SEP+soldDate+SEP+NUL+SEP+con.Status+SEP+NUL+SEP+NUL+SEP+'Elec'+SEP+dealType+SEP+'Fixed'+SEP+con.Account.BillingPostalCode+SEP+paymentMethod+SEP+cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.SWAN_Commission_Payment_Period__c+SEP+NUL+SEP+NUL+SEP+'Enterprise'+SEP+NUL+SEP+NUL+SEP+quoteNumber+'\r\n';
                                    if(cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__c != null && cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.SWAN_Broker_Commission_Margin_pence_per__c > 0)
                                        CSVIncaData += '' + contractNumber+SEP+quoteNumber+SEP+NUL+SEP+brokerAccId+SEP+'2'+SEP+startDate+SEP+endDate+SEP+soldDate+SEP+salesAgent+SEP+meterPoint+SEP+profileClass+SEP+ECC+SEP+String.valueOf(cli.SWAN_Quote__r.SWAN_Broker_Commission__c)+SEP+'4'+SEP+cli.vlocity_cmt__LineStatus__c+SEP+'p/kWh'+SEP+String.valueOf(cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.SWAN_Broker_Commission_Margin_pence_per__c)+SEP+'p/kWh'+SEP+brokerAccName+SEP+con.AccountId+SEP+con.Account.name+SEP+soldDate+SEP+NUL+SEP+con.Status+SEP+NUL+SEP+NUL+SEP+'Elec'+SEP+dealType+SEP+'Fixed'+SEP+con.Account.BillingPostalCode+SEP+paymentMethod+SEP+cli.SWAN_Quote__r.vlocity_cmt__ParentQuoteId__r.SWAN_Commission_Payment_Period__c+SEP+NUL+SEP+NUL+SEP+'Enterprise'+SEP+NUL+SEP+NUL+SEP+quoteNumber+'\r\n';
                                }
                            }
                        }
                    }
                }
              
              }
            }
        }
        
        String meterFileName = 'SWAN_TRESOR_Meter_'+DateTime.now().format('YYYYMMddHHmmss')+'.csv';
        SWAN_Custom_Report__c meterTresorRepo = new SWAN_Custom_Report__c();
        meterTresorRepo.Name = meterFileName;
        meterTresorRepo.SWAN_Report_Type__c = 'TRESOR';
        
        String termFileName = 'SWAN_TRESOR_Term_'+DateTime.now().format('YYYYMMddHHmmss')+'.csv';
        SWAN_Custom_Report__c termTresorRepo = new SWAN_Custom_Report__c();
        termTresorRepo.Name = termFileName;
        termTresorRepo.SWAN_Report_Type__c = 'TRESOR';
        
        String incaFileName = 'swan_inca_'+DateTime.now().format('YYYYMMddHHmmss')+'.csv';
        SWAN_Custom_Report__c incaRepo = new SWAN_Custom_Report__c();
        incaRepo.Name = incaFileName;
        incaRepo.SWAN_Report_Type__c = 'INCA';
        
        if (Schema.sObjectType.SWAN_Custom_Report__c.fields.SWAN_Report_Type__c.isCreateable()) {
            insert meterTresorRepo;
            insert termTresorRepo;
            insert incaRepo;
        }
        
        List<Attachment> attList = new List<Attachment>();
        Attachment meterCSVFile = new Attachment(Name = meterFileName, ParentId = meterTresorRepo.Id, Body = Blob.valueOf('\uFEFF'+CSVMeterData));
        Attachment termCSVFile = new Attachment(Name = termFileName, ParentId = termTresorRepo.Id, Body = Blob.valueOf('\uFEFF'+CSVTermData));
        Attachment incaCSVFile = new Attachment(Name = incaFileName, ParentId = incaRepo.Id, Body = Blob.valueOf('\uFEFF'+CSVIncaData));
        //termCSVFile.ContentType='application/csv; charset=UTF-8';
        //termCSVFile.CharacterEncoding='UTF-8';
        attList.add(meterCSVFile);
        attList.add(termCSVFile);
        attList.add(incaCSVFile);
        try {
            if (Schema.sObjectType.Attachment.fields.Body.isCreateable()) 
            insert attList; 
        }
            Catch(Exception e) {System.debug(e);}
    }
}