/*
* @name: EV_LeadConversionUtilsRemoteAction
*/
global with sharing class EV_LeadConversionUtilsRemoteAction implements vlocity_cmt.VlocityOpenInterface {

	private static final Map<String, RecordTypeInfo> RT_LEADOBJECT = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName();
	private static final Id  RT_LEADEV = RT_LEADOBJECT.get('EV').getRecordTypeId();

    private static final Map<String, RecordTypeInfo> RT_OPPORTUNITYOBJECT = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName();
	private static final Id  RT_OPPACQUISITON = RT_OPPORTUNITYOBJECT.get('EV_ACQUISITION').getRecordTypeId();
    
    global class SiteDetail {
        public String postCode;
		public String answer1;
        public String answer2;
        public String answer3;
        public String answer4;
        public String answer5;
        public String answer6;        
        public String priceMatrixCombination;
    }

    global class QuestionAnswer{
        public String id;
        public String name;
        public String value;        
    }
    
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options){        
        System.debug('Method');
        try{
            if(methodName == 'checkExistingLead'){
                outMap.put('RALeadId', checkExistingLead(inputMap));
            }
            if (methodName.equals('Question1')) {
                getAnswersPicklist('Question 1', inputMap, outMap, options);
            }
            if (methodName.equals('Question2')) {
                getAnswersPicklist('Question 2', inputMap, outMap, options);
            }
            if (methodName.equals('Question3')) {
                getAnswersPicklist('Question 3', inputMap, outMap, options);
            }
            if (methodName.equals('Question4')) {
                getAnswersPicklist('Question 4', inputMap, outMap, options);
            }
            if (methodName.equals('Question5')) {
                getAnswersPicklist('Question 5', inputMap, outMap, options);
            }
            if (methodName.equals('Question6')) {
                getAnswersPicklist('Question 6', inputMap, outMap, options);
            }
            if (methodName.equals('setIndicativeQuote')) {
                setIndicativeQuote(inputMap, outMap, options);
            }
            if (methodName.equals('convertEVLead')) {
                convertLead(inputMap, outMap, options);
            }
        }catch(Exception ex){
            System.debug('Error Message: '+ex.getMessage()+' '+' Line Number: '+ ex.getLineNumber());
            return false;
        }
        return true;
    }
	
    /*
     * @description: Check for Lead in System and return the ID
     */
    private static String checkExistingLead(Map<String,Object> inputMap){
		String email = (String) inputMap.get('Email');      
        List<Lead> leadQuery = [SELECT Id, Status, RecordTypeId FROM Lead WHERE Email =:email AND RecordTypeId =:RT_LEADEV AND Status != 'Qualified' AND Status != 'Unqualified'];
		if(leadQuery.size() > 0){
        	return leadQuery[0].Id;
    	}   	
    	return null;         
	}

    public void getAnswersPicklist(String question, Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options) {
        List<Map<String, String>> UIoptions = new List<Map<String, String>>();
        for (Answer__c varAnswer: [SELECT ID, IndicativeQuotePriceMatrixKey__c, Value__c FROM Answer__c WHERE Status__c = 'Active' and Question__r.name = :question ORDER BY ORDER__C ASC]) {
            Map<String, String> tempMap = new Map <String, String> ();
            
            tempMap.put('name', varAnswer.IndicativeQuotePriceMatrixKey__c);
            tempMap.put('value', varAnswer.Value__c);
            
            // Displayed in Picklist
            UIoptions.add(tempMap);
        }
        system.debug(UIoptions);
        outMap.put('options', UIoptions);
    }
    
    public void setIndicativeQuote(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
        //Get Indicative Quote Id
        Id indicativeQuoteId = (Id) JSON.deserialize((String) inputMap.get('indicativeQuoteId') , Id.class);
        
        //Get Indicative Quote Price Matrix for all sites
        List<SiteDetail> listSiteDetails = (List<SiteDetail>) JSON.deserialize((String) inputMap.get('siteDetails') , List<SiteDetail>.class );
        
        Set<String> setPriceMatrixCombination = new Set<String>();
        Set<String> setPostCodeIdentifiers = new Set<String>();
        
        for(SiteDetail varSiteDetails: listSiteDetails){
            String priceMatrixCombination;
            if(varSiteDetails.answer3 != 'wall'){
            	priceMatrixCombination = varSiteDetails.answer6 + varSiteDetails.answer3 + varSiteDetails.answer2 + varSiteDetails.answer4 + varSiteDetails.answer5;
            }else{
                priceMatrixCombination = varSiteDetails.answer6 + varSiteDetails.answer3 + varSiteDetails.answer2 + varSiteDetails.answer4 + 'no';
            }     
            setPriceMatrixCombination.add(priceMatrixCombination);
            //Get First Part PostCode (2-4 Characters)
            setPostCodeIdentifiers.add(varSiteDetails.postCode.split(' ')[0]);
        }
        
        Map<String, IndicativeQuotePriceMatrix__c> mapIndQuotePriceMatrix = new Map<String, IndicativeQuotePriceMatrix__c>();
        //Name -> IndicativeQuotePriceMatrix stands for CombinationId -> Indicative Quote Site
        for(IndicativeQuotePriceMatrix__c varPriceMatrix: [SELECT Id, Name, SpotPrice__c, LowerRangePrice__c, HigherRangePrice__c, PriceMatrixCombination__c from IndicativeQuotePriceMatrix__c WHERE Status__c = 'Active' and PriceMatrixCombination__c in :setPriceMatrixCombination]){
            mapIndQuotePriceMatrix.put(varPriceMatrix.PriceMatrixCombination__c, varPriceMatrix);
        }

		//Question Anwers
        Map<String, Id> mapOptionsQuestion1 = transformIntoMapQuestionAnswers((List<QuestionAnswer>) JSON.deserialize((String) inputMap.get('question1') , List<QuestionAnswer>.class ));
        Map<String, Id> mapOptionsQuestion2 = transformIntoMapQuestionAnswers((List<QuestionAnswer>) JSON.deserialize((String) inputMap.get('question2') , List<QuestionAnswer>.class ));
        Map<String, Id> mapOptionsQuestion3 = transformIntoMapQuestionAnswers((List<QuestionAnswer>) JSON.deserialize((String) inputMap.get('question3') , List<QuestionAnswer>.class ));
        Map<String, Id> mapOptionsQuestion4 = transformIntoMapQuestionAnswers((List<QuestionAnswer>) JSON.deserialize((String) inputMap.get('question4') , List<QuestionAnswer>.class ));
        Map<String, Id> mapOptionsQuestion5 = transformIntoMapQuestionAnswers((List<QuestionAnswer>) JSON.deserialize((String) inputMap.get('question5') , List<QuestionAnswer>.class ));
        Map<String, Id> mapOptionsQuestion6 = transformIntoMapQuestionAnswers((List<QuestionAnswer>) JSON.deserialize((String) inputMap.get('question6') , List<QuestionAnswer>.class ));
        
        //Get Uplift Percentage
        Map<String, CategoryUpliftPostCode__mdt> mapPostCodeUpliftPercentage = new Map<String, CategoryUpliftPostCode__mdt>();
        //Map<Id, CategoryUplift__mdt> mapPostCodeCategory = new Map<Id, CategoryUplift__mdt>([SELECT Id, value__c FROM CategoryUplift__mdt]);        
        for(CategoryUpliftPostCode__mdt varPriceMatrix: [SELECT Id, PostCodeIdentifier__c, CategoryUplift__r.value__c FROM CategoryUpliftPostCode__mdt WHERE PostCodeIdentifier__c in :setPostCodeIdentifiers]){
        	mapPostCodeUpliftPercentage.put(varPriceMatrix.PostCodeIdentifier__c, varPriceMatrix);
        }
         
		//Create Indicative Quote Sites
		List<IndicativeQuoteSite__c> listIndicativeQuoteSites = new List<IndicativeQuoteSite__c>();
        
        System.debug('listSiteDetails'+listSiteDetails);
        for(SiteDetail varSiteDetails: listSiteDetails){   
			String priceMatrixCombination;
            if(varSiteDetails.answer3 != 'wall'){
            	priceMatrixCombination = varSiteDetails.answer6 + varSiteDetails.answer3 + varSiteDetails.answer2 + varSiteDetails.answer4 + varSiteDetails.answer5;
            }else{
                priceMatrixCombination = varSiteDetails.answer6 + varSiteDetails.answer3 + varSiteDetails.answer2 + varSiteDetails.answer4 + 'no';
            } 
            
            IndicativeQuoteSite__c site = new IndicativeQuoteSite__c();
             System.debug(varSiteDetails);
            site.Name = varSiteDetails.postCode;
            site.IndicativeQuote__c = indicativeQuoteId;           
            
            site.CombinationId__c = mapIndQuotePriceMatrix.containsKey(priceMatrixCombination) ?  mapIndQuotePriceMatrix.get(priceMatrixCombination).Name: null;
            
            //Base Pricing
            site.SpotPrice__c = mapIndQuotePriceMatrix.containsKey(priceMatrixCombination) ?  mapIndQuotePriceMatrix.get(priceMatrixCombination).SpotPrice__c: 0;
            site.LowerRangePrice__c = mapIndQuotePriceMatrix.containsKey(priceMatrixCombination) ?  mapIndQuotePriceMatrix.get(priceMatrixCombination).LowerRangePrice__c: 0;
            site.HigherRangePrice__c = mapIndQuotePriceMatrix.containsKey(priceMatrixCombination) ?  mapIndQuotePriceMatrix.get(priceMatrixCombination).HigherRangePrice__c: 0;
            //Uplift Pricing
            site.UpliftPercentage__c = mapPostCodeUpliftPercentage.containsKey(varSiteDetails.postCode.split(' ')[0]) ? mapPostCodeUpliftPercentage.get(varSiteDetails.postCode.split(' ')[0]).CategoryUplift__r.value__c: 0;
            

            site.CombinationId__c = mapIndQuotePriceMatrix.containsKey(priceMatrixCombination) ? mapIndQuotePriceMatrix.get(priceMatrixCombination).Name: null;
            site.UpliftSpotPrice__c = mapIndQuotePriceMatrix.containsKey(priceMatrixCombination) ? mapPostCodeUpliftPercentage.containsKey(varSiteDetails.postCode.split(' ')[0]) ? (Integer) Math.round(Double.valueOf(mapIndQuotePriceMatrix.get(priceMatrixCombination).SpotPrice__c) + (Double.valueOf(mapIndQuotePriceMatrix.get(priceMatrixCombination).SpotPrice__c) * (Double.valueOf(mapPostCodeUpliftPercentage.get(varSiteDetails.postCode.split(' ')[0]).CategoryUplift__r.value__c) / Double.valueOf(100)))) :  mapIndQuotePriceMatrix.get(priceMatrixCombination).SpotPrice__c : 0;
            site.UpliftLowerRangePrice__c = mapIndQuotePriceMatrix.containsKey(priceMatrixCombination) ? mapPostCodeUpliftPercentage.containsKey(varSiteDetails.postCode.split(' ')[0]) ? ((Integer) Math.round((Double.valueOf(mapIndQuotePriceMatrix.get(priceMatrixCombination).LowerRangePrice__c) + (Double.valueOf(mapIndQuotePriceMatrix.get(priceMatrixCombination).LowerRangePrice__c) * (Double.valueOf(mapPostCodeUpliftPercentage.get(varSiteDetails.postCode.split(' ')[0]).CategoryUplift__r.value__c) / Double.valueOf(100)))) / 100) * 100) :  mapIndQuotePriceMatrix.get(priceMatrixCombination).LowerRangePrice__c : 0;
			site.UpliftHigherRangePrice__c = mapIndQuotePriceMatrix.containsKey(priceMatrixCombination) ? mapPostCodeUpliftPercentage.containsKey(varSiteDetails.postCode.split(' ')[0]) ? ((Integer) Math.round((Double.valueOf(mapIndQuotePriceMatrix.get(priceMatrixCombination).HigherRangePrice__c) + (Double.valueOf(mapIndQuotePriceMatrix.get(priceMatrixCombination).HigherRangePrice__c) * (Double.valueOf(mapPostCodeUpliftPercentage.get(varSiteDetails.postCode.split(' ')[0]).CategoryUplift__r.value__c) / Double.valueOf(100)))) / 100) * 100) :  mapIndQuotePriceMatrix.get(priceMatrixCombination).HigherRangePrice__c : 0;
        
            site.Answer1__c = mapOptionsQuestion1.get(varSiteDetails.answer1);
            site.Answer2__c = mapOptionsQuestion2.get(varSiteDetails.answer2);
            site.Answer3__c = mapOptionsQuestion3.get(varSiteDetails.answer3);
            site.Answer4__c = mapOptionsQuestion4.get(varSiteDetails.answer4);
            site.Answer5__c = mapOptionsQuestion5.get(varSiteDetails.answer5);
            site.Answer6__c = mapOptionsQuestion6.get(varSiteDetails.answer6);
            
            listIndicativeQuoteSites.add(site);            
        }
        outputMap.put('indicativeQuoteSites',  JSON.serialize(listIndicativeQuoteSites));
    }
    
    //Temporary Function - To Be Replaced with DataRaptor Transform (Line 111 to 117 && Line 149 to 154)
    public Map<String, String> transformIntoMapQuestionAnswers(List<QuestionAnswer> listOptionsQuestion){
        //Question
        Map<String, String> mapOptionsQuestion = new Map<String, String> ();
    	for(QuestionAnswer varQuestionAnswer: listOptionsQuestion){
			mapOptionsQuestion.put(varQuestionAnswer.name, varQuestionAnswer.Id);
    	}
    	return mapOptionsQuestion;
    }       
    public void convertLead(Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options) {
        System.debug('ConvertLead Method');
        //Get AccountId
        String accountId = (String) inputMap.get('accountId');
                System.debug('accountId'+accountId);
        //Get ContactId
        String contactId = (String) inputMap.get('contactId');
                System.debug('contactId'+contactId);
        //Get IndicativeQuoteId
        String indicativeQuoteId = (String) inputMap.get('indicativeQuoteId');
             System.debug('IndicativeQuoteId'+IndicativeQuoteId);
        //Get numberOfSites
        Integer oppNumberOfSites = (Integer) inputMap.get('oppNumberOfSites');
                System.debug('oppNumberOfSites'+oppNumberOfSites);
        //Get LeadId
        String leadId = (String) inputMap.get('leadId');
                System.debug('leadId'+leadId);
        //Get convertedStatus
        String leadStatus = (String) inputMap.get('leadStatus');
                System.debug('leadStatus'+leadStatus);
        //Get Channel
        String oppChannel = (String) inputMap.get('oppChannel');
                System.debug('oppChannel'+oppChannel);
        //Get ChannelPersonalIdentifier
        String oppChannelPersonalIdentifier = (String) inputMap.get('oppChannelPersonalIdentifier');
                System.debug('oppChannelPersonalIdentifier'+oppChannelPersonalIdentifier);    
        //Get CloseDate
        String oppCloseDate = (String) inputMap.get('oppCloseDate');
                System.debug('oppCloseDate'+oppCloseDate); 
        //Get StageName
        String oppStageName = (String) inputMap.get('oppStageName');
               System.debug('oppStageName'+oppStageName); 
        //Get CompanyName
        String oppNameCompany = (String) inputMap.get('oppCompany');
                System.debug('oppNameCompany'+oppNameCompany); 
        //Get IndicativeQuoteURN
        String oppIndicativeQuoteURN = (String) inputMap.get('oppIndicativeQuoteURN');
                System.debug('oppIndicativeQuoteURN'+oppIndicativeQuoteURN); 

        //Lead Conversion
        Database.LeadConvertResult lcr;
        try
        {
            Database.LeadConvert lc = new Database.LeadConvert(); 
            lc.setLeadId(leadId); 
            lc.setAccountId(accountId);
            lc.setContactId(contactId);
            lc.setConvertedStatus(leadStatus);
            lc.setDoNotCreateOpportunity(false);
            
            //Create Opportunity           
            Opportunity opportunity = new Opportunity();
			opportunity.AccountId = accountId;
            opportunity.ContactId = contactId;
            opportunity.IndicativeQuote__c = indicativeQuoteId;
            oppNameCompany = oppNameCompany.length() > 60 ? oppNameCompany.substring(0, oppNameCompany.length()-1): oppNameCompany;
            opportunity.Name = 'EV_'+oppNameCompany+'_'+oppIndicativeQuoteURN;
            opportunity.CloseDate = Date.TODAY().addDays(365);
            opportunity.StageName = oppStageName;
            opportunity.Channel__c = oppChannel;
            opportunity.ChannelPersonalIdentifier__c = oppChannelPersonalIdentifier;
            opportunity.EV_numberSites__c = oppNumberOfSites;
            opportunity.RecordTypeId = RT_OPPACQUISITON;
            insert opportunity;
            
            lc.setOpportunityId(opportunity.Id);
 			
            lcr = Database.convertLead(lc);   
            
            //Update Lead
			Lead lead = [Select Id from Lead WHERE Id = :leadId limit 1];
			lead.leadConverted__c = 'Yes';
            update lead;
            
            outputMap.put('leadConversionStatus', 'Success');
            outputMap.put('opportunityId', opportunity.Id);
        } catch(Exception e) {
            outputMap.put('leadConversionStatus',  JSON.serialize('Unsuccess'));
            outputMap.put('errorMessage',  JSON.serialize(e.getMessage())+e.GetLineNumber());
        }
    }
}