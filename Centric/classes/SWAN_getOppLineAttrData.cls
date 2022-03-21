global with sharing class SWAN_getOppLineAttrData implements vlocity_cmt.VlocityOpenInterface {
    
    /**
        * Top level call by a Vlocity Remote Action
        *
        * @param inputMap  - The input provided to the Remote Action
        * @param outputMap - Any output to be provided back to the Remote Action
        * @param options   - Any options to aid in the execution of this class
        *
        * @returns true if the method completes successfully, false otherwise
    */      
    global Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options){

        if(methodName == 'extractOpportunity'){
            return extractOpportunity(inputMap, outputMap, options);     
        } 
        
        return false;
    }
   
    public Boolean extractOpportunity(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options){
        String OppId = (string)inputMap.get('ContextId');
        Map<Id,User> userMap = new Map<Id,User>([Select id, name from user where IsActive=true]);
        List<Profile> profileName = [Select Id, name From Profile where id=:userinfo.getProfileId() and 
        name='System Administrator' Limit 1];
        List<PermissionSetAssignment> permSets = [SELECT id, PermissionSetId, PermissionSet.Name FROM PermissionSetAssignment
         WHERE AssigneeId =:Userinfo.getUserId() AND PermissionSet.Name = 'I_C_Pricing_Analyst'];
        List<AggregateResult> results = [Select count(Id) from OpportunityLineItem where OpportunityId=:OppId];
        Integer total = Integer.valueOf(results[0].get('expr0'));
        List<Object> OppList = new List<Object>();
        
        for(OpportunityLineItem opl : [Select id, name, CreatedDate, SWAN_IsActive__c, vlocity_cmt__ServicePointId__c, 
            vlocity_cmt__ServicePointId__r.vlocity_cmt__ServicePointNumber__c, vlocity_cmt__JSONAttribute__c, 
            Opportunity.SWAN_Fuel_Type__c From OpportunityLineItem Where OpportunityId=:OppId and vlocity_cmt__ServicePointId__c!=null])
        {
            String lastModDate='',custAQ='', custSOQ='';
            Map<string,object> AttributeMap = new Map<string,object>();
            if(!String.isblank(opl.vlocity_cmt__JSONAttribute__c))
            {
                for(object Attr : (List<object>) ((Map<String, Object>)JSON.deserializeUntyped(opl.vlocity_cmt__JSONAttribute__c)).get('SWAN_SP_ATT_CAT'))
                {
                    String key = (string) ((map<string,object>)Attr).get('attributeuniquecode__c');
                    if(key == 'SWAN_ATT_CUST_AQ' || key == 'SWAN_ATT_CUST_EFF_FROM' || key == 'SWAN_ATT_CUST_EFF_TO' || 
                    key == 'SWAN_ATT_CUST_EUC' || key =='SWAN_ATT_CUST_SOQ' || key == 'SWAN_LAST_MOD_DATE' || 
                    key == 'SWAN_ATT_CUST_SOQ' || key == 'SWAN_LAST_MOD_BY' || key == 'SWAN_ATT_CUST_EAC')
                    {
                        AttributeMap.put(key,((MAP<string,object>)((map<string,object>)Attr).get('attributeRunTimeInfo')).get('value'));
                        if(key == 'SWAN_LAST_MOD_DATE')
                        {
                            Object tempObj = (((MAP<string,object>)((map<string,object>)Attr).get('attributeRunTimeInfo')).get('value'));//.toString();
                            if(tempObj != null)
                            {
                            String temp = string.valueOf(tempObj);
                            temp=temp.replace('T',' ');
                            temp=temp.substringBefore('.');
                            DateTime dt = dateTime.valueOf(temp);
                            lastModDate = dt.format('dd/MM/yyyy HH:mm');
                            }
                        }  
                        if(key == 'SWAN_ATT_CUST_AQ')
                        {
                            Object temp = (((MAP<string,object>)((map<string,object>)Attr).get('attributeRunTimeInfo')).get('value'));
                            custAQ = (temp!=null?String.valueOf(temp) + ' kWh':'');
                        }
                        if(key == 'SWAN_ATT_CUST_SOQ')
                        {
                            Object temp = (((MAP<string,object>)((map<string,object>)Attr).get('attributeRunTimeInfo')).get('value'));
                            custSOQ = (temp!=null?String.valueOf(temp) + ' kWh':'');
                        } 
                    }
                }
            }
            String lasModBy=(AttributeMap.containsKey('SWAN_LAST_MOD_BY')?(string)AttributeMap.get('SWAN_LAST_MOD_BY'):''); 
            
            Map<String, Object> eachRec = new Map<String, Object>();
            eachRec.put('CreatedDate', opl.CreatedDate);
            eachRec.put('DisplayAmendAction', (profileName.size()>0?true:false));
            eachRec.put('CustomerAQ', custAQ);
            eachRec.put('SOQ', custSOQ);
            eachRec.put('EUC', (AttributeMap.containsKey('SWAN_ATT_CUST_EUC')?AttributeMap.get('SWAN_ATT_CUST_EUC'):''));
            eachRec.put('HavePermission', (permSets.size()>0?true:false));
            eachRec.put('Id', opl.Id);
            eachRec.put('LastModifiedBy', (userMap.containsKey(lasModBy)?userMap.get(lasModBy).Name:''));
            eachRec.put('Msg', (total<1?'No Data to Display':null));
            eachRec.put('NumOLIs', total);
            eachRec.put('FuelType', opl.Opportunity.SWAN_Fuel_Type__c);
            eachRec.put('ServicePoint', opl.vlocity_cmt__ServicePointId__r.vlocity_cmt__ServicePointNumber__c);
            eachRec.put('Status', opl.SWAN_IsActive__c);
            eachRec.put('SPId', opl.vlocity_cmt__ServicePointId__c);
            eachRec.put('CustomerEAC', (AttributeMap.containsKey('SWAN_ATT_CUST_EAC')?AttributeMap.get('SWAN_ATT_CUST_EAC'):''));
            
            Date customerAQEffFromDateValue;
            Date customerAQEffToDateValue;
            
            if(AttributeMap.containsKey('SWAN_ATT_CUST_EFF_FROM'))
            {
                object value = AttributeMap.get('SWAN_ATT_CUST_EFF_FROM');
                customerAQEffFromDateValue = ((value!=null && Value != '')?date.valueOf(((string)value).contains('T')?((string)value).substring(0,((string)value).indexOf('T')):(string)value):null);
                //system.debug(value +'<=fromdate=>'+customerAQEffFromDateValue);
            }
            if(AttributeMap.containsKey('SWAN_ATT_CUST_EFF_TO'))
            {
                object value = AttributeMap.get('SWAN_ATT_CUST_EFF_TO');
                customerAQEffToDateValue = ((value!=null && Value != '')?date.valueOf(((string)value).contains('T')?((string)value).substring(0,((string)value).indexOf('T')):(string)value):null);
                //system.debug(value +'<=todate=>'+customerAQEffFromDateValue);
            }
            
            eachRec.put('EFD', customerAQEffFromDateValue);
            eachRec.put('ETD', customerAQEffToDateValue);
                        
            //eachRec.put('EFD', (AttributeMap.containsKey('SWAN_ATT_CUST_EFF_FROM')?(AttributeMap.get('SWAN_ATT_CUST_EFF_FROM')):''));
            //eachRec.put('ETD', (AttributeMap.containsKey('SWAN_ATT_CUST_EFF_TO')?(AttributeMap.get('SWAN_ATT_CUST_EFF_TO')):''));
            eachRec.put('ModifiedDate', lastModDate);
            OppList.add(eachRec);
        }
        if(total<1)
        {
            Map<String, Object> eachRec = new Map<String, Object>();
            eachRec.put('NumOLIs', total);
            eachRec.put('Msg', (total<1?'No Data to Display':null));
            outputMap.put('OLI', eachRec);
        }
        else
        outputMap.put('OLI', OppList); 
        /*
        if(profileName.size()>0)
        { 
            Map<String, Object> admProfile = new Map<String, Object>(); 
            admProfile.put('ProfileId',profileName[0].Id);
            outputMap.put('UserProfile',admProfile);
            
            admProfile = new Map<String, Object>(); 
            admProfile.put('Id',profileName[0].Id);
            outputMap.put('ProfileName',admProfile);
        }  
        if(permSets.size()>0)
        {
            Map<String, Object> PermMap = new Map<String, Object>(); 
            PermMap.put('Name',permSets[0].PermissionSet.Name);
            PermMap.put('Id',permSets[0].PermissionSetId);
            outputMap.put('PermissionSetId',PermMap);
        } */                             
        return true;
    }
        
}