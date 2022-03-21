/**
* Lead Domain
*/
public without sharing class LeadDomain extends SObjectDomain {
    
    private static final Map<String, RecordTypeInfo> RT_LEADOBJECT = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName();
    private static final Id  RT_LEADEV = RT_LEADOBJECT.get('EV').getRecordTypeId();
    
    //==================================================================================================================
    // Core
    //==================================================================================================================
    
    public override SObjectType getSObjectType() {
        return Lead.SObjectType; 
    }
    
    //==================================================================================================================
    // Event Handlers
    //==================================================================================================================
    
    //Trigger context goes here
    
    /*
    protected override void beforeInsert(List<SObject> records){
        
    }  
                   
    
    protected override void beforeUpdate(Map<Id, SObject> updatedRecords, Map<Id, SObject> oldRecords) {
    
    }
    */
    protected override void afterInsert(Map<Id, SObject> records) {        
        System.debug('After Insert');
        setUniqueReferenceNumber(records.keyset());
    }    
    /*
    protected override void afterUpdate(Map<Id, SObject> updatedRecords, Map<Id, SObject> oldRecords) {        
    
    }
    */
    //==================================================================================================================
    // Automation
    //==================================================================================================================
    
    //Logic Methods go here
    
    //==================================================================================================================
    // Auxiliar Methods
    //==================================================================================================================
    
    // US 7444
    private void setUniqueReferenceNumber(Set<Id> setIdsLeads){
        System.debug('After');
        List<Lead> listLeads = [Select Id, RecordTypeId, LeadAutoNumber__c, UniqueReferenceNumber__c FROM Lead WHERE Id IN :setIdsLeads];
        final String[] chars = new String[]{'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z'};
        
        String[] arr = new String[2];
        Integer idx;
        List<Lead> updatedLeads = new List<Lead>();
        for(Lead varLead : listLeads){
            if(varLead.RecordTypeId == RT_LEADEV){
                System.debug(varLead);
                arr[0] = chars[(Integer)(Math.random()*(chars.size()-1))];
                arr[1] = chars[(Integer)(Math.random()*(chars.size()-1))];
                String autonumber = varLead.LeadAutoNumber__c;
                System.debug(autonumber);
                varLead.UniqueReferenceNumber__c = arr[0]+autonumber+arr[1];
                System.debug(varLead);
                updatedLeads.add(varLead);
            }
        }
        System.debug('updatedLeads');
        if(updatedLeads.size() > 0){
            update updatedLeads;
        }
        
    }
    
    //7450
    public Id existingLead(string email){
        List<Lead> leadQuery = [SELECT Id, Status, RecordTypeId FROM Lead WHERE Email =:email AND RecordTypeId =:RT_LEADEV AND Status != 'Qualified' AND Status != 'Unqualified'];
        if(leadQuery.size()>0){
            return leadQuery[0].Id;
        }
        return null;
    }
}