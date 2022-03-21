/**
* Opportunity Domain
*/
public without sharing class OpportunityDomain extends SObjectDomain {
    
    //==================================================================================================================
    // Core
    //==================================================================================================================
    private static final Map<String, RecordTypeInfo> RT_OPPORTUNITYOBJECT = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName();
    private static final Id RT_OPPORTUNITYEV = RT_OPPORTUNITYOBJECT.get('EV_ACQUISITION').getRecordTypeId();
    
    public override SObjectType getSObjectType() {
        return Opportunity.SObjectType; 
    }
    
    //==================================================================================================================
    // Event Handlers
    //==================================================================================================================
    
    //Trigger context goes here
    /*
    protected override void beforeInsert(List<SObject> records) {

         
    }
    */
    
    protected override void beforeUpdate(Map<Id, SObject> updatedRecords, Map<Id, SObject> oldRecords) {
       	checkChangeOnNotAllowedFields(updatedRecords, oldRecords);
    }
    
    protected override void afterInsert(Map<Id, SObject> records) {        
        setOpportunityUniqueReferenceNumber(records.keyset());
    }    
    /*
    protected override void afterUpdate(Map<Id, SObject> updatedRecords, Map<Id, SObject> oldRecords) {        
        
    }
    */
    
    //==================================================================================================================
    // Automation
    //==================================================================================================================
    
    // US 7929 (Opportunity reference)
    private void setOpportunityUniqueReferenceNumber(Set<Id> setIdsOpportunities){
        System.debug('After');
        List<Opportunity> listOpportunities = [Select Id, RecordTypeId, OpportunityAutoNumber__c, UniqueReferenceNumber__c FROM Opportunity WHERE Id IN :setIdsOpportunities];
        List<Opportunity> updatedOpportunities = new List<Opportunity>();
        for(Opportunity varOpportunity : listOpportunities){
            if(varOpportunity.RecordTypeId == RT_OPPORTUNITYEV){ 
                String autonumber = varOpportunity.OpportunityAutoNumber__c;
                varOpportunity.UniqueReferenceNumber__c = 'EV-'+autonumber;
                System.debug(varOpportunity);
                updatedOpportunities.add(varOpportunity);
            }
        }
        if(updatedOpportunities.size() > 0){
            update updatedOpportunities;
        }
        
    }
    
    private void checkChangeOnNotAllowedFields(Map<Id, SObject> updatedRecords, Map<Id, SObject> oldRecords){
        //Get RecordTypes 
        Map<Id,String> mapRTypeIdDevName = getRTypesIDsDeveloperNames();
        System.debug('Map recordTypes: '+mapRTypeIdDevName);
        
        //Get FieldSet Names
        set<String> setFieldSets = new set<String>();
        for(Opportunity varOpp: (List<Opportunity>)oldRecords.values()){
            setFieldSets.add('NA_'+mapRTypeIdDevName.get(varOpp.recordTypeId)+'_'+varOpp.StageName.replaceAll('\\s+',''));            
        }
        System.debug('FieldsSets: '+setFieldSets);
        
        //Get Field Sets
        Map<String, FieldSet> mapFieldSet = new  Map<String, FieldSet>();
        for(String varFieldSet: setFieldSets){
            if(hasFieldSet(getSObjectType(), varFieldSet)){
            	mapFieldSet.put(varFieldSet, getFieldSet(getSObjectType(), varFieldSet));
            }
        }	 
        System.debug('FieldsSets Fields: '+mapFieldSet);
        
        //Check if NOT ALLOWED Fields are edited
        for(Opportunity varOpp: (List<Opportunity>)updatedRecords.values()){
            String fieldSet = 'NA_'+mapRTypeIdDevName.get(varOpp.recordTypeId)+'_'+((Opportunity)oldRecords.get(varOpp.Id)).StageName.replaceAll('\\s+','');
            if(mapFieldSet.get(fieldSet) != null){
                System.debug('FieldsSet FOUND: '+fieldSet);
            	String fieldNotAllowedMessageError = '';
                for (FieldSetMember field : mapFieldSet.get(fieldSet).getFields()){
                    System.debug('Field Validated: '+field.getSObjectField());
                    if(varOpp.get(field.getSObjectField()) != oldRecords.get(varOpp.Id).get(field.getSObjectField())){
                        fieldNotAllowedMessageError += field.getLabel()+', ';
                    }
            	}
                if(fieldNotAllowedMessageError != ''){
                	fieldNotAllowedMessageError = fieldNotAllowedMessageError.subString(0, fieldNotAllowedMessageError.length()-2);
                	varOpp.addError('The fields '+fieldNotAllowedMessageError+' cannot be edited on this Stage'+varOpp.stageName);
                }
        	}
        }
    }
    
    //==================================================================================================================
    // Auxiliar Methods
    //==================================================================================================================
   
	public static Boolean hasFieldSet(SObjectType sObjectType, String fieldSetName) {
		return getFieldSet(sObjectType, fieldSetName) != null;
	}
	
	public static FieldSet getFieldSet(SObjectType sObjectType, String fieldSetName) {
		return sObjectType.getDescribe().fieldSets.getMap().get(fieldSetName);
	}
    
    public static Map<Id, String> getRTypesIDsDeveloperNames() {
        Map<Id,String> mapRTypeIdDevName = new Map<Id,String>();
        for(RecordTypeInfo varRTypeInfo: RT_OPPORTUNITYOBJECT.values()){
            mapRTypeIdDevName.put(varRTypeInfo.getRecordTypeId(), varRTypeInfo.getDeveloperName());
        }
        return mapRTypeIdDevName;
	}
}