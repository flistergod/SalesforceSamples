global with sharing class ECOESresponseParsing implements vlocity_cmt.VlocityOpenInterface2 {

        global Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {

            if (methodName == 'parse') return parse(inputMap, outputMap, options);  
            
            return false;
        }

        private Boolean parse(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
            integer NumberofSP = Integer.valueof(inputMap.get('NumberofSP'));
            
            List<Object> ECOESresponse = (List<Object>)(((MAP<string,object>)inputMap.get('ECOESresponse')).get('Results'));
            system.debug('AccountHierarchy: '+((MAP<string,object>)inputMap.get('AccountHierarchy')).get('ServiceLocations'));
            List<Object> SPs = ((NumberofSP > 1) ? (List<Object>)(((MAP<string,object>)inputMap.get('AccountHierarchy')).get('ServiceLocations')) : new List<Object>{(((MAP<string,object>)inputMap.get('AccountHierarchy')).get('ServiceLocations'))});
            
            Map<string,object> spmap = new Map<string,Map<string,object>>();
            for(Object objsp :SPs)
            {
                map<string,object>temp = (map<string,object>)(objsp);
                spmap.put(string.valueof(temp.get('ServicePointId')),temp);    
            }
            
            List<Map<string,object>>SPJSON = new List<Map<string,object>>();
            for(Object eachSP : ECOESresponse )//eachSP = Results[i]
            {
               Object UtilityMatches =((List<Object>)(((MAP<string,object>)eachSP).get('UtilityMatches')))[0];
               Object Meters = ((List<Object>)(((MAP<string,object>)UtilityMatches).get('Meters')))[0];
               List<object> MeterDetails = (List<Object>)(((MAP<string,object>)Meters).get('MeterDetails'));
               List<object> UtilityDetails = (List<Object>)(((MAP<string,object>)UtilityMatches).get('UtilityDetails'));
               Map<string,object>temp = new Map<string,object>();
               
               temp.put('ServiceLocations',spmap.get(string.valueof(temp.get('mpancore'))));
               
               for(Object obj0 : MeterDetails)
               {
                   Map<string,object> obj1 = (Map<string,object>) obj0;
                   temp.put(string.valueof(obj1.get('Key')),(((string.valueof(obj1.get('Key')).endsWithIgnoreCase('_efd') || string.valueof(obj1.get('Key')).endsWithIgnoreCase('_date')) && obj1.get('Value')!=null)?(string.valueof(obj1.get('Value')).substring(0,4)+'-'+string.valueof(obj1.get('Value')).substring(4,6)+'-'+ string.valueof(obj1.get('Value')).substring(6)):obj1.get('Value')));
               }
               
               for(Object obj2 : UtilityDetails )
               {
                   Map<string,object> obj3 = (Map<string,object>) obj2;
                   temp.put(string.valueof(obj3.get('Key')),(((string.valueof(obj3.get('Key')).endsWithIgnoreCase('_efd') || string.valueof(obj3.get('Key')).endsWithIgnoreCase('_date')) && obj3.get('Value')!=null)?(string.valueof(obj3.get('Value')).substring(0,4)+'-'+string.valueof(obj3.get('Value')).substring(4,6)+'-'+ string.valueof(obj3.get('Value')).substring(6)):obj3.get('Value')));
                   //system.debug('Service Locations: '+temp.get('ServiceLocations')+'\nstring.valueof key: '+string.valueof(obj3.get('Key'))+'\nobj3.get value: '+obj3.get('Value'));
                   if(temp.get('ServiceLocations') == null && string.valueof(obj3.get('Key')).endsWithIgnoreCase('mpan_core')){
                       temp.put('ServiceLocations',spmap.get(string.valueof(obj3.get('Value'))));
                   }

                   
                }
                //system.debug('%%%%%'+string.valueof(temp.get('mpancore')));
                
                //Due to a change\mapping issue on the API\Vlocity, we need to replace the IHD value from the short code to the full picklist value in Vlocity side
                if(temp.containsKey('ihd_status') && temp.get('ihd_status')!= null){
                    String ihd_status_efdValue = (String)temp.get('ihd_status');
                    if(ihd_status_efdValue.equalsIgnoreCase('I')){
                        ihd_status_efdValue = 'Installed';
                    }else if(ihd_status_efdValue.equalsIgnoreCase('E')){
                        ihd_status_efdValue = 'Existing';
                    }else if(ihd_status_efdValue.equalsIgnoreCase('D')){
                        ihd_status_efdValue = 'Declined';
                    }

                    temp.put('ihd_status', ihd_status_efdValue);
                }
               
                SPJSON.add(temp);
            }
            outputMap.put('ECOESParsedResponse',SPJSON);
            //system.debug('=====>ECOES_JSON\n'+JSON.serializePretty(SPJSON));
            return true;
        }
}