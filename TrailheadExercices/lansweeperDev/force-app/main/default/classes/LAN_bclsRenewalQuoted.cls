public with sharing class LAN_bclsRenewalQuoted implements Database.Batchable<SObject>, Database.Stateful {
    //TODO: date frame based on end date and days before end date field
    //private final String STRQUERY = 'SELECT Id FROM Contract WHERE EndDate >= TODAY AND LAN_Renewal_Quote_Creation_Day__c <= TODAY AND SBQQ__RenewalQuoted__c = FALSE AND SBQQ__RenewalOpportunity__r.SBQQ__PrimaryQuote__c = NULL AND SBQQ__RenewalOpportunity__r.IsClosed = FALSE ORDER BY LAN_Renewal_Quote_Creation_Day__c ASC';
    private final String STRQUERY = 'SELECT Id FROM Contract WHERE EndDate >= LAST_N_DAYS:' + Label.LAN_Days_before_End_Date_Renewal_Quote + ' AND LAN_Renewal_Quote_Creation_Day__c <= TODAY AND SBQQ__RenewalOpportunity__r.SBQQ__PrimaryQuote__c = NULL AND SBQQ__RenewalOpportunity__r.IsClosed = FALSE AND (LAN_Status__c=\'Active\' OR LAN_Status__c=\'Expired\') ORDER BY LAN_Renewal_Quote_Creation_Day__c ASC';
    private List<LAN_wSaveResult> lstFailures;
    private String genericError;
    
    public LAN_bclsRenewalQuoted() {
        lstFailures = new List<LAN_wSaveResult>();
        genericError = '';
    }

    public Database.QueryLocator start(Database.BatchableContext info) {
        return Database.getQueryLocator(STRQUERY);
    }

    public void execute(Database.BatchableContext info, List<SObject> lstScope) {
        List<Contract> lstUpdate = new List<Contract>();
        // Batch size must be 1 due to the CPQ setup of async
        System.Debug('LAN_bclsRenewalQuoted:execute --> lstFailures: ' + lstFailures.size());
        System.Debug('LAN_bclsRenewalQuoted:execute --> lstFailures: ' + lstFailures);

        for(SObject rec : lstScope) {
            System.Debug('LAN_bclsRenewalQuoted:execute --> rec: ' + rec);

            Contract c = (Contract) rec;
            c.SBQQ__RenewalQuoted__c = TRUE;
            lstUpdate.add(c);
        }

        try {
            List<Database.SaveResult> lstResult = Database.update(lstUpdate, false);

            for(Database.SaveResult sr : lstResult) {
                if(!sr.isSuccess()) {
                    System.DEbug('LAN_bclsRenewalQuoted:execute --> sr: ' + sr.getId() + ' ' + sr.getErrors());
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
            errorEmail.setSubject('LAN_bclsRenewalQuoted contains errors! Please review');

            String emailBody = 'Batch job LAN_bclsRenewalQuoted failed with the following issues: \n\n';

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