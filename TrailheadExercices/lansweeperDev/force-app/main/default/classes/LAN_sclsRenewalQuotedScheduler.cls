public with sharing class LAN_sclsRenewalQuotedScheduler implements Schedulable {
    private static Integer BATCH_SIZE = 1;

    public void execute(SchedulableContext sc) {
        LAN_bclsRenewalQuoted b = new LAN_bclsRenewalQuoted();
        Database.executeBatch(b, BATCH_SIZE);
    }
}