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
global with sharing class LAN_clsWebServiceMock implements  WebServiceMock {

   

    
    global void  doInvoke(
        Object stub,
        Object request,
        Map<String, Object> response,
        String endpoint,
        String soapAction,
        String requestName,
        String responseNS,
        String responseName,
        String responseType) {
    docSample.EchoStringResponse_element respElement = 
        new docSample.EchoStringResponse_element();
    respElement.EchoStringResult = (String) request.toString();
    response.put('response_x', respElement); 
}
     
}