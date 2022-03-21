public without sharing class SWAN_UpdateContracts implements Database.Batchable<sObject>, Database.Stateful{
    
    Id CounterSignNotRequiredRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Counter Signature not Required').getRecordTypeId();
    Id CounterSignRequiredRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Counter Signature Required').getRecordTypeId();
    Id NotCountersignedContractRecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Not countersigned Contract').getRecordTypeId();
            
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([select id, Account.SWAN_Customer_Segment__c, recordtypeid from contract limit 50000]);
    }
    
    public void execute(Database.BatchableContext BC, List<Contract> ContractList){
        
        List<Contract> UpdateContractList = new List<Contract>();
        
        for(Contract contractUpdate : ContractList){
        
            if(contractUpdate.recordtypeid == null || String.isBlank(contractUpdate.recordtypeid)){
                contractUpdate.recordtypeid = CounterSignRequiredRecordTypeId;
                UpdateContractList.add(contractUpdate);
            }
            else if(contractUpdate.recordtypeid == NotCountersignedContractRecordTypeId){
                contractUpdate.recordtypeid = CounterSignNotRequiredRecordTypeId;
                UpdateContractList.add(contractUpdate);
            }
        }
        
        if(UpdateContractList.size()>0)
            Database.update(UpdateContractList);
    }
    
    public void finish(Database.BatchableContext BC){
        
    }
}