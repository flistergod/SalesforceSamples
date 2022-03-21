@isTest
public class SWAN_ScheduleWINSReport_Test {
  @isTest
  public static void SWAN_ScheduleWINSReport_TestMethod()
  {
        String CRON_EXP = '0 0 0 3 9 ? 2022';
        Test.startTest();
        SWAN_ScheduleWINSReport winRep = new SWAN_ScheduleWINSReport();
        String jobID = system.schedule('Test WINSReport', CRON_EXP, winRep);  
        Test.stopTest();
      
  }
    
}