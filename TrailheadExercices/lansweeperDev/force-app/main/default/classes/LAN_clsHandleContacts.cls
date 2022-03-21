public class LAN_clsHandleContacts {
    @future
    public static void futureUpdateContacts(List<ID> userContactIds)
        {   
        List<Contact> contactsToUpdate = new List<Contact>();
        List<User> user = new List<User>();
        for(ID contactId : userContactIds) {            
            contactsToUpdate.add(new Contact(
                Id = contactId,
                LAN_Community_User__c = [SELECT Id FROM User WHERE ContactId = :contactId].Id));
            }
        update contactsToUpdate;
        }
}