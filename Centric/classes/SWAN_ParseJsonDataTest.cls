@isTest
public class SWAN_ParseJsonDataTest {
  
  @isTest
  public static void parseJsonTest()
    {
        Map < String, Object > input = new Map < String, Object >();
        Map < String, Object > output = new Map < String, Object >();
        Map < String, Object > options = new Map < String, Object >();
        
        List<Map<String,Object>> dataMapLst = new List<Map<String,Object>>();
        Map<String,Object> dataMap = new Map<String,Object>();
        Map<String,Object> calParamMap = new Map<String,Object>();
        dataMap.put('validators','test');
        dataMap.put('id','99682068-7592-11e9-8201-0284f92601e2');
        dataMap.put('name','testName');
        
        Map<String,Object> dataMap1 = new Map<String,Object>();
        dataMap1.put('validators','test');
        dataMap1.put('id','99682068-7592-11e9-8201-0284f92601e2');
        dataMap1.put('name','testName');
        dataMapLst.add(dataMap);
        dataMapLst.add(dataMap1);
        
        calParamMap.put('data',dataMapLst);
        
        input.put('GetCalculationParameters',calParamMap);
        SWAN_ParseJsonData par = new SWAN_ParseJsonData();
        boolean testInvoke = par.invokeMethod('ParseJsonData',input,output,options);
        system.assert(testInvoke);
    }
    
    @isTest
  public static void parseJsonTest1()
    {
        Map < String, Object > input = new Map < String, Object >();
        Map < String, Object > output = new Map < String, Object >();
        Map < String, Object > options = new Map < String, Object >();
        
        List<Map<String,Object>> dataMapLst = new List<Map<String,Object>>();
        Map<String,Object> dataMap = new Map<String,Object>();
        Map<String,Object> calParamMap = new Map<String,Object>();
        dataMap.put('validators','test');
        dataMap.put('id','99682068-7592-11e9-8201-0284f92601e2');
        dataMap.put('name','testName');
        
        Map<String,Object> dataMap1 = new Map<String,Object>();
        dataMap1.put('validators','test');
        dataMap1.put('id','99682068-7592-11e9-8201-0284f92601e2');
        dataMap1.put('name','testName');
        dataMapLst.add(dataMap);
        dataMapLst.add(dataMap1);
        
        calParamMap.put('data',dataMapLst);
       
        input.put('GetCalculationParameters',calParamMap);
        SWAN_ParseJsonData par = new SWAN_ParseJsonData();
        boolean testInvoke = par.invokeMethod('ParseJsonData1',input,output,options);
        system.assert(!testInvoke);
    }

  }