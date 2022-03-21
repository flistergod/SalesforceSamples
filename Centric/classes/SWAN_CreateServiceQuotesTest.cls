@isTest
public class SWAN_CreateServiceQuotesTest {
    
    public static Quote masterQuote = new Quote();
    public static Quote masterQuote1 = new Quote();
    public static Opportunity opp = new Opportunity();
    public static Contact con = new Contact();
    public Static List<Id> spList = new List<Id>();
    
    
    @testSetup static void createStaticDataWithOfferPack(){
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
        
        Product2 prod_FixedPriceGas = new Product2(Name = 'Fixed Price Gas',ProductCode='BG_GAS');
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
        
        Quote childQuote = new Quote();
        
        //Contract Spend £120,089
        //Annual Spend Pricing £79,841
        //Contract Volume (KWh)20,111
        childQuote.SWAN_Parent_Quote__c= masterQuote1.id;
        childQuote.vlocity_cmt__ParentQuoteId__c = masterQuote1.id;
        childQuote.vlocity_cmt__DefaultServicePointId__c = servicePoint.id;
        childQuote.SWAN_Service_Point_Start_Date__c = date.today();
        childQuote.name = 'child quote';
        childQuote.OpportunityId = opp.id;
        childQuote.pricebook2Id = pb.Id;
        childQuote.RecordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('Sub Quote').getRecordTypeId();

        insert childQuote;
        
        Quote grQuote = new Quote();
        date endDate = date.today();  //.addYears(2)
        grQuote.SWAN_Parent_Quote__c= masterQuote1.id;
        grQuote.vlocity_cmt__ParentQuoteId__c = masterQuote1.id;
        grQuote.vlocity_cmt__DefaultServicePointId__c = servicePoint.id;
        grQuote.SWAN_Service_Point_Start_Date__c = date.today();
        grQuote.SWAN_Offer_Start_Date__c = date.today(); 
        grQuote.SWAN_Offer_End_Date__c = endDate.addYears(2);
        grQuote.name = 'grQuote';
        grQuote.OpportunityId = opp.id;
        grQuote.pricebook2Id = pb.Id;
        grQuote.RecordTypeId=Schema.SObjectType.Quote.getRecordTypeInfosByName().get('Group Cart').getRecordTypeId();
        insert grQuote;
        
        vlocity_cmt__QuoteGroup__c QuoteGroup1 = new vlocity_cmt__QuoteGroup__c();
        QuoteGroup1.vlocity_cmt__QuoteId__c = grQuote.Id;
        insert QuoteGroup1;
        
        Quote grQuote2 = new Quote();
        date endDate2 = date.today();  //.addYears(2)
        grQuote2.SWAN_Parent_Quote__c= masterQuote2.id;
        grQuote2.vlocity_cmt__ParentQuoteId__c = masterQuote2.id;
        grQuote2.vlocity_cmt__DefaultServicePointId__c = servicePoint.id;
        grQuote2.SWAN_Service_Point_Start_Date__c = date.today();
        grQuote2.SWAN_Offer_Start_Date__c = date.today();
        grQuote2.SWAN_Offer_End_Date__c = endDate2.addYears(2);  
        grQuote2.name = 'grQuote2';
        grQuote2.OpportunityId = opp.id;
        grQuote2.pricebook2Id = pb.Id;
        grQuote2.RecordTypeId=Schema.SObjectType.Quote.getRecordTypeInfosByName().get('Group Cart').getRecordTypeId();
        insert grQuote2;
        
        vlocity_cmt__QuoteGroup__c QuoteGroup2 = new vlocity_cmt__QuoteGroup__c();
        QuoteGroup2.vlocity_cmt__QuoteId__c = grQuote2.Id;
        insert QuoteGroup2;  
        
        Quote childQuote2 = new Quote();
        childQuote2.SWAN_Parent_Quote__c= masterQuote1.id;
        childQuote2.vlocity_cmt__ParentQuoteId__c = masterQuote1.id;
        childQuote2.vlocity_cmt__DefaultServicePointId__c = servicePoint.id;
        childQuote2.SWAN_Service_Point_Start_Date__c = date.today();
        childQuote2.name = 'child quote2';
        childQuote2.OpportunityId = opp.id;
        childQuote2.pricebook2Id = pb.Id;
        childQuote2.RecordTypeId=Schema.SObjectType.Quote.getRecordTypeInfosByName().get('Sub Quote').getRecordTypeId();

        insert childQuote2;  
        
        
        QuoteLineItem qli = new QuoteLineItem();
        qli.Product2Id = prod_FixedPriceGas.Id;
        qli.QuoteId = childQuote.Id;
        qli.UnitPrice = 0;
        qli.Quantity = 1;
        qli.PricebookEntryId = pbe.Id;
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
        
        Contract con = new Contract();
        con.vlocity_cmt__QuoteId__c = masterQuote1.id;
        con.EndDate = masterQuote1.SWAN_Offer_End_Date__c;
        con.SWAN_Offer_End_Date__c = masterQuote1.SWAN_Offer_End_Date__c;
        con.StartDate = masterQuote1.SWAN_Offer_Start_Date__c;
        con.SWAN_Offer_Start_Date__c = masterQuote1.SWAN_Offer_Start_Date__c;
        con.vlocity_cmt__OpportunityId__c = opp.Id;
        con.AccountId = acc.Id;
        con.status ='Draft';
        insert con;
        
    }
    
