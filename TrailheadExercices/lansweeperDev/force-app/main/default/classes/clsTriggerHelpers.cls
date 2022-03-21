public with sharing class clsTriggerHelpers {
    private static Map<String, Boolean> mapTriggerRan = new Map<String, Boolean>();

    public static void setTriggerRan(String triggerName, Boolean hasRan) {
        mapTriggerRan.put(triggerName, hasRan);
    }
    
    public static void setTriggerRan(String triggerName) {
        mapTriggerRan.put(triggerName, true);
    }
    
    public static Boolean getTriggerRan(String triggerName) {
        if(mapTriggerRan.containsKey(triggerName)) return mapTriggerRan.get(triggerName);
        else return false;
    }
}