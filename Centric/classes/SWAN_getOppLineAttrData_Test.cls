@isTest
public class SWAN_getOppLineAttrData_Test {
      public static Map<string, object> input = new Map<string, object>();
      public static Map<string, object> output = new Map<string, object>();
      public static Map<string, object> options = new Map<string, object>();
    public static void createTestData(){
        string temp = '{"SWAN_SP_ATT_CAT":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"a2D8E000001aMT0UAM","attributeid__c":"a0L8E000006FCBHUA4","attributecategoryid__c":"a0K8E000007t8OXUAY","categorycode__c":"SWAN_SP_ATT_CAT","categoryname__c":"SWAN Service Point Attributes","attributeuniquecode__c":"SWAN_ATT_CUST_EAC","attributeconfigurable__c":true,"attributedisplaysequence__c":"31","attributefilterable__c":true,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Customer EAC","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"vlocity_cmt__ObjectClass__c","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a0I8E0000062nWZUAY","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Single Value","value__c":null,"valuedatatype__c":"Number","valuedescription__c":null,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Number","uiDisplayType":"Single Value","value":7777},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t8E00000B4oh5QAB","attributeid__c":"a0L8E000005kdPgUAI","attributecategoryid__c":"a0K8E000007t8OXUAY","categorycode__c":"SWAN_SP_ATT_CAT","categoryname__c":"SWAN Service Point Attributes","attributeuniquecode__c":"SWAN_LAST_MOD_BY","attributeconfigurable__c":true,"attributedisplaysequence__c":"60","attributefilterable__c":true,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Last Modified By","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a0I8E0000062nWeUAI","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"0058E000005thUBQAY"},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t8E00000B4oh5QAB","attributeid__c":"a0L8E000005kdPhUAI","attributecategoryid__c":"a0K8E000007t8OXUAY","categorycode__c":"SWAN_SP_ATT_CAT","categoryname__c":"SWAN Service Point Attributes","attributeuniquecode__c":"SWAN_LAST_MOD_DATE","attributeconfigurable__c":true,"attributedisplaysequence__c":"70","attributefilterable__c":true,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Last Modified Date","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isnottranslatable__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a0I8E0000062nWfUAI","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Text","value__c":null,"valuedatatype__c":"Text","valuedescription__c":null,"attributegrouptype__c":null,"attributeRunTimeInfo":{"dataType":"Text","uiDisplayType":"Text","value":"2020-09-29T13:30:08.613Z"},"$$AttributeDefinitionEnd$$":null}]}';
          //Id recordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('SubQuote').getRecordTypeId();
          
          Product2 p = new Product2();
          p.name='Fixed Price Gyser';
          p.productCode='BG_GYS';
          p.vlocity_cmt__IsOrderable__c=true;
          insert p;
        
          Id pricebookId = Test.getStandardPricebookId();
          PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = p.Id, UnitPrice = 15000, IsActive = true);
          insert standardPrice;
        
          Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
          insert customPB;
        
          PricebookEntry customPrice = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = p.Id, UnitPrice = 22000, IsActive = true);
          insert customPrice;
          
          Opportunity TestOpp = new Opportunity();
          TestOpp.Name = 'Opportunity New_Test';
          TestOpp.StageName = 'Prospecting';
          TestOpp.CloseDate = Date.Today();
          insert TestOpp;
          
        
        
         vlocity_cmt__Premises__c oTestPremise = new vlocity_cmt__Premises__c();
          oTestPremise.vlocity_cmt__PostalCode__c = 'OX4 2ML';
          insert oTestPremise;
        vlocity_cmt__ServicePoint__c oTestServicePoint = new vlocity_cmt__ServicePoint__c();
          oTestServicePoint.vlocity_cmt__ServicePointNumber__c = '99999';
          oTestServicePoint.vlocity_cmt__PremisesId__c = oTestPremise.Id;
          insert oTestServicePoint;
        OpportunityLineItem opl_for_Opp = new OpportunityLineItem();
          //opl_for_Opp.Name='3G Plan';
          opl_for_Opp.SWAN_IsActive__c=true;
          opl_for_Opp.OpportunityId=TestOpp.Id;
          opl_for_Opp.vlocity_cmt__ServicePointId__c=oTestServicePoint.Id;
          opl_for_Opp.vlocity_cmt__JSONAttribute__c=temp;
          opl_for_Opp.Quantity=1;
          opl_for_Opp.UnitPrice=10;
          opl_for_Opp.PricebookEntryId=customPrice.id;
          insert opl_for_Opp;
        output.put('ContextId',TestOpp.Id);
        input.put('ContextId',TestOpp.Id);
    }
     @isTest
      public static void testInvoke(){
          createTestData();
          
          Test.startTest();
          SWAN_getOppLineAttrData temp = new SWAN_getOppLineAttrData ();
          temp.invokeMethod('extractOpportunity',input,output,options);
           Test.stopTest();
      }
}