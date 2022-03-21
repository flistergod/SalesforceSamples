public with sharing class LAN_sclsRenewalForcecastScheduler implements Schedulable {
    private static Integer BATCH_SIZE = 1;

    public void execute(SchedulableContext sc) {
        LAN_bclsRenewalForecast forecastBatch = new LAN_bclsRenewalForecast();
        Database.executeBatch(forecastBatch, BATCH_SIZE);
    }
}