@isTest
public class SWAN_OverlapSPTest {

  public static Quote masterQuote = new Quote();
  public static Quote masterQuote1 = new Quote();
    public static Opportunity opp = new Opportunity();
    public static Contact con = new Contact();
    public static Contract cont = new Contract();
    public static Contract cont_withoutcli = new Contract();
    public static List<Id> spList = new List<Id>();
    public static QuoteLineItem qli = new QuoteLineItem();
  
  public static void createStaticDataWithOfferPack()
    {
        Account acc = new Account();
        acc.Name = 'Test Acc';
        acc.SWAN_Customer_Segment__c = 'I&C';
        acc.SWAN_Micro_Business_Selection__c = 'Non_Micro_Business';
        insert acc;
        
        opp.AccountId = acc.Id;
        opp.Name = 'Test Opp';
        opp.StageName = 'Prospecting';
        opp.CloseDate = date.today();
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
    
    //Quote masterQuote = new Quote();
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
    System.debug('ContractIdNinad'+cont.Id);
    
    cont_withoutcli.vlocity_cmt__QuoteId__c = masterQuote1.id;
    cont_withoutcli.EndDate = masterQuote1.SWAN_Offer_End_Date__c;
    cont_withoutcli.SWAN_Offer_End_Date__c = masterQuote1.SWAN_Offer_End_Date__c;
    cont_withoutcli.StartDate = masterQuote1.SWAN_Offer_Start_Date__c;
    cont_withoutcli.SWAN_Offer_Start_Date__c = masterQuote1.SWAN_Offer_Start_Date__c;
    cont_withoutcli.vlocity_cmt__OpportunityId__c = opp.Id;
    cont_withoutcli.AccountId = acc.Id;
    cont_withoutcli.status ='Draft';
    insert cont_withoutcli;
    System.debug('ContractIdNinad'+cont_withoutcli.Id);
    
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
    //child_cli_in_for.vlocity_cmt__LineNumber__c = qli.linenumber;
    child_cli_in_for.SWAN_ListPrice__c  = qli.listprice;
    child_cli_in_for.vlocity_cmt__PricebookEntryId__c  = qli.pricebookentryid;
    child_cli_in_for.vlocity_cmt__Product2Id__c  = qli.product2id;
    child_cli_in_for.vlocity_cmt__Quantity__c  = qli.quantity;
    child_cli_in_for.vlocity_cmt__RecurringCharge__c  = qli.vlocity_cmt__recurringcharge__c;
    child_cli_in_for.vlocity_cmt__UnitPrice__c  = qli.UnitPrice;
    child_cli_in_for.SWAN_UnitRate__c  = qli.SWAN_UnitRate__c;
   // child_cli_in_for.SWAN_UnitRateCalculatedPrice__c = qli.SWAN_UnitRateCalculatedPrice__c;
    //child_cli_in_for.SWAN_UnitRateDiscountPrice__c = qli.SWAN_UnitRateDiscountPrice__c;
   // child_cli_in_for.SWAN_UnitRateEffectiveUsageTotal__c  = qli.SWAN_UnitRateEffectiveUsageTotal__c;
    //child_cli_in_for.SWAN_UnitRateManualDiscount__c  = qli.SWAN_UnitRateManualDiscount__c;
   // child_cli_in_for.SWAN_UnitRateTotal__c  = qli.SWAN_UnitRateTotal__c;
   // child_cli_in_for.SWAN_UnitRateUOM__c  = qli.SWAN_UnitRateUOM__c;
    child_cli_in_for.vlocity_cmt__ContractId__c  = cont.Id;
    child_cli_in_for.vlocity_cmt__OriginalLineItemId__c  = cli_in_for.id;
    //String clidate = String.valueof(childQuote.SWAN_Service_Point_End_Date__c)+' 21:59:00';
    child_cli_in_for.vlocity_cmt__EffectiveEndDate__c  = cli_in_for.vlocity_cmt__EffectiveEndDate__c;
    System.debug('child_cli_in_for.vlocity_cmt__EffectiveEndDate__c'+child_cli_in_for.vlocity_cmt__EffectiveEndDate__c);
    child_cli_in_for.vlocity_cmt__EffectiveStartDate__c  = cli_in_for.vlocity_cmt__EffectiveStartDate__c;
    insert child_cli_in_for;
    
    vlocity_cmt__ContractLineItem__c child_cli_in_for1 = new vlocity_cmt__ContractLineItem__c();
    //child_cli_in_for1.vlocity_cmt__LineNumber__c = qli.linenumber;
    child_cli_in_for1.SWAN_ListPrice__c  = qliUR.listprice;
    child_cli_in_for1.vlocity_cmt__PricebookEntryId__c  = qliUR.pricebookentryid;
    child_cli_in_for1.vlocity_cmt__Product2Id__c  = qliUR.product2id;
    child_cli_in_for1.vlocity_cmt__Quantity__c  = qliUR.quantity;
    child_cli_in_for1.vlocity_cmt__RecurringCharge__c  = qli.vlocity_cmt__recurringcharge__c;
    child_cli_in_for1.vlocity_cmt__UnitPrice__c  = qli.UnitPrice;
    child_cli_in_for1.SWAN_UnitRate__c  = qliUR.SWAN_UnitRate__c;
   // child_cli_in_for1.SWAN_UnitRateCalculatedPrice__c = qli.SWAN_UnitRateCalculatedPrice__c;
    //child_cli_in_for1.SWAN_UnitRateDiscountPrice__c = qli.SWAN_UnitRateDiscountPrice__c;
   // child_cli_in_for1.SWAN_UnitRateEffectiveUsageTotal__c  = qli.SWAN_UnitRateEffectiveUsageTotal__c;
    //child_cli_in_for1.SWAN_UnitRateManualDiscount__c  = qli.SWAN_UnitRateManualDiscount__c;
   // child_cli_in_for1.SWAN_UnitRateTotal__c  = qli.SWAN_UnitRateTotal__c;
   // child_cli_in_for1.SWAN_UnitRateUOM__c  = qli.SWAN_UnitRateUOM__c;
    child_cli_in_for1.vlocity_cmt__ContractId__c  = cont.Id;
    child_cli_in_for1.vlocity_cmt__OriginalLineItemId__c  = cli_in_for.id;
    //String clidate = String.valueof(childQuote.SWAN_Service_Point_End_Date__c)+' 21:59:00';
    child_cli_in_for1.vlocity_cmt__EffectiveEndDate__c  = cli_in_for.vlocity_cmt__EffectiveEndDate__c;
    System.debug('child_cli_in_for1.vlocity_cmt__EffectiveEndDate__c'+child_cli_in_for1.vlocity_cmt__EffectiveEndDate__c);
    child_cli_in_for1.vlocity_cmt__EffectiveStartDate__c  = cli_in_for.vlocity_cmt__EffectiveStartDate__c;
    insert child_cli_in_for1;
    
    vlocity_cmt__ContractLineItem__c child_cli_in_for2 = new vlocity_cmt__ContractLineItem__c();
    //child_cli_in_for2.vlocity_cmt__LineNumber__c = qli.linenumber;
    child_cli_in_for2.SWAN_ListPrice__c  = qliStd.listprice;
    child_cli_in_for2.vlocity_cmt__PricebookEntryId__c  = qliStd.pricebookentryid;
    child_cli_in_for2.vlocity_cmt__Product2Id__c  = qliStd.product2id;
    child_cli_in_for2.vlocity_cmt__Quantity__c  = qliStd.quantity;
    child_cli_in_for2.vlocity_cmt__RecurringCharge__c  = qliStd.vlocity_cmt__recurringcharge__c;
    child_cli_in_for2.vlocity_cmt__UnitPrice__c  = qli.UnitPrice;
    child_cli_in_for2.SWAN_UnitRate__c  = qli.SWAN_UnitRate__c;
   // child_cli_in_for2.SWAN_UnitRateCalculatedPrice__c = qli.SWAN_UnitRateCalculatedPrice__c;
    //child_cli_in_for2.SWAN_UnitRateDiscountPrice__c = qli.SWAN_UnitRateDiscountPrice__c;
   // child_cli_in_for2.SWAN_UnitRateEffectiveUsageTotal__c  = qli.SWAN_UnitRateEffectiveUsageTotal__c;
    //child_cli_in_for2.SWAN_UnitRateManualDiscount__c  = qli.SWAN_UnitRateManualDiscount__c;
   // child_cli_in_for2.SWAN_UnitRateTotal__c  = qli.SWAN_UnitRateTotal__c;
   // child_cli_in_for2.SWAN_UnitRateUOM__c  = qli.SWAN_UnitRateUOM__c;
    child_cli_in_for2.vlocity_cmt__ContractId__c  = cont.Id;
    child_cli_in_for2.vlocity_cmt__OriginalLineItemId__c  = cli_in_for.id;
    //String clidate = String.valueof(childQuote.SWAN_Service_Point_End_Date__c)+' 21:59:00';
    child_cli_in_for2.vlocity_cmt__EffectiveEndDate__c  = cli_in_for.vlocity_cmt__EffectiveEndDate__c;
    System.debug('child_cli_in_for2.vlocity_cmt__EffectiveEndDate__c'+child_cli_in_for2.vlocity_cmt__EffectiveEndDate__c);
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
    cli_in_for_1.vlocity_cmt__LineStatus__c ='Active';
    insert cli_in_for_1;
    
    vlocity_cmt__ContractLineItem__c child_cli_in_for_1 = new vlocity_cmt__ContractLineItem__c();
    //child_cli_in_for_1.vlocity_cmt__LineNumber__c = qli.linenumber;
    child_cli_in_for_1.SWAN_ListPrice__c  = qli_1.listprice;
    child_cli_in_for_1.vlocity_cmt__PricebookEntryId__c  = qli_1.pricebookentryid;
    child_cli_in_for_1.vlocity_cmt__Product2Id__c  = qli_1.product2id;
    child_cli_in_for_1.vlocity_cmt__Quantity__c  = qli_1.quantity;
    child_cli_in_for_1.vlocity_cmt__RecurringCharge__c  = qli_1.vlocity_cmt__recurringcharge__c;
    child_cli_in_for_1.vlocity_cmt__UnitPrice__c  = qli_1.UnitPrice;
    child_cli_in_for_1.SWAN_UnitRate__c  = qli_1.SWAN_UnitRate__c;
   // child_cli_in_for_1.SWAN_UnitRateCalculatedPrice__c = qli.SWAN_UnitRateCalculatedPrice__c;
    //child_cli_in_for_1.SWAN_UnitRateDiscountPrice__c = qli.SWAN_UnitRateDiscountPrice__c;
   // child_cli_in_for_1.SWAN_UnitRateEffectiveUsageTotal__c  = qli.SWAN_UnitRateEffectiveUsageTotal__c;
    //child_cli_in_for_1.SWAN_UnitRateManualDiscount__c  = qli.SWAN_UnitRateManualDiscount__c;
   // child_cli_in_for_1.SWAN_UnitRateTotal__c  = qli.SWAN_UnitRateTotal__c;
   // child_cli_in_for_1.SWAN_UnitRateUOM__c  = qli.SWAN_UnitRateUOM__c;
    child_cli_in_for_1.vlocity_cmt__ContractId__c  = cont.Id;
    child_cli_in_for_1.vlocity_cmt__OriginalLineItemId__c  = cli_in_for_1.id;
    //String clidate = String.valueof(childQuote.SWAN_Service_Point_End_Date__c)+' 21:59:00';
    child_cli_in_for_1.vlocity_cmt__EffectiveEndDate__c  = cli_in_for_1.vlocity_cmt__EffectiveEndDate__c;
    System.debug('child_cli_in_for_1.vlocity_cmt__EffectiveEndDate__c'+child_cli_in_for_1.vlocity_cmt__EffectiveEndDate__c);
    child_cli_in_for_1.vlocity_cmt__EffectiveStartDate__c  = cli_in_for_1.vlocity_cmt__EffectiveStartDate__c;
    child_cli_in_for_1.vlocity_cmt__LineStatus__c ='Active';
    insert child_cli_in_for_1;
    
    vlocity_cmt__ContractLineItem__c child_cli_in_for1_1 = new vlocity_cmt__ContractLineItem__c();
    //child_cli_in_for1_1.vlocity_cmt__LineNumber__c = qli.linenumber;
    child_cli_in_for1_1.SWAN_ListPrice__c  = qliUR_1.listprice;
    child_cli_in_for1_1.vlocity_cmt__PricebookEntryId__c  = qliUR_1.pricebookentryid;
    child_cli_in_for1_1.vlocity_cmt__Product2Id__c  = qliUR_1.product2id;
    child_cli_in_for1_1.vlocity_cmt__Quantity__c  = qliUR_1.quantity;
    child_cli_in_for1_1.vlocity_cmt__RecurringCharge__c  = qli_1.vlocity_cmt__recurringcharge__c;
    child_cli_in_for1_1.vlocity_cmt__UnitPrice__c  = qli_1.UnitPrice;
    child_cli_in_for1_1.SWAN_UnitRate__c  = qliUR_1.SWAN_UnitRate__c;
   // child_cli_in_for1_1.SWAN_UnitRateCalculatedPrice__c = qli.SWAN_UnitRateCalculatedPrice__c;
    //child_cli_in_for1_1.SWAN_UnitRateDiscountPrice__c = qli.SWAN_UnitRateDiscountPrice__c;
   // child_cli_in_for1_1.SWAN_UnitRateEffectiveUsageTotal__c  = qli.SWAN_UnitRateEffectiveUsageTotal__c;
    //child_cli_in_for1_1.SWAN_UnitRateManualDiscount__c  = qli.SWAN_UnitRateManualDiscount__c;
   // child_cli_in_for1_1.SWAN_UnitRateTotal__c  = qli.SWAN_UnitRateTotal__c;
   // child_cli_in_for1_1.SWAN_UnitRateUOM__c  = qli.SWAN_UnitRateUOM__c;
    child_cli_in_for1_1.vlocity_cmt__ContractId__c  = cont.Id;
    child_cli_in_for1_1.vlocity_cmt__OriginalLineItemId__c  = cli_in_for_1.id;
    //String clidate = String.valueof(childQuote.SWAN_Service_Point_End_Date__c)+' 21:59:00';
    child_cli_in_for1_1.vlocity_cmt__EffectiveEndDate__c  = cli_in_for_1.vlocity_cmt__EffectiveEndDate__c;
    System.debug('child_cli_in_for1_1.vlocity_cmt__EffectiveEndDate__c'+child_cli_in_for1_1.vlocity_cmt__EffectiveEndDate__c);
    child_cli_in_for1_1.vlocity_cmt__EffectiveStartDate__c  = cli_in_for_1.vlocity_cmt__EffectiveStartDate__c;
    child_cli_in_for1_1.vlocity_cmt__LineStatus__c ='Active';
    insert child_cli_in_for1_1;
    
    vlocity_cmt__ContractLineItem__c child_cli_in_for2_1 = new vlocity_cmt__ContractLineItem__c();
    //child_cli_in_for2_1.vlocity_cmt__LineNumber__c = qli.linenumber;
    child_cli_in_for2_1.SWAN_ListPrice__c  = qliStd_1.listprice;
    child_cli_in_for2_1.vlocity_cmt__PricebookEntryId__c  = qliStd_1.pricebookentryid;
    child_cli_in_for2_1.vlocity_cmt__Product2Id__c  = qliStd_1.product2id;
    child_cli_in_for2_1.vlocity_cmt__Quantity__c  = qliStd_1.quantity;
    child_cli_in_for2_1.vlocity_cmt__RecurringCharge__c  = qliStd_1.vlocity_cmt__recurringcharge__c;
    child_cli_in_for2_1.vlocity_cmt__UnitPrice__c  = qli_1.UnitPrice;
    child_cli_in_for2_1.SWAN_UnitRate__c  = qli_1.SWAN_UnitRate__c;
   // child_cli_in_for2_1.SWAN_UnitRateCalculatedPrice__c = qli.SWAN_UnitRateCalculatedPrice__c;
    //child_cli_in_for2_1.SWAN_UnitRateDiscountPrice__c = qli.SWAN_UnitRateDiscountPrice__c;
   // child_cli_in_for2_1.SWAN_UnitRateEffectiveUsageTotal__c  = qli.SWAN_UnitRateEffectiveUsageTotal__c;
    //child_cli_in_for2_1.SWAN_UnitRateManualDiscount__c  = qli.SWAN_UnitRateManualDiscount__c;
   // child_cli_in_for2_1.SWAN_UnitRateTotal__c  = qli.SWAN_UnitRateTotal__c;
   // child_cli_in_for2_1.SWAN_UnitRateUOM__c  = qli.SWAN_UnitRateUOM__c;
    child_cli_in_for2_1.vlocity_cmt__ContractId__c  = cont.Id;
    child_cli_in_for2_1.vlocity_cmt__OriginalLineItemId__c  = cli_in_for_1.id;
    //String clidate = String.valueof(childQuote.SWAN_Service_Point_End_Date__c)+' 21:59:00';
    child_cli_in_for2_1.vlocity_cmt__EffectiveEndDate__c  = cli_in_for_1.vlocity_cmt__EffectiveEndDate__c;
    System.debug('child_cli_in_for2_1.vlocity_cmt__EffectiveEndDate__c'+child_cli_in_for2_1.vlocity_cmt__EffectiveEndDate__c);
    child_cli_in_for2_1.vlocity_cmt__EffectiveStartDate__c  = cli_in_for_1.vlocity_cmt__EffectiveStartDate__c;
    child_cli_in_for2_1.vlocity_cmt__LineStatus__c ='Active';
    insert child_cli_in_for2_1;
    
    SWAN_CLI_Statuses__c clistatuses = new SWAN_CLI_Statuses__c();
    clistatuses.SWAN_Cancelled__c = 'Cancelled';
    clistatuses.SWAN_Terminated__c = 'Terminated';
    insert clistatuses;
    
    /*    
    SWAN_Offer_Pack__c offerPack = new SWAN_Offer_Pack__c();
        offerPack.Contact__c = cont.id;
        offerPack.SWAN_Opportunity__c = opp.id;
        insert offerPack;
        
        List<SWAN_Offer_Pack_Quote__c> listOfferPackQuote = new List<SWAN_Offer_Pack_Quote__c>();
        SWAN_Offer_Pack_Quote__c opq1 = new SWAN_Offer_Pack_Quote__c();
        opq1.SWAN_Offer_Pack__c = offerPack.id;
        opq1.SWAN_Quote__c = masterQuote1.id;
        listOfferPackQuote.add(opq1);
        
        SWAN_Offer_Pack_Quote__c opq2 = new SWAN_Offer_Pack_Quote__c();
        opq2.SWAN_Offer_Pack__c = offerPack.id;
        opq2.SWAN_Quote__c = masterQuote2.id;
        listOfferPackQuote.add(opq2);
        
        insert listOfferPackQuote;
    
    masterQuote1.Status = 'Selected';
    update masterQuote1;
    
    Contract con1 = new Contract();
    con1.vlocity_cmt__QuoteId__c = masterQuote1.id;
    con1.AccountId = acc.Id;
    con1.status = 'Draft';
    insert con1;
    
    vlocity_cmt__ContractLineItem__c CLI = new vlocity_cmt__ContractLineItem__c();
    CLI.vlocity_cmt__ContractId__c = con1.id;
    CLI.SWAN_Service_Point__c = servicePoint.id;
    insert CLI;
    
    con1.vlocity_cmt__OpportunityId__c = opp.Id;
    con1.status = 'Contract Signed';
    update con1;*/
  }  
  
