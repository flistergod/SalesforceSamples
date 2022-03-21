@isTest
public class TestDataFactory {


    public static Account createAccount(String name) {
        
        Account acc = new Account(Name=name);
        acc.SWAN_Customer_Segment__c = 'I&C';
        acc.SWAN_Micro_Business_Selection__c = 'Non_Micro_Business';
        insert acc;

        TestDataFactory.createContact(acc.Name, 'Last Name', acc.Id, true);
        
        return acc;
    }

    public static Contact createContact(String firstName, String lastName, ID accountId, Boolean doInsert){
        Contact con = new Contact();
        con.AccountId = accountId;
        con.lastName = lastName;
        con.firstname =firstName;
        con.MailingStreet='M street';
        con.MailingPostalCode='M50 2HX';
        con.SWAN_Mailing_Building_Name__c='Building name';
        con.MailingCity = 'test City';
        
        if(doInsert){
            insert con;
        }

        return con;
    }

    public static Opportunity createOpportunity(Account acc, String fuelType, String recordTypeName, String stageName) {

        Id pricebookId = Test.getStandardPricebookId();
        vlocity_cmt__PriceList__c prList = new vlocity_cmt__PriceList__c(vlocity_cmt__Code__c='PL-B2BT',vlocity_cmt__IsActive__c=true,vlocity_cmt__Pricebook2Id__c=pricebookId,Name='I&C Price List');
        //insert prList;
        
        Opportunity opp = new Opportunity();
        opp.Name=acc.Name + ' Opportunity ';
        opp.StageName = stageName;
        opp.CloseDate = System.today().addMonths(6); //Acquisition or Renewal
        opp.SWAN_Fuel_Type__c = fuelType; //Gas or Electricity
        //opp.vlocity_cmt__PriceListId__c =prList.Id;
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
        insert opp;

        return opp;
    }
      
    public static List<Product2> createProducts( Map<String,String> productNameByCode){
        //name='Fixed Price Gas'
        //productCode='BG_GAS'
        List<Product2> lstProducts = new List<Product2>();
        
        for(String productName : productNameByCode.keySet() ){
            Product2 p = new Product2();
            p.name=productName;
            p.productCode=productNameByCode.get(productName);
            p.vlocity_cmt__IsOrderable__c=true;
            lstProducts.add(p);
        }
        
        return lstProducts;
    }
    
    public static List<PricebookEntry> createStandardPricebookEntry( List<Product2> listProducts ){
        Id pricebookId = Test.getStandardPricebookId();
        List<PricebookEntry> lstStandardPricebookEntry = new List<PricebookEntry>();
        
        for(Product2 p: listProducts){
            PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = p.Id, UnitPrice = 10000, IsActive = true);
            lstStandardPricebookEntry.add(standardPrice);
        }
        
