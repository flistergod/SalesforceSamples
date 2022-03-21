public class SWAN_ScheduleATLASReport implements Schedulable{
   public void execute(SchedulableContext SC) {
      Database.executeBatch(new SWAN_BatchGenerateCSVForAtlas(),2000);
   }
}