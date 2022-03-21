trigger LAN_clsAccountTrigger on Account (before insert, before update, after insert, after update) {
    new LAN_clsAccountTriggerHandler().run();
}