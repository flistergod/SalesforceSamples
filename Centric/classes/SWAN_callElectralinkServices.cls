global with sharing class SWAN_callElectralinkServices implements vlocity_cmt.VlocityOpenInterface {
 global Boolean invokeMethod(String methodName,
    Map < String, Object > input,
    Map < String, Object > output,
    Map < String, Object > options) {
    
                if(methodName == 'callElectralinkSer')
                {
                      return callElectralinkSer(input,output,options);
                }
                
                return false;
                
        }
        
    public Boolean callElectralinkSer (Map < String, Object > input,Map < String, Object > output,Map < String, Object > options) {
    
      String recordId = String.valueOf(input.get('RecordId'));
      String ownerId = String.valueOf(input.get('UserId'));
      String FilePath = String.valueOf(input.get('FilePath'));
      String AccessTokenVal = String.valueOf(input.get('AccessTokenVal'));
      String codeId =  String.valueOf(input.get('finalCodeId'));
      String code_value = String.valueOf(input.get('code'));
      SWAN_Electralink_Connectors_Codes__c cs = SWAN_Electralink_Connectors_Codes__c.getOrgDefaults();
      Gorilla_Configuration_Data__mdt custMeta = [select SWAN_HH_DataComponent_Output_ID__c,SWAN_NHH_DataComponent_Output_ID__c from Gorilla_Configuration_Data__mdt where DeveloperName = 'IntegrationEnvironment' limit 1];
      String proName = '';
      string opCodeName ='';
      string opDCId = '';
      if(code_value == cs.HH_Code__c)
         {
            proName = 'ElectraLink HH';
            opCodeName = cs.Consumption_Code__c;
            opDCId = custMeta.SWAN_HH_DataComponent_Output_ID__c;
         }
         else if(code_value == cs.NHH_Code__c)
         {   
            proName = 'ElectraLink NHH';
            opCodeName = cs.SWAN_EAC_Output_Code__c;
            opDCId = custMeta.SWAN_NHH_DataComponent_Output_ID__c;
         }
      System.debug('code_value'+code_value);
      system.debug('finalCodeId=='+codeId+' FilePath= '+FilePath +'AccessTokenVal= '+AccessTokenVal);
      List<String> servPointIds = new List<String>();
             if(input.get('servicePointId') == null || input.get('servicePointId') == '')
             {
                for(Object obj : (List<object>)input.get('servicePointList'))
                  {
                      servPointIds.add(String.valueOf(obj));
                  }
             }
             else
             {
                 servPointIds.add(string.valueOf(input.get('servicePointId')));
             }
      HttpRequest req = new HttpRequest();
      
      // Set the file request details
      req.setMethod('POST');
      req.setTimeout(120000);
      req.setEndpoint(FilePath);
      req.setHeader('Authorization', AccessTokenVal);
      req.setHeader('Content-Type', 'application/json');
      Map<String, Object> ipInput = new Map<String, Object> ();
      List<object>ServiceLocations=new List<object>();
     // servPointIds.add('a4P2600000059pgEAA');
      //servPointIds.add('a4P2600000059naEAA');
      system.debug('servPointIds'+servPointIds);
      
      system.debug('cs'+cs);
      for(vlocity_cmt__ServicePoint__c service_Point :[select id,vlocity_cmt__ServicePointNumber__c from vlocity_cmt__ServicePoint__c where Id in :servPointIds] )
      {
            Map<string,object>sp_valuemap = new Map<string,object>{'value' => service_Point.vlocity_cmt__ServicePointNumber__c};            
            ServiceLocations.add(sp_valuemap);
      }
      System.debug('ServiceLocations: ' + ServiceLocations);
      
      
      Map<string,object> ip_map =new Map<string,object>{'args' =>ServiceLocations,'code' =>cs.MPAN_Code__c};
      List<Object> ip_map_list = new List<Object>();
      ip_map_list.add(ip_map);
      ipInput.put('inputs',ip_map_list);
      ipInput.put('status','scheduled');
      ipInput.put('name','QA - Test ElectraLink Connector');
      //to get code from input map ...for now hardcoding
      ipInput.put('connector_version',new Map<string,object>{'model_id' =>codeId});
      // for output
      List<object> opList = new List<object>();
      List<object> opArgsLst =new List<object>();
      Map<string,object> op_mapdata = new Map<string,object>();
      op_mapdata.put('id', opDCId);
      op_mapdata.put('version_id', null);
      opArgsLst.add(op_mapdata);
      Map<string,object> op_map =new Map<string,object>{'args' =>opArgsLst,'code' =>opCodeName};
      opList.add(op_map);
      ipInput.put('outputs',opList);
      String Json_inputs = JSON.serialize(ipInput);
      System.debug('Json_inputs' + Json_inputs);
      String bodydata = Json_inputs;
      //String bodydata = '{"outputs":[],"connector_version":{"model_id":"004af9d2-abba-11ea-ab9c-0a05a4892f7a"},"name":"QA - Test ElectraLink Connector","status":"scheduled","inputs":[{"code":"mpan","args":[{"value":"1012804068728"}]}]}';
      req.setBody(bodydata);
      system.debug('reuest=='+req);
      Http http = new Http();
      //Send the file upload request and debug the response / check for exceptions
      HTTPResponse res = http.send(req);
         System.debug('RESPONSE STRING: ' + res.getBody());
         Map<String, Object> listJson = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
         String calculationId =  String.valueOf(listJson.get('id'));
         system.debug('calculationId='+calculationId);
         string dataComponentId = '';
         for(Object obj : (List<Object>) listJson.get('outputs'))
         {
            MAP<String,Object> mapObj = (MAP<String,Object>) obj;
            if(mapObj.get('code') == cs.Summary_Code__c)
            {
               for(Object ob : (List<Object>) mapObj.get('args'))
               {
                  MAP<String,Object> mapObj1 = (MAP<String,Object>) ob;
                  dataComponentId = String.valueOf(mapObj1.get('id'));
                   system.debug('deeer='+mapObj1.get('id'));
                   system.debug('deeer='+mapObj1.get('version_id'));
               }
               break;
            }
         }
         SWAN_Status_Log__c  st = new SWAN_Status_Log__c ();
            st.SWAN_WorkflowId__c = calculationId;
            st.SWAN_DatacomponentId__c  = dataComponentId;
            st.OwnerId=ownerId;
            st.SWAN_Record_Id__c = recordId; 
            st.SWAN_Process_Name__c = proName;
            System.debug('RESPONSE ST= '+ listJson.get('outputs'));
         
         insert st; 
        return true;
    }
    
}