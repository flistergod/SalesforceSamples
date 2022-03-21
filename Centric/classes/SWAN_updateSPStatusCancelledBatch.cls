public class SWAN_updateSPStatusCancelledBatch implements Database.Batchable<sObject>,Database.Stateful{

    public string UserId;
    public string status;
    public string termination_Date;
    public List<Id> cli_Id_List;
    public Id con_id;
    public boolean hasErrors;
    public string process_Name;
    
    public SWAN_updateSPStatusCancelledBatch (List<Id> cli_Id_List,String UserId,String process_Name)
    {
        this.cli_Id_List=cli_Id_List;
        this.UserId=UserId;
        this.process_Name=process_Name;
        this.hasErrors=false;
    }
    
    public SWAN_updateSPStatusCancelledBatch (List<Id> cli_Id_List,String UserId,String status,String termination_Date,String process_Name)
    {
        this.cli_Id_List=cli_Id_List;
        this.UserId=UserId;
        this.process_Name=process_Name;
        this.hasErrors=false;
        this.status=status;
        this.termination_Date=termination_Date;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'Select id,vlocity_cmt__ContractId__c FROM vlocity_cmt__ContractLineItem__c where Id IN :cli_Id_List';
        return Database.getQueryLocator(query);        
    }

    public void execute(Database.BatchableContext BC, List<vlocity_cmt__ContractLineItem__c> scope) {
        system.debug('scope'+scope.size());
        List<ID> cli_ids = new List<ID>();
        for(vlocity_cmt__ContractLineItem__c cli_scope : scope){
            
            cli_ids.add(cli_scope.Id);
        }
        if(scope != null && scope.size()>0)
            con_id = scope[0].vlocity_cmt__ContractId__c;
        system.debug('cli_ids'+cli_ids);
        system.debug('cli_ids'+cli_ids.size());
        List<vlocity_cmt__ContractLineItem__c> parent_cli_list = [SELECT id,vlocity_cmt__LineStatus__c, vlocity_cmt__EffectiveEndDate__c,vlocity_cmt__EffectiveStartDate__c,(select id,vlocity_cmt__EffectiveEndDate__c,vlocity_cmt__EffectiveStartDate__c,vlocity_cmt__LineStatus__c from vlocity_cmt__Contract_Line_Items__r) from vlocity_cmt__ContractLineItem__c where Id IN :cli_ids];
        system.debug('parent_cli_list'+parent_cli_list);
        SWAN_CLI_Statuses__c cancelledstatus = [SELECT id,SWAN_Cancelled__c FROM SWAN_CLI_Statuses__c WHERE Name != ''];
        SWAN_CLI_Statuses__c terminatedstatus = [SELECT id,SWAN_Terminated__c FROM SWAN_CLI_Statuses__c WHERE Name != ''];
        system.debug('cancelledstatus'+cancelledstatus);
        List<vlocity_cmt__ContractLineItem__c> update_cli = new List<vlocity_cmt__ContractLineItem__c>();
        List<vlocity_cmt__ContractLineItem__c> update_child_cli = new List<vlocity_cmt__ContractLineItem__c>();
        try
        { 
            for(vlocity_cmt__ContractLineItem__c parent_cli : parent_cli_list)
            {
                if(this.process_Name == 'Cancelled')
                { 
                    parent_cli.vlocity_cmt__EffectiveEndDate__c  = null;
                    parent_cli.vlocity_cmt__EffectiveStartDate__c  = null;
                    parent_cli.vlocity_cmt__LineStatus__c  = cancelledstatus.SWAN_Cancelled__c;
                }
                if(this.process_Name == 'Termination')
                {
                    system.debug('thistermination_Date'+this.termination_Date);
                    DateTime terminateDate = DateTime.valueOfGMT(this.termination_Date.replace('T', ' '));
                    if (terminateDate >= parent_cli.vlocity_cmt__EffectiveStartDate__c) {
                        parent_cli.vlocity_cmt__EffectiveEndDate__c  =  terminateDate;
                    }
                    
                    parent_cli.vlocity_cmt__LineStatus__c  = terminatedstatus.SWAN_Terminated__c;
                }   
                update_cli.add(parent_cli);
                update_child_cli.addAll(parent_cli.vlocity_cmt__Contract_Line_Items__r);
            }
            System.debug('update_cli_list'+update_cli);
            for(vlocity_cmt__ContractLineItem__c child_cli : update_child_cli)
            {
                if(this.process_Name == 'Cancelled')
                { 
                    child_cli.vlocity_cmt__EffectiveEndDate__c  = null;
                    child_cli.vlocity_cmt__EffectiveStartDate__c  = null;
                    child_cli.vlocity_cmt__LineStatus__c  = cancelledstatus.SWAN_Cancelled__c;
                }
                if(this.process_Name == 'Termination')
                {
                    DateTime terminateDate = DateTime.valueOfGMT(this.termination_Date.replace('T', ' '));
                    if (terminateDate >= child_cli.vlocity_cmt__EffectiveStartDate__c) {
                        child_cli.vlocity_cmt__EffectiveEndDate__c  =  terminateDate;
                    }
                    
                    child_cli.vlocity_cmt__LineStatus__c  = terminatedstatus.SWAN_Terminated__c;
                }   
                update_cli.add(child_cli);
            }
            System.debug('update_cli_list'+update_cli);
            update update_cli;
        }
        catch(exception ex){
            system.debug('Exception in cli update!!!!!!'+ex);
            this.hasErrors =true;
        }
        System.debug('Updated CLI'+update_cli);
        System.debug('Updated CLI size'+update_cli.size());
    }

    public void finish(Database.BatchableContext BC){
      
        try{
            system.debug('Finished');
            system.debug('haserrors2'+this.hasErrors);
            Task notify = new Task();
            notify.OwnerId = UserId;
            notify.Subject = (this.hasErrors?'Contract Line Items Status update failed':'Contract Line Items Status updated successfully');
            notify.Status = 'Open';
            notify.Priority = 'High';
            notify.WhatId = con_id;
            notify.ActivityDate=date.today();
            notify.Description=(this.hasErrors?'Contract Line Items Status update failed':'Contract Line Items Status updated successfully');
            notify.IsReminderSet=true;
            notify.ReminderDateTime=system.now().addSeconds(10);
            insert notify;

          
            String DR_EXTRACT_HEADER='SWAN_GetNewContractStatus';
            String DR_LOAD_HEADER='SWAN_SetContractEndDateAndStatus';
            Id contractId = con_id;
            String dateToUse = '';
            String statusToUse='';
            

            List<Map<String, Object>> DRinputs = new List<Map<String, Object>>();
            Map<String, Object> DRinput = new Map<String, Object>();
            Map<String, Object> resultMap=new Map<String, Object>();
            Map<String, Object> errors=new Map<String, Object>();

            DRinput.put('ContextId', contractId); 
            DRinputs.add(DRinput);

            System.debug(DRinputs);

            vlocity_cmt.DRProcessResult drProcessResultExtract = vlocity_cmt.DRGlobal.process(DRInputs, DR_EXTRACT_HEADER);
            System.debug('drProcessResult Extract->' + drProcessResultExtract);
            resultMap = drProcessResultExtract.convertToMap();
            System.debug('resultMap EXTRACT ->' + resultMap);

            
            if (!drProcessResultExtract.hasErrors()){

                Map<String, Object> myTransformResult = (Map<String, Object>)resultMap.get('returnResultsData');

                system.debug(myTransformResult.get('AllServicePointsEnded'));

                if((Boolean)myTransformResult.get('AllServicePointsEnded')){

                    DRinputs = new List<Map<String, Object>>();

                    if(this.process_Name == 'Cancelled'){
                        dateToUse=((DateTime) System.today()).format('dd/MM/yyyy');
                    }else{
                        dateToUse=(String)myTransformResult.get('EndDateOfLastServicePoint')+'T22:59:00.000Z';
                        System.debug(dateToUse);
                    }

                    String newContractStatus = (String) myTransformResult.get('NewContractStatus');
                    if(this.process_Name != 'Termination' || (this.process_Name == 'Termination' && newContractStatus == 'Contract Terminated')){
                        statusToUse = newContractStatus;
                        System.debug(statusToUse);
                    }

                    DRinput.put('DateToUse', dateToUse);
                    DRinput.put('StatusToUse', statusToUse);
                    DRinputs.add(DRinput);

                    vlocity_cmt.DRProcessResult drProcessResultLoad = vlocity_cmt.DRGlobal.process(DRInputs, DR_LOAD_HEADER);
                    System.debug('drProcessResultLoad ->' + drProcessResultLoad);
                    
                    resultMap = drProcessResultLoad.convertToMap();
                    System.debug('resultmap load ->' + resultMap);
                
                    if (drProcessResultLoad.hasErrors()){

                        errors = (Map<String, Object>)resultMap.get('errors');
                        system.debug('erors on dr load status contract \n'+errors+'\nhasErrors\n'+this.hasErrors);
                    }
                }

            }else{

                errors = (Map<String, Object>)resultMap.get('errors');
                system.debug('erors on dr load status contract \n'+errors+'\nhasErrors\n'+this.hasErrors);
            }

        }catch(exception ex){
            system.debug('Exception!!!!!!'+ex);
        }
    }
}