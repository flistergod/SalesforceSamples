@isTest
public class AWSS3csvFileReader_Test{

      public static Map<string, object> input = new Map<string, object>();
      public static Map<string, object> output = new Map<string, object>();
      public static Map<string, object> options = new Map<string, object>();
      
   public static void createTestData(){
   
      
      //Test.setMock(HttpCalloutMock.class, new AWSFileReaderCalloutMockImpl()); 
      
      
      Id standardPBId = Test.getStandardPricebookId() ;      
           
      Opportunity oTestOpty = new Opportunity();
      oTestOpty.Name = 'Opportunity AWSS3csvFileReader_Test'+ '_' + date.today();
      oTestOpty.StageName = 'Prospecting';
      oTestOpty.CloseDate = Date.Today();
      insert oTestOpty;
      
      Quote oTestMasterQuote = new Quote();
      oTestMasterQuote.Name = 'Master Quote AWSS3csvFileReader_Test' + '_' + date.today();
      oTestMasterQuote.OpportunityId = oTestOpty.Id;
      oTestMasterQuote.SWAN_Pricing_Calculation_Id__c = '999999';
      oTestMasterQuote.SWAN_Service_Point_Start_Date__c = Date.today();
      //oTestMasterQuote.vlocity_cmt__PriceListId__c = standardPBId;
      insert oTestMasterQuote;
      input.put('MasterQuoteId',oTestMasterQuote.id);   
      
      vlocity_cmt__Premises__c oTestPremise = new vlocity_cmt__Premises__c();
                      
      vlocity_cmt__ServicePoint__c oTestServicePoint = new vlocity_cmt__ServicePoint__c();
      oTestPremise.vlocity_cmt__PostalCode__c = 'OX4 2LL';
      insert oTestPremise;
      
      oTestServicePoint.vlocity_cmt__ServicePointNumber__c = '12345';
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
      oTestServicePoint.SWAN_Meter_Serial_Number__c = '4.824983943';
      oTestServicePoint.SWAN_Meter_Capacity__c = 100;
      oTestServicePoint.SWAN_CSEP_Id__c = 'text';
      oTestServicePoint.SWAN_SMSO_ID__c = 'text';
      oTestServicePoint.SWAN_Interruption_Contract_Exists__c = false;
      oTestServicePoint.SWAN_Twin_Stream_indicator__c = false;
      oTestServicePoint.SWAN_IGT_Transportation_Rate__c = 10;
      oTestServicePoint.SWAN_IGT_Transporter_Rate_Type__c = '';
      oTestServicePoint.vlocity_cmt__PremisesId__c = oTestPremise.Id;
       oTestServicePoint.SWAN_MDD_Combination_Supported__c = true;
      
      insert oTestServicePoint;
      
     
      Quote oTestChildQuote = new Quote();
      oTestChildQuote.vlocity_cmt__ParentQuoteId__c = oTestMasterQuote.Id;
      oTestChildQuote.vlocity_cmt__DefaultServicePointId__c= oTestServicePoint.Id;
      oTestChildQuote.Name = 'Child Quote AWSS3Upload_Test';
      oTestChildQuote.OpportunityId = oTestOpty.Id;  
      insert oTestChildQuote;
       
      SWAN_Status_Log__c st = new SWAN_Status_Log__c();
         st.swan_record_Id__c = oTestServicePoint.Id;
       st.OwnerId = Userinfo.getUserId();
       st.SWAN_WorkflowId__c ='999999';
       insert st;
                    
      /*Product2 oUnitCharge = new Product2();
      oUnitCharge.Name = 'Unit Rate';
      oUnitCharge.ProductCode = 'BG_UNITRATE'; 
      oUnitCharge.IsActive = true;
      insert oUnitCharge;

      
      PricebookEntry oPriceBookEntry = new PricebookEntry();
      oPriceBookEntry.Pricebook2Id = standardPBId;
      oPriceBookEntry.Product2Id = oUnitCharge.Id;
      oPriceBookEntry.UnitPrice = 10;
      oPriceBookEntry.UseStandardPrice = false;
      oPriceBookEntry.isActive = true;
      insert oPriceBookEntry;


      Product2 oStandingCharge = new Product2();
      oStandingCharge.Name = 'Standing Charge';
      oStandingCharge.ProductCode = 'BG_STD';
      insert oStandingCharge;

      PricebookEntry oPriceBookEntry2 = new PricebookEntry();
      oPriceBookEntry2.Pricebook2Id = standardPBId;
      oPriceBookEntry2.Product2Id = oStandingCharge.Id;
      oPriceBookEntry2.UnitPrice = 10;
      oPriceBookEntry2.isActive = true;
      insert oPriceBookEntry2;
      
      
      QuoteLineItem oQLIUnitCharge = new QuoteLineItem();
      oQLIUnitCharge.QuoteId = oTestChildQuote.Id;
      oQLIUnitCharge.Product2Id = oUnitCharge.Id;
      oQLIUnitCharge.PricebookEntryId = oPriceBookEntry.Id;
      oQLIUnitCharge.Quantity = 1;
      oQLIUnitCharge.UnitPrice = 10;
      insert oQLIUnitCharge;
      
      QuoteLineItem oQLIStandingCharge = new QuoteLineItem();
      oQLIStandingCharge.QuoteId = oTestChildQuote.Id;
      oQLIStandingCharge.Product2Id = oStandingCharge.Id;
      oQLIStandingCharge.PricebookEntryId = oPriceBookEntry2.Id;
      oQLIStandingCharge.Quantity = 1;
      oQLIStandingCharge.UnitPrice = 10;
      insert oQLIStandingCharge;*/
            
           
   }
   
