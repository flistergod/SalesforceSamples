@isTest
public class SWAN_OfferPackTest {
    
    public static Opportunity opp = new Opportunity();
    public static Contact con = new Contact();
    
    public static void createStaticData()
    {
        Account acc = new Account();
        acc.Name = 'Test Opp';
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
    }
    
    @isTest
    public static void differentPricingStructureTest()
    {
        createStaticData();
        
        Quote masterQuote1 = new Quote();
        masterQuote1.OpportunityId = opp.Id;
        masterQuote1.Name = 'Master Quote';
        masterQuote1.SWAN_Pricing_Structure__c = 'Site Specific With Standing Charge';
        masterQuote1.SWAN_Payment_Method_and_Term__c = 'Direct Debit - 14 Days';
        masterQuote1.SWAN_Payment_Method__c = 'Direct Debit';
        masterQuote1.SWAN_Payment_Term__c = '14 Days';
        masterQuote1.SWAN_Offer_Start_Date__c = Date.today();
        masterQuote1.SWAN_Number_of_Service_Points__c = 2;
        insert masterQuote1;
        
        Quote masterQuote2 = new Quote();
        masterQuote2.OpportunityId = opp.Id;
        masterQuote2.Name = 'Master Quote';
        masterQuote2.SWAN_Pricing_Structure__c = 'Site Specific Without Standing Charge';
        masterQuote2.SWAN_Payment_Method_and_Term__c = 'Direct Debit - 14 Days';
        masterQuote2.SWAN_Payment_Method__c = 'Direct Debit';
        masterQuote2.SWAN_Payment_Term__c = '14 Days';
        masterQuote2.SWAN_Offer_Start_Date__c = Date.today();
        masterQuote2.SWAN_Number_of_Service_Points__c = 2;
        insert masterQuote2;
        
        Test.startTest();
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
        
        Test.stopTest();
    }
    
    @isTest
    public static void differentPaymentMethodTest()
    {
        createStaticData();
        
        Quote masterQuote1 = new Quote();
        masterQuote1.OpportunityId = opp.Id;
        masterQuote1.Name = 'Master Quote';
        masterQuote1.SWAN_Pricing_Structure__c = 'Site Specific With Standing Charge';
        masterQuote1.SWAN_Payment_Method_and_Term__c = 'Direct Debit - 14 Days';
        masterQuote1.SWAN_Payment_Method__c = 'Direct Debit';
        masterQuote1.SWAN_Payment_Term__c = '14 Days';
        masterQuote1.SWAN_Offer_Start_Date__c = Date.today();
        masterQuote1.SWAN_Number_of_Service_Points__c = 2;
        insert masterQuote1;
        
        system.debug('--------------------------');
        
        Quote masterQuote2 = new Quote();
        masterQuote2.OpportunityId = opp.Id;
        masterQuote2.Name = 'Master Quote';
        masterQuote2.SWAN_Pricing_Structure__c = 'Site Specific With Standing Charge';
        masterQuote2.SWAN_Payment_Method_and_Term__c = 'BACS - 14 Days';
        masterQuote2.SWAN_Payment_Method__c = 'BACS';
        masterQuote2.SWAN_Payment_Term__c = '14 Days';
        masterQuote2.SWAN_Offer_Start_Date__c = Date.today();
        masterQuote2.SWAN_Number_of_Service_Points__c = 2;
        insert masterQuote2;
        
        system.debug('--------------------------');
        
        Test.startTest();
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
        
        Test.stopTest();
    }
    
    @isTest
    public static void differentStartDateTest()
    {
        createStaticData();
        
        Quote masterQuote1 = new Quote();
        masterQuote1.OpportunityId = opp.Id;
        masterQuote1.Name = 'Master Quote';
        masterQuote1.SWAN_Pricing_Structure__c = 'Site Specific With Standing Charge';
        masterQuote1.SWAN_Payment_Method_and_Term__c = 'Direct Debit - 14 Days';
        masterQuote1.SWAN_Payment_Method__c = 'Direct Debit';
        masterQuote1.SWAN_Payment_Term__c = '14 Days';
        masterQuote1.SWAN_Offer_Start_Date__c = Date.today();
        masterQuote1.SWAN_Number_of_Service_Points__c = 2;
        insert masterQuote1;
        
        Quote masterQuote2 = new Quote();
        masterQuote2.OpportunityId = opp.Id;
        masterQuote2.Name = 'Master Quote';
        masterQuote2.SWAN_Pricing_Structure__c = 'Site Specific With Standing Charge';
        masterQuote2.SWAN_Payment_Method_and_Term__c = 'Direct Debit - 14 Days';
        masterQuote2.SWAN_Payment_Method__c = 'Direct Debit';
        masterQuote2.SWAN_Payment_Term__c = '14 Days';
        masterQuote2.SWAN_Offer_Start_Date__c = Date.today().addDays(2);
        masterQuote2.SWAN_Number_of_Service_Points__c = 2;
        insert masterQuote2;
        
        Test.startTest();
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
        
        Test.stopTest();
    }
    
