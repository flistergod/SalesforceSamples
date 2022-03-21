@isTest
public class SWAN_ScheduleATLASReportTest {
	@isTest
  public static void scheduleClassTest()
  {
        SWAN_ScheduleATLASReport m = new SWAN_ScheduleATLASReport();
        String sch = '0 12 9 * * ?';
        String jobID = system.schedule('ATLAS Report', sch, m);  
      
  }
    
}