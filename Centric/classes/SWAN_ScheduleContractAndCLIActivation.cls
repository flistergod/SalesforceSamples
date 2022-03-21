global with sharing class SWAN_ScheduleContractAndCLIActivation implements Schedulable{
    global SWAN_ScheduleContractAndCLIActivation() {

    }

    global void execute(SchedulableContext SC) {
        Database.executeBatch(new SWAN_BatchSetCLIStatus(true));
        Database.executeBatch(new SWAN_BatchSetContractStatus(true));
    }
}