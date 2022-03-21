@isTest
private with sharing class LAN_clsRESTServiceTest {
    @isTest
    static void calloutSuccess() {
        Test.setMock(HttpCalloutMock.class, new LAN_clsRESTServiceMock(LAN_clsRESTServiceMock.MOCK_TYPE.SUCCESS));
        LAN_clsRESTService call = new LAN_clsRESTService();
        call.setMethod('GET');
        call.setBodyAsString('body');
        call.setAuthSubscriptionKey();
        call.setCustomHeader('key', 'value');
        call.setEndpoint('endpoint');
        
        HttpResponse resp = call.invokeCallout();
        System.assertEquals(200, resp.getStatusCode());
    }

    @isTest
    static void calloutFailed() {
        Test.setMock(HttpCalloutMock.class, new LAN_clsRESTServiceMock(LAN_clsRESTServiceMock.MOCK_TYPE.FAIL));
        LAN_clsRESTService call = new LAN_clsRESTService();
        call.setMethod('GET');
        call.setBodyAsString('body');
        call.setAuthSubscriptionKey();
        call.setCustomHeader('key', 'value');
        call.setEndpoint('endpoint');
        
        HttpResponse resp = call.invokeCallout();
        System.assertEquals(500, resp.getStatusCode());
    }
}