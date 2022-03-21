public class SWAN_CSVUpload implements Database.Batchable<SWAN_CustomIterable.CSVWrapper>,Database.Stateful{
   
    public final map<string,object>osinput;
    public string UserId;
    public string pan;
    public id pai;
    public string failureReason='';
    public List<string>MRPNList;
    public boolean hasErrors;
    public SWAN_CSVUpload (map<string,object>osinput,string UserId)
    {
        this.MRPNList=new List<string>();
        this.osinput=osinput;
        this.UserId=UserId;
        this.pan=(string)((Map<String, Object>)osinput.get('AccountHierarchy')).get('ParentAccountName');
        this.pai=(string)((Map<String, Object>)osinput.get('AccountHierarchy')).get('ParentAccountId');
        this.hasErrors=false;
    }
    
    public Iterable<SWAN_CustomIterable.CSVWrapper> start(Database.BatchableContext BC){
        return new SWAN_CustomIterable(osinput);
    }
    public void execute(Database.BatchableContext BC, List<SWAN_CustomIterable.CSVWrapper> scope){
        if(!this.hasErrors){
            for(SWAN_CustomIterable.CSVWrapper obj : scope){
                this.MRPNList.add(obj.ServicePointId);
            }
        
            string dataJson = JSON.serializePretty(scope, false);
            vlocity_cmt.DRProcessResult result = vlocity_cmt.DRGlobal.processObjectsJSON(dataJson, 'CSVv3');
            Map<String, Object> resultMap = result.convertToMap();
            //System.debug('<<(*;*)>>'+JSON.serialize(resultMap));
            /* 
            Process the results of the load: these methods return details about objects affected by the DataRaptor load, plus any errors that occured 
            */
            /*
            Map<String, Object> createdObjectsByType = (Map<String, Object>)resultMap.get('createdObjectsByType'); 
            Map<String, Object> createdObjectsByTypeForBundle = (Map<String, Object>)createdObjectsByType.get('Create Accounts');
            Map<String, Object> createdObjectsByOrder = (Map<String, Object>)resultMap.get('createdObjectsByOrder');*/
            Map<String, Object> errors = (Map<String, Object>)resultMap.get('errors');
            //Map<String, Object> errorsByField = (Map<String, Object>)resultMap.get('errorsByField');
            //List<Map<String, Object>> errorsAsJson = (List<Map<String, Object>>)resultMap.get('errorsAsJson'); // Returns input JSON plus per-node errors
            this.hasErrors = result.hasErrors();
            if(this.hasErrors && errors.get('CSVv3')!=null){
                this.failureReason = JSON.serialize(errors.get('CSVv3'));
                for(string s:((Map<String, Object>)errors.get('CSVv3')).keyset())
                {
                    this.failureReason+=s+'=>'+((Map<String, Object>)errors.get('CSVv3')).get(s)+'\n';
                }            
                system.debug('erors\n'+errors+'\nfailureReason\n'+this.failureReason+'\nhasErrors\n'+this.hasErrors);
            }
        }
    }

    public void finish(Database.BatchableContext BC){
        if(!hasErrors){
            set<id>SPids=new set<id>();
            for(vlocity_cmt__ServicePoint__c sp : [select id from vlocity_cmt__ServicePoint__c where multisite_sync_due__c=true and vlocity_cmt__ServicePointNumber__c in:MRPNList and recordtype.developername='SWAN_Gas_Service_Point'])
                SPids.add(sp.id);
            if(SPids.size()>1)
                Database.executeBatch(new callVIP (SPids,UserId,pan,pai), 45);
        }
        try{
            system.debug(pan+'==='+this.hasErrors+'@@@@'+UserId);
            Task notify = new Task();
            notify.OwnerId = UserId;
            notify.Subject = (this.hasErrors?'Error occured while Account and service point and premise upload':'Account and service point and premise upload complete');
            notify.Status = 'In Progress';
            notify.Priority = 'High';
            notify.WhatId = pai;
            notify.ActivityDate=date.today();
            notify.Description=(this.hasErrors?'Error occured while Account and service point and premise upload, no further process will run.\n\nBelow are the error(s):-\n'+this.failureReason:'Account and service point and premise upload completed for '+pan+'.\n Xoserve callout will run. Once that completes you will receive another notification.');
            notify.IsReminderSet=true;
            notify.ReminderDateTime=system.now().addSeconds(30);
            insert notify;
            /*Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {EmailId};
            mail.setToAddresses(toAddresses);
            mail.setSubject('Account and service point and premise upload complete');
            mail.setHTMLBody('Account and service point and premise upload completed for '+pan+'.<br/>Next Xoserver callout will run. Once that completes you will receive another notification. <br/><br/>Regards,<br/>I&C Sales Team');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });*/
        }
        catch(exception ex){system.debug('!!!!!!'+ex);}
    }
    
}