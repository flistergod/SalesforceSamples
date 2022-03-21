@isTest
public class SWAN_CustomFunctionImplementation_Test{
    // Inputs required to test the methods being invoked
    public static Map<string, object> input = new Map<string, object>();
    public static Map<string, object> output = new Map<string, object>();
    public static Map<string, object> options = new Map<string, object>();

    @TestSetup
    static void makeData(){
        TestDataFactory.createMasterQuoteWithQLI();
    }

    @isTest
    public static void testFormatNumber(){
        List<Integer> integerList = new List<Integer>();
        integerList.add(10000);
        input.put('arguments', integerList); // Set a test input for the formatNumber method
        SWAN_CustomFunctionImplementation customFunctionImpl = new SWAN_CustomFunctionImplementation(); // Instantiate an instance of the class
        customFunctionImpl.invokeMethod('formatNumber',input,output,options); // Invoke the method being tested
    }

    @isTest
    public static void testGetCostBreakdown(){
         Test.startTest();
        (new SWAN_CustomFunctionImplementation()).invokeMethod('getCostBreakdown', input,output,options);
        Test.stopTest();
    }

    @isTest
    public static void testGetQLIData(){
        Quote masterQuote = [Select Id from Quote where Name like 'Master Quote%' limit 1];
        List<Object> lstArguments = new List<Object>();
        lstArguments.add(masterQuote.Id);
        input.put('arguments',lstArguments);
        Test.startTest();
        SWAN_CustomFunctionImplementation customFunctionImpl = new SWAN_CustomFunctionImplementation(); // Instantiate an instance of the class
        customFunctionImpl.invokeMethod('getQLIData',input,output,options); // Invoke the method being tested
        Test.stopTest();
    }
}