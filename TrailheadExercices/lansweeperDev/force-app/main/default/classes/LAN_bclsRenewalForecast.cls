public with sharing class LAN_bclsRenewalForecast implements Database.Batchable<sObject>, Database.Stateful {
    private static String STRQUERY = 'SELECT Id, SBQQ__RenewalForecast__c, EndDate, SBQQ__RenewalOpportunity__c FROM Contract WHERE EndDate >= TODAY AND CreatedDate = LAST_N_DAYS:' + Label.LAN_Days_before_End_Date_Renewal_Forecast + ' AND SBQQ__RenewalOpportunity__c = NULL ORDER BY EndDate ASC';
    @testVisible private List<LAN_wSaveResult> lstFailures;
    @testVisible private String genericError;

    public LAN_bclsRenewalForecast() {
        lstFailures = new List<LAN_wSaveResult>();
        genericError = '';
    }

    public Database.QueryLocator start(Database.BatchableContext info) {
        return Database.getQueryLocator(STRQUERY);
    }

    public void execute(Database.BatchableContext info, List<sObject> lstScope) {
        List<Contract> lstUpdate = new List<Contract>();

        for(sObject rec : lstScope) {
            System.Debug('LAN_bclsRenewalForecast:execute --> rec: ' + rec);

            Contract c = (Contract) rec;
            c.SBQQ__RenewalForecast__c = TRUE;
            lstUpdate.add(c);
        } 
        
        try {
            List<Database.SaveResult> lstResult = Database.update(lstUpdate, false);

            for(Database.SaveResult sr : lstResult) {
                if(!sr.isSuccess()) {
                    System.DEbug('LAN_bclsRenewalForecast:execute --> sr: ' + sr.getId() + ' ' + sr.getErrors());
                    LAN_wSaveResult wsr = new LAN_wSaveResult(sr.getId(), null);
                    String errorMsg;

                    for(Database.Error err : sr.getErrors()) {
                        errorMsg += err.getStatusCode() + ' ' + err.getMessage() + ' ' + err.getFields();
                    }

                    wsr.errorMessage = errorMsg;
                    lstFailures.add(wsr);
                }
            }
        } catch(Exception e) {
            genericError += e.getMessage() + ' ' + e.getStackTraceString();
        }
    }

    public void finish(Database.BatchableContext info) {
        if(genericError != '' || lstFailures.size() > 0) {
            // Errors have happened. Send our an error email containing the details:
            AsyncApexJob job = [SELECT Status, NumberOfErrors, JobItemsProcessed, TotalJobItems FROM AsyncApexJob WHERE Id = :info.getJobId()];
            List<User> lstReceivers = [SELECT Email FROM User WHERE LAN_receiveBatchExceptions__c = TRUE];

            Messaging.SingleEmailMessage errorEmail = new Messaging.SingleEmailMessage();
            List<String> lstEmails = new List<String>();

            for(User u : lstReceivers) {
                lstEmails.add(u.Email);
            }

            errorEmail.setToAddresses(lstEmails);
            errorEmail.setSubject('LAN_bclsRenewalForecast contains errors! Please review');

            String emailBody = 'Batch job LAN_bclsRenewalForecast failed with the following issues: \n\n';

            if(genericError != '') emailBody += genericError + '\n\n\n';
            if(lstFailures.size() > 0) {
                for(LAN_wSaveResult sr : lstFailures) {
                    emailBody += 'Record Id: ' + sr.recordId + ' --> Errors: \n';
                    emailBody += sr.errorMessage + '\n';
                    emailBody += '\n';
                }
            }

            errorEmail.setPlainTextBody(emailBody);
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{errorEmail});
        }
    }
}