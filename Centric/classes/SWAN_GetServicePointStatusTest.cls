@isTest
public with sharing class SWAN_GetServicePointStatusTest {

  @testSetup 
    static void createMokeData(){
    
        Account acc= new Account();
		acc.Name='TomWalkerLeaveALightOn Acquisition Offer acc';
		acc.SWAN_Customer_Segment__c='Enterprise';
		acc.SWAN_Micro_Business_Selection__c ='Micro_Business';
		insert acc;

		Opportunity opp= new Opportunity();
		opp.Name='TomWalkerLeaveALightOn Acquisition Offer opp';
		opp.RecordTypeId='0124J000000YlVoQAK';
		opp.StageName='Qualification';
		opp.CloseDate=date.parse('31/12/2021');
        insert opp;

		Quote q = new Quote();
		q.Name='TomWalkerLeaveALightOn Acquisition Offer quote';
		q.OpportunityId=opp.Id;
		insert q;

		Quote q_child = new Quote();
		q_child.Name='TomWalkerLeaveALightOn Acquisition Offer quote_child';
		q_child.OpportunityId=opp.Id;
        q_child.vlocity_cmt__ParentQuoteId__c=q.Id;
		insert q_child;

		vlocity_cmt__Premises__c premise= new vlocity_cmt__Premises__c();
		insert premise;

        Contract c= new Contract();
		c.AccountId=acc.Id;
		c.Name='TomWalkerLeaveALightOn Acquisition Offer contract';
		c.EndDate=date.parse('14/11/2021');
		c.StartDate=date.parse('14/09/2021');
		c.Status='Draft';
        c.vlocity_cmt__ContractType__c='';
     	c.vlocity_cmt__OpportunityId__c=opp.Id;

		insert c;
		
 
        vlocity_cmt__ServicePoint__c sp= new vlocity_cmt__ServicePoint__c();
        sp.vlocity_cmt__ServicePointNumber__c='938249102';
		sp.vlocity_cmt__PremisesId__c=premise.Id;
		sp.Name='sp_938249102';
        insert sp;
        
        List<vlocity_cmt__ContractLineItem__c> clis= new List<vlocity_cmt__ContractLineItem__c>();


        for(Integer i=5;i<10;i++){
            
            vlocity_cmt__ContractLineItem__c cli= new vlocity_cmt__ContractLineItem__c();
            cli.Name=c.Name+'_'+String.valueOf(i);
            cli.vlocity_cmt__ContractId__c=c.Id;
            cli.SWAN_Service_Point__c=sp.Id;
            cli.SWAN_Service_Point_End_Date__c=c.EndDate;
            cli.vlocity_cmt__LineStatus__c='Inactive';
            cli.vlocity_cmt__EffectiveEndDate__c=c.EndDate;
            cli.vlocity_cmt__EffectiveStartDate__c=c.StartDate;
			cli.SWAN_Service_Point_Start_Date__c=c.StartDate;
            cli.vlocity_cmt__OriginalLineItemId__c=null;
			cli.SWAN_Quote__c=q_child.Id;

            clis.add(cli);

        }
		
        
       
        insert clis;

    }

 @isTest
    static void getServicePointStatusCount(){
        
        Boolean result;
        Id cID=[Select Id from Contract limit 1][0].Id;
        String methodName='getServicePointCount';
		String lineStatus='Inactive';
        
        Map<String, Object> outputMap = new Map<String, Object>(); 
        Map<String, Object> options = new Map<String, Object>();
        Map<String, Object> inputMap = new Map<String, Object>();

        inputMap.put('ContextId', cID);
        inputMap.put('ContractStatus', lineStatus);

		
        Test.startTest();
		
        SWAN_GetServicePointStatus getSps = new SWAN_GetServicePointStatus();
        result=getSps.invokeMethod(methodName, inputMap, outputMap, options);
        
        Integer numOfSps= (Integer) outputMap.get('ContractLineItemSize');
		
        Test.stopTest();
		
		system.assertEquals(5,  numOfSps, outputMap.get('ContractLineItemSize'));
		
        
    }
    
     @isTest
    static void getServicePointStatus(){
        
        Boolean result;
        Id cID=[Select Id from Contract limit 1][0].Id;
        String methodName='getServicePointStatus';
		Id badId='8008E000001ORcPQAW';
		String badmethodName='getServicePointStatusActive';
		String lineStatus='Inactive';
        
        Map<String, Object> outputMap = new Map<String, Object>(); 
        Map<String, Object> options = new Map<String, Object>();
        Map<String, Object> inputMap = new Map<String, Object>();

        inputMap.put('ContextId', cID);
        inputMap.put('ContractStatus', lineStatus);

		
        Test.startTest();
		
        SWAN_GetServicePointStatus getSps = new SWAN_GetServicePointStatus();
        result=getSps.invokeMethod(methodName, inputMap, outputMap, options);

		List<Object> clis= (List<Object>)outputMap.get('ContractLineItem');
        Integer numOfSps= (Integer) outputMap.get('NumberOfSps');
		
        Test.stopTest();
		
        system.assertNotEquals(clis.size(), 0, outputMap);
		system.assertEquals(numOfSps, 5, outputMap);
		
        
    }


  @isTest
    static void getServicePointStatusWrongId(){
        
     	Boolean result;
        //Id cID=[Select Id from Contract limit 1][0].Id;
        String methodName='getServicePointStatus';
		Id badId='8008E000001ORcPQAW';
		String badmethodName='getServicePointStatusActive';
		String lineStatus='Inactive';
        
        Map<String, Object> outputMap = new Map<String, Object>(); 
        Map<String, Object> options = new Map<String, Object>();
        Map<String, Object> inputMap = new Map<String, Object>();

        inputMap.put('ContextId', badId);
        inputMap.put('ContractStatus', lineStatus);

		
        Test.startTest();
		
        SWAN_GetServicePointStatus getSps = new SWAN_GetServicePointStatus();
        result=getSps.invokeMethod(methodName, inputMap, outputMap, options);

		List<Object> clis= (List<Object>)outputMap.get('ContractLineItem');
        Integer numOfSps= (Integer) outputMap.get('NumberOfSps');
		
        Test.stopTest();
        
        system.assertEquals(clis.size(), 0, outputMap);
        
    }


	  @isTest
    static void getServicePointStatusWrongMethod(){
        
     	Boolean result;
        Id cID=[Select Id from Contract limit 1][0].Id;
        String methodName='getServicePointStatus';
		Id badId='8008E000001ORcPQAW';
		String badmethodName='getServicePointStatusActive';
		String lineStatus='Inactive';
        
        Map<String, Object> outputMap = new Map<String, Object>(); 
        Map<String, Object> options = new Map<String, Object>();
        Map<String, Object> inputMap = new Map<String, Object>();

        inputMap.put('ContextId', cID);
        inputMap.put('ContractStatus', lineStatus);

		
        Test.startTest();
		
        SWAN_GetServicePointStatus getSps = new SWAN_GetServicePointStatus();
        result=getSps.invokeMethod(badmethodName, inputMap, outputMap, options);
		
        Test.stopTest();
        
		system.assertEquals(false, result, result);
        
    }

    
}