@isTest
public class SWAN_ExtractServicePointsTest {
    
    
    @testSetup static void createBaseData() {
        
        Quote masterQuote = new Quote();
        Quote masterQuote1 = new Quote();
        Opportunity opp = new Opportunity();
        Contact con = new Contact();
        List<Id> spList = new List<Id>();
        
        Account acc = new Account();
        acc.Name = 'Test Acc';
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
        //insert con;
        
        List<Quote> masterQuoteList = new List<Quote>();
        
        //Quote masterQuote = new Quote();
        masterQuote1.OpportunityId = opp.Id;
        masterQuote1.Name = 'Master Quote 1';
        masterQuote1.SWAN_Pricing_Structure__c = 'Site Specific With Standing Charge';
        masterQuote1.SWAN_Payment_Method_and_Term__c = 'Direct Debit - 14 Days';
        masterQuote1.SWAN_Offer_Start_Date__c = Date.today();
        masterQuote1.SWAN_Number_of_Service_Points__c = 2;
        masterQuote1.Status = 'Draft';
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
        servicePoint.SWAN_Measurement_Class__c = 'C';
        servicePoint.SWAN_Measurement_Class_Ovrd__c = 'C';
        insert servicePoint;
        spList.add(servicePoint.id);
        
        Quote childQuote = new Quote();
        childQuote.vlocity_cmt__ParentQuoteId__c = masterQuote1.id;
        childQuote.vlocity_cmt__DefaultServicePointId__c = servicePoint.id;
        childQuote.SWAN_Service_Point_Start_Date__c = date.today();
        childQuote.name = 'child quote';
        childQuote.OpportunityId = opp.id;
        insert childQuote;
        
    }
    
    
    @isTest
    public static void extractSP(){
        
        List<Quote>  qt = new List<Quote>([Select Id, name  from Quote Where Name='Master Quote 1']);
        
        SWAN_ExtractServicePoints  sw = new SWAN_ExtractServicePoints();
        String methodName;
        Map<String, Object> inputMap =  new Map<String, Object>();
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> options;
        inputMap.put('ContextId', qt.get(0).Id);
        
        sw.invokeMethod('getServicePointsOfMasterQuote', inputMap,  outputMap, null);
        sw.invokeMethod('getServicePointsOfMasterQuoteElec', inputMap,  outputMap, null);
        
        //break into  exeption
        sw.invokeMethod(null, inputMap,  outputMap, null);

    }
    
}