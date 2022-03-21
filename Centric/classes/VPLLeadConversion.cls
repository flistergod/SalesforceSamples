global with sharing class VPLLeadConversion implements vlocity_cmt.VlocityOpenInterface
{
    global VPLLeadConversion() { }
    
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        Boolean result = true;
        try
        {
            if (methodName.equals('LeadConversion'))
            {
                LeadConversion(inputMap,outMap,options);
            }
            else if(methodName.equals('CloneRecord'))
            {
                CloneRecord(inputMap,outMap,options);
            }
            else 
            {
                result = false;
            }   
        } 
        catch(leadConversionException e)
        {System.debug('VPLLeadConversion:invokeMethod -> exception: '+e);
            result = false;
            throw new leadConversionException(Label.DuplicateAccount);}
        
        catch(Exception e)
        {System.debug('VPLLeadConversion:invokeMethod -> exception: '+e);
            result = false;}
        
        return result;
    }
    
    public class leadConversionException extends Exception {}

    string BuildSearchQuery(string ObjectApiName, string RecordId) {
        Map<String, Schema.SObjectField> fields = Schema.getGlobalDescribe().get(ObjectApiName).getDescribe().fields.getMap();
        List<String> editableFields = new List<String>();
        for(Schema.SObjectField fieldRef : fields.values()) {
            Schema.DescribeFieldResult fieldResult = fieldRef.getDescribe();
            if(fieldResult.isCreateable()) {
                editableFields.add(fieldResult.getname());
            }
        }
        String querystring ='SELECT ID,';
        for(string api : editableFields)
        {
            querystring+=api+',';
        }
        querystring=querystring.removeendignorecase(',')+' FROM '+ObjectApiName+' WHERE ID=\''+RecordId+'\'';
        return querystring;
    }
    
    void LeadConversion(Map<String, Object> inputMap, Map<String, Object> outMap,Map<String,Object> options)
    {
        System.debug('ContextId '+(String)inputMap.get('DRId_Lead'));
        System.debug('Input Map '+inputMap);
        String leadId =(String)inputMap.get('DRId_Lead');
        System.debug('lead id '+leadid);
        String BusinessTypeVal ='';
        String OpptyObjectApiName = 'Opportunity';
        if(inputMap.containsKey('LeadDetails'))
        {
            Map<string,object> BusinessTypeMap = (Map<string,object>) inputMap.get('LeadDetails');
            if(BusinessTypeMap.containsKey('BusinessType'))
            {
                BusinessTypeVal = (String) BusinessTypeMap.get('BusinessType');
            }
        }
        String isBrokerAccount = String.ValueOf(inputMap.get('IsBrokerAccount'));
        System.debug('isBrokerAccount'+isBrokerAccount);
            
        lead le = new lead();
        if (Schema.sObjectType.Lead.isAccessible()) {
        le = [SELECT Id,Lead_Type__c FROM Lead Where Id=: leadId];
        }
        System.debug('lead '+le);
        Database.LeadConvertResult lcr;
      
        try
        {
            Database.LeadConvert lc = new Database.LeadConvert(); 
        
            lc.setLeadId(leadId); 
 
            if(isBrokerAccount=='true' || isBrokerAccount != null)
            {
                lc.setDoNotCreateOpportunity(TRUE);
            }else {
                        lc.setDoNotCreateOpportunity(FALSE);
                    }

                     
             if (Schema.sObjectType.LeadStatus.isAccessible()) {
            LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1]; 
  
            lc.setConvertedStatus(convertStatus.MasterLabel);
          
            lcr = Database.convertLead(lc);
          
             }
          
        }
        catch(Exception e)
        {throw new leadConversionException(e.getMessage());}
        
        
        
        lcr.getAccountId();
        System.debug('=====lcr.getAccountId()====>'+lcr.getAccountId());
        System.debug('=====lcr.getOpportunityId()====>'+lcr.getOpportunityId());
        outMap.put('AccountId',lcr.getAccountId());
        outMap.put('ContactId',lcr.getContactId());
        outMap.put('OpportunityId',lcr.getOpportunityId());
        outMap.put('CloseDate',date.today().addmonths(6).year()+'-'+ (date.today().addmonths(6).month()<10?'0'+date.today().addmonths(6).month():string.valueof(date.today().addmonths(6).month()))+'-'+ Date.daysInMonth(date.today().addmonths(6).year(), date.today().addmonths(6).month()));   
        System.debug('=====le.Lead_Type__c====>'+le.Lead_Type__c);
        if(isBrokerAccount =='true')
        {
            Id broker_recdtype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
                Account broker_Acc_Update= new Account(Id=lcr.getAccountId(),RecordtypeId=broker_recdtype,vlocity_cmt__PrimaryContactId__c=lcr.getContactId(),type=BusinessTypeVal);
                if (Schema.sObjectType.Account.fields.Name.isUpdateable()) {
                    Update broker_Acc_Update;
                }
        }   
        else
        {
            Id devRecordTypeId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId();
                    Account accUpdate1= new Account(Id=lcr.getAccountId(),RecordtypeId=devRecordTypeId1,vlocity_cmt__PrimaryContactId__c=lcr.getContactId(),type=BusinessTypeVal);
                    if (Schema.sObjectType.Account.fields.Name.isUpdateable()) {
                        Update accUpdate1;
                    }
        }

        sObject opptyObj = Schema.getGlobalDescribe().get(OpptyObjectApiName).newSObject();
        opptyObj = Database.query(BuildSearchQuery(OpptyObjectApiName,lcr.getOpportunityId()));
        outMap.put('OpptyData',opptyObj);
    }
    
    void CloneRecord(Map<String, Object> inputMap, Map<String, Object> outMap,Map<String,Object> options)
    {
        String ObjectApiName = (String)options.get('ObjectAPI');
        String RecordId = (String)options.get('RecordId');
        
        String querystring=BuildSearchQuery(ObjectApiName,RecordId);
        //system.debug('==$$$$$$$$$$$$$$$\n'+querystring);
        sObject sObj = Schema.getGlobalDescribe().get(ObjectApiName).newSObject();
        sObj = Database.query(querystring);
        system.debug('==>>>>>>>>>>'+sObj);
        
        sObject ClonedsObj = Schema.getGlobalDescribe().get(ObjectApiName).newSObject();
        ClonedsObj = sObj.clone(false, false, false, false);
        insert(ClonedsObj);
        ClonedsObj.put('SWAN_Fuel_Type__c','Electricity');
        update ClonedsObj;
        outMap.put('ClonedOpportunityId',ClonedsObj.id);
    }
}