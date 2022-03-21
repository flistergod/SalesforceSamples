@isTest
public class LAN_clsUserTriggerTest {
    public static testMethod void UserTriggerTest() {
            
        UserRole userrole = [Select Id, DeveloperName From UserRole Where DeveloperName = 'LAN_CEO' Limit 1];

        User adminUser = [Select Id, UserRoleId From User Where Profile.Name='LAN_System_Administrator' AND IsActive = True Limit 1];

        adminUser.UserRoleId = userRole.Id;
        update adminUser;

        System.runAs(adminUser){
            Account a = new Account(Name='Test Account Name');
            insert a;

            Contact c = new Contact(FirstName = 'Test FN', LastName = 'Contact Last Name', AccountId = a.id, Email = 'test@contact.com');
            insert c;

            User user = new User();
            user.ProfileID = [Select Id From Profile Where Name='LAN_Partner_Community_User'].id;
            user.EmailEncodingKey = 'UTF-8';
            user.LanguageLocaleKey = 'en_US';
            user.TimeZoneSidKey = 'America/Los_Angeles';
            user.LocaleSidKey = 'en_US';
            user.FirstName = 'first';
            user.LastName = 'last';
            user.Username = 'testPartnerUser@123455678.com';
            user.CommunityNickname = 'testUser12345';
            user.Alias = 't1';
            user.Email = 'no@email.com';
            user.IsActive = true;
            user.ContactId = c.Id;

            insert user;
      
        /*
        c = [
            select Id, LAN_Community_User__c
            from Contact
            where Id = : c.id];
            system.assertEquals(c.LAN_Community_User__c, user.id);
       */     
        }
    }
}