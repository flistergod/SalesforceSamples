@isTest
public with sharing class SWAN_ExtractSubQuoteCountTest {

	  public static Quote masterQuote = new Quote();
    public static Quote masterQuote1 = new Quote();
    public static Opportunity opp = new Opportunity();
    public static Contact con = new Contact();
    public static Contract cont = new Contract();
    public static Contract cont_withoutcli = new Contract();
    public static List<Id> spList = new List<Id>();
    public static QuoteLineItem qli = new QuoteLineItem();

  @testSetup 
  static void createMokeData(){
  
      Account acc= new Account();
      acc.Name='TomWalkerLeaveALightOn Acquisition Offer acc';
      acc.SWAN_Customer_Segment__c='Enterprise';
      acc.SWAN_Micro_Business_Selection__c ='Micro_Business';
      insert acc;

 
      opp.Name='TomWalkerLeaveALightOn Acquisition Offer opp';
      opp.RecordTypeId='0124J000000YlVoQAK';
      opp.StageName='Qualification';
	    opp.AccountId = acc.Id;	
      opp.CloseDate=date.parse('31/12/2021');
      insert opp;

	    con.AccountId = acc.Id;
      con.lastName = 'Last Name';
      con.firstname ='Fname';
      con.MailingStreet='M street';
      con.MailingPostalCode='M50 2HX';
      con.SWAN_Mailing_Building_Name__c='Building name'; 
      con.MailingCity = 'test City';
      insert con;

	    List<Quote> masterQuoteList = new List<Quote>();
    
      masterQuote1.OpportunityId = opp.Id;
      masterQuote1.Name = 'Master Quote 1';
      masterQuote1.SWAN_Pricing_Structure__c = 'Site Specific With Standing Charge';
      masterQuote1.SWAN_Payment_Method_and_Term__c = 'Direct Debit - 14 Days';
      masterQuote1.SWAN_Offer_Start_Date__c = Date.today();
      masterQuote1.SWAN_Offer_End_Date__c = Date.newInstance(date.today().year()+1, date.today().month(), date.today().Day());
      masterQuote1.SWAN_Number_of_Service_Points__c = 2;
      masterQuote1.Status = 'Draft';
      masterQuoteList.add(masterQuote1);
      
      Quote masterQuote2 = new Quote();
      masterQuote2.OpportunityId = opp.Id;
      masterQuote2.Name = 'Master Quote 2';
      masterQuote2.SWAN_Pricing_Structure__c = 'Site Specific Without Standing Charge';
      masterQuote2.SWAN_Payment_Method_and_Term__c = 'Direct Debit - 14 Days';
      masterQuote2.SWAN_Offer_Start_Date__c = Date.today();
      masterQuote2.SWAN_Offer_End_Date__c = Date.newInstance(date.today().year()+1, date.today().month(), date.today().Day());
      masterQuote2.SWAN_Number_of_Service_Points__c = 2;
      masterQuote2.Status = 'Draft';
      masterQuoteList.add(masterQuote2);
      insert masterQuoteList;
    
      vlocity_cmt__Premises__c premise = new vlocity_cmt__Premises__c();
      insert premise;
    
      Product2 prod_FixedPriceGas = new Product2(Name = 'Fixed Price Gas',ProductCode='BG_GAS', vlocity_cmt__Type__c = 'Gas');
      insert prod_FixedPriceGas;
      
      Product2 prod_StandingCharge = new Product2(Name = 'Standing Charge',ProductCode='BG_STD');
      insert prod_StandingCharge;
      
      Product2 prod_UnitRate = new Product2(Name = 'Unit Rate',ProductCode='BG_UNITRATE');
      insert prod_UnitRate;
      
      PriceBook2 pb = new PriceBook2();
      pb.name = 'Example Price Book';
      //pb.isStandard = true;
      pb.IsActive = true;
      insert pb;
    
      Id pricebookId = Test.getStandardPricebookId();

      PricebookEntry standardPriceBookEntry = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prod_FixedPriceGas.Id,
            UnitPrice = 100.00,
            UseStandardPrice = false,
            IsActive = true
        );

        insert standardPriceBookEntry;
        
        PricebookEntry standardPriceBookEntry1 = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prod_StandingCharge.Id,
            UnitPrice = 100.00,
            UseStandardPrice = false,
            IsActive = true
        );

        insert standardPriceBookEntry1;
        
        PricebookEntry standardPriceBookEntry2 = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prod_UnitRate.Id,
            UnitPrice = 100.00,
            UseStandardPrice = false,
            IsActive = true
        );

        insert standardPriceBookEntry2;
        
        PriceBookEntry pbe = new PricebookEntry();
        pbe.product2Id = prod_FixedPriceGas.Id;
        pbe.Pricebook2Id = pb.Id;
        pbe.IsActive = true;
        pbe.Unitprice =0;
        pbe.UseStandardPrice = false;
        insert pbe;
        
        PriceBookEntry pbeStd = new PricebookEntry();
        pbeStd.product2Id = prod_StandingCharge.Id;
        pbeStd.Pricebook2Id = pb.Id;
        pbeStd.IsActive = true;
        pbeStd.Unitprice =0;
        pbeStd.UseStandardPrice = false;
        insert pbeStd;
        
        PriceBookEntry pbeUR = new PricebookEntry();
        pbeUR.product2Id = prod_UnitRate.Id;
        pbeUR.Pricebook2Id = pb.Id;
        pbeUR.IsActive = true;
        pbeUR.Unitprice =0;
        pbeUR.UseStandardPrice = false;
        insert pbeUR;
    
        vlocity_cmt__ServicePoint__c servicePoint = new vlocity_cmt__ServicePoint__c();
        servicePoint.SWAN_Formula_Year_Annual_Quantity__c = 12331;
        servicePoint.SWAN_Formula_Year_Offtake_Quantity__c = 3321;
        servicePoint.vlocity_cmt__ServicePointNumber__c = '1231231231';
        servicePoint.vlocity_cmt__PremisesId__c = premise.id;
        servicePoint.SWAN_Product_Class__c = '3';
        insert servicePoint;
        spList.add(servicePoint.id);
        
        vlocity_cmt__ServicePoint__c servicePoint_1 = new vlocity_cmt__ServicePoint__c();
        servicePoint_1.SWAN_Formula_Year_Annual_Quantity__c = 12331;
        servicePoint_1.SWAN_Formula_Year_Offtake_Quantity__c = 3321;
        servicePoint_1.vlocity_cmt__ServicePointNumber__c = '1231231232';
        servicePoint_1.vlocity_cmt__PremisesId__c = premise.id;
        servicePoint_1.SWAN_Product_Class__c = '3';
        insert servicePoint_1;
        spList.add(servicePoint_1.id);
        
        Quote childQuote = new Quote();
        childQuote.vlocity_cmt__ParentQuoteId__c = masterQuote1.id;
        childQuote.vlocity_cmt__DefaultServicePointId__c = servicePoint.id;
        childQuote.SWAN_Service_Point_Start_Date__c = date.today();
        childQuote.name = 'child quote';
        childQuote.OpportunityId = opp.id;
        childQuote.pricebook2Id = pb.Id;
        insert childQuote;
        
        Quote childQuote_1 = new Quote();
        childQuote_1.vlocity_cmt__ParentQuoteId__c = masterQuote1.id;
        childQuote_1.vlocity_cmt__DefaultServicePointId__c = servicePoint_1.id;
        childQuote_1.SWAN_Service_Point_Start_Date__c = date.today();
        childQuote_1.name = 'child quote';
        childQuote_1.OpportunityId = opp.id;
        childQuote_1.pricebook2Id = pb.Id;
        insert childQuote_1;
        
        OpportunityLineItem opp_line_item = new OpportunityLineItem();
        opp_line_item.vlocity_cmt__ServicePointId__c = servicePoint.id;
        opp_line_item.OpportunityId = opp.Id;
        opp_line_item.Quantity = 2;
        opp_line_item.PriceBookEntryId=pbe.Id;
        opp_line_item.UnitPrice=10;
        insert opp_line_item;

        qli.Product2Id = prod_FixedPriceGas.Id;
          qli.QuoteId = childQuote.Id;
          qli.UnitPrice = 0;
          qli.Quantity = 1;
          qli.PricebookEntryId = pbe.Id;
          String json = '{' + 
          '\"SWAN_SP_ATT_CAT\":[' +
          '{'+
          ' \"attributedisplayname__c\":\"Customer AQ\",'+
          ' \"isactive__c\":true,'+
          ' \"attributeRunTimeInfo\":'+
          '{'+
          ' \"value\":9999'+
          '}'+
          '},'+
          '{' +
          ' \"attributedisplayname__c\":\"Customer AQ Effective From Date\",'+
          ' \"attributeRunTimeInfo\":'+
          '{'+
          ' \"value\":\"2020-04-01T00:00:00.000Z\"'+'}'+'},'+
          '{'+
          ' \"attributedisplayname__c\":\"Customer AQ Effective To Date\",'+
          ' \"attributeRunTimeInfo\":'+
          '{'+
          ' \"value\":'+
          ' \"2021-03-31T23:59:59.000Z\"'+'}'+'},'+
          '{'+
          ' \"attributedisplayname__c\":'+
          ' \"Customer EUC\",'+
          ' \"attributeRunTimeInfo\":'+
          '{'+
          ' \"value\":'+
          ' \"15810\"'+
          '}'+
          '},'+
          '{'+
          ' \"attributedisplayname__c\":'+
          ' \"Customer SOQ\",'+
          ' \"attributeRunTimeInfo\":'+
          '{'+
          ' \"value\":8888'+
          '}'+'}'+']'+'}';

          qli.vlocity_cmt__JSONAttribute__c  = json;
          insert qli;
          
          QuoteLineItem qliStd = new QuoteLineItem();
          qliStd.Product2Id = prod_StandingCharge.Id;
          qliStd.QuoteId = childQuote.Id;
          qliStd.UnitPrice = 0;
          qliStd.Quantity = 1;
          qliStd.vlocity_cmt__recurringcharge__c = 77.7;
          qliStd.PricebookEntryId = pbeStd.Id;
          insert qliStd;
          
          QuoteLineItem qliUR = new QuoteLineItem();
          qliUR.Product2Id = prod_UnitRate.Id;
          qliUR.QuoteId = childQuote.Id;
          qliUR.UnitPrice = 0;
          qliUR.Quantity = 1;
          qliUR.SWAN_UnitRate__c = 88.8;
          qliUR.PricebookEntryId = pbeUR.Id;
          insert qliUR;
          
          QuoteLineItem qli_1 = new QuoteLineItem();
          qli_1.Product2Id = prod_FixedPriceGas.Id;
          qli_1.QuoteId = childQuote_1.Id;
          qli_1.UnitPrice = 0;
          qli_1.Quantity = 1;
          qli_1.PricebookEntryId = pbe.Id;
          qli_1.vlocity_cmt__JSONAttribute__c  = json;
          insert qli_1;
          
          QuoteLineItem qliStd_1 = new QuoteLineItem();
          qliStd_1.Product2Id = prod_StandingCharge.Id;
          qliStd_1.QuoteId = childQuote_1.Id;
          qliStd_1.UnitPrice = 0;
          qliStd_1.Quantity = 1;
          qliStd_1.vlocity_cmt__recurringcharge__c = 77.7;
          qliStd_1.PricebookEntryId = pbeStd.Id;
          insert qliStd_1;
          
          QuoteLineItem qliUR_1 = new QuoteLineItem();
          qliUR_1.Product2Id = prod_UnitRate.Id;
          qliUR_1.QuoteId = childQuote_1.Id;
          qliUR_1.UnitPrice = 0;
          qliUR_1.Quantity = 1;
          qliUR_1.SWAN_UnitRate__c = 88.8;
          qliUR_1.PricebookEntryId = pbeUR.Id;
          insert qliUR_1;
          
          vlocity_cmt__DRBundle__c dr = new vlocity_cmt__DRBundle__c();
          dr.Name = 'SWAN_ExtractContractAndAccount';
          dr.vlocity_cmt__BatchSize__c = 200;
          dr.vlocity_cmt__DRMapName__c = 'SWAN_ExtractContractAndAccount';
          dr.vlocity_cmt__InterfaceObject__c ='json';
          dr.vlocity_cmt__IsDefaultForInterface__c = false;
          dr.vlocity_cmt__IsProcessSuperBulk__c = false;
          dr.vlocity_cmt__InputType__c ='JSON';
          dr.vlocity_cmt__OutputType__c ='JSON';
          dr.vlocity_cmt__Type__c='Extract';
          insert dr;
          system.debug('DR inserted'+dr);
          
          cont.vlocity_cmt__QuoteId__c = masterQuote1.id;
          cont.EndDate = masterQuote1.SWAN_Offer_End_Date__c;
          cont.SWAN_Offer_End_Date__c = masterQuote1.SWAN_Offer_End_Date__c;
          cont.StartDate = masterQuote1.SWAN_Offer_Start_Date__c;
          cont.SWAN_Offer_Start_Date__c = masterQuote1.SWAN_Offer_Start_Date__c;
          cont.vlocity_cmt__OpportunityId__c = opp.Id;
          cont.AccountId = acc.Id;
          cont.SWAN_Number_of_Service_Points__c = 1;
          cont.SWAN_Contract_Volume_KWh__c = 10000;
          cont.status ='Draft';
          insert cont;

          
          cont_withoutcli.vlocity_cmt__QuoteId__c = masterQuote1.id;
          cont_withoutcli.EndDate = masterQuote1.SWAN_Offer_End_Date__c;
          cont_withoutcli.SWAN_Offer_End_Date__c = masterQuote1.SWAN_Offer_End_Date__c;
          cont_withoutcli.StartDate = masterQuote1.SWAN_Offer_Start_Date__c;
          cont_withoutcli.SWAN_Offer_Start_Date__c = masterQuote1.SWAN_Offer_Start_Date__c;
          cont_withoutcli.vlocity_cmt__OpportunityId__c = opp.Id;
          cont_withoutcli.AccountId = acc.Id;
          cont_withoutcli.status ='Draft';
          insert cont_withoutcli;

          
          vlocity_cmt__ContractLineItem__c cli_in_for = new vlocity_cmt__ContractLineItem__c();
          cli_in_for.SWAN_Contract_Volume__c = childQuote.swan_contract_volume_kwh__c;
          cli_in_for.SWAN_Quote__c  = childQuote.Id;
          cli_in_for.Name  = childQuote.name;
          Date spEndDate = Date.newInstance(date.today().year()+1, date.today().month(), date.today().Day());
          String clidate = String.valueOf(spEndDate)+' 22:59:00';
          cli_in_for.vlocity_cmt__EffectiveEndDate__c  = DateTime.valueOfGMT(clidate);
          cli_in_for.SWAN_Service_Point_End_Date__c  = childQuote.swan_service_point_end_date__c;
          cli_in_for.vlocity_cmt__EffectiveStartDate__c  = childQuote.swan_service_point_start_date__c;
          cli_in_for.SWAN_Service_Point_Start_Date__c  = childQuote.swan_service_point_start_date__c;
          cli_in_for.SWAN_Service_Point__c  = childQuote.swan_service_point__c;
          cli_in_for.SWAN_Service_Point__c  = childQuote.vlocity_cmt__DefaultServicePointId__c;
          cli_in_for.vlocity_cmt__ContractId__c  = cont.Id;       
          insert cli_in_for;
          
          vlocity_cmt__ContractLineItem__c child_cli_in_for = new vlocity_cmt__ContractLineItem__c();
          child_cli_in_for.SWAN_ListPrice__c  = qli.listprice;
          child_cli_in_for.vlocity_cmt__PricebookEntryId__c  = qli.pricebookentryid;
          child_cli_in_for.vlocity_cmt__Product2Id__c  = qli.product2id;
          child_cli_in_for.vlocity_cmt__Quantity__c  = qli.quantity;
          child_cli_in_for.vlocity_cmt__RecurringCharge__c  = qli.vlocity_cmt__recurringcharge__c;
          child_cli_in_for.vlocity_cmt__UnitPrice__c  = qli.UnitPrice;
          child_cli_in_for.SWAN_UnitRate__c  = qli.SWAN_UnitRate__c;
          child_cli_in_for.vlocity_cmt__ContractId__c  = cont.Id;
          child_cli_in_for.vlocity_cmt__OriginalLineItemId__c  = cli_in_for.id;
          child_cli_in_for.vlocity_cmt__EffectiveEndDate__c  = cli_in_for.vlocity_cmt__EffectiveEndDate__c;
          child_cli_in_for.vlocity_cmt__EffectiveStartDate__c  = cli_in_for.vlocity_cmt__EffectiveStartDate__c;
          insert child_cli_in_for;
    
          vlocity_cmt__ContractLineItem__c child_cli_in_for1 = new vlocity_cmt__ContractLineItem__c();
          child_cli_in_for1.SWAN_ListPrice__c  = qliUR.listprice;
          child_cli_in_for1.vlocity_cmt__PricebookEntryId__c  = qliUR.pricebookentryid;
          child_cli_in_for1.vlocity_cmt__Product2Id__c  = qliUR.product2id;
          child_cli_in_for1.vlocity_cmt__Quantity__c  = qliUR.quantity;
          child_cli_in_for1.vlocity_cmt__RecurringCharge__c  = qli.vlocity_cmt__recurringcharge__c;
          child_cli_in_for1.vlocity_cmt__UnitPrice__c  = qli.UnitPrice;
          child_cli_in_for1.SWAN_UnitRate__c  = qliUR.SWAN_UnitRate__c;
          child_cli_in_for1.vlocity_cmt__ContractId__c  = cont.Id;
          child_cli_in_for1.vlocity_cmt__OriginalLineItemId__c  = cli_in_for.id;
          child_cli_in_for1.vlocity_cmt__EffectiveEndDate__c  = cli_in_for.vlocity_cmt__EffectiveEndDate__c;
          child_cli_in_for1.vlocity_cmt__EffectiveStartDate__c  = cli_in_for.vlocity_cmt__EffectiveStartDate__c;
          insert child_cli_in_for1;
          
          vlocity_cmt__ContractLineItem__c child_cli_in_for2 = new vlocity_cmt__ContractLineItem__c();
          child_cli_in_for2.SWAN_ListPrice__c  = qliStd.listprice;
          child_cli_in_for2.vlocity_cmt__PricebookEntryId__c  = qliStd.pricebookentryid;
          child_cli_in_for2.vlocity_cmt__Product2Id__c  = qliStd.product2id;
          child_cli_in_for2.vlocity_cmt__Quantity__c  = qliStd.quantity;
          child_cli_in_for2.vlocity_cmt__RecurringCharge__c  = qliStd.vlocity_cmt__recurringcharge__c;
          child_cli_in_for2.vlocity_cmt__UnitPrice__c  = qli.UnitPrice;
          child_cli_in_for2.SWAN_UnitRate__c  = qli.SWAN_UnitRate__c;
          child_cli_in_for2.vlocity_cmt__ContractId__c  = cont.Id;
          child_cli_in_for2.vlocity_cmt__OriginalLineItemId__c  = cli_in_for.id;
          child_cli_in_for2.vlocity_cmt__EffectiveEndDate__c  = cli_in_for.vlocity_cmt__EffectiveEndDate__c;
          child_cli_in_for2.vlocity_cmt__EffectiveStartDate__c  = cli_in_for.vlocity_cmt__EffectiveStartDate__c;
          insert child_cli_in_for2;
              
          
          vlocity_cmt__ContractLineItem__c cli_in_for_1 = new vlocity_cmt__ContractLineItem__c();
          cli_in_for_1.SWAN_Contract_Volume__c = childQuote_1.swan_contract_volume_kwh__c;
          cli_in_for_1.SWAN_Quote__c  = childQuote_1.Id;
          cli_in_for_1.Name  = childQuote_1.name;
          Date spEndDate_1 = Date.newInstance(date.today().year()+1, date.today().month(), date.today().Day());
          String clidate_1 = String.valueOf(spEndDate_1)+' 22:59:00';
          cli_in_for_1.vlocity_cmt__EffectiveEndDate__c  = DateTime.valueOfGMT(clidate_1);
          cli_in_for_1.SWAN_Service_Point_End_Date__c  = childQuote_1.swan_service_point_end_date__c;
          cli_in_for_1.vlocity_cmt__EffectiveStartDate__c  = childQuote_1.swan_service_point_start_date__c;
          cli_in_for_1.SWAN_Service_Point_Start_Date__c  = childQuote_1.swan_service_point_start_date__c;
          cli_in_for_1.SWAN_Service_Point__c  = childQuote_1.swan_service_point__c;
          cli_in_for_1.SWAN_Service_Point__c  = childQuote_1.vlocity_cmt__DefaultServicePointId__c;
          cli_in_for_1.vlocity_cmt__ContractId__c  = cont.Id;
          cli_in_for_1.vlocity_cmt__LineStatus__c ='Inactive';
          insert cli_in_for_1;
          
          vlocity_cmt__ContractLineItem__c child_cli_in_for_1 = new vlocity_cmt__ContractLineItem__c();
          child_cli_in_for_1.SWAN_ListPrice__c  = qli_1.listprice;
          child_cli_in_for_1.vlocity_cmt__PricebookEntryId__c  = qli_1.pricebookentryid;
          child_cli_in_for_1.vlocity_cmt__Product2Id__c  = qli_1.product2id;
          child_cli_in_for_1.vlocity_cmt__Quantity__c  = qli_1.quantity;
          child_cli_in_for_1.vlocity_cmt__RecurringCharge__c  = qli_1.vlocity_cmt__recurringcharge__c;
          child_cli_in_for_1.vlocity_cmt__UnitPrice__c  = qli_1.UnitPrice;
          child_cli_in_for_1.SWAN_UnitRate__c  = qli_1.SWAN_UnitRate__c;
          child_cli_in_for_1.vlocity_cmt__ContractId__c  = cont.Id;
          child_cli_in_for_1.vlocity_cmt__OriginalLineItemId__c  = cli_in_for_1.id;
          child_cli_in_for_1.vlocity_cmt__EffectiveEndDate__c  = cli_in_for_1.vlocity_cmt__EffectiveEndDate__c;
          child_cli_in_for_1.vlocity_cmt__EffectiveStartDate__c  = cli_in_for_1.vlocity_cmt__EffectiveStartDate__c;
          child_cli_in_for_1.vlocity_cmt__LineStatus__c ='Inactive';
          insert child_cli_in_for_1;
          
          vlocity_cmt__ContractLineItem__c child_cli_in_for1_1 = new vlocity_cmt__ContractLineItem__c();
          child_cli_in_for1_1.SWAN_ListPrice__c  = qliUR_1.listprice;
          child_cli_in_for1_1.vlocity_cmt__PricebookEntryId__c  = qliUR_1.pricebookentryid;
          child_cli_in_for1_1.vlocity_cmt__Product2Id__c  = qliUR_1.product2id;
          child_cli_in_for1_1.vlocity_cmt__Quantity__c  = qliUR_1.quantity;
          child_cli_in_for1_1.vlocity_cmt__RecurringCharge__c  = qli_1.vlocity_cmt__recurringcharge__c;
          child_cli_in_for1_1.vlocity_cmt__UnitPrice__c  = qli_1.UnitPrice;
          child_cli_in_for1_1.SWAN_UnitRate__c  = qliUR_1.SWAN_UnitRate__c;
          child_cli_in_for1_1.vlocity_cmt__ContractId__c  = cont.Id;
          child_cli_in_for1_1.vlocity_cmt__OriginalLineItemId__c  = cli_in_for_1.id;
          child_cli_in_for1_1.vlocity_cmt__EffectiveEndDate__c  = cli_in_for_1.vlocity_cmt__EffectiveEndDate__c;
          System.debug('child_cli_in_for1_1.vlocity_cmt__EffectiveEndDate__c'+child_cli_in_for1_1.vlocity_cmt__EffectiveEndDate__c);
          child_cli_in_for1_1.vlocity_cmt__EffectiveStartDate__c  = cli_in_for_1.vlocity_cmt__EffectiveStartDate__c;
          child_cli_in_for1_1.vlocity_cmt__LineStatus__c ='Inactive';
          insert child_cli_in_for1_1;
          
          vlocity_cmt__ContractLineItem__c child_cli_in_for2_1 = new vlocity_cmt__ContractLineItem__c();
          child_cli_in_for2_1.SWAN_ListPrice__c  = qliStd_1.listprice;
          child_cli_in_for2_1.vlocity_cmt__PricebookEntryId__c  = qliStd_1.pricebookentryid;
          child_cli_in_for2_1.vlocity_cmt__Product2Id__c  = qliStd_1.product2id;
          child_cli_in_for2_1.vlocity_cmt__Quantity__c  = qliStd_1.quantity;
          child_cli_in_for2_1.vlocity_cmt__RecurringCharge__c  = qliStd_1.vlocity_cmt__recurringcharge__c;
          child_cli_in_for2_1.vlocity_cmt__UnitPrice__c  = qli_1.UnitPrice;
          child_cli_in_for2_1.SWAN_UnitRate__c  = qli_1.SWAN_UnitRate__c;
          child_cli_in_for2_1.vlocity_cmt__ContractId__c  = cont.Id;
          child_cli_in_for2_1.vlocity_cmt__OriginalLineItemId__c  = cli_in_for_1.id;
          child_cli_in_for2_1.vlocity_cmt__EffectiveEndDate__c  = cli_in_for_1.vlocity_cmt__EffectiveEndDate__c;
          System.debug('child_cli_in_for2_1.vlocity_cmt__EffectiveEndDate__c'+child_cli_in_for2_1.vlocity_cmt__EffectiveEndDate__c);
          child_cli_in_for2_1.vlocity_cmt__EffectiveStartDate__c  = cli_in_for_1.vlocity_cmt__EffectiveStartDate__c;
          child_cli_in_for2_1.vlocity_cmt__LineStatus__c ='Inactive';
          insert child_cli_in_for2_1;
    
          SWAN_CLI_Statuses__c clistatuses = new SWAN_CLI_Statuses__c();
          clistatuses.SWAN_Cancelled__c = 'Cancelled';
          clistatuses.SWAN_Terminated__c = 'Terminated';
          insert clistatuses;
          
          Quote q = new Quote();
          q.Name='TomWalkerLeaveALightOn Acquisition Offer quote';
          q.OpportunityId=opp.Id;
          insert q;

          Quote q_child = new Quote();
          q_child.Name='TomWalkerLeaveALightOn Acquisition Offer quote_child';
          q_child.OpportunityId=opp.Id;
          q_child.vlocity_cmt__ParentQuoteId__c=q.Id;
          insert q_child;

          Contract c= new Contract();
          c.AccountId=acc.Id;
          c.Name='TomWalkerLeaveALightOn Acquisition Offer contract';
          c.EndDate=date.parse('14/11/2021');
          c.StartDate=date.parse('14/09/2021');
          c.Status='Draft';
          c.vlocity_cmt__ContractType__c='';
          c.vlocity_cmt__OpportunityId__c=opp.Id;
          insert c;
      

          vlocity_cmt__ServicePoint__c sp= new vlocity_cmt__ServicePoint__c();
          sp.vlocity_cmt__ServicePointNumber__c='938249102';
          sp.vlocity_cmt__PremisesId__c=premise.Id;
          sp.Name='sp_938249102';
          insert sp;
          
          List<vlocity_cmt__ContractLineItem__c> clis= new List<vlocity_cmt__ContractLineItem__c>();


          for(Integer i=5;i<10;i++){
          
          vlocity_cmt__ContractLineItem__c cli= new vlocity_cmt__ContractLineItem__c();
          cli.Name=c.Name+'_'+String.valueOf(i);
          cli.vlocity_cmt__ContractId__c=c.Id;
          cli.SWAN_Service_Point__c=sp.Id;
          cli.SWAN_Service_Point_End_Date__c=c.EndDate;
          cli.vlocity_cmt__LineStatus__c='Inactive';
          cli.vlocity_cmt__EffectiveEndDate__c=c.EndDate;
          cli.vlocity_cmt__EffectiveStartDate__c=c.StartDate;
          cli.SWAN_Service_Point_Start_Date__c=c.StartDate;
          cli.vlocity_cmt__OriginalLineItemId__c=null;
          cli.SWAN_Quote__c=q_child.Id;

          clis.add(cli);

      }
          insert clis;

  }

  
   @isTest
  static void updateServicePointStatusCancelled(){
      
      Boolean resultGet;
      Boolean resultUpdate;
      Id cID=[Select Id from Contract limit 1][0].Id;
      String methodNameGet='getServicePointStatus';
      String methodNameUpdate='updateServicePointStatus';
      String process_Name = 'Cancelled';
      String needForMap= 'false';
      String lineStatus='Inactive';
      
      Map<String, Object> outputMap = new Map<String, Object>(); 
      Map<String, Object> options = new Map<String, Object>();
      Map<String, Object> inputMap = new Map<String, Object>();

      inputMap.put('ContextId', cID);
      inputMap.put('ContractStatus', lineStatus);
      inputMap.put('Processname', process_Name);
      inputMap.put('NeedForMap', needForMap);

      Test.startTest();

      SWAN_GetServicePointStatus getSps = new SWAN_GetServicePointStatus();
      resultGet=getSps.invokeMethod(methodNameGet, inputMap, outputMap, options);
      Integer numOfSps= (Integer) outputMap.get('NumberOfSps');

		  if(numOfSps>0){

  				inputMap.put('ContractLineItem',outputMap.get('ContractLineItem'));

          SWAN_ExtractSubQuoteCount updateSps = new SWAN_ExtractSubQuoteCount();
          resultUpdate=updateSps.invokeMethod(methodNameUpdate, inputMap, outputMap, options);
      
      }


      Test.stopTest();   
  }


  @isTest
  static void updateServicePointStatusTermination(){
      
      Boolean resultGet;
      Boolean resultUpdate;
      Id cID=[Select Id from Contract limit 1][0].Id;
      String methodNameGet='getServicePointStatus';
      String methodNameUpdate='updateServicePointStatus';
      String process_Name = 'Termination';
      String needForMap= 'false';
      String lineStatus='Inactive';
	    String final_status = 'Terminated';
      String terminatedEndDateTime = String.valueOf(cont.EndDate);
      
      Map<String, Object> outputMap = new Map<String, Object>(); 
      Map<String, Object> options = new Map<String, Object>();
      Map<String, Object> inputMap = new Map<String, Object>();

      inputMap.put('ContextId', cID);
      inputMap.put('ContractStatus', lineStatus);
      inputMap.put('Processname', process_Name);
      inputMap.put('NeedForMap', needForMap);
      inputMap.put('FinalStatus', final_status);
      inputMap.put('TerminatedEndDateTime', terminatedEndDateTime);
	  

      Test.startTest();

      SWAN_GetServicePointStatus getSps = new SWAN_GetServicePointStatus();
      resultGet=getSps.invokeMethod(methodNameGet, inputMap, outputMap, options);
      Integer numOfSps= (Integer) outputMap.get('NumberOfSps');


		  if(numOfSps>0){
		  
        inputMap.put('ContractLineItem',outputMap.get('ContractLineItem'));
  
        SWAN_ExtractSubQuoteCount updateSps = new SWAN_ExtractSubQuoteCount();
        resultUpdate=updateSps.invokeMethod(methodNameUpdate, inputMap, outputMap, options);
      
      }

      Test.stopTest();
  
  }


   @isTest
   static void updateSelectedServicePointStatusTermination(){
      
      Boolean resultGet;
      Boolean resultUpdate;
      Id cID=[Select Id from Contract limit 1][0].Id;
      String methodNameGet='getServicePointStatus';
      String methodNameUpdate='updateSelectedServicePointStatus';
      String process_Name = 'Termination';
      String needForMap= 'false';
	    String final_status = 'Terminated';
      String terminatedEndDateTime = String.valueOf(cont.EndDate);
      String lineStatus='Inactive';
      
      Map<String, Object> outputMap = new Map<String, Object>(); 
      Map<String, Object> options = new Map<String, Object>();
      Map<String, Object> inputMap = new Map<String, Object>();

      inputMap.put('ContextId', cID);
      inputMap.put('ContractStatus', lineStatus);
      inputMap.put('Processname', process_Name);
      inputMap.put('NeedForMap', needForMap);
      inputMap.put('FinalStatus', final_status);
      inputMap.put('TerminatedEndDateTime', terminatedEndDateTime);
		

      Test.startTest();

      SWAN_GetServicePointStatus getSps = new SWAN_GetServicePointStatus();
      resultGet=getSps.invokeMethod(methodNameGet, inputMap, outputMap, options);
      Integer numOfSps= (Integer) outputMap.get('NumberOfSps');

		  if(numOfSps>0){

      List <Object> selectedSps=(List<Object>)outputMap.get('ContractLineItem');
      inputMap.put('SelectedSpsJson',selectedSps);

      SWAN_ExtractSubQuoteCount updateSps = new SWAN_ExtractSubQuoteCount();
      resultUpdate=updateSps.invokeMethod(methodNameUpdate, inputMap, outputMap, options);
      
      }

      Test.stopTest();
  
  }

  @isTest
  static void updateSelectedServicePointStatusCancelled(){
      
      Boolean resultGet;
      Boolean resultUpdate;
      Id cID=[Select Id from Contract limit 1][0].Id;
      String methodNameGet='getServicePointStatus';
      String methodNameUpdate='updateSelectedServicePointStatus';
      String process_Name = 'Cancelled';
      String needForMap= 'false';
      String lineStatus='Inactive';
      
      Map<String, Object> outputMap = new Map<String, Object>(); 
      Map<String, Object> options = new Map<String, Object>();
      Map<String, Object> inputMap = new Map<String, Object>();

      inputMap.put('ContextId', cID);
      inputMap.put('ContractStatus', lineStatus);
      inputMap.put('Processname', process_Name);
      inputMap.put('NeedForMap', needForMap);
		

      Test.startTest();

      SWAN_GetServicePointStatus getSps = new SWAN_GetServicePointStatus();
      resultGet=getSps.invokeMethod(methodNameGet, inputMap, outputMap, options);
      Integer numOfSps= (Integer) outputMap.get('NumberOfSps');

		  if(numOfSps>0){

        List <Object> selectedSps=(List<Object>)outputMap.get('ContractLineItem');
        inputMap.put('SelectedSpsJson',selectedSps);
        
        SWAN_ExtractSubQuoteCount updateSps = new SWAN_ExtractSubQuoteCount();
        resultUpdate=updateSps.invokeMethod(methodNameUpdate, inputMap, outputMap, options);
      
      }

      Test.stopTest();
    
  }



    @isTest
    public static void createContractWithBulkSPTest()
    {

Test.startTest();
        
        Map<String, Object> inputMap = new Map<String, Object>();
        inputMap.put('isQuote',true);
        inputMap.put('ContextId',masterQuote1.id);
		Map<String, Object> outputMap = new Map<String, Object>(); 
        Map<String, Object> options = new Map<String, Object>();
        SWAN_ExtractSubQuoteCount  sub_Quote_count = new SWAN_ExtractSubQuoteCount();
        Boolean abc = sub_Quote_count.invokeMethod('getSubQuoteCount',inputMap,outputMap,options);
        SWAN_OverlapSP spTest = new SWAN_OverlapSP();
        Boolean xyz = sptest.invokeMethod('calculateOverlap',inputMap,outputMap,options);
        Boolean mno = sub_Quote_count.invokeMethod('createContract',inputMap,outputMap,options);
        Map<String, Object> inputMap1 = new Map<String, Object>();
        System.debug('ContractIdNinad2'+cont.Id);
        inputMap1.put('ContextId',cont.id);
        SWAN_ExtractContractLineItems extractContractLineItems = new SWAN_ExtractContractLineItems();
        Boolean pqr = extractContractLineItems.invokeMethod('getContractLineItemsInfo',inputMap1,outputMap,outputMap);
		Integer subQuotesSize=(Integer)outputMap.get('sub_Quotes_Size');

	
  Test.stopTest();

	//System.AssertEquals(abc, true, outputMap);
	System.AssertEquals(3, subQuotesSize, outputMap);
    }

    @isTest
    public static void createContractWithBulkSPTestBadMasterQuote(){

      Test.startTest();
        
        Map<String, Object> outputMap = new Map<String, Object>(); 
        Map<String, Object> options = new Map<String, Object>();
        Map<String, Object> inputMap = new Map<String, Object>();
        inputMap.put('isQuote',true);
        inputMap.put('ContextId','aedffdsf42424');
		    

        SWAN_ExtractSubQuoteCount  sub_Quote_count = new SWAN_ExtractSubQuoteCount();
        Boolean abc = sub_Quote_count.invokeMethod('getSubQuoteCount',inputMap,outputMap,options);
        SWAN_OverlapSP spTest = new SWAN_OverlapSP();

        Boolean xyz = sptest.invokeMethod('calculateOverlap',inputMap,outputMap,options);
        Boolean mno = sub_Quote_count.invokeMethod('createContract',inputMap,outputMap,options);

        Map<String, Object> inputMap1 = new Map<String, Object>();

        inputMap1.put('ContextId',cont.id);
        SWAN_ExtractContractLineItems extractContractLineItems = new SWAN_ExtractContractLineItems();
        
        Boolean pqr = extractContractLineItems.invokeMethod('getContractLineItemsInfo',inputMap1,outputMap,outputMap);
				Integer subQuotesSize=(Integer)outputMap.get('sub_Quotes_Size');
	
        Test.stopTest();

	      System.AssertEquals(0, subQuotesSize, outputMap);
    }

   @isTest
    public static void bulkCancelSPTest(){

        Test.startTest();

        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outputMap = new Map<String, Object>();

        inputMap.put('ContextId',cont.id);
        SWAN_GetServicePointStatus getServicePointStatus = new SWAN_GetServicePointStatus();

        Boolean pqr = getServicePointStatus.invokeMethod('getServicePointStatus',inputMap,outputMap,null);
        Map<String, Object> inputMap1 = new Map<String, Object>();
        inputMap1.put('SelectServicePoint',outputMap);

        Map<String, Object> outputMap1 = new Map<String, Object>();
        String termination = 'Cancelled';
        Object obj_termination = (Object)termination;
        String processname = 'Cancelled';
        Object obj_processname = (Object)processname;
       
        inputMap1.put('FinalStatus',obj_termination);
        inputMap1.put('Processname',obj_processname);

        SWAN_ExtractSubQuoteCount updateServicePointStatus = new SWAN_ExtractSubQuoteCount();
        Boolean stu = updateServicePointStatus.invokeMethod('updateServicePointStatus',inputMap1,outputMap1,null);

        Test.stopTest();
    }

    @isTest
    public static void bulkTerminateSPTest(){
        
        Test.startTest();
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outputMap = new Map<String, Object>();
 
        inputMap.put('ContextId',cont.id);
        SWAN_GetServicePointStatus getServicePointStatus = new SWAN_GetServicePointStatus();

        Boolean pqr = getServicePointStatus.invokeMethod('getServicePointStatusActive',inputMap,outputMap,null);
        
        Map<String, Object> inputMap1 = new Map<String, Object>();
        inputMap1.put('SelectServicePoint',outputMap);
        
        Map<String, Object> outputMap1 = new Map<String, Object>();
        String termination = 'Terminated';
        Object obj_termination = (Object)termination;
        String processname = 'Termination';
        Object obj_processname = (Object)processname;
        String terminatedEndDateTime = String.valueOf(date.today())+' 23:59:00';
        Object obj_terminatedEndDateTime = (Object)terminatedEndDateTime;

        inputMap1.put('FinalStatus',obj_termination);
        inputMap1.put('Processname',obj_processname);
        inputMap1.put('TerminatedEndDateTime',obj_terminatedEndDateTime);

        SWAN_ExtractSubQuoteCount updateServicePointStatus = new SWAN_ExtractSubQuoteCount();
        Boolean stu = updateServicePointStatus.invokeMethod('updateServicePointStatus',inputMap1,outputMap1,null);

        Test.stopTest();
        
    }
}