    @isTest
    public static void differentSiteTest()
    {
        createStaticData();
        
        Quote masterQuote1 = new Quote();
        masterQuote1.OpportunityId = opp.Id;
        masterQuote1.Name = 'Master Quote';
        masterQuote1.SWAN_Pricing_Structure__c = 'Site Specific With Standing Charge';
        masterQuote1.SWAN_Payment_Method_and_Term__c = 'Direct Debit - 14 Days';
        masterQuote1.SWAN_Payment_Method__c = 'Direct Debit';
        masterQuote1.SWAN_Payment_Term__c = '14 Days';
        masterQuote1.SWAN_Offer_Start_Date__c = Date.today();
        masterQuote1.SWAN_Number_of_Service_Points__c = 2;
        insert masterQuote1;
        
        Quote masterQuote2 = new Quote();
        masterQuote2.OpportunityId = opp.Id;
        masterQuote2.Name = 'Master Quote';
        masterQuote2.SWAN_Pricing_Structure__c = 'Site Specific With Standing Charge';
        masterQuote2.SWAN_Payment_Method_and_Term__c = 'Direct Debit - 14 Days';
        masterQuote2.SWAN_Payment_Method__c = 'Direct Debit';
        masterQuote2.SWAN_Payment_Term__c = '14 Days';
        masterQuote2.SWAN_Offer_Start_Date__c = Date.today();
        masterQuote2.SWAN_Number_of_Service_Points__c = 3;
        insert masterQuote2;
        
        Test.startTest();
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
        
        delete listOfferPackQuote[0];
        Test.stopTest();
    }
    
    @isTest
    public static void invalidPriceData()
    {
        createStaticData();
        
        Quote masterQuote1 = new Quote();
        masterQuote1.OpportunityId = opp.Id;
        masterQuote1.Name = 'Master Quote';
        masterQuote1.SWAN_Pricing_Structure__c = 'Site Specific With Standing Charge';
        masterQuote1.SWAN_Payment_Method_and_Term__c = 'Direct Debit - 14 Days';
        masterQuote1.SWAN_Payment_Method__c = 'Direct Debit';
        masterQuote1.SWAN_Payment_Term__c = '14 Days';
        masterQuote1.SWAN_Offer_Start_Date__c = Date.today();
        masterQuote1.SWAN_Price_out_of_Date__c = true;
        masterQuote1.SWAN_Number_of_Service_Points__c = 2;
        insert masterQuote1;
        
        Quote masterQuote2 = new Quote();
        masterQuote2.OpportunityId = opp.Id;
        masterQuote2.Name = 'Master Quote';
        masterQuote2.SWAN_Pricing_Structure__c = 'Site Specific With Standing Charge';
        masterQuote2.SWAN_Payment_Method_and_Term__c = 'Direct Debit - 14 Days';
        masterQuote2.SWAN_Payment_Method__c = 'Direct Debit';
        masterQuote2.SWAN_Payment_Term__c = '14 Days';
        masterQuote2.SWAN_Offer_Start_Date__c = Date.today();
        masterQuote2.SWAN_Number_of_Service_Points__c = 3;
        insert masterQuote2;
        
        Test.startTest();
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
        
        delete listOfferPackQuote[0];
        Test.stopTest();
    }
    
    @isTest
    public static void invalidPriceDataCorrectSiteData()
    {
        createStaticData();
        
        Quote masterQuote1 = new Quote();
        masterQuote1.OpportunityId = opp.Id;
        masterQuote1.Name = 'Master Quote';
        masterQuote1.SWAN_Pricing_Structure__c = 'Site Specific With Standing Charge';
        masterQuote1.SWAN_Payment_Method_and_Term__c = 'Direct Debit - 14 Days';
        masterQuote1.SWAN_Payment_Method__c = 'Direct Debit';
        masterQuote1.SWAN_Payment_Term__c = '14 Days';
        masterQuote1.SWAN_Offer_Start_Date__c = Date.today();
        masterQuote1.SWAN_Price_out_of_Date__c = true;
        masterQuote1.SWAN_Number_of_Service_Points__c = 2;
        insert masterQuote1;
        
        Quote masterQuote2 = new Quote();
        masterQuote2.OpportunityId = opp.Id;
        masterQuote2.Name = 'Master Quote';
        masterQuote2.SWAN_Pricing_Structure__c = 'Site Specific With Standing Charge';
        masterQuote2.SWAN_Payment_Method_and_Term__c = 'Direct Debit - 14 Days';
        masterQuote2.SWAN_Payment_Method__c = 'Direct Debit';
        masterQuote2.SWAN_Payment_Term__c = '14 Days';
        masterQuote2.SWAN_Offer_Start_Date__c = Date.today();
        masterQuote2.SWAN_Number_of_Service_Points__c = 2;
        insert masterQuote2;
        
        Test.startTest();
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
        
        delete listOfferPackQuote[0];
        Test.stopTest();
    }
    