   public static void createTestDataBulk(){
   
      Id standardPBId = Test.getStandardPricebookId() ; 
      Id recordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('SubQuote').getRecordTypeId();
       
      Product2 p = new Product2();
      p.name='Fixed Price Gas';
      p.productCode='BG_GAS';
      p.vlocity_cmt__IsOrderable__c=true;
      insert p;
    
      Id pricebookId = Test.getStandardPricebookId();
      PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = p.Id, UnitPrice = 10000, IsActive = true);
      insert standardPrice;
    
      Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
      insert customPB;
    
      PricebookEntry customPrice = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = p.Id, UnitPrice = 12000, IsActive = true);
      insert customPrice;    
           
      Opportunity oTestOpty = new Opportunity();
      oTestOpty.Name = 'Opportunity AWSS3csvFileReader_Test'+ '_' + date.today();
      oTestOpty.StageName = 'Prospecting';
      oTestOpty.CloseDate = Date.Today();
      insert oTestOpty;
      
      Quote oTestMasterQuote = new Quote();
      oTestMasterQuote.Name = 'Master Quote AWSS3csvFileReader_Test' + '_' + date.today();
      oTestMasterQuote.OpportunityId = oTestOpty.Id;
      oTestMasterQuote.SWAN_Pricing_Calculation_Id__c = '999999';
      oTestMasterQuote.SWAN_Service_Point_Start_Date__c = Date.today();
      oTestMasterQuote.pricebook2Id=customPB.id;
      oTestMasterQuote.SWAN_Pricing_User__c=userinfo.getuserid();
      insert oTestMasterQuote;
      input.put('MasterQuoteId',oTestMasterQuote.id);   
      
      QuoteLineItem qli_for_Master = new QuoteLineItem();
      qli_for_Master.QuoteId = oTestMasterQuote.id;
      qli_for_Master.PriceBookEntryId=customPrice.id;
      qli_for_Master.Product2Id = p.id;
      qli_for_Master.Quantity=1;
      qli_for_Master.UnitPrice=10;
      insert qli_for_Master;
      
      list<vlocity_cmt__Premises__c> oTestPremiseList= new list<vlocity_cmt__Premises__c>();
      for(integer i=10;i<=70;i++){
          oTestPremiseList.add(new vlocity_cmt__Premises__c(vlocity_cmt__PostalCode__c = 'X'+i+' 2LL'));
      }
      insert(oTestPremiseList);
      
      List<vlocity_cmt__ServicePoint__c>oTestServicePointlist= new List<vlocity_cmt__ServicePoint__c>();
      for(integer j=0;j<60;j++){
          vlocity_cmt__ServicePoint__c oTestServicePoint = new vlocity_cmt__ServicePoint__c();
          oTestServicePoint.vlocity_cmt__ServicePointNumber__c = '12345'+j;
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
          oTestServicePoint.SWAN_Meter_Serial_Number__c = '4.824983943';
          oTestServicePoint.SWAN_Meter_Capacity__c = 100;
          oTestServicePoint.SWAN_CSEP_Id__c = 'text';
          oTestServicePoint.SWAN_SMSO_ID__c = 'text';
          oTestServicePoint.SWAN_Interruption_Contract_Exists__c = false;
          oTestServicePoint.SWAN_Twin_Stream_indicator__c = false;
          oTestServicePoint.SWAN_IGT_Transportation_Rate__c = 10;
          oTestServicePoint.SWAN_IGT_Transporter_Rate_Type__c = '';
          oTestServicePoint.vlocity_cmt__PremisesId__c = oTestPremiseList[j].id;//oTestPremise.Id;
          oTestServicePoint.SWAN_MDD_Combination_Supported__c = true;
          oTestServicePointlist.add(oTestServicePoint);    
      }
      insert oTestServicePointlist;//oTestServicePoint;
     
     List<Quote>oTestChildQuotelist = new List<Quote>(); 
     for(integer k=0;k<60;k++){
          Quote oTestChildQuote = new Quote();
          oTestChildQuote.vlocity_cmt__ParentQuoteId__c = oTestMasterQuote.Id;
          oTestChildQuote.vlocity_cmt__DefaultServicePointId__c= oTestServicePointlist[k].id;//oTestServicePoint.Id;
          oTestChildQuote.Name = 'Child Quote AWSS3Upload_Test';
          oTestChildQuote.OpportunityId = oTestOpty.Id;  
          oTestChildQuote.pricebook2Id=customPB.id;
          oTestChildQuote.recordTypeId = recordTypeId;
          oTestChildQuotelist.add(oTestChildQuote);
      }
      insert oTestChildQuotelist;//oTestChildQuote;
          
   }
   
   /*@isTest
   public static void testGetCalculationParameter(){
      Test.startTest();
      createTestData();
      String strNotificationBody = '{\"outputs\": [{\"parameter_id\": \"972328b0-87ae-11e9-8dee-06c1cfef501c\", \"name\": \"ndm_forecast\", \"type\": \"bg_forecast_table\", \"value\": \"s3://gorilla-integration-british-gas-data/results/esult_take_consumption_forecast_product_classes_3_and_4_0.3.4_d012445834400811d168bec9314dffc5_ndm_forecast/user_view.csv\"}], \"metadata\": {}, \"correlation_id\": \"65dba472-3e9b-4ca3-8b5c-3ecbe4ded769\"}';      
      input.put('strNotificationMessage',strNotificationBody);
      AWSS3csvFileReader ocsvFileReader = new AWSS3csvFileReader();
      Boolean ret = ocsvFileReader.GetCalculationParameter(input,output,options);
      Test.stopTest();
   }*/

   @isTest
   public static void testAWSReadcsvFileContract(){
      createTestData();
      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new AWSFileReaderCalloutMockImpl()); 
      //createTestData();
      input.put('strUploadedCSVURL','https://www.sapo.com');
      input.put('strCalculationId','999999');
      input.put('strDataComponentName','Offer summary');
      AWSS3csvFileReader ocsvFileReader = new AWSS3csvFileReader();
      Boolean ret = ocsvFileReader.AWSReadcsvFile(input,output,options);
      Test.stopTest();
   }

   @isTest
   public static void testAWSReadcsvFileMeter(){
      createTestData();
      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new AWSFileReaderMeterCalloutMockImpl()); 
      //createTestData();
      input.put('strUploadedCSVURL','https://www.sapo.com');
      input.put('strCalculationId','999999');
      input.put('strDataComponentName','Meter level results');
      AWSS3csvFileReader ocsvFileReader = new AWSS3csvFileReader();
      Boolean ret = ocsvFileReader.AWSReadcsvFile(input,output,options);
      Test.stopTest();
   }

  @isTest
  public static void testAWSReadcsvFileMeterTest()
  {
    createTestData();
      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new AWSFileReaderMeterCalloutMockImpl()); 
      //createTestData();
      input.put('strUploadedCSVURL','https://www.sapo.com');
      input.put('strCalculationId','999999');
      input.put('strDataComponentName','Meter level results');
      AWSS3csvFileReader ocsvFileReader = new AWSS3csvFileReader();
      ocsvFileReader.invokeMethod('AWSReadcsvFileMeterLevel',input,output,options);
      ocsvFileReader.invokeMethod('AWSReadcsvFileForContract',input,output,options);
    
      Boolean ret = ocsvFileReader.AWSReadcsvFile(input,output,options);
    try{
    ocsvFileReader.invokeMethod('GetDataComponentId',input,output,options);
    }
    catch(exception e)
    {}
      Test.stopTest();
  }
  
  @isTest
  public static void testAWSReadcsvFileMeterElecTest()
  {
    createTestData();
      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new AWSFileReaderMeterCalloutMockImpl()); 
      //createTestData();
      input.put('strUploadedCSVURL','https://www.sapo.com');
      input.put('strCalculationId','999999');
      input.put('strDataComponentName','Elec Meter level results');
      AWSS3csvFileReader ocsvFileReader = new AWSS3csvFileReader();
      ocsvFileReader.invokeMethod('AWSReadcsvFileMeterLevelElec',input,output,options);
      
      Boolean ret = ocsvFileReader.AWSReadcsvFile(input,output,options);
    try{
    ocsvFileReader.invokeMethod('GetDataComponentId',input,output,options);
    }
    catch(exception e)
    {}
      Test.stopTest();
  }
   
  @isTest
  public static void calculateOfferSummaryTest()
  {
      createTestData();
      Test.startTest();
      string offerlevel =   'cost_component,kwh,percentage_of_spend,pounds\n'+
                            'Contribution Margin,,0.82,125900\n'+
                            'Commodity,,41.99,6414671\n'+
                            'Cost to Serve,,4.75,724857\n'+
                            'Metering,,29.31,4477321\n'+
                            'Other External,,0.12,18416\n'+
                            'Other Internal,,1.64,251091\n'+
                            'Transportation,,20.12,3074057\n'+
                            'Unidentified Gas Cost,,2.06,314728\n'+
                            'Standing Charge,,51.99,7941630\n'+
                            'Unit Rate,629501605,48.01,7333513\n'+
                            'Annual Spend,,,15275142\n'+
                            'Contract Spend,,,15275142';
                            
      Map<string,object> temp = new Map<string,object>{'strUploadedCSVContract'=>offerlevel};                      
      input.put('UploadData',temp);
      //input.get('MasterQuoteId',oTestMasterQuote.id);   
      AWSS3csvFileReader1.calculateOfferSummary(input,output,options);
      
      string MeterLevel =   'cost_component,mprn,contract_spend,errors,kwh,pence_per_day,pence_per_kwh,annual_spend\n'+
                            'Standing Charge,12345,0,,0,932.786,,0\n'+
                            'Total Revenue,12345,4137,,0,,,4137\n'+
                            'Unit Rate,12345,0,,62950,,1.164,0\n';
      
      input.put('strUploadedCSV',MeterLevel);                        
      AWSS3csvFileReader1.calculateMeterLevelSummary(input,output,options);
      Test.stopTest(); 
  }  
  
  @isTest
  public static void calculateOfferSummaryTestBulk()
  {
      createTestDatabulk();
      Test.startTest();
      string offerlevel =   'cost_component,kwh,percentage_of_spend,pounds\n'+
                            'Contribution Margin,,0.82,125900\n'+
                            'Commodity,,41.99,6414671\n'+
                            'Cost to Serve,,4.75,724857\n'+
                            'Metering,,29.31,4477321\n'+
                            'Other External,,0.12,18416\n'+
                            'Other Internal,,1.64,251091\n'+
                            'Transportation,,20.12,3074057\n'+
                            'Unidentified Gas Cost,,2.06,314728\n'+
                            'Standing Charge,,51.99,7941630\n'+
                            'Unit Rate,629501605,48.01,7333513\n'+
                            'Annual Spend,,,15275142\n'+
                            'Contract Spend,,,15275142';
                            
      Map<string,object> temp = new Map<string,object>{'strUploadedCSVContract'=>offerlevel};                      
      input.put('UploadData',temp);
      //input.get('MasterQuoteId',oTestMasterQuote.id);   
      AWSS3csvFileReader1.calculateOfferSummary(input,output,options);
      
      string MeterLevel =   'cost_component,mprn,contract_spend,errors,kwh,pence_per_day,pence_per_kwh,annual_spend\n'+
                            'Standing Charge,12345,0,,0,932.786,,0\n'+
                            'Total Revenue,12345,4137,,0,,,4137\n'+
                            'Unit Rate,12345,0,,62950,,1.164,0\n';
      
      input.put('strUploadedCSV',MeterLevel);                        
      AWSS3csvFileReader1.calculateMeterLevelSummary(input,output,options);
      Test.stopTest(); 
  }
  
  @isTest
  public static void calculateOfferSummaryElecTest()
  {
      createTestData();
      Test.startTest();
      string offerlevel =   'cost_component,pounds,percentage_of_spend,kwh\n' + 
      'AAHEDC,189.26,0.26,,\n' + 
      'BSUoS,1910.0,2.6,,\n' + 
      'Broker Commission,655.83,0.89,,\n' + 
      'Capacity Market,2862.02,3.89,,\n' + 
      'Commodity,26765.29,36.39,,\n' + 
      'Contracts for Difference,140.08,0.19,,\n' + 
      'Cost to Serve,1535.41,2.09,,\n' + 
      'DUoS,16349.4,22.23,,\n' + 
      'Feed-in Tariffs,3624.49,4.93,,\n' + 
      'Other,114.1,0.16,,\n'+ 
      'Renewable Option,166.22,0.23,,\n'+ 
      'Renewables Obligation,13224.14,17.98,,\n' + 
      'TNUoS,6017.59,8.18,,\n' + 
      'Contribution Margin,1111.66,1.51,,\n' + 
      'Contract Spend,73553.81,,,\n'+ 
      'Annual Spend,73553.81,,,\n'+ 
      'Contract Volume,,,12784103.8\n'+ 
      'Annual Volume,,,12784103.8\n';
                            
      Map<string,object> temp = new Map<string,object>{'strUploadedCSVContract'=>offerlevel};                      
      input.put('UploadData',temp);
      //input.get('MasterQuoteId',oTestMasterQuote.id);   
      AWSS3csvFileReader1.calculateOfferSummaryElec(input,output,options);
      
      string MeterLevel =   'mpan,output,price_type,price,pounds,usage,errors' + '\n' + '12345,Day Unit Charge,Unit Charge,12.787,51951.75,406315,,' + '\n' + '12345,Night Unit Charge,Unit Charge,7.626,11401.82,149516,,' + '\n' + '12345,Standing Charge,Standing Charge,59.542,217.33,365,,' + '\n' + '12345,Contract Spend,,,72897.99,,,' + '\n' + '12345,Annual Spend,,,72897.99,,,' + '\n' + '12345,Contract kWh,,,,555831,,' + '\n' + '12345,Annual kWh,,,,555831,,' +'\n' + '12345,Broker Commission,,,655.84,,\n';
      
      input.put('strUploadedCSV',MeterLevel);                        
      AWSS3csvFileReader1.calculateElecMeterLevelSummary(input,output,options);
      Test.stopTest(); 
  }   
  
  @isTest
  public static void calculateOfferSummaryElecTestBulk()
  {
      createTestDatabulk();
      Test.startTest();
      string offerlevel =   'cost_component,pounds,percentage_of_spend,kwh\n' + 
      'AAHEDC,189.26,0.26,,\n' + 
      'BSUoS,1910.0,2.6,,\n' + 
      'Broker Commission,655.83,0.89,,\n' + 
      'Capacity Market,2862.02,3.89,,\n' + 
      'Commodity,26765.29,36.39,,\n' + 
      'Contracts for Difference,140.08,0.19,,\n' + 
      'Cost to Serve,1535.41,2.09,,\n' + 
      'DUoS,16349.4,22.23,,\n' + 
      'Feed-in Tariffs,3624.49,4.93,,\n' + 
      'Other,114.1,0.16,,\n'+ 
      'Renewable Option,166.22,0.23,,\n'+ 
      'Renewables Obligation,13224.14,17.98,,\n' + 
      'TNUoS,6017.59,8.18,,\n' + 
      'Contribution Margin,1111.66,1.51,,\n' + 
      'Contract Spend,73553.81,,,\n'+ 
      'Annual Spend,73553.81,,,\n'+ 
      'Contract Volume,,,12784103.8\n'+ 
      'Annual Volume,,,12784103.8\n';
                            
      Map<string,object> temp = new Map<string,object>{'strUploadedCSVContract'=>offerlevel};                      
      input.put('UploadData',temp);
      //input.get('MasterQuoteId',oTestMasterQuote.id);   
      AWSS3csvFileReader1.calculateOfferSummaryElec(input,output,options);
      
      string MeterLevel =   'mpan,output,price_type,price,pounds,usage,errors' + '\n' + '12345,Day Unit Charge,Unit Charge,12.787,51951.75,406315,,' + '\n' + '12345,Night Unit Charge,Unit Charge,7.626,11401.82,149516,,' + '\n' + '12345,Standing Charge,Standing Charge,59.542,217.33,365,,' + '\n' + '12345,Contract Spend,,,72897.99,,,' + '\n' + '12345,Annual Spend,,,72897.99,,,' + '\n' + '12345,Contract kWh,,,,555831,,' + '\n' + '12345,Annual kWh,,,,555831,,' +'\n' + '12345,Broker Commission,,,655.84,,\n';
      
      input.put('strUploadedCSV',MeterLevel);                        
      AWSS3csvFileReader1.calculateElecMeterLevelSummary(input,output,options);
      Test.stopTest(); 
  } 
  
  /*
  @isTest
  public static void strDataComponentNameTest()
  {
      createTestData();
      Test.startTest();
      string offerlevel =   'cost_component,kwh,percentage_of_spend,pounds\n'+
                            'Contribution Margin,,0.82,125900\n'+
                            'Commodity,,41.99,6414671\n'+
                            'Cost to Serve,,4.75,724857\n'+
                            'Metering,,29.31,4477321\n'+
                            'Other External,,0.12,18416\n'+
                            'Other Internal,,1.64,251091\n'+
                            'Transportation,,20.12,3074057\n'+
                            'Unidentified Gas Cost,,2.06,314728\n'+
                            'Standing Charge,,51.99,7941630\n'+
                            'Unit Rate,629501605,48.01,7333513\n'+
                            'Annual Spend,,,15275142\n'+
                            'Contract Spend,,,15275142';
                            
      Map<string,object> temp = new Map<string,object>{'strUploadedCSVContract'=>offerlevel};                      
      input.put('UploadData',temp);
      input.put('strDataComponentName','Offer summary');
      input.put('strDataComponentName','Offer summary');   
      input.put('strCalculationId','999999');   
      AWSS3csvFileReader obj = new AWSS3csvFileReader(); 
      obj.AWSParseFileClone(input,output,options);
      /*
      AWSS3csvFileReader1.calculateOfferSummary(input,output,options);
      
      string MeterLevel =   'cost_component,mprn,contract_spend,errors,kwh,pence_per_day,pence_per_kwh,annual_spend\n'+
                            'Standing Charge,12345,0,,0,932.786,,0\n'+
                            'Total Revenue,12345,4137,,0,,,4137\n'+
                            'Unit Rate,12345,0,,62950,,1.164,0\n';
      
      input.put('strUploadedCSV',MeterLevel);                        
      AWSS3csvFileReader1.calculateMeterLevelSummary(input,output,options);
      Test.stopTest(); 
  }*/

     @isTest
   public static void testAWSReadMDDResultFile(){
      createTestData();
       
       
      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new AWSFileReaderCalloutMDDMockImpl()); 
      //createTestData();
      input.put('strUploadedCSVURL','https://www.sapo.com');
      input.put('strCalculationId','999999');
      input.put('strDataComponentName','AWSReadMDDResultFile');
      AWSS3csvFileReader ocsvFileReader = new AWSS3csvFileReader();
      Boolean ret = ocsvFileReader.invokeMethod('AWSReadMDDResultFile',input,output,options);
      Test.stopTest();
   }
    
     @isTest
   public static void testAWSReadElectralinkResultFile(){
      createTestData();
       
       
      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new AWSFileReaderElectraMockImpl()); 
      //createTestData();
      input.put('strUploadedCSVURL','https://www.sapo.com');
      input.put('strCalculationId','999999');
      input.put('strDataComponentName','AWSReadElectralinkResultFile');
      AWSS3csvFileReader ocsvFileReader = new AWSS3csvFileReader();
      Boolean ret = ocsvFileReader.invokeMethod('AWSReadElectralinkResultFile',input,output,options);
      Test.stopTest();
   }
    
    @isTest
   public static void SWAN_CSVUpload_MDD_Test(){
      createTestData();
      vlocity_cmt__ServicePoint__c spId = [Select id from vlocity_cmt__ServicePoint__c limit 1];
      String UserId = userinfo.getuserid();
      Test.startTest(); 
          List<String> sCSVLines = new List<String>();
          sCSVLines.add('mpan,import_export,prepayment_indicator,voltage,site_specific,combination_valid,combination_supported,unsupported_reason,distributor_id,profile_class,meter_timeswitch_class,line_loss_factor_class,gsp_group_id,measurement_class,standard_settlement_configuration');
          sCSVLines.add('12345,import,false,LVN,false,true,false,1234,78,01,abc,abc,ac,A,abc');
           SWAN_CSVUpload_MDD batchMdd = new SWAN_CSVUpload_MDD(sCSVLines,spId.id,UserId);
           database.executeBatch(batchMdd,2000);
      Test.stopTest();
   }
    
    @isTest
   public static void testAWSReadPriceResultFile(){
      createTestData();
       
       
      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new AWSFileReaderCalloutMDDMockImpl()); 
      //createTestData();
      
       string MeterLevel =   'component,category\n'+
                            'Total,Management Fee\n';
      input.put('strUploadedCSVData',MeterLevel);
      input.put('strCalculationId','999999');
      //input.put('strDataComponentName','AWSReadMDDResultFile');
      AWSS3csvFileReader ocsvFileReader = new AWSS3csvFileReader();
      Boolean ret = ocsvFileReader.AWSReadQuotePriceSummaryFile(input,output,options);
      Test.stopTest();
   }
   
     @isTest
   public static void Utility_RowIterator_test(){
     
      Test.startTest(); 
       Utility_RowIterator ut = new Utility_RowIterator('Test Data');
       ut.Iterator();
      Test.stopTest();
   }
}