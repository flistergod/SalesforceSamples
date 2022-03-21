@ isTest
public class EV_LeadConversionUtilsRemoteActionTest {
    private static Boolean noArgConstructorInvoked = false;
    
    private static final Map<String, RecordTypeInfo> RT_LEADOBJECT = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName();
    private static final Id  RT_LEADEV = RT_LEADOBJECT.get('EV').getRecordTypeId();
    
    private static final Map<String, RecordTypeInfo> RT_OPPORTUNITYOBJECT = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName();
    private static final Id  RT_OPPACQUISITON = RT_OPPORTUNITYOBJECT.get('EV_ACQUISITION').getRecordTypeId();
    
    public static void setNoArgConstructorInvoked(boolean val){
        noArgConstructorInvoked = val;
    }
    
    private static final InvokeMethodDate data = new InvokeMethodDate();
    
    //==================================================================================================================
    // Test setup and utility
    //==================================================================================================================
    
    @TestSetup
    private static void setup() {
        setDataBase();
    }
    
    private static void setDataBase() {
        List<Lead> mockLeads = new List<Lead>();
        List<IndicativeQuote__c> mockQuotes = new List<IndicativeQuote__c>();
        Profile pEv = [SELECT Id, Name FROM Profile WHERE Name = 'Centrica EV User'];
        String uniqueEvUserName = 'evuser'+DateTime.now().getTime()+'@mock.com';
        User EvUser = new User(
            Alias = 'EvUser',
            Email='ev.user@testorg.com',
            EmailEncodingKey='UTF-8',
            LastName='Testing',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            ProfileId = pEv.Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName=uniqueEvUserName
        );
        
        System.runAs(EvUser){
            System.debug('Create EV Leads');
            mockLeads.add(new Lead( FirstName = 'EvUser', LastName = 'Lead1', Company = 'Centrica EV User', Status = 'New',  Email = 'lead1.ev@mail.com', SWAN_Customer_Segment__c = 'I&C', SWAN_Micro_Business_Selection__c = 'Non_Micro_Business', LeadSource='Advertisement'));
            System.debug(mockLeads);
            insert mockLeads;
            List<Lead> newLead = [SELECT Id from Lead WHERE Email = 'lead1.ev@mail.com'];
            Id leadId = newLead[0].Id;
            mockQuotes.add(new IndicativeQuote__c(Lead__c = leadId));
            insert mockQuotes;

            String question;
            String questionText;
            String answer;
            String answerValue;
            // Quesitons
            System.debug('Questions creation');
            List<Question__c> mockQuestions = new List<Question__c>();
            for (Integer i = 1; i < 7; i++) {
                question = 'Question ' + i;
                questionText = 'This is question number '+i;
                mockQuestions.add(new Question__c(Question__c = questionText, Name = question));
            }
            insert mockQuestions;
            
            // Answers
            List<Answer__c> mockAnswers = new List<Answer__c>();
            System.debug('Answers creation');
            for (Integer i = 1; i < 7; i++) {
                question = 'Question ' + i;
                List<Question__c> listNewQuestionId = [SELECT Id FROM Question__c WHERE Name =:question];
                Id questionId = listNewQuestionId.get(0).Id;
                System.debug(questionId);
                answer= 'Answer '+i;
                answerValue= 'This is the answer to question '+i;
                mockAnswers.add(new  Answer__c(Status__c = 'Active', Question__c = questionId, Value__c= answerValue, Name = answer, IndicativeQuotePriceMatrixKey__c=answer, Order__c = i));
            }
            System.debug(mockAnswers);
            insert mockAnswers;
            
            // Create Account
            List<Account> accounts = new List<Account>();
            accounts.add(new Account(Name = 'Mock Account', Type = 'Business', SWAN_Customer_Segment__c = 'I&C', SWAN_Micro_Business_Selection__c = 'Non_Micro_Business'));
            insert accounts;

            // Create Contact
            List<Account> listAccountId = [SELECT Id FROM Account WHERE Name = 'Mock Account'];
            Id accountId = listAccountId.get(0).Id;
            List<Contact> listContact = new List<Contact>();
            listContact.add(new Contact(FirstName = 'Mock', LastName = 'Contact', AccountId = accountId, Email = 'contact.mock@mail.com', Phone = '01111111111', MailingCity = 'CGI Cap', MailingCountry = 'CGI Landia', MailingPostalCode = 'M4 2AA', MailingState = 'Impednacia', MailingStreet = 'No Name',SWAN_Mailing_Building_Name__c	= 'House of the Rising Sun', SWAN_Mailing_Building_Number__c='666'));
            insert listContact;
        }

    }
    
