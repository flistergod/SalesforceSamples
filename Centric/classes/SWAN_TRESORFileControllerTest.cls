@isTest
public class SWAN_TRESORFileControllerTest {
  public static Quote masterQuote = new Quote();
  public static Quote masterQuote1 = new Quote();
  public static Quote masterQuote_ENT = new Quote();
    //public static Opportunity opp = new Opportunity();
//	public static Opportunity opp_ent = new Opportunity();
    //public static Contact con = new Contact();
  
    @TestSetup
  public static void createStaticDataWithOfferPack()
    {
        List<Opportunity> oppList = new List<Opportunity>();
        List<Account> accList = new List<Account>();
        List<Contact> conList = new List<Contact>();

        Id pricebookIdTest = Test.getStandardPricebookId();
		Product2 prod_FixedPriceGas = new Product2(Name = 'Fixed Price Gas',ProductCode='BG_GAS', vlocity_cmt__Type__c = 'Gas');
		insert prod_FixedPriceGas;
		PricebookEntry standardPriceBookEntry = new PricebookEntry(
			Pricebook2Id = pricebookIdTest,
			Product2Id = prod_FixedPriceGas.Id,
			UnitPrice = 100.00,
			UseStandardPrice = false,
			IsActive = true
		);
		insert standardPriceBookEntry;
		PriceBook2 pb = new PriceBook2();
		pb.name = 'Example Price Book';
		//pb.isStandard = true;
		pb.IsActive = true;
		insert pb;
		PriceBookEntry pbe = new PricebookEntry();
		pbe.product2Id = prod_FixedPriceGas.Id;
		pbe.Pricebook2Id = pb.Id;
		pbe.IsActive = true;
		pbe.Unitprice =0;
		pbe.UseStandardPrice = false;
		insert pbe;
        vlocity_cmt__PriceList__c prList = new vlocity_cmt__PriceList__c(vlocity_cmt__Code__c='12349870',vlocity_cmt__IsActive__c=true,vlocity_cmt__Pricebook2Id__c=pricebookIdTest,Name='I&C Price List');
        insert prList;
		vlocity_cmt__PriceList__c prList_ENT = new vlocity_cmt__PriceList__c(vlocity_cmt__Code__c='1234987ENT',vlocity_cmt__IsActive__c=true,vlocity_cmt__Pricebook2Id__c=pricebookIdTest,Name='Enterprise Price List');
        insert prList_ENT;

        Account acc = new Account();
        acc.Name = 'Test Acc';
        acc.SWAN_Customer_Segment__c = 'I&C';
        acc.SWAN_Micro_Business_Selection__c = 'Non_Micro_Business';
        accList.add(acc);

        Account acc_ENT = new Account();
        acc_ENT.Name = 'Test Acc ENT';
        acc_ENT.SWAN_Customer_Segment__c = 'Enterprise';
        acc_ENT.SWAN_Micro_Business_Selection__c = 'Non_Micro_Business';
        accList.add(acc_ENT);
        insert accList;
        
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.Name = 'Test Opp';
        opp.StageName = 'Prospecting';
        opp.CloseDate = date.today();
        opp.vlocity_cmt__PriceListId__c = prList.id;
        oppList.add(opp);
		
        Opportunity opp_ent = new Opportunity();
		opp_ent.AccountId = acc_ENT.Id;
        opp_ent.Name = 'Test Opp ENT';
        opp_ent.StageName = 'Prospecting';
        opp_ent.CloseDate = date.today();
        opp_ent.vlocity_cmt__PriceListId__c = prList_ENT.id;
        oppList.add(opp_ent);
        insert oppList;
        
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.lastName = 'Last Name';
        con.firstname ='Fname';
        con.MailingStreet='M street';
        con.MailingPostalCode='M50 2HX';
        con.SWAN_Mailing_Building_Name__c='Building name';
        con.MailingCity = 'test City';
        conList.add(con);
        insert conList;
    
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
        masterQuote1.SWAN_Broker_Commission__c = 10;
		masterQuote1.SWAN_Broker_Commission_Margin_p__c = 10;
		masterQuote1.SWAN_Broker_Commission_Margin_pence_per__c = 10;
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
		
		masterQuote_ENT.OpportunityId = opp_ent.Id;
        masterQuote_ENT.Name = 'Master Quote 3';
        masterQuote_ENT.SWAN_Pricing_Structure__c = 'Site Specific With Standing Charge';
        masterQuote_ENT.SWAN_Payment_Method_and_Term__c = 'Direct Debit - 14 Days';
        masterQuote_ENT.SWAN_Offer_Start_Date__c = Date.today();
        masterQuote_ENT.SWAN_Offer_End_Date__c = date.today()+1000;
        masterQuote_ENT.SWAN_Number_of_Service_Points__c = 2;
        masterQuote_ENT.Status = 'Draft';
        masterQuote_ENT.SWAN_Broker_Commission__c = 10;
		masterQuote_ENT.SWAN_Broker_Commission_Margin_p__c = 10;
		masterQuote_ENT.SWAN_Broker_Commission_Margin_pence_per__c = 10;
        masterQuoteList.add(masterQuote_ENT);
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
	
	Id spElec_RecordTypeId = Schema.SObjectType.vlocity_cmt__ServicePoint__c.getRecordTypeInfosByName().get('Electricity Service Point').getRecordTypeId();
	
	vlocity_cmt__ServicePoint__c servicePoint_elec = new vlocity_cmt__ServicePoint__c();
    servicePoint_elec.SWAN_Formula_Year_Annual_Quantity__c = 12331;
    servicePoint_elec.SWAN_Formula_Year_Offtake_Quantity__c = 3321;
    servicePoint_elec.vlocity_cmt__ServicePointNumber__c = '1231231235';
    servicePoint_elec.vlocity_cmt__PremisesId__c = premise.id;
    servicePoint_elec.SWAN_Product_Class__c = '3';
	servicePoint_elec.RecordTypeId = spElec_RecordTypeId;
    insert servicePoint_elec;
	System.debug('SPELec'+servicePoint_elec);
	System.debug('SPELec record type'+servicePoint_elec.RecordTypeId);
	
	vlocity_cmt__ServicePoint__c servicePoint_elec_2 = new vlocity_cmt__ServicePoint__c();
    servicePoint_elec_2.SWAN_Formula_Year_Annual_Quantity__c = 12331;
    servicePoint_elec_2.SWAN_Formula_Year_Offtake_Quantity__c = 3321;
    servicePoint_elec_2.vlocity_cmt__ServicePointNumber__c = '1231231237';
    servicePoint_elec_2.vlocity_cmt__PremisesId__c = premise.id;
    servicePoint_elec_2.SWAN_Product_Class__c = '3';
	//servicePoint_elec_2.RecordTypeId = spElec_RecordTypeId;
    insert servicePoint_elec_2;
	System.debug('SPELec'+servicePoint_elec_2);
	System.debug('SPELec record type'+servicePoint_elec_2.RecordTypeId);
    
    Quote childQuote = new Quote();
    childQuote.vlocity_cmt__ParentQuoteId__c = masterQuote1.id;
    childQuote.vlocity_cmt__DefaultServicePointId__c= servicePoint.id;
    childQuote.SWAN_Service_Point_Start_Date__c = date.today();
    
    childQuote.name = 'child quote';
    childQuote.OpportunityId = opp.id;
    childQuote.SWAN_Broker_Commission__c = 10;
    insert childQuote;
	
	Quote childQuote_elec = new Quote();
    childQuote_elec.vlocity_cmt__ParentQuoteId__c = masterQuote1.id;
    childQuote_elec.vlocity_cmt__DefaultServicePointId__c= servicePoint_elec.id;
    childQuote_elec.SWAN_Service_Point_Start_Date__c = date.today();
    childQuote_elec.name = 'child quote elec';
    childQuote_elec.OpportunityId = opp.id;
    childQuote_elec.SWAN_Broker_Commission__c = 10;
    insert childQuote_elec;
	
	Quote childQuote_ENT = new Quote();
    childQuote_ENT.vlocity_cmt__ParentQuoteId__c = masterQuote_ENT.id;
    childQuote_ENT.vlocity_cmt__DefaultServicePointId__c= servicePoint_elec.id;
    childQuote_ENT.SWAN_Service_Point_Start_Date__c = date.today();
    childQuote_ENT.name = 'child quote ENT';
    childQuote_ENT.OpportunityId = opp_ent.id;
    childQuote_ENT.SWAN_Broker_Commission__c = 10;
	childQuote_ENT.pricebook2Id = pb.Id;
    insert childQuote_ENT;
	
	QuoteLineItem qli_1 = new QuoteLineItem();
    qli_1.Product2Id = prod_FixedPriceGas.Id;
    qli_1.QuoteId = childQuote_ENT.Id;
    qli_1.UnitPrice = 0;
    qli_1.Quantity = 1;
    qli_1.PricebookEntryId = pbe.Id;
    insert qli_1;
	
	Quote childQuote_ENT_2 = new Quote();
    childQuote_ENT_2.vlocity_cmt__ParentQuoteId__c = masterQuote_ENT.id;
    childQuote_ENT_2.vlocity_cmt__DefaultServicePointId__c= servicePoint_elec_2.id;
    childQuote_ENT_2.SWAN_Service_Point_Start_Date__c = date.today();
    childQuote_ENT_2.name = 'child quote ENT2';
    childQuote_ENT_2.OpportunityId = opp_ent.id;
    childQuote_ENT_2.SWAN_Broker_Commission__c = 10;
	childQuote_ENT_2.pricebook2Id = pb.Id;
    insert childQuote_ENT_2;
	
	QuoteLineItem qli_2 = new QuoteLineItem();
    qli_2.Product2Id = prod_FixedPriceGas.Id;
    qli_2.QuoteId = childQuote_ENT_2.Id;
    qli_2.UnitPrice = 0;
    qli_2.Quantity = 1;
    qli_2.PricebookEntryId = pbe.Id;
    insert qli_2;
    
        
    SWAN_Offer_Pack__c offerPack = new SWAN_Offer_Pack__c();
        offerPack.Contact__c = con.id;
        offerPack.SWAN_Opportunity__c = opp.id;
        insert offerPack;
		
	SWAN_Offer_Pack__c offerPack_ENT = new SWAN_Offer_Pack__c();
        offerPack_ENT.Contact__c = con.id;
        offerPack_ENT.SWAN_Opportunity__c = opp_ent.id;
        insert offerPack_ENT;	
        
        List<SWAN_Offer_Pack_Quote__c> listOfferPackQuote = new List<SWAN_Offer_Pack_Quote__c>();
        SWAN_Offer_Pack_Quote__c opq1 = new SWAN_Offer_Pack_Quote__c();
        opq1.SWAN_Offer_Pack__c = offerPack.id;
        opq1.SWAN_Quote__c = masterQuote1.id;
        listOfferPackQuote.add(opq1);
        
        SWAN_Offer_Pack_Quote__c opq2 = new SWAN_Offer_Pack_Quote__c();
        opq2.SWAN_Offer_Pack__c = offerPack.id;
        opq2.SWAN_Quote__c = masterQuote2.id;
        listOfferPackQuote.add(opq2);
		
        SWAN_Offer_Pack_Quote__c opq3 = new SWAN_Offer_Pack_Quote__c();
        opq3.SWAN_Offer_Pack__c = offerPack_ENT.id;
        opq3.SWAN_Quote__c = masterQuote_ENT.id;
        listOfferPackQuote.add(opq3);
        
        insert listOfferPackQuote;
    
    system.debug('~~~~~'+masterQuote1.Status);
    masterQuote1.Status = 'Selected';
    update masterQuote1;
    system.debug('~~~~~'+masterQuote1.Status);
	
	masterQuote_ENT.Status = 'Selected';
    update masterQuote_ENT;
    
    Contract con1 = new Contract();
    con1.vlocity_cmt__QuoteId__c = masterQuote1.id;
    con1.AccountId = acc.Id;
    con1.status = 'Draft';
    insert con1;
	
	/*Contract con2 = new Contract();
    con2.vlocity_cmt__QuoteId__c = masterQuote_ENT.id;
    con2.AccountId = acc.Id;
    con2.status = 'Draft';
    insert con2;*/
        
    ContractHistory conh = new ContractHistory();
       // conH.NewValue = 'Contract Signed';
        //conH.OldValue = 'Draft';
        conH.ContractId = con1.Id;
        conH.Field = 'Status';
        Insert conH;
	
	/*ContractHistory conh_ent = new ContractHistory();
       // conH.NewValue = 'Contract Signed';
        //conH.OldValue = 'Draft';
        conh_ent.ContractId = con2.Id;
        conh_ent.Field = 'Status';
        Insert conh_ent;*/
      
		con1.vlocity_cmt__PriceListId__c = prList.id;
        con1.status = 'Contract Signed';
        update con1;
		
		/*con2.vlocity_cmt__PriceListId__c = prList_ENT.id;
        con2.status = 'Contract Signed';
        update con2;*/
        
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
    CLI.SWAN_Quote__c = childQuote.Id;
    insert CLI;
	
	vlocity_cmt__ContractLineItem__c CLI_elec_IC = new vlocity_cmt__ContractLineItem__c();
    CLI_elec_IC.vlocity_cmt__ContractId__c = con1.id;
    CLI_elec_IC.SWAN_Service_Point__c = servicePoint_elec.id;
    CLI_elec_IC.SWAN_Quote__c = childQuote_elec.Id;
    insert CLI_elec_IC;
    
    con1.status = 'Contract Signed';
    update con1;
	
	/*vlocity_cmt__ContractLineItem__c CLI_Elec = new vlocity_cmt__ContractLineItem__c();
    CLI_Elec.vlocity_cmt__ContractId__c = con2.id;
  //CLI.vlocity_cmt__ServicePointId__c = servicePoint.id;
    CLI_Elec.SWAN_Service_Point__c = servicePoint_elec.id;
    CLI_Elec.SWAN_Quote__c = childQuote_ENT.Id;
    insert CLI_Elec;
	
	vlocity_cmt__ContractLineItem__c CLI_Elec_2 = new vlocity_cmt__ContractLineItem__c();
    CLI_Elec_2.vlocity_cmt__ContractId__c = con2.id;
  //CLI.vlocity_cmt__ServicePointId__c = servicePoint.id;
    CLI_Elec_2.SWAN_Service_Point__c = servicePoint_elec_2.id;
    CLI_Elec_2.SWAN_Quote__c = childQuote_ENT_2.Id;
    insert CLI_Elec_2;*/
    
    /*con2.status = 'Contract Signed';
    update con2;*/
  }  
  
