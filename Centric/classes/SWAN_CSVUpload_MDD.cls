public class SWAN_CSVUpload_MDD implements Database.Batchable<SWAN_CustomIterableMDD.CSVWrapper_MDD>{
   
    public final List<string> CSVData;
    public final String recordId;
    public final string ownerId;
    
    public SWAN_CSVUpload_MDD (List<string> CSVData,String recordId,string ownerId)
    {
        this.CSVData = CSVData;
        this.recordId = recordId;
        this.ownerId = ownerId;
    }
    
    public Iterable<SWAN_CustomIterableMDD.CSVWrapper_MDD> start(Database.BatchableContext BC){
        return new SWAN_CustomIterableMDD(CSVData);
    }
    public void execute(Database.BatchableContext BC, List<SWAN_CustomIterableMDD.CSVWrapper_MDD> scope){
           List<vlocity_cmt__ServicePoint__c> serPointList = new List<vlocity_cmt__ServicePoint__c>();
            for(SWAN_CustomIterableMDD.CSVWrapper_MDD obj : scope){
               vlocity_cmt__ServicePoint__c serPoin = new vlocity_cmt__ServicePoint__c();
               serPoin.vlocity_cmt__ServicePointNumber__c = obj.mprn;
               serPoin.SWAN_Import_Export_Identifier__c = obj.import_export;
               //serPoin.SWAN_prepayment_indicator__c = obj.prepayment_indicator;
               serPoin.vlocity_cmt__VoltageLevel__c = obj.voltage;
               serPoin.SWAN_Site_Specific_Indicator__c = obj.site_specific;
               serPoin.SWAN_MDD_Validation__c = obj.combination_valid;
               serPoin.SWAN_MDD_Combination_Supported__c = obj.combination_supported;
               serPoin.SWAN_Unsupported_Reason__c = obj.unsupported_reason;
               serPoin.SWAN_Distributor_ID_Ovrd__c = obj.distributor_id;
               serPoin.SWAN_Profile_Class_Ovrd__c = obj.profile_class;
               serPoin.SWAN_Meter_Time_switch_Class_Ovrd__c = obj.meter_timeswitch_class;
               serPoin.SWAN_Line_Loss_Factor_Class_Ovrd__c = obj.line_loss_factor_class;
               serPoin.SWAN_Grid_Supply_Point_Group_Id_Ovrd__c = obj.gsp_group_id;
               serPoin.SWAN_Measurement_Class_Ovrd__c = obj.measurement_class;
               serPoin.SWAN_Standard_Settlement_Config_Ovrd__c = obj.standard_settlement_configuration;
               serPoin.SWAN_SSC_Grp__c = obj.standard_settlement_configuration_group;
               serPointList.add(serPoin);
            }
            
            if(!serPointList.isEmpty())
            {
                upsert serPointList vlocity_cmt__ServicePointNumber__c;
            }
    }

    public void finish(Database.BatchableContext BC){
        try{
          
          AWSS3csvFileReader aws = new AWSS3csvFileReader();
          aws.createTaskNotification(ownerId,recordId,'Supply point upload & MDD validation completed','Supply point upload & MDD validation completed for related records.');
         /*   //system.debug(MPANList.size()+'==='+this.hasErrors+'@@@@'+UserId);
            Task notify = new Task();
            notify.OwnerId = UserId;
            notify.Subject = (this.hasErrors?'Error occured while Account and service point and premise upload':'Account and service point and premise upload complete');
            notify.Status = 'Open';
            notify.Priority = 'High';
            notify.WhatId = pai;
            notify.ActivityDate=date.today();
            notify.Description=(this.hasErrors?'Error occured while Account and service point and premise upload, no further process will run.\n\nBelow are the error(s):-\n'+this.failureReason:'Account and service point and premise upload completed for '+pan+'.\n ECOES callout will run. Once that completes you will receive another notification.');
            notify.IsReminderSet=true;
            notify.ReminderDateTime=system.now().addSeconds(10);
            insert notify;*/
        }
        catch(exception ex){system.debug('!!!!!!'+ex);}
    }
    
}