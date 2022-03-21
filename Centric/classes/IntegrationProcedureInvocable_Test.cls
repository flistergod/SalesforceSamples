@isTest
public class IntegrationProcedureInvocable_Test{

    public static testMethod void callIntegrationProcedure()
    {
        Account acc = new Account();
        acc.Name = 'Test Opp';
		acc.SWAN_Customer_Segment__c = 'I&C';
        acc.SWAN_Micro_Business_Selection__c = 'Non_Micro_Business';
        insert acc;
        
        opportunity opp = new Opportunity();
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
        
        Quote masterQuote1 = new Quote();
        masterQuote1.OpportunityId = opp.Id;
        masterQuote1.Name = 'Master Quote 1';
        masterQuote1.SWAN_Pricing_Structure__c = 'Site Specific With Standing Charge';
        masterQuote1.SWAN_Payment_Method_and_Term__c = 'Direct Debit - 14 Days';
        masterQuote1.SWAN_Payment_Method__c = 'Direct Debit';
        masterQuote1.SWAN_Payment_Term__c = '14 Days';
        masterQuote1.SWAN_Offer_Start_Date__c = Date.today();
        masterQuote1.SWAN_Number_of_Service_Points__c = 2;
        
        insert masterQuote1;
        
        Contract contr = new Contract();
        contr.AccountId = acc.Id;
        contr.Status = 'Draft';
        contr.vlocity_cmt__QuoteId__c = masterQuote1.id;
        contr.StartDate = Date.today();
        contr.EndDate = Date.today().adddays(365);
        insert contr;
        
        IntegrationProcedureInvocable.IntegrationProcedureInput Ip = new IntegrationProcedureInvocable.IntegrationProcedureInput();
        Ip.IPName = 'BGGorillaPricingEngine_BGCheckCommotity';
        Ip.CommodityObject = 'Quote';
        Ip.SkipUpdate = 'Y';
        Ip.ContextId = masterQuote1.Id;
        Ip.ContractId = contr.Id;
        
        List<IntegrationProcedureInvocable.IntegrationProcedureInput> ipList = new List<IntegrationProcedureInvocable.IntegrationProcedureInput>();
        ipList.add(Ip);
        IntegrationProcedureInvocable.runIntegrationServiceInvocable(ipList);
        
    }
}