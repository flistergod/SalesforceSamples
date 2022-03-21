@isTest
public class LeadBespokeAPITest {
    
    static testmethod void testSuccess(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/leadapi/bespoke'; //Request URL
        req.httpMethod = 'POST';
        
        list<LeadCaptureWrapper.IndicativeQuoteSite> lstIndQuoteSite = new list<LeadCaptureWrapper.IndicativeQuoteSite>();
        LeadCaptureWrapper.IndicativeQuoteSite indQuoteSite = new LeadCaptureWrapper.IndicativeQuoteSite();
        indQuoteSite.chargeRate ='asd';
        indQuoteSite.designatedParking ='asd';
        indQuoteSite.distance ='asd';
        indQuoteSite.groundType ='asd';
        indQuoteSite.maxNumVehicle ='asd';
        indQuoteSite.mountingType ='asd';
        indQuoteSite.postCode ='asd';
        lstIndQuoteSite.add(indQuoteSite);
        
        LeadCaptureWrapper.LeadWrapper resp = new LeadCaptureWrapper.LeadWrapper();
        resp.email = 'asdasd@cgi.com';
        resp.firstName ='asd';
        resp.lastName ='asd';
        resp.company ='asd';
        resp.contactNumber ='asd';
        resp.numberOfSites ='asd';
        resp.callbackConsent = false;
        resp.campaignCode ='asd';
        resp.channel ='Web';
        resp.personalIdentifier ='asd';
        resp.indicativeQuoteConfirmEmail ='asd';
        resp.indicativeQuoteSite =lstIndQuoteSite;
        resp.webIndicativeQuoteReference ='asd';
        resp.emailConsent  =false;
        resp.product ='Installation';
        resp.callbacktime ='asd';
        resp.postCodeMainSite ='asd';
        resp.interestComments ='asd';
        resp.evChargingSpeed ='asd';
        resp.numberOfChargingPoints ='asd';
        string respString = JSON.serialize(resp);
        
        req.requestBody = Blob.valueOf(respString);
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        LeadCaptureWrapper.LeadBespokeResponseWrapper responseWs = LeadBespokeAPI.bespoke();
        Test.stopTest();
        
        //System.assert(responseWs.leadURN != null);
    }
    
    static testmethod void testError(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/leadapi/bespoke'; //Request URL
        req.httpMethod = 'POST';
        
        list<LeadCaptureWrapper.IndicativeQuoteSite> lstIndQuoteSite = new list<LeadCaptureWrapper.IndicativeQuoteSite>();
        LeadCaptureWrapper.IndicativeQuoteSite indQuoteSite = new LeadCaptureWrapper.IndicativeQuoteSite();
        indQuoteSite.chargeRate ='asd';
        indQuoteSite.designatedParking ='asd';
        indQuoteSite.distance ='asd';
        indQuoteSite.groundType ='asd';
        indQuoteSite.maxNumVehicle ='asd';
        indQuoteSite.mountingType ='asd';
        indQuoteSite.postCode ='asd';
        lstIndQuoteSite.add(indQuoteSite);
        
        LeadCaptureWrapper.LeadWrapper resp = new LeadCaptureWrapper.LeadWrapper();
        //resp.email = 'asdasd@cgi.com';
        resp.firstName ='asd';
        resp.lastName ='asd';
        resp.company ='asd';
        resp.contactNumber ='asd';
        resp.numberOfSites ='asd';
        resp.callbackConsent = false;
        resp.campaignCode ='asd';
        resp.channel ='Web';
        resp.personalIdentifier ='asd';
        resp.indicativeQuoteConfirmEmail ='asd';
        resp.indicativeQuoteSite =lstIndQuoteSite;
        resp.webIndicativeQuoteReference ='asd';
        resp.emailConsent  =false;
        resp.product ='Installation';
        resp.callbacktime ='asd';
        resp.postCodeMainSite ='asd';
        resp.interestComments ='asd';
        resp.evChargingSpeed ='asd';
        resp.numberOfChargingPoints ='asd';
        string respString = JSON.serialize(resp);
        
        req.requestBody = Blob.valueOf(respString);
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        LeadCaptureWrapper.LeadBespokeResponseWrapper responseWs = LeadBespokeAPI.bespoke();
        Test.stopTest();
        
        System.assert(responseWs.status == 'Error');
    }
}