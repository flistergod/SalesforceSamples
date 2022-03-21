global class callVIP implements Database.Batchable<sObject>,Database.AllowsCallouts{
   
    global final set<Id>SPID;
    global string UserId;
    public string pan;
    public id pai;
    public callVIP(set<Id>SPID,string UserId,string pan,string pai)
    {
        this.SPID=SPID;
        this.UserId=UserId;
        this.pan=pan;
        this.pai=pai;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('SELECT id from vlocity_cmt__ServicePoint__c where id in:SPID');//multisite_sync_due__c=true
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        string jsonInput='{"SPList":[';
        for(sobject s : scope){
            jsonInput+='{"Id":"'+s.id+'"},';        
        }
        jsonInput=jsonInput.removeend(',')+']}';
        system.debug(jsonInput);
        Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(jsonInput);
        CallIPService('XOserve_XoserveServiceBulkAsync',m);
    }

    global void finish(Database.BatchableContext BC){
        Task notify = new Task();
        notify.OwnerId = UserId;
        notify.Subject = 'Supply point/points upload complete';
        notify.Status =  'Open';
        notify.Priority = 'High';
        notify.WhatId = pai;
        notify.ActivityDate=date.today();
        notify.Description=SPID.size()+' Supply point/points upload complete for '+pan;
        notify.IsReminderSet=true;
        notify.ReminderDateTime=system.now().addSeconds(30);
        insert notify;
        /*Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {EmailId};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Supply point bulk upload complete');
        mail.setHTMLBody(SPID.size()+' Supply point bulk upload completed for '+pan+'.<br/><br/>Regards,<br/>I&C Sales Team');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });*/
    }
    
    private static boolean CallIPService(string IPname,Map<String, Object> ipInput) {
        
        Map<String, Object> ipOutput = new Map<String, Object> ();
                
        /* Call the IP via runIntegrationService, 
        and save the output to ipOutput */
        try{
            ipOutput = (Map<String, Object>) vlocity_cmt.IntegrationProcedureService.runIntegrationService(IPname, ipInput, new Map<String, Object>());
            system.debug('OUT#######>>>\n'+ipOutput );
            return true;
        }
        catch(Exception ex)
        {
            system.debug('===>'+ex);
            return false;
        }
    }  
    
}