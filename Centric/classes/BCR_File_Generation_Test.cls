@isTest
public class BCR_File_Generation_Test {
    
    @TestSetup
    static void testSetupMethod(){
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
        system.debug('masterQuote ');
        system.debug(masterQuote.Id);
        system.debug(masterQuote.OpportunityId);
        system.debug(masterQuote.AccountId);
        
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
        ct.status = 'Awaiting Signature';
        update ct;
        ct.status = 'Contract Counter Signed';
        update ct;

        //add contract line items from site Addition
        TestDataFactory.addContractLineItems(lstSubQuotesSA,  lstproducts.get(0), ct, mapSubQuoteToQLI);
    }

    @isTest
    static void testgenerateFile() {

        Test.startTest();
        system.debug('========== testgenerateFile ==================');
        string quoteRecordTypeId=Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('MasterQuote').getRecordTypeId();
        system.debug(quoteRecordTypeId);
        List<Id> quoteIdList = new List<Id>(new Map<Id, Quote>([select id from quote where RecordTypeId =: quoteRecordTypeId and AccountId != null]).keySet());
        List<Id> accountIdList = new List<Id>(new Map<Id, Account>([select id from account]).keySet());
        if(quoteIdList.size() > 0 && accountIdList.size() > 0) {
            List<Contract> contractList = [select id,SWAN_Payment_Term__c from contract];
    
            List<String> paymentTermList = new List<String>();
            paymentTermList.add('14 Days');
            Map<Id, Id> ownerMap = new Map<Id, Id>();
            ownerMap.put(quoteIdList[0], Userinfo.getUserId());
            Map<Id, String> fileNameMap = new Map<Id, String>();
            fileNameMap.put(quoteIdList[0], 'Renewal'); 
            Map<Id, Id> QuoteContractMap = new Map<Id, Id>();
            QuoteContractMap.put(quoteIdList[0], contractList[0].Id);
            BCR_File_Generation.generateFile(quoteIdList, accountIdList, paymentTermList, ownerMap, fileNameMap, QuoteContractMap);
            

        }
        Test.stopTest();
    }

    @isTest
    static void testreturnFieldvalueGeneral() {
        Test.startTest();

        BCR_File_Generation.returnFieldvalueGeneral(null);
        BCR_File_Generation.returnFieldvalueGeneral('field');

        Test.stopTest();
    }

    @isTest
    static void testreturnFieldValueString() {
        Test.startTest();

        BCR_File_Generation.returnFieldValueString(null);
        BCR_File_Generation.returnFieldValueString('field');

        Test.stopTest();
    }

    @isTest
    static void testreturnFieldValueDate() {
        Test.startTest();

        BCR_File_Generation.returnFieldValueDate(null);
        BCR_File_Generation.returnFieldValueDate(system.today());

        Test.stopTest();
    }

    @isTest
    static void testreturnFieldvalueDecimal() {
        Test.startTest();

        BCR_File_Generation.returnFieldvalueDecimal(null);
        BCR_File_Generation.returnFieldvalueDecimal(12);

        Test.stopTest();
    }

    @isTest
    static void testreturnFieldvalueCharges() {
        Test.startTest();

        BCR_File_Generation.returnFieldvalueCharges(null);
        BCR_File_Generation.returnFieldvalueCharges(12);

        Test.stopTest();
    }

    @isTest
    static void testgetUnitRate() {
        Test.startTest();
        string quoteRecordTypeId=Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('MasterQuote').getRecordTypeId();
        system.debug(quoteRecordTypeId);
        List<Id> quoteIdList = new List<Id>(new Map<Id, Quote>([select id from quote where RecordTypeId =: quoteRecordTypeId]).keySet());

        BCR_File_Generation.getUnitRate('Electricity',quoteIdList[0],'Gas','FLEXIBLE');
        BCR_File_Generation.getUnitRate('Electricity',quoteIdList[0],'Gas','FIXED');
        BCR_File_Generation.getUnitRate('Gas',quoteIdList[0],'Gas','FIXED');
        BCR_File_Generation.getUnitRate('Gas',quoteIdList[0],'Gas','FLEXIBLE');

        Test.stopTest();
    }

    @isTest
    static void testgetItemPrices() {
        Test.startTest();
        string quoteRecordTypeId=Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('MasterQuote').getRecordTypeId();
        system.debug(quoteRecordTypeId);
        List<Id> quoteIdList = new List<Id>(new Map<Id, Quote>([select id from quote where RecordTypeId =: quoteRecordTypeId]).keySet());

        BCR_File_Generation.getItemPrices('Electricity',quoteIdList[0],'Gas','FLEXIBLE','StandingCharge','unitRate','availCharge','Acquisition');
        
        BCR_File_Generation.getItemPrices('Electricity',quoteIdList[0],'Gas','FIXED','StandingCharge','unitRate','availCharge','Acquisition');

        Test.stopTest();
    }
}