public class CallECOESVIP{

@AuraEnabled
public static boolean CallIPService(string IPname,List<id> SPID) {
        
        Map<String, Object> ipInput = new Map<String, Object> ();
        Map<String, Object> ipOutput = new Map<String, Object> ();
        String UserId = Userinfo.getUserId();
        List<vlocity_cmt__ServicePoint__c> SPList = [select id,vlocity_cmt__ServicePointNumber__c,recordtypeid,SWAN_Supply_Capacity__c from vlocity_cmt__ServicePoint__c where id in: SPID];
        List<object>ServiceLocations=new list<object>();
        for(vlocity_cmt__ServicePoint__c sp : SPList){
            map<string,object>keyvaluemap = new Map<string,object>{'SPrecordtype' => sp.recordtypeid, 'ServicePointId' => sp.vlocity_cmt__ServicePointNumber__c, 'SupplyCapacity' =>sp.SWAN_Supply_Capacity__c};            
            ServiceLocations.add(keyvaluemap);
        }
        
        ipInput.put('AccountHierarchy',new Map<string,object>{'ServiceLocations' =>ServiceLocations});
        //system.debug('=====>JSON\n'+JSON.serializePretty(ipInput));
        /* Call the IP via runIntegrationService, 
        and save the output to ipOutput */
        try{
            ipOutput = (Map<String, Object>) vlocity_cmt.IntegrationProcedureService.runIntegrationService(IPname, ipInput, new Map<String, Object>());
            //system.debug('OUT#######>>>\n'+ipOutput );
            
            Map<string, object> input = new Map<string, object>();
            Map<string, object> output = new Map<string, object>();
            Map<string, object> options = new Map<string, object>();
            input.put('SPID',SPID);
            SWAN_ClearMDDValidations clearMDD = new SWAN_ClearMDDValidations();
            clearMDD.invokeMethod('clearServicePoint',input,output,options);
            
            if(SPID.size() == 1 && !system.isBatch())
            {
              callMDDIP(SPID,userId);
            }
            return true;
        }
        catch(Exception ex)
        {
            system.debug('===>'+ex);
            return false;
        }
    }

  @future(callout=true)
  public static void callMDDIP(List<ID> SPID,string userId){
  CallMDDVIP.CallIPService('BG-MDDValidation_CreateComponent',SPID,SPID[0],UserId);
  }  

}