    @isTest
    public static void invalidPriceData_Test()
    {
        createStaticData();
        
        Quote masterQuote1 = new Quote();
        masterQuote1.OpportunityId = opp.Id;
        masterQuote1.Name = 'Master Quote';
        masterQuote1.SWAN_Pricing_Structure__c = 'Site Specific With Standing Charge';
        masterQuote1.SWAN_Payment_Method_and_Term__c = 'Direct Debit - 14 Days';
        masterQuote1.SWAN_Payment_Method__c = 'Direct Debit';
        masterQuote1.SWAN_Payment_Term__c = '14 Days';
        masterQuote1.SWAN_Offer_Start_Date__c = Date.today();
        masterQuote1.SWAN_Price_out_of_Date__c = true;
        masterQuote1.SWAN_Number_of_Service_Points__c = 2;
        insert masterQuote1;
        
        Quote masterQuote2 = new Quote();
        masterQuote2.OpportunityId = opp.Id;
        masterQuote2.Name = 'Master Quote';
        masterQuote2.SWAN_Pricing_Structure__c = 'Site Specific With Standing Charge';
        masterQuote2.SWAN_Payment_Method_and_Term__c = 'Direct Debit - 14 Days';
        masterQuote2.SWAN_Payment_Method__c = 'Direct Debit';
        masterQuote2.SWAN_Payment_Term__c = '14 Days';
        masterQuote2.SWAN_Offer_Start_Date__c = Date.today();
        masterQuote2.SWAN_Number_of_Service_Points__c = 3;
        insert masterQuote2;
        
         Product2 oUnitCharge = new Product2();
          oUnitCharge.Name = 'Unit Rate';
          oUnitCharge.ProductCode = 'BG_UNITRATE'; 
          oUnitCharge.IsActive = true;
        oUnitCharge.vlocity_cmt__IsOrderable__c = true;
          insert oUnitCharge;
          
          Product2 oUnitCharge1 = new Product2();
          oUnitCharge1.Name = 'Unit Rate';
          oUnitCharge1.ProductCode = 'BG_UNITRATE'; 
          oUnitCharge1.IsActive = true;
        oUnitCharge1.vlocity_cmt__IsOrderable__c = true;
          insert oUnitCharge1;
        
        Pricebook2 pb = new pricebook2();
        pb.Name = 'Standard Price Book 2009';
        pb.description = 'Price Book 2009 Products';
        pb.isActive = True;
        insert pb;
       
       Id pricebookId = Test.getStandardPricebookId();        

        PricebookEntry StandardPriceBookEntry = new PricebookEntry();
        StandardPriceBookEntry.Pricebook2Id = pricebookId;
        StandardPriceBookEntry.Product2Id = oUnitCharge.Id;
        StandardPriceBookEntry.UnitPrice = 10000;
        StandardPriceBookEntry.IsActive =True;        
        insert StandardPriceBookEntry;
        
         PricebookEntry pbe = new PricebookEntry(pricebook2id=pb.id, product2id=oUnitCharge.id, unitprice=10000, isActive = True);
       insert pbe;
        
         PricebookEntry StandardPriceBookEntry1 = new PricebookEntry();
        StandardPriceBookEntry1.Pricebook2Id = pricebookId;
        StandardPriceBookEntry1.Product2Id = oUnitCharge1.Id;
        StandardPriceBookEntry1.UnitPrice = 10000;
        StandardPriceBookEntry1.IsActive =True;        
        insert StandardPriceBookEntry1;
       
       PricebookEntry pbe1 = new PricebookEntry(pricebook2id=pb.id, product2id=oUnitCharge1.id, unitprice=10000, isActive = True);
       insert pbe1;
       
       Quote oTestChildQuote = new Quote();
      oTestChildQuote.vlocity_cmt__ParentQuoteId__c = masterQuote1.Id;
      oTestChildQuote.Name = 'Child Quote test';
      oTestChildQuote.OpportunityId = opp.Id; 
      oTestChildQuote.Pricebook2Id = pb.Id;
      insert oTestChildQuote;
      
      
      
      Quote oTestChildQuote1 = new Quote();
      oTestChildQuote1.vlocity_cmt__ParentQuoteId__c = masterQuote2.Id;
      oTestChildQuote1.Name = 'Child Quote test1';
      oTestChildQuote1.OpportunityId = opp.Id; 
      oTestChildQuote1.Pricebook2Id = pb.Id;
      insert oTestChildQuote1;
      
        QuoteLineItem QLI  = new QuoteLineItem();
        QLI.Product2Id = oUnitCharge.Id;
        QLI.QuoteId = oTestChildQuote.Id;
        QLI.PricebookEntryId = Pbe.Id;
        QLI.Quantity = 2;
        QLI.UnitPrice = 150000.0; 
        insert QLI;
        
        QuoteLineItem QLI1  = new QuoteLineItem();
        QLI1.Product2Id = oUnitCharge1.Id;
        QLI1.QuoteId = oTestChildQuote1.Id;
        QLI1.PricebookEntryId = Pbe.Id;
        QLI1.Quantity = 2;
        QLI1.UnitPrice = 150000.0; 
        insert QLI1;
        
        Test.startTest();
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
        Test.stopTest();
    }
}