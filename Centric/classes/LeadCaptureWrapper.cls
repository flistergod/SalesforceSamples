global class LeadCaptureWrapper {
    
    global class LeadWrapper {
        public String email {get; set;}
        public String firstName {get; set;}
        public String lastName {get; set;}
        public String company {get; set;}
        public String contactNumber {get; set;}
        public String numberOfSites {get; set;} ////////
        public boolean callbackConsent {get; set;}
        public String campaignCode {get; set;}
        public String channel {get; set;}
        public String personalIdentifier {get; set;}
        public String indicativeQuoteConfirmEmail {get; set;}
        public list<indicativeQuoteSite> indicativeQuoteSite {get; set;}
        public String webIndicativeQuoteReference {get; set;}
        
        public boolean emailConsent {get; set;} //////
        public String product {get; set;} ///////
        public String callbacktime {get; set;} //////
        public String postCodeMainSite {get; set;} //////
        public String interestComments {get; set;} //////
        public String evChargingSpeed {get; set;} ///////
        public String numberOfChargingPoints {get; set;} //////
    }
    
    global class Sites {
        public String postCode {get; set;}
        public integer spotPrice {get; set;}
        public integer lowerRangePrice {get; set;}
        public integer higherRangePrice {get; set;}
        public boolean priceChanged {get; set;}
        
    }
    global class LeadBespokeResponseWrapper {
        public String status {get; set;}
        public String statusDetail {get; set;}
        public Integer statusCode {get; set;}
        public String leadURN {get; set;}        
    }
    
    global class LeadResponseWrapper {
        public String status {get; set;}
        public String statusDetail {get; set;}
        public Integer statusCode {get; set;}
        public String leadURN {get; set;}
        public String indicativeQuoteURN {get; set;}
        public integer aggregatedSpotPrice {get; set;}
        public integer aggregatedSpotLowerRangePrice {get; set;}
        public Integer aggregatedSpotHigherRangePrice {get; set;}
        public list<Sites> sites {get; set;}
        
    }
    
    global class IndicativeQuoteSite {
        public String postCode {get; set;}
        public String designatedParking {get; set;}
        public String maxNumVehicle {get; set;}
        public String mountingType {get; set;}
        public String distance {get; set;}
        public String groundType {get; set;}
        public String chargeRate {get; set;}
        
    }    
}