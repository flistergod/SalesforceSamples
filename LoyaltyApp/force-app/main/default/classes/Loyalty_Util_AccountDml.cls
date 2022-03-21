/*
   @Author: João Almeida
   @CreatedDate: 16/09/2020
   @Description: Contains the CRUD methods for Account SObject
 */
public with sharing class Loyalty_Util_AccountDml {
    private class AccountDmlException extends Exception {}

    public Loyalty_Util_AccountDml() {

    }

    /*
       @Description: gets loyalty program record by the record type name
       @param1: Api name of the record type
       @Return: the loyalty program record related to the record type name
       @Exception: thrown when there is no record related or if there is more than 1 record related
	 */
    public Account getAccountDataByAccountId(Id accountId) {
        Account account = null;
        if (accountId != null && !String.isEmpty(accountId)) {
            list<Account> accounts = [SELECT Id, Name, Loyalty_Opportunity_Total_of_Purchases__c FROM Account WHERE Id = :accountId];
            if (accounts != null && !accounts.isEmpty()) {
                account = accounts[0];
            }
            else {
                throw new AccountDmlException('getAccountDataByAccountId Error: ' + 'no account found for ID: ' + accountId);
            }
        }
        else {
            throw new AccountDmlException('getAccountDataByAccountId Error: ' + 'the account Id is invalid: ' + accountId);
        }
        return account;
    }
}