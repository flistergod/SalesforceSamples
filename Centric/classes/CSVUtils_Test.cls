@isTest
public class CSVUtils_Test {
    
    /*
     * This method is use to parse csv with data having base64 & data 
     * start & end with "
     * */
    static testMethod void invokeMethodTest1()
    {
        Map<String , String> csvFileMap = new Map<String,String>();
        Map<String,Object> optionsMap = new Map<String,object>();
        Map<String,Object> inputMap = new Map<String,object>();
        Map<String,Object> outputMap = new Map<String,object>();
        csvFileMap.put('data','data:text/csv;base64,QmlsbGluZ0FjY291bnQsTmFtZSxTZXJpYWx');
        csvFileMap.put('data1','data:text/csv;,\"tests');
        csvFileMap.put('data1','data:text/csv;,tests \n testsss \n');
        csvFileMap.put('data2','data:text/csv;,\"tests\" \n');
        csvFileMap.put('data3','data:text/csv;,tests\"');
        csvFileMap.put('Corrector','data:text/csv;,tests\"');
        
        Object obj = (object) csvFileMap;
        optionsMap.put('vlcFilesMap',obj);
        
        
        
        test.startTest();
        CSVUtils cs = new CSVUtils();
        cs.invokeMethod('load', inputMap, outputMap, optionsMap);
        
        optionsMap.put('EnergyType','GAS');
        cs.invokeMethod('loadv2', inputMap, outputMap, optionsMap);
        system.assert(CSVUtils.isDecimal('1.11'));
        
        test.stopTest();   
        system.assert(!outputMap.isEmpty());
        
    }
    
  /*
     * This method is use to parse csv with data having base64 & data 
     * having the document id.
     * */    
    @isTest
    static void invokeMethodTest2()
    {
       // createData();
        Map<String , String> csvFileMap = new Map<String,String>();
        Map<String,Object> optionsMap = new Map<String,object>();
        Map<String,Object> inputMap = new Map<String,object>();
        Map<String,Object> outputMap = new Map<String,object>();
        
        //Document doc = [Select id from Document where developerName = 'my_document' limit 1];
        csvFileMap.put('data','rwvs456677');
        Object obj = (object) csvFileMap;
        optionsMap.put('vlcFilesMap',obj);
        
        
        
        test.startTest();
        CSVUtils cs = new CSVUtils();
        
        try{  
            cs.invokeMethod('load', inputMap, outputMap, optionsMap);
            cs.invokeMethod('loadv2', inputMap, outputMap, optionsMap);
            
        }
        catch(Exception e)
        {}
        test.stopTest();   
        system.assert(outputMap.isEmpty());
        
        system.assert(outputMap.isEmpty());
        
    }
    
    /*
     * This method is use to cover the exception class.
     * */ 
    static testMethod void test3(){
        CSVUtils cs = new CSVUtils();
        Map<String , String> csvFileMap = new Map<String,String>();
        Map<String,Object> optionsMap = new Map<String,object>();
        Map<String,Object> inputMap = new Map<String,object>();
        Map<String,Object> outputMap = new Map<String,object>();
        
        cs.invokeMethod('load1', inputMap, outputMap, optionsMap);
        try{
            CSVUtils.ParsingException pr = new CSVUtils.ParsingException();
            pr.getStackTraceString();
        }
        catch(Exception ex)
        {
            
        }
        system.assert(outputMap.isEmpty());
    }
    
    static void createData()
    {
        Document documet = new document();
        documet = new Document();
        documet.Body = Blob.valueOf('Some Text');
        documet.ContentType = 'text/csv';
        documet.DeveloperName = 'my_document';
        documet.IsPublic = true;
        documet.Name = 'My Document';
        documet.FolderId = [select id from folder where name='Sales Tools'].Id;
        insert documet;
        
        ContentVersion conV = new ContentVersion();
        //conv.ContentDocument = documet.Id;
        conv.Title = 'test';
        conv.PathOnClient = 'test';
        conv.VersionData = EncodingUtil.base64Decode('Some Text');
        
        insert conv;
        
        system.debug('saasas'+conv.ContentDocumentId);
    }

}