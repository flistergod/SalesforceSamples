@isTest
public class SWAN_getQuotePricingData_Test{

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
          
          Product2 p2 = new Product2();
          p2.name='Std Charge';
          p2.productCode='BG_STD';
          p2.vlocity_cmt__IsOrderable__c=false;
          insert p2;
          
          Product2 p3 = new Product2();
          p3.name='Unit Rate';
          p3.productCode='BG_UNITRATE';
          p3.vlocity_cmt__IsOrderable__c=false;
          insert p3;
          
          Product2 p4 = new Product2();
          p4.name='Unit Rate';
          p4.productCode='BG_UNIT_CHARGE_ALL_OTHER';
          p4.vlocity_cmt__IsOrderable__c=false;
          insert p4;
          
          Product2 p5 = new Product2();
          p5.name='Unit Rate';
          p5.productCode='BG_UNIT_CHARGE_DAY';
          p5.vlocity_cmt__IsOrderable__c=false;
          insert p5;
          
          Product2 p6 = new Product2();
          p6.name='Unit Rate';
          p6.productCode='BG_UNIT_CHARGE_NIGHT';
          p6.vlocity_cmt__IsOrderable__c=false;
          insert p6;
          
          Product2 p7 = new Product2();
          p7.name='Unit Rate';
          p7.productCode='BG_UNIT_CHARGE_PEAK_SHOULDER';
          p7.vlocity_cmt__IsOrderable__c=false;
          insert p7;
          
          Product2 p8 = new Product2();
          p8.name='Unit Rate';
          p8.productCode='BG_UNIT_CHARGE_PEAK';
          p8.vlocity_cmt__IsOrderable__c=false;
          insert p8;
          
          Product2 p9 = new Product2();
          p9.name='Unit Rate';
          p9.productCode='BG_UNIT_CHARGE_SUMMER_DAY';
          p9.vlocity_cmt__IsOrderable__c=false;
          insert p9;
          
          Product2 p10 = new Product2();
          p10.name='Unit Rate';
          p10.productCode='BG_UNIT_CHARGE_SUMMER_NIGHT';
          p10.vlocity_cmt__IsOrderable__c=false;
          insert p10;
          
          Product2 p11 = new Product2();
          p11.name='Unit Rate';
          p11.productCode='BG_UNIT_CHARGE_WEEKDAY';
          p11.vlocity_cmt__IsOrderable__c=false;
          insert p11;
          
          Product2 p12 = new Product2();
          p12.name='Unit Rate';
          p12.productCode='BG_UNIT_CHARGE_WEEKEND';
          p12.vlocity_cmt__IsOrderable__c=false;
          insert p12;
          
          Product2 p13 = new Product2();
          p13.name='Unit Rate';
          p13.productCode='BG_UNIT_CHARGE_WINTER_DAY';
          p13.vlocity_cmt__IsOrderable__c=false;
          insert p13;
          
          Product2 p14 = new Product2();
          p14.name='Unit Rate';
          p14.productCode='BG_UNIT_CHARGE_WINTER_NIGHT';
          p14.vlocity_cmt__IsOrderable__c=false;
          insert p14;
          
          Product2 p15 = new Product2();
          p15.name='Unit Rate';
          p15.productCode='BG_AVAILABILITY_CHARGE';
          p15.vlocity_cmt__IsOrderable__c=false;
          insert p15;
          
        
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
          oTestMasterQuote.recordtypeid = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('MasterQuote').getRecordTypeId();
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
          oTestChildQuote.SWAN_Annual_Spend__c=20.000;
          oTestChildQuote.SWAN_Contract_Spend__c=20.000;
          oTestChildQuote.SWAN_Contract_Volume_KWh__c=20.000;
          
          insert oTestChildQuote;
          
          QuoteLineItem qli = new QuoteLineItem();
          qli.QuoteId = oTestChildQuote.id;
          qli.Product2Id = p.id;
          qli.PriceBookEntryId=customPrice.id;
          qli.Quantity=1;
          qli.UnitPrice=10;
          qli.SWAN_needToReset__c=true;
          insert qli;
          
          QuoteLineItem qli2 = new QuoteLineItem();
          qli2.QuoteId = oTestChildQuote.id;
          qli2.Product2Id = p2.id;
          qli2.PriceBookEntryId=customPrice.id;
          qli2.Quantity=1;
          qli2.UnitPrice=10;
          qli2.SWAN_needToReset__c=true;
          qli2.vlocity_cmt__RecurringCharge__c = 234.567;
          insert qli2;
          
