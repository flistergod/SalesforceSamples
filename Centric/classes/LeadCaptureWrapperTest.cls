@isTest
public class LeadCaptureWrapperTest {
    
    static testmethod void test1(){
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
        resp.product ='asd';
        resp.callbacktime ='asd';
        resp.postCodeMainSite ='asd';
        resp.interestComments ='asd';
        resp.evChargingSpeed ='asd';
        resp.numberOfChargingPoints ='asd';
        
        LeadCaptureWrapper.Sites site = new LeadCaptureWrapper.Sites();
        site.postCode ='asd';
        site.higherRangePrice =1;
        site.lowerRangePrice =1;
        site.spotPrice =1;
        site.priceChanged =false;
        
        LeadCaptureWrapper.LeadBespokeResponseWrapper LeadBespokeResponseWrapper = new LeadCaptureWrapper.LeadBespokeResponseWrapper();
        LeadBespokeResponseWrapper.status= 'Success';
        LeadBespokeResponseWrapper.statusDetail ='asd';
        LeadBespokeResponseWrapper.statusCode =200;
        LeadBespokeResponseWrapper.leadURN ='asd'; 
        
        LeadCaptureWrapper.LeadResponseWrapper LeadResponseWrapper = new LeadCaptureWrapper.LeadResponseWrapper();
        LeadResponseWrapper.status= 'Success';
        LeadResponseWrapper.statusDetail ='asd';
        LeadResponseWrapper.statusCode =200;
        LeadResponseWrapper.leadURN ='asd';
        LeadResponseWrapper.indicativeQuoteURN ='asd';
        LeadResponseWrapper.aggregatedSpotPrice =200;
        LeadResponseWrapper.aggregatedSpotLowerRangePrice =200;
        LeadResponseWrapper.aggregatedSpotHigherRangePrice =200;
    }
    
}