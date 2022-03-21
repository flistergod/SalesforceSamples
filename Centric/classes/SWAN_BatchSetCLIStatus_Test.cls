@isTest
public with sharing class SWAN_BatchSetCLIStatus_Test {

    @TestSetup
    static void createTestData(){

        Account acc = new Account();
        acc.Name = 'Test Acc';
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

        con1.status = 'Contract Signed';
        update con1;

        con1.status = 'Contract Live';
        con1.Name = 'primary';
        update con1;

        Contract con2 = new Contract();
        con2.vlocity_cmt__QuoteId__c = masterQuote1.id;
        con2.AccountId = acc.Id;
        con2.status = 'Draft';
        con2.SWAN_Offer_Start_Date__c = date.today();
        insert con2;

        con2.status = 'Contract Signed';
        update con2;

        con2.status = 'Contract Counter Signed';
        update con2;

        Contract con3 = new Contract();
        con3.vlocity_cmt__QuoteId__c = masterQuote1.id;
        con3.AccountId = acc.Id;
        con3.status = 'Draft';
        con3.SWAN_Offer_Start_Date__c = date.today().addDays(-60);
        con3.SWAN_Offer_End_Date__c = date.today();
        insert con3;

        con3.status = 'Contract Signed';
        update con3;

        con3.status = 'Contract Live';
        update con3;
          
        
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
    }

    @isTest
    static void testNoData(){
        
        Final List<String> LIST_OF_STATUS = new List<String>{'Active','Inactive','Terminated'};
        
        Database.delete([Select Id from vlocity_cmt__ContractLineItem__c]);

        Date todaysDate = System.today();
        
        Test.startTest();
        Database.executeBatch(new SWAN_BatchSetCLIStatus(false), 2000);
        Test.stopTest();

        System.assert([Select Id, vlocity_cmt__LineStatus__c, vlocity_cmt__EffectiveEndDate__c, vlocity_cmt__EffectiveStartDate__c, SWAN_Service_Point_Start_Date__c, SWAN_Service_Point_End_Date__c, SWAN_Service_Point__c from vlocity_cmt__ContractLineItem__c where vlocity_cmt__LineStatus__c in :LIST_OF_STATUS AND (vlocity_cmt__EffectiveEndDate__c = :todaysDate OR vlocity_cmt__EffectiveStartDate__c = :todaysDate)].size()==0);
    }

    @isTest
    static void massTestData(){
        
        Final List<String> LIST_OF_STATUS = new List<String>{'Active','Inactive','Terminated'};
        
        Date todaysDate = System.today();

        System.assert([Select Id, vlocity_cmt__LineStatus__c, vlocity_cmt__EffectiveEndDate__c, vlocity_cmt__EffectiveStartDate__c, SWAN_Service_Point_Start_Date__c, SWAN_Service_Point_End_Date__c, SWAN_Service_Point__c from vlocity_cmt__ContractLineItem__c where vlocity_cmt__LineStatus__c in :LIST_OF_STATUS AND (DAY_ONLY(vlocity_cmt__EffectiveEndDate__c) = :todaysDate OR DAY_ONLY(vlocity_cmt__EffectiveStartDate__c) = :todaysDate)].size()==200);
        
        Test.startTest();
        Database.executeBatch(new SWAN_BatchSetCLIStatus(false), 2000);
        Database.executeBatch(new SWAN_BatchSetCLIStatus(true), 2000);
        Test.stopTest();
    }
    
    
    @isTest
    static void remoteSWANSetCLIStatus(){
        
        Final List<String> LIST_OF_STATUS = new List<String>{'Active','Inactive','Terminated'};
        
        Date todaysDate = System.today();
		Map<String, Object> inputMap = new  Map<String, Object>() ;
        Map<String, Object> outputMap = new  Map<String, Object>() ;
        Map<String, Object> options = new  Map<String, Object>() ;
        
        System.assert([Select Id, vlocity_cmt__LineStatus__c, vlocity_cmt__EffectiveEndDate__c, vlocity_cmt__EffectiveStartDate__c, SWAN_Service_Point_Start_Date__c, SWAN_Service_Point_End_Date__c, SWAN_Service_Point__c from vlocity_cmt__ContractLineItem__c where vlocity_cmt__LineStatus__c in :LIST_OF_STATUS AND (DAY_ONLY(vlocity_cmt__EffectiveEndDate__c) = :todaysDate OR DAY_ONLY(vlocity_cmt__EffectiveStartDate__c) = :todaysDate)].size()==200);
        
        Test.startTest();
        SWAN_SetCLIStatus.triggerBatchScheduling(false,null);
        SWAN_SetCLIStatus.triggerBatchScheduling(true,null);
        Test.stopTest();
    }

    @isTest
    static void testSWAN_BatchSetContractStatus(){
        
        Map<String, Object> inputMap = new  Map<String, Object>() ;
        Map<String, Object> outputMap = new  Map<String, Object>() ;
        Map<String, Object> options = new  Map<String, Object>() ;

        Test.startTest();
        Contract ct =[Select id , Status from Contract where Name = 'primary'];
        ct.SWAN_Offer_End_Date__c = System.today();
        ct.status='Contract Ended';
        update ct;
        SWAN_SetCLIStatus.triggerBatchScheduling(false,null);
        SWAN_SetCLIStatus.triggerBatchScheduling(true,null);
        Test.stopTest();

        
    }
    
    @isTest
    static void testConstructors(){
        new SWAN_BatchSetContractStatus();
        new SWAN_BatchSetCLIStatus();
    }

}