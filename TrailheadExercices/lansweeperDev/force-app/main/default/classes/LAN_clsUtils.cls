public with sharing class LAN_clsUtils {
    private static Set<Id> setReviewedRecords = new Set<Id>();

    public static void addReviewedRecord(Id recordId) {
        setReviewedRecords.add(recordId);
    }

    public static Boolean hasReviewedRecord(Id recordId) {
        return setReviewedRecords.contains(recordId);
    }
}