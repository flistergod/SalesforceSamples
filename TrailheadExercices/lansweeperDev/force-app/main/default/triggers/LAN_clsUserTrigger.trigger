trigger LAN_clsUserTrigger on User (after insert, after update) {
    List<ID> userContactIds = new List<ID>();
    for (User u : trigger.new) {
        if (string.isNotBlank(u.ContactId)) {
            userContactIds.add(u.ContactId);
        }
    }
    LAN_clsHandleContacts.futureUpdateContacts(userContactIds);
}