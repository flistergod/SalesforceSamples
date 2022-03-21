public with sharing class LAN_wSaveResult {
    public Id recordId;
    public String errorMessage;

    public LAN_wSaveResult(Id recordId, String errorMessage) {
        this.recordId = recordId;
        this.errorMessage = errorMessage;
    }
}