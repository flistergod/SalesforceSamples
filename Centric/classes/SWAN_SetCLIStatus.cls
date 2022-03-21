global with sharing class  SWAN_SetCLIStatus  implements vlocity_cmt.VlocityOpenInterface{


    global static void triggerBatchScheduling(Boolean activate_records, String chronString){
            
        if(activate_records){

            String sch='';

            if(String.isNotBlank(chronString)){
                sch=chronString;
            }else{
                sch='0 10 0 * * ?';
            }

            system.schedule('Activate Contracts and CLI '+System.now().getTime(), sch , new SWAN_ScheduleContractAndCLIActivation());

        }else{

            String sch='';

            if(String.isNotBlank(chronString)){
                sch=chronString;
            }else{
                sch='0 30 23 * * ?';
            }

            System.schedule('Deactivate Contracts and CLI '+System.now().getTime(), sch , new SWAN_ScheduleContractAndCLIDeactivation());
        }
    }


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
        
        Boolean result = true;
        try{
            if (methodName.equals('setCLIStatus')){
                Database.executeBatch(new SWAN_BatchSetCLIStatus());
            }else if (methodName.equals('setContractStatus')){
                Database.executeBatch(new SWAN_BatchSetContractStatus());
            }
        }catch(Exception e){
            return false;
        }
        
        return result;
    }    
}