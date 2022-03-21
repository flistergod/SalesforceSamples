public class LAN_UpdateRenewalContractAction {
    @InvocableMethod(label='Update Renewal Contract Fields' description='Given defined parameters, it will update contract fields.' category='Contract')
    public static void UpdateRenewalContractAction(List<LAN_UpdateContractWrapper> toUpdate) {
        system.debug('######## LAN_UpdateRenewalContractAction ##########');
        if (string.isNotBlank(toUpdate[0].contractId)) {
            Contract contractToUpdate = new Contract();
            contractToUpdate.Id = toUpdate[0].contractId;
            switch on toUpdate[0].fieldToUpdate {
                when 'SBQQ__RenewalQuoted__c' {
                    contractToUpdate.SBQQ__RenewalQuoted__c = true;
                }
            }
            toUpdate[0].contracts = new List<Contract>{contractToUpdate};
        }
        updateRenewalContracts(JSON.serialize(toUpdate[0]));
    }

    @future
    private static void updateRenewalContracts(string contractsToUpdate) {
        LAN_UpdateContractWrapper contractUpdateData = (LAN_UpdateContractWrapper)JSON.deserialize(contractsToUpdate, LAN_UpdateContractWrapper.class);
        List<Contract> toggleContracts = new List<Contract>();
        List<Contract> setContracts = new List<Contract>();
        system.debug(contractUpdateData);
        if (contractUpdateData.contracts != null && !contractUpdateData.contracts.isEmpty()) {
            for(Contract contract : contractUpdateData.contracts) {
                switch on contractUpdateData.fieldToUpdate {
                    when 'SBQQ__RenewalQuoted__c' {
                        if (contractUpdateData.isToggleField) {
                            toggleContracts.add(new Contract(Id=contract.Id,SBQQ__RenewalQuoted__c = false));
                        }
                        setContracts.add(new Contract(Id=contract.Id,SBQQ__RenewalQuoted__c = true));
                    }
                    when 'SBQQ__RenewalForecast__c' {
                        if (contractUpdateData.isToggleField) {
                            toggleContracts.add(new Contract(Id=contract.Id,SBQQ__RenewalForecast__c = false));
                        }
                        setContracts.add(new Contract(Id=contract.Id,SBQQ__RenewalForecast__c = true));
                    }
                }
            }

            system.debug('## toggle to false');
            system.debug(toggleContracts);
            if (!toggleContracts.isEmpty()) {
                update toggleContracts;
            }
            system.debug('## toggle to true');
            system.debug(setContracts);
            if (!setContracts.isEmpty()) {
                update setContracts;
            }
        }
    }
}