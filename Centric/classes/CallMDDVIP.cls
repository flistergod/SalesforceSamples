public class CallMDDVIP{


public static boolean CallIPService(string IPname,List<id> SPID,string AccId,string ownerId) {
        
        Map<String, Object> ipInput = new Map<String, Object> ();
        Map<String, Object> ipOutput = new Map<String, Object> ();
        ipInput.put('servicePointList',SPID);
        ipInput.put('RecordId',AccId);
        ipInput.put('UserId',ownerId);
        try{
            ipOutput = (Map<String, Object>) vlocity_cmt.IntegrationProcedureService.runIntegrationService(IPname, ipInput, new Map<String, Object>());
            //system.debug('OUT#######>>>\n'+ipOutput );
            return true;
        }
        catch(Exception ex)
        {
            system.debug('===>'+ex);
            return false;
        }
    }  

}