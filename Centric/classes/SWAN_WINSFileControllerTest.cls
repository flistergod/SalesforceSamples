@isTest
public class SWAN_WINSFileControllerTest {
  public static Quote masterQuote = new Quote();
  public static Quote masterQuote1 = new Quote();
    public static Opportunity opp = new Opportunity();
    public static Contact con = new Contact();
  
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
        masterQuote1.SWAN_Offer_End_Date__c = date.today()+1000;
        masterQuote1.SWAN_Number_of_Service_Points__c = 2;
        masterQuote1.Status = 'Draft';
        masterQuoteList.add(masterQuote1);
        
        Quote masterQuote2 = new Quote();
        masterQuote2.OpportunityId = opp.Id;
        masterQuote2.Name = 'Master Quote 2';
        masterQuote2.SWAN_Pricing_Structure__c = 'Site Specific Without Standing Charge';
        masterQuote2.SWAN_Payment_Method_and_Term__c = 'Direct Debit - 14 Days';
        masterQuote2.SWAN_Offer_Start_Date__c = Date.today();
        masterQuote2.SWAN_Number_of_Service_Points__c = 2;
        masterQuote2.Status = 'Draft';
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
    childQuote.vlocity_cmt__DefaultServicePointId__c = servicePoint.id;
    childQuote.SWAN_Service_Point_Start_Date__c = date.today();
    
    childQuote.name = 'child quote';
    childQuote.OpportunityId = opp.id;
    insert childQuote;
    
        
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
      
        con1.status = 'Contract Signed';
        update con1;
        
      ContractHistory conh1 = new ContractHistory();
       // conH.NewValue = 'Contract Signed';
        //conH.OldValue = 'Draft';
        conH1.ContractId = con1.Id;
        conH1.Field = 'Status';
        Insert conH1;
    system.debug('ssss='+conH+'sssw='+conH1);
    vlocity_cmt__ContractLineItem__c CLI = new vlocity_cmt__ContractLineItem__c();
    CLI.vlocity_cmt__ContractId__c = con1.id;
  //CLI.vlocity_cmt__ServicePointId__c = servicePoint.id;
    CLI.SWAN_Service_Point__c = servicePoint.id;
    insert CLI;
    
    con1.status = 'Contract Signed';
    update con1;
  }  
  
  @isTest
  public static void childQuoteInsertTest()
    {
        createStaticDataWithOfferPack();
    SWAN_WINSFileController.runWINSReport();
    }
  
  @isTest
  public static void getReportDataTest()
    {
        createStaticDataWithOfferPack();
    SWAN_WINSFileController.runWINSReport();
    SWAN_WINSFileController.getReportData(date.today());
    }
    
   /* @isTest
  public static void ForSiteAdditionQuotes()
    {
        createStaticDataWithOfferPack(); 
        Id recId = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('Site Addition Quote').getRecordTypeId();
        Id recId1 = Schema.SObjectType.Quote.getRecordTypeInfosByName().get(label.QuoteSiteAdditionRecordType).getRecordTypeId();  
          

        vlocity_cmt__Premises__c premise = new vlocity_cmt__Premises__c();
        insert premise;

        vlocity_cmt__Premises__c premise2 = new vlocity_cmt__Premises__c();
        insert premise2;

        vlocity_cmt__ServicePoint__c servicePoint = new vlocity_cmt__ServicePoint__c();
        servicePoint.SWAN_Formula_Year_Annual_Quantity__c = 12331;
        servicePoint.SWAN_Formula_Year_Offtake_Quantity__c = 3321;
        servicePoint.vlocity_cmt__ServicePointNumber__c = '1231231231';
        servicePoint.vlocity_cmt__PremisesId__c = premise.id;
        servicePoint.SWAN_Product_Class__c = '3';
        insert servicePoint;

        vlocity_cmt__ServicePoint__c servicePoint2 = new vlocity_cmt__ServicePoint__c();
        servicePoint2.SWAN_Formula_Year_Annual_Quantity__c = 12331;
        servicePoint2.SWAN_Formula_Year_Offtake_Quantity__c = 3321;
        servicePoint2.vlocity_cmt__ServicePointNumber__c = '1231231234';
        servicePoint2.vlocity_cmt__PremisesId__c = premise2.id;
        servicePoint2.SWAN_Product_Class__c = '3';
        insert servicePoint2;
        

        Quote childQuote = new Quote();
        childQuote.recordTypeId=recId;
        childQuote.Name = 'Site Addition Quote';
        childQuote.SWAN_Site_Addition_Parent__c = masterQuote1.Id;
        childQuote.OpportunityId = opp.id;
        childQuote.status='Draft';
        childQuote.SWAN_Contribution_Margin__c=1615.19;
        childQuote.SWAN_Gross_Margin__c =   1970.25;
        childQuote.SWAN_Contract_Volume_KWh__c=10;
        childQuote.SWAN_Offer_End_Date__c  = Date.newInstance(2021,11,26);
        childQuote.SWAN_Offer_Start_Date__c   = Date.newInstance(2019,11,26);
        childQuote.vlocity_cmt__DefaultServicePointId__c = servicePoint.id;
        insert childQuote;
        
        Product2 p = new Product2();
        p.name='Fixed Price Gas';
        p.productCode='BG_GAS';
        insert p;
        
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = p.Id, UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;
        
        PricebookEntry customPrice = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = p.Id, UnitPrice = 12000, IsActive = true);
        insert customPrice;
        
        Quote childQuote1 = new Quote();
        childQuote1.recordTypeId=recId1;
        childQuote1.Name = 'SP Quote';
        childQuote1.vlocity_cmt__ParentQuoteId__c = childQuote.Id;
        childQuote1.OpportunityId = opp.id;
        childQuote1.pricebook2Id=customPB.id;
        childQuote.vlocity_cmt__DefaultServicePointId__c = servicePoint2.id;
        insert childQuote1;
        
        
        QuoteLineItem qli = new QuoteLineItem();
        qli.QuoteId = childQuote1.id;
        qli.PriceBookEntryId=customPrice.id;
        qli.Quantity=1;
        qli.UnitPrice=10;
        insert qli;
        
        Test.startTest();
        try{
        childQuote.Status = 'Accepted';
        update childQuote;
        SWAN_WINSFileController.runWINSReport();
        SWAN_WINSFileController.getReportData(date.today());
        } catch(Exception ex){}
        Test.stopTest();
    }*/
}