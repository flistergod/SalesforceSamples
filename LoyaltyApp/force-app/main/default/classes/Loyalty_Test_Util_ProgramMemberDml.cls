@isTest
private class Loyalty_Test_Util_ProgramMemberDml {
    private static Id accountId;
    private static Id programId;
    @testSetup
    static void populateMockData() {
        Account a = new Account(Name = 'Test Account');
        insert a;

        accountId = a.Id;

        List<Loyalty_Program__c> programs = new List<Loyalty_Program__c>();

        Loyalty_Program__c programSpend = new Loyalty_Program__c();
        programSpend.Type__c = 'Spend Program';
        List<RecordType> spendRecordType = [Select Id From RecordType where sobjecttype = 'Loyalty_Program__c' and name = 'Spend Program'];
        programSpend.RecordTypeId = spendRecordType[0].Id;
        programSpend.Program_Start_Date__c = system.today();
        programSpend.Program_End_Date__c = date.parse('27/12/2045');

        programs.add(programSpend);

        insert programs;

        programId = programSpend.Id;
        
        Loyalty_Level__c loyaltyLevel = new Loyalty_Level__c();
		loyaltyLevel.Name = 'Silver Customer';

        insert loyaltyLevel;

        List<Loyalty_Program_Member__c> members = new List<Loyalty_Program_Member__c>();
        
        Loyalty_Program_Member__c member = new Loyalty_Program_Member__c();
        member.Name = 'Silver Customer';
        member.Is_Active__c = true;
        member.Joining_Date__c = date.today();
        member.Loyalty_Level__c = loyaltyLevel.Id;
        member.Loyalty_Program__c = programSpend.Id;
        member.Member__c = a.Id;
        member.Member_Number__c = 'FIRSTMEMBER0001';
        spendRecordType = [Select Id From RecordType where sobjecttype = 'Loyalty_Program_Member__c' and name = 'Spend Program Member'];
        member.RecordTypeId = spendRecordType[0].Id;
        
        members.add(member);

        insert members;
    }

    @IsTest static void testUtil_ProgramMemberDml() {
    	Loyalty_Util_ProgramMemberDml controller = new Loyalty_Util_ProgramMemberDml();
    
    	System.assertNotEquals(controller,null); 
    }

    @IsTest static void testGetCustomerLoyaltyProgramsByAccountId() {
        Loyalty_Util_ProgramMemberDml controller = new Loyalty_Util_ProgramMemberDml();
        
        Test.startTest();
        populateMockData();
        List<Loyalty_Program_Member__c> programMembers = controller.getCustomerLoyaltyProgramsByAccountId(accountId);
    
    	System.assertNotEquals(programMembers,null); 
        Test.stopTest();
    }

    @IsTest static void testGetCustomerLoyaltyProgramTypesByAccountId() {
        Loyalty_Util_ProgramMemberDml controller = new Loyalty_Util_ProgramMemberDml();
        
        Test.startTest();
        populateMockData();
        Set<String> types = controller.getCustomerLoyaltyProgramTypesByAccountId(accountId);
    
    	System.assertNotEquals(types,null); 
        Test.stopTest();
    }

    @IsTest static void testGetCurrentCustomerLoyaltyLevel() {
        Loyalty_Util_ProgramMemberDml controller = new Loyalty_Util_ProgramMemberDml();
        
        Test.startTest();
        populateMockData();
        Loyalty_Program_Member__c programMemberLevel = controller.getCurrentCustomerLoyaltyLevel(accountId, programId);
    
    	System.assertNotEquals(programMemberLevel,null); 
        Test.stopTest();
    }
}