  @isTest
  public static void childQuoteInsertTest()
    {
        createStaticDataWithOfferPack();
        SWAN_OverlapSP spTest = new SWAN_OverlapSP();
        Map<String, Object> inputMap = new Map<String, Object>();
        inputMap.put('isQuote',true);
        inputMap.put('ContextId',masterQuote1.id);
        Boolean xyz = sptest.invokeMethod('calculateOverlap',inputMap,null,null);
    }
    
  @isTest
  public static void childQuoteInsert2Test()
    {
        createStaticDataWithOfferPack();
        Asset ast = new Asset(ContactId = con.id,name='testAsset',Status='Active',vlocity_cmt__ActivationDate__c=date.today(),UsageEndDate=date.today().addDays(30));
        insert ast;
        
        SWAN_OverlapSP spTest = new SWAN_OverlapSP();
        Map<String, Object> inputMap = new Map<String, Object>();
        inputMap.put('isQuote',false);
        inputMap.put('startDate',date.today());
        inputMap.put('endDate',date.today().addDays(30));
        inputMap.put('spList',spList);
        Boolean xyz = sptest.invokeMethod('calculateOverlap',inputMap,null,null);
        Map<String, Object> tempMap = sptest.pushEachRecord(ast);
    }
    
    @isTest
    public static void createContractWithBulkSPTest()
    {
        createStaticDataWithOfferPack();
        Map<String, Object> inputMap = new Map<String, Object>();
        inputMap.put('isQuote',true);
        inputMap.put('ContextId',masterQuote1.id);
        SWAN_ExtractSubQuoteCount  sub_Quote_count = new SWAN_ExtractSubQuoteCount();
        Boolean abc = sub_Quote_count.invokeMethod('getSubQuoteCount',inputMap,null,null);
        SWAN_OverlapSP spTest = new SWAN_OverlapSP();
        Boolean xyz = sptest.invokeMethod('calculateOverlap',inputMap,null,null);
        Boolean mno = sub_Quote_count.invokeMethod('createContract',inputMap,null,null);
        Map<String, Object> inputMap1 = new Map<String, Object>();
        System.debug('ContractIdNinad2'+cont.Id);
        inputMap1.put('ContextId',cont.id);
        SWAN_ExtractContractLineItems extractContractLineItems = new SWAN_ExtractContractLineItems();
        Boolean pqr = extractContractLineItems.invokeMethod('getContractLineItemsInfo',inputMap1,null,null);
    }
    