          QuoteLineItem qli3 = new QuoteLineItem();
          qli3.QuoteId = oTestChildQuote.id;
          qli3.Product2Id = p3.id;
          qli3.SWAN_UnitRate__c=102.987;
          qli3.PriceBookEntryId=customPrice.id;
          qli3.Quantity=1;
          qli3.UnitPrice=10;
          qli3.SWAN_needToReset__c=true;
          insert qli3;
          
          QuoteLineItem qli4 = new QuoteLineItem();
          qli4.QuoteId = oTestChildQuote.id;
          qli4.Product2Id = p4.id;
          qli4.SWAN_UnitRate__c=102.987;
          qli4.PriceBookEntryId=customPrice.id;
          qli4.Quantity=1;
          qli4.UnitPrice=10;
          qli4.SWAN_needToReset__c=true;
          insert qli4;
          
          QuoteLineItem qli5 = new QuoteLineItem();
          qli5.QuoteId = oTestChildQuote.id;
          qli5.Product2Id = p5.id;
          qli5.SWAN_UnitRate__c=102.987;
          qli5.PriceBookEntryId=customPrice.id;
          qli5.Quantity=1;
          qli5.UnitPrice=10;
          qli5.SWAN_needToReset__c=true;
          insert qli5;
          
          QuoteLineItem qli6 = new QuoteLineItem();
          qli6.QuoteId = oTestChildQuote.id;
          qli6.Product2Id = p6.id;
          qli6.SWAN_UnitRate__c=102.987;
          qli6.PriceBookEntryId=customPrice.id;
          qli6.Quantity=1;
          qli6.UnitPrice=10;
          qli6.SWAN_needToReset__c=true;
          insert qli6;
          
          QuoteLineItem qli7 = new QuoteLineItem();
          qli7.QuoteId = oTestChildQuote.id;
          qli7.Product2Id = p7.id;
          qli7.SWAN_UnitRate__c=102.987;
          qli7.PriceBookEntryId=customPrice.id;
          qli7.Quantity=1;
          qli7.UnitPrice=10;
          qli7.SWAN_needToReset__c=true;
          insert qli7;
          
          QuoteLineItem qli8 = new QuoteLineItem();
          qli8.QuoteId = oTestChildQuote.id;
          qli8.Product2Id = p8.id;
          qli8.SWAN_UnitRate__c=102.987;
          qli8.PriceBookEntryId=customPrice.id;
          qli8.Quantity=1;
          qli8.UnitPrice=10;
          qli8.SWAN_needToReset__c=true;
          insert qli8;
          
          QuoteLineItem qli9 = new QuoteLineItem();
          qli9.QuoteId = oTestChildQuote.id;
          qli9.Product2Id = p9.id;
          qli9.SWAN_UnitRate__c=102.987;
          qli9.PriceBookEntryId=customPrice.id;
          qli9.Quantity=1;
          qli9.UnitPrice=10;
          qli9.SWAN_needToReset__c=true;
          insert qli9;
          
          QuoteLineItem qli10 = new QuoteLineItem();
          qli10.QuoteId = oTestChildQuote.id;
          qli10.Product2Id = p10.id;
          qli10.SWAN_UnitRate__c=102.987;
          qli10.PriceBookEntryId=customPrice.id;
          qli10.Quantity=1;
          qli10.UnitPrice=10;
          qli10.SWAN_needToReset__c=true;
          insert qli10;
          
          QuoteLineItem qli11 = new QuoteLineItem();
          qli11.QuoteId = oTestChildQuote.id;
          qli11.Product2Id = p11.id;
          qli11.SWAN_UnitRate__c=102.987;
          qli11.PriceBookEntryId=customPrice.id;
          qli11.Quantity=1;
          qli11.UnitPrice=10;
          qli11.SWAN_needToReset__c=true;
          insert qli11;
          
          QuoteLineItem qli12 = new QuoteLineItem();
          qli12.QuoteId = oTestChildQuote.id;
          qli12.Product2Id = p12.id;
          qli12.SWAN_UnitRate__c=102.987;
          qli12.PriceBookEntryId=customPrice.id;
          qli12.Quantity=1;
          qli12.UnitPrice=10;
          qli12.SWAN_needToReset__c=true;
          insert qli12;
          
          QuoteLineItem qli13 = new QuoteLineItem();
          qli13.QuoteId = oTestChildQuote.id;
          qli13.Product2Id = p13.id;
          qli13.SWAN_UnitRate__c=102.987;
          qli13.PriceBookEntryId=customPrice.id;
          qli13.Quantity=1;
          qli13.UnitPrice=10;
          qli13.SWAN_needToReset__c=true;
          insert qli13;
          
