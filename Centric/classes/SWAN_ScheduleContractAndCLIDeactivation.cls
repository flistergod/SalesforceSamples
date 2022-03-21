global with sharing class SWAN_ScheduleContractAndCLIDeactivation implements Schedulable{
    global SWAN_ScheduleContractAndCLIDeactivation() {

    }

    global void execute(SchedulableContext SC) {
        Database.executeBatch(new SWAN_BatchSetCLIStatus(false));
        Database.executeBatch(new SWAN_BatchSetContractStatus(false));
    }
}