    @isTest
    public static void getContractDataWithValidCLITest()
    {
        createStaticDataWithOfferPack();
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outputMap = new Map<String, Object>();
        System.debug('ContractIdNinad2'+cont.Id);
        inputMap.put('ContextId',cont.id);
        SWAN_getContractDataWithValidCLI getContractDataWithValidCLI = new SWAN_getContractDataWithValidCLI();
        Boolean pqr = getContractDataWithValidCLI.invokeMethod('getContractDataWithValidCLI',inputMap,outputMap,null);
        Map<String, Object> inputMap1 = new Map<String, Object>();
        Map<String, Object> outputMap1 = new Map<String, Object>();
        System.debug('ContractIdNinad2'+cont_withoutcli.Id);
        inputMap1.put('ContextId',cont_withoutcli.id);
        SWAN_getContractDataWithValidCLI getContractDataWithValidCLInew = new SWAN_getContractDataWithValidCLI();
        Boolean stu = getContractDataWithValidCLInew.invokeMethod('getContractDataWithValidCLI',inputMap1,outputMap1,null);
        
    }
    
    @isTest
    public static void bulkCancelSPTest()
    {
        createStaticDataWithOfferPack();
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outputMap = new Map<String, Object>();
        System.debug('ContractIdNinad3'+cont.Id);
        inputMap.put('ContextId',cont.id);
        SWAN_GetServicePointStatus getServicePointStatus = new SWAN_GetServicePointStatus();
        Boolean pqr = getServicePointStatus.invokeMethod('getServicePointStatus',inputMap,outputMap,null);
        system.debug('outputMapafter'+outputMap);
        Map<String, Object> inputMap1 = new Map<String, Object>();
        inputMap1.put('SelectServicePoint',outputMap);
        system.debug('inputMap1after'+inputMap1);
        Map<String, Object> outputMap1 = new Map<String, Object>();
        String termination = 'Cancelled';
        Object obj_termination = (Object)termination;
        String processname = 'Cancelled';
        Object obj_processname = (Object)processname;
        //String terminatedEndDateTime = String.valueOf(date.today())+' 23:59:00';
        //Object obj_terminatedEndDateTime = (Object)terminatedEndDateTime;
        inputMap1.put('FinalStatus',obj_termination);
        inputMap1.put('Processname',obj_processname);
        //inputMap1.put('TerminatedEndDateTime',obj_terminatedEndDateTime);
        system.debug('inputMap1after11'+inputMap1);
        SWAN_ExtractSubQuoteCount updateServicePointStatus = new SWAN_ExtractSubQuoteCount();
        Boolean stu = updateServicePointStatus.invokeMethod('updateServicePointStatus',inputMap1,outputMap1,null);
    }
    
