public without sharing class BCR_File_Generation {
    
    static final String NUL = '';
    static final String SEP = '|';
    //static final String START_HEADER = 'BCR2|BCR2_ACQ_GAS_';
    //static final String FILE_NAME_START = 'BCR2_ACQ_GAS_';
    static final String FILE_EXTENSION = '.psv';
    static final String FILE_VERSION = '_0_';
    public static Map<Id,List<QuoteLineItem>> qtProdListMap = new Map<Id,List<QuoteLineItem>>();    
    
    public static void generateFile(List<Id> quoteIdList, List<Id> accountIdList, List<String> paymentTermList, Map<Id, Id> ownerMap, Map<Id, String> fileNameMap, Map<Id, Id> QuoteContractMap)
    {
        Map<String,String> paymentTermDaysToSAPKey = new Map<String,String>();
        Messaging.SingleEmailMessage[] lstEMailMessage = new Messaging.SingleEmailMessage[]{};
        Map<id, contract> mapContract = new Map<id, contract>();
        Segment_Values__c segmentVal = Segment_Values__c.getOrgDefaults();
        List<id> qliIdList = new List<Id>();
        if(QuoteContractMap != null){
            mapContract = new Map<id, contract>([select id, name, StartDate, Account.Name, contractnumber, RecordType.DeveloperName from contract where id in: QuoteContractMap.values()]);
        }
        if(quoteIdList != null && quoteIdList.size() > 0)
        {
            List<Quote> masterQuoteList = new List<Quote>([SELECT id,Opportunity.SWAN_Direct_Relation_With_Meter_Agents__c,Swan_Micro_Business_Selection__c,Account.SWAN_Customer_Segment__c, SWAN_Quote_for_Fuel_Type__c,SWAN_Quote_Type__c,SWAN_Passthrough_Option__c,RecordType.Name,Opportunity.RecordType.DeveloperName,Account.Name, RecordType.DeveloperName ,Opportunity.Name,QuoteNumber,AccountId,SWAN_Payment_Term__c,SWAN_Site_Addition_Parent__c,vlocity_cmt__PriceListId__c,vlocity_cmt__PriceListId__r.Name,SWAN_Site_Addition_Parent__r.vlocity_cmt__PriceListId__c, Opportunity.SWAN_Account_Micro_Business_Selection__c, SWAN_Site_Addition_Parent__r.vlocity_cmt__PriceListId__r.Name,(SELECT QuoteNumber, SWAN_Service_Point_Start_Date__c, SWAN_Service_Point_End_Date__c, vlocity_cmt__DefaultServicePointId__r.SWAN_Product_Class__c, vlocity_cmt__DefaultServicePointId__r.vlocity_cmt__ServicePointNumber__c, vlocity_cmt__DefaultServicePointId__r.SWAN_Formula_Year_Annual_Quantity__c, vlocity_cmt__DefaultServicePointId__r.SWAN_Formula_Year_Offtake_Quantity__c,vlocity_cmt__DefaultServicePointId__r.vlocity_cmt__PremisesId__c, vlocity_cmt__DefaultServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__City__c, vlocity_cmt__DefaultServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c, vlocity_cmt__DefaultServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__PostalCode__c, vlocity_cmt__DefaultServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__AlternatePostalCode__c,vlocity_cmt__DefaultServicePointId__r.vlocity_cmt__PremisesId__r.SWAN_House_Number__c,vlocity_cmt__DefaultServicePointId__r.vlocity_cmt__PremisesId__r.SWAN_House_Name__c,vlocity_cmt__DefaultServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__State__c,vlocity_cmt__ParentQuoteId__r.SWAN_Pricing_Structure__c,vlocity_cmt__DefaultServicePointId__r.SWAN_Standard_Settlement_Configuration__c,vlocity_cmt__DefaultServicePointId__r.SWAN_Measurement_Class__c,vlocity_cmt__DefaultServicePointId__r.SWAN_metered_indicator__c,vlocity_cmt__DefaultServicePointId__r.SWAN_Profile_Class__c,vlocity_cmt__DefaultServicePointId__r.SWAN_Meter_Time_Switch_Code__c,vlocity_cmt__DefaultServicePointId__r.SWAN_Line_Loss_Factor_Class__c,vlocity_cmt__DefaultServicePointId__r.SWAN_Distributor_Id__c, Annual_Volume__c, vlocity_cmt__DefaultServicePointId__r.SWAN_data_collector_mpid__c, vlocity_cmt__DefaultServicePointId__r.SWAN_data_aggregator_mpid__c,vlocity_cmt__DefaultServicePointId__r.SWAN_meter_operator_mpid__c, vlocity_cmt__DefaultServicePointId__r.SWAN_Supply_Capacity__c FROM vlocity_cmt__Quotes__r where Recordtype.Developername != 'GroupCart'  AND vlocity_cmt__DefaultServicePointId__c != null) FROM Quote WHERE Id IN :quoteIdList]);
            for(Quote qt: masterQuoteList)
            {
                if(qt.vlocity_cmt__Quotes__r.size()>0)
                {
                    for(Quote qtChild:qt.vlocity_cmt__Quotes__r)
                        qliIdList.add(qtChild.id);
                }   
            }
            
            Map<Id,User> userMap;   
            if(ownerMap != null && ownerMap.size()>0)
                userMap = new Map<Id,user>([SELECT Id,Swan_Sales_Agent_ID__c FROM User WHERE Id IN :ownerMap.values()]);

            system.debug('==='+ accountIdList);            
            Map<Id,Account> accountIdToAccountRecMap;
            if(accountIdList != null && accountIdList.size()>0)
                accountIdToAccountRecMap = new Map<Id,Account>([SELECT Id, Name, BP_Number__c, BillingCity,billingState, BillingStreet, BillingPostalCode, SWAN_Billing_Building_Name__c,SWAN_Billing_Building_Number__c,Company_Registration_No__c,vlocity_cmt__BillFrequency__c, vlocity_cmt__PrimaryContactId__r.FirstName, vlocity_cmt__PrimaryContactId__r.LastName, vlocity_cmt__PrimaryContactId__r.Phone, vlocity_cmt__PrimaryContactId__r.Fax, vlocity_cmt__PrimaryContactId__r.Email, vlocity_cmt__PrimaryContactId__r.MailingStreet, vlocity_cmt__PrimaryContactId__r.MailingCity, vlocity_cmt__PrimaryContactId__r.MailingPostalCode,vlocity_cmt__PrimaryContactId__r.SWAN_Mailing_Building_Name__c,vlocity_cmt__PrimaryContactId__r.SWAN_Mailing_Building_Number__c,vlocity_cmt__PrimaryContactId__r.MailingState FROM Account WHERE Id IN :accountIdList]);
            
            Map<Id,String> quoteIdToProductNameMap = new Map<Id,String>();
            Map<Id,String> quoteIdToStandingChargeMap = new Map<Id,String>();
            Map<Id,Decimal> quoteIdToUnitRateMap = new Map<Id,Decimal>();
            Map<Id,Decimal> quoteIdToAvailChargeMap = new Map<Id,Decimal>();

            //List<ContractHistory> contractHistoryList = new List<ContractHistory>([SELECT ContractId,CreatedById,CreatedDate,Field,Id,IsDeleted,NewValue,OldValue FROM ContractHistory WHERE ContractId IN :contractIdList AND Field = 'Status' ORDER BY CreatedDate DESC]);
            //system.debug(paymentTermList);
            List<vlocity_cmt__CalculationMatrixRow__c> agentDetailList = [SELECT id,vlocity_cmt__inputdata__c,name,vlocity_cmt__calculationmatrixversionid__c,vlocity_cmt__outputdata__c FROM vlocity_cmt__CalculationMatrixRow__c WHERE Name != 'Header' AND vlocity_cmt__CalculationMatrixVersionId__r.vlocity_cmt__CalculationMatrixId__c != null and vlocity_cmt__CalculationMatrixVersionId__r.vlocity_cmt__CalculationMatrixId__r.Name='SWAN_Agent_Lookup' and vlocity_cmt__CalculationMatrixVersionId__r.vlocity_cmt__IsEnabled__c=true];
            
            List<SWAN_SAP_Mapping_Payment_Days__mdt> paymentTermMetadataList;
            if(paymentTermList != null && paymentTermList.size()>0)
            {
                paymentTermMetadataList = new List<SWAN_SAP_Mapping_Payment_Days__mdt>([SELECT id,DeveloperName,SWAN_Payment_term__c FROM SWAN_SAP_Mapping_Payment_Days__mdt WHERE SWAN_Payment_term__c IN :paymentTermList]); 
                system.debug('~~~~~~~~ '+paymentTermMetadataList);          
            
                for(SWAN_SAP_Mapping_Payment_Days__mdt sapDays : paymentTermMetadataList)
                {
                    paymentTermDaysToSAPKey.put(sapDays.SWAN_Payment_term__c.toLowerCase(),sapDays.DeveloperName);
                }
                system.debug('~~~~!!!'+paymentTermDaysToSAPKey);
            }
            if(qliIdList.size()>0) 
            {
                for(QuoteLineItem qli : [SELECT id, PriceBookEntry.Product2.Name,PriceBookEntry.Product2.vlocity_cmt__Type__c, PriceBookEntry.Product2.productCode, SWAN_UnitRate__c,vlocity_cmt__RecurringCharge__c, QuoteId, vlocity_cmt__UsageUnitPrice__c FROM QuoteLineItem WHERE QuoteId in:qliIdList])
                {
                    system.debug('====qli '+qli.PriceBookEntry.Product2Id+'===='+qli.PriceBookEntry.Product2.productCode+'==='+qli.vlocity_cmt__RecurringCharge__c);
                     if(qli.PriceBookEntry.Product2.vlocity_cmt__Type__c == 'Gas' || qli.PriceBookEntry.Product2.vlocity_cmt__Type__c == 'Electricity')
                    {
                        quoteIdToProductNameMap.put(qli.quoteId,qli.PriceBookEntry.Product2.Name);
                    }
                    if(qli.PriceBookEntry.Product2.productCode == 'BG_STD')
                    {
                        String stdCharge = '0.000';
                        if(qli.vlocity_cmt__UsageUnitPrice__c != null ){
                            string temp = string.valueOf(qli.vlocity_cmt__UsageUnitPrice__c.format());
                            stdCharge = (!temp.contains('.')? (temp + '.000'):(temp+'000').substring(0,((temp+'000').indexOf('.'))+4));
                        }else if(qli.vlocity_cmt__RecurringCharge__c != null){
                            string temp = string.valueOf(qli.vlocity_cmt__RecurringCharge__c.format());
                            stdCharge = (!temp.contains('.')? (temp + '.000'):(temp+'000').substring(0,((temp+'000').indexOf('.'))+4));
                        }
                        quoteIdToStandingChargeMap.put(qli.quoteid,stdCharge);
                    }
                    if(qli.PriceBookEntry.Product2.productCode == 'BG_UNITRATE')
                    {
                        quoteIdToUnitRateMap.put(qli.quoteId,qli.SWAN_UnitRate__c);
                    }
                    if(qli.PriceBookEntry.Product2.productCode.contains('BG_UNIT_CHARGE'))
                    {
                        if(qtProdListMap.containsKey(qli.quoteId))
                        {
                            List<QuoteLineItem> tempList = qtProdListMap.get(qli.quoteId);
                            tempList.add(qli);
                            qtProdListMap.put(qli.quoteId,tempList);
                        }
                        else
                        {
                            List<QuoteLineItem> tempList = new List<QuoteLineItem>();
                            tempList.add(qli);
                            qtProdListMap.put(qli.quoteId,tempList);
                        }
                    }
                    if(qli.PriceBookEntry.Product2.productCode == 'BG_AVAILABILITY_CHARGE')
                    {
                        if(qli.vlocity_cmt__UsageUnitPrice__c != null)
                        quoteIdToAvailChargeMap.put(qli.quoteId,qli.vlocity_cmt__UsageUnitPrice__c.setScale(3));
                        else
                        quoteIdToAvailChargeMap.put(qli.quoteId, 0.000);
                    }
                        
                }
            }
            
            system.debug('==='+quoteIdToProductNameMap+'====='+quoteIdToStandingChargeMap+'===='+quoteIdToUnitRateMap);
            // Strings for the "header"

            String timestamp = String.valueOf( datetime.now() ).replaceAll( '-', '' ).replaceAll( ':', '' ).replaceAll( ' ', '' );
            String datestring = timestamp.substring( 0, 8 );
            String hourstring = String.valueOf(datetime.now()).substring( 11 );
        
            String csv;

            List<Attachment> attList = new List<Attachment>();
            
            if(masterQuoteList != null && masterQuoteList.size()>0)
            {            
                for(Quote q : masterQuoteList)
                {
                    string fuelType = q.SWAN_Quote_for_Fuel_Type__c;
                    String quoteType;
                    if(q.SWAN_Quote_Type__c == 'Flex')
                    {
                        quoteType ='FLEXIBLE';
                    }else{
                        quoteType ='FIXED';
                    }
                    Account a;
                    system.debug('===='+q.AccountId+'==='+fileNameMap+'==='+accountIdToAccountRecMap);
                    if(accountIdToAccountRecMap != null && accountIdToAccountRecMap.containsKey(q.AccountId))
                        a = accountIdToAccountRecMap.get(q.AccountId);
                    String contractCustomerSignedDate = returnFieldValueDate( Datetime.now() );
                    String contractPaymentTerm = '';
                    if (paymentTermDaysToSAPKey.containsKey(q.SWAN_Payment_Term__c.Trim().toLowerCase()))
                    {
                        contractPaymentTerm = returnFieldValueString(paymentTermDaysToSAPKey.get(q.SWAN_Payment_Term__c.Trim().toLowerCase())); 
                    }
                    /*********Opportunity Recordtype Check *****************/
                    
                    String record_type = '';
                    if(
                        fileNameMap.get(q.id) == 'Acquisition' ||
                        fileNameMap.get(q.id) == 'Renewal' ||
                        fileNameMap.get(q.id) == 'Upgrade' || //updated 11/10/2021
                        fileNameMap.get(q.id) == 'Site Addition')
                    {
                        record_type = 'C';
                    }
                    /****Added to be in case on new connections****
                    else
                    {
                        record_type = 'N';
                    }
                    /****Added to be in case on new connections****/
                    
                    /*************************************/
                    
                    // Populate segment
                    String segment='';
                    if(fileNameMap.get(q.id) == 'Site Addition')
                    {
                        if(q.SWAN_Site_Addition_Parent__c != null && q.SWAN_Site_Addition_Parent__r.vlocity_cmt__PriceListId__c != null)
                        {
                            if(q.SWAN_Site_Addition_Parent__r.vlocity_cmt__PriceListId__r.Name == label.Swan_Enterprise_Price_List)
                                segment = segmentVal.Enterprise_Segment__c;
                            else if(q.SWAN_Site_Addition_Parent__r.vlocity_cmt__PriceListId__r.Name == label.Swan_I_C_Price_List)
                                segment = segmentVal.I_C_Segment__c;
                        }
                    }
                    else 
                    {
                        if(q.vlocity_cmt__PriceListId__c != null)
                        {
                            if(q.vlocity_cmt__PriceListId__r.Name == label.Swan_Enterprise_Price_List)
                                segment = segmentVal.Enterprise_Segment__c;
                            else if(q.vlocity_cmt__PriceListId__r.Name == label.Swan_I_C_Price_List)
                                segment = segmentVal.I_C_Segment__c;
                        }
                    }
                    
                    User u;
                    if(userMap != null && userMap.containsKey(ownerMap.get(q.Id))) 
                        u = userMap.get(ownerMap.get(q.Id));
                    Integer counter = 0;
                    String START_HEADER = ((fileNameMap.get(q.id)=='Renewal' ||fileNameMap.get(q.id)=='Upgrade')?'BCR2|BCR2_REN'+(fuelType=='Gas'?'_GAS_':'_ELEC_'):'BCR2|BCR2_ACQ'+(fuelType=='Gas'?'_GAS_':'_ELEC_'));
                    csv = START_HEADER + q.QuoteNumber + FILE_VERSION + timestamp + FILE_EXTENSION + SEP + datestring + SEP + hourstring + '\n';
                        
                    for(Quote cq : q.vlocity_cmt__Quotes__r)
                    {
                        string serPointNum = '';
                        if(cq.vlocity_cmt__DefaultServicePointId__r.vlocity_cmt__ServicePointNumber__c!=null)
                            serPointNum = cq.vlocity_cmt__DefaultServicePointId__r.vlocity_cmt__ServicePointNumber__c.right(3);
                        String distributorId='';
                        if(cq.vlocity_cmt__DefaultServicePointId__r.SWAN_Distributor_Id__c != null)
                           distributorId = String.valueOf(cq.vlocity_cmt__DefaultServicePointId__r.SWAN_Distributor_Id__c);
                        String productName = quoteIdToProductNameMap.get(cq.id);
                        String StandingCharge = '';
                        if(quoteIdToStandingChargeMap.containsKey(cq.id))
                        {
                            StandingCharge = (quoteIdToStandingChargeMap.get(cq.id));    
                        }
                        
                        String unitRate = '';
                        if(quoteIdToUnitRateMap.containsKey(cq.id))
                        {
                            unitRate = returnFieldvalueCharges(quoteIdToUnitRateMap.get(cq.id));    
                        }
                        
                        String availCharge = '';
                        if(quoteIdToAvailChargeMap.containsKey(cq.id))
                        {
                            availCharge = returnFieldvalueCharges(quoteIdToAvailChargeMap.get(cq.id));
                        }
                        system.debug('===='+StandingCharge+'======'+unitRate);
                        counter++;
                        String meterType = '';
                        if(cq.vlocity_cmt__DefaultServicePointId__r.SWAN_Product_Class__c == '1' || cq.vlocity_cmt__DefaultServicePointId__r.SWAN_Product_Class__c == '2')
                        {
                            meterType = 'DM';
                        }
                        else if (cq.vlocity_cmt__DefaultServicePointId__r.SWAN_Product_Class__c == '3' || cq.vlocity_cmt__DefaultServicePointId__r.SWAN_Product_Class__c == '4')
                        {
                            meterType = 'NDM';
                        }
                        
                        String RO_Flag = ((q.SWAN_Passthrough_Option__c!=null && q.SWAN_Passthrough_Option__c!='' && q.SWAN_Passthrough_Option__c.contains('Renewable Obligation') && !cq.vlocity_cmt__DefaultServicePointId__r.SWAN_Measurement_Class__c.contains('A') && !cq.vlocity_cmt__DefaultServicePointId__r.SWAN_Measurement_Class__c.contains('B'))?'Y':'N');
                        String FiT_Flag = ((q.SWAN_Passthrough_Option__c!=null && q.SWAN_Passthrough_Option__c!='' && q.SWAN_Passthrough_Option__c.contains('Feed in Tariff') && !cq.vlocity_cmt__DefaultServicePointId__r.SWAN_Measurement_Class__c.contains('A') && !cq.vlocity_cmt__DefaultServicePointId__r.SWAN_Measurement_Class__c.contains('B'))?'Y':'N');
                        String TNUoS_Flag = ((q.SWAN_Passthrough_Option__c!=null && q.SWAN_Passthrough_Option__c!='' && q.SWAN_Passthrough_Option__c.contains('TNUoS') && !cq.vlocity_cmt__DefaultServicePointId__r.SWAN_Measurement_Class__c.contains('A') && !cq.vlocity_cmt__DefaultServicePointId__r.SWAN_Measurement_Class__c.contains('B'))?'Y':'N');
                        String DUoS_Flag = ((q.SWAN_Passthrough_Option__c!=null && q.SWAN_Passthrough_Option__c!='' && q.SWAN_Passthrough_Option__c.contains('DUoS') && !cq.vlocity_cmt__DefaultServicePointId__r.SWAN_Measurement_Class__c.contains('A') && !cq.vlocity_cmt__DefaultServicePointId__r.SWAN_Measurement_Class__c.contains('B'))?'Y':'N');
                        String BSUoS_Flag = ((q.SWAN_Passthrough_Option__c!=null && q.SWAN_Passthrough_Option__c!='' && q.SWAN_Passthrough_Option__c.contains('BSUoS + RCRC') && !cq.vlocity_cmt__DefaultServicePointId__r.SWAN_Measurement_Class__c.contains('A') && !cq.vlocity_cmt__DefaultServicePointId__r.SWAN_Measurement_Class__c.contains('B'))?'Y':'N');
                        String AAHEDC_Flag = ((q.SWAN_Passthrough_Option__c!=null && q.SWAN_Passthrough_Option__c!='' && q.SWAN_Passthrough_Option__c.contains('AAHEDC') && !cq.vlocity_cmt__DefaultServicePointId__r.SWAN_Measurement_Class__c.contains('A') && !cq.vlocity_cmt__DefaultServicePointId__r.SWAN_Measurement_Class__c.contains('B'))?'Y':'N');
                        String CfD_Flag = ((q.SWAN_Passthrough_Option__c!=null && q.SWAN_Passthrough_Option__c!='' && q.SWAN_Passthrough_Option__c.contains('Contracts for Difference') && !cq.vlocity_cmt__DefaultServicePointId__r.SWAN_Measurement_Class__c.contains('A') && !cq.vlocity_cmt__DefaultServicePointId__r.SWAN_Measurement_Class__c.contains('B'))?'Y':'N');
                        String CM_Flag = ((q.SWAN_Passthrough_Option__c!=null && q.SWAN_Passthrough_Option__c!='' && q.SWAN_Passthrough_Option__c.contains('Capacity Market') && !cq.vlocity_cmt__DefaultServicePointId__r.SWAN_Measurement_Class__c.contains('A') && !cq.vlocity_cmt__DefaultServicePointId__r.SWAN_Measurement_Class__c.contains('B'))?'Y':'N');
                        String DA='';
                        String DC='';
                        String MOP='';
                        String MP_Id_Default='';
                        if(fuelType == 'Electricity')
                        {
                            if(q.Opportunity.SWAN_Direct_Relation_With_Meter_Agents__c)
                            {
                                for(vlocity_cmt__CalculationMatrixRow__c agt:agentDetailList)
                                {
                                    Map<String,Object> outputData = (Map<String, Object>)json.deserializeUntyped(agt.vlocity_cmt__outputdata__c);
                                    if(agt.vlocity_cmt__inputdata__c.contains(cq.vlocity_cmt__DefaultServicePointId__r.SWAN_data_aggregator_mpid__c))
                                    {
                                        DA = ((outputData.containsKey('DA') && (string)outputData.get('DA')!='NA')?(string)outputData.get('DA'):'');
                                    }
                                    if(agt.vlocity_cmt__inputdata__c.contains(cq.vlocity_cmt__DefaultServicePointId__r.SWAN_data_collector_mpid__c))
                                    {
                                        DC = ((outputData.containsKey('DC') && (string)outputData.get('DC')!='NA')?(string)outputData.get('DC'):'');
                                    }
                                    if(agt.vlocity_cmt__inputdata__c.contains(cq.vlocity_cmt__DefaultServicePointId__r.SWAN_meter_operator_mpid__c))
                                    {
                                        MOP = ((outputData.containsKey('MOP') && (string)outputData.get('MOP')!='NA')?(string)outputData.get('MOP'):'');
                                    }    
                                    if(DA != '' && DC != '' && MOP != '')
                                        break;
                                }
                            }
                            else
                            {
                                UKB_Preferred_Agent__c agt = UKB_Preferred_Agent__c.getInstance();
                                DA = agt.DA__c;
                                DC = agt.DC__c;
                                MOP = agt.MOP__c;
                                MP_Id_Default = agt.MP_Id__c;
                            }
                        }
                        
                        system.debug('====DA'+DA+'===DC'+DC+'===MOP'+MOP);
                        // Build "header" line
                        csv+='BCR' + SEP +
                         (fileNameMap.get(q.id) =='Upgrade'?'Renewal':fileNameMap.get(q.id))
                         + SEP + 
                        'BCR2' + SEP + NUL +  SEP + q.Opportunity.Name + SEP + q.Opportunity.Name + 
                        SEP + a.Name + 
                        SEP + ((a.BP_Number__c!=null && a.BP_Number__c!='')?a.BP_Number__c:NUL) + //((fileNameMap.get(q.id)=='Site Addition' || fileNameMap.get(q.id)=='Renewal')?a.BP_Number__c:NUL) + 
                        SEP + '0030' + 
                        SEP + 'C' + 
                        SEP + segment + 
                        SEP + NUL + 
                        SEP + returnFieldValueString(a.Company_Registration_No__c) + 
                        SEP + NUL + 
                        SEP + NUL + 
                        SEP + NUL + 
                        SEP + NUL + 
                        SEP + NUL + 
                        SEP + NUL + 
                        SEP + NUL + 
                        SEP + NUL + 
                        SEP + NUL + 
                        SEP + returnFieldValueString(a.SWAN_Billing_Building_Name__c) + 
                        SEP + NUL + 
                        SEP + returnFieldValueString(a.SWAN_Billing_Building_Number__c) + 
                        SEP + NUL + 
                        SEP + NUL + 
                        SEP + returnFieldValueString(a.BillingState) + 
                        SEP + NUL + 
                        SEP + returnFieldValueString(a.BillingCity) + 
                        SEP + returnFieldValueString(a.BillingStreet) + 
                        SEP + returnFieldValueString(a.BILLINGPostalCode) +
                        SEP + NUL +
                        SEP + NUL +
                        SEP + NUL + 
                        SEP + NUL + 
                        SEP + NUL + 
                        SEP + NUL + 
                        SEP + NUL + 
                        SEP + NUL + 
                        SEP + NUL + 
                        SEP + NUL + 
                        SEP + NUL + 
                        SEP + NUL + 
                        SEP + NUL + 
                        SEP + NUL + 
                        SEP + NUL + 
                        SEP + NUL + 
                        SEP + NUL + 
                        SEP + returnFieldValueString(a.vlocity_cmt__PrimaryContactId__r.FirstName) + 
                        SEP + returnFieldValueString(a.vlocity_cmt__PrimaryContactId__r.LastName) + 
                        SEP + NUL + 
                        SEP + NUL + 
                        SEP + NUL + 
                        SEP + returnFieldValueString(a.vlocity_cmt__PrimaryContactId__r.SWAN_Mailing_Building_Name__c) + 
                        SEP + NUL + 
                        SEP + returnFieldValueString(a.vlocity_cmt__PrimaryContactId__r.SWAN_Mailing_Building_Number__c) + 
                        SEP + NUL + 
                        SEP + NUL + 
                        SEP + returnFieldValueString(a.vlocity_cmt__PrimaryContactId__r.MailingState) + 
                        SEP + NUL + 
                        SEP + returnFieldvalueGeneral(a.vlocity_cmt__PrimaryContactId__r.Phone) + 
                        SEP + returnFieldvalueGeneral(a.vlocity_cmt__PrimaryContactId__r.Fax) + 
                        SEP + returnFieldValueString(a.vlocity_cmt__PrimaryContactId__r.Email) + 
                        SEP + returnFieldValueString(a.vlocity_cmt__PrimaryContactId__r.MailingStreet) + 
                        SEP + returnFieldValueString(a.vlocity_cmt__PrimaryContactId__r.MailingCity) + 
                        SEP + returnFieldValueString(a.vlocity_cmt__PrimaryContactId__r.MailingPostalCode) + 
                        SEP + NUL + 
                        SEP + NUL + 
                        SEP + NUL + 
                        SEP + NUL + 
                        SEP + NUL + 
                        SEP + NUL + 
                        SEP + NUL + 
                        SEP + NUL + 
                        SEP + NUL + 
                        SEP + NUL + 
                        SEP + NUL + 
                        SEP + NUL + 
                        SEP + NUL + 
                        SEP + NUL + 
                        SEP + NUL + 
                        SEP + NUL + 
                        SEP + NUL + 
                        SEP + NUL + 
                        SEP + NUL + 
                        SEP + returnFieldValueString(a.SWAN_Billing_Building_Name__c) + 
                        SEP + NUL + 
                        SEP + returnFieldValueString(a.SWAN_Billing_Building_Number__c) + 
                        SEP + NUL + 
                        SEP + NUL + 
                        SEP + returnFieldValueString(a.BillingState) + 
                        SEP + NUL + 
                        SEP + returnFieldValueString(a.BillingStreet) + 
                        SEP + returnFieldValueString(a.BillingCity) + 
                        SEP + returnFieldValueString(a.BillingPostalCode) + 
                        SEP + 'N' + 
                        SEP + 'N' + 
                        SEP + 'Y' + 
                        SEP + returnFieldValueString(cq.vlocity_cmt__DefaultServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__City__c) + 
                        SEP + NUL + 
                        SEP + NUL + 
                        SEP + NUL + 
                        SEP + NUL + 
                        SEP + returnFieldValueString(cq.vlocity_cmt__DefaultServicePointId__r.vlocity_cmt__PremisesId__r.SWAN_House_Name__c) + 
                        SEP + returnFieldValueString(cq.vlocity_cmt__DefaultServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__AlternatePostalCode__c) + 
                        SEP + returnFieldValueString(cq.vlocity_cmt__DefaultServicePointId__r.vlocity_cmt__PremisesId__r.SWAN_House_Number__c) + 
                        SEP + NUL + 
                        SEP + NUL + 
                        SEP + returnFieldValueString(cq.vlocity_cmt__DefaultServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__State__c) + 
                        SEP + NUL + 
                        SEP + NUL + 
                        SEP + returnFieldValueString(cq.vlocity_cmt__DefaultServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c) + 
                        SEP + returnFieldValueString(cq.vlocity_cmt__DefaultServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__City__c) + 
                        SEP + returnFieldValueString(cq.vlocity_cmt__DefaultServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__PostalCode__c) + 
                        SEP + (fuelType=='Gas'?NUL:returnFieldValueString(cq.vlocity_cmt__DefaultServicePointId__r.SWAN_Standard_Settlement_Configuration__c)) + 
                        SEP + (fuelType=='Gas'?NUL:(cq.vlocity_cmt__DefaultServicePointId__r.SWAN_metered_indicator__c?NUL:'Y')) + 
                        SEP + (fuelType=='Gas'?returnFieldValueString(meterType):NUL) + 
                        SEP + (fuelType=='Gas'?NUL:((cq.vlocity_cmt__DefaultServicePointId__r.SWAN_Measurement_Class__c=='A' || cq.vlocity_cmt__DefaultServicePointId__r.SWAN_Measurement_Class__c=='B')?'NHH':'HH')) +  
                        SEP + NUL +
                        SEP + (fuelType=='Gas'?NUL:returnFieldValueString(cq.vlocity_cmt__DefaultServicePointId__r.SWAN_Profile_Class__c)) +  
                        SEP + (fuelType=='Gas'?NUL:returnFieldValueString(cq.vlocity_cmt__DefaultServicePointId__r.SWAN_Meter_Time_Switch_Code__c)) +  
                        SEP + (fuelType=='Gas'?NUL:returnFieldValueString(cq.vlocity_cmt__DefaultServicePointId__r.SWAN_Line_Loss_Factor_Class__c)) +  
                        SEP + (fuelType=='Gas'?NUL:distributorId) +  
                        SEP + (fuelType=='Gas'?NUL:returnFieldValueString(cq.vlocity_cmt__DefaultServicePointId__r.vlocity_cmt__ServicePointNumber__c)) +  
                        SEP + (fuelType=='Gas'?NUL:serPointNum) +  
                        SEP + (fuelType=='Gas'?NUL:(cq.Annual_Volume__c!=null?returnFieldValueString(String.valueOf(cq.Annual_Volume__c)):'')) + 
                        SEP + (fuelType=='Gas'?returnFieldValueString(cq.vlocity_cmt__DefaultServicePointId__r.vlocity_cmt__ServicePointNumber__c):NUL) + 
                        SEP + (fuelType=='Gas'?returnFieldValueString(cq.vlocity_cmt__DefaultServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__PostalCode__c):NUL) + 
                        SEP + (fuelType=='Gas'?returnFieldvalueDecimal(cq.vlocity_cmt__DefaultServicePointId__r.SWAN_Formula_Year_Annual_Quantity__c):NUL) + 
                        SEP + (fuelType=='Gas'?returnFieldvalueDecimal(cq.vlocity_cmt__DefaultServicePointId__r.SWAN_Formula_Year_Annual_Quantity__c):NUL) + 
                        SEP + (fuelType=='Gas'?returnFieldvalueDecimal(cq.vlocity_cmt__DefaultServicePointId__r.SWAN_Formula_Year_Offtake_Quantity__c):NUL) + 
                        SEP + (fuelType=='Gas'?returnFieldvalueDecimal(cq.vlocity_cmt__DefaultServicePointId__r.SWAN_Formula_Year_Offtake_Quantity__c):NUL) + 
                        SEP + NUL + 
                        SEP + NUL + 
                        SEP + (fuelType=='Gas'?returnFieldValueString(meterType):NUL) + 
                        SEP + (fuelType=='Gas'?returnFieldValueString(record_type):NUL) + 
                        SEP + NUL + 
                        SEP + NUL + 
                        SEP + NUL + 
                        SEP + NUL + 
                        SEP + NUL + 
                        SEP + NUL + 
                        SEP + NUL + 
                        SEP + NUL + 
                        SEP + NUL + 
                        SEP + NUL + 
                        SEP + NUL + 
                        SEP + NUL + 
                        SEP + NUL + 
                        SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + 
                        SEP + ((fileNameMap.get(q.id) == 'Acquisition' || fileNameMap.get(q.id) == 'Renewal'|| fileNameMap.get(q.id) == 'Upgrade')?quoteType:'FIXED') + 
                        SEP + NUL + 
                        SEP + contractPaymentTerm.trim() + 
                        SEP + '004' + 
                        SEP + '02' + 
                        SEP + (fuelType=='Gas'?'FIRM':NUL) + 
                        SEP + contractCustomerSignedDate + 
                        SEP + NUL + 
                        SEP + NUL + 
                        SEP + NUL + 
                        SEP + returnFieldValueString(a.vlocity_cmt__BillFrequency__c) + 
                        SEP + (fuelType=='Gas'?NUL:(cq.vlocity_cmt__DefaultServicePointId__r.SWAN_Measurement_Class__c=='A' || cq.vlocity_cmt__DefaultServicePointId__r.SWAN_Measurement_Class__c=='B')?NUL:(cq.vlocity_cmt__DefaultServicePointId__r.SWAN_Supply_Capacity__c!=null?string.valueOf(cq.vlocity_cmt__DefaultServicePointId__r.SWAN_Supply_Capacity__c):'0')) + 
                        SEP + '70' + 
                        SEP + '130' + 
                        SEP + NUL + 
                        SEP + NUL + 
                        SEP + NUL + 
                        SEP + NUL + 
                        SEP + NUL + 
                        SEP + NUL + 
                        SEP + q.QuoteNumber + 
                        SEP + returnFieldValueDate(cq.SWAN_Service_Point_Start_Date__c) + 
                        SEP + returnFieldValueDate(cq.SWAN_Service_Point_End_Date__c) + 
                        SEP + NUL + 
                        SEP + NUL + 
                        SEP + NUL + 
                        SEP + NUL + 
                        SEP + NUL + 
                        SEP + returnFieldValueString(productName) + 
                        SEP + (fuelType=='Gas'?NUL:'Y') +
                        SEP + (fuelType=='Gas'?'Y':NUL) +
                        SEP + NUL + 
                        SEP + NUL + 
                        SEP + NUL + 
                        SEP + NUL + 
                        getItemPrices(fuelType, cq.Id, cq.vlocity_cmt__ParentQuoteId__r.SWAN_Pricing_Structure__c,quoteType,StandingCharge,unitRate,availCharge,fileNameMap.get(q.id))
                        + SEP + NUL + SEP + NUL + 
                        SEP + returnFieldvalueGeneral(u.Swan_Sales_Agent_ID__c) + 
                        SEP + (fuelType=='Gas'?NUL:(MP_Id_Default!=''?MP_Id_Default:returnFieldvalueString(cq.vlocity_cmt__DefaultServicePointId__r.SWAN_data_collector_mpid__c))) +
                        SEP + (fuelType=='Gas'?NUL:DC) +
                        SEP + (fuelType=='Gas'?NUL:(MP_Id_Default!=''?MP_Id_Default:returnFieldvalueString(cq.vlocity_cmt__DefaultServicePointId__r.SWAN_data_aggregator_mpid__c))) +
                        SEP + (fuelType=='Gas'?NUL:DA) +
                        SEP + (fuelType=='Gas'?NUL:(MP_Id_Default!=''?MP_Id_Default:returnFieldvalueString(cq.vlocity_cmt__DefaultServicePointId__r.SWAN_meter_operator_mpid__c))) +
                        SEP + (fuelType=='Gas'?NUL:MOP) +
                        SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + 
                        SEP + (fuelType=='Gas'?NUL:RO_Flag) +
                        SEP + (fuelType=='Gas'?NUL:FiT_Flag) +
                        SEP + NUL + 
                        SEP + (fuelType=='Gas'?NUL:TNUoS_Flag) +
                        SEP + (fuelType=='Gas'?NUL:DUoS_Flag) +
                        SEP + NUL + SEP + NUL + 
                        SEP + (fuelType=='Gas'?NUL:BSUoS_Flag) +
                        SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + 
                        SEP + (fuelType=='Gas'?NUL:AAHEDC_Flag) +
                        SEP + (fuelType=='Gas'?NUL:CfD_Flag) +
                        SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + 
                        'N' + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + SEP + NUL + 
                        SEP + (fuelType=='Gas'?NUL:CM_Flag) +
                        '\n';
                        
                        
                    }
                    csv += 'TRL' + SEP + counter;
                    
                    // Attach the file to Contract
                    String FILE_NAME_START = ((fileNameMap.get(q.id)=='Renewal' || fileNameMap.get(q.id)=='Upgrade')?'BCR2_REN':'BCR2_ACQ');
                    Attachment csvFile = new Attachment(
                        Name = FILE_NAME_START + (fuelType=='Gas'?'_GAS_':'_ELEC_') + q.QuoteNumber + FILE_VERSION + timestamp + FILE_EXTENSION,
                        ParentId = (QuoteContractMap != null && QuoteContractMap.containskey(q.id)?QuoteContractMap.get(q.id):q.Id),
                        Body = Blob.valueOf( csv )
                    );
                    attList.add(csvFile);
                    
                    String QuotetypeforEmail;
                    String SaleTypeForEmail;
                    String NumberForEmail;
                    String EmailSubject;
                    String EmailBody;
                    Date ContractDate;
                  
                    If('MasterQuote'.equalsIgnoreCase(q.Recordtype.Developername)){
                        QuotetypeforEmail = mapContract.get(QuoteContractMap.get(q.id)).ContractNumber;
                        SaleTypeForEmail= 'Acquisition'; 
                        NumberForEmail= 'Contract Number';
                        ContractDate= (QuoteContractMap != null && QuoteContractMap.containskey(q.id)?mapContract.get(QuoteContractMap.get(q.id)).StartDate:null);
                        String ContractStartDate= ContractDate.format();
                        EmailSubject = 'BCR Ready: '  + NumberForEmail + ' : ' + QuotetypeforEmail + ' , ' + 'Contract Start date: ' + ContractStartDate ;
                        EmailBody = '<html><body> BCR File is ready to be downloaded from Vlocity:  </br></br>  <b> - Contract Number: </b>' + QuotetypeforEmail + '<br/>' + '<b>- Company Name: </b>' + (QuoteContractMap != null && QuoteContractMap.containskey(q.id)?mapContract.get(QuoteContractMap.get(q.id)).Account.Name:q.Account.Name) + '<br/>' + '<b>- Segment: </b>' + q.Account.SWAN_Customer_Segment__c + '<br/>' + '<b>- Product: </b>' + q.SWAN_Quote_for_Fuel_Type__c + '<br/>' + '<b>- Sale Type: </b>' + SaleTypeForEmail + '<br/>' + '<b>- MB Status: </b>' + q.Opportunity.SWAN_Account_Micro_Business_Selection__c + '<br/>' + '<b>- Contract Start Date: </b>' + ContractStartDate + '<br/><br/><br/>';
                    }
                    else if('Site_Addition_Quote'.equalsIgnoreCase(q.Recordtype.Developername)){
                        QuotetypeforEmail = q.QuoteNumber;
                        SaleTypeForEmail= 'Site Additions';
                        NumberForEmail= 'Quote Number';
                        EmailSubject = 'BCR Ready: '  + NumberForEmail + ' : ' + QuotetypeforEmail;
                        EmailBody = '<html><body> BCR File is ready to be downloaded from Vlocity: </br></br>  <b> - Quote Number: </b>' + QuotetypeforEmail + '<br/>' + '<b>- Company Name: </b>' + (QuoteContractMap != null && QuoteContractMap.containskey(q.id)?mapContract.get(QuoteContractMap.get(q.id)).Account.Name:q.Account.Name) + '<br/>' + '<b>- Segment: </b>' + q.Account.SWAN_Customer_Segment__c + '<br/>' + '<b>- Product: </b>' + q.SWAN_Quote_for_Fuel_Type__c + '<br/>' + '<b>- Sale Type: </b>' + SaleTypeForEmail + '<br/>' + '<b>- MB Status: </b>' + q.Opportunity.SWAN_Account_Micro_Business_Selection__c + '<br/><br/><br/>';
                    }
                    
                    //EmailBody = EmailBody + '<br/>' + '<b>Company Name: </b>' + (QuoteContractMap != null && QuoteContractMap.containskey(q.id)?mapContract.get(QuoteContractMap.get(q.id)).Account.Name:q.Account.Name) + '<br/>' + '<b>Segment: </b>' + q.Account.SWAN_Customer_Segment__c + '<br/>' + '<b>Product: </b>' + q.SWAN_Quote_for_Fuel_Type__c + '<br/>' + '<b>Sale Type: </b>' + SaleTypeForEmail + '<br/>' + '<b>MB Status: </b>' + q.Opportunity.SWAN_Account_Micro_Business_Selection__c + '<br/>' + '<b>Contract Start Date: </b>' + (QuoteContractMap != null && QuoteContractMap.containskey(q.id)?mapContract.get(QuoteContractMap.get(q.id)).StartDate:null) + '<br/><br/><br/>';
                    OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'noreplyswan@centrica.com'];
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    if ( owea.size() > 0 ) {
                    mail.setOrgWideEmailAddressId(owea.get(0).Id);
                    }
                    String[] sendingTo = new String[]{System.label.ContractLiveTeamEmail}; 
                    mail.setToAddresses(sendingTo); 
                    mail.setSubject(EmailSubject); 
                    mail.setHTMLBody(EmailBody +  'Link to Vlocity Home Page <a href=' + System.label.Vlocity_Home_Page_URL + '>Vlocity Home</a></body></html>');
                    lstEMailMessage.add(mail);  
                    Task notify = new Task(OwnerId = UserInfo.getUserId(), 
                               Subject = 'Email sent to Registration team', 
                               Status = 'Open', 
                               Priority = 'Normal', 
                               WhatId = q.AccountId, 
                               ActivityDate=date.today(), 
                               Description='Email sent to Registration team',
                               IsReminderSet=true, 
                               ReminderDateTime=system.now().addSeconds(10)
                              );
        
        insert notify;

                }
            }
            if(!attList.isEmpty())
            {
                if (Schema.sObjectType.Attachment.isCreateable()) 
                {
                    insert attList;
                    
                }
                
                if(lstEMailMessage.size()>0){
                    Messaging.sendEmail(lstEMailMessage); 
                }
            }
        }
        
    }
    
    
    public static String returnFieldvalueGeneral(Object fieldvalue)
    {
        if (fieldvalue == null)
        {
            return '';
        }
        else
        {
            return String.valueof(fieldvalue);
        }
    }
    
    public static String returnFieldValueString(String fieldvalue)
    {
        if (string.isblank(fieldvalue))
        {
            return '';
        }
        else
        {
            return fieldvalue;
        }
    }
    
    public static String returnFieldValueDate(Datetime fieldvalue)
    {
        if (fieldvalue == null)
        {
            return '';
        }
        else
        {
            return fieldvalue.format('dd/MM/YYYY');
        }
    }
    public static String returnFieldvalueDecimal(Decimal fieldvalue)
    {
        if (fieldvalue == null)
        {
            return '';
        }
        else
        {
            return String.valueof(fieldvalue);
        }
    }
    public static String returnFieldvalueCharges(Decimal fieldvalue)
    {
        if (fieldvalue == null || fieldvalue == 0)
        {
            return '0.000';
        }
        else
        {
            return String.valueof(fieldvalue);
        }
    }
    
    public static String getUnitRate(string fuelType, string qId, string pricingStr,String quoteType)
    {
        String rateStr = '';
        if(fuelType == 'Electricity')
        {
            //if(pricingStr.contains('HH 2 Rate'))
            {
                if(qtProdListMap.containsKey(qId) && qtProdListMap.get(qId) != null && qtProdListMap.get(qId).size() >0 && qtProdListMap.get(qId).size() <=6 && quoteType != 'FLEXIBLE')
                {
                    Integer count = 0;
                    for(QuoteLineItem qli:qtProdListMap.get(qId))
                    {
                        rateStr = rateStr + 
                        SEP + qli.PricebookEntry.Product2.Name +
                        SEP + (qli.vlocity_cmt__UsageUnitPrice__c!=null?(String.valueOf(qli.vlocity_cmt__UsageUnitPrice__c).contains(',')?String.valueOf(qli.vlocity_cmt__UsageUnitPrice__c.setScale(3)).replace(',',''):String.valueOf(qli.vlocity_cmt__UsageUnitPrice__c.setScale(3))):'0.000');
                        count++;
                    }
                    if(count != 6)
                    {
                        for(Integer j=0;j<(6-count);j++)
                        {
                            rateStr = rateStr+
                            SEP + NUL +
                            SEP + NUL;
                            //j++;
                        }
                    }
                }
                else
                {
                    rateStr = SEP + NUL +
                    SEP + NUL +
                    SEP + NUL +
                    SEP + NUL +
                    SEP + NUL +
                    SEP + NUL +
                    SEP + NUL +
                    SEP + NUL +
                    SEP + NUL +
                    SEP + NUL +
                    SEP + NUL +
                    SEP + NUL;
                }
            }
        }
        else
        {
            rateStr = SEP + NUL +
                    SEP + NUL +
                    SEP + NUL +
                    SEP + NUL +
                    SEP + NUL +
                    SEP + NUL +
                    SEP + NUL +
                    SEP + NUL +
                    SEP + NUL +
                    SEP + NUL +
                    SEP + NUL +
                    SEP + NUL;
        }
        return rateStr;
    }
    
    public static String getItemPrices(string fuelType,String cq_ID,String cq_SWAN_Pricing_Structure,String quoteType,string StandingCharge, string unitRate,String availCharge,String rectype)
    {
        String itemPriceStr = '';
        if(quoteType == 'FLEXIBLE' && (rectype == 'Acquisition' || rectype == 'Renewal'|| rectype == 'Upgrade'))
        {   
            if(fuelType == 'Electricity')
            {
                //Do not populate items 259 - 274 which are present for FIXED
                
                    itemPriceStr =SEP + NUL + 
                        SEP + NUL +
                        SEP + NUL + 
                        SEP + NUL + 
                        getUnitRate(fuelType, cq_Id, cq_SWAN_Pricing_Structure,quoteType) + 
                        SEP + NUL +
                        SEP + NUL +
                        SEP + NUL;
                    
            }
            else
            {
                System.debug('In flex gas');
                //Do not populate items 275 - 277 which are present for FIXED
                itemPriceStr = SEP + NUL +
                        SEP + NUL +
                        SEP + NUL + 
                        SEP + NUL + 
                        getUnitRate(fuelType, cq_Id, cq_SWAN_Pricing_Structure,quoteType) +
                        SEP + NUL +
                        SEP + NUL + 
                        SEP + NUL ;
            }
        }
        else{
            itemPriceStr = SEP + (fuelType=='Gas'?NUL:'Standing Charge') +
                        SEP + (fuelType=='Gas'?NUL:(StandingCharge.contains(',')?StandingCharge.replace(',',''):StandingCharge)) +
                        SEP + (fuelType=='Gas'?NUL:((availCharge!=null && availCharge!='')?'Availability Charge':NUL)) +
                        SEP + (fuelType=='Gas'?NUL:(availCharge.contains(',')?availCharge.replace(',',''):availCharge)) +
                        getUnitRate(fuelType, cq_Id, cq_SWAN_Pricing_Structure,quoteType) + 
                        SEP + (fuelType=='Gas'?(unitRate.contains(',')?unitRate.replace(',',''):unitRate):NUL) + 
                        SEP + (fuelType=='Gas'?(StandingCharge.contains(',')?StandingCharge.replace(',',''):StandingCharge):NUL) +
                        SEP + NUL;
        }
        return itemPriceStr;
    }
}