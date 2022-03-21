@isTest
public class SWAN_GetDataForQuoteNegotiationTest {

    @TestSetup
    static void makeData(){
        TestDataFactory.createMasterQuoteWithQLI();
    }

    @isTest
    static void testGetData(){

        Map<String, Object> input = new Map<String, Object>();
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();

        Quote masterQuote = [Select Id from Quote where RecordType.DeveloperName = 'MasterQuote' limit 1];
        input.put('ContextId', masterQuote.Id);

        Test.startTest();
            SWAN_GetDataForQuoteNegotiation getDataForNegotiation = new SWAN_GetDataForQuoteNegotiation();
            getDataForNegotiation.invokeMethod('GetData', input, output, options);
        Test.stopTest();
    }
}