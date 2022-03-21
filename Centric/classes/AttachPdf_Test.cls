@isTest
public class AttachPdf_Test{
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
    public static void attachPdfTestmethod()
    {
        createStaticData();
        
        Quote masterQuote1 = new Quote();
        masterQuote1.OpportunityId = opp.Id;
        masterQuote1.Name = 'Master Quote';
        masterQuote1.SWAN_Pricing_Structure__c = 'Site Specific With Standing Charge';
        masterQuote1.SWAN_Payment_Method_and_Term__c = 'Direct Debit - 14 Days';
        masterQuote1.SWAN_Offer_Start_Date__c = Date.today();
        masterQuote1.SWAN_Number_of_Service_Points__c = 2;
        insert masterQuote1;
        
        Quote masterQuote2 = new Quote();
        masterQuote2.OpportunityId = opp.Id;
        masterQuote2.Name = 'Master Quote';
        masterQuote2.SWAN_Pricing_Structure__c = 'Site Specific Without Standing Charge';
        masterQuote2.SWAN_Payment_Method_and_Term__c = 'Direct Debit - 14 Days';
        masterQuote2.SWAN_Offer_Start_Date__c = Date.today();
        masterQuote2.SWAN_Number_of_Service_Points__c = 2;
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
        Map<String,Object> inputMap = new Map<String, Object>(); 
        Map<String,Object> outMap = new Map<String, Object>(); 
        Map<String,Object> options = new Map<String, Object>();
        
        inputMap.put('ContextId',offerPack.Id);
        
        ContentVersion contentVersion = new ContentVersion(
          Title = 'Penguins',
          PathOnClient = 'Penguins.jpg',
          VersionData = Blob.valueOf('Test Content'),
          IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = offerPack.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        AttachPdf  ap = new AttachPdf ();
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AttachPDFMockImpl());
        ap.invokeMethod('attachPdf',inputMap,outMap,options);

        
        Test.stopTest();
    }
    
    @isTest
    public static void attachPdfTestmethod1()
    {
        Map<String,Object> inputMap = new Map<String, Object>(); 
        Map<String,Object> outMap = new Map<String, Object>(); 
        Map<String,Object> options = new Map<String, Object>();
        
        Test.StartTest();
          AttachPdf  ap = new AttachPdf ();
          ap.invokeMethod('attachPdf1',inputMap,outMap,options);
        Test.StopTest();
    }
    
    }