global with sharing class SWAN_ClearMDDValidations implements vlocity_cmt.VlocityOpenInterface {

 /**
     * Top level call by a Vlocity Remote Action
     *
     * @param inputMap  - The input provided to the Remote Action
     * @param outputMap - Any output to be provided back to the Remote Action
     * @param options   - Any options to aid in the execution of this class
     *
     * @returns true if the method completes successfully, false otherwise
     */ 
    global Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {

        if (methodName == 'clearServicePoint') return clearServicePoint(inputMap, outputMap, options);
            return false;
    }
    
    
    public Boolean clearServicePoint (Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options){
        List<String> spIds = new List<Id>();
        List<vlocity_cmt__ServicePoint__c> spList = new List<vlocity_cmt__ServicePoint__c>();
        Id sId = String.ValueOf(inputMap.get('ContextId')); 
        if(sId != null && sId.getSObjectType().getDescribe().getName() == 'vlocity_cmt__ServicePoint__c'){
            spIds.add(String.valueOf(inputMap.get('ContextId'))); }
        else if(inputMap.containsKey('SPID'))
        {
            for(Object str:(List<object>)inputMap.get('SPID'))
                spIds.add(String.valueOf(str));
        }
        
        if(spIds.size()>0)
        {
            for(String spId:spIds)
            {
                vlocity_cmt__ServicePoint__c sp = new vlocity_cmt__ServicePoint__c(Id=spId);
                sp.SWAN_Import_Export_Identifier__c = null;
                sp.vlocity_cmt__VoltageLevel__c = null;
                sp.SWAN_Unsupported_Reason__c = null;
                //Due to order of execution it would first clear the override values and only then fill the CSV file for Gorilla
                sp.SWAN_Distributor_ID_Ovrd__c = null;
                sp.SWAN_Profile_Class_Ovrd__c = null;
                sp.SWAN_Meter_Time_switch_Class_Ovrd__c = null;
                sp.SWAN_Line_Loss_Factor_Class_Ovrd__c = null;
                sp.SWAN_Grid_Supply_Point_Group_Id_Ovrd__c = null;
                sp.SWAN_Measurement_Class_Ovrd__c = null;
                sp.SWAN_Standard_Settlement_Config_Ovrd__c = null;
                sp.SWAN_MDD_Validation__c = false;
                sp.SWAN_Site_Specific_Indicator__c = false;
                sp.SWAN_MDD_Combination_Supported__c = false;
                spList.add(sp);
            }
        }
        if(spList.size() > 0)
            update spList;
            
        return true;
    }
}