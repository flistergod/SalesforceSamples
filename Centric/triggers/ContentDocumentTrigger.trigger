/**
* EV Opportunity File Input Trigger.
*/


trigger ContentDocumentTrigger on ContentDocumentLink  (after insert) {
    private static final Map<String, RecordTypeInfo> RT_OPPORTUNITYOBJECT = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName();
    private static final Id RT_OPPORTUNITYEV = RT_OPPORTUNITYOBJECT.get('EV_ACQUISITION').getRecordTypeId();
    
    set<Opportunity> optSet = new set<Opportunity>();
    for (ContentDocumentLink cdl : trigger.new) {
        String objId = cdl.LinkedEntityId;
        if(objId.left(3)=='006'){ // '006' -> Salesforce OpportunityId Prefix
            Opportunity opt = [Select Id, RecordTypeId, StageName, QuoteDocument__c, QuoteVariationsDocument__c  FROM Opportunity WHERE id =:objId];
                if(opt.RecordTypeId == RT_OPPORTUNITYEV){
                    if(opt.StageName == 'Record Quote'){
                        opt.QuoteDocument__c = true;
                    }
                    else if(opt.StageName == 'Record Variations'){
                        opt.QuoteVariationsDocument__c = true;
                    }
                    optSet.add(opt);
                }
        } 
    }
    if(optSet.size()>0){
        update new List<Opportunity>(optSet);
    }
}