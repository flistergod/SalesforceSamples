public with sharing class AccountController {
  public static List<Account> getAllActiveAccounts(){


    return [SELECT Id,Name,Active__c FROM Account WHERE Active__c = 'yE'];

  }



    public static List<Account> updateOlderAccounts() {
      // Get the 5 oldest accounts
      Account[] oldAccounts = [SELECT Id, Description 
      FROM Account ORDER BY CreatedDate ASC LIMIT 5];
      // loop through them and update the Description field
      for (Account acct : oldAccounts) {
          acct.Description = 'Heritage Account';
      }
      // save the change you made
      update oldAccounts;

      return oldAccounts;
    }

    AccountController.updateOlderAccounts();

}
