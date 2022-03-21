@isTest
public class SWAN_ElecContractDocumentTokenTest {
    
   
    @isTest(SeeAllData=true)
    static void testMethod1(){
        
        Map<String, Object> input = new Map<String, Object>();
        Map<String, Object> output = new Map<String, Object>(); 
        Map<String, Object> options = new Map<String, Object>();
        
        /**
         * Moved over code from test factory to the class so we could play with the location of test.starttest
         */
        //TestDataFactory.createAllDataUntilContractCounterSigned();
       
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
        
        Test.startTest();
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
        

        /*Contract contractId = [Select Id from Contract limit 1];
        input.put('contextId',contractId.Id);*/

        SWAN_ElecContractDocumentTokenExtract  swanECDTE = new SWAN_ElecContractDocumentTokenExtract();
        swanECDTE.invokeMethod('getTokenData', input ,output , options );

        Test.stopTest();
    }
    
}