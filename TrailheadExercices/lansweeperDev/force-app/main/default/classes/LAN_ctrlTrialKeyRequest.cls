public with sharing class LAN_ctrlTrialKeyRequest {
    @InvocableMethod(label='Trial Key - Inventory/Helpdesk')
    public static List<String> requestTrialKeyFromFlow(List<LAN_TrialKeyRequestClass> requests){
        Id jobId = System.enqueueJob(new LAN_clsQueueTrialKeyCallout(requests));

        return new List<String>{jobId};
    }

    public class LAN_TrialKeyResultClass {
        @InvocableVariable
        public String url;
        @InvocableVariable
        public String key;

        public LAN_TrialKeyResultClass(String url, String key) {
            this.url = url;
            this.key = key;
        }
    }

    public class LAN_TrialKeyRequestClass {
        @InvocableVariable
        public Integer duration;
        @InvocableVariable
        public String email;
        @InvocableVariable
        public String requester;
        @InvocableVariable
        public String user;
        @InvocableVariable
        public Integer agentslimit;
        @InvocableVariable
        public String type;
        @InvocableVariable
        public Boolean cloudAccess;
        @InvocableVariable
        public String recordId;

        public LAN_TrialKeyRequestClass() {

        }

        public LAN_TrialKeyRequestClass(String recordId, Integer duration, String email, String requester, String user, Boolean cloudAccess) {
            this.duration = duration;
            this.email = email;
            this.requester = requester;
            this.user = user;
            this.cloudAccess = cloudAccess;
            this.recordId = recordId;
        }

        public LAN_TrialKeyRequestClass(String recordId, Integer duration, String email, String requester, String user, Integer agentslimit) {
            this.duration = duration;
            this.email = email;
            this.requester = requester;
            this.user = user;
            this.agentslimit = agentslimit;
            this.recordId = recordId;
        }
    }
}