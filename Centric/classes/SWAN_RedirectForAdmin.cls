public class SWAN_RedirectForAdmin {

    @AuraEnabled
    public static Boolean getUserProfileData() {
        String profileId = UserInfo.getProfileId();
        Profile sysAdminPro = new Profile();
        if(Schema.sObjectType.Profile.isAccessible())
        {
          sysAdminPro = [select id from profile where name='System Administrator'];
        }
        Boolean sysAdmin = false;
        if(sysAdminPro.Id != null){
        if(sysAdminPro.Id == profileId)
        {
            sysAdmin = true;
        } }
     return sysAdmin;
    }
}