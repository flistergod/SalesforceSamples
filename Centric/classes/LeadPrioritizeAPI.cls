@RestResource(urlMapping='/lead/*')
global without sharing class LeadPrioritizeAPI {
  
    @HttpGet
    global static List<Lead> doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        List<Lead>	 result = [SELECT Id, UniqueReferenceNumber__c, RecordTypeId, Name, Status, LeadPriority__c, OwnerId FROM Lead];
        return result;
    }

    // US 7452
    @HttpPost
    global static Response prioritizeLead(String leadURN) {
        system.debug(leadURN);
        List<Lead> listLead = [SELECT Id, UniqueReferenceNumber__c, Status, LeadPriority__c FROM Lead WHERE UniqueReferenceNumber__c = :leadURN];
        if(listLead.size()<1){
            System.debug('Lead with URN ['+ leadURN +'] does not exist');
            return new Response(404,'Lead Not Found');
        }
        Lead workingLead = listLead[0];
        if(workingLead.LeadPriority__c == 'High'){
            return new Response(304,'Lead is already in High priority');
        }
        workingLead.LeadPriority__c = 'High';
        System.debug(workingLead);
        update workingLead;
        
        return new Response(200,'Lead priority updated');
    }
    
    global class Response{
        private Integer statusCode;
        private String message;
        
        public Response(Integer status, String msg){
            message = msg;
            statusCode = status;
        }
    }
}