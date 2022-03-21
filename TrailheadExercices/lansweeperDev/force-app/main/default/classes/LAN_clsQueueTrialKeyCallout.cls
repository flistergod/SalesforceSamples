public with sharing class LAN_clsQueueTrialKeyCallout implements Queueable, Database.AllowsCallouts {
    private static final String INVENTORY_KEY_URL = 'URL';
    private static final String INVENTORY_KEY = 'Key';
    private LAN_ctrlTrialKeyRequest.LAN_TrialKeyRequestClass request;

    public static final String NAMED_CRED_INVENTORY_REQUEST = 'callout:LAN_Inventory_Trial_Key';
    public static final String NAMED_CRED_HELPDESK_REQUEST = 'callout:LAN_Helpdesk_Trial_Key';

    public class LAN_ctrlTrialKeyRequestException extends Exception {}

    public LAN_clsQueueTrialKeyCallout(List<LAN_ctrlTrialKeyRequest.LAN_TrialKeyRequestClass> requests) {
        this.request = requests[0]; 
    }

    public void execute(QueueableContext context) {
        LAN_clsRESTService req = new LAN_clsRESTService();

        switch on request.type {
            when 'Inventory' {
                req.setEndpoint(NAMED_CRED_INVENTORY_REQUEST);
            } when 'Helpdesk' {
                req.setEndpoint(NAMED_CRED_HELPDESK_REQUEST);
            }
        }

        req.setMethod('POST');
        req.setCustomHeader('cache-control', 'no-cache');
        req.setCustomHeader('Content-Type', 'application/json');
        req.setAuthSubscriptionKey();
        req.setBodyAsString(JSON.serialize(request));

        HttpResponse resp = req.invokeCallout();

        switch on resp.getStatusCode() {
            when 200, 201 {
                LAN_ctrlTrialKeyRequest.LAN_TrialKeyResultClass result = getKey(resp);
                LAN_License_Key__c keyUpdate = new LAN_License_Key__c(Id = request.recordId, 
                                                                        LAN_License_Key_Location__c = result.url,
                                                                        LAN_License_Key__c = result.key);
                update keyUpdate;
            } when 500 {
                throw new LAN_ctrlTrialKeyRequestException('We could not connect towards the trial license key manager. Please contact your System Administrator');
            } when else {
                throw new LAN_ctrlTrialKeyRequestException('An unexpected issue happened. Please contact your System Adminitrator.');
            }
        }
    }

    private static LAN_ctrlTrialKeyRequest.LAN_TrialKeyResultClass getKey(HttpResponse resp) {
        Map<String, Object> mapResult = (Map<String, Object>) JSON.deserializeUntyped(resp.getBody());

        if(!mapResult.containsKey(INVENTORY_KEY_URL)) {
            throw new LAN_ctrlTrialKeyRequestException('NO_KEY');
        }

        return new LAN_ctrlTrialKeyRequest.LAN_TrialKeyResultClass((String) mapResult.get(INVENTORY_KEY_URL), (String) mapResult.get(INVENTORY_KEY));
    }
}