    @isTest
    public static void bulkTerminateSPTest()
    {
        createStaticDataWithOfferPack();
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outputMap = new Map<String, Object>();
        System.debug('ContractIdNinad3'+cont.Id);
        inputMap.put('ContextId',cont.id);
        SWAN_GetServicePointStatus getServicePointStatus = new SWAN_GetServicePointStatus();
        Boolean pqr = getServicePointStatus.invokeMethod('getServicePointStatusActive',inputMap,outputMap,null);
        system.debug('outputMapafter'+outputMap);
        Map<String, Object> inputMap1 = new Map<String, Object>();
        inputMap1.put('SelectServicePoint',outputMap);
        system.debug('inputMap1after'+inputMap1);
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
        system.debug('inputMap1after11'+inputMap1);
        SWAN_ExtractSubQuoteCount updateServicePointStatus = new SWAN_ExtractSubQuoteCount();
        Boolean stu = updateServicePointStatus.invokeMethod('updateServicePointStatus',inputMap1,outputMap1,null);
        
    }
    
    @isTest
    public static void updateSelectedServicePointStatus()
    {
        createStaticDataWithOfferPack();
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outputMap = new Map<String, Object>();
        System.debug('ContractIdNinad3'+cont.Id);
        inputMap.put('ContextId',cont.id);
        SWAN_GetServicePointStatus getServicePointStatus = new SWAN_GetServicePointStatus();
        Boolean pqr = getServicePointStatus.invokeMethod('getServicePointStatusActive',inputMap,outputMap,null);
        system.debug('outputMapafter'+outputMap);
        Map<String, Object> inputMap1 = new Map<String, Object>();
        inputMap1.put('SelectServicePoint',outputMap);
        system.debug('inputMap1after'+inputMap1);
        Map<String, Object> outputMap1 = new Map<String, Object>();
        String termination = 'Terminated';
        Object obj_termination = (Object)termination;
        String processname = 'Terminated';
        Object obj_processname = (Object)processname;
        String terminatedEndDateTime = String.valueOf(date.today())+' 23:59:00';
        Object obj_terminatedEndDateTime = (Object)terminatedEndDateTime;
        inputMap1.put('FinalStatus',obj_termination);
        inputMap1.put('Processname',obj_processname);
        inputMap1.put('TerminatedEndDateTime',obj_terminatedEndDateTime);
        system.debug('inputMap1after11'+inputMap1);
        SWAN_ExtractSubQuoteCount updateServicePointStatus = new SWAN_ExtractSubQuoteCount();
        Boolean stu = updateServicePointStatus.invokeMethod('updateSelectedServicePointStatus',inputMap1,outputMap1,null);
        
    }

