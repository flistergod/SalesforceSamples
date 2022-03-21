public without sharing class  SWAN_ContractLogicHandler
{
    public static void generateBCRFile()
    {
        Id recTypeIdRenewal; Id recTypeIdUpgrade;
        //Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(label.OptyRenewalRecordType);
        //if(rtMapByName != null && rtMapByName.getRecordTypeId() != null)
        //    recTypeId = rtMapByName.getRecordTypeId();
        
        Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Opportunity.getRecordTypeInfosByName();
        if(rtMapByName != null && rtMapByName.containskey(label.OptyRenewalRecordType)){
            recTypeIdRenewal =  rtMapByName.get(label.OptyRenewalRecordType).getRecordTypeId();
        }


        if(rtMapByName != null && rtMapByName.containskey(label.OptyUpgradeRecordType)){
            recTypeIdUpgrade =  rtMapByName.get(label.OptyUpgradeRecordType).getRecordTypeId();
        }

        
        
        List<Id> quoteIdList = new List<Id>();
        List<Id> accountIdList = new List<Id>();
        List<String> paymentTermList = new List<String>();
        Map<Id, Id> ownerMap = new Map<Id, Id>();
        List<Id> tempList = new List<Id>();
        List<Id> oppIdListRenewal = new List<Id>();
        List<Id> oppIdListUpgrade = new List<Id>();
        Map<Id, Id> QuoteContractMap = new Map<Id, Id>();
        Map<Id, String> fileNameMap = new Map<id, String>();
        
        for(Contract c : (List<Contract>)Trigger.new)
        {
            Contract oldCon = (Contract)Trigger.oldmap.get(c.id);
            if(c.vlocity_cmt__QuoteId__c != null && c.status != oldCon.status && oldCon.status!='Contract Counter Signed'
             &&  c.status == 'Contract Signed' && c.vlocity_cmt__OpportunityId__c != null)
                tempList.add(c.vlocity_cmt__OpportunityId__c);
        }
        
        if(recTypeIdRenewal != null)
        {
            for(Opportunity opp: [Select id From Opportunity where Id IN: tempList and recordTypeId =:recTypeIdRenewal])
            oppIdListRenewal.add(opp.id);
        }

        if(recTypeIdUpgrade != null)
        {
            for(Opportunity opp: [Select id From Opportunity where Id IN: tempList and recordTypeId =:recTypeIdUpgrade])
            oppIdListUpgrade.add(opp.id);
        }
        
        for(Contract c : (List<Contract>)Trigger.new)
        {
            Contract oldCon = (Contract)Trigger.oldmap.get(c.id);
            if(c.vlocity_cmt__QuoteId__c != null && c.status != oldCon.status && oldCon.status!='Contract Counter Signed' 
            && c.status == 'Contract Signed')
            {
                quoteIdList.add(c.vlocity_cmt__QuoteId__c);
                accountIdList.add(c.AccountId);
                paymentTermList.add(c.SWAN_Payment_Term__c.Trim());
                ownerMap.put(c.vlocity_cmt__QuoteId__c, c.OwnerId);
                QuoteContractMap.put(c.vlocity_cmt__QuoteId__c,c.id);
                if(c.vlocity_cmt__OpportunityId__c != null && oppIdListRenewal.size()>0 && oppIdListRenewal.contains(c.vlocity_cmt__OpportunityId__c)){
                   fileNameMap.put(c.vlocity_cmt__QuoteId__c, 'Renewal'); 
                }
                else if(c.vlocity_cmt__OpportunityId__c != null && oppIdListUpgrade.size()>0 && oppIdListUpgrade.contains(c.vlocity_cmt__OpportunityId__c)){
                    fileNameMap.put(c.vlocity_cmt__QuoteId__c, 'Upgrade'); 
                 }
                else{
                    fileNameMap.put(c.vlocity_cmt__QuoteId__c, 'Acquisition');  
                }
            }
        }
        system.debug('====='+quoteIdList);    
        BCR_File_Generation.generateFile(quoteIdList, accountIdList, paymentTermList, ownerMap, fileNameMap,QuoteContractMap);
        SWAN_Constants.QuoteTriggerExecuted = true;
    }
}