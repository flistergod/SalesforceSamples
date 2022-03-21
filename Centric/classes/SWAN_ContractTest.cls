@isTest
public class SWAN_ContractTest {

    public static Quote masterQuote = new Quote();
    public static Quote masterQuote1 = new Quote();
    public static Opportunity opp = new Opportunity();
    public static Contact con = new Contact();
    
    public static void createStaticDataWithOfferPack()
    {
        Account acc = new Account();
        acc.Name = 'createStaticDataWithOfferPack';
        acc.SWAN_Customer_Segment__c = 'I&C';
        acc.SWAN_Micro_Business_Selection__c = 'Non_Micro_Business';
        insert acc;
        
        opp.AccountId = acc.Id;
        opp.Name = 'Test Opp';
        opp.StageName = 'Prospecting';
        opp.CloseDate = date.today();
        insert opp;
        
        con.AccountId = acc.Id;
        con.lastName = 'Last Name';
        con.firstname ='Fname';
        con.MailingStreet='M street';
        con.MailingPostalCode='M50 2HX';
        con.SWAN_Mailing_Building_Name__c='Building name';
        con.MailingCity = 'test City';
        insert con;
        
        List<Quote> masterQuoteList = new List<Quote>();
        
        //Quote masterQuote = new Quote();
        masterQuote1.OpportunityId = opp.Id;
        masterQuote1.Name = 'Master Quote 1';
        masterQuote1.SWAN_Pricing_Structure__c = 'Site Specific With Standing Charge';
        masterQuote1.SWAN_Payment_Method_and_Term__c = 'Direct Debit - 14 Days';
        masterQuote1.SWAN_Offer_Start_Date__c = Date.today();
        masterQuote1.SWAN_Number_of_Service_Points__c = 2;
        masterQuote1.Status = 'Draft';
        masterQuote1.SWAN_Sales_Channel__c = 'Direct Quote';
        masterQuoteList.add(masterQuote1);
        
        Quote masterQuote2 = new Quote();
        masterQuote2.OpportunityId = opp.Id;
        masterQuote2.Name = 'Master Quote 2';
        masterQuote2.SWAN_Pricing_Structure__c = 'Site Specific Without Standing Charge';
        masterQuote2.SWAN_Payment_Method_and_Term__c = 'Direct Debit - 14 Days';
        masterQuote2.SWAN_Offer_Start_Date__c = Date.today();
        masterQuote2.SWAN_Number_of_Service_Points__c = 2;
        masterQuote2.Status = 'Draft';
        masterQuoteList.add(masterQuote2);
        insert masterQuoteList;
        
        vlocity_cmt__Premises__c premise = new vlocity_cmt__Premises__c();
        insert premise;
        
        vlocity_cmt__ServicePoint__c servicePoint = new vlocity_cmt__ServicePoint__c();
        servicePoint.SWAN_Formula_Year_Annual_Quantity__c = 12331;
        servicePoint.SWAN_Formula_Year_Offtake_Quantity__c = 3321;
        servicePoint.vlocity_cmt__ServicePointNumber__c = '1231231231';
        servicePoint.vlocity_cmt__PremisesId__c = premise.id;
        servicePoint.SWAN_Product_Class__c = '3';
        insert servicePoint;
        
        Quote childQuote = new Quote();
        childQuote.vlocity_cmt__ParentQuoteId__c = masterQuote1.id;
        childQuote.vlocity_cmt__DefaultServicePointId__c= servicePoint.id;
        childQuote.SWAN_Service_Point_Start_Date__c = date.today();
        childQuote.name = 'child quote';
        childQuote.OpportunityId = opp.id;
        insert childQuote;
        
        
        SWAN_Offer_Pack__c offerPack = new SWAN_Offer_Pack__c();
        offerPack.Contact__c = con.id;
        offerPack.SWAN_Opportunity__c = opp.id;
        insert offerPack;
        
        List<SWAN_Offer_Pack_Quote__c> listOfferPackQuote = new List<SWAN_Offer_Pack_Quote__c>();
        SWAN_Offer_Pack_Quote__c opq1 = new SWAN_Offer_Pack_Quote__c();
        opq1.SWAN_Offer_Pack__c = offerPack.id;
        opq1.SWAN_Quote__c = masterQuote1.id;
        listOfferPackQuote.add(opq1);
        
        SWAN_Offer_Pack_Quote__c opq2 = new SWAN_Offer_Pack_Quote__c();
        opq2.SWAN_Offer_Pack__c = offerPack.id;
        opq2.SWAN_Quote__c = masterQuote2.id;
        listOfferPackQuote.add(opq2);
        
        insert listOfferPackQuote;
        
        system.debug('~~~~~'+masterQuote1.Status);
        masterQuote1.Status = 'Selected';
        update masterQuote1;
        system.debug('~~~~~'+masterQuote1.Status);
        
        Contract con1 = new Contract();
        con1.vlocity_cmt__QuoteId__c = masterQuote1.id;
        con1.AccountId = acc.Id;
        con1.status = 'Draft';
        insert con1;
        
        vlocity_cmt__ContractLineItem__c CLI = new vlocity_cmt__ContractLineItem__c();
        CLI.vlocity_cmt__ContractId__c = con1.id;
        CLI.SWAN_Service_Point__c = servicePoint.id;
        CLI.vlocity_cmt__EffectiveStartDate__c = system.today();
        CLI.vlocity_cmt__EffectiveEndDate__c = system.today().addYears(2);
		CLI.SWAN_Quote__c=childQuote.id;
        insert CLI;
        
        con1.vlocity_cmt__OpportunityId__c = opp.Id;
        con1.status = 'Contract Signed';
        update con1;
    }  
    
