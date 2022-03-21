/**
 * @description       : 
 * @author            : Flistergod
 * @group             : 
 * @last modified on  : 02-01-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   01-29-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
@isTest
private class Loyalty_Test_Util_RewardValueDml {
   
    private static Id rewardValueId;
  

    static void populateMockData() {

        List<RecordType> loyaltyProgramRecordTypes = [Select Id From RecordType where sobjecttype = 'Loyalty_Program__c' and Name like '%Spend%'];
        List<RecordType> programMemberRecordTypes = [Select Id From RecordType where sobjecttype = 'Loyalty_Program_Member__c' and Name like '%Spend%'];


        Account acc= new Account();
        acc.Name='account_unitTest';
        insert acc;

        Loyalty_Level__c loyaltyLevel= new Loyalty_Level__c();
        loyaltyLevel.Name='loyaltyLevel_unitTest';
        insert loyaltyLevel;

        Loyalty_Program__c loyaltyProgram= new Loyalty_Program__c();
        loyaltyProgram.Description__c='Loyalty Program used to test Reward Value';
        loyaltyProgram.Name='loyaltyProgram_unitTest';
        loyaltyProgram.Program_Start_Date__c=date.parse('10/08/2020');
        loyaltyProgram.Program_End_Date__c=date.parse('10/08/2021');
        loyaltyProgram.RecordTypeId=loyaltyProgramRecordTypes[0].Id;
        loyaltyProgram.Type__c='Spend Program';
        insert loyaltyProgram;

        Loyalty_Program_Member__c programMember = new Loyalty_Program_Member__c();
        programMember.Is_Active__c=true;
        programMember.Joining_Date__c=date.parse('10/01/2021');
        programMember.Loyalty_Level__c=loyaltyLevel.Id; // lookup
        programMember.Loyalty_Program__c=loyaltyProgram.Id; //lookup
        programMember.Member__c=acc.Id; //lookup
        programMember.Name='program_Member_unitTest';
        programMember.Member_Number__c='dfgdfgd3232424';
        programMember.RecordTypeId = programMemberRecordTypes[0].Id;
        insert programMember;

        Loyalty_Business_Group__c busGrp= new Loyalty_Business_Group__c();
        busGrp.Name='business_Group_unitTest';
        busGrp.Is_Associated_Group__c=false;
        insert busGrp;

        Loyalty_Brand__c loyaltyBrand= new Loyalty_Brand__c();
        loyaltyBrand.Business_Group__c=busGrp.Id; //lookup
        loyaltyBrand.Name='loyaltyBrand_unitTest';
        insert loyaltyBrand;

        Loyalty_Value__c lv= new Loyalty_Value__c();
        lv.Customer_Points__c=100;
        lv.Customer_Spend_Points__c=30;
        lv.Expiration_Date__c=date.parse('10/07/2021');
        lv.Is_Points_Used__c=false;
        lv.Loyalty_Brand_Value__c=loyaltyBrand.Id;//lookup
        lv.Loyalty_Business_Group__c=busGrp.Id;// lookup
        lv.Name='Loyalty_Value_unitTest';
        lv.Program_Member__c=programMember.Id; //lookup
        insert lv;

        Loyalty_Reward__c lr= new  Loyalty_Reward__c();
        lr.Name='Loyalty_Reward_unitTest';
        insert lr;

        Loyalty_Reward_Value__c rewardValueRecord= new Loyalty_Reward_Value__c();
        rewardValueRecord.Name='rewardValueRecord';
        rewardValueRecord.Is_Delivered__c=false;
        rewardValueRecord.Loyalty_Reward__c=lr.Id; //lookup
        rewardValueRecord.Loyalty_Value__c=lv.Id; //lookup
        rewardValueRecord.Reward_Type__c='Offer';
        insert rewardValueRecord;

        rewardValueId=rewardValueRecord.Id;
    }
         

    @IsTest static void testUtil_LoyaltyRewardValueDml() {
        
        Loyalty_Util_RewardValueDml controller = new Loyalty_Util_RewardValueDml();
    	System.assertNotEquals(controller,null); 
    }

    @IsTest static void getLoyaltyRewardValues(){
        
        Loyalty_Util_RewardValueDml controller = new Loyalty_Util_RewardValueDml();
        List<Loyalty_Reward_Value__c> returnedRewardValues=new List<Loyalty_Reward_Value__c>();
        Integer pagenumber=1;
        Integer pageSize=10;
        Integer lastRecordPosition=0;
        Boolean isAddedData=false;
        String searchString=null;
        List<String> whereClauses=null;
        String orderByStr='Name';

        Test.startTest();
        populateMockData();    
       
        returnedRewardValues= controller.getLoyaltyRewardValues(pagenumber, pageSize, lastRecordPosition, isAddedData, 
        searchString, whereClauses, orderByStr);

    	System.assertEquals(returnedRewardValues.size(),1); 
        Test.stopTest();
    }
    
    @IsTest static void getLoyaltyRewardValuesCount() {
      
        Loyalty_Util_RewardValueDml controller = new Loyalty_Util_RewardValueDml();
        List<Loyalty_Reward_Value__c> returnedRewardValues=new List<Loyalty_Reward_Value__c>();

        Integer quantity=0;

        Test.startTest();
        populateMockData();   
        
        returnedRewardValues=[Select Id from Loyalty_Reward_Value__c];
        quantity= controller.getLoyaltyRewardValuesCount();
        
        System.assertEquals(returnedRewardValues.size(),quantity);      
        Test.stopTest();
    }


    @IsTest static void getRewardValueById() {
      
        Loyalty_Util_RewardValueDml controller = new Loyalty_Util_RewardValueDml();
        List<Loyalty_Reward_Value__c> returnedRewardValues=new List<Loyalty_Reward_Value__c>();

        Test.startTest();
        populateMockData();   
        
        returnedRewardValues= controller.getRewardValueById(rewardValueId);
        
        System.assertEquals(returnedRewardValues.size(),1);      
        Test.stopTest();
    }

    @IsTest static void insertLoyaltyRewardValues() {
       
        Loyalty_Util_RewardValueDml controller = new Loyalty_Util_RewardValueDml();
        String resultMessage='';
      
        Test.startTest();        
        List<Loyalty_Reward_Value__c> rewardValueToInsert= new List<Loyalty_Reward_Value__c>();
        List<RecordType> loyaltyProgramRecordTypes = [Select Id From RecordType where sobjecttype = 'Loyalty_Program__c' and Name like '%Spend%'];
        List<RecordType> programMemberRecordTypes = [Select Id From RecordType where sobjecttype = 'Loyalty_Program_Member__c' and Name like '%Spend%'];

        Account acc= new Account();
        acc.Name='account_unitTest';
        insert acc;

        Loyalty_Level__c loyaltyLevel= new Loyalty_Level__c();
        loyaltyLevel.Name='loyaltyLevel_unitTest';
        insert loyaltyLevel;

        Loyalty_Program__c loyaltyProgram= new Loyalty_Program__c();
        loyaltyProgram.Description__c='Loyalty Program used to test Reward Value';
        loyaltyProgram.Name='loyaltyProgram_unitTest';
        loyaltyProgram.Program_Start_Date__c=date.parse('10/08/2020');
        loyaltyProgram.Program_End_Date__c=date.parse('10/08/2021');
        loyaltyProgram.RecordTypeId=loyaltyProgramRecordTypes[0].Id;
        loyaltyProgram.Type__c='Spend Program';
        insert loyaltyProgram;

        Loyalty_Program_Member__c programMember = new Loyalty_Program_Member__c();
        programMember.Is_Active__c=true;
        programMember.Joining_Date__c=date.parse('10/01/2021');
        programMember.Loyalty_Level__c=loyaltyLevel.Id; // lookup
        programMember.Loyalty_Program__c=loyaltyProgram.Id; //lookup
        programMember.Member__c=acc.Id; //lookup
        programMember.Name='program_Member_unitTest';
        programMember.Member_Number__c='dfgdfgd3232424';
        programMember.RecordTypeId = programMemberRecordTypes[0].Id;
        insert programMember;

        Loyalty_Business_Group__c busGrp= new Loyalty_Business_Group__c();
        busGrp.Name='business_Group_unitTest';
        busGrp.Is_Associated_Group__c=false;
        insert busGrp;

        Loyalty_Brand__c loyaltyBrand= new Loyalty_Brand__c();
        loyaltyBrand.Business_Group__c=busGrp.Id; //lookup
        loyaltyBrand.Name='loyaltyBrand_unitTest';
        insert loyaltyBrand;

        Loyalty_Value__c lv= new Loyalty_Value__c();
        lv.Customer_Points__c=100;
        lv.Customer_Spend_Points__c=30;
        lv.Expiration_Date__c=date.parse('10/07/2021');
        lv.Is_Points_Used__c=false;
        lv.Loyalty_Brand_Value__c=loyaltyBrand.Id;//lookup
        lv.Loyalty_Business_Group__c=busGrp.Id;// lookup
        lv.Name='Loyalty_Value_unitTest';
        lv.Program_Member__c=programMember.Id; //lookup
        insert lv;

        Loyalty_Reward__c lr= new  Loyalty_Reward__c();
        lr.Name='Loyalty_Reward_unitTest';
        insert lr;

        Loyalty_Reward_Value__c rewardValueRecord= new Loyalty_Reward_Value__c();
        rewardValueRecord.Name='rewardValueRecord';
        rewardValueRecord.Is_Delivered__c=false;
        rewardValueRecord.Loyalty_Reward__c=lr.Id; //lookup
        rewardValueRecord.Loyalty_Value__c=lv.Id; //lookup
        rewardValueRecord.Reward_Type__c='Offer';
        rewardValueToInsert.add(rewardValueRecord);

        resultMessage=  controller.insertLoyaltyRewardValues(rewardValueToInsert);
    
    	System.assertEquals(resultMessage,'INSERT SUCCESS'); 
        Test.stopTest();
    }

    @IsTest static void insertRewardValue() {
       
        Loyalty_Util_RewardValueDml controller = new Loyalty_Util_RewardValueDml();
        String resultMessage='';
      
        Test.startTest();        
        List<RecordType> loyaltyProgramRecordTypes = [Select Id From RecordType where sobjecttype = 'Loyalty_Program__c' and Name like '%Spend%'];
        List<RecordType> programMemberRecordTypes = [Select Id From RecordType where sobjecttype = 'Loyalty_Program_Member__c' and Name like '%Spend%'];

        Account acc= new Account();
        acc.Name='account_unitTest';
        insert acc;

        Loyalty_Level__c loyaltyLevel= new Loyalty_Level__c();
        loyaltyLevel.Name='loyaltyLevel_unitTest';
        insert loyaltyLevel;

        Loyalty_Program__c loyaltyProgram= new Loyalty_Program__c();
        loyaltyProgram.Description__c='Loyalty Program used to test Reward Value';
        loyaltyProgram.Name='loyaltyProgram_unitTest';
        loyaltyProgram.Program_Start_Date__c=date.parse('10/08/2020');
        loyaltyProgram.Program_End_Date__c=date.parse('10/08/2021');
        loyaltyProgram.RecordTypeId=loyaltyProgramRecordTypes[0].Id;
        loyaltyProgram.Type__c='Spend Program';
        insert loyaltyProgram;

        Loyalty_Program_Member__c programMember = new Loyalty_Program_Member__c();
        programMember.Is_Active__c=true;
        programMember.Joining_Date__c=date.parse('10/01/2021');
        programMember.Loyalty_Level__c=loyaltyLevel.Id; // lookup
        programMember.Loyalty_Program__c=loyaltyProgram.Id; //lookup
        programMember.Member__c=acc.Id; //lookup
        programMember.Name='program_Member_unitTest';
        programMember.Member_Number__c='dfgdfgd3232424';
        programMember.RecordTypeId = programMemberRecordTypes[0].Id;
        insert programMember;

        Loyalty_Business_Group__c busGrp= new Loyalty_Business_Group__c();
        busGrp.Name='business_Group_unitTest';
        busGrp.Is_Associated_Group__c=false;
        insert busGrp;

        Loyalty_Brand__c loyaltyBrand= new Loyalty_Brand__c();
        loyaltyBrand.Business_Group__c=busGrp.Id; //lookup
        loyaltyBrand.Name='loyaltyBrand_unitTest';
        insert loyaltyBrand;

        Loyalty_Value__c lv= new Loyalty_Value__c();
        lv.Customer_Points__c=100;
        lv.Customer_Spend_Points__c=30;
        lv.Expiration_Date__c=date.parse('10/07/2021');
        lv.Is_Points_Used__c=false;
        lv.Loyalty_Brand_Value__c=loyaltyBrand.Id;//lookup
        lv.Loyalty_Business_Group__c=busGrp.Id;// lookup
        lv.Name='Loyalty_Value_unitTest';
        lv.Program_Member__c=programMember.Id; //lookup
        insert lv;

        Loyalty_Reward__c lr= new  Loyalty_Reward__c();
        lr.Name='Loyalty_Reward_unitTest';
        insert lr;

        Loyalty_Reward_Value__c rewardValueRecord= new Loyalty_Reward_Value__c();
        rewardValueRecord.Name='rewardValueRecord';
        rewardValueRecord.Is_Delivered__c=false;
        rewardValueRecord.Loyalty_Reward__c=lr.Id; //lookup
        rewardValueRecord.Loyalty_Value__c=lv.Id; //lookup
        rewardValueRecord.Reward_Type__c='Offer';
       
        resultMessage=  controller.insertRewardValue(rewardValueRecord);
    
    	System.assertEquals(resultMessage,'INSERT SUCCESS'); 
        Test.stopTest();
    }

    @IsTest static void changeLoyaltyRewardValueField() {
        
        Loyalty_Util_RewardValueDml controller = new Loyalty_Util_RewardValueDml();
        String message='';

        Test.startTest();
        populateMockData();   
        
        String field='Reward_Type__c';
        Object newFieldValue='Voucher';
        Id rewardValueId=rewardValueId;
        String name = 'rewardValueRecord';

        message=controller.changeLoyaltyRewardValueField(field, newFieldValue, rewardValueId, name);
        
    	System.assertEquals('UPDATE SUCCESS', message);
        Test.stopTest();
    }

    @IsTest static void updateRewardValue() {
       
        Loyalty_Util_RewardValueDml controller = new Loyalty_Util_RewardValueDml();
        String message='';

        Test.startTest();
        populateMockData();   
        
        Loyalty_Reward_Value__c editRewardValue=[Select Id from Loyalty_Reward_Value__c where Id=:rewardValueId];

        message=controller.updateRewardValue(editRewardValue);
        
    	System.assertEquals('UPDATE SUCCESS', message);
        Test.stopTest();
    }

    /*
    
    @IsTest static void getLoyaltyRewardValueListViews() {

        List<ListView> rewardValueListViews = new List<ListView>();
        Loyalty_Util_RewardValueDml controller = new Loyalty_Util_RewardValueDml();
        Integer quantity=0;
        Integer quantity2=0;

        Test.startTest();
        populateMockData();   
        
        rewardValueListViews=[Select Id, DeveloperName from ListView where SObjectType = 'Loyalty_Reward_Value__c'];
        quantity= rewardValueListViews.size();
        rewardValueListViews=controller.getLoyaltyRewardValueListViews();
        quantity2= rewardValueListViews.size();
        
        System.assertEquals(quantity2,quantity);      
        Test.stopTest();
    }

    */

  
}