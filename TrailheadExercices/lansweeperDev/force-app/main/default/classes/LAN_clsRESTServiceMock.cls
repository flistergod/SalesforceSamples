/**
 * @description       : 
 * @author            : Flistergod
 * @group             : 
 * @last modified on  : 11-11-2020
 * @last modified by  : Flistergod
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   11-11-2020   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public with sharing class LAN_clsRESTServiceMock implements HttpCalloutMock {
    public enum MOCK_TYPE {SUCCESS, FAIL}

    private MOCK_TYPE type;

    public LAN_clsRESTServiceMock(MOCK_TYPE type) {
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
        return resp;
    }

    private HttpResponse responseFail(HttpRequest req) {
        HttpResponse resp = new HttpResponse();
        resp.setStatusCode(500);
        return resp;
    }

}