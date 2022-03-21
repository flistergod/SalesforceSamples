@isTest
public class callValidateGroupIntegrationProcTest {

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

    }
    
    @isTest
    static void testMethod1(){
        Test.startTest();
        Quote masterQuote = [select id, name from quote where recordtypeid=:Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('MasterQuote').getRecordTypeId() limit 1];
        callValidateGroupIntegrationProcedure.IntegrationProcedureInput objIPInput = new callValidateGroupIntegrationProcedure.IntegrationProcedureInput();
        objIPInput.ContextId = masterQuote.Id;
        
        List < callValidateGroupIntegrationProcedure.IntegrationProcedureInput > lstIntegrationProcedureInput = new List < callValidateGroupIntegrationProcedure.IntegrationProcedureInput >();
        lstIntegrationProcedureInput.add(objIPInput);
        
        callValidateGroupIntegrationProcedure.runIntegrationServiceInvocable(lstIntegrationProcedureInput);
                
        Test.stopTest();
    }
    
}