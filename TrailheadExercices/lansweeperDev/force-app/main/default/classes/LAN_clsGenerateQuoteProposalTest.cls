/**
 * @description       : 
 * @author            : Flistergod
 * @group             : 
 * @last modified on  : 11-11-2020
 * @last modified by  : Flistergod
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   11-10-2020   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
@isTest
public class LAN_clsGenerateQuoteProposalTest {
    
    private static Account a{
        get{
            return [select Id from Account order by LastModifiedDate  desc limit 1];
        }
    }
    
     private static Opportunity o{
        get{
            return [select Id from Opportunity order by LastModifiedDate  desc limit 1];
        }
    }
    
     private static SBQQ__QuoteTemplate__c template{
        get{
            return [select Id, SBQQ__Default__c from SBQQ__QuoteTemplate__c order by LastModifiedDate  desc limit 1];
        }
    }
 
    @testSetup
    private static void setupTestData() {
        
        
        Pricebook2 pb = new Pricebook2(Id = Test.getStandardPricebookId(), isActive = true);
        
     	Account   a = new Account(Name='Test', RecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('LAN_Account').getRecordTypeId());
        insert a;

      	Opportunity   o = new Opportunity(AccountId = a.Id, RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('LAN_Renewal').getRecordTypeId(), 
                                       StageName = 'Qualify', Name = 'Oppty', CloseDate = System.today().addDays(365), Pricebook2Id = Test.getStandardPricebookId());
        insert o;
        }
    
   

/*    
   
    @isTest
    private static void testGenerateQuoteID() {
        
        Test.startTest();
        SBQQ__Quote__c q = new SBQQ__Quote__c();
        q.SBQQ__Account__c = a.Id;
        q.SBQQ__Opportunity2__c  = o.Id;
        q.SBQQ__StartDate__c = System.today();
        q.LAN_Main_Quote_Document_Id__c=null;
        insert q;

    	QuoteProposalModel context = new QuoteProposalModel(q.Id);

        Test.stopTest();
	    System.assertEquals(q.Id, context.quoteId);
    }
    
    
    @isTest
    private static void testGenerateQuoteModelWithoutTemplate() {
        
        Test.startTest();
 
        SBQQ__Quote__c q = new SBQQ__Quote__c();
        q.SBQQ__Account__c = a.Id;
        q.SBQQ__Opportunity2__c  = o.Id;
        q.SBQQ__StartDate__c = System.today();
        q.SBQQ__QuoteTemplateId__c=null;
        insert q;

		SBQQ__QuoteTemplate__c   template= new SBQQ__QuoteTemplate__c(Name='No Discount', SBQQ__Default__c=true);
        insert template;

    	QuoteProposalModel context = new QuoteProposalModel(q.Id);
        
        Id templateId;
         templateId=[select Id, SBQQ__QuoteTemplateId__c from SBQQ__Quote__c where Id=:q.Id].SBQQ__QuoteTemplateId__c;
          
          if(string.isBlank(templateId)) {
               templateId=[select Id from SBQQ__QuoteTemplate__c where SBQQ__Default__c=true].Id;
          }
        
        context.templateId=templateId;
      
        Test.stopTest();
		System.assertNotEquals(null, context.templateId);
        System.assertEquals(templateId, context.templateId);
              
    }


   
        @isTest
    private static void testGenerateQuoteModelWithTemplate() {
        
        Test.startTest();
       
        SBQQ__Quote__c q = new SBQQ__Quote__c();
        q.SBQQ__Account__c = a.Id;
        q.SBQQ__Opportunity2__c  = o.Id;
        q.SBQQ__StartDate__c = System.today();
        q.SBQQ__QuoteTemplateId__c=null;
        insert q;
        
		SBQQ__QuoteTemplate__c   template= new SBQQ__QuoteTemplate__c(Name='No Discount', SBQQ__Default__c=true);
        insert template;
        
    	QuoteProposalModel context = new QuoteProposalModel(q.Id);
        
        Id templateId=q.SBQQ__QuoteTemplateId__c;
     

          if(string.isBlank(templateId)) {
               templateId=[select Id from SBQQ__QuoteTemplate__c where SBQQ__Default__c=true].Id;
          }

        context.templateId=templateId;
      
        Test.stopTest();
        System.assertEquals(template.Id, context.templateId);
              
    }
    

           @isTest
    private static void testGenerateQuoteProposal() {
        
        Test.startTest();
        
        SBQQ__Quote__c q = new SBQQ__Quote__c();
        q.SBQQ__Account__c = a.Id;
        q.SBQQ__Opportunity2__c  = o.Id;
        q.SBQQ__StartDate__c = System.today();
        q.SBQQ__QuoteTemplateId__c=null;
        insert q;
        
		SBQQ__QuoteTemplate__c   template= new SBQQ__QuoteTemplate__c(Name='No Discount', SBQQ__Default__c=true);
        insert template;
        
        Id templateId=q.SBQQ__QuoteTemplateId__c;
     
        
          if(string.isBlank(templateId)) {
               templateId=[select Id from SBQQ__QuoteTemplate__c where SBQQ__Default__c=true].Id;
          }

        QuoteProposalModel context = new QuoteProposalModel(q.Id);
        
        context.templateId=templateId;
        
        String jobId= JSON.serialize(context);
      
        Test.stopTest();
        System.assertNotEquals(null, jobId);
    
              
    }

    */
    
      public static String callEchoString(String input) {
        docSample.DocSamplePort sample = new docSample.DocSamplePort();
        sample.endpoint_x = 'http://example.com/example/test';
        
        // This invokes the EchoString method in the generated class
        String echo = sample.EchoString(input);
        
        return echo;
    }  
    
    @isTest
    private static void testCallout() {
        
        
        SBQQ__Quote__c q = new SBQQ__Quote__c();
        q.SBQQ__Account__c = a.Id;
        q.SBQQ__Opportunity2__c  = o.Id;
        q.SBQQ__StartDate__c = System.today();
        q.SBQQ__QuoteTemplateId__c=null;
        insert q;
        
		SBQQ__QuoteTemplate__c   template= new SBQQ__QuoteTemplate__c(Name='No Discount', SBQQ__Default__c=true);
        insert template;
        
        Id templateId=q.SBQQ__QuoteTemplateId__c;
     
        
          if(string.isBlank(templateId)) {
               templateId=[select Id from SBQQ__QuoteTemplate__c where SBQQ__Default__c=true].Id;
          }

        
        Test.setMock(WebServiceMock.class, new LAN_clsWebServiceMock());
        
         // Call the method that invokes a callout
        String output = LAN_clsGenerateQuoteProposalTest.callEchoString('Hello World!');
          
		

        System.assertNotEquals(null, output);
              
    }

    /*
    private static void testCalloutFail() {
        
        Test.startTest();
        
        SBQQ__Quote__c q = new SBQQ__Quote__c();
        q.SBQQ__Account__c = a.Id;
        q.SBQQ__Opportunity2__c  = o.Id;
        q.SBQQ__StartDate__c = System.today();
        q.SBQQ__QuoteTemplateId__c=null;
        insert q;
        
		SBQQ__QuoteTemplate__c   template= new SBQQ__QuoteTemplate__c(Name='No Discount', SBQQ__Default__c=true);
        insert template;
        
        Id templateId=q.SBQQ__QuoteTemplateId__c;
     
        
          if(string.isBlank(templateId)) {
               templateId=[select Id from SBQQ__QuoteTemplate__c where SBQQ__Default__c=true].Id;
          }

        QuoteProposalModel context = new QuoteProposalModel(q.Id);
        
        context.templateId=templateId;
        
        String jobId= JSON.serialize(context);
        String jobId2=LAN_clsGenerateQuoteProposal.save(q.Id);
      
        Test.stopTest();
        System.assertNotEquals(null, jobId);
        System.assertNotEquals(null, jobId2);
              
    }

    */

}