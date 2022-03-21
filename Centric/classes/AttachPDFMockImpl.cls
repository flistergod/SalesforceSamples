@isTest
global class AttachPDFMockImpl implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response.
        // Set response values, and 
        // return response.
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('test data');
        res.setStatusCode(200);
        return res;
    }
}