    @isTest
    public static void testGasContractDocumentTokenExtractor()
    {
        system.debug([Select Id, Name from vlocity_cmt__DRBundle__c]);
        createStaticDataWithOfferPack();
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outputMap = new Map<String, Object>();
        System.debug('ContractIdNinad2'+cont.Id);
        inputMap.put('ContextId',cont.id);
        SWAN_getContractDataWithValidCLI getContractDataWithValidCLI = new SWAN_getContractDataWithValidCLI();
        Boolean pqr = getContractDataWithValidCLI.invokeMethod('getContractDataWithValidCLI',inputMap,outputMap,null);

        SWAN_GasContractDocumentTokenExtractor gasContractDocumentTokenExtractor = new SWAN_GasContractDocumentTokenExtractor ();
        Map<String, Object> gasInputMap = new Map<String, Object>();
        Map<String, Object> gasOutputMap = new Map<String, Object>();
        Map<String, Object> gasOptionsMap = new Map<String, Object>();
        gasInputMap.put('contextId',cont.id);
        //gasContractDocumentTokenExtractor.opportunityId = opp.Id;
        //gasContractDocumentTokenExtractor.quoteId = masterQuote1.id;
        //gasInputMap.put('contextId','80025000005nILiAAM');
        gasContractDocumentTokenExtractor.invokeMethod('getTokenData',gasInputMap, gasOutputMap, gasOptionsMap);
        System.debug('First:testGasContractDocumentTokenExtractor:outputMap --> ' + gasOutputMap);
        //Map<String, Object> paginationInformation = (MAP<string,object>)(JSON.deserializeUntyped(String.valueof(gasOutputMap.get('tokenDataQueryInfo'))));
        Map<String, Object> paginationInformation =  (Map<String, Object>)gasOutputMap.get('tokenDataQueryInfo');
        System.debug('paginationInformationmmm --> ' + paginationInformation);
        Integer totalItems = gasContractDocumentTokenExtractor.countContractItems(cont.id);
        List<Id> lstServicePointIds = gasContractDocumentTokenExtractor.getOppLineItemServicePointIds(opp.Id);
        Map<String, Object> quoteLineItems = gasContractDocumentTokenExtractor.getQuoteLineItems(masterQuote1.id, lstServicePointIds);
        paginationInformation.put('quoteLineItems', quoteLineItems);
        gasInputMap.put('tokenDataQueryInfo',paginationInformation);
        gasContractDocumentTokenExtractor.invokeMethod('getTokenData',gasInputMap, outputMap, gasOptionsMap);
        System.debug('Second:testGasContractDocumentTokenExtractor:outputMap --> ' + outputMap);
    }
    
