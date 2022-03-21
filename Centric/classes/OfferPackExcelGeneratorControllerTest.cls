@isTest
public class OfferPackExcelGeneratorControllerTest {

    @TestSetup
    static void makeData(){
        TestDataFactory.createMasterQuoteWithQLI();
    }

    @isTest
    static void testClass(){

        Quote masterQuote = [Select Id,SWAN_Quote_Type__c from Quote where recordType.DeveloperName = 'MasterQuote' limit 1];
        masterQuote.SWAN_Quote_Type__c = 'Fixed';
        update masterQuote;
        PageReference pageRef = Page.Excel_Image;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('mquoteid', masterQuote.Id);

        Test.startTest();
        OfferPackExcelGeneratorController controller = new OfferPackExcelGeneratorController();
        Test.stopTest();
    }
}
