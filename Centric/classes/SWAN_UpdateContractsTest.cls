@isTest
public with sharing class SWAN_UpdateContractsTest {

    @TestSetup
    static void createTestData(){

        Account acc = new Account();
        acc.Name = 'I&C Test Acc';
        acc.SWAN_Customer_Segment__c = 'I&C';
        acc.SWAN_Micro_Business_Selection__c = 'Non_Micro_Business';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.Name = 'Test Opp';
        opp.StageName = 'Prospecting';
        opp.CloseDate = date.today();
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
    
        List<Quote> masterQuoteList = new List<Quote>();
    
        Quote masterQuote1 = new Quote();
        masterQuote1.OpportunityId = opp.Id;
        masterQuote1.Name = 'Master Quote 1';
        masterQuote1.SWAN_Pricing_Structure__c = 'Site Specific With Standing Charge';
        masterQuote1.SWAN_Payment_Method_and_Term__c = 'Direct Debit - 14 Days';
        masterQuote1.SWAN_Offer_Start_Date__c = Date.today(); 
        masterQuote1.SWAN_Offer_End_Date__c = date.today()+1000;
        masterQuote1.SWAN_Number_of_Service_Points__c = 2;
        masterQuote1.Status = 'Draft';
        masterQuote1.SWAN_Service_Point_Start_Date__c = System.today();
        masterQuoteList.add(masterQuote1);
        
        Quote masterQuote2 = new Quote();
        masterQuote2.OpportunityId = opp.Id;
        masterQuote2.Name = 'Master Quote 2';
        masterQuote2.SWAN_Pricing_Structure__c = 'Site Specific Without Standing Charge';
        masterQuote2.SWAN_Payment_Method_and_Term__c = 'Direct Debit - 14 Days';
        masterQuote2.SWAN_Offer_Start_Date__c = Date.today();
        masterQuote2.SWAN_Number_of_Service_Points__c = 2;
        masterQuote2.Status = 'Draft';
        masterQuote2.SWAN_Service_Point_Start_Date__c = System.today();
        masterQuoteList.add(masterQuote2);
        insert masterQuoteList;
        
        List<vlocity_cmt__Premises__c> lstPremises = new List<vlocity_cmt__Premises__c>();

        for(Integer i = 0; i < 200; i++){
            vlocity_cmt__Premises__c premise = new vlocity_cmt__Premises__c(Name = 'Prem'+i);
            lstPremises.add(premise);
        }
        insert lstpremises;
        
        List<Quote> lstQuote = [Select Id, Name from Quote];
        for(Quote q : lstQuote){
            if(q.Name.equalsIgnoreCase('Master Quote 1')){
                masterQuote1.Id = q.Id;
            }else{
                masterQuote2.Id = q.Id;
            }
        }

        Map<String, Id> mapPremiseIdByName = new Map<String, Id>();
        for(vlocity_cmt__Premises__c prem : [Select id, Name from vlocity_cmt__Premises__c]){
            mapPremiseIdByName.put(prem.Name, prem.Id);
        }

        List<vlocity_cmt__ServicePoint__c> lstServicePoints = new List<vlocity_cmt__ServicePoint__c>();

        for(Integer i = 0; i < 200; i++){
            vlocity_cmt__ServicePoint__c servicePoint = new vlocity_cmt__ServicePoint__c();
            servicePoint.SWAN_Formula_Year_Annual_Quantity__c = 12331;
            servicePoint.SWAN_Formula_Year_Offtake_Quantity__c = 3321;
            servicePoint.vlocity_cmt__ServicePointNumber__c = '1231231231';
            servicePoint.vlocity_cmt__PremisesId__c = mapPremiseIdByName.get('Prem'+i);
            servicePoint.SWAN_Product_Class__c = '3';
            servicePoint.Annual_Quantity__c = 10;
            servicePoint.Name = 'SP'+i;
            lstServicePoints.add(servicePoint);
        }

        insert lstServicePoints;

        Map<String, Id> mapSPIdByName = new Map<String, Id>();
        for(vlocity_cmt__ServicePoint__c sp : [Select id, Name from vlocity_cmt__ServicePoint__c]){
            mapSPIdByName.put(sp.Name, sp.Id);
        }
        

        List<Quote> lstChildQuotes = new List<Quote>();

        for(Integer i = 0; i < 200; i++){

            Quote childQuote = new Quote();
            childQuote.SWAN_Parent_Quote__c = masterQuote1.id;
            childQuote.SWAN_Service_Point__c = mapSPIdByName.get('SP'+i);
            childQuote.SWAN_Service_Point_Start_Date__c = date.today();
            
            childQuote.name = 'CQ'+i;
            childQuote.OpportunityId = opp.id;

            lstChildQuotes.add(childQuote);
        }

        insert lstChildQuotes;
    
        Map<String, Id> mapChildQuotesIdByName = new Map<String, Id>();
        for(Quote q : [Select id, Name from Quote]){
            mapChildQuotesIdByName.put(q.Name, q.Id);
        }

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

        masterQuote1.Status = 'Selected';
        update masterQuote1;
        
        Contract con1 = new Contract();
        con1.vlocity_cmt__QuoteId__c = masterQuote1.id;
        con1.AccountId = acc.Id;
        con1.status = 'Draft';
        con1.SWAN_Offer_Start_Date__c = date.today();
        insert con1;

        Contract con2 = new Contract();
        con2.vlocity_cmt__QuoteId__c = masterQuote1.id;
        con2.AccountId = acc.Id;
        con2.status = 'Draft';
        con2.SWAN_Offer_Start_Date__c = date.today();
        insert con2;
        
        Contract con3 = new Contract();
        con3.vlocity_cmt__QuoteId__c = masterQuote1.id;
        con3.AccountId = acc.Id;
        con3.status = 'Draft';
        con3.SWAN_Offer_Start_Date__c = date.today().addDays(-60);
        con3.SWAN_Offer_End_Date__c = date.today();
        insert con3;
        
        List<vlocity_cmt__ContractLineItem__c> lstCLI = new List<vlocity_cmt__ContractLineItem__c>();

        for(Integer i = 0; i < 200; i++){
            vlocity_cmt__ContractLineItem__c CLI = new vlocity_cmt__ContractLineItem__c();
            CLI.vlocity_cmt__ContractId__c = con1.id;
            CLI.vlocity_cmt__ServicePointId__c = mapSPIdByName.get('SP'+i);
            CLI.SWAN_Service_Point__c = mapSPIdByName.get('SP'+i);
            CLI.SWAN_Quote__c = mapChildQuotesIdByName.get('CQ'+i);

            DateTime systemDateTimeNow = System.now();

            if(Math.mod(i,3)==0){
                CLI.vlocity_cmt__EffectiveStartDate__c = systemDateTimeNow;
                CLI.vlocity_cmt__EffectiveEndDate__c = systemDateTimeNow.addDays(5);
                CLI.SWAN_Service_Point_End_Date__c = systemDateTimeNow.date();
                CLI.vlocity_cmt__LineStatus__c = 'Inactive';
            }else if(Math.mod(i,3)==1){
                CLI.vlocity_cmt__EffectiveStartDate__c = systemDateTimeNow.addDays(-5);
                CLI.vlocity_cmt__EffectiveEndDate__c = systemDateTimeNow;
                CLI.SWAN_Service_Point_End_Date__c = systemDateTimeNow.date();
                CLI.vlocity_cmt__LineStatus__c = 'Active';
            }else{
                CLI.vlocity_cmt__EffectiveStartDate__c = systemDateTimeNow.addDays(-5);
                CLI.vlocity_cmt__EffectiveEndDate__c = systemDateTimeNow;
                CLI.SWAN_Service_Point_End_Date__c = systemDateTimeNow.date().addDays(5);
                CLI.vlocity_cmt__LineStatus__c = 'Active';
            }

            lstCLI.add(CLI);
        }

        insert lstCLI;
        
        Id pricebookIdTest = Test.getStandardPricebookId();
        vlocity_cmt__PriceList__c prList = new vlocity_cmt__PriceList__c(vlocity_cmt__Code__c='12349870',vlocity_cmt__IsActive__c=true,vlocity_cmt__Pricebook2Id__c=pricebookIdTest,Name='I&C Price List');
        insert prList;
        
        insert new Segment_Values__c(Enterprise_Segment__c='ME',I_C_Segment__c='MU');
        Id recId = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('Site Addition Quote').getRecordTypeId();
        Id recId1 = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('Service Point Quote').getRecordTypeId();  
        
        Account acc1 = new Account();
        acc1.Name = 'Enterprise Test Acc';
        acc1.SWAN_Customer_Segment__c = 'Enterprise';
        acc1.SWAN_Micro_Business_Selection__c = 'Non_Micro_Business';
        insert acc1;
        
        Opportunity opp1 = new Opportunity();
        opp1.AccountId = acc1.Id;
        opp1.Name = 'Test Opp';
        opp1.StageName = 'Prospecting';
        opp1.CloseDate = date.today();
        insert opp1;
        
        Contact con12 = new Contact();
        con12.AccountId = acc1.Id;
        con12.lastName = 'Last Name';
        con12.firstname ='Fname';
        con12.MailingStreet='M street';
        con12.MailingPostalCode='M50 2HX';
        con12.SWAN_Mailing_Building_Name__c='Building name';
        con12.MailingCity = 'test City';
        insert con12;
        
        
        Product2 prod = new Product2(Name = 'BG_GAS', Family = 'Gas',ProductCode='BG_GAS');
            insert prod;
            
        Product2 prod_FixedPriceGas = new Product2(Name = 'Fixed Price Gas', ProductCode='BG_GAS');
            insert prod_FixedPriceGas;
            
        PriceBook2 pb = new PriceBook2();
        pb.name = 'Example Price Book';
        pb.IsActive = true;
        insert pb;
        Id pricebookId = Test.getStandardPricebookId();
    
        PricebookEntry standardPriceBookEntry = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prod_FixedPriceGas.Id,
            UnitPrice = 100.00,
            UseStandardPrice = false,
            IsActive = true
        );
    
        insert standardPriceBookEntry;  
        
        PriceBookEntry pbe = new PricebookEntry();
        pbe.product2Id = prod_FixedPriceGas.Id;
        pbe.Pricebook2Id = pb.Id;
        pbe.IsActive = true;
        pbe.Unitprice =0;
        pbe.UseStandardPrice = false;
        insert pbe;
        
        List<Quote> masterQuoteList1 = new List<Quote>();
        
        Quote masterQuote11 = new Quote();
        masterQuote11.OpportunityId = opp1.Id;
        masterQuote11.Name = 'Master Quote 1';
        masterQuote11.SWAN_Pricing_Structure__c = 'HH 2 Rate';
        masterQuote11.SWAN_Payment_Method_and_Term__c = 'Direct Debit - 14 Days';
        masterQuote11.SWAN_Offer_Start_Date__c = Date.today();
        masterQuote11.SWAN_Offer_End_Date__c = date.today()+100;
        masterQuote11.SWAN_Number_of_Service_Points__c = 2;
        masterQuote11.Status = 'Draft';
        masterQuote11.vlocity_cmt__PriceListId__c = prlist.id;
        masterQuote11.SWAN_Quote_for_Fuel_Type__c = 'Electricity';
        masterQuote11.SWAN_Quote_Type__c = 'Flex';
        masterQuoteList1.add(masterQuote11);
        
        Quote masterQuote21 = new Quote();
        masterQuote21.OpportunityId = opp1.Id;
        masterQuote21.Name = 'Master Quote 2';
        masterQuote21.SWAN_Pricing_Structure__c = 'HH 2 Rate';
        masterQuote21.SWAN_Payment_Method_and_Term__c = 'Direct Debit - 14 Days';
        masterQuote21.SWAN_Offer_Start_Date__c = Date.today();
        masterQuote21.SWAN_Number_of_Service_Points__c = 2;
        masterQuote21.Status = 'Draft';
        masterQuote21.SWAN_Quote_for_Fuel_Type__c = 'Electricity';
        masterQuoteList1.add(masterQuote21);
        insert masterQuoteList1;
        
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
        childQuote.SWAN_Parent_Quote__c = masterQuote1.id;
        childQuote.vlocity_cmt__DefaultServicePointId__c= servicePoint.id;
        childQuote.SWAN_Service_Point_Start_Date__c = date.today();
        childQuote.name = 'child quote';
        childQuote.OpportunityId = opp1.id;
        childQuote.pricebook2Id = pb.Id;
        childQuote.SWAN_Quote_for_Fuel_Type__c = 'Electricity';
        childQuote.SWAN_Quote_Type__c = 'Flex';
        insert childQuote;
        
        Quote childQuote1 = new Quote();
        childQuote1.recordTypeId=recId;
        childQuote1.Name = 'Site Addition Quote';
        childQuote1.SWAN_Site_Addition_Parent__c = masterQuote1.Id;
        childQuote1.SWAN_Offer_End_Date__c = date.today().adddays(90);
        childQuote1.OpportunityId = opp1.id;
        childQuote1.status='Draft';
        childQuote1.SWAN_Pricing_Structure__c = 'HH 2 Rate';
        childQuote1.SWAN_Quote_for_Fuel_Type__c = 'Electricity';
        childQuote1.SWAN_Quote_Type__c = 'Flex';
        insert childQuote1;
        
        Quote childQuote2 = new Quote();
        childQuote2.vlocity_cmt__ParentQuoteId__c = childQuote1.id;
        childQuote2.SWAN_Parent_Quote__c = childQuote1.Id;
        childQuote2.vlocity_cmt__DefaultServicePointId__c= servicePoint.id;
        childQuote2.SWAN_Service_Point_Start_Date__c = date.today();
        childQuote2.name = 'child quote2';
        childQuote2.OpportunityId = opp1.id;
        childQuote2.SWAN_Quote_for_Fuel_Type__c = 'Electricity';
        insert childQuote2;
                
        SWAN_Offer_Pack__c offerPack1 = new SWAN_Offer_Pack__c();
        offerPack1.Contact__c = con.id;
        offerPack1.SWAN_Opportunity__c = opp1.id;
        insert offerPack1;
        
        List<SWAN_Offer_Pack_Quote__c> listOfferPackQuote1 = new List<SWAN_Offer_Pack_Quote__c>();
        SWAN_Offer_Pack_Quote__c opq11 = new SWAN_Offer_Pack_Quote__c();
        opq11.SWAN_Offer_Pack__c = offerPack.id;
        opq11.SWAN_Quote__c = masterQuote1.id;
        listOfferPackQuote1.add(opq11);
        
        SWAN_Offer_Pack_Quote__c opq21 = new SWAN_Offer_Pack_Quote__c();
        opq21.SWAN_Offer_Pack__c = offerPack.id;
        opq21.SWAN_Quote__c = masterQuote2.id;
        listOfferPackQuote1.add(opq21);
        
        insert listOfferPackQuote1;
        
        system.debug('~~~~~'+masterQuote1.Status);
        masterQuote1.Status = 'Selected';
        update masterQuote1;
        system.debug('~~~~~'+masterQuote1.Status);
        
        Contract con11 = new Contract();
        con11.vlocity_cmt__QuoteId__c = masterQuote1.id;
        con11.AccountId = acc1.Id;
        con11.status = 'Draft';
        con11.recordtypeid = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Not countersigned Contract').getRecordTypeId();
        insert con11;
        
        vlocity_cmt__ContractLineItem__c CLI1 = new vlocity_cmt__ContractLineItem__c();
        CLI1.vlocity_cmt__ContractId__c = con1.id;
        CLI1.SWAN_Service_Point__c = servicePoint.id;
        CLI1.SWAN_Quote__c=childQuote.id;
        CLI1.vlocity_cmt__EffectiveStartDate__c = system.now();
        CLI1.vlocity_cmt__EffectiveEndDate__c = system.now().addYears(1);
        insert CLI1;
        
        vlocity_cmt__ContractLineItem__c CLI2 = new vlocity_cmt__ContractLineItem__c();
        CLI2.vlocity_cmt__ContractId__c = con1.id;
        CLI2.SWAN_Service_Point__c = servicePoint.id;
        cli2.SWAN_Quote__c=childQuote2.id;
        CLI2.vlocity_cmt__EffectiveStartDate__c = system.now();
        CLI2.vlocity_cmt__EffectiveEndDate__c = system.now().addYears(1);
        insert CLI2;
        
        vlocity_cmt__ContractLineItem__c CLI3 = new vlocity_cmt__ContractLineItem__c();
        CLI3.vlocity_cmt__ContractId__c = con1.id;
        CLI3.vlocity_cmt__Product2Id__c = prod.id;
        CLI3.vlocity_cmt__OriginalLineItemId__c=CLI1.id;
        CLI3.vlocity_cmt__EffectiveStartDate__c = system.now();
        CLI3.vlocity_cmt__EffectiveEndDate__c = system.now().addYears(1);
        insert CLI3;
        
        vlocity_cmt__ContractLineItem__c CLI4 = new vlocity_cmt__ContractLineItem__c();
        CLI4.vlocity_cmt__ContractId__c = con1.id;
        CLI4.vlocity_cmt__Product2Id__c = prod.id;
        CLI4.vlocity_cmt__OriginalLineItemId__c=CLI2.id;
        CLI4.vlocity_cmt__EffectiveStartDate__c = system.now();
        CLI4.vlocity_cmt__EffectiveEndDate__c = system.now().addYears(1);
        insert CLI4;
    }

    @isTest
    static void testContractsData(){
        
        Test.startTest();
        Id batchJobId = Database.executeBatch(new SWAN_UpdateContracts(), 100);
        Test.stopTest();
    }

}