    @isTest static void createMasterQuoteAndCloneQuoteService() {
        
        
        Quote mQT = [Select Id, OpportunityId from Quote Where Name ='Master Quote 1'];
        
        Quote clMasterQuote = new Quote();
        clMasterQuote.OpportunityId = mQT.OpportunityId;
        clMasterQuote.Name = 'Master Quote Clonned';
        clMasterQuote.SWAN_Pricing_Structure__c = 'Site Specific Without Standing Charge';
        clMasterQuote.SWAN_Payment_Method_and_Term__c = 'Direct Debit - 14 Days';
        clMasterQuote.SWAN_Offer_Start_Date__c = Date.today();
        clMasterQuote.SWAN_Offer_End_Date__c = Date.newInstance(date.today().year()+1, date.today().month(), date.today().Day());
        clMasterQuote.SWAN_Number_of_Service_Points__c = 2;
        clMasterQuote.Status = 'Draft';
        insert clMasterQuote; 
        
        
        ////////////////////////////////////
        Quote grQuote = new Quote();
        date endDate = date.today();  //.addYears(2)
        grQuote.SWAN_Parent_Quote__c= clMasterQuote.id;
        grQuote.vlocity_cmt__ParentQuoteId__c = clMasterQuote.id;
        grQuote.vlocity_cmt__DefaultServicePointId__c = [Select id from vlocity_cmt__ServicePoint__c  Where vlocity_cmt__ServicePointNumber__c='1231231231'].Id;
        grQuote.SWAN_Service_Point_Start_Date__c = date.today();
        grQuote.SWAN_Offer_Start_Date__c = date.today(); 
        grQuote.SWAN_Offer_End_Date__c = endDate.addYears(2);
        grQuote.name = 'grQuote';
        grQuote.OpportunityId = clMasterQuote.OpportunityId;
        grQuote.pricebook2Id = [Select id from PriceBook2 Where name='Example Price Book'].Id;
        grQuote.RecordTypeId=Schema.SObjectType.Quote.getRecordTypeInfosByName().get('Group Cart').getRecordTypeId();
        insert grQuote;
        
        vlocity_cmt__QuoteGroup__c QuoteGroup1 = new vlocity_cmt__QuoteGroup__c();
        QuoteGroup1.vlocity_cmt__QuoteId__c = grQuote.Id;
        insert QuoteGroup1;
        
        Quote grQuote2 = new Quote();
        date endDate2 = date.today();  //.addYears(2)
        grQuote2.SWAN_Parent_Quote__c= clMasterQuote.id;
        grQuote2.vlocity_cmt__ParentQuoteId__c = clMasterQuote.id;
        grQuote2.vlocity_cmt__DefaultServicePointId__c = [Select id from vlocity_cmt__ServicePoint__c  Where vlocity_cmt__ServicePointNumber__c='1231231231'].Id;
        grQuote2.SWAN_Service_Point_Start_Date__c = date.today();
        grQuote2.SWAN_Offer_Start_Date__c = date.today();
        grQuote2.SWAN_Offer_End_Date__c = endDate2.addYears(2);  
        grQuote2.name = 'grQuote2';
        grQuote2.OpportunityId = clMasterQuote.OpportunityId;
        grQuote2.pricebook2Id = [Select id from PriceBook2 Where name='Example Price Book'].Id;
        grQuote2.RecordTypeId=Schema.SObjectType.Quote.getRecordTypeInfosByName().get('Group Cart').getRecordTypeId();
        insert grQuote2;
        
        vlocity_cmt__QuoteGroup__c QuoteGroup2 = new vlocity_cmt__QuoteGroup__c();
        QuoteGroup2.vlocity_cmt__QuoteId__c = grQuote2.Id;
        insert QuoteGroup2;  
        ////////////////////////////////////
        
        
        SWAN_CreateServiceQuotes createSQ = new SWAN_CreateServiceQuotes();
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outputMap = new Map<String, Object>();
        
        List<Quote> ClonnedMasterQuoteId = new List<Quote>();
        ClonnedMasterQuoteId.add(clMasterQuote);
        
        //1º method
        inputMap.put('MasterQuoteId', mQT.Id);
        inputMap.put('ClonnedMasterQuoteId',ClonnedMasterQuoteId);
        Boolean xyz = createSQ.invokeMethod('createServiceQuotes',inputMap,outputMap,null);
        createSQ.invokeMethod(null,inputMap,null,null);
        
        //2º method	
        //
        String name = 'Nothing to find';
        Map<String, Object> output= new Map<String, Object>();
        List<String> lstNames = new List<String>();
        lstNames.add('Master Quote 1');
        lstNames.add('Master Quote 2');
        inputMap.put('NewQuoteName', lstNames);
        createSQ.invokeMethod('checkQuoteName',inputMap,output,null);
        
    }
    
    
}