    private static void setInvokeMethodDate(){        
        data.addTestMethodName('checkExistingLead');
        data.addTestInputMap('EMail','lead1.ev@mail.com');
        data.addTestMethodName('Question1');
        data.addTestMethodName('Question2');
        data.addTestMethodName('Question3');
        data.addTestMethodName('Question4');
        data.addTestMethodName('Question5');
        data.addTestMethodName('Question6');
        data.addTestMethodName('setIndicativeQuote');
        data.addTestMethodName('convertEVLead');
        data.addTestInputMap('oppCompany', 'Centrica EV Company For The Purpose Of Testing and Better Functionality');
        
        List<IndicativeQuote__c> listIndicativeQuoteId = [SELECT Id, UniqueReferenceNumber__c FROM IndicativeQuote__c WHERE Lead__r.Email = 'lead1.ev@mail.com'];
        Id indicativeQuoteId = listIndicativeQuoteId.get(0).Id;
        System.debug('indicativeQuoteId: ' + indicativeQuoteId);
		data.addTestInputMap('oppIndicativeQuoteURN',listIndicativeQuoteId.get(0).UniqueReferenceNumber__c);
        data.addTestInputMap('indicativeQuoteId',JSON.serialize(indicativeQuoteId));
        
        SiteDetail siteDetails = new SiteDetail('M4 2AA','This is the answer to question 1','This is the answer to question 2','This is the answer to question 3','This is the answer to question 4','This is the answer to question 5','This is the answer to question 6','');
    	List<SiteDetail> listSiteDetails = new List<SiteDetail>();
        listSiteDetails.add(siteDetails);
        data.addTestInputMap('siteDetails', JSON.serialize(listSiteDetails));
        
        List<Answer__c> lAnswers = new List<Answer__c>();
        String answerName; 
        for (Integer i = 1; i < 7; i++) {
            answerName = 'Answer '+i;
            lAnswers = [SELECT Id, Name, Value__c FROM Answer__c WHERE Name = :answerName];
            data.addTestInputMap('question'+i,JSON.serialize(lAnswers));
        }
        
        List<Account> listAccountId = [SELECT Id FROM Account WHERE Name = 'Mock Account'];
        Id accountId = listAccountId.get(0).Id;
        data.addTestInputMap('accountId',accountId);


    }

    //==================================================================================================================
	// Construction test cases
	//==================================================================================================================

    @IsTest
    private static void shouldInvokeMethod(){
        Boolean invokeResult = true;
        setInvokeMethodDate();
        System.debug('shouldInvokeMethod');
        EV_LeadConversionUtilsRemoteAction leadConversion = new EV_LeadConversionUtilsRemoteAction();
        System.debug(data);
        for (String method : data.testMethodName) {
            System.debug('Method Name = ' + method);
            invokeResult = invokeResult && leadConversion.invokeMethod(method, data.testInputMap, data.testOutputMap, data.testOptions);
        }
        System.assert(invokeResult);

    } 
    
    //==================================================================================================================
    // Auxiliar Classes
    //==================================================================================================================
    
    public class InvokeMethodDate {
        
        List<String> testMethodName; 
        Map<String,Object> testInputMap;
        Map<String,Object> testOutputMap;
        Map<String,Object> testOptions;
        
        public InvokeMethodDate(){
            testMethodName = new List<String>();
            testInputMap = new Map<String,Object>();
            testOutputMap = new Map<String,Object>();
            testOptions = new Map<String,Object>();
        }
        
        public void addTestMethodName(String methodName){
            testMethodName.add(methodName);
        }
        
        public void addTestInputMap(String key, Object value){
            testInputMap.put(key,value);
        }
        
        public void addTestOutputMap(String key, Object value){
            testOutputMap.put(key,value);
        }
        
        public void addTestOptions(String key, Object value){
            testOptions.put(key,value);
        }
    }
    
    public class SiteDetail {
        public String postCode;
		public String answer1;
        public String answer2;
        public String answer3;
        public String answer4;
        public String answer5;
        public String answer6;        
        public String priceMatrixCombination;

        public SiteDetail(String postCode, String answer1, String answer2, String answer3, String answer4, String answer5, String answer6, String priceMatrixCombination){
            this.postCode = postCode;
            this.answer1 = answer1;
            this.answer2 = answer2;
            this.answer3 = answer3;
            this.answer4 = answer4;
            this.answer5 = answer5;
            this.answer6 = answer6;
            this.priceMatrixCombination = priceMatrixCombination;
        }
    }
}