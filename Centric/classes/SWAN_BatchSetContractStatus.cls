//Test class: SWAN_BatchSetCLIStatus_Test
global with sharing class SWAN_BatchSetContractStatus implements Database.Batchable<sObject>, Database.Stateful {

    private List<Database.SaveResult> lstSaveResults;
    private final static String PROFILE_NAME = 'System Administrator';
    private final static String LIVE_STATUS = 'Contract Live';
    private final static String EXPIRED_STATUS = 'Contract Ended';
    private final static String ACTIVE_STATUS = 'Active';
    private final static String COUNTER_SIGNED_STATUS = 'Contract Counter Signed';
    private final static String COUNTER_SIGNED_NOTREQUIRED_RECORD_TYPE = 'Counter Signature not Required';
    private final static String SIGNED_STATUS = 'Contract Signed';
    private final static String TERMINATED_STATUS = 'Contract Terminated';
    private final Boolean ACTIVATE_RECORDS;
    private Date todaysDate;

    public SWAN_BatchSetContractStatus() {
        lstSaveResults = new List<Database.SaveResult>();
    }

    public SWAN_BatchSetContractStatus(Boolean activateRecords) {
        lstSaveResults = new List<Database.SaveResult>();
        ACTIVATE_RECORDS = activateRecords;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        //Date todaysDate = System.today();
        //batch scheduled to run at 11:30 pm, if you move on to the next day, one day must be subtracted!!
        this.todaysDate  = (datetime.now().hour() != 23 && !ACTIVATE_RECORDS ? System.today().addDays(-1) : System.today() ) ;

        if(ACTIVATE_RECORDS){
            return Database.getQueryLocator('Select Id, Status, StartDate, EndDate, SWAN_End_Date__c from Contract where StartDate = :todaysDate and ((RecordType.Name = :COUNTER_SIGNED_NOTREQUIRED_RECORD_TYPE and Status = :SIGNED_STATUS) or Status = :COUNTER_SIGNED_STATUS)');
        }else{
            return Database.getQueryLocator('Select Id, Status, StartDate, EndDate, SWAN_End_Date__c from Contract where (EndDate = :todaysDate OR DAY_ONLY(SWAN_End_Date__c) = :todaysDate) AND Status = :LIVE_STATUS');
        }
    }

    global void execute(Database.BatchableContext bc, list<Contract> lstContractsToUpdate) {
        List<Contract> lstContractsToLive = new List<Contract>();
        List<Contract> lstContractsToExpired = new List<Contract>();
        List<Contract> lstContractsToTerminated = new List<Contract>();
        List<Contract> lstAllContractsToUpdate = new List<Contract>();
        Date todaysDate = this.todaysDate; //System.today();

        for(Contract c : lstContractsToUpdate){

            if(c.StartDate == todaysDate && !c.Status.equalsIgnoreCase(LIVE_STATUS)){
                lstContractsToLive.add(c);

            } else if(c.EndDate == todaysDate && !c.Status.equalsIgnoreCase(EXPIRED_STATUS)){
                lstContractsToExpired.add(c);

            } else if(c.SWAN_End_Date__c.Date() == todaysDate && c.SWAN_End_Date__c < c.EndDate && c.Status.equals(LIVE_STATUS)){
                lstContractsToTerminated.add(c);
            }
        }

        for(Contract c : lstContractsToLive){
            c.Status = LIVE_STATUS;
            lstAllContractsToUpdate.add(c);
        }

        for(Contract c : lstContractsToExpired){
            c.Status = EXPIRED_STATUS;
            lstAllContractsToUpdate.add(c);
        }

        for(Contract c : lstContractsToTerminated){
            c.Status = TERMINATED_STATUS;
            lstAllContractsToUpdate.add(c);
        }

        lstSaveResults.addAll(Database.update(lstAllContractsToUpdate,false));
    }

    global void finish(Database.BatchableContext bc){
        String finalTextBody = 'List of all errors per record ID:\n';
            for(Database.SaveResult sr : lstSaveResults){
                if(sr.getErrors().size()>0){
                    finalTextBody +='Record ID: ' + sr.getId() + '\n';
                    for(Database.Error err : sr.getErrors()){
                        finalTextBody+='Error Message: ' + err.getMessage() + ' Error Code: ' + err.getStatusCode() + ' Error Fields: ' + err.getFields() + '\n';
                    }
                }
            }
        
        //TO-DO: If something is wrong (send database.SaveResult.getErrors() parsed by record) then send an email to all sys admins
        if(finalTextBody.indexOf('Error Message') != -1 || Test.isRunningTest()){
            
            List<User> lstUsers =  new List<User>([SELECT Email FROM User Where Profile.Name =:PROFILE_NAME and IsActive=true]);
            List<String> userEmails = new List<String>();
            
            for(User  us : lstUsers){
                userEmails.add(us.Email);
            }
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            mail.setToAddresses(userEmails);
            mail.setSenderDisplayName('Batch Processing');
            mail.setSubject('Batch Process Completed - Contracts');
            mail.setPlainTextBody(finalTextBody);
            
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
          
        }     
    }
}