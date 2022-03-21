@RestResource(urlMapping='/lead/api/*')
global without sharing class LeadIndicativeQuoteAPI {
    
    global static string missingField;
    private static final Map<String, RecordTypeInfo> RT_LEADOBJECT = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName();
    private static final Id  RT_LEADEV = RT_LEADOBJECT.get('EV').getRecordTypeId();
    private static final String ACTIVE_STATUS = 'Active';
    private static final String INDICATIVE_PRICING_STATUS_RECORD_TYPE_ID = Schema.SObjectType.indicativequotepricematrix__c.getRecordTypeInfosByName().get('Default').getRecordTypeId();
    
    @HTTPPost
    global static LeadCaptureWrapper.LeadResponseWrapper indicativeQuote() {
        try{
            list<string> lstAnswers = new list<string>();
            RestRequest req = RestContext.request;
            String requestBody = req.requestBody.toString();
            
            LeadCaptureWrapper.LeadWrapper leadWrapper = (LeadCaptureWrapper.LeadWrapper) JSON.deserialize(requestBody, LeadCaptureWrapper.LeadWrapper.class);
            Map<String, Object> mpLead = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(leadWrapper));
            if(hasNullField(mpLead)){
                LeadCaptureWrapper.LeadResponseWrapper response = new LeadCaptureWrapper.LeadResponseWrapper();
                response.status = 'Error';
                response.statusDetail = 'Missing the following required field: '+missingField;
                response.statuscode = 400;
                return response;
            }
            list<LeadCaptureWrapper.indicativeQuoteSite> lstIndQuoteSiteWrapper = leadWrapper.indicativeQuoteSite;
            for(LeadCaptureWrapper.indicativeQuoteSite iqs : lstIndQuoteSiteWrapper){
                Map<String, Object> mpIndQuoteSite = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(iqs));
                for(object o : mpIndQuoteSite.values()){
                    lstAnswers.add(string.valueOf(o));
                }
                
                if(hasNullField(mpIndQuoteSite)){
                    LeadCaptureWrapper.LeadResponseWrapper response = new LeadCaptureWrapper.LeadResponseWrapper();
                    response.status = 'Error';
                    response.statusDetail = 'Missing the following required field: indicativeQuoteSite.'+missingField;
                    response.statuscode = 400;
                    return response;
                }
            }
            
            IndicativeQuote__c indicativeQuoteToInsert = new IndicativeQuote__c();
            lead leadToInsert = new lead();
            
            //check existing lead
            List<Lead> lstLead = [SELECT Id, Status, RecordTypeId, ownerId FROM Lead WHERE Email =:leadWrapper.email AND RecordTypeId =:RT_LEADEV AND Status != 'Qualified' AND Status != 'Unqualified'];
            if(lstLead.size() > 0){
                leadToInsert = lstLead[0];
            }
            
            if(leadToInsert.OwnerId == null || string.valueof(leadToInsert.OwnerId).substring(0,3) != '005'){
                Database.DMLOptions dmo = new Database.DMLOptions();
                dmo.assignmentRuleHeader.useDefaultRule= true;
                leadToInsert.setOptions(dmo);
            }
            leadToInsert.recordtypeid = RT_LEADEV;
            leadToInsert.LeadPriority__c = 'Low';
            leadToInsert.Status = 'New';
            leadToInsert.email = leadWrapper.email;
            leadToInsert.CampaignCode__c = leadWrapper.campaignCode;
            leadToInsert.Company = leadWrapper.company;
            leadToInsert.Phone = leadWrapper.contactNumber;
            leadToInsert.FirstName = leadWrapper.firstName;
            leadToInsert.LastName = leadWrapper.lastName;
            leadToInsert.EVSitesAmount__c = leadWrapper.numberOfSites;
            leadToInsert.LeadChannelPersonalIdentifier__c = leadWrapper.personalIdentifier;
            leadToInsert.CallbackConsent__c = leadWrapper.callbackConsent;
            leadToInsert.LeadChannel__c = leadWrapper.channel;
            leadToInsert.WebIndicativeQuote__c = leadWrapper.webIndicativeQuoteReference;
            database.upsert(leadToInsert);
            
            indicativeQuoteToInsert.Lead__c = leadToInsert.Id;
            indicativeQuoteToInsert.status__c=ACTIVE_STATUS;
            insert indicativeQuoteToInsert;
            
            leadToInsert.Status = 'Working';
            update leadToInsert;
            
            map<string,indicativequotepricematrix__c> mpAuxIndQuotePriceMatrix = new map<string,indicativequotepricematrix__c>();
            map<string,string> mpAux = new map<string,string>();
            list<string> lstPriceMatrixCombination = new list<string>();
            
            for(answer__c a : [select id, value__c, IndicativeQuotePriceMatrixKey__c from answer__c where IndicativeQuotePriceMatrixKey__c
                               in:lstAnswers and status__c=:ACTIVE_STATUS]){
                                   mpAux.put(a.IndicativeQuotePriceMatrixKey__c, a.id);
                               }
            for(indicativequotepricematrix__c iqpm : [select id, PriceMatrixCombination__c,HigherRangePrice__c, LowerRangePrice__c, SpotPrice__c, name 
                                                      from indicativequotepricematrix__c where Status__c = :ACTIVE_STATUS and RecordTypeId = :INDICATIVE_PRICING_STATUS_RECORD_TYPE_ID]){
                                                          mpAuxIndQuotePriceMatrix.put(iqpm.PriceMatrixCombination__c, iqpm);
                                                      }
            
            Set<String> setPostCodeIdentifiers = new Set<String>();
            
            for(LeadCaptureWrapper.indicativeQuoteSite iqs : lstIndQuoteSiteWrapper){
                setPostCodeIdentifiers.add(iqs.postCode.split(' ')[0]);
            }
            
            //Get Uplift Percentage
            Map<String, CategoryUpliftPostCode__mdt> mapPostCodeUpliftPercentage = new Map<String, CategoryUpliftPostCode__mdt>();        
            for(CategoryUpliftPostCode__mdt varPriceMatrix: [SELECT Id, PostCodeIdentifier__c, CategoryUplift__r.value__c FROM CategoryUpliftPostCode__mdt WHERE PostCodeIdentifier__c in :setPostCodeIdentifiers]){
                mapPostCodeUpliftPercentage.put(varPriceMatrix.PostCodeIdentifier__c, varPriceMatrix);
            }
            
            
            system.debug('mpAux: '+mapPostCodeUpliftPercentage);
            
            list<indicativeQuoteSite__c> lstIndicativeQuoteSite = new list<indicativeQuoteSite__c>();
            
            for(LeadCaptureWrapper.indicativeQuoteSite iqs : lstIndQuoteSiteWrapper){
                indicativeQuoteSite__c indQuoteSite = new indicativeQuoteSite__c();
                
                indQuoteSite.Name = iqs.postCode;
                indQuoteSite.Answer1__c = mpAux.get(iqs.designatedParking);
                indQuoteSite.Answer2__c = mpAux.get(iqs.maxNumVehicle);
                indQuoteSite.Answer3__c = mpAux.get(iqs.mountingType);
                indQuoteSite.Answer4__c = mpAux.get(iqs.distance);
                indQuoteSite.Answer5__c = mpAux.get(iqs.groundType);
                indQuoteSite.Answer6__c = mpAux.get(iqs.chargeRate);
                indQuoteSite.IndicativeQuote__c = indicativeQuoteToInsert.id; 
                string a = ''+iqs.chargeRate+''+iqs.mountingType+''+iqs.maxNumVehicle+''+iqs.distance+''+(iqs.mountingType != 'wall' ? iqs.groundType : 'no');
                string b = a.trim();
                system.debug(''+mpAuxIndQuotePriceMatrix.get(b));
                //system.debug(''+mapPostCodeUpliftPercentage.get(iqs.postCode.split(' ')[0]));
                if(mpAuxIndQuotePriceMatrix.get(b)!=null) indQuoteSite.CombinationID__c = mpAuxIndQuotePriceMatrix.get(b).name;
                indQuoteSite.SpotPrice__c = mpAuxIndQuotePriceMatrix.get(b)!=null ? mpAuxIndQuotePriceMatrix.get(b).spotPrice__c : 0;
                indQuoteSite.HigherRangePrice__c = mpAuxIndQuotePriceMatrix.get(b)!=null ? mpAuxIndQuotePriceMatrix.get(b).HigherRangePrice__c : 0;
                indQuoteSite.LowerRangePrice__c = mpAuxIndQuotePriceMatrix.get(b)!=null ? mpAuxIndQuotePriceMatrix.get(b).LowerRangePrice__c : 0;
                //indQuoteSite.UpliftSpotPrice__c = (mpAuxIndQuotePriceMatrix.get(b)!=null && mapPostCodeUpliftPercentage.get(iqs.postCode.split(' ')[0]) !=null) ? (Integer) Math.round(Double.valueOf(mpAuxIndQuotePriceMatrix.get(b).spotPrice__c) + (Double.valueOf(mpAuxIndQuotePriceMatrix.get(b).spotPrice__c) * (Double.valueOf(mapPostCodeUpliftPercentage.get(iqs.postCode.split(' ')[0]).CategoryUplift__r.value__c) / Double.valueOf(100)))) : 0;
                //indQuoteSite.UpliftLowerRangePrice__c = (mpAuxIndQuotePriceMatrix.get(b)!=null && mapPostCodeUpliftPercentage.get(iqs.postCode.split(' ')[0]) !=null)  ? (Integer) Math.round(Double.valueOf(mpAuxIndQuotePriceMatrix.get(b).LowerRangePrice__c) + (Double.valueOf(mpAuxIndQuotePriceMatrix.get(b).LowerRangePrice__c) * (Double.valueOf(mapPostCodeUpliftPercentage.get(iqs.postCode.split(' ')[0]).CategoryUplift__r.value__c) / Double.valueOf(100)))) : 0;
                //indQuoteSite.UpliftHigherRangePrice__c = (mpAuxIndQuotePriceMatrix.get(b)!=null && mapPostCodeUpliftPercentage.get(iqs.postCode.split(' ')[0]) !=null)  ? (Integer) Math.round(Double.valueOf(mpAuxIndQuotePriceMatrix.get(b).HigherRangePrice__c) + (Double.valueOf(mpAuxIndQuotePriceMatrix.get(b).HigherRangePrice__c) * (Double.valueOf(mapPostCodeUpliftPercentage.get(iqs.postCode.split(' ')[0]).CategoryUplift__r.value__c) / Double.valueOf(100)))) : 0;
                indQuoteSite.UpliftPercentage__c = (mpAuxIndQuotePriceMatrix.get(b)!=null && mapPostCodeUpliftPercentage.get(iqs.postCode.split(' ')[0]) !=null) ? mapPostCodeUpliftPercentage.get(iqs.postCode.split(' ')[0]).CategoryUplift__r.value__c : 0;
                
                indQuoteSite.UpliftSpotPrice__c = mpAuxIndQuotePriceMatrix.containsKey(b) ? mapPostCodeUpliftPercentage.containsKey(iqs.postCode.split(' ')[0]) ? (Integer) Math.round(Double.valueOf(mpAuxIndQuotePriceMatrix.get(b).SpotPrice__c) + (Double.valueOf(mpAuxIndQuotePriceMatrix.get(b).SpotPrice__c) * (Double.valueOf(mapPostCodeUpliftPercentage.get(iqs.postCode.split(' ')[0]).CategoryUplift__r.value__c) / Double.valueOf(100)))) :  mpAuxIndQuotePriceMatrix.get(b).SpotPrice__c : 0;
				indQuoteSite.UpliftLowerRangePrice__c = mpAuxIndQuotePriceMatrix.containsKey(b) ? mapPostCodeUpliftPercentage.containsKey(iqs.postCode.split(' ')[0]) ? ((Integer) Math.round((Double.valueOf(mpAuxIndQuotePriceMatrix.get(b).LowerRangePrice__c) + (Double.valueOf(mpAuxIndQuotePriceMatrix.get(b).LowerRangePrice__c) * (Double.valueOf(mapPostCodeUpliftPercentage.get(iqs.postCode.split(' ')[0]).CategoryUplift__r.value__c) / Double.valueOf(100)))) / 100) * 100) :  mpAuxIndQuotePriceMatrix.get(b).LowerRangePrice__c : 0;
				indQuoteSite.UpliftHigherRangePrice__c = mpAuxIndQuotePriceMatrix.containsKey(b) ? mapPostCodeUpliftPercentage.containsKey(iqs.postCode.split(' ')[0]) ? ((Integer) Math.round((Double.valueOf(mpAuxIndQuotePriceMatrix.get(b).HigherRangePrice__c) + (Double.valueOf(mpAuxIndQuotePriceMatrix.get(b).HigherRangePrice__c) * (Double.valueOf(mapPostCodeUpliftPercentage.get(iqs.postCode.split(' ')[0]).CategoryUplift__r.value__c) / Double.valueOf(100)))) / 100) * 100) :  mpAuxIndQuotePriceMatrix.get(b).HigherRangePrice__c : 0;
                
                lstIndicativeQuoteSite.add(indQuoteSite);
                
            }
            
            insert lstIndicativeQuoteSite;
            
            LeadCaptureWrapper.LeadResponseWrapper response =new LeadCaptureWrapper.LeadResponseWrapper();
            response.status= 'Success';
            response.statusCode = 200;
            response.statusDetail = 'Data has been submitted successfully';
            response.leadURN = [select id, UniqueReferenceNumber__c from lead where id=: leadToInsert.id].UniqueReferenceNumber__c;
            indicativequote__c iq = [select id, UniqueReferenceNumber__c,AggregatedUpliftLowerRangePrice__c,AggregatedUpliftSpotPrice__c,
                                     AggregatedUpliftHigherRangePrice__c from indicativequote__c where id=:indicativeQuoteToInsert.id];
            response.aggregatedSpotLowerRangePrice = (integer) iq.AggregatedUpliftLowerRangePrice__c;
            response.aggregatedSpotPrice = (integer) iq.AggregatedUpliftSpotPrice__c;
            response.aggregatedSpotHigherRangePrice = (integer) iq.AggregatedUpliftHigherRangePrice__c;
            response.indicativeQuoteURN = iq.UniqueReferenceNumber__c;
            list<LeadCaptureWrapper.Sites> lstsite = new list<LeadCaptureWrapper.Sites>();
            for(indicativeQuoteSite__c iqs : lstIndicativeQuoteSite){
                LeadCaptureWrapper.Sites site = new LeadCaptureWrapper.Sites();
                site.postCode = iqs.name;
                site.priceChanged = iqs.PriceChanged__c;
                site.spotPrice = (integer) iqs.UpliftSpotPrice__c;
                site.lowerRangePrice = (integer) iqs.UpliftLowerRangePrice__c;
                site.higherRangePrice = (integer) iqs.UpliftHigherRangePrice__c;
                lstsite.add(site);
            }
            response.sites = lstSite; 
            
            return response;
        }catch(exception e){
            system.debug(e.getMessage()+' - '+e.getLineNumber());
            LeadCaptureWrapper.LeadResponseWrapper response = new LeadCaptureWrapper.LeadResponseWrapper();
            response.status = 'Error';
            response.statusDetail = 'Missing the following required field: '+missingField;
            response.statuscode = 400;
            return response;
        }
    }
    
    public static Boolean hasNullField(Map<String, Object> mpLead) {
        for (String curr : mpLead.keyset()) {
            if (curr != 'personalIdentifier' && curr != 'firstName' && curr != 'campaignCode' && curr != 'webIndicativeQuoteReference' &&
                curr != 'emailConsent' && curr != 'product' && curr != 'callbacktime' && curr != 'postCodeMainSite' &&
                curr != 'interestComments' && curr != 'evChargingSpeed' && curr != 'numberOfChargingPoints' && curr != 'numberOfSites' && curr != 'indicativeQuoteConfirmEmail'
                && (mpLead.get(curr) == null || mpLead.get(curr) == '')){
                missingField = curr;
                return true;
            }
        }
        
        return false;
        
    }
    
    
}