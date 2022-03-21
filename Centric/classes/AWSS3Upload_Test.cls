@isTest
public class AWSS3Upload_Test{
    
    public static Map<string, object> input = new Map<string, object>();
    public static Map<string, object> output = new Map<string, object>();
    public static Map<string, object> options = new Map<string, object>();
    
    public static void createTestData(){
        
        
        Test.setMock(HttpCalloutMock.class, new AWSS3UploadCalloutMockImpl());            
        
        Opportunity oTestOpty = new Opportunity();
        oTestOpty.Name = 'Opportunity AWSS3Upload_Test';
        oTestOpty.StageName = 'Prospecting';
        oTestOpty.CloseDate = Date.Today();
        insert oTestOpty;
        
        Quote oTestMasterQuote = new Quote();
        oTestMasterQuote.Name = 'Master Quote AWSS3Upload_Test';
        oTestMasterQuote.OpportunityId = oTestOpty.Id;
        oTestMasterQuote.SWAN_Service_Point_Start_Date__c = Date.today();
        insert oTestMasterQuote;
        
        
        vlocity_cmt__Premises__c oTestPremise = new vlocity_cmt__Premises__c();
        
        vlocity_cmt__ServicePoint__c oTestServicePoint = new vlocity_cmt__ServicePoint__c();
        oTestPremise.vlocity_cmt__PostalCode__c = 'OX4 2LL';
        insert oTestPremise;
        
        oTestServicePoint.vlocity_cmt__ServicePointNumber__c = '99999';
        oTestServicePoint.SWAN_Measurement_Class__c = 'A';
        oTestServicePoint.SWAN_Standard_Settlement_Configuration__c = 'test';
        oTestServicePoint.SWAN_Line_Loss_Factor_Class__c = 'test';
        oTestServicePoint.SWAN_Grid_Supply_Point__c = 'test';
        //oTestServicePoint.SWAN_Distributor_Id__c = 1;
        oTestServicePoint.SWAN_Meter_Time_switch_Class_Ovrd__c = 't';
        oTestServicePoint.SWAN_Exit_Zone__c = 'EA1';
        oTestServicePoint.SWAN_Local_Distribution_Zone__c = 'EA';
        oTestServicePoint.SWAN_Product_Class__c = '4';
        oTestServicePoint.SWAN_Supply_Offtake_Quantity__c = 619.0;
        oTestServicePoint.SWAN_Formula_Year_Offtake_Quantity__c = 601.0;
        oTestServicePoint.SWAN_Formula_Year_Annual_Quantity__c = 69364.0;
        oTestServicePoint.Annual_Quantity__c = 71445.0;
        oTestServicePoint.SWAN_Transporter__c = 'National Grid Gas Distribution';
        oTestServicePoint.SWAN_AMR_Indicator__c = false;
        oTestServicePoint.SWAN_AMR_Service_Provider__c = 'EAI';
        //oTestServicePoint.SWAN_Data_Logger__c = false;
        oTestServicePoint.SWAN_Corrector__c = false; 
        oTestServicePoint.SWAN_Meter_Asset_Manager__c = 'EAI'; 
        oTestServicePoint.SWAN_End_User_Category_Code__c = '13619'; 
        oTestServicePoint.SWAN_Perspective_FY_Effective_Date__c = system.today();
        oTestServicePoint.SWAN_Perspective_FY_Annual_Quantity__c = 1;
        oTestServicePoint.SWAN_Perspective_FY_Offtake_Qty__c = 1;
        oTestServicePoint.SWAN_CSEP_Development_SOQ__c = 10;
        oTestServicePoint.SWAN_DCC_Service_Flag__c = 'A';
        oTestServicePoint.SWAN_Imperial_Indicator__c = false;
        oTestServicePoint.SWAN_Meter_Type__c = 'D';
        oTestServicePoint.SWAN_Meter_Serial_Number__c = '4A234D3433S';
        oTestServicePoint.SWAN_Meter_Capacity__c = 100;
        oTestServicePoint.SWAN_CSEP_Id__c = 'text';
        oTestServicePoint.SWAN_SMSO_ID__c = 'text';
        oTestServicePoint.SWAN_Interruption_Contract_Exists__c = false;
        oTestServicePoint.SWAN_Twin_Stream_indicator__c = false;
        oTestServicePoint.SWAN_IGT_Transportation_Rate__c = 10;
        oTestServicePoint.SWAN_IGT_Transporter_Rate_Type__c = '';
        oTestServicePoint.vlocity_cmt__PremisesId__c = oTestPremise.Id;
        
        insert oTestServicePoint;
        
        Quote oTestChildQuote = new Quote();
        oTestChildQuote.vlocity_cmt__ParentQuoteId__c = oTestMasterQuote.Id;
        oTestChildQuote.vlocity_cmt__DefaultServicePointId__c = oTestServicePoint.Id;
        oTestChildQuote.Name = 'Child Quote AWSS3Upload_Test';
        oTestChildQuote.OpportunityId = oTestOpty.Id;
        insert oTestChildQuote;
        
        input.put('strUploadedCSVURL','https://gorilla-integration-british-gas-data.s3.amazonaws.com/');
        input.put('QuoteId',oTestMasterQuote.Id);
        input.put('strUploadFileType','MeterListFile');
        input.put('strQuoteId',oTestMasterQuote.Id);
        input.put('strCalculationId','TestCalculationId');
        Map<String,Object> oMap = new Map<String,Object>();
        Map<String,Object> oMap1 = new Map<String,Object>();
        oMap.put('ServicePointId',oTestServicePoint.Id);
        oMap.put('SOQ','');
        oMap.put('CustomerAQ','');
        oMap.put('EUC','');
        oMap.put('ETD','');
        oMap.put('EFD','');
        input.put('JsonNewOLI',oMap);
        
    }
    
