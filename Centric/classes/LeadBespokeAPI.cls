@RestResource(urlMapping='/leadapi/*')
global without sharing class LeadBespokeAPI {
    
    global static string missingField;
    private static final Map<String, RecordTypeInfo> RT_LEADOBJECT = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName();
    private static final Id  RT_LEADEV = RT_LEADOBJECT.get('EV').getRecordTypeId();
    
    @HTTPPost
    global static LeadCaptureWrapper.LeadBespokeResponseWrapper bespoke() {
        system.debug('request body: ');
        try{
            RestRequest req = RestContext.request;
            String requestBody = req.requestBody.toString();
            system.debug('request body: '+requestBody);
            
            LeadCaptureWrapper.LeadWrapper leadWrapper = (LeadCaptureWrapper.LeadWrapper) JSON.deserialize(requestBody, LeadCaptureWrapper.LeadWrapper.class);
            Map<String, Object> mpLead = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(leadWrapper));
            if(hasNullField(mpLead)){
                LeadCaptureWrapper.LeadBespokeResponseWrapper response = new LeadCaptureWrapper.LeadBespokeResponseWrapper();
                response.status = 'Error';
                response.statusDetail = 'Missing the following required field: '+missingField;
                response.statuscode = 400;
                return response;
            }
            list<LeadCaptureWrapper.indicativeQuoteSite> lstIndQuoteSiteWrapper = leadWrapper.indicativeQuoteSite;
            
            
            lead leadToInsert = new lead();
            
            //check existing lead
            List<Lead> lstLead = [SELECT Id, Status, RecordTypeId, ownerId FROM Lead WHERE Email =:leadWrapper.email AND RecordTypeId =:RT_LEADEV AND Status != 'Qualified' AND Status != 'Unqualified'];
            if(lstLead.size() > 0){
                leadToInsert = lstLead[0];
            }
            
            if(leadToInsert.OwnerId == null || string.valueof(leadToInsert.OwnerId).substring(0,3) != '005'){
                Database.DMLOptions dmo = new Database.DMLOptions();
                dmo.assignmentRuleHeader.useDefaultRule= true;
                leadToInsert.setOptions(dmo);
            }
            leadToInsert.recordtypeid = RT_LEADEV;
            leadToInsert.LeadPriority__c = 'High';
            leadToInsert.Status = 'New';
            leadToInsert.email = leadWrapper.email;
            leadToInsert.CampaignCode__c = leadWrapper.campaignCode;
            leadToInsert.Company = leadWrapper.company;
            leadToInsert.Phone = leadWrapper.contactNumber;
            leadToInsert.FirstName = leadWrapper.firstName;
            leadToInsert.LastName = leadWrapper.lastName;
            leadToInsert.LeadChannelPersonalIdentifier__c = leadWrapper.personalIdentifier;
            leadToInsert.LeadChannel__c = leadWrapper.channel;
            leadToInsert.ConsentEmailUpdates__c = leadWrapper.emailConsent;
            leadToInsert.Product__c = leadWrapper.product;
            leadToInsert.MainPostCode__c = leadWrapper.postCodeMainSite;
            leadToInsert.CallBackTimePreference__c = leadWrapper.callbacktime;
            leadToInsert.EVInterestComments__c = leadWrapper.interestComments;
            leadToInsert.EVChargingSpeed__c = leadWrapper.evChargingSpeed;
            leadToInsert.EVSitesAmount__c = leadWrapper.numberOfSites;
            leadToInsert.EVChargingPointsAmount__c = leadWrapper.numberOfChargingPoints;
            database.upsert(leadToInsert);
            
            
            
            /*leadToInsert.Status = 'Working';
            update leadToInsert;*/
            
            LeadCaptureWrapper.LeadBespokeResponseWrapper response =new LeadCaptureWrapper.LeadBespokeResponseWrapper();
            response.status= 'Success';
            response.statusDetail= 'Data has been submitted successfully';
            response.statusCode = 200;
            response.leadURN = [select id, UniqueReferenceNumber__c from lead where id=: leadToInsert.id].UniqueReferenceNumber__c;
            return response;
            
        }catch(exception e){
            system.debug(e.getMessage()+' - '+e.getLineNumber());
            LeadCaptureWrapper.LeadBespokeResponseWrapper response = new LeadCaptureWrapper.LeadBespokeResponseWrapper();
            response.status = 'Error';
            response.statusDetail = e.getMessage()+' - '+e.getLineNumber();
            response.statuscode = 400;
            return response;
        }
    }
    
    public static Boolean hasNullField(Map<String, Object> mpLead) {
        for (String curr : mpLead.keyset()) {
            system.debug(curr);
            if (curr != 'personalIdentifier' && curr != 'firstName' && curr != 'campaignCode' && curr != 'callbacktime' && curr != '' && 
                curr != 'callbackConsent' && curr != 'numberOfSites' && curr != 'indicativeQuoteSite' && curr != 'evChargingSpeed' && 
                curr != 'interestComments' && curr != 'indicativeQuoteConfirmEmail' && curr != 'webIndicativeQuoteReference' &&
                (mpLead.get(curr) == null || mpLead.get(curr) == '')){
                    missingField = curr;
                    return true;
                }
        }
        return false;
        
    }
    
    
}