@isTest
public class SWAN_getQuoteRelatedData_Test{

      public static Map<string, object> input = new Map<string, object>();
      public static Map<string, object> output = new Map<string, object>();
      public static Map<string, object> options = new Map<string, object>();
      
      public static void createTestData(){
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
          oTestOpty.Name = 'Opportunity AWSS3Upload_Test';
          oTestOpty.StageName = 'Prospecting';
          oTestOpty.CloseDate = Date.Today();
          insert oTestOpty;
          
          Quote oTestMasterQuote = new Quote();
          oTestMasterQuote.Name = 'Master Quote AWSS3Upload_Test';
          oTestMasterQuote.OpportunityId = oTestOpty.Id;
          oTestMasterQuote.SWAN_Service_Point_Start_Date__c = Date.today();
          oTestMasterQuote.pricebook2Id=customPB.id;
          oTestMasterQuote.SWAN_Pricing_User__c=userinfo.getuserid();
          insert oTestMasterQuote;
          
          QuoteLineItem qli_for_Master = new QuoteLineItem();
          qli_for_Master.QuoteId = oTestMasterQuote.id;
          qli_for_Master.PriceBookEntryId=customPrice.id;
          qli_for_Master.Product2Id = p.id;
          qli_for_Master.Quantity=1;
          qli_for_Master.UnitPrice=10;
          insert qli_for_Master;
          
          vlocity_cmt__Premises__c oTestPremise = new vlocity_cmt__Premises__c();
          oTestPremise.vlocity_cmt__PostalCode__c = 'OX4 2LL';
          insert oTestPremise;
                       
          vlocity_cmt__ServicePoint__c oTestServicePoint = new vlocity_cmt__ServicePoint__c();
          oTestServicePoint.vlocity_cmt__ServicePointNumber__c = '99999';
          oTestServicePoint.vlocity_cmt__PremisesId__c = oTestPremise.Id;
          insert oTestServicePoint;
          
          Quote oTestChildQuote = new Quote();
          oTestChildQuote.vlocity_cmt__ParentQuoteId__c = oTestMasterQuote.Id;
          oTestChildQuote.vlocity_cmt__DefaultServicePointId__c = oTestServicePoint.Id;
          oTestChildQuote.Name = 'Child Quote AWSS3Upload_Test';
          oTestChildQuote.OpportunityId = oTestOpty.Id;
          oTestChildQuote.pricebook2Id=customPB.id;
          oTestChildQuote.recordTypeId = recordTypeId;
          oTestChildQuote.recordTypeId = recordTypeId;
          
          insert oTestChildQuote;
          
          QuoteLineItem qli = new QuoteLineItem();
          qli.QuoteId = oTestChildQuote.id;
          qli.Product2Id = p.id;
          qli.PriceBookEntryId=customPrice.id;
          qli.Quantity=1;
          qli.UnitPrice=10;
          qli.SWAN_needToReset__c=true;
          insert qli;
          
          Map<String,Object> obj = new Map<String,Object>();
          Map<String,Object> fcp = new Map<String,Object>();
          fcp.put('FixedCostPeriod','Full Contract Duration;First Year');
          input.put('Product',fcp);
          input.put('QuoteId',oTestMasterQuote.Id);
          input.put('BaseProductId',p.Id);
          input.put('OpportunityId',oTestOpty.Id);
          input.put('CreateDataComponent',obj);
          input.put('GorillaAuthorizationHostName','Test');
          input.put('GorillaSecret','Test');
          input.put('GorillaHostName','Test');
      }
      
      @isTest
      public static void testInvoke(){
          createTestData();
          
          Test.startTest();
          SWAN_getQuoteRelatedData temp = new SWAN_getQuoteRelatedData();
          temp.invokeMethod('extractQuote',input,output,options);
          temp.invokeMethod('resetQLI',input,output,options);
          temp.invokeMethod('setQLI',input,output,options);
          temp.invokeMethod('invokeClearPricingBatch',input,output,options);
          temp.invokeMethod('getOLIs',input,output,options);
          temp.invokeMethod('BG_UpdateQuoteWebhook',input,output,options);
          database.executebatch(new BG_UpdateQuoteWebhookBatch(string.valueof(input.get('QuoteId')),'Priced'));
          
          Test.stopTest();
      }
    
     @isTest
      public static void testInvoke1(){
          createTestData();
          
          Test.startTest();
          SWAN_getQuoteRelatedData temp = new SWAN_getQuoteRelatedData();
          temp.invokeMethod('extractQuote_Elec',input,output,options);
          temp.invokeMethod('setChildQuoteEAC',input,output,options);
          temp.invokeMethod('resetChildQuoteEAC',input,output,options);
          temp.invokeMethod('invokeClearPricingBatch',input,output,options);
          temp.invokeMethod('getQuoteAttr',input,output,options);
          temp.invokeMethod('getQLIAttr',input,output,options);
          temp.invokeMethod('PopulatePicklist',input,output,options);
          temp.invokeMethod('resetBA_QLI',input,output,options);
          temp.invokeMethod('getBusinessAccSubQuoteQLI',input,output,options);
          temp.invokeMethod('checkConsumptionIssueforCustEAC',input,output,options);
          Map<String, Object> offerDatesMaptest = new Map<String, Object>();
          input.put('OfferDates',offerDatesMaptest);
          temp.invokeMethod('fixedCostPeriodDefault',input,output,options);
          Test.stopTest();
      }
}