    @isTest
    public static void testMeterListUpload(){
        Test.startTest();
        createTestData();
        AWSS3Upload oAWSUpload = new AWSS3Upload();
        oAWSUpload.invokeMethod('uploadCSVFileToS3',input,output,options);
        //Boolean ret = oAWSUpload.uploadCSVFileToS3(input,output,options);
        Test.stopTest();
    }
    
    @isTest
    public static void testMeterListUpload1(){
        Test.startTest();
        createTestData();
        AWSS3Upload oAWSUpload = new AWSS3Upload();
        vlocity_cmt__ServicePoint__c spId = [Select id from vlocity_cmt__ServicePoint__c limit 1];
        Map<String,Object> oMap = new Map<String,Object>();
        oMap.put('ServicePointId',spId.Id);
        oMap.put('SWAN_ATT_CUST_SOQ','12');
        oMap.put('SWAN_ATT_CUST_AQ','2122');
        oMap.put('SWAN_ATT_CUST_EUC','test');
        oMap.put('SWAN_ATT_CUST_EFF_TO','2020-02-03T00:00:00.000Z');
        oMap.put('SWAN_ATT_CUST_EFF_FROM','2020-02-03T00:00:00.000Z');
        Map<String,Object> oMap1 = new Map<String,Object>();
        oMap1.put(spId.Id,oMap);
        input.put('JsonNewOLI',oMap1);
        oAWSUpload.invokeMethod('uploadCSVFileToS3',input,output,options);
        //Boolean ret = oAWSUpload.uploadCSVFileToS3(input,output,options);
        Test.stopTest();
    }
    
    @isTest
    public static void testMeterListElecUpload(){
        Test.startTest();
        createTestData();
        AWSS3Upload oAWSUpload = new AWSS3Upload();
        vlocity_cmt__ServicePoint__c spId = [Select id from vlocity_cmt__ServicePoint__c limit 1];
        Map<String,Object> oMap = new Map<String,Object>();
        oMap.put('ServicePointId',spId.Id);
        oMap.put('SWAN_ATT_CUST_SOQ','12');
        oMap.put('SWAN_ATT_CUST_AQ','2122');
        oMap.put('SWAN_ATT_CUST_EUC','test');
        oMap.put('SWAN_ATT_HH_RATE_STRUCT','HH 2');
        oMap.put('SWAN_ATT_CUST_EAC',1.0);
        oMap.put('SWAN_ATT_CUST_EFF_TO','2020-02-03T00:00:00.000Z');
        oMap.put('SWAN_ATT_CUST_EFF_FROM','2020-02-03T00:00:00.000Z');
        Map<String,Object> oMap1 = new Map<String,Object>();
        oMap1.put(spId.Id,oMap);
        input.put('JsonNewOLI',oMap1);
        input.put('JsonRateStru',oMap1);
        input.put('JsonNewEAC',oMap1);
        input.put('strUploadFileType','MeterListFileElec');
        oAWSUpload.invokeMethod('uploadCSVFileToS3',input,output,options);
        //Boolean ret = oAWSUpload.uploadCSVFileToS3(input,output,options);
        Test.stopTest();
    }
    
    @isTest
    public static void testMeterListElecUpload1(){
        Test.startTest();
        createTestData();
        AWSS3Upload oAWSUpload = new AWSS3Upload();
        vlocity_cmt__ServicePoint__c spId = [Select id,SWAN_Measurement_Class_Ovrd__c from vlocity_cmt__ServicePoint__c limit 1];
        spId.SWAN_Measurement_Class_Ovrd__c = 'C';
        update spId;
        Map<String,Object> oMap = new Map<String,Object>();
        oMap.put('ServicePointId',spId.Id);
        oMap.put('SWAN_ATT_CUST_SOQ','12');
        oMap.put('SWAN_ATT_CUST_AQ','2122');
        oMap.put('SWAN_ATT_CUST_EUC','test');
        oMap.put('SWAN_ATT_HH_RATE_STRUCT','HH 2');
        oMap.put('SWAN_ATT_CUST_EAC',1.0);
        oMap.put('SWAN_ATT_CUST_EFF_TO','2020-02-03T00:00:00.000Z');
        oMap.put('SWAN_ATT_CUST_EFF_FROM','2020-02-03T00:00:00.000Z');
        Map<String,Object> oMap1 = new Map<String,Object>();
        oMap1.put(spId.Id,oMap);
        input.put('JsonNewOLI',oMap1);
        input.put('JsonRateStru',oMap1);
        input.put('JsonNewEAC',oMap1);
        input.put('strUploadFileType','MeterListFileElec');
        oAWSUpload.invokeMethod('uploadCSVFileToS3',input,output,options);
        //Boolean ret = oAWSUpload.uploadCSVFileToS3(input,output,options);
        Test.stopTest();
    }
    
