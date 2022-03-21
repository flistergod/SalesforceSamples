public class SWAN_ScheduleWINSReport implements Schedulable{
   public void execute(SchedulableContext SC) {
      Database.executeBatch(new SWAN_BatchGenerateCSVForWins(),2000);   
   }
}