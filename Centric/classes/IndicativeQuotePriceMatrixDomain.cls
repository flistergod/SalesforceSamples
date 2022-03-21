public without sharing class IndicativeQuotePriceMatrixDomain extends SObjectDomain {
    
    public override SObjectType getSObjectType() {
        return IndicativeQuotePriceMatrix__c.SObjectType; 
    }
    
    protected override void beforeInsert(List<SObject> records) {
        setHigherPriceRange(records);
    }    
    
    protected override void beforeUpdate(Map<Id, SObject> updatedRecords, Map<Id, SObject> oldRecords) {
        list<sObject> records = updatedRecords.values();
        setHigherPriceRange(records);
        setPriceMatrixVersion(records);
    }
    
    protected override void afterUpdate(Map<Id, SObject> updatedRecords, Map<Id, SObject> oldRecords) {
        getPriceChanges(updatedRecords,oldRecords);
    }
    
    //Logic Methods
    public void getPriceChanges(Map<Id, SObject> updatedRecords, Map<Id, SObject> oldRecords){
        list<IndicativeQuotePriceMatrix__c> lstNewIndicativeQuotePriceMatrix = updatedRecords.values();
        list<IndicativeQuotePriceMatrix__c> lstOldIndicativeQuotePriceMatrix = oldRecords.values();
        list<String> lstIndicativeQuoteSiteMatrixNames = new list<String>();
        list<IndicativeQuoteSite__c> lstIndicativeQuoteSite = new list<IndicativeQuoteSite__c>();
        
        for(IndicativeQuotePriceMatrix__c newMatrix : lstNewIndicativeQuotePriceMatrix){
            for(IndicativeQuotePriceMatrix__c oldMatrix : lstOldIndicativeQuotePriceMatrix){
                if(newMatrix.id == oldMatrix.id && newMatrix.SpotPrice__c != oldMatrix.SpotPrice__c && newMatrix.Status__c == 'Active'){
                    lstIndicativeQuoteSiteMatrixNames.add(newMatrix.Name);
                }
            }
        } 
        
        lstIndicativeQuoteSite = [select id, pricechanged__c, IndicativeQuote__c from IndicativeQuoteSite__c where
                                  IndicativeQuote__r.status__c='Active'and IndicativeQuote__r.QuoteOutcome__c ='In Progress' 
                                  and CombinationID__c in: lstIndicativeQuoteSiteMatrixNames];
        
        for(IndicativeQuoteSite__c iqs : lstIndicativeQuoteSite){
            iqs.pricechanged__c = true;
        }
        update lstIndicativeQuoteSite;
        
    }
    
    public void setHigherPriceRange(list<SObject> records){
        list<IndicativeQuotePriceMatrix__c> lstIndicativeQuotePriceMatrix = records;
        decimal upliftPercentage;
        list<uplift__mdt> lstUplifts = [select id,percentage__c, key__c from uplift__mdt where key__c='Spot Price' and percentage__c!=0];
        if(lstUplifts.size()>0){
            upliftPercentage = lstUplifts[0].percentage__c;
            for(IndicativeQuotePriceMatrix__c iqpm :lstIndicativeQuotePriceMatrix){
            	iqpm.HigherRangePrice__c = ((Integer) Math.round((iqpm.SpotPrice__c +(iqpm.SpotPrice__c* upliftPercentage/100)) / 100.0) * 100);
        	}
        }else{
            for(IndicativeQuotePriceMatrix__c iqpm :lstIndicativeQuotePriceMatrix){
            	iqpm.HigherRangePrice__c = iqpm.SpotPrice__c;
        	}
        }
    }
    
    public void setPriceMatrixVersion(list<sObject> records){
        for(IndicativeQuotePriceMatrix__c iqpm : (list<IndicativeQuotePriceMatrix__c>) records){
            iqpm.Version__c+=1;
        }
    }
    
}