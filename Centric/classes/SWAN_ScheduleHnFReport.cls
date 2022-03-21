public class SWAN_ScheduleHnFReport implements Schedulable{
   public void execute(SchedulableContext SC) {
      Database.executeBatch(new SWAN_BatchGenerateCSVHedgAndForecast(),2000);
   }
}