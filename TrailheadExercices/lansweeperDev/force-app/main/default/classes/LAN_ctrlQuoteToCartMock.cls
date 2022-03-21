public with sharing class LAN_ctrlQuoteToCartMock implements HttpCalloutMock {
    public enum MOCK_TYPE {SUCCESS, FAIL}
    public static final String MOCK_URL = 'https://store.lansweeper.com/447/uurl-hh9keepkmj';

    private MOCK_TYPE type;

    public LAN_ctrlQuoteToCartMock(MOCK_TYPE type) {
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