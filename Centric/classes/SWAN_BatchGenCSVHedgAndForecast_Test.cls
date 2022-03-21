@isTest
public class SWAN_BatchGenCSVHedgAndForecast_Test {
    public static Quote masterQuote = new Quote();
  public static Quote masterQuote1 = new Quote();
    public static Opportunity opp = new Opportunity();
    public static Contact con = new Contact();
    
    @testSetUp
    public static void createStaticDataWithOfferPack()
    {
        Id pricebookIdTest = Test.getStandardPricebookId();
        vlocity_cmt__PriceList__c prList = new vlocity_cmt__PriceList__c(vlocity_cmt__Code__c='12349870',vlocity_cmt__IsActive__c=true,vlocity_cmt__Pricebook2Id__c=pricebookIdTest,Name='I&C Price List');
        insert prList;
        
        insert new Segment_Values__c(Enterprise_Segment__c='ME',I_C_Segment__c='MU');
        Id recId = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('Site Addition Quote').getRecordTypeId();
        Id recId1 = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('Service Point Quote').getRecordTypeId();  
        
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
        
        
    Product2 prod = new Product2(Name = 'BG_GAS',
                                     Family = 'Gas',ProductCode='BG_GAS');
        insert prod;
        
    Product2 prod_FixedPriceGas = new Product2(Name = 'Fixed Price Gas',
                                     ProductCode='BG_GAS');
        insert prod_FixedPriceGas;
        
    PriceBook2 pb = new PriceBook2();
    pb.name = 'Example Price Book';
    //pb.isStandard = true;
    pb.IsActive = true;
    insert pb;
        
    // Get the Standard Price Book ID

    /*Pricebook2 standardPriceBook = [
        SELECT Id
          FROM Pricebook2
         WHERE isStandard = true
         LIMIT 1
    ];
    System.debug('standardPriceBook'+standardPriceBook);*/
    // Insert the Product in the Standard Price Book (if necessary)
    Id pricebookId = Test.getStandardPricebookId();

    PricebookEntry standardPriceBookEntry = new PricebookEntry(
        Pricebook2Id = pricebookId,
        Product2Id = prod_FixedPriceGas.Id,
        UnitPrice = 100.00,
        UseStandardPrice = false,
        IsActive = true
    );

    insert standardPriceBookEntry;  
    
    PriceBookEntry pbe = new PricebookEntry();
    pbe.product2Id = prod_FixedPriceGas.Id;
    pbe.Pricebook2Id = pb.Id;
    pbe.IsActive = true;
    pbe.Unitprice =0;
    pbe.UseStandardPrice = false;
    insert pbe;
    
    List<Quote> masterQuoteList = new List<Quote>();
    
    //Quote masterQuote = new Quote();
        masterQuote1.OpportunityId = opp.Id;
        masterQuote1.Name = 'Master Quote 1';
        masterQuote1.SWAN_Pricing_Structure__c = 'HH 2 Rate';
        masterQuote1.SWAN_Payment_Method_and_Term__c = 'Direct Debit - 14 Days';
        masterQuote1.SWAN_Offer_Start_Date__c = Date.today();
        masterQuote1.SWAN_Offer_End_Date__c = date.today()+100;
        masterQuote1.SWAN_Number_of_Service_Points__c = 2;
        masterQuote1.Status = 'Draft';
        masterQuote1.vlocity_cmt__PriceListId__c = prlist.id;
        masterQuote1.SWAN_Quote_for_Fuel_Type__c = 'Electricity';
        masterQuote1.SWAN_Quote_Type__c = 'Flex';
        masterQuoteList.add(masterQuote1);
        
        Quote masterQuote2 = new Quote();
        masterQuote2.OpportunityId = opp.Id;
        masterQuote2.Name = 'Master Quote 2';
        masterQuote2.SWAN_Pricing_Structure__c = 'HH 2 Rate';
        masterQuote2.SWAN_Payment_Method_and_Term__c = 'Direct Debit - 14 Days';
        masterQuote2.SWAN_Offer_Start_Date__c = Date.today();
        masterQuote2.SWAN_Number_of_Service_Points__c = 2;
        masterQuote2.Status = 'Draft';
        masterQuote2.SWAN_Quote_for_Fuel_Type__c = 'Electricity';
        masterQuoteList.add(masterQuote2);
    insert masterQuoteList;
    
    vlocity_cmt__Premises__c premise = new vlocity_cmt__Premises__c();
    insert premise;
    
    vlocity_cmt__ServicePoint__c servicePoint = new vlocity_cmt__ServicePoint__c();
    servicePoint.SWAN_Formula_Year_Annual_Quantity__c = 12331;
    servicePoint.SWAN_Formula_Year_Offtake_Quantity__c = 3321;
    servicePoint.vlocity_cmt__ServicePointNumber__c = '1231231231';
    servicePoint.vlocity_cmt__PremisesId__c = premise.id;
    servicePoint.SWAN_Product_Class__c = '3';
    insert servicePoint;
    
    Quote childQuote = new Quote();
    childQuote.vlocity_cmt__ParentQuoteId__c = masterQuote1.id;
    childQuote.SWAN_Parent_Quote__c = masterQuote1.id;
    childQuote.vlocity_cmt__DefaultServicePointId__c= servicePoint.id;
    childQuote.SWAN_Service_Point_Start_Date__c = date.today();
    childQuote.name = 'child quote';
    childQuote.OpportunityId = opp.id;
    childQuote.pricebook2Id = pb.Id;
    childQuote.SWAN_Quote_for_Fuel_Type__c = 'Electricity';
    childQuote.SWAN_Quote_Type__c = 'Flex';
    insert childQuote;
    
    Quote childQuote1 = new Quote();
    childQuote1.recordTypeId=recId;
    childQuote1.Name = 'Site Addition Quote';
    childQuote1.SWAN_Site_Addition_Parent__c = masterQuote1.Id;
    childQuote1.SWAN_Offer_End_Date__c = date.today().adddays(90);
    childQuote1.OpportunityId = opp.id;
    childQuote1.status='Draft';
    childQuote1.SWAN_Pricing_Structure__c = 'HH 2 Rate';
    childQuote1.SWAN_Quote_for_Fuel_Type__c = 'Electricity';
    childQuote1.SWAN_Quote_Type__c = 'Flex';
    insert childQuote1;
    
    Quote childQuote2 = new Quote();
    childQuote2.vlocity_cmt__ParentQuoteId__c = childQuote1.id;
    childQuote2.SWAN_Parent_Quote__c = childQuote1.Id;
    childQuote2.vlocity_cmt__DefaultServicePointId__c= servicePoint.id;
    childQuote2.SWAN_Service_Point_Start_Date__c = date.today();
    childQuote2.name = 'child quote2';
    childQuote2.OpportunityId = opp.id;
    childQuote2.SWAN_Quote_for_Fuel_Type__c = 'Electricity';
    insert childQuote2;
            
    SWAN_Offer_Pack__c offerPack = new SWAN_Offer_Pack__c();
        offerPack.Contact__c = con.id;
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
    
    system.debug('~~~~~'+masterQuote1.Status);
    masterQuote1.Status = 'Selected';
    update masterQuote1;
    system.debug('~~~~~'+masterQuote1.Status);
    
    Contract con1 = new Contract();
    con1.vlocity_cmt__QuoteId__c = masterQuote1.id;
    con1.AccountId = acc.Id;
    con1.status = 'Draft';
    insert con1;
    
        ContractHistory conh = new ContractHistory();
       // conH.NewValue = 'Contract Signed';
        //conH.OldValue = 'Draft';
        conH.ContractId = con1.Id;
        conH.Field = 'Status';
        Insert conH;
    
    vlocity_cmt__ContractLineItem__c CLI1 = new vlocity_cmt__ContractLineItem__c();
    CLI1.vlocity_cmt__ContractId__c = con1.id;
    CLI1.SWAN_Service_Point__c = servicePoint.id;
    CLI1.SWAN_Quote__c=childQuote.id;
    CLI1.vlocity_cmt__EffectiveStartDate__c = system.now();
    CLI1.vlocity_cmt__EffectiveEndDate__c = system.now().addYears(1);
    insert CLI1;
    
    vlocity_cmt__ContractLineItem__c CLI2 = new vlocity_cmt__ContractLineItem__c();
    CLI2.vlocity_cmt__ContractId__c = con1.id;
    CLI2.SWAN_Service_Point__c = servicePoint.id;
    cli2.SWAN_Quote__c=childQuote2.id;
    CLI2.vlocity_cmt__EffectiveStartDate__c = system.now();
    CLI2.vlocity_cmt__EffectiveEndDate__c = system.now().addYears(1);
    insert CLI2;
    
    vlocity_cmt__ContractLineItem__c CLI3 = new vlocity_cmt__ContractLineItem__c();
    CLI3.vlocity_cmt__ContractId__c = con1.id;
    CLI3.vlocity_cmt__Product2Id__c = prod.id;
    CLI3.vlocity_cmt__OriginalLineItemId__c=CLI1.id;
    CLI3.vlocity_cmt__EffectiveStartDate__c = system.now();
    CLI3.vlocity_cmt__EffectiveEndDate__c = system.now().addYears(1);
    //CLI3.vlocity_cmt__ProductCode__c = 'BG_GAS';
    insert CLI3;
    
    vlocity_cmt__ContractLineItem__c CLI4 = new vlocity_cmt__ContractLineItem__c();
    CLI4.vlocity_cmt__ContractId__c = con1.id;
    CLI4.vlocity_cmt__Product2Id__c = prod.id;
    CLI4.vlocity_cmt__OriginalLineItemId__c=CLI2.id;
    CLI4.vlocity_cmt__EffectiveStartDate__c = system.now();
    CLI4.vlocity_cmt__EffectiveEndDate__c = system.now().addYears(1);
    //CLI4.vlocity_cmt__ProductCode__c = 'BG_GAS';
    insert CLI4;
    
    childQuote1.status='Accepted';
    update childQuote1;
    
    
        
    QuoteLineItem qli = new QuoteLineItem();
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
    
    con1.status = 'Contract Signed';
    update con1;
    
     ContractHistory conh1 = new ContractHistory();
       // conH.NewValue = 'Contract Signed';
        //conH.OldValue = 'Draft';
        conH1.ContractId = con1.Id;
        conH1.Field = 'Status';
        Insert conH1;
        
        system.debug('conthist='+conH1+'conH1='+conH);
        
        List<vlocity_cmt__ContractLineItem__c> productCLIList = [ SELECT vlocity_cmt__Product2Id__r.Name,vlocity_cmt__ContractId__c,id,vlocity_cmt__ProductCode__c FROM vlocity_cmt__ContractLineItem__c WHERE vlocity_cmt__ContractId__c = :con1.id ];
    
    system.debug('~~~~~productCLIList'+productCLIList[0].vlocity_cmt__Product2Id__r.Name + '~~~~'+productCLIList[0].vlocity_cmt__ProductCode__c);
  }
    
   @isTest static void testMethod1() {
       test.startTest();
       Test.setMock(HttpCalloutMock.class, new AWSFileReaderMeterCalloutMockImpl()); 
       Database.executeBatch(new SWAN_BatchGenerateCSVHedgAndForecast(),2000);
       test.stopTest();
   }
   
    @isTest static void testMethod2() {
       test.startTest();
       Test.setMock(HttpCalloutMock.class, new AWSFileReaderMeterCalloutMockImpl()); 
       SWAN_ScheduleHnFReport sc = new SWAN_ScheduleHnFReport();
       String sch = '0 0 23 * * ?';
       system.schedule('test check',sch,sc);
       test.stopTest();
   }

}