@isTest
private class Loyalty_Test_Util_ProgramSetupLevelDml {
    private static Id accountId;
    private static Id programSetupId;
    private static Id loyaltyLevelId;
    private static Loyalty_Program_Setup_Level__c currentLevel;

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
        
        Loyalty_Level__c loyaltyLevel = new Loyalty_Level__c();
		loyaltyLevel.Name = 'Silver Customer';

        insert loyaltyLevel;
        
        Loyalty_Level__c loyaltyLevel2 = new Loyalty_Level__c();
		loyaltyLevel2.Name = 'Gold Customer';

        insert loyaltyLevel2;

        loyaltyLevelId = loyaltyLevel.Id;

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
        
        List<Loyalty_Program_Setup__c> programSetups = new List<Loyalty_Program_Setup__c>();

        Loyalty_Program_Setup__c programSpendSetup = new Loyalty_Program_Setup__c();
        programSpendSetup.Loyalty_Program__c = programSpend.Id;
        List<RecordType> spendSetupRecordType = [Select Id From RecordType where sobjecttype = 'Loyalty_Program_Setup__c' and name = 'Spend Program Setup'];
        programSpendSetup.RecordTypeId = spendSetupRecordType[0].Id;
        programSpendSetup.Points_Per_Value_Spent__c = 23;
        programSpendSetup.Value_Spent__c = 30;
        programSpendSetup.Points_Validity_Days__c = 600;

        programSetups.add(programSpendSetup);

        insert programSetups;

        programSetupId = programSpendSetup.Id;
        
        List<Loyalty_Program_Setup_Level__c> programSetupLevels = new List<Loyalty_Program_Setup_Level__c>();

        Loyalty_Program_Setup_Level__c programSpendSetupLevel = new Loyalty_Program_Setup_Level__c();
        programSpendSetupLevel.Achievable_Bought_Items__c = 4;
        programSpendSetupLevel.Achievable_Points__c = 50;
        programSpendSetupLevel.Achievable_Purchases__c = 5;
        programSpendSetupLevel.Is_Bought_Items_Mandatory__c = false;
        programSpendSetupLevel.Is_Points_Manadatory__c = true;
        programSpendSetupLevel.Is_Purchases_Mandatory__c = false;
        programSpendSetupLevel.Loyalty_Level__c = loyaltyLevel.Id;
        programSpendSetupLevel.Loyalty_Program_Setup__c = programSpendSetup.Id;
        programSpendSetupLevel.Loyalty_Reward_Achievable__c = null;
        programSpendSetupLevel.Name = 'Spend silver level';

        programSetupLevels.add(programSpendSetupLevel);

        
        Loyalty_Program_Setup_Level__c programSpendSetupLevel2 = new Loyalty_Program_Setup_Level__c();
        programSpendSetupLevel2.Achievable_Bought_Items__c = 40;
        programSpendSetupLevel2.Achievable_Points__c = 500;
        programSpendSetupLevel2.Achievable_Purchases__c = 50;
        programSpendSetupLevel2.Is_Bought_Items_Mandatory__c = true;
        programSpendSetupLevel2.Is_Points_Manadatory__c = true;
        programSpendSetupLevel2.Is_Purchases_Mandatory__c = false;
        programSpendSetupLevel2.Loyalty_Level__c = loyaltyLevel2.Id;
        programSpendSetupLevel2.Loyalty_Program_Setup__c = programSpendSetup.Id;
        programSpendSetupLevel2.Loyalty_Reward_Achievable__c = null;
        programSpendSetupLevel2.Name = 'Spend Gold level';

        programSetupLevels.add(programSpendSetupLevel2);

        insert programSetupLevels;

        currentLevel = programSpendSetupLevel;
    }

    @IsTest static void testUtil_ProgramSetupLevelDml() {
    	Loyalty_Util_ProgramSetupLevelDml controller = new Loyalty_Util_ProgramSetupLevelDml();
    
    	System.assertNotEquals(controller,null); 
    }

    @IsTest static void testGetProgramSetupLevelsByProgramSetupId() {
        Loyalty_Util_ProgramSetupLevelDml controller = new Loyalty_Util_ProgramSetupLevelDml();
        
        Test.startTest();
        populateMockData();
        List<Loyalty_Program_Setup_Level__c> programSetupLevels = controller.getProgramSetupLevelsByProgramSetupId(programSetupId);
    
    	System.assertNotEquals(programSetupLevels,null); 
        Test.stopTest();
    }

    @IsTest static void testGetProgramSetupLevelByLoyaltyLevelId() {
        Loyalty_Util_ProgramSetupLevelDml controller = new Loyalty_Util_ProgramSetupLevelDml();
        
        Test.startTest();
        populateMockData();
        Loyalty_Program_Setup_Level__c programSetupLevel = controller.getProgramSetupLevelByLoyaltyLevelId(loyaltyLevelId);
    
    	System.assertNotEquals(programSetupLevel,null); 
        Test.stopTest();
    }

    @IsTest static void testGetNextProgramSetupLevels() {
        Loyalty_Util_ProgramSetupLevelDml controller = new Loyalty_Util_ProgramSetupLevelDml();
        
        Test.startTest();
        populateMockData();
        List<Loyalty_Program_Setup_Level__c> programSetupLevels = controller.getNextProgramSetupLevels(programSetupId, currentLevel);
    
    	System.assertNotEquals(programSetupLevels,null); 
        Test.stopTest();
    }
}