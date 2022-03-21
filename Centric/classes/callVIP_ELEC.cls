global class callVIP_ELEC implements Database.Batchable<sObject>,Database.AllowsCallouts{
   
    global final set<Id>SPID;
    global string UserId;
    public string pan;
    public id pai;
    public callVIP_ELEC(set<Id>SPID,string UserId,string pan,string pai)
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
        List<id>SPIDLIST = new List<id>();
        for(vlocity_cmt__ServicePoint__c obj : (List<vlocity_cmt__ServicePoint__c>)scope){SPIDLIST.add(obj.id);}
        CallECOESVIP.CallIPService('ECOES_ECOESMPAN',SPIDLIST);
    }

    global void finish(Database.BatchableContext BC){
      /*  Task notify = new Task();
        notify.OwnerId = UserId;
        notify.Subject = 'Supply point bulk upload complete';
        notify.Status = 'In Progress';
        notify.Priority = 'High';
        notify.WhatId = pai;
        notify.ActivityDate=date.today();
        notify.Description=SPID.size()+' Supply point bulk upload completed for '+pan;
        notify.IsReminderSet=true;
        notify.ReminderDateTime=system.now().addSeconds(10);
        insert notify;*/
        List<Id> spList = new List<ID>();
        spList.addAll(SPID);
        //Call MDD validation VIP
        CallMDDVIP.CallIPService('BG-MDDValidation_CreateComponent',spList,pai,UserId);
    }
        
}