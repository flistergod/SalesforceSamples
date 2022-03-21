@IsTest
public class LAN_UpdateRenewalContractActionTest {
    private static Contract contract {
        get {
            return [SELECT Id, SBQQ__RenewalForecast__c FROM Contract];
        }
    }

    @testSetup
    private static void setupTestData() {
        
        Account a = new Account(Name='Test', RecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('LAN_Account').getRecordTypeId());
        insert a;
        
        Contract c = new Contract(AccountId = a.Id, Status = 'Draft', StartDate = System.today(), ContractTerm  = 12);
        insert c;
    }

    @isTest
    private static void testUpdateRenewalContractForecastAction() {
        test.startTest();
        contract.SBQQ__RenewalForecast__c = true;

        LAN_UpdateContractWrapper contractWrapper = new LAN_UpdateContractWrapper();
        contractWrapper.fieldToUpdate = 'SBQQ__RenewalForecast__c';
        contractWrapper.isToggleField = true;
        contractWrapper.contracts = new List<Contract>{contract};

        LAN_UpdateRenewalContractAction.UpdateRenewalContractAction(new List<LAN_UpdateContractWrapper>{contractWrapper});

        test.stopTest();
    }

    @isTest
    private static void testUpdateRenewalContractQuotedAction() {
        test.startTest();
        contract.SBQQ__RenewalQuoted__c = true;

        LAN_UpdateContractWrapper contractWrapper = new LAN_UpdateContractWrapper();
        contractWrapper.fieldToUpdate = 'SBQQ__RenewalQuoted__c';
        contractWrapper.isToggleField = false;
        contractWrapper.contractId = contract.Id;

        LAN_UpdateRenewalContractAction.UpdateRenewalContractAction(new List<LAN_UpdateContractWrapper>{contractWrapper});

        test.stopTest();
    }
}