    @isTest
    public static void testElecContractDocumentTokenExtractor()
    {
        system.debug([Select Id, Name from vlocity_cmt__DRBundle__c]);
        createStaticDataWithOfferPack();
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outputMap = new Map<String, Object>();
        System.debug('ContractIdNinad2'+cont.Id);
        inputMap.put('ContextId',cont.id);
        SWAN_getContractDataWithValidCLI getContractDataWithValidCLI = new SWAN_getContractDataWithValidCLI();
        Boolean pqr = getContractDataWithValidCLI.invokeMethod('getContractDataWithValidCLI',inputMap,outputMap,null);

        SWAN_ElecContractDocumentTokenExtract elecContractDocumentTokenExtractor = new SWAN_ElecContractDocumentTokenExtract ();
        Map<String, Object> elecInputMap = new Map<String, Object>();
        Map<String, Object> elecOutputMap = new Map<String, Object>();
        Map<String, Object> elecOptionsMap = new Map<String, Object>();
        elecInputMap.put('contextId',cont.id);
        //elecContractDocumentTokenExtractor.opportunityId = opp.Id;
        //elecContractDocumentTokenExtractor.quoteId = masterQuote1.id;
        //elecInputMap.put('contextId','8008E000001b1iEQAQ');
        elecContractDocumentTokenExtractor.invokeMethod('getTokenData',elecInputMap, elecOutputMap, elecOptionsMap);
        System.debug('First:testElecContractDocumentTokenExtractor:outputMap --> ' + elecOutputMap);
        //Map<String, Object> paginationInformation = (MAP<string,object>)(JSON.deserializeUntyped(String.valueof(elecOutputMap.get('tokenDataQueryInfo'))));
        Map<String, Object> paginationInformation =  (Map<String, Object>)elecOutputMap.get('tokenDataQueryInfo');
        System.debug('paginationInformationmmm --> ' + paginationInformation);
        Integer totalItems = elecContractDocumentTokenExtractor.countContractItems(cont.id);
        Map<String, Object> quoteLineItems = (MAP<String, Object>)(paginationInformation.get('quoteLineItems'));          
        paginationInformation.put('quoteLineItems', quoteLineItems);
        elecInputMap.put('tokenDataQueryInfo',paginationInformation);
        elecContractDocumentTokenExtractor.invokeMethod('getTokenData',elecInputMap, outputMap, elecOptionsMap);
        System.debug('Second:testElecContractDocumentTokenExtractor:outputMap --> ' + outputMap);
    }
    
