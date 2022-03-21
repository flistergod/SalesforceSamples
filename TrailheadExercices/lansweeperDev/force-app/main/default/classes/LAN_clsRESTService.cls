public with sharing class LAN_clsRESTService {
    private HttpRequest req;
    private final String OCP_APIM_SUBSCRIPTION_KEY = 'Ocp-Apim-Subscription-Key';

    public class LAN_RESTException extends Exception {}

    public LAN_clsRESTService() {
        this.req = new HttpRequest();
        
    }

    public void setMethod(String method) {
        req.setMethod(method);
    }

    public void setCustomHeader(String key, String value) {
        System.Debug(key + value);
        req.setHeader(key, value);
    }

    public void setAuthSubscriptionKey() {
        setCustomHeader(OCP_APIM_SUBSCRIPTION_KEY, '{!$Credential.Password}');
    }

    public void setBodyAsString(String body) {
        req.setBody(body);
    }

    public void setEndpoint(String endpoint) {
        req.setEndpoint(endpoint);
    }

    public HttpResponse invokeCallout() {
        Http http = new Http();

        try {
            HttpResponse resp = Http.send(req);

            switch on resp.getStatusCode() {
                when 200, 201, 500 {
                    // OK
                    return resp;
                } when else {
                    throw new LAN_RESTException('Status code: ' + resp.getStatusCode() + ' with the following response: ' + resp.getBody());
                }
            }
        } catch (Exception e) {
            //TODO: Create utility to handle exception logic. Handle in the form of a Case?
        }

        return null;
    }
}