          QuoteLineItem qli14 = new QuoteLineItem();
          qli14.QuoteId = oTestChildQuote.id;
          qli14.Product2Id = p14.id;
          qli14.SWAN_UnitRate__c=102.987;
          qli14.PriceBookEntryId=customPrice.id;
          qli14.Quantity=1;
          qli14.UnitPrice=10;
          qli14.SWAN_needToReset__c=true;
          insert qli14;
          
          QuoteLineItem qli15 = new QuoteLineItem();
          qli15.QuoteId = oTestChildQuote.id;
          qli15.Product2Id = p15.id;
          qli15.SWAN_UnitRate__c=102.987;
          qli15.vlocity_cmt__UsageUnitPrice__c=102.987;
          qli15.PriceBookEntryId=customPrice.id;
          qli15.Quantity=1;
          qli15.UnitPrice=10;
          qli15.SWAN_needToReset__c=true;
          insert qli15;
          
          Map<String,Object> obj = new Map<String,Object>();
          input.put('ContextId',oTestMasterQuote.Id);
      }
    
    public static void createTestDataFlex(){
        Id recordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('SubQuote').getRecordTypeId();
        
        Product2 p = new Product2();
        p.name='Fixed Price Gas';
        p.productCode='BG_GAS';
        p.vlocity_cmt__IsOrderable__c=true;
        insert p;

        
        
        Product2 p2 = new Product2();
        p2.name='Std Charge';
        p2.productCode='BG_STD';
        p2.vlocity_cmt__IsOrderable__c=false;
        insert p2;
        
        Product2 p3 = new Product2();
        p3.name='Unit Rate';
        p3.productCode='BG_SHAPING';
        p3.vlocity_cmt__IsOrderable__c=false;
        insert p3;
        
        Product2 p4 = new Product2();
        p4.name='Unit Rate';
        p4.productCode='BG_UNIT_CHARGE_ALL_OTHER';
        p4.vlocity_cmt__IsOrderable__c=false;
        insert p4;
        
        Product2 p5 = new Product2();
        p5.name='Unit Rate';
        p5.productCode='BG_UNIT_CHARGE_DAY';
        p5.vlocity_cmt__IsOrderable__c=false;
        insert p5;
        
        Product2 p6 = new Product2();
        p6.name='Unit Rate';
        p6.productCode='BG_ELECTRICITY_INDUSTRY_CHARGES';
        p6.vlocity_cmt__IsOrderable__c=false;
        insert p6;
        
        Product2 p7 = new Product2();
        p7.name='Unit Rate';
        p7.productCode='BG_UNIT_CHARGE_PEAK_SHOULDER';
        p7.vlocity_cmt__IsOrderable__c=false;
        insert p7;
        
        Product2 p8 = new Product2();
        p8.name='Unit Rate';
        p8.productCode='BG_RENEWABLE_CHARGE';
        p8.vlocity_cmt__IsOrderable__c=false;
        insert p8;
        
        Product2 p9 = new Product2();
        p9.name='Unit Rate';
        p9.productCode='BG_UNIT_CHARGE_SUMMER_DAY';
        p9.vlocity_cmt__IsOrderable__c=false;
        insert p9;
        
        Product2 p10 = new Product2();
        p10.name='Unit Rate';
        p10.productCode='BG_BALANCE_IMBALANCE';
        p10.vlocity_cmt__IsOrderable__c=false;
        insert p10;
        
        Product2 p11 = new Product2();
        p11.name='Unit Rate';
        p11.productCode='BG_UNIT_CHARGE_WEEKDAY';
        p11.vlocity_cmt__IsOrderable__c=false;
        insert p11;
        
        Product2 p12 = new Product2();
        p12.name='Unit Rate';
        p12.productCode='BG_UNIT_CHARGE_WEEKEND';
        p12.vlocity_cmt__IsOrderable__c=false;
        insert p12;
        
        Product2 p13 = new Product2();
        p13.name='Unit Rate';
        p13.productCode='BG_UNIT_CHARGE_WINTER_DAY';
        p13.vlocity_cmt__IsOrderable__c=false;
        insert p13;
        
        Product2 p14 = new Product2();
        p14.name='Unit Rate';
        p14.productCode='BG_ELECTRICITY_MANAGEMENT_FEE';
        p14.vlocity_cmt__IsOrderable__c=false;
        insert p14;
        
        Product2 p15 = new Product2();
        p15.name='Unit Rate';
        p15.productCode='BG_AVAILABILITY_CHARGE';
        p15.vlocity_cmt__IsOrderable__c=false;
        insert p15;

        List<vlocity_cmt__ProductChildItem__c> lchilditems = new List<vlocity_cmt__ProductChildItem__c>();
        vlocity_cmt__ProductChildItem__c pchilditem1 = new vlocity_cmt__ProductChildItem__c();
        pchilditem1.Name = 'pchilditem1';
        pchilditem1.vlocity_cmt__ParentProductId__c = p.Id;
        pchilditem1.vlocity_cmt__ChildLineNumber__c = '1';
        lchilditems.add(pchilditem1);

        vlocity_cmt__ProductChildItem__c pchilditem2 = new vlocity_cmt__ProductChildItem__c();
        pchilditem2.Name = 'pchilditem2';
        pchilditem2.vlocity_cmt__ParentProductId__c = p2.Id;
        pchilditem2.vlocity_cmt__ChildLineNumber__c = '1';
        lchilditems.add(pchilditem2);

        vlocity_cmt__ProductChildItem__c pchilditem3 = new vlocity_cmt__ProductChildItem__c();
        pchilditem3.Name = 'pchilditem3';
        pchilditem3.vlocity_cmt__ParentProductId__c = p3.Id;
        pchilditem3.vlocity_cmt__ChildLineNumber__c = '1';
        lchilditems.add(pchilditem3);

        vlocity_cmt__ProductChildItem__c pchilditem4 = new vlocity_cmt__ProductChildItem__c();
        pchilditem4.Name = 'pchilditem4';
        pchilditem4.vlocity_cmt__ParentProductId__c = p4.Id;
        pchilditem4.vlocity_cmt__ChildLineNumber__c = '1';
        lchilditems.add(pchilditem4);

        vlocity_cmt__ProductChildItem__c pchilditem5 = new vlocity_cmt__ProductChildItem__c();
        pchilditem5.Name = 'pchilditem5';
        pchilditem5.vlocity_cmt__ParentProductId__c = p5.Id;
        pchilditem5.vlocity_cmt__ChildLineNumber__c = '1';
        lchilditems.add(pchilditem5);

        vlocity_cmt__ProductChildItem__c pchilditem6 = new vlocity_cmt__ProductChildItem__c();
        pchilditem6.Name = 'pchilditem6';
        pchilditem6.vlocity_cmt__ParentProductId__c = p6.Id;
        pchilditem6.vlocity_cmt__ChildLineNumber__c = '1';
        lchilditems.add(pchilditem6);

        vlocity_cmt__ProductChildItem__c pchilditem7 = new vlocity_cmt__ProductChildItem__c();
        pchilditem7.Name = 'pchilditem7';
        pchilditem7.vlocity_cmt__ParentProductId__c = p7.Id;
        pchilditem7.vlocity_cmt__ChildLineNumber__c = '1';
        lchilditems.add(pchilditem7);

        vlocity_cmt__ProductChildItem__c pchilditem8 = new vlocity_cmt__ProductChildItem__c();
        pchilditem8.Name = 'pchilditem8';
        pchilditem8.vlocity_cmt__ParentProductId__c = p8.Id;
        pchilditem8.vlocity_cmt__ChildLineNumber__c = '1';
        lchilditems.add(pchilditem8);

        vlocity_cmt__ProductChildItem__c pchilditem9 = new vlocity_cmt__ProductChildItem__c();
        pchilditem9.Name = 'pchilditem9';
        pchilditem9.vlocity_cmt__ParentProductId__c = p9.Id;
        pchilditem9.vlocity_cmt__ChildLineNumber__c = '1';
        lchilditems.add(pchilditem9);

        vlocity_cmt__ProductChildItem__c pchilditem10 = new vlocity_cmt__ProductChildItem__c();
        pchilditem10.Name = 'pchilditem10';
        pchilditem10.vlocity_cmt__ParentProductId__c = p10.Id;
        pchilditem10.vlocity_cmt__ChildLineNumber__c = '1';
        lchilditems.add(pchilditem10);

        vlocity_cmt__ProductChildItem__c pchilditem11 = new vlocity_cmt__ProductChildItem__c();
        pchilditem11.Name = 'pchilditem11';
        pchilditem11.vlocity_cmt__ParentProductId__c = p11.Id;
        pchilditem11.vlocity_cmt__ChildLineNumber__c = '1';
        lchilditems.add(pchilditem11);

        vlocity_cmt__ProductChildItem__c pchilditem12 = new vlocity_cmt__ProductChildItem__c();
        pchilditem12.Name = 'pchilditem12';
        pchilditem12.vlocity_cmt__ParentProductId__c = p12.Id;
        pchilditem12.vlocity_cmt__ChildLineNumber__c = '1';
        lchilditems.add(pchilditem12);

        vlocity_cmt__ProductChildItem__c pchilditem13 = new vlocity_cmt__ProductChildItem__c();
        pchilditem13.Name = 'pchilditem13';
        pchilditem13.vlocity_cmt__ParentProductId__c = p13.Id;
        pchilditem13.vlocity_cmt__ChildLineNumber__c = '1';
        lchilditems.add(pchilditem13);

        vlocity_cmt__ProductChildItem__c pchilditem14 = new vlocity_cmt__ProductChildItem__c();
        pchilditem14.Name = 'pchilditem14';
        pchilditem14.vlocity_cmt__ParentProductId__c = p14.Id;
        pchilditem14.vlocity_cmt__ChildLineNumber__c = '1';
        lchilditems.add(pchilditem14);

        vlocity_cmt__ProductChildItem__c pchilditem15 = new vlocity_cmt__ProductChildItem__c();
        pchilditem15.Name = 'pchilditem15';
        pchilditem15.vlocity_cmt__ParentProductId__c = p15.Id;
        pchilditem15.vlocity_cmt__ChildLineNumber__c = '1';
        lchilditems.add(pchilditem15);
        
        insert lchilditems;
        
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
        oTestMasterQuote.SWAN_Industry_Charges_End_Date__c = Date.today().addDays(10);
        oTestMasterQuote.SWAN_Management_Fee_End_Date__c = Date.today().addDays(10);
        oTestMasterQuote.SWAN_Balance_and_Imbalance_End_Date__c = Date.today().addDays(10);
        oTestMasterQuote.SWAN_Shaping_Premium_End_Date__c = Date.today().addDays(10);
        oTestMasterQuote.SWAN_Renewable_Charge_End_Date__c = Date.today().addDays(10);
        oTestMasterQuote.pricebook2Id=customPB.id;
        oTestMasterQuote.SWAN_Pricing_User__c=userinfo.getuserid();
        oTestMasterQuote.SWAN_Quote_Type__c = 'Flex';
        oTestMasterQuote.recordtypeid = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get('MasterQuote').getRecordTypeId();
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
        oTestChildQuote.SWAN_Annual_Spend__c=20.000;
        oTestChildQuote.SWAN_Contract_Spend__c=20.000;
        oTestChildQuote.SWAN_Contract_Volume_KWh__c=20.000;
        
        insert oTestChildQuote;
        
        QuoteLineItem qli = new QuoteLineItem();
        qli.QuoteId = oTestChildQuote.id;
        qli.Product2Id = p.id;
        qli.PriceBookEntryId=customPrice.id;
        qli.Quantity=1;
        qli.UnitPrice=10;
        qli.SWAN_needToReset__c=true;
        qli.vlocity_cmt__UsageUnitPrice__c = 12;
        insert qli;
        
        QuoteLineItem qli2 = new QuoteLineItem();
        qli2.QuoteId = oTestChildQuote.id;
        qli2.Product2Id = p2.id;
        qli2.PriceBookEntryId=customPrice.id;
        qli2.Quantity=1;
        qli2.UnitPrice=10;
        qli2.SWAN_needToReset__c=true;
        qli2.vlocity_cmt__RecurringCharge__c = 234.567;
        qli2.vlocity_cmt__UsageUnitPrice__c = 12;
        insert qli2;
        
        QuoteLineItem qli3 = new QuoteLineItem();
        qli3.QuoteId = oTestChildQuote.id;
        qli3.Product2Id = p3.id;
        qli3.SWAN_UnitRate__c=102.987;
        qli3.PriceBookEntryId=customPrice.id;
        qli3.Quantity=1;
        qli3.UnitPrice=10;
        qli3.vlocity_cmt__UsageUnitPrice__c=102.987;
        qli3.SWAN_needToReset__c=true;
        insert qli3;
        
        QuoteLineItem qli4 = new QuoteLineItem();
        qli4.QuoteId = oTestChildQuote.id;
        qli4.Product2Id = p4.id;
        qli4.SWAN_UnitRate__c=102.987;
        qli4.PriceBookEntryId=customPrice.id;
        qli4.Quantity=1;
        qli4.UnitPrice=10;
        qli4.vlocity_cmt__UsageUnitPrice__c=102.987;
        qli4.SWAN_needToReset__c=true;
        insert qli4;
        
        QuoteLineItem qli5 = new QuoteLineItem();
        qli5.QuoteId = oTestChildQuote.id;
        qli5.Product2Id = p5.id;
        qli5.SWAN_UnitRate__c=102.987;
        qli5.PriceBookEntryId=customPrice.id;
        qli5.Quantity=1;
        qli5.UnitPrice=10;
        qli5.vlocity_cmt__UsageUnitPrice__c=102.987;
        qli5.SWAN_needToReset__c=true;
        insert qli5;
        
        QuoteLineItem qli6 = new QuoteLineItem();
        qli6.QuoteId = oTestChildQuote.id;
        qli6.Product2Id = p6.id;
        qli6.SWAN_UnitRate__c=102.987;
        qli6.PriceBookEntryId=customPrice.id;
        qli6.Quantity=1;
        qli6.UnitPrice=10;
        qli6.vlocity_cmt__UsageUnitPrice__c=102.987;
        qli6.SWAN_needToReset__c=true;
        insert qli6;
        
        QuoteLineItem qli7 = new QuoteLineItem();
        qli7.QuoteId = oTestChildQuote.id;
        qli7.Product2Id = p7.id;
        qli7.SWAN_UnitRate__c=102.987;
        qli7.PriceBookEntryId=customPrice.id;
        qli7.Quantity=1;
        qli7.UnitPrice=10;
        qli7.vlocity_cmt__UsageUnitPrice__c=102.987;
        qli7.SWAN_needToReset__c=true;
        insert qli7;
        
        QuoteLineItem qli8 = new QuoteLineItem();
        qli8.QuoteId = oTestChildQuote.id;
        qli8.Product2Id = p8.id;
        qli8.SWAN_UnitRate__c=102.987;
        qli8.vlocity_cmt__UsageUnitPrice__c=102.987;
        qli8.PriceBookEntryId=customPrice.id;
        qli8.Quantity=1;
        qli8.UnitPrice=10;
        qli8.SWAN_needToReset__c=true;
        insert qli8;
        
        QuoteLineItem qli9 = new QuoteLineItem();
        qli9.QuoteId = oTestChildQuote.id;
        qli9.Product2Id = p9.id;
        qli9.SWAN_UnitRate__c=102.987;
        qli9.vlocity_cmt__UsageUnitPrice__c=102.987;
        qli9.PriceBookEntryId=customPrice.id;
        qli9.Quantity=1;
        qli9.UnitPrice=10;
        qli9.SWAN_needToReset__c=true;
        insert qli9;
        
        QuoteLineItem qli10 = new QuoteLineItem();
        qli10.QuoteId = oTestChildQuote.id;
        qli10.Product2Id = p10.id;
        qli10.SWAN_UnitRate__c=102.987;
        qli10.vlocity_cmt__UsageUnitPrice__c=102.987;
        qli10.PriceBookEntryId=customPrice.id;
        qli10.Quantity=1;
        qli10.UnitPrice=10;
        qli10.SWAN_needToReset__c=true;
        insert qli10;
        
        QuoteLineItem qli11 = new QuoteLineItem();
        qli11.QuoteId = oTestChildQuote.id;
        qli11.Product2Id = p11.id;
        qli11.SWAN_UnitRate__c=102.987;
        qli11.vlocity_cmt__UsageUnitPrice__c=102.987;
        qli11.PriceBookEntryId=customPrice.id;
        qli11.Quantity=1;
        qli11.UnitPrice=10;
        qli11.SWAN_needToReset__c=true;
        insert qli11;
        
        QuoteLineItem qli12 = new QuoteLineItem();
        qli12.QuoteId = oTestChildQuote.id;
        qli12.Product2Id = p12.id;
        qli12.SWAN_UnitRate__c=102.987;
        qli12.vlocity_cmt__UsageUnitPrice__c=102.987;
        qli12.PriceBookEntryId=customPrice.id;
        qli12.Quantity=1;
        qli12.UnitPrice=10;
        qli12.SWAN_needToReset__c=true;
        insert qli12;
        
        QuoteLineItem qli13 = new QuoteLineItem();
        qli13.QuoteId = oTestChildQuote.id;
        qli13.Product2Id = p13.id;
        qli13.SWAN_UnitRate__c=102.987;
        qli13.vlocity_cmt__UsageUnitPrice__c=102.987;
        qli13.PriceBookEntryId=customPrice.id;
        qli13.Quantity=1;
        qli13.UnitPrice=10;
        qli13.SWAN_needToReset__c=true;
        insert qli13;
        
        QuoteLineItem qli14 = new QuoteLineItem();
        qli14.QuoteId = oTestChildQuote.id;
        qli14.Product2Id = p14.id;
        qli14.SWAN_UnitRate__c=102.987;
        qli14.vlocity_cmt__UsageUnitPrice__c=102.987;
        qli14.PriceBookEntryId=customPrice.id;
        qli14.Quantity=1;
        qli14.UnitPrice=10;
        qli14.SWAN_needToReset__c=true;
        insert qli14;
        
        QuoteLineItem qli15 = new QuoteLineItem();
        qli15.QuoteId = oTestChildQuote.id;
        qli15.Product2Id = p15.id;
        qli15.SWAN_UnitRate__c=102.987;
        qli15.vlocity_cmt__UsageUnitPrice__c=102.987;
        qli15.PriceBookEntryId=customPrice.id;
        qli15.Quantity=1;
        qli15.UnitPrice=10;
        qli15.SWAN_needToReset__c=true;
        insert qli15;
        
        Map<String,Object> obj = new Map<String,Object>();
        input.put('ContextId',oTestMasterQuote.Id);
    }
      
      @isTest
      public static void testExtractQuotePriceFixed(){
          createTestData();
          
          Test.startTest();
          SWAN_getQuotePricingData temp = new SWAN_getQuotePricingData();
          temp.invokeMethod('extractQuotePrice',input,output,options);
          Test.stopTest();
      }
    
      @isTest
    public static void testExtractQuotePriceFlex(){
        createTestDataFlex();
        
        Quote masterQuote = [Select Id from Quote where RecordType.DeveloperName = 'MasterQuote' limit 1];
        input.put('ContextId', masterQuote.Id);
        
        Test.startTest();
        SWAN_getQuotePricingData temp = new SWAN_getQuotePricingData();
        temp.invokeMethod('extractQuotePrice',input,output,options);
        Test.stopTest();
    }

    @isTest
    public static void testfixedUntil() {
        createTestDataFlex();
        
        Quote masterQuote = [Select Id from Quote where Name like '%Child Quote%' limit 1];
        input.put('ContextId', masterQuote.Id);

        List<QuoteLineItem> qlis_productcode_management = [select Id, Product2Id, Product2.ProductCode, Quote.vlocity_cmt__ParentQuoteId__r.SWAN_Management_Fee_End_Date__c, Quote.vlocity_cmt__ParentQuoteId__r.SWAN_Balance_and_Imbalance_End_Date__c,Quote.vlocity_cmt__ParentQuoteId__r.SWAN_Shaping_Premium_End_Date__c,Quote.vlocity_cmt__ParentQuoteId__r.SWAN_Industry_Charges_End_Date__c, Quote.vlocity_cmt__ParentQuoteId__r.SWAN_Quote_Renewable__c,Quote.vlocity_cmt__ParentQuoteId__r.SWAN_Renewable_Charge_End_Date__c from QuoteLineItem where QuoteId =: masterQuote.Id and Product2.ProductCode = 'BG_ELECTRICITY_MANAGEMENT_FEE'];
        List<QuoteLineItem> qlis_productcode_imbalance = [select Id, Product2Id, Product2.ProductCode, Quote.vlocity_cmt__ParentQuoteId__r.SWAN_Management_Fee_End_Date__c, Quote.vlocity_cmt__ParentQuoteId__r.SWAN_Balance_and_Imbalance_End_Date__c,Quote.vlocity_cmt__ParentQuoteId__r.SWAN_Shaping_Premium_End_Date__c,Quote.vlocity_cmt__ParentQuoteId__r.SWAN_Industry_Charges_End_Date__c, Quote.vlocity_cmt__ParentQuoteId__r.SWAN_Quote_Renewable__c,Quote.vlocity_cmt__ParentQuoteId__r.SWAN_Renewable_Charge_End_Date__c from QuoteLineItem where QuoteId =: masterQuote.Id and Product2.ProductCode = 'BG_BALANCE_IMBALANCE'];
        List<QuoteLineItem> qlis_productcode_shaping = [select Id, Product2Id, Product2.ProductCode, Quote.vlocity_cmt__ParentQuoteId__r.SWAN_Management_Fee_End_Date__c, Quote.vlocity_cmt__ParentQuoteId__r.SWAN_Balance_and_Imbalance_End_Date__c,Quote.vlocity_cmt__ParentQuoteId__r.SWAN_Shaping_Premium_End_Date__c,Quote.vlocity_cmt__ParentQuoteId__r.SWAN_Industry_Charges_End_Date__c, Quote.vlocity_cmt__ParentQuoteId__r.SWAN_Quote_Renewable__c,Quote.vlocity_cmt__ParentQuoteId__r.SWAN_Renewable_Charge_End_Date__c from QuoteLineItem where QuoteId =: masterQuote.Id and Product2.ProductCode = 'BG_SHAPING'];
        List<QuoteLineItem> qlis_productcode_industry = [select Id, Product2Id, Product2.ProductCode, Quote.vlocity_cmt__ParentQuoteId__r.SWAN_Management_Fee_End_Date__c, Quote.vlocity_cmt__ParentQuoteId__r.SWAN_Balance_and_Imbalance_End_Date__c,Quote.vlocity_cmt__ParentQuoteId__r.SWAN_Shaping_Premium_End_Date__c,Quote.vlocity_cmt__ParentQuoteId__r.SWAN_Industry_Charges_End_Date__c, Quote.vlocity_cmt__ParentQuoteId__r.SWAN_Quote_Renewable__c,Quote.vlocity_cmt__ParentQuoteId__r.SWAN_Renewable_Charge_End_Date__c from QuoteLineItem where QuoteId =: masterQuote.Id and Product2.ProductCode = 'BG_ELECTRICITY_INDUSTRY_CHARGES'];
        List<QuoteLineItem> qlis_productcode_renewable = [select Id, Product2Id, Product2.ProductCode, Quote.vlocity_cmt__ParentQuoteId__r.SWAN_Management_Fee_End_Date__c, Quote.vlocity_cmt__ParentQuoteId__r.SWAN_Balance_and_Imbalance_End_Date__c,Quote.vlocity_cmt__ParentQuoteId__r.SWAN_Shaping_Premium_End_Date__c,Quote.vlocity_cmt__ParentQuoteId__r.SWAN_Industry_Charges_End_Date__c, Quote.vlocity_cmt__ParentQuoteId__r.SWAN_Quote_Renewable__c,Quote.vlocity_cmt__ParentQuoteId__r.SWAN_Renewable_Charge_End_Date__c from QuoteLineItem where QuoteId =: masterQuote.Id and Product2.ProductCode = 'BG_RENEWABLE_CHARGE'];
        
        Test.startTest();
        SWAN_getQuotePricingData temp = new SWAN_getQuotePricingData();
        temp.fixedUntil(qlis_productcode_management[0]);
        temp.fixedUntil(qlis_productcode_imbalance[0]);
        temp.fixedUntil(qlis_productcode_shaping[0]);
        temp.fixedUntil(qlis_productcode_industry[0]);
        temp.fixedUntil(qlis_productcode_renewable[0]);
        Test.stopTest();
    }

    @isTest
    public static void testrowTable() {
        createTestDataFlex();
        
        Quote masterQuote = [Select Id from Quote where Name like '%Child Quote%' limit 1];
        input.put('ContextId', masterQuote.Id);

        List<QuoteLineItem> qlis = [select Id, vlocity_cmt__UsageUnitPrice__c, SWAN_UsageUnitPriceNBP__c, vlocity_cmt__OneTimeCost__c, SWAN_UnitRate__c, SWAN_Unit_Rate_Therms__c,SWAN_UsageUnitPriceGSP__c, Product2Id, Product2.ProductCode, Quote.vlocity_cmt__ParentQuoteId__r.SWAN_Management_Fee_End_Date__c, Quote.vlocity_cmt__ParentQuoteId__r.SWAN_Balance_and_Imbalance_End_Date__c,Quote.vlocity_cmt__ParentQuoteId__r.SWAN_Shaping_Premium_End_Date__c,Quote.vlocity_cmt__ParentQuoteId__r.SWAN_Industry_Charges_End_Date__c, Quote.vlocity_cmt__ParentQuoteId__r.SWAN_Quote_Renewable__c,Quote.vlocity_cmt__ParentQuoteId__r.SWAN_Renewable_Charge_End_Date__c from QuoteLineItem where QuoteId =: masterQuote.Id and vlocity_cmt__UsageUnitPrice__c != null];
        
        Test.startTest();
        SWAN_getQuotePricingData temp = new SWAN_getQuotePricingData();
        temp.rowTable(qlis[0],'Electricity','detail','masterProd','FixedUntil');
        temp.rowTable(qlis[0],'Gas','detail','masterProd','FixedUntil');
        Test.stopTest();
    }
}