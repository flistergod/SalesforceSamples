@isTest
public class SWAN_callFixFailedSubQuoteBatch_Test {
      public static Map<string, object> input = new Map<string, object>();
      public static Map<string, object> output = new Map<string, object>();
      public static Map<string, object> options = new Map<string, object>();
    
   public static void createTestData()
   {
      Id standardPBId = Test.getStandardPricebookId() ;      
           
      Opportunity oTestOpty = new Opportunity();
      oTestOpty.Name = 'Opportunity AWSS3csvFileReader_Test'+ '_' + date.today();
      oTestOpty.StageName = 'Prospecting';
      oTestOpty.CloseDate = Date.Today();
      insert oTestOpty;
      
      Quote oTestMasterQuote = new Quote();
      oTestMasterQuote.Name = 'Master Quote';
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
      
      insert oTestServicePoint;
       
      vlocity_cmt__ServicePoint__c oTestServicePoint1 = new vlocity_cmt__ServicePoint__c();
      oTestServicePoint1.vlocity_cmt__ServicePointNumber__c = '12346';
      oTestServicePoint1.SWAN_Exit_Zone__c = 'EA1';
      oTestServicePoint1.SWAN_Local_Distribution_Zone__c = 'EA';
      oTestServicePoint1.SWAN_Product_Class__c = '4';
      oTestServicePoint1.SWAN_Supply_Offtake_Quantity__c = 619.0;
      oTestServicePoint1.SWAN_Formula_Year_Offtake_Quantity__c = 601.0;
      oTestServicePoint1.SWAN_Formula_Year_Annual_Quantity__c = 69364.0;
      oTestServicePoint1.Annual_Quantity__c = 71445.0;
      oTestServicePoint1.SWAN_Transporter__c = 'National Grid Gas Distribution';
      oTestServicePoint1.SWAN_AMR_Indicator__c = false;
      oTestServicePoint1.SWAN_AMR_Service_Provider__c = 'EAI';
      //oTestServicePoint1.SWAN_Data_Logger__c = false;
      oTestServicePoint1.SWAN_Corrector__c = false; 
      oTestServicePoint1.SWAN_Meter_Asset_Manager__c = 'EAI'; 
      oTestServicePoint1.SWAN_End_User_Category_Code__c = '13619'; 
      oTestServicePoint1.SWAN_Perspective_FY_Effective_Date__c = system.today();
      oTestServicePoint1.SWAN_Perspective_FY_Annual_Quantity__c = 1;
      oTestServicePoint1.SWAN_Perspective_FY_Offtake_Qty__c = 1;
      oTestServicePoint1.SWAN_CSEP_Development_SOQ__c = 10;
      oTestServicePoint1.SWAN_DCC_Service_Flag__c = 'A';
      oTestServicePoint1.SWAN_Imperial_Indicator__c = false;
      oTestServicePoint1.SWAN_Meter_Type__c = 'D';
      oTestServicePoint1.SWAN_Meter_Serial_Number__c = '4.824983943';
      oTestServicePoint1.SWAN_Meter_Capacity__c = 100;
      oTestServicePoint1.SWAN_CSEP_Id__c = 'text';
      oTestServicePoint1.SWAN_SMSO_ID__c = 'text';
      oTestServicePoint1.SWAN_Interruption_Contract_Exists__c = false;
      oTestServicePoint1.SWAN_Twin_Stream_indicator__c = false;
      oTestServicePoint1.SWAN_IGT_Transportation_Rate__c = 10;
      oTestServicePoint1.SWAN_IGT_Transporter_Rate_Type__c = '';
      oTestServicePoint1.vlocity_cmt__PremisesId__c = oTestPremise.Id;
      
      insert oTestServicePoint1;
      
      Product2 oUnitCharge = new Product2();
      oUnitCharge.Name = 'Unit Rate';
      oUnitCharge.ProductCode = 'BG_UNITRATE'; 
      oUnitCharge.IsActive = true;
      insert oUnitCharge;
       
      Product2 oUnitCharge1 = new Product2();
      oUnitCharge1.Name = 'Standing Charge';
      oUnitCharge1.ProductCode = 'BG_STD'; 
      oUnitCharge1.IsActive = true;
      insert oUnitCharge1;
       
       Pricebook2 pb = new pricebook2();
        pb.Name = 'Standard Price Book 2009';
        pb.description = 'Price Book 2009 Products';
        pb.isActive = True;
        insert pb;
       
       Id pricebookId = Test.getStandardPricebookId();        

        PricebookEntry StandardPriceBookEntry = new PricebookEntry();
        StandardPriceBookEntry.Pricebook2Id = pricebookId;
        StandardPriceBookEntry.Product2Id = oUnitCharge.Id;
        StandardPriceBookEntry.UnitPrice = 10000;
        StandardPriceBookEntry.IsActive =True;        
        insert StandardPriceBookEntry;
       
       PricebookEntry pbe = new PricebookEntry(pricebook2id=pb.id, product2id=oUnitCharge.id, unitprice=10000, isActive = True);
       insert pbe;
       
       PricebookEntry StandardPriceBookEntry1 = new PricebookEntry();
        StandardPriceBookEntry1.Pricebook2Id = pricebookId;
        StandardPriceBookEntry1.Product2Id = oUnitCharge1.Id;
        StandardPriceBookEntry1.UnitPrice = 10000;
        StandardPriceBookEntry1.IsActive =True;        
        insert StandardPriceBookEntry1;
       
       PricebookEntry pbe1 = new PricebookEntry(pricebook2id=pb.id, product2id=oUnitCharge1.id, unitprice=10000, isActive = True);
       insert pbe1;
     
      Quote oTestChildQuote1 = new Quote();
      oTestChildQuote1.vlocity_cmt__ParentQuoteId__c = oTestMasterQuote.Id;
      oTestChildQuote1.Name = 'Group Quote';
      oTestChildQuote1.OpportunityId = oTestOpty.Id;
      insert oTestChildQuote1;
       
       vlocity_cmt__QuoteGroup__c qtGrp = new vlocity_cmt__QuoteGroup__c();
       qtGrp.vlocity_cmt__QuoteId__c = oTestChildQuote1.Id;
       qtGrp.Name = 'group1';
       insert qtGrp;
       Id devRecordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('Sub Quote').getRecordTypeId();
      Quote oTestChildQuote = new Quote();
      oTestChildQuote.vlocity_cmt__ParentQuoteId__c = oTestMasterQuote.Id;
      oTestChildQuote.vlocity_cmt__DefaultServicePointId__c= oTestServicePoint.Id;
      oTestChildQuote.Name = 'Child Quote AWSS3Upload_Test';
       oTestChildQuote.RecordTypeId = devRecordTypeId;
      oTestChildQuote.OpportunityId = oTestOpty.Id; 
      oTestChildQuote.Pricebook2Id = pb.Id;
       oTestChildQuote.vlocity_cmt__QuoteGroupId__c = qtGrp.Id;
      insert oTestChildQuote;
       
      QuoteLineItem QLI  = new QuoteLineItem();
        QLI.Product2Id = oUnitCharge.Id;
        QLI.QuoteId = oTestChildQuote.Id;
        QLI.PricebookEntryId = Pbe.Id;
        QLI.Quantity = 2;
        QLI.UnitPrice = 150000.0; 
        insert QLI;
       
       QuoteLineItem QLI1  = new QuoteLineItem();
        QLI1.Product2Id = oUnitCharge1.Id;
        QLI1.QuoteId = oTestChildQuote.Id;
        QLI1.PricebookEntryId = Pbe1.Id;
        QLI1.Quantity = 2;
        QLI1.UnitPrice = 150000.0; 
        insert QLI1;
       
      SWAN_Status_Log__c st = new SWAN_Status_Log__c();
         st.swan_record_Id__c = oTestServicePoint.Id;
       st.OwnerId = Userinfo.getUserId();
       st.SWAN_WorkflowId__c ='999999';
       insert st;
       
       Attachment att = new Attachment();
       att.name = 'groupInfo';
       att.ParentId = oTestMasterQuote.Id;
       att.Body = Blob.valueOf('{"groupName":"group 1","groupId":"'+qtGrp.id+'","groupCartId":"'+oTestChildQuote.id+'","contextId":"'+oTestMasterQuote.id+'","parentId":"'+oTestOpty.Id+'","servicePoints":["'+oTestServicePoint.Id+'","'+oTestServicePoint1.Id+'"]}');
       insert att;
           
   }
    
    @isTest
   public static void testCallFixFail(){
        createTestData();
       Test.startTest();
       Quote Qt = [Select id from Quote where Name='Master Quote' limit 1];
         input.put('ContextId', Qt.id);
        SWAN_callFixFailedSubQuoteBatch cl = new SWAN_callFixFailedSubQuoteBatch();
       cl.invokeMethod('callFixFailedSubQuote', input, output, options);
       Test.stopTest();
   }
    
    @isTest
   public static void testCallFixFail1(){
        //createTestData();
       Test.startTest();
       
        SWAN_callFixFailedSubQuoteBatch cl = new SWAN_callFixFailedSubQuoteBatch();
       cl.invokeMethod('callFixFailedSubQuote111', input, output, options);
       Test.stopTest();
   }
    
    
    
}