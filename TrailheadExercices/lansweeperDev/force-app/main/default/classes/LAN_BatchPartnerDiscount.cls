global class LAN_BatchPartnerDiscount implements Database.Batchable<sObject>,schedulable {
    private Set<String> possibleOpptyRenewalRecordTypes;
    private Set<String> possibleOpptyAmendRecordTypes;
    private Set<String> specificOpptyRenewalRecordTypes;

    global LAN_BatchPartnerDiscount(){
        //'LAN_Renewal_with_Up_Sell_Cross_Sell' is excluded because is related to Amend & Renew
        possibleOpptyRenewalRecordTypes = new Set<String>{'LAN_Renewal','LAN_Renewal_with_Down_Sell', 'LAN_Delayed_Renewal'};
        specificOpptyRenewalRecordTypes = new Set<String>{'LAN_Renewal_with_Up_Sell_Cross_Sell','LAN_Renewal_with_Down_Sell'};
        possibleOpptyAmendRecordTypes = new Set<String>{'LAN_Up_Sell_Cross_Sell'};
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT Opportunity__r.LAN_Partner_Account__c, Opportunity__r.LAN_Contract_Restart_with_Up_Sell__c, Opportunity__r.LAN_Opportunity_Record_Type_Dev_Name__c, Opportunity__r.SBQQ__PrimaryQuote__c,Opportunity__r.SBQQ__PrimaryQuote__r.SBQQ__Type__c, Opportunity__r.SBQQ__PrimaryQuote__r.SBQQ__Opportunity2__c,Opportunity__r.SBQQ__PrimaryQuote__r.SBQQ__Status__c, Opportunity__r.LAN_Related_Contract__c, Opportunity__r.LAN_Original_Contract__c, Opportunity__r.SBQQ__AmendedContract__c, Opportunity__r.SBQQ__RenewedContract__c,' +
            ' Opportunity__r.SBQQ__RenewedContract__r.SBQQ__Quote__r.SBQQ__Status__c, Opportunity__r.SBQQ__RenewedContract__r.SBQQ__Quote__c, Opportunity__r.SBQQ__RenewedContract__r.SBQQ__RenewalForecast__c, Opportunity__r.SBQQ__RenewedContract__r.SBQQ__RenewalQuoted__c, ' +
            ' Opportunity__r.SBQQ__AmendedContract__r.SBQQ__Quote__r.SBQQ__Status__c, Opportunity__r.SBQQ__AmendedContract__r.SBQQ__Quote__c, Opportunity__r.SBQQ__AmendedContract__r.SBQQ__RenewalForecast__c, Opportunity__r.SBQQ__AmendedContract__r.SBQQ__RenewalQuoted__c,Opportunity__r.LAN_Original_Contract__r.SBQQ__Quote__r.SBQQ__Status__c, Opportunity__r.LAN_Original_Contract__r.SBQQ__Quote__c, Opportunity__r.LAN_Original_Contract__r.SBQQ__RenewalForecast__c, Opportunity__r.LAN_Original_Contract__r.SBQQ__RenewalQuoted__c, ' +
            ' ID, Opportunity__c, Type__c, Status__c' +
            ' FROM Batch_Queue__c ' + 
            'Where Type__c = \'Batch - Partner Discount\' and Status__c = \'To be recalculated\''
        );
    }
    
    global void execute(Database.BatchableContext bc, List<Batch_Queue__c> records){
        Map<Id,Contract> contractsToUpdate = new Map<Id,Contract>();
        List<Batch_Queue__c> batchQueuesToUpdate = new List<Batch_Queue__c>();
        Map<Id,Contract> contractsToggleForecastToUpdate = new Map<Id,Contract>();
        Map<Id,Contract> contractsToggleQuotedToUpdate = new Map<Id,Contract>();
        for (Batch_Queue__c batchQueue : records) {
            boolean isOpptyToRecalculate = false;
            
            //no recalculate for Amend & Renew as we cannot recalculate the Credit
            if (!batchQueue.Opportunity__r.LAN_Contract_Restart_with_Up_Sell__c) {
                isOpptyToRecalculate = true;
            }
            else if (this.possibleOpptyRenewalRecordTypes.contains(batchQueue.Opportunity__r.LAN_Opportunity_Record_Type_Dev_Name__c)) {
                isOpptyToRecalculate = true;
            }
            else if (this.possibleOpptyAmendRecordTypes.contains(batchQueue.Opportunity__r.LAN_Opportunity_Record_Type_Dev_Name__c)) {
                isOpptyToRecalculate = true;
            }
            Contract contractToUpdate = String.isNotBlank(batchQueue.Opportunity__r.SBQQ__RenewedContract__c) ? batchQueue.Opportunity__r.SBQQ__RenewedContract__r : (String.isNotBlank(batchQueue.Opportunity__r.SBQQ__AmendedContract__c) ? batchQueue.Opportunity__r.SBQQ__AmendedContract__r : batchQueue.Opportunity__r.LAN_Original_Contract__r);
            system.debug('############### batch - contract to update #########');
            system.debug(contractToUpdate);
            if (contractToUpdate != null) {
                // if quote defined is renewal,Opportunity__r.SBQQ__PrimaryQuote__r.SBQQ__Type__c
                if (String.isNotBlank(batchQueue.Opportunity__r.SBQQ__PrimaryQuote__c)) {
                    system.debug('############### batch - quote Id and quote oppty id #########');
                    system.debug(batchQueue.Opportunity__r.SBQQ__PrimaryQuote__c);
                    system.debug(batchQueue.Opportunity__r.SBQQ__PrimaryQuote__r.SBQQ__Opportunity2__c);
                    system.debug(batchQueue.Opportunity__r.SBQQ__PrimaryQuote__r.SBQQ__Status__c == 'Draft');
                    // if oppty is renewal up sell or down sell
                    if (this.specificOpptyRenewalRecordTypes.contains(batchQueue.Opportunity__r.LAN_Opportunity_Record_Type_Dev_Name__c)) {
                        if (contractToUpdate.SBQQ__RenewalForecast__c) {
                            contractToUpdate.SBQQ__RenewalForecast__c = false;
                            if (contractsToggleForecastToUpdate.get(contractToUpdate.Id) == null) {
                        		contractsToggleForecastToUpdate.put(contractToUpdate.Id,contractToUpdate);
                        	}
                        }
                        else {
                            contractToUpdate.SBQQ__RenewalForecast__c = true;
                        }
                        
                        if (contractsToUpdate.get(contractToUpdate.Id) == null) {
                        	contractsToUpdate.put(contractToUpdate.Id,contractToUpdate);
                        }
                    }
                    else {
                        // if quote is draft, toggle field Renewal Quoted on the contract
                        if (batchQueue.Opportunity__r.SBQQ__PrimaryQuote__r.SBQQ__Status__c == 'Draft') {
                            if (contractToUpdate.SBQQ__RenewalQuoted__c) {
                                contractToUpdate.SBQQ__RenewalQuoted__c = false;
                                if (contractsToggleQuotedToUpdate.get(contractToUpdate.Id) == null) {
                                    contractsToggleQuotedToUpdate.put(contractToUpdate.Id,contractToUpdate);
                                }
                            }
                            else {
                                contractToUpdate.SBQQ__RenewalQuoted__c = true;
                            }
                            
                            if (contractsToUpdate.get(contractToUpdate.Id) == null) {
                                contractsToUpdate.put(contractToUpdate.Id,contractToUpdate);
                            }
                        }
                    }
                }
                else {
                    if (contractToUpdate.SBQQ__RenewalForecast__c) {
                        contractToUpdate.SBQQ__RenewalForecast__c = false;
                        if (contractsToggleForecastToUpdate.get(contractToUpdate.Id) == null) {
                            contractsToggleForecastToUpdate.put(contractToUpdate.Id,contractToUpdate);
                        }
                    }
                    else {
                        contractToUpdate.SBQQ__RenewalForecast__c = true;
                    }
                    
                    if (contractsToUpdate.get(contractToUpdate.Id) == null) {
                    	contractsToUpdate.put(contractToUpdate.Id,contractToUpdate);
                    }
                }
            }
            batchQueue.Status__c = 'Recalculated';
            batchQueuesToUpdate.add(batchQueue);
        }
        System.debug(contractsToUpdate);
        System.debug(contractsToggleForecastToUpdate);
        System.debug(contractsToggleQuotedToUpdate);
        If(!Test.isRunningTest()){
        	update contractsToUpdate.values();
            for (Contract forecastToUpdate : contractsToggleForecastToUpdate.values()) {
                forecastToUpdate.SBQQ__RenewalForecast__c = true;
            }
            if (!contractsToggleForecastToUpdate.isEmpty()) {
                update contractsToggleForecastToUpdate.values();
            }
            for (Contract quotedToUpdate : contractsToggleQuotedToUpdate.values()) {
                quotedToUpdate.SBQQ__RenewalQuoted__c = true;
            }
            if (!contractsToggleQuotedToUpdate.isEmpty()) {
                update contractsToggleQuotedToUpdate.values();
            }
        }
        //update batchQueuesToUpdate;
    }
    
    global void finish(Database.BatchableContext bc){
    } 
    
    global void execute(SchedulableContext sc) {
      	LAN_BatchPartnerDiscount batchPD = new LAN_BatchPartnerDiscount(); 
        If(Test.isRunningTest()){
              ID jobID = Database.executeBatch(batchPD);
              System.abortJob(jobID);
        }else{
              Database.executeBatch(batchPD,1);
        }
    }
}