        return lstStandardPricebookEntry;
    }
    
    public static List<PricebookEntry> createCustomPricebookEntry( List<Product2> listProducts, String IdCustomPricebook2 ){
        
        List<PricebookEntry> lstCustomPricebookEntry = new List<PricebookEntry>();
        for(Product2 p: listProducts){
            PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = IdCustomPricebook2, Product2Id = p.Id, UnitPrice = 12000, IsActive = true);
            lstCustomPricebookEntry.add(standardPrice);
        }
        
        return lstCustomPricebookEntry;
    }
    
    public static List<vlocity_cmt__ServicePoint__c> createServicePoints(List<String> lstServicePointsNumbers){
        
        List<vlocity_cmt__ServicePoint__c> lstSPN = new List<vlocity_cmt__ServicePoint__c>();
        Map<String, vlocity_cmt__Premises__c> mapSPNtoPremise = new Map<String,vlocity_cmt__Premises__c>();
        
        for(String spn : lstServicePointsNumbers){
            vlocity_cmt__Premises__c premise = new vlocity_cmt__Premises__c();
            mapSPNtoPremise.put(spn,premise );
        }
        insert mapSPNtoPremise.values();
        
        for(String spn : mapSPNtoPremise.keySet()){
            vlocity_cmt__ServicePoint__c servicePoint = new vlocity_cmt__ServicePoint__c();
            servicePoint.SWAN_Formula_Year_Annual_Quantity__c = 12331;
            servicePoint.SWAN_Formula_Year_Offtake_Quantity__c = 3321;
            servicePoint.vlocity_cmt__ServicePointNumber__c = '0000'+spn;
            servicePoint.vlocity_cmt__PremisesId__c =  mapSPNtoPremise.get(spn).id;
            servicePoint.SWAN_Product_Class__c = '3';
            servicePoint.SWAN_distributor_mpid__c = 'MIDE';
            lstSPN.add(servicePoint);
        }
        
        return lstSPN;
    }

    public static Quote createMasterQuote(Opportunity opp, Pricebook2  customPB, String recordTypeName ){
       
        Quote masterQuote = new Quote();
       
        masterQuote.OpportunityId = opp.Id;
        masterQuote.Name = 'Master Quote Elec';
        masterQuote.SWAN_Quote_for_Fuel_Type__c = opp.SWAN_Fuel_Type__c;
        masterQuote.SWAN_Pricing_Structure__c = 'Site Specific Without Standing Charge';
        masterQuote.SWAN_Payment_Method_and_Term__c = 'Direct Debit - 14 Days';
        masterQuote.SWAN_Offer_Start_Date__c = Date.today().addDays(19);
        masterQuote.SWAN_Offer_End_Date__c = Date.today().addMonths(12);
        masterQuote.SWAN_Number_of_Service_Points__c = 2;
        masterQuote.SWAN_Broker_Commission_Margin_p__c = 0.50;
        masterQuote.Status = 'Draft';
        masterQuote.recordtypeid = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
        masterQuote.pricebook2Id=customPB.id;
        masterQuote.SWAN_Quote_Type__c = 'Flex';

        return masterQuote;
    }



    public static List<Quote> createSubQuotes(List<vlocity_cmt__ServicePoint__c> lstSPN, Quote masterQuote, List<PricebookEntry>  lstCustomPricebookEntry ){

        List<Quote> lstSubQuotes = new List<Quote>();
        
        for(vlocity_cmt__ServicePoint__c spn :  lstSPN ){
            Quote subQuote = new Quote();
            subQuote.pricebook2Id = masterQuote.pricebook2Id;
            subQuote.vlocity_cmt__ParentQuoteId__c = masterQuote.Id;
            subQuote.SWAN_Parent_Quote__c = masterQuote.id;
            subQuote.vlocity_cmt__DefaultServicePointId__c = spn.id;
            subQuote.SWAN_Service_Point__c = spn.id;
            subQuote.SWAN_Service_Point_Start_Date__c =  masterQuote.SWAN_Offer_Start_Date__c ;
            subQuote.SWAN_Offer_End_Date__c =  Date.today().addMonths(6);
            subQuote.name = 'Child quote ' + spn.Id;
            subQuote.OpportunityId = masterQuote.OpportunityId;
            subQuote.SWAN_Broker_Commission__c = 10;
            subQuote.recordtypeid = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('SWAN_Service_Point_Quote').getRecordTypeId();
            subQuote.SWAN_Quote_Type__c = 'Flex';
            lstSubQuotes.add(subQuote);
            
        }

       return lstSubQuotes;

    }
    public static  List<QuoteLineItem> createQuoteLineItems( Quote subQuote, Quote masterQuote,  Integer numberOfQLI, PricebookEntry pBookEntry ){

        List <QuoteLineItem> lstQLI =  new List <QuoteLineItem>();
        // json Attribute is not according with quote
        String JSONATT = '';

        QuoteLineItem qliWithJSONAttribute = new QuoteLineItem();
        qliWithJSONAttribute.QuoteId = subQuote.id;
        qliWithJSONAttribute.PriceBookEntryId=pBookEntry.Id;
        qliWithJSONAttribute.Quantity=1;
        qliWithJSONAttribute.UnitPrice=10;
        qliWithJSONAttribute.vlocity_cmt__JSONAttribute__c=JSONATT;
        lstQLI.add(qliWithJSONAttribute);
        
        for(Integer i=0; i < numberOfQLI ; i++){
            QuoteLineItem qli = new QuoteLineItem();
            qli.QuoteId = subQuote.id;
            qli.PriceBookEntryId=pBookEntry.Id;
            qli.Quantity=1;
            qli.UnitPrice=10;
            lstQLI.add(qli);
        }

        return lstQLI;          
    }


    public static Contract createContractAndCLI(List<Quote> lstSubQuotes, Quote masterQuote, Account account, Product2 prod, Map<String, List<QuoteLineItem>> mapSubQuoteToQLI ){
        
        // created Contract
        Contract ct = new Contract();
        ct.vlocity_cmt__QuoteId__c = masterQuote.id;
        ct.AccountId = account.Id;
        ct.status = 'Draft';
        ct.StartDate = System.today();
        ct.EndDate = ct.StartDate.addMonths(6);
        insert ct;

        // create contract line items
        // create Child contract line items
        addContractLineItems(lstSubQuotes, prod, ct, mapSubQuoteToQLI);

        //create contract History 
        ContractHistory ctHistory = new ContractHistory();  
        ctHistory.ContractId = ct.Id;
        ctHistory.Field = 'created';
        insert ctHistory;
       
        return ct;
    }

    public static void addContractLineItems(List<Quote> lstSubQuotes,  Product2 prod, Contract ct, Map<String, List<QuoteLineItem>> mapSubQuoteToQLI ){
       
        List<vlocity_cmt__ContractLineItem__c> lstCLI = new List<vlocity_cmt__ContractLineItem__c>();
        List<vlocity_cmt__ContractLineItem__c> lstChildCLI = new List<vlocity_cmt__ContractLineItem__c>();
       
        // create contract line items
        for(Quote subQuote : lstSubQuotes ){
            vlocity_cmt__ContractLineItem__c cli = new vlocity_cmt__ContractLineItem__c();
            cli.vlocity_cmt__ContractId__c = ct.Id;
            cli.SWAN_Service_Point__c = subQuote.vlocity_cmt__DefaultServicePointId__c;
            cli.SWAN_Quote__c=subQuote.Id;
            cli.vlocity_cmt__EffectiveStartDate__c= subQuote.SWAN_Service_Point_Start_Date__c;
            cli.vlocity_cmt__EffectiveEndDate__c= subQuote.SWAN_Offer_End_Date__c;

            lstCLI.add(cli);    
        }

        insert lstCLI;   

        // create Child contract line items
        for(vlocity_cmt__ContractLineItem__c cli : lstCLI ){
            for(QuoteLineItem qli : mapSubQuoteToQLI.get(cli.SWAN_Quote__c) ){

                vlocity_cmt__ContractLineItem__c childCLI = new vlocity_cmt__ContractLineItem__c();
                childCLI.vlocity_cmt__ContractId__c = cli.vlocity_cmt__ContractId__c;
                childCLI.vlocity_cmt__Product2Id__c = prod.Id;
                childCLI.vlocity_cmt__OriginalLineItemId__c=cli.Id;
                cli.vlocity_cmt__EffectiveEndDate__c= cli.vlocity_cmt__EffectiveStartDate__c;
                lstChildCLI.add(childCLI);
            }
        }
        insert lstChildCLI;

    }


    public static void createQuoteStatusTracking( Quote masterQuote, String newStatus  ){
        SWAN_Quote_Status_Tracking__c swanQST = new SWAN_Quote_Status_Tracking__c();
        swanQST.SWAN_Quote__c = masterQuote.Id;
        swanQST.New_Status__c = newStatus;

        insert swanQST;
    }

    public static SWAN_Offer_Pack_Quote__c createQuoteOfferPack( Quote masterQuote, String nameOP ){

        SWAN_Offer_Pack__c offerPack = new SWAN_Offer_Pack__c();
        offerPack.Contact__c = TestDataFactory.createContact('First', 'Last', masterQuote.Opportunity.AccountId, true).Id;
        offerPack.Name = nameOP ;
        offerPack.SWAN_Opportunity__c = masterQuote.OpportunityId;
        offerPack.SWAN_IsNotAmendable__c = false;
        insert offerPack;
      
        SWAN_Offer_Pack_Quote__c childOfferPack = new SWAN_Offer_Pack_Quote__c();
        childOfferPack.SWAN_Offer_Pack__c = offerPack.id;
        childOfferPack.SWAN_Quote__c = masterQuote.id;
        
        return  childOfferPack;
    }

    public static void  createAllDataUntilContractCounterSigned(){
         
        Map<String, List<QuoteLineItem>> mapSubQuoteToQLI = new Map<String, List<QuoteLineItem>>();
        //create account  
        Account acc =  TestDataFactory.createAccount('TestAccount');
        Opportunity opp = TestDataFactory.createOpportunity(acc, 'Electricity', 'Acquisition', 'Qualification');
        
        //create products    
        Map<String,String> productNameByCode = new Map<String,String>{'Fixed Price Gas' => 'BG_GAS', 'Fixed Price Electricity' => 'BG_Elec'};
        List<Product2> lstproducts = TestDataFactory.createProducts(productNameByCode);
        insert lstproducts; 

        //create price Standard Pricebook Entries
        List<PricebookEntry> lstStandardPricebookEntry = TestDataFactory.createStandardPricebookEntry(lstproducts);
        insert lstStandardPricebookEntry;

        //create price Custom Pricebook 
        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;

        //create price Custom Pricebook Entries
        List<PricebookEntry> lstCustomPricebookEntry = TestDataFactory.createCustomPricebookEntry(lstproducts, customPB.Id);
        insert lstCustomPricebookEntry;

        //create Service points
        List<String> lstServicePointsNumbers = new List<String>{'1111', '2222' };
        List<vlocity_cmt__ServicePoint__c> lstSPN =TestDataFactory.createServicePoints(lstServicePointsNumbers);
        insert lstSPN;
        
        //Create Master Quote
        Quote masterQuote =TestDataFactory.createMasterQuote(opp, customPB , 'MasterQuote');
        insert masterQuote;
        
        //Create sub Quotes 
        List<Quote> lstSubQuotes = TestDataFactory.createSubQuotes(lstSPN,masterQuote, lstCustomPricebookEntry );
        insert lstSubQuotes;

        //create Quote Line Items
        List<QuoteLineItem> lstQLI = new List<QuoteLineItem>() ;
        for(Quote subQuote : lstSubQuotes ){
            lstQLI.addAll(TestDataFactory.createQuoteLineItems( subQuote, masterQuote,  2, lstCustomPricebookEntry.get(0) ));
            mapSubQuoteToQLI.put(subQuote.Id , lstQLI);
            
        }
        insert lstQLI;

        //create Service points For site  addition
        List<String> lstServicePointsNumbersSA = new List<String>{'3333', '4444' };
        List<vlocity_cmt__ServicePoint__c> lstSPNSA =TestDataFactory.createServicePoints(lstServicePointsNumbersSA);
        insert lstSPNSA;

        //create Offer Pack
        SWAN_Offer_Pack_Quote__c offerPack = TestDataFactory.createQuoteOfferPack(masterQuote, 'Test Offer Pack');
        insert offerPack;

        //Create Master Quote Site Addition
        Quote masterQuoteSA =TestDataFactory.createMasterQuote(opp, customPB , 'Site_Addition_Quote');
        insert masterQuoteSA;

        //Create sub Quotes 
        List<Quote> lstSubQuotesSA = TestDataFactory.createSubQuotes(lstSPNSA ,masterQuoteSA, lstCustomPricebookEntry );
        insert lstSubQuotesSA;
        
        for(Quote subQuote : lstSubQuotesSA ){
            lstQLI.addAll(TestDataFactory.createQuoteLineItems( subQuote, masterQuote,  2, lstCustomPricebookEntry.get(0) ));
            mapSubQuoteToQLI.put(subQuote.Id , lstQLI);
            
        }
    
        //create Contract  and respctive CLI's
        Contract ct = TestDataFactory.createContractAndCLI(lstSubQuotes, masterQuote, acc, lstproducts.get(0), mapSubQuoteToQLI);
        //change contract status 
        /*
        ct.status = 'Awaiting Signature';
        update ct;
        ct.status = 'Contract Counter Signed';
        update ct;
        */
        //add contract line items from site Addition
        TestDataFactory.addContractLineItems(lstSubQuotesSA,  lstproducts.get(0), ct, mapSubQuoteToQLI);
    }

    public static void createMasterQuoteWithQLI(){
        
        Map<String, List<QuoteLineItem>> mapSubQuoteToQLI = new Map<String, List<QuoteLineItem>>();
        //create account  
        Account acc =  TestDataFactory.createAccount('TestAccount');
        Opportunity opp = TestDataFactory.createOpportunity(acc, 'Electricity', 'Acquisition', 'Qualification');
        
        //create products    
        Map<String,String> productNameByCode = new Map<String,String>{'Fixed Price Gas' => 'BG_GAS', 'Fixed Price Electricity' => 'BG_Elec'};
        List<Product2> lstproducts = TestDataFactory.createProducts(productNameByCode);
        insert lstproducts; 

        //create price Standard Pricebook Entries
        List<PricebookEntry> lstStandardPricebookEntry = TestDataFactory.createStandardPricebookEntry(lstproducts);
        insert lstStandardPricebookEntry;

        //create price Custom Pricebook 
        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;

        //create price Custom Pricebook Entries
        List<PricebookEntry> lstCustomPricebookEntry = TestDataFactory.createCustomPricebookEntry(lstproducts, customPB.Id);
        insert lstCustomPricebookEntry;

        //create Service points
        List<String> lstServicePointsNumbers = new List<String>{'1111', '2222' };
        List<vlocity_cmt__ServicePoint__c> lstSPN =TestDataFactory.createServicePoints(lstServicePointsNumbers);
        insert lstSPN;
        
        //Create Master Quote
        Quote masterQuote =TestDataFactory.createMasterQuote(opp, customPB , 'MasterQuote');
        insert masterQuote;
        
        //Create sub Quotes 
        List<Quote> lstSubQuotes = TestDataFactory.createSubQuotes(lstSPN,masterQuote, lstCustomPricebookEntry );
        insert lstSubQuotes;

        Quote bag = TestDataFactory.createSubQuoteBusinessAccountGroup(masterQuote, lstCustomPricebookEntry).get(0);
        insert bag;
        

        //create Quote Line Items
        List<QuoteLineItem> lstQLI = new List<QuoteLineItem>() ;
        lstQLI.addAll(TestDataFactory.createQuoteLineItems( bag, masterQuote,  2, lstCustomPricebookEntry.get(0) ));
        lstQLI.addAll(TestDataFactory.createQuoteLineItems( masterQuote, masterQuote, 1, lstCustomPricebookEntry.get(0) ));        
        
        for(Quote subQuote : lstSubQuotes ){
            lstQLI.addAll(TestDataFactory.createQuoteLineItems( subQuote, masterQuote,  2, lstCustomPricebookEntry.get(0) ));   
        }
        insert lstQLI;
    }

    public static List<Quote> createSubQuoteBusinessAccountGroup(Quote masterQuote, List<PricebookEntry>  lstCustomPricebookEntry ){

        List<Quote> lstSubQuotes = new List<Quote>();
        
        Quote subQuote = new Quote();
        subQuote.pricebook2Id = masterQuote.pricebook2Id;
        subQuote.vlocity_cmt__ParentQuoteId__c = masterQuote.Id;
        subQuote.SWAN_Parent_Quote__c = masterQuote.id;
        subQuote.SWAN_Service_Point_Start_Date__c =  masterQuote.SWAN_Offer_Start_Date__c ;
        subQuote.SWAN_Offer_End_Date__c =  Date.today().addMonths(6);
        subQuote.name = 'Business Account Group';
        subQuote.OpportunityId = masterQuote.OpportunityId;
        subQuote.recordtypeid = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('GroupCart').getRecordTypeId();
        subQuote.SWAN_Quote_Type__c = 'Flex';
        lstSubQuotes.add(subQuote);

       return lstSubQuotes;

    }

}