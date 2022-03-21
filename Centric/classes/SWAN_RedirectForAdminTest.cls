@isTest
public class SWAN_RedirectForAdminTest{
   
   public static testmethod void SWAN_RedirectForAdminTest()
   {
       Boolean sysAdmin = SWAN_RedirectForAdmin.getUserProfileData();
       
       System.assert(sysAdmin);
       
   }
}