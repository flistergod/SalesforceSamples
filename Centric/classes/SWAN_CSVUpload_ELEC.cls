public class SWAN_CSVUpload_ELEC implements Database.Batchable<SWAN_CustomIterable_ELEC.CSVWrapper_ELEC>,Database.Stateful{
   
    public final map<string,object>osinput;
    public string UserId;
    public string pan;
    public id pai;
    public string failureReason='';
    public List<string>MPANList;
    public boolean hasErrors;
    public integer ECOESBatchSize=integer.ValueOf(System.Label.ECOESBatchSize);
    public integer MaxECOESBatchSize=integer.ValueOf(System.Label.Max_ECOES_Batch_Size);
    public SWAN_CSVUpload_ELEC (map<string,object>osinput,string UserId)
    {
        this.MPANList=new List<string>();
        this.osinput=osinput;
        this.UserId=UserId;
        this.pan=(string)((Map<String, Object>)osinput.get('AccountHierarchy')).get('ParentAccountName');
        this.pai=(string)((Map<String, Object>)osinput.get('AccountHierarchy')).get('ParentAccountId');
        this.hasErrors=false;
    }
    
    public Iterable<SWAN_CustomIterable_ELEC.CSVWrapper_ELEC> start(Database.BatchableContext BC){
        return new SWAN_CustomIterable_ELEC(osinput);
    }
    public void execute(Database.BatchableContext BC, List<SWAN_CustomIterable_ELEC.CSVWrapper_ELEC> scope){
        if(!this.hasErrors){
            for(SWAN_CustomIterable_ELEC.CSVWrapper_ELEC obj : scope){
                this.MPANList.add(obj.ServicePointId);
            }
            string dataJson = JSON.serializePretty(scope, false);
            vlocity_cmt.DRProcessResult result = vlocity_cmt.DRGlobal.processObjectsJSON(dataJson, 'CSV_Async_ELEC');
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
            if(this.hasErrors && errors.get('CSV_ELEC')!=null){
                this.failureReason = JSON.serialize(errors.get('CSV_ELEC'));
                for(string s:((Map<String, Object>)errors.get('CSV_ELEC')).keyset())
                {
                    this.failureReason+=s+'=>'+((Map<String, Object>)errors.get('CSV_ELEC')).get(s)+'\n';
                }            
                system.debug('erors\n'+errors+'\nfailureReason\n'+this.failureReason+'\nhasErrors\n'+this.hasErrors);
            }
        }
    }

    public void finish(Database.BatchableContext BC){
        if(!hasErrors){
            set<id>SPids=new set<id>();
            for(vlocity_cmt__ServicePoint__c sp : [select id from vlocity_cmt__ServicePoint__c where multisite_sync_due__c=true and vlocity_cmt__ServicePointNumber__c in:MPANList and recordtype.developername='SWAN_Electricity_Service_point'])
                SPids.add(sp.id);
            
            if(SPids.size()>1)
                {
                if(ECOESBatchSize<=MaxECOESBatchSize)
                Database.executeBatch(new callVIP_ELEC(SPids,UserId,pan,pai), ECOESBatchSize);
                else
                Database.executeBatch(new callVIP_ELEC(SPids,UserId,pan,pai), MaxECOESBatchSize);
                }
        }
        try{
            //system.debug(MPANList.size()+'==='+this.hasErrors+'@@@@'+UserId);
            Task notify = new Task();
            notify.OwnerId = UserId;
            notify.Subject = (this.hasErrors?'Error occured while Account and service point and premise upload':'Account and service point and premise upload complete');
            notify.Status = 'In Progress';
            notify.Priority = 'High';
            notify.WhatId = pai;
            notify.ActivityDate=date.today();
            notify.Description=(this.hasErrors?'Error occured while Account and service point and premise upload, no further process will run.\n\nBelow are the error(s):-\n'+this.failureReason:'Account and service point and premise upload completed for '+pan+'.\n ECOES callout will run. Once that completes you will receive another notification.');
            notify.IsReminderSet=true;
            notify.ReminderDateTime=system.now().addSeconds(10);
            insert notify;
        }
        catch(exception ex){system.debug('!!!!!!'+ex);}
    }
    
}