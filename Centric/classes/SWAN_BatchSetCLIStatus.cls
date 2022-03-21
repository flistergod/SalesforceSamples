//Test class: SWAN_BatchSetCLIStatus_Test
global with sharing class SWAN_BatchSetCLIStatus implements Database.Batchable<sObject>, Database.Stateful {

    private List<Database.SaveResult> lstSaveResults;
    private final static String PROFILE_NAME = 'System Administrator';
    private final Boolean ACTIVATE_RECORDS;
    private final static String ACTIVE_STATUS = 'Active';
    private final static List<String> LIST_OF_NOT_ACTIVE_STATUS = new List<String>{'Inactive','Terminated'};
    private final static String COUNTER_SIGNED_STATUS = 'Contract Counter Signed';
    private final static String LIVE_STATUS = 'Contract Live';
    private final static String COUNTER_SIGNED_NOTREQUIRED_RECORD_TYPE = 'Counter Signature not Required';
    private final static String SIGNED_STATUS = 'Contract Signed';


    global SWAN_BatchSetCLIStatus(){
        lstSaveResults = new List<Database.SaveResult>();
    }

    global SWAN_BatchSetCLIStatus(Boolean activateRecords){
        lstSaveResults = new List<Database.SaveResult>();
        ACTIVATE_RECORDS = activateRecords;
    }


    global Database.QueryLocator start(Database.BatchableContext bc) {

        Date todaysDate = System.today();
        if(ACTIVATE_RECORDS){
            return Database.getQueryLocator('Select Id, vlocity_cmt__LineStatus__c, vlocity_cmt__EffectiveEndDate__c, vlocity_cmt__EffectiveStartDate__c, SWAN_Service_Point_Start_Date__c, SWAN_Service_Point_End_Date__c, vlocity_cmt__ServicePointId__c, SWAN_Service_Point__c, vlocity_cmt__OriginalLineItemId__c, vlocity_cmt__ContractId__r.StartDate, vlocity_cmt__ContractId__r.Status, vlocity_cmt__ContractId__r.RecordType.Name  from vlocity_cmt__ContractLineItem__c where vlocity_cmt__LineStatus__c in :LIST_OF_NOT_ACTIVE_STATUS AND DAY_ONLY(vlocity_cmt__EffectiveStartDate__c) = :todaysDate');
        }else{
            return Database.getQueryLocator('Select Id, vlocity_cmt__LineStatus__c, vlocity_cmt__EffectiveEndDate__c, vlocity_cmt__EffectiveStartDate__c, SWAN_Service_Point_Start_Date__c, SWAN_Service_Point_End_Date__c, vlocity_cmt__ServicePointId__c, SWAN_Service_Point__c, vlocity_cmt__OriginalLineItemId__c, vlocity_cmt__ContractId__r.RecordType.Name  from vlocity_cmt__ContractLineItem__c where vlocity_cmt__LineStatus__c = :ACTIVE_STATUS AND DAY_ONLY(vlocity_cmt__EffectiveEndDate__c) = :todaysDate');
        }
    }

    global void execute(Database.BatchableContext bc, list<vlocity_cmt__ContractLineItem__c> lstCLIToUpdate){
        
        List<vlocity_cmt__ContractLineItem__c> lstCLIToActive = new List<vlocity_cmt__ContractLineItem__c>();
        List<vlocity_cmt__ContractLineItem__c> lstCLIToInactive = new List<vlocity_cmt__ContractLineItem__c>();
        List<vlocity_cmt__ContractLineItem__c> lstCLIToTerminated = new List<vlocity_cmt__ContractLineItem__c>();
        List<vlocity_cmt__ContractLineItem__c> lstAllCLIToUpdate = new List<vlocity_cmt__ContractLineItem__c>();

        Date todaysDate = System.today();
        Timezone tz = Timezone.getTimeZone('Europe/London');

        for(vlocity_cmt__ContractLineItem__c cli : lstCLIToUpdate){
            if((cli.vlocity_cmt__ServicePointId__c != null || cli.SWAN_Service_Point__c != null || cli.vlocity_cmt__OriginalLineItemId__c != null  ) 
                && ( cli.vlocity_cmt__EffectiveStartDate__c.date() == todaysDate && ACTIVATE_RECORDS ) 
                && ( cli.vlocity_cmt__ContractId__r.Status == COUNTER_SIGNED_STATUS || cli.vlocity_cmt__ContractId__r.Status == LIVE_STATUS
                    || (cli.vlocity_cmt__ContractId__r.RecordType.Name == COUNTER_SIGNED_NOTREQUIRED_RECORD_TYPE && cli.vlocity_cmt__ContractId__r.Status == SIGNED_STATUS) ) 
                &&   cli.vlocity_cmt__ContractId__r.StartDate == todaysDate){
                lstCLIToActive.add(cli);
            }else if((cli.vlocity_cmt__EffectiveEndDate__c.date()) != cli.SWAN_Service_Point_End_Date__c && cli.vlocity_cmt__LineStatus__c.equalsIgnoreCase('Active') && !ACTIVATE_RECORDS){
                lstCLIToTerminated.add(cli);
            }else if((cli.vlocity_cmt__EffectiveEndDate__c.date()) == cli.SWAN_Service_Point_End_Date__c && cli.vlocity_cmt__LineStatus__c.equalsIgnoreCase('Active') && !ACTIVATE_RECORDS){
                lstCLIToInactive.add(cli);
            }
        }

        if(lstCLIToActive.size() > 0){
            for(vlocity_cmt__ContractLineItem__c cli : lstCliToActive){
                cli.vlocity_cmt__LineStatus__c = 'Active';
                //Datetime targetDateTime = DateTime.newInstanceGMT(todaysDate.addDays(1),Time.newInstance(0, 0, 0, 0)); 
                //cli.vlocity_cmt__EffectiveStartDate__c = targetDateTime.addSeconds(tz.getOffset(targetDateTime)/1000);
                lstAllCLIToUpdate.add(cli);
            }
        }

        if(lstCLIToTerminated.size() > 0){
            for(vlocity_cmt__ContractLineItem__c cli : lstCLIToTerminated){
                cli.vlocity_cmt__LineStatus__c = 'Terminated';
                //Datetime targetDateTime = DateTime.newInstance(todaysDate,Time.newInstance(23, 59, 0, 0)); 
                //cli.vlocity_cmt__EffectiveEndDate__c = targetDateTime.addSeconds(tz.getOffset(targetDateTime)/1000);
                lstAllCLIToUpdate.add(cli);
            }
        }

        if(lstCLIToInactive.size() > 0){
            for(vlocity_cmt__ContractLineItem__c cli : lstCLIToInactive){
                cli.vlocity_cmt__LineStatus__c = 'Inactive';
                //Datetime targetDateTime = DateTime.newInstance(todaysDate,Time.newInstance(23, 59, 0, 0)); 
                //cli.vlocity_cmt__EffectiveEndDate__c = targetDateTime.addSeconds(tz.getOffset(targetDateTime)/1000);
                lstAllCLIToUpdate.add(cli);
            }
        }

        lstSaveResults.addAll(Database.update(lstAllCLIToUpdate,false));
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
        if(finalTextBody.indexOf('Error Message') != -1  || Test.isRunningTest()){
            
            List<User> lstUsers =  new List<User>([SELECT Email FROM User Where Profile.Name =:PROFILE_NAME and IsActive=true]);
            List<String> userEmails = new List<String>();
            
            for(User  us : lstUsers){
                userEmails.add(us.Email);
            }
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            mail.setToAddresses(userEmails);
            mail.setSenderDisplayName('Batch Processing');
            mail.setSubject('Batch Process Completed - Contract Line Items');
            mail.setPlainTextBody(finalTextBody);
            
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
          
        }
              
    }
}