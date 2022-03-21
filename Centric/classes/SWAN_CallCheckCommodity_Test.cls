@isTest
public class SWAN_CallCheckCommodity_Test{
 
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
    public static void callInteProTest1()
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
        masterQuote2.SWAN_Price_out_Of_Date__c = true;
        insert masterQuote2;
        
        
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
        Map<String,Object> mapOfferId = new Map<String,Object>();
        Map<String,Object> outputMap = new Map<String,Object>();
        Map<String,Object> Options = new Map<String,Object>();
        mapOfferId.put('OfferPackId',offerPack.Id);
        Test.startTest();
        SWAN_CallCheckCommodity callCheck = new SWAN_CallCheckCommodity();
        callCheck.invokeMethod('callIntegration',mapOfferId,outputMap,Options);
        Test.stopTest();
    }
    
    @isTest
    public static void callInteProTest2()
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
        masterQuote2.SWAN_Price_out_Of_Date__c = true;
        insert masterQuote2;
        
        
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
        Map<String,Object> mapOfferId = new Map<String,Object>();
        Map<String,Object> outputMap = new Map<String,Object>();
        Map<String,Object> Options = new Map<String,Object>();
        mapOfferId.put('OfferPackId',offerPack.Id);
        Test.startTest();
        SWAN_CallCheckCommodity callCheck = new SWAN_CallCheckCommodity();
        callCheck.invokeMethod('callIntegration1',mapOfferId,outputMap,Options);
        Test.stopTest();
    }
}