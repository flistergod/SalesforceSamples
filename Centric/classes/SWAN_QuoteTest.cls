@isTest
public class SWAN_QuoteTest {
    public static Quote masterQuote = new Quote();
  public static Quote masterQuote1 = new Quote();
    public static Opportunity opp = new Opportunity();
    public static Contact con = new Contact();
  
  public static void createStaticDataWithOfferPack()
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
    
    List<Quote> masterQuoteList = new List<Quote>();
    
    //Quote masterQuote = new Quote();
        masterQuote1.OpportunityId = opp.Id;
        masterQuote1.Name = 'Master Quote 1';
        masterQuote1.SWAN_Pricing_Structure__c = 'Site Specific With Standing Charge';
        masterQuote1.SWAN_Payment_Method_and_Term__c = 'Direct Debit - 14 Days';
        masterQuote1.SWAN_Payment_Method__c = 'Direct Debit';
        masterQuote1.SWAN_Payment_Term__c = '14 Days';
        masterQuote1.SWAN_Offer_Start_Date__c = Date.today();
        masterQuote1.SWAN_Number_of_Service_Points__c = 2;
        masterQuote1.SWAN_Pricing_User__c = userinfo.getUserId();
        masterQuoteList.add(masterQuote1);
        
        Quote masterQuote2 = new Quote();
        masterQuote2.OpportunityId = opp.Id;
        masterQuote2.Name = 'Master Quote 2';
        masterQuote2.SWAN_Pricing_Structure__c = 'Site Specific Without Standing Charge';
        masterQuote2.SWAN_Payment_Method_and_Term__c = 'Direct Debit - 14 Days';
        masterQuote2.SWAN_Payment_Method__c = 'Direct Debit';
        masterQuote2.SWAN_Payment_Term__c = '14 Days';
        masterQuote2.SWAN_Offer_Start_Date__c = Date.today();
        masterQuote2.SWAN_Number_of_Service_Points__c = 2;
        masterQuoteList.add(masterQuote2);
    insert masterQuoteList;
        
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
    }
  
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
        
        masterQuote.OpportunityId = opp.Id;
        masterQuote.Name = 'Master Quote';
        insert masterQuote;
    }
    
    @isTest
  public static void childQuoteInsertTest()
    {
        createStaticData();
        
        Test.startTest();
        SWAN_Constants.QuoteTriggerExecuted = false;
        Quote childQuote = new Quote();
        childQuote.Name = 'Child Quote';
        childQuote.vlocity_cmt__ParentQuoteId__c = masterQuote.Id;
        childQuote.OpportunityId = opp.id;
        insert childQuote;
        Test.stopTest();
    }
    
    @isTest
  public static void childQuoteDeleteTest()
    {
        
        createStaticData();
        Id recId = Schema.SObjectType.Quote.getRecordTypeInfosByName().get(label.QuoteServicePointRecordType).getRecordTypeId();
        Quote childQuote = new Quote();
        childQuote.recordTypeId=recId;
        childQuote.Name = 'Child Quote';
        childQuote.vlocity_cmt__ParentQuoteId__c = masterQuote.Id;
        childQuote.OpportunityId = opp.id;
        insert childQuote;
        
        Test.startTest();
        
        SWAN_Constants.QuoteTriggerExecuted = false;
        try{
        delete childQuote;
        }catch(Exception ex){}
        
        Test.stopTest();
    }
  
  @isTest
  public static void quotePriceTest()
    {
        
        createStaticDataWithOfferPack();
        
        Test.startTest();
        masterQuote1.SWAN_Price_out_of_Date__c = true;
    update masterQuote1;
        
        
        Test.stopTest();
    }
  
  @isTest
  public static void quotePricePositiveTest()
    {
        
        createStaticDataWithOfferPack();
        
        Test.startTest();
        masterQuote1.SWAN_Price_out_of_Date__c = true;
    update masterQuote1;
        
    masterQuote1.SWAN_Price_out_of_Date__c = false;
    update masterQuote1;
        
        Test.stopTest();
    }
    
  @isTest
  public static void restrictMasterQuoteDeleteTest()
    {   
        createStaticDataWithOfferPack();
        
        Test.startTest();
            try { 
                SWAN_Constants.QuoteTriggerExecuted = false;
                delete masterQuote1;
            } catch(Exception ex){}
        Test.stopTest();
    }
    
  @isTest
  public static void restrictSubmittedChildQuoteDeleteTest()
    { 
        Id recId = Schema.SObjectType.Quote.getRecordTypeInfosByName().get(label.QuoteServicePointRecordType).getRecordTypeId();  
        createStaticDataWithOfferPack();
        masterQuote1.Status='Submitted';
        masterQuote1.SWAN_Has_been_submitted__c=true;
        update masterQuote1;
        
        Quote childQuote = new Quote();
        childQuote.recordTypeId=recId;
        childQuote.Name = 'Child Quote';
        childQuote.vlocity_cmt__ParentQuoteId__c = masterQuote1.Id;
        childQuote.OpportunityId = opp.id;
        insert childQuote;
        
        Test.startTest();
            try { 
                SWAN_Constants.QuoteTriggerExecuted = false;
                delete childQuote;
            } catch(Exception ex){}
        Test.stopTest();
    }
    
  @isTest
  public static void ChildSPQuoteDeleteTest()
    { 
        Id recId = Schema.SObjectType.Quote.getRecordTypeInfosByName().get(label.QuoteServicePointRecordType).getRecordTypeId();  
        createStaticDataWithOfferPack();
        masterQuote1.status='Priced';
        update masterQuote1;
        
        Quote childQuote = new Quote();
        childQuote.recordTypeId=recId;
        childQuote.Name = 'Child Quote';
        childQuote.Status = 'Priced';
        childQuote.vlocity_cmt__ParentQuoteId__c = masterQuote1.Id;
        childQuote.OpportunityId = opp.id;
        insert childQuote;
        
        Test.startTest();
            try { 
                SWAN_Constants.QuoteTriggerExecuted = false;
                delete childQuote;
            } catch(Exception ex){}
        Test.stopTest();
    }
    
    @isTest
  public static void restrictContentDocdeletionForSiteAdditionQuotes()
    { 
        Id recId = Schema.SObjectType.Quote.getRecordTypeInfosByName().get(label.QuoteSiteAdditionRecordType).getRecordTypeId();  
        createStaticData();
        Quote childQuote = new Quote();
        childQuote.recordTypeId=recId;
        childQuote.Name = 'Child Quote';
        childQuote.SWAN_Site_Addition_Parent__c = masterQuote.Id;
        childQuote.OpportunityId = opp.id;
        insert childQuote;
        
        ContentVersion contentVersion_1 = new ContentVersion(
        Title = 'Penguins',
        PathOnClient = 'Penguins.jpg',
        VersionData = Blob.valueOf('Test Content'),
        IsMajorVersion = true
        );
        insert contentVersion_1;
        
        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        System.debug('documents'+documents);
        System.debug('contentVersion_2'+contentVersion_2);
        
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=childQuote.id; 
        contentlink.ShareType= 'I';              
        contentlink.ContentDocumentId=documents[0].Id;
        contentlink.Visibility = 'AllUsers';
        insert contentlink;
        System.debug('contentlink'+contentlink);
        
        Test.startTest();
        try{
        delete documents[0];
        } catch(Exception ex){}
        Test.stopTest();
    }
    
    @isTest
  public static void restrictAttachmentdeletionForSiteAdditionQuotes()
    { 
        Id recId = Schema.SObjectType.Quote.getRecordTypeInfosByName().get(label.QuoteSiteAdditionRecordType).getRecordTypeId();  
        createStaticData();
        Quote childQuote = new Quote();
        childQuote.recordTypeId=recId;
        childQuote.Name = 'Child Quote';
        childQuote.SWAN_Site_Addition_Parent__c = masterQuote.Id;
        childQuote.OpportunityId = opp.id;
        insert childQuote;
        
        childQuote.Status = 'Accepted';
        update childQuote;
        
        Attachment att = [Select id from Attachment where Parentid = :childQuote.Id Limit 1];
        System.debug('attachment'+att);
        
        Test.startTest();
        try{
        delete att;
        } catch(Exception ex){}
        Test.stopTest();
    }
    
    @isTest
  public static void BCRFileForSiteAdditionQuotes()
    {
        createStaticData(); 
        Id recId = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('Site Addition Quote').getRecordTypeId();
        Id recId1 = Schema.SObjectType.Quote.getRecordTypeInfosByName().get(label.QuoteSiteAdditionRecordType).getRecordTypeId();  
          
        Quote childQuote = new Quote();
        childQuote.recordTypeId=recId;
        childQuote.Name = 'Site Addition Quote';
        //childQuote.SWAN_Site_Addition_Parent__c = masterQuote.Id;
        childQuote.OpportunityId = opp.id;
        childQuote.status='Draft';
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
        SWAN_Constants.QuoteTriggerExecuted = false;
        childQuote.Status = 'Accepted';
        update childQuote;
        } catch(Exception ex){}
        Test.stopTest();
    }

    @isTest
  public static void quoteCarbonCopyTest()
    {
        
        createStaticDataWithOfferPack();
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
        
        Quote childQuote1 = new Quote();
        childQuote1.Name = 'Child Quote';
        childQuote1.vlocity_cmt__DefaultServicePointId__c = servicePoint.id;
        childQuote1.vlocity_cmt__ParentQuoteId__c = masterQuote1.Id;
        childQuote1.OpportunityId = opp.id;
        childQuote1.pricebook2Id = pb.Id;
        insert childQuote1;
        QuoteLineItem qli = new QuoteLineItem();
        qli.Product2Id = prod_FixedPriceGas.Id;
        qli.QuoteId = childQuote1.Id;
        qli.UnitPrice = 0;
        qli.Quantity = 1;
        qli.PricebookEntryId = pbe.Id;
        insert qli;
        QuoteLineItem qliStd = new QuoteLineItem();
        qliStd.Product2Id = prod_StandingCharge.Id;
        qliStd.QuoteId = childQuote1.Id;
        qliStd.UnitPrice = 0;
        qliStd.Quantity = 1;
        qliStd.vlocity_cmt__recurringcharge__c = 77.7;
        qliStd.PricebookEntryId = pbeStd.Id;
        insert qliStd;
        
        QuoteLineItem qliUR = new QuoteLineItem();
        qliUR.Product2Id = prod_UnitRate.Id;
        qliUR.QuoteId = childQuote1.Id;
        qliUR.UnitPrice = 0;
        qliUR.Quantity = 1;
        qliUR.SWAN_UnitRate__c = 88.8;
        qliUR.PricebookEntryId = pbeUR.Id;
        insert qliUR;
        
        system.debug('$$$'+masterQuote1.Id);
        masterQuote.OpportunityId = opp.Id;
        masterQuote.Name = 'Master Quote';
        masterQuote.SWAN_Number_of_Service_Points__c=0;
        masterQuote.Swan_Original_Quote__c = masterQuote1.Id;
        masterQuote.SWAN_Total_Service_Points__c=1;
        insert masterQuote;
        system.debug('$$$'+masterQuote.Id);
        Quote childQuote = new Quote();
        childQuote.Name = 'Child Quote';
        childQuote.vlocity_cmt__DefaultServicePointId__c = servicePoint.id;
        childQuote.vlocity_cmt__ParentQuoteId__c = masterQuote.Id;
        childQuote.OpportunityId = opp.id;
        childQuote.pricebook2Id = pb.Id;
        insert childQuote;
        QuoteLineItem qli_1 = new QuoteLineItem();
        qli_1.Product2Id = prod_FixedPriceGas.Id;
        qli_1.QuoteId = childQuote.Id;
        qli_1.UnitPrice = 0;
        qli_1.Quantity = 1;
        qli_1.PricebookEntryId = pbe.Id;
        insert qli_1;
        
        QuoteLineItem qliStd_1 = new QuoteLineItem();
        qliStd_1.Product2Id = prod_StandingCharge.Id;
        qliStd_1.QuoteId = childQuote.Id;
        qliStd_1.UnitPrice = 0;
        qliStd_1.Quantity = 1;
        qliStd_1.vlocity_cmt__recurringcharge__c = 77.7;
        qliStd_1.PricebookEntryId = pbeStd.Id;
        insert qliStd_1;
        
        QuoteLineItem qliUR_1 = new QuoteLineItem();
        qliUR_1.Product2Id = prod_UnitRate.Id;
        qliUR_1.QuoteId = childQuote.Id;
        qliUR_1.UnitPrice = 0;
        qliUR_1.Quantity = 1;
        qliUR_1.SWAN_UnitRate__c = 88.8;
        qliUR_1.PricebookEntryId = pbeUR.Id;
        insert qliUR_1;

        
        Test.startTest();
        masterQuote.SWAN_Number_of_Service_Points__c=1;  
        masterQuote.SWAN_Total_Service_Points__c=1;  
        masterQuote.Swan_Original_Quote__c = masterQuote1.Id;    
        update masterQuote;
        Test.stopTest();
    }

    @isTest
    public static void deleteQuoteWithOfferPackTest()
    {
        createStaticDataWithOfferPack();
        test.startTest();
        try {
            delete masterQuote1;
        }catch(Exception ex) {
        }
        test.stopTest();
    }
}