  @isTest
  public static void childQuoteInsertTest()
    {
    SWAN_TRESORFileController.runTRESORReport();
    }
  
  @isTest
  public static void getReportDataTest()
    {
    SWAN_TRESORFileController.runTRESORReport();
    SWAN_TRESORFileController.getReportData(date.today());
    }
    
    @isTest
  public static void ForSiteAdditionQuotes()
    {
        Opportunity opp = [select Id from Opportunity where Name = 'Test Opp'];
        Id recId = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('Site Addition Quote').getRecordTypeId();
        Id recId1 = Schema.SObjectType.Quote.getRecordTypeInfosByName().get(label.QuoteSiteAdditionRecordType).getRecordTypeId();  
          
        Quote childQuote = new Quote();
        childQuote.recordTypeId=recId;
        childQuote.Name = 'Site Addition Quote';
        childQuote.SWAN_Site_Addition_Parent__c = masterQuote.Id;
        childQuote.OpportunityId = opp.id;
        childQuote.status='Draft';
        childQuote.SWAN_Contribution_Margin__c=1615.19;
        childQuote.SWAN_Gross_Margin__c =   1970.25;
        childQuote.SWAN_Contract_Volume_KWh__c=10;
        childQuote.SWAN_Offer_End_Date__c  = Date.newInstance(2021,11,26);
        childQuote.SWAN_Offer_Start_Date__c   = Date.newInstance(2019,11,26);
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
        SWAN_TRESORFileController.runTRESORReport();
        SWAN_TRESORFileController.getReportData(date.today());
        } catch(Exception ex){}
        Test.stopTest();
    }
}