    @isTest
    public static void testUpdateCalculationId(){
        Test.startTest();
        createTestData();
        AWSS3Upload oAWSUpload = new AWSS3Upload();
        oAWSUpload.invokeMethod('UpdateQuoteCalculationId',input,output,options);
        //Boolean ret = oAWSUpload.UpdateQuoteCalculationId(input,output,options);
        Test.stopTest();
    }
    
    @isTest
    public static void CreateMeterListFile_ElecTest(){
        Test.startTest();
        createTestData();
        vlocity_cmt__ServicePoint__c spId = [Select id from vlocity_cmt__ServicePoint__c limit 1];
        input.put('servicePointId',spId.Id);
        AWSS3Upload oAWSUpload = new AWSS3Upload();
        oAWSUpload.invokeMethod('CreateMeterListFile_Elec',input,output,options);
        //Boolean ret = oAWSUpload.UploadSleep(input,output,options);
        Test.stopTest();
    }
    
    @isTest
    public static void CreateMeterListFile_ElecTest1(){
        Test.startTest();
        createTestData();
        vlocity_cmt__ServicePoint__c spId = [Select id from vlocity_cmt__ServicePoint__c limit 1];
        List<Id> spList = new List<Id>();
        spList.add(spId.id);
        input.put('servicePointId','');
        input.put('servicePointList',spList);
        AWSS3Upload oAWSUpload = new AWSS3Upload();
        oAWSUpload.invokeMethod('CreateMeterListFile_Elec',input,output,options);
        //Boolean ret = oAWSUpload.UploadSleep(input,output,options);
        Test.stopTest();
    }
    
    @isTest
    public static void CallMDDVIP_Test(){
        Test.startTest();
        createTestData();
        vlocity_cmt__ServicePoint__c spId = [Select id from vlocity_cmt__ServicePoint__c limit 1];
        List<Id> spList = new List<Id>();
        spList.add(spId.id);
        String UserId = userinfo.getuserid();
        CallMDDVIP.CallIPService('BG-MDDValidation_CreateComponent',spList,spId.id,UserId);
        //Boolean ret = oAWSUpload.UploadSleep(input,output,options);
        Test.stopTest();
    }

    @isTest
    public static void apiBatchRequestElecTest(){
      Test.setMock(HttpCalloutMock.class, new AWSS3UploadCalloutMockImpl());

      Test.startTest();
      Map<String,Object> output = new Map<String,Object>();
      Map<String,Object> options = new Map<String,Object>{  'BrokerMarginPence' => '0.2',
                                                            'BrokerMarginPound' => '20',
                                                            'DataComponentId'   => 'e84934b0-1f6e-11eb-9c9c-0a54f1193edb',
                                                            'HostName'          => 'https://app-int.gorilla.co/api/v1/' 
                                                         };
      Map<String,Object> input = new Map<String,Object>{ 'AuthorizationToken' => 'Bearer eyJraWQiOiJSclVWdlZ2R0g5emJ6MXF1ZHJnTEtKSy',
                                                         'SetTransformCalculationDate' => ' "workflow_component_parameter": 15',
                                                         'SetTransformCalculationDateHTTPMethodPath' =>'PUT /api/v1/calculations/1a7a36cc-22b3-11eb-ba9d-022c32f9a207/parameters/1bd1825a-22b3-11eb-ba9d-022c32f9a207 HTTP/1.1',
                                                         'SetTransformSetBrokerMarginPound' => ' "workflow_component_parameter": 15',
                                                         'SetTransformSetBrokerMarginPoundHTTPMethodPath' =>'PUT /api/v1/calculations/1a7a36cc-22b3-11eb-ba9d-022c32f9a207/parameters/1bd1825a-22b3-11eb-ba9d-022c32f9a207 HTTP/1.1',
                                                         'SetTransformSetBrokerMarginPence' => ' "workflow_component_parameter": 15',
                                                         'SetTransformSetBrokerMarginPenceHTTPMethodPath' =>'PUT /api/v1/calculations/1a7a36cc-22b3-11eb-ba9d-022c32f9a207/parameters/1bd1825a-22b3-11eb-ba9d-022c32f9a207 HTTP/1.1'
      };                                                            
     
      AWSS3Upload  aws = new AWSS3Upload();
      aws.invokeMethod('apiBatchRequestElec', input, output, options);
      Test.stopTest();
      

    }
}