    @isTest
    public static void callElectralinkServices_HHTest()
    {
        createStaticDataWithOfferPack();
        SWAN_Electralink_Connectors_Codes__c  code = new SWAN_Electralink_Connectors_Codes__c();
        code.hh_code__c = 'electralink_mpan_hh_per_period';
        code.nhh_code__c='electralink_nhh_eac_full_tpr';
        code.summary_code__c = 'summary';
        code.mpan_code__c='mpan';
        code.consumption_code__c ='consumption';
        code.name ='SWAN_Electralink_Connectors_Codes';
        insert code;
        system.debug('connector codes'+code);
        vlocity_cmt__Premises__c premise_electralink = new vlocity_cmt__Premises__c();
        insert premise_electralink;
        vlocity_cmt__ServicePoint__c servicePoint_Electralink = new vlocity_cmt__ServicePoint__c();
        servicePoint_Electralink.SWAN_Formula_Year_Annual_Quantity__c = 12331;
        servicePoint_Electralink.SWAN_Formula_Year_Offtake_Quantity__c = 3321;
        servicePoint_Electralink.vlocity_cmt__ServicePointNumber__c = '2600000060304';
        servicePoint_Electralink.vlocity_cmt__PremisesId__c = premise_electralink.id;
        servicePoint_Electralink.SWAN_Product_Class__c = '3';
        servicePoint_Electralink.SWAN_Measurement_Class__c = 'C';
        insert servicePoint_Electralink;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SWAN_ElectralinkServicesMockImpl());  
        Map<String, Object> inputMap = new Map<String, Object>();
        inputMap.put('UserId',UserInfo.getUserId());
        inputMap.put('servicePointId',servicePoint_Electralink.id);
        inputMap.put('RecordId',servicePoint_Electralink.id);
        inputMap.put('FilePath','https://app-int.gorilla.co/api/v1/connectors/executions');
        inputMap.put('AccessTokenVal','');
        inputMap.put('finalCodeId','004af9d2-abba-11ea-ab9c-0a05a4892f7a');
        inputMap.put('code','electralink_mpan_hh_per_period');
        SWAN_callElectralinkServices  electralinkServices = new SWAN_callElectralinkServices();
        Boolean abc = electralinkServices.invokeMethod('callElectralinkSer',inputMap,null,null);
        Test.stopTest();
    }
    
    @isTest
    public static void callElectralinkServices_NHHTest()
    {
        createStaticDataWithOfferPack();
        SWAN_Electralink_Connectors_Codes__c  code = new SWAN_Electralink_Connectors_Codes__c();
        code.hh_code__c = 'electralink_mpan_hh_per_period';
        code.nhh_code__c='electralink_nhh_eac_full_tpr';
        code.summary_code__c = 'summary';
        code.mpan_code__c='mpan';
        code.consumption_code__c ='consumption';
        code.name ='SWAN_Electralink_Connectors_Codes';
        insert code;
        system.debug('connector codes'+code);
        vlocity_cmt__Premises__c premise_electralink = new vlocity_cmt__Premises__c();
        insert premise_electralink;
        vlocity_cmt__ServicePoint__c servicePoint_Electralink = new vlocity_cmt__ServicePoint__c();
        servicePoint_Electralink.SWAN_Formula_Year_Annual_Quantity__c = 12331;
        servicePoint_Electralink.SWAN_Formula_Year_Offtake_Quantity__c = 3321;
        servicePoint_Electralink.vlocity_cmt__ServicePointNumber__c = '2600000060305';
        servicePoint_Electralink.vlocity_cmt__PremisesId__c = premise_electralink.id;
        servicePoint_Electralink.SWAN_Product_Class__c = '3';
        servicePoint_Electralink.SWAN_Measurement_Class__c = 'B';
        insert servicePoint_Electralink;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SWAN_ElectralinkServicesMockImpl());  
        Map<String, Object> inputMap = new Map<String, Object>();
        inputMap.put('UserId',UserInfo.getUserId());
        inputMap.put('servicePointId',servicePoint_Electralink.id);
        inputMap.put('RecordId',servicePoint_Electralink.id);
        inputMap.put('FilePath','https://app-int.gorilla.co/api/v1/connectors/executions');
        inputMap.put('AccessTokenVal','');
        inputMap.put('finalCodeId','004af9d2-abba-11ea-ab9c-0a05a4892f7a');
        inputMap.put('code','electralink_nhh_eac_full_tpr');
        SWAN_callElectralinkServices  electralinkServices = new SWAN_callElectralinkServices();
        Boolean abc = electralinkServices.invokeMethod('callElectralinkSer',inputMap,null,null);
        Test.stopTest();
    }
    
    @isTest
    public static void CallElectralinkVIP_Test()
    {
        //createStaticDataWithOfferPack();
        Account acc = new Account();
        acc.Name = 'Test Acc';
        acc.SWAN_Customer_Segment__c = 'I&C';
        acc.SWAN_Micro_Business_Selection__c = 'Non_Micro_Business';
        insert acc;
        SWAN_Electralink_Connectors_Codes__c  code = new SWAN_Electralink_Connectors_Codes__c();
        code.hh_code__c = 'electralink_mpan_hh_per_period';
        code.nhh_code__c='electralink_nhh_eac_full_tpr';
        code.summary_code__c = 'summary';
        code.mpan_code__c='mpan';
        code.consumption_code__c ='consumption';
        code.name ='SWAN_Electralink_Connectors_Codes';
        insert code;
        system.debug('connector codes'+code);
        vlocity_cmt__Premises__c premise_electralink = new vlocity_cmt__Premises__c();
        insert premise_electralink;
        vlocity_cmt__ServicePoint__c servicePoint_Electralink = new vlocity_cmt__ServicePoint__c();
        servicePoint_Electralink.SWAN_Formula_Year_Annual_Quantity__c = 12331;
        servicePoint_Electralink.SWAN_Formula_Year_Offtake_Quantity__c = 3321;
        servicePoint_Electralink.vlocity_cmt__ServicePointNumber__c = '2600000060305';
        servicePoint_Electralink.vlocity_cmt__PremisesId__c = premise_electralink.id;
        servicePoint_Electralink.SWAN_Product_Class__c = '3';
        servicePoint_Electralink.SWAN_Measurement_Class__c = 'B';
        insert servicePoint_Electralink;
        List<Id> splist = new List<Id>();
        splist.add(servicePoint_Electralink.id);
        Test.startTest();
        Boolean testresult = CallElectralinkVIP.CallIPService('BG-Electralinkdata_BGGorillaElectralinkDataComponent',splist,acc.id,UserInfo.getUserId(),'electralink_nhh_eac_full_tpr');
        Test.stopTest();
    }
    
    @isTest
    public static void getQuoteExceptionsTest()
    {
        createStaticDataWithOfferPack();
        Asset ast = new Asset(ContactId = con.id,name='testAsset',Status='Active',vlocity_cmt__ActivationDate__c=date.today(),UsageEndDate=date.today().addDays(30));
        insert ast;
        
        SWAN_getQuoteExceptions spTest = new SWAN_getQuoteExceptions();
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outputMap = new Map<String, Object>();
        inputMap.put('ContextId',masterQuote1.id);
        Boolean xyz = sptest.invokeMethod('extractQuoteExceptions',inputMap,outputMap,null);
    }
}