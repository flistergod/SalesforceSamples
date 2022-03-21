public with sharing class LAN_ctrlTrialKeyMock implements HttpCalloutMock {
    public enum MOCK_TYPE {SUCCESS, FAIL}
    public static final String MOCK_URL = 'https://key.lansweeper.com/EA28AE53B23C4AF5A0335D21494B5334/HelpdeskTrial.txt';

    private MOCK_TYPE type;

    public LAN_ctrlTrialKeyMock(MOCK_TYPE type) {
        this.type = type;
    }

    public HttpResponse respond(HttpRequest req) {
        if(type == MOCK_TYPE.SUCCESS) {
            return responseSuccess(req);
        } else {
            return responseFail(req);
        }
    }

    private HttpResponse responseSuccess(HttpRequest req) {
        HttpResponse resp = new HttpResponse();
        resp.setStatusCode(200);
        resp.setBody('{"URL": "' + MOCK_URL + '"}');
        return resp;
    }

    private HttpResponse responseFail(HttpRequest req) {
        HttpResponse resp = new HttpResponse();
        resp.setStatusCode(500);
        return resp;
    }
}