    public static void createElecStaticDataWithOfferPack()
    {
        Account acc = new Account();
        acc.Name = 'ContractAccount';
        acc.SWAN_Customer_Segment__c = 'I&C';
        acc.SWAN_Micro_Business_Selection__c = 'Non_Micro_Business';
        insert acc;
        
        Opportunity Opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.Name = 'Test Opp';
        opp.StageName = 'Prospecting';
        opp.CloseDate = date.today();
        Opp.SWAN_Fuel_Type__c = 'Electricity';
        //Opp.SWAN_Direct_Relation_With_Meter_Agents__c=true;
        insert opp;
        
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.lastName = 'Last Name';
        con.firstname ='Fname';
        con.MailingStreet='M street';
        con.MailingPostalCode='M50 2HX';
        con.SWAN_Mailing_Building_Name__c='Building name';
        con.MailingCity = 'test City';
        insert con;
        
        Product2 p = new Product2();
          p.name='Fixed Price Electricity';
          p.productCode='BG_ELEC';
          p.vlocity_cmt__IsOrderable__c=true;
          insert p;
          
          Product2 p2 = new Product2();
          p2.name='Std Charge';
          p2.productCode='BG_STD';
          p2.vlocity_cmt__IsOrderable__c=false;
          insert p2;
          
          /*
          Product2 p3 = new Product2();
          p3.name='Unit Rate';
          p3.productCode='BG_UNITRATE';
          p3.vlocity_cmt__IsOrderable__c=false;
          insert p3;
          */ 
          
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
          
          /*
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
          */
          
          Product2 p15 = new Product2();
          p15.name='Unit Rate';
          p15.productCode='BG_AVAILABILITY_CHARGE';
          p15.vlocity_cmt__IsOrderable__c=false;
          insert p15;
          
        
          Id pricebookId = Test.getStandardPricebookId();
          PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = p.Id, UnitPrice = 10000, IsActive = true);
          PricebookEntry standardPrice2 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = p2.Id, UnitPrice = 10000, IsActive = true);
          PricebookEntry standardPrice4 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = p4.Id, UnitPrice = 10000, IsActive = true);
          PricebookEntry standardPrice5 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = p5.Id, UnitPrice = 10000, IsActive = true);
          PricebookEntry standardPrice15 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = p15.Id, UnitPrice = 10000, IsActive = true);
          insert standardPrice;
          insert standardPrice2;
          insert standardPrice4;
          insert standardPrice5;
          insert standardPrice15;
        
          Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
          insert customPB;
        
          PricebookEntry customPrice = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = p.Id, UnitPrice = 12000, IsActive = true);
          insert customPrice;
          PricebookEntry customPrice2 = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = p2.Id, UnitPrice = 12000, IsActive = true);
          insert customPrice2;
          PricebookEntry customPrice4 = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = p4.Id, UnitPrice = 12000, IsActive = true);
          insert customPrice4;
          PricebookEntry customPrice5 = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = p5.Id, UnitPrice = 12000, IsActive = true);
          insert customPrice5;
          PricebookEntry customPrice15 = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = p15.Id, UnitPrice = 12000, IsActive = true);
          insert customPrice15;
          
        
        Quote masterQuote1_New = new Quote();
        masterQuote1_New.OpportunityId = opp.Id;
        masterQuote1_New.Name = 'Master Quote 1';
        masterQuote1_New.SWAN_Pricing_Structure__c = 'HH 2 Rate';
        masterQuote1_New.SWAN_Payment_Method_and_Term__c = 'Direct Debit - 14 Days';
        masterQuote1_New.SWAN_Offer_Start_Date__c = Date.today();
        masterQuote1_New.SWAN_Number_of_Service_Points__c = 2;
        masterQuote1_New.Status = 'Draft';
        masterQuote1_New.SWAN_Quote_for_Fuel_Type__c='Electricity';
        masterQuote1_New.SWAN_Passthrough_Option__c='AAHEDC';
        masterQuote1_New.SWAN_Pricing_User__c=userinfo.getuserid();
        masterQuote1_New.pricebook2Id=customPB.id;
        insert masterQuote1_New;
        
        QuoteLineItem qli_for_Master = new QuoteLineItem();
          qli_for_Master.QuoteId = masterQuote1_New.id;
          qli_for_Master.PriceBookEntryId=customPrice.id;
          qli_for_Master.Product2Id = p.id;
          qli_for_Master.Quantity=1;
          qli_for_Master.UnitPrice=10;
          insert qli_for_Master;
          
        Quote masterQuote2_New = new Quote();
        masterQuote2_New.OpportunityId = opp.Id;
        masterQuote2_New.Name = 'Master Quote 2';
        masterQuote2_New.SWAN_Pricing_Structure__c = 'HH 2 Rate';
        masterQuote2_New.SWAN_Payment_Method_and_Term__c = 'Direct Debit - 14 Days';
        masterQuote2_New.SWAN_Offer_Start_Date__c = Date.today();
        masterQuote2_New.SWAN_Number_of_Service_Points__c = 2;
        masterQuote2_New.Status = 'Draft';
        masterQuote2_New.SWAN_Quote_for_Fuel_Type__c='Electricity';
        masterQuote2_New.SWAN_Passthrough_Option__c='AAHEDC';
        masterQuote2_New.pricebook2Id=customPB.id;
        masterQuote2_New.SWAN_Pricing_User__c=userinfo.getuserid();
        insert masterQuote2_New;
        
        QuoteLineItem qli_for_Master2 = new QuoteLineItem();
          qli_for_Master2.QuoteId = masterQuote2_New.id;
          qli_for_Master2.PriceBookEntryId=customPrice.id;
          qli_for_Master2.Product2Id = p.id;
          qli_for_Master2.Quantity=1;
          qli_for_Master2.UnitPrice=10;
          insert qli_for_Master2;
          
        vlocity_cmt__Premises__c premise = new vlocity_cmt__Premises__c();
        insert premise;
        
        vlocity_cmt__ServicePoint__c servicePoint = new vlocity_cmt__ServicePoint__c();
        servicePoint.SWAN_Formula_Year_Annual_Quantity__c = 12331;
        servicePoint.SWAN_Formula_Year_Offtake_Quantity__c = 3321;
        servicePoint.vlocity_cmt__ServicePointNumber__c = '1231231231';
        servicePoint.vlocity_cmt__PremisesId__c = premise.id;
        servicePoint.SWAN_Product_Class__c = '3';
        servicePoint.SWAN_Measurement_Class__c='C';
        insert servicePoint;
        
        Quote childQuote = new Quote();
        childQuote.vlocity_cmt__ParentQuoteId__c = masterQuote1_New.id;
        childQuote.vlocity_cmt__DefaultServicePointId__c= servicePoint.id;
        childQuote.SWAN_Service_Point_Start_Date__c = date.today();
        childQuote.name = 'child quote';
        childQuote.OpportunityId = opp.id;
        childQuote.pricebook2Id=customPB.id;
        insert childQuote;
        
        QuoteLineItem qli = new QuoteLineItem();
          qli.QuoteId = childQuote.id;
          qli.Product2Id = p.id;
          qli.PriceBookEntryId=customPrice.id;
          qli.Quantity=1;
          qli.UnitPrice=10;
          qli.SWAN_needToReset__c=true;
          insert qli;
          
          QuoteLineItem qli2 = new QuoteLineItem();
          qli2.QuoteId = childQuote.id;
          qli2.Product2Id = p2.id;
          qli2.PriceBookEntryId=customPrice2.id;
          qli2.Quantity=1;
          qli2.UnitPrice=10;
          qli2.SWAN_needToReset__c=true;
          qli2.vlocity_cmt__RecurringCharge__c = 234.567;
          insert qli2;
          
          /*QuoteLineItem qli3 = new QuoteLineItem();
          qli3.QuoteId = childQuote.id;
          qli3.Product2Id = p3.id;
          qli3.SWAN_UnitRate__c=102.987;
          qli3.PriceBookEntryId=customPrice.id;
          qli3.Quantity=1;
          qli3.UnitPrice=10;
          qli3.SWAN_needToReset__c=true;
          insert qli3;*/
          
          QuoteLineItem qli4 = new QuoteLineItem();
          qli4.QuoteId = childQuote.id;
          qli4.Product2Id = p4.id;
          qli4.SWAN_UnitRate__c=102.987;
          qli4.PriceBookEntryId=customPrice4.id;
          qli4.Quantity=1;
          qli4.UnitPrice=10;
          qli4.SWAN_needToReset__c=true;
          insert qli4;
          
          QuoteLineItem qli5 = new QuoteLineItem();
          qli5.QuoteId = childQuote.id;
          qli5.Product2Id = p5.id;
          qli5.SWAN_UnitRate__c=102.987;
          qli5.PriceBookEntryId=customPrice5.id;
          qli5.Quantity=1;
          qli5.UnitPrice=10;
          qli5.SWAN_needToReset__c=true;
          insert qli5;
          
          /*QuoteLineItem qli6 = new QuoteLineItem();
          qli6.QuoteId = childQuote.id;
          qli6.Product2Id = p6.id;
          qli6.SWAN_UnitRate__c=102.987;
          qli6.PriceBookEntryId=customPrice.id;
          qli6.Quantity=1;
          qli6.UnitPrice=10;
          qli6.SWAN_needToReset__c=true;
          insert qli6;
          
          QuoteLineItem qli7 = new QuoteLineItem();
          qli7.QuoteId = childQuote.id;
          qli7.Product2Id = p7.id;
          qli7.SWAN_UnitRate__c=102.987;
          qli7.PriceBookEntryId=customPrice.id;
          qli7.Quantity=1;
          qli7.UnitPrice=10;
          qli7.SWAN_needToReset__c=true;
          insert qli7;
          
          QuoteLineItem qli8 = new QuoteLineItem();
          qli8.QuoteId = childQuote.id;
          qli8.Product2Id = p8.id;
          qli8.SWAN_UnitRate__c=102.987;
          qli8.PriceBookEntryId=customPrice.id;
          qli8.Quantity=1;
          qli8.UnitPrice=10;
          qli8.SWAN_needToReset__c=true;
          insert qli8;
          
          QuoteLineItem qli9 = new QuoteLineItem();
          qli9.QuoteId = childQuote.id;
          qli9.Product2Id = p9.id;
          qli9.SWAN_UnitRate__c=102.987;
          qli9.PriceBookEntryId=customPrice.id;
          qli9.Quantity=1;
          qli9.UnitPrice=10;
          qli9.SWAN_needToReset__c=true;
          insert qli9;
          
          QuoteLineItem qli10 = new QuoteLineItem();
          qli10.QuoteId = childQuote.id;
          qli10.Product2Id = p10.id;
          qli10.SWAN_UnitRate__c=102.987;
          qli10.PriceBookEntryId=customPrice.id;
          qli10.Quantity=1;
          qli10.UnitPrice=10;
          qli10.SWAN_needToReset__c=true;
          insert qli10;
          
          QuoteLineItem qli11 = new QuoteLineItem();
          qli11.QuoteId = childQuote.id;
          qli11.Product2Id = p11.id;
          qli11.SWAN_UnitRate__c=102.987;
          qli11.PriceBookEntryId=customPrice.id;
          qli11.Quantity=1;
          qli11.UnitPrice=10;
          qli11.SWAN_needToReset__c=true;
          insert qli11;
          
          QuoteLineItem qli12 = new QuoteLineItem();
          qli12.QuoteId = childQuote.id;
          qli12.Product2Id = p12.id;
          qli12.SWAN_UnitRate__c=102.987;
          qli12.PriceBookEntryId=customPrice.id;
          qli12.Quantity=1;
          qli12.UnitPrice=10;
          qli12.SWAN_needToReset__c=true;
          insert qli12;
          
          QuoteLineItem qli13 = new QuoteLineItem();
          qli13.QuoteId = childQuote.id;
          qli13.Product2Id = p13.id;
          qli13.SWAN_UnitRate__c=102.987;
          qli13.PriceBookEntryId=customPrice.id;
          qli13.Quantity=1;
          qli13.UnitPrice=10;
          qli13.SWAN_needToReset__c=true;
          insert qli13;
          
          QuoteLineItem qli14 = new QuoteLineItem();
          qli14.QuoteId = childQuote.id;
          qli14.Product2Id = p14.id;
          qli14.SWAN_UnitRate__c=102.987;
          qli14.PriceBookEntryId=customPrice.id;
          qli14.Quantity=1;
          qli14.UnitPrice=10;
          qli14.SWAN_needToReset__c=true;
          insert qli14;*/
          
          QuoteLineItem qli15 = new QuoteLineItem();
          qli15.QuoteId = childQuote.id;
          qli15.Product2Id = p15.id;
          qli15.SWAN_UnitRate__c=102.987;
          qli15.vlocity_cmt__UsageUnitPrice__c=102.987;
          qli15.PriceBookEntryId=customPrice15.id;
          qli15.Quantity=1;
          qli15.UnitPrice=10;
          qli15.SWAN_needToReset__c=true;
          insert qli15;
          
        SWAN_Offer_Pack__c offerPack = new SWAN_Offer_Pack__c();
        offerPack.Contact__c = con.id;
        offerPack.SWAN_Opportunity__c = opp.id;
        insert offerPack;
        
        List<SWAN_Offer_Pack_Quote__c> listOfferPackQuote = new List<SWAN_Offer_Pack_Quote__c>();
        SWAN_Offer_Pack_Quote__c opq1 = new SWAN_Offer_Pack_Quote__c();
        opq1.SWAN_Offer_Pack__c = offerPack.id;
        opq1.SWAN_Quote__c = masterQuote1_New.id;
        listOfferPackQuote.add(opq1);
        
        SWAN_Offer_Pack_Quote__c opq2 = new SWAN_Offer_Pack_Quote__c();
        opq2.SWAN_Offer_Pack__c = offerPack.id;
        opq2.SWAN_Quote__c = masterQuote2_New.id;
        listOfferPackQuote.add(opq2);
        
        insert listOfferPackQuote;
        
        system.debug('~~~~~'+masterQuote1_New.Status);
        masterQuote1_New.Status = 'Selected';
        update masterQuote1_New;
        system.debug('~~~~~'+masterQuote1_New.Status);
        
        Contract con1 = new Contract();
        con1.vlocity_cmt__QuoteId__c = masterQuote1_New.id;
        con1.AccountId = acc.Id;
        con1.status = 'Draft';
        insert con1;
        
        vlocity_cmt__ContractLineItem__c CLI = new vlocity_cmt__ContractLineItem__c();
        CLI.vlocity_cmt__ContractId__c = con1.id;
        CLI.SWAN_Service_Point__c = servicePoint.id;
		CLI.vlocity_cmt__EffectiveStartDate__c = system.today();
        CLI.vlocity_cmt__EffectiveEndDate__c = system.today().addYears(2);
		CLI.SWAN_Quote__c=childQuote.id;
        insert CLI;
        
        con1.vlocity_cmt__OpportunityId__c = opp.Id;
        con1.status = 'Contract Signed';
        update con1;
    }  
    
    public static void createElecStaticDataWithOfferPack2()
    {
        Account acc = new Account();
        acc.Name = 'TestAccnt3';
        acc.SWAN_Customer_Segment__c = 'I&C';
        acc.SWAN_Micro_Business_Selection__c = 'Non_Micro_Business';
        insert acc;
        
        Opportunity Opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.Name = 'Test Opp';
        opp.StageName = 'Prospecting';
        opp.CloseDate = date.today();
        Opp.SWAN_Fuel_Type__c = 'Electricity';
        //Opp.SWAN_Direct_Relation_With_Meter_Agents__c=true;
        insert opp;
        
        Contact con = new Contact();
        con.AccountId = acc.Id;
        con.lastName = 'Last Name';
        con.firstname ='Fname';
        con.MailingStreet='M street';
        con.MailingPostalCode='M50 2HX';
        con.SWAN_Mailing_Building_Name__c='Building name';
        con.MailingCity = 'test City';
        insert con;
        
        Product2 p = new Product2();
          p.name='Fixed Price Electricity';
          p.productCode='BG_ELEC';
          p.vlocity_cmt__IsOrderable__c=true;
          insert p;
          
          Product2 p2 = new Product2();
          p2.name='Std Charge';
          p2.productCode='BG_STD';
          p2.vlocity_cmt__IsOrderable__c=false;
          insert p2;
          
          
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
          
          Product2 p15 = new Product2();
          p15.name='Unit Rate';
          p15.productCode='BG_AVAILABILITY_CHARGE';
          p15.vlocity_cmt__IsOrderable__c=false;
          insert p15;
          
        
          Id pricebookId = Test.getStandardPricebookId();
          PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = p.Id, UnitPrice = 10000, IsActive = true);
          PricebookEntry standardPrice2 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = p2.Id, UnitPrice = 10000, IsActive = true);
          PricebookEntry standardPrice4 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = p4.Id, UnitPrice = 10000, IsActive = true);
          PricebookEntry standardPrice5 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = p5.Id, UnitPrice = 10000, IsActive = true);
          PricebookEntry standardPrice6 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = p6.Id, UnitPrice = 10000, IsActive = true);
          PricebookEntry standardPrice15 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = p15.Id, UnitPrice = 10000, IsActive = true);
          insert standardPrice;
          insert standardPrice2;
          insert standardPrice4;
          insert standardPrice5;
          insert standardPrice6;
          insert standardPrice15;
        
          Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
          insert customPB;
        
          PricebookEntry customPrice = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = p.Id, UnitPrice = 12000, IsActive = true);
          insert customPrice;
          PricebookEntry customPrice2 = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = p2.Id, UnitPrice = 12000, IsActive = true);
          insert customPrice2;
          PricebookEntry customPrice4 = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = p4.Id, UnitPrice = 12000, IsActive = true);
          insert customPrice4;
          PricebookEntry customPrice5 = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = p5.Id, UnitPrice = 12000, IsActive = true);
          insert customPrice5;
          PricebookEntry customPrice6 = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = p6.Id, UnitPrice = 12000, IsActive = true);
          insert customPrice6;
          PricebookEntry customPrice15 = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = p15.Id, UnitPrice = 12000, IsActive = true);
          insert customPrice15;
          
        
        Quote masterQuote1_New = new Quote();
        masterQuote1_New.OpportunityId = opp.Id;
        masterQuote1_New.Name = 'Master Quote 1';
        masterQuote1_New.SWAN_Pricing_Structure__c = 'HH 3 Rate EW';
        masterQuote1_New.SWAN_Payment_Method_and_Term__c = 'Direct Debit - 14 Days';
        masterQuote1_New.SWAN_Offer_Start_Date__c = Date.today();
        masterQuote1_New.SWAN_Number_of_Service_Points__c = 2;
        masterQuote1_New.Status = 'Draft';
        masterQuote1_New.SWAN_Quote_for_Fuel_Type__c='Electricity';
        masterQuote1_New.SWAN_Passthrough_Option__c='DUoS';
        masterQuote1_New.SWAN_Pricing_User__c=userinfo.getuserid();
        masterQuote1_New.pricebook2Id=customPB.id;
        insert masterQuote1_New;
        
        QuoteLineItem qli_for_Master = new QuoteLineItem();
          qli_for_Master.QuoteId = masterQuote1_New.id;
          qli_for_Master.PriceBookEntryId=customPrice.id;
          qli_for_Master.Product2Id = p.id;
          qli_for_Master.Quantity=1;
          qli_for_Master.UnitPrice=10;
          insert qli_for_Master;
          
        Quote masterQuote2_New = new Quote();
        masterQuote2_New.OpportunityId = opp.Id;
        masterQuote2_New.Name = 'Master Quote 2';
        masterQuote2_New.SWAN_Pricing_Structure__c = 'HH 4 Rate Summer Winter';
        masterQuote2_New.SWAN_Payment_Method_and_Term__c = 'Direct Debit - 14 Days';
        masterQuote2_New.SWAN_Offer_Start_Date__c = Date.today();
        masterQuote2_New.SWAN_Number_of_Service_Points__c = 2;
        masterQuote2_New.Status = 'Draft';
        masterQuote2_New.SWAN_Quote_for_Fuel_Type__c='Electricity';
        masterQuote2_New.SWAN_Passthrough_Option__c='AAHEDC';
        masterQuote2_New.pricebook2Id=customPB.id;
        masterQuote2_New.SWAN_Pricing_User__c=userinfo.getuserid();
        insert masterQuote2_New;
        
        QuoteLineItem qli_for_Master2 = new QuoteLineItem();
          qli_for_Master2.QuoteId = masterQuote2_New.id;
          qli_for_Master2.PriceBookEntryId=customPrice.id;
          qli_for_Master2.Product2Id = p.id;
          qli_for_Master2.Quantity=1;
          qli_for_Master2.UnitPrice=10;
          insert qli_for_Master2;
          
        vlocity_cmt__Premises__c premise = new vlocity_cmt__Premises__c();
        insert premise;
        
        vlocity_cmt__ServicePoint__c servicePoint = new vlocity_cmt__ServicePoint__c();
        servicePoint.SWAN_Formula_Year_Annual_Quantity__c = 12331;
        servicePoint.SWAN_Formula_Year_Offtake_Quantity__c = 3321;
        servicePoint.vlocity_cmt__ServicePointNumber__c = '1231231231';
        servicePoint.vlocity_cmt__PremisesId__c = premise.id;
        servicePoint.SWAN_Product_Class__c = '3';
        servicePoint.SWAN_Measurement_Class__c='C';
        insert servicePoint;
        
        Quote childQuote = new Quote();
        childQuote.vlocity_cmt__ParentQuoteId__c = masterQuote1_New.id;
        childQuote.vlocity_cmt__DefaultServicePointId__c= servicePoint.id;
        childQuote.SWAN_Service_Point_Start_Date__c = date.today();
        childQuote.name = 'child quote';
        childQuote.OpportunityId = opp.id;
        childQuote.pricebook2Id=customPB.id;
        insert childQuote;
        
        //
        Quote childQuote2 = new Quote();
        childQuote2.vlocity_cmt__ParentQuoteId__c = masterQuote2_New.id;
        childQuote2.vlocity_cmt__DefaultServicePointId__c= servicePoint.id;
        childQuote2.SWAN_Service_Point_Start_Date__c = date.today();
        childQuote2.name = 'child quote';
        childQuote2.OpportunityId = opp.id;
        childQuote2.pricebook2Id=customPB.id;
        insert childQuote2;
        //
        
        QuoteLineItem qli = new QuoteLineItem();
          qli.QuoteId = childQuote.id;
          qli.Product2Id = p.id;
          qli.PriceBookEntryId=customPrice.id;
          qli.Quantity=1;
          qli.UnitPrice=10;
          qli.SWAN_needToReset__c=true;
          insert qli;
          
          QuoteLineItem qli2 = new QuoteLineItem();
          qli2.QuoteId = childQuote.id;
          qli2.Product2Id = p2.id;
          qli2.PriceBookEntryId=customPrice2.id;
          qli2.Quantity=1;
          qli2.UnitPrice=10;
          qli2.SWAN_needToReset__c=true;
          qli2.vlocity_cmt__RecurringCharge__c = 234.567;
          insert qli2;
          
          /*QuoteLineItem qli3 = new QuoteLineItem();
          qli3.QuoteId = childQuote.id;
          qli3.Product2Id = p3.id;
          qli3.SWAN_UnitRate__c=102.987;
          qli3.PriceBookEntryId=customPrice.id;
          qli3.Quantity=1;
          qli3.UnitPrice=10;
          qli3.SWAN_needToReset__c=true;
          insert qli3;*/
          
          QuoteLineItem qli4 = new QuoteLineItem();
          qli4.QuoteId = childQuote.id;
          qli4.Product2Id = p4.id;
          qli4.SWAN_UnitRate__c=102.987;
          qli4.PriceBookEntryId=customPrice4.id;
          qli4.Quantity=1;
          qli4.UnitPrice=10;
          qli4.SWAN_needToReset__c=true;
          insert qli4;
          
          QuoteLineItem qli5 = new QuoteLineItem();
          qli5.QuoteId = childQuote.id;
          qli5.Product2Id = p5.id;
          qli5.SWAN_UnitRate__c=102.987;
          qli5.PriceBookEntryId=customPrice5.id;
          qli5.Quantity=1;
          qli5.UnitPrice=10;
          qli5.SWAN_needToReset__c=true;
          insert qli5;
          
          QuoteLineItem qli6 = new QuoteLineItem();
          qli6.QuoteId = childQuote.id;
          qli6.Product2Id = p6.id;
          qli6.SWAN_UnitRate__c=102.987;
          qli6.PriceBookEntryId=customPrice6.id;
          qli6.Quantity=1;
          qli6.UnitPrice=10;
          qli6.SWAN_needToReset__c=true;
          insert qli6;
          
          QuoteLineItem qli15 = new QuoteLineItem();
          qli15.QuoteId = childQuote.id;
          qli15.Product2Id = p15.id;
          qli15.SWAN_UnitRate__c=102.987;
          qli15.vlocity_cmt__UsageUnitPrice__c=102.987;
          qli15.PriceBookEntryId=customPrice15.id;
          qli15.Quantity=1;
          qli15.UnitPrice=10;
          qli15.SWAN_needToReset__c=true;
          insert qli15;
          
        SWAN_Offer_Pack__c offerPack = new SWAN_Offer_Pack__c();
        offerPack.Contact__c = con.id;
        offerPack.SWAN_Opportunity__c = opp.id;
        insert offerPack;
        
        List<SWAN_Offer_Pack_Quote__c> listOfferPackQuote = new List<SWAN_Offer_Pack_Quote__c>();
        SWAN_Offer_Pack_Quote__c opq1 = new SWAN_Offer_Pack_Quote__c();
        opq1.SWAN_Offer_Pack__c = offerPack.id;
        opq1.SWAN_Quote__c = masterQuote1_New.id;
        listOfferPackQuote.add(opq1);
        
        SWAN_Offer_Pack_Quote__c opq2 = new SWAN_Offer_Pack_Quote__c();
        opq2.SWAN_Offer_Pack__c = offerPack.id;
        opq2.SWAN_Quote__c = masterQuote2_New.id;
        listOfferPackQuote.add(opq2);
        
        insert listOfferPackQuote;
        
        system.debug('~~~~~'+masterQuote1_New.Status);
        masterQuote1_New.Status = 'Selected';
        update masterQuote1_New;
        system.debug('~~~~~'+masterQuote1_New.Status);
        
        Contract con1 = new Contract();
        con1.vlocity_cmt__QuoteId__c = masterQuote1_New.id;
        con1.AccountId = acc.Id;
        con1.status = 'Draft';
        insert con1;
        
        vlocity_cmt__ContractLineItem__c CLI = new vlocity_cmt__ContractLineItem__c();
        CLI.vlocity_cmt__ContractId__c = con1.id;
        CLI.SWAN_Service_Point__c = servicePoint.id;
		CLI.vlocity_cmt__EffectiveStartDate__c = system.today();
        CLI.vlocity_cmt__EffectiveEndDate__c = system.today().addYears(2);
		CLI.SWAN_Quote__c=childQuote.id;
        insert CLI;
        
        con1.vlocity_cmt__OpportunityId__c = opp.Id;
        con1.status = 'Contract Signed';
        update con1;
        
        //
        Contract con2 = new Contract();
        con2.vlocity_cmt__QuoteId__c = masterQuote2_New.id;
        con2.AccountId = acc.Id;
        con2.status = 'Draft';
        insert con2;
        
        vlocity_cmt__ContractLineItem__c CLI2 = new vlocity_cmt__ContractLineItem__c();
        CLI2.vlocity_cmt__ContractId__c = con2.id;
        CLI2.SWAN_Service_Point__c = servicePoint.id;
		CLI2.vlocity_cmt__EffectiveStartDate__c = system.today();
        CLI2.vlocity_cmt__EffectiveEndDate__c = system.today().addYears(2);
		CLI2.SWAN_Quote__c=childQuote2.id;
        insert CLI2;
        
        con2.vlocity_cmt__OpportunityId__c = opp.Id;
        con2.status = 'Contract Signed';
        update con2;
        //
    }   
    
    @isTest
    public static void childQuoteInsertTest()
    {
        createStaticDataWithOfferPack();
        createElecStaticDataWithOfferPack();
        test.startTest();
        createElecStaticDataWithOfferPack2();
        test.stopTest();
    }
    
     @isTest
    public static void assetCreationTest()
    {
        createStaticDataWithOfferPack();
        List<Contract> conIds = new List<Contract>();
        for(Contract con : [Select id from contract])
        {
           conIds.add(con);
        }
        test.startTest();
        SWAN_Asset_Creation.createAsset(conIds);
        test.stopTest();
    }
}