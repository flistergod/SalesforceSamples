@isTest
private class LAN_BatchPartnerDiscountTest {
	@testSetup 
    static void setup() {
        Account account = new Account(name='Account Test', 
                billingcity='New York', billingcountry='USA');
        insert account;
        
        RecordType amendAndRenewalRecordType = [Select Id, DeveloperName from RecordType where DeveloperName = 'LAN_Renewal_with_Up_Sell_Cross_Sell'];
        RecordType renewalRecordType = [Select Id, DeveloperName from RecordType where DeveloperName = 'LAN_Renewal'];
        
        Opportunity renewalOppty = new Opportunity(name='Renewal Oppty Account Test', StageName='Qualify', AccountId=account.Id,RecordTypeId=renewalRecordType.Id,
                            CloseDate=System.Today(), Amount=1000);
        insert renewalOppty;   
        
        SBQQ__Quote__c renewalQuote = new SBQQ__Quote__c();
        renewalQuote.SBQQ__Status__c = 'Draft';
        renewalQuote.SBQQ__Opportunity2__c = renewalOppty.Id;
        
        insert renewalQuote;
        
        Contract renewalContract = new Contract();
        renewalContract.AccountId = account.Id;
        renewalContract.Name = 'Contract Renewal';
        renewalContract.SBQQ__RenewalOpportunity__c = renewalOppty.Id;
		renewalContract.SBQQ__Quote__c = renewalQuote.Id;
        renewalContract.StartDate = Date.parse('10/10/2020');
        renewalContract.LAN_Days_before_End_Date_Renewal_Quote__c = 5;
        
        insert renewalContract;
        
        Contract amendContract = new Contract();
        amendContract.AccountId = account.Id;
        amendContract.Name = 'Contract Amend';
        renewalContract.StartDate = Date.parse('10/10/2020');
        renewalContract.SBQQ__AmendmentStartDate__c	 = Date.parse('10/10/2020');
        renewalContract.LAN_Days_before_End_Date_Renewal_Quote__c = 5;
        
        insert amendContract;
        
        List<Opportunity> oppties = new List<Opportunity>();
        
        Opportunity amendOppty = new Opportunity(name='Amend Oppty Account Test', StageName='Qualify', AccountId=account.Id,RecordTypeId=amendAndRenewalRecordType.Id,
                            CloseDate=System.Today(),LAN_Contract_Restart_with_Up_Sell__c=true,SBQQ__AmendedContract__c=amendContract.Id, SBQQ__RenewedContract__c=renewalContract.Id);
        insert amendOppty;

        
        System.debug('quote');
        System.debug(renewalQuote);
        // insert 10 oppties
        for (integer i = 0; i < 10; i++) {
            if(i == 9) {
                oppties.add(new Opportunity(name='Oppty Account Test' + i, StageName='Qualify',RecordTypeId=amendAndRenewalRecordType.Id, 
                	CloseDate=System.Today(),AccountId=account.Id,SBQQ__AmendedContract__c=amendContract.Id));
            }
            else {
            	oppties.add(new Opportunity(name='Oppty Account Test' + i, StageName='Qualify',RecordTypeId=renewalRecordType.Id, 
                	CloseDate=System.Today(),AccountId=account.Id,SBQQ__RenewedContract__c=renewalContract.Id));
            }
        }
        
        insert oppties;
        
        System.debug('oppties');
        System.debug(oppties);
        
        List<Batch_Queue__c> batchQueues = new List<Batch_Queue__c>();
        for (integer i = 0; i < 10; i++) {
            batchQueues.add(new Batch_Queue__c(Type__c='Batch - Partner Discount', Status__c='To be recalculated',Opportunity__c=oppties[i].Id));
        }
        insert batchQueues;
    }
    
    static testmethod void testLAN_BatchPartnerDiscount() {        
        Test.startTest();
        LAN_BatchPartnerDiscount batchPD = new LAN_BatchPartnerDiscount();
        Id batchId = Database.executeBatch(batchPD);
        Test.stopTest();
        // after the testing stops, assert records were updated properly
        System.assertEquals(10, [select count() from Batch_Queue__c where Status__c = 'To be recalculated']);
		
    }
    
    static testmethod void testScheduledBatchPartnerDiscount() {
   		Test.startTest();

        String CRON_EXP = '0 0 0 3 9 ? 2022';
 
      	// Schedule the test job
 
      	String jobId = System.schedule('testScheduleBatchPartnerDiscount',CRON_EXP, new LAN_BatchPartnerDiscount());
 
      	// Get the information from the CronTrigger API object
      	CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
         		FROM CronTrigger WHERE id = :jobId];
 
        // Verify the expressions are the same
        System.assertEquals(CRON_EXP, ct.CronExpression);
        
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        
 
       	Test.stopTest();
 
   }
}