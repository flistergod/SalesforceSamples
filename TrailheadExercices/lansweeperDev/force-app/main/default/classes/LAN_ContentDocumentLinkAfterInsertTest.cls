@isTest
public class LAN_ContentDocumentLinkAfterInsertTest{
    public static testMethod void UserTriggerTest() {
            
        User adminUser = [Select Id, UserRoleId From User Where Profile.Name='LAN_System_Administrator' AND IsActive = True Limit 1];

        System.runAs(adminUser){
            Account a = new Account(Name='Test Account Name');
            insert a;
            
            ContentVersion cv = new ContentVersion();
            cv.Description= 'Test Description';
            cv.Title = 'Test Title';
            cv.PathOnClient = 'Test Title.snote';
            cv.VersionData = EncodingUtil.base64Decode('Test Version Data');
            insert cv;
            
            ContentVersion insertedCV = [Select Id, ContentDocumentId From ContentVersion Where Id = :cv.Id];
            
            ContentDocumentLink cdl = new ContentDocumentLink ();
            cdl.LinkedEntityId = a.id;
            cdl.ContentDocumentId = insertedCV.ContentDocumentId;

            insert cdl;
      
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