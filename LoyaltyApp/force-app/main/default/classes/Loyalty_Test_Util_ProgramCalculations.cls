@isTest
private class Loyalty_Test_Util_ProgramCalculations {

    @testSetup
    static void populateMockData() {
        Account a = new Account(Name = 'Test Account');
        insert a;

        List<Opportunity> oppties = new List<Opportunity>();
        List<OpportunityStage> otherStages = [SELECT Id, ApiName, MasterLabel FROM OpportunityStage WHERE IsWon = false];

        for (integer i = 0; i < 1; i++) {
            Opportunity oppty = new Opportunity();
            oppty.name = 'Test Opp';
            oppty.CloseDate = date.today().addDays(10);
            oppty.AccountId = a.id;
            oppty.StageName = otherStages[0].ApiName;
            oppty.Amount = 100;

            oppties.add(oppty);
        }
        insert oppties;

        List<Loyalty_Program__c> programs = new List<Loyalty_Program__c>();

        Loyalty_Program__c programSpend = new Loyalty_Program__c();
        programSpend.Type__c = 'Spend Program';
        List<RecordType> spendRecordType = [Select Id From RecordType where sobjecttype = 'Loyalty_Program__c' and name = 'Spend Program'];
        programSpend.RecordTypeId = spendRecordType[0].Id;
        programSpend.Program_Start_Date__c = system.today();
        programSpend.Program_End_Date__c = date.parse('27/12/2045');

        programs.add(programSpend);

        Loyalty_Program__c programPoints = new Loyalty_Program__c();
        programPoints.Type__c = 'Point Program';
        List<RecordType> pointRecordType = [Select Id From RecordType where sobjecttype = 'Loyalty_Program__c' and name = 'Point Program'];
        programPoints.RecordTypeId = pointRecordType[0].Id;
        programPoints.Program_Start_Date__c = system.today();
        programPoints.Program_End_Date__c = date.parse('27/12/2045');

        programs.add(programPoints);

        insert programs;
        
        Loyalty_Level__c loyaltyLevel = new Loyalty_Level__c();
		loyaltyLevel.Name = 'Silver Customer';

        insert loyaltyLevel;
        
        Loyalty_Level__c loyaltyLevel2 = new Loyalty_Level__c();
		loyaltyLevel2.Name = 'Gold Customer';

        insert loyaltyLevel2;

        List<Loyalty_Program_Member__c> members = new List<Loyalty_Program_Member__c>();
        
        Loyalty_Program_Member__c member = new Loyalty_Program_Member__c();
        member.Name = 'Silver Customer';
        member.Is_Active__c = true;
        member.Joining_Date__c = date.today();
        //member.Loyalty_Level__c = loyaltyLevel.Id; create member without any level
        member.Loyalty_Program__c = programSpend.Id;
        member.Member__c = a.Id;
        member.Member_Number__c = 'FIRSTMEMBER0001';
        spendRecordType = [Select Id From RecordType where sobjecttype = 'Loyalty_Program_Member__c' and name = 'Spend Program Member'];
        member.RecordTypeId = spendRecordType[0].Id;
        
        members.add(member);

        insert members;
        
        List<Loyalty_Program_Setup__c> programSetups = new List<Loyalty_Program_Setup__c>();
        List<Loyalty_Program_Setup__c> existingSetup = [SELECT Id FROM Loyalty_Program_Setup__c WHERE Loyalty_Program__c =: programSpend.Id];
        if (existingSetup != null && !existingSetup.isEmpty()) {
            existingSetup[0].Name = 'Spend Program Setup';
            List<RecordType> spendSetupRecordType = [Select Id From RecordType where sobjecttype = 'Loyalty_Program_Setup__c' and name = 'Spend Program Setup'];
            existingSetup[0].RecordTypeId = spendSetupRecordType[0].Id;
            existingSetup[0].Points_Per_Value_Spent__c = 23;
            existingSetup[0].Value_Spent__c = 30;
            existingSetup[0].Points_Validity_Days__c = 600;

            programSetups.add(existingSetup[0]);
        }
        else {
            Loyalty_Program_Setup__c programSpendSetup = new Loyalty_Program_Setup__c();
            programSpendSetup.Name = 'Spend Program Setup';
            programSpendSetup.Loyalty_Program__c = programSpend.Id;
            List<RecordType> spendSetupRecordType = [Select Id From RecordType where sobjecttype = 'Loyalty_Program_Setup__c' and name = 'Spend Program Setup'];
            programSpendSetup.RecordTypeId = spendSetupRecordType[0].Id;
            programSpendSetup.Points_Per_Value_Spent__c = 23;
            programSpendSetup.Value_Spent__c = 30;
            programSpendSetup.Points_Validity_Days__c = 600;

            programSetups.add(programSpendSetup);
        }

        List<Loyalty_Program_Setup__c> existingPointsSetup = [SELECT Id FROM Loyalty_Program_Setup__c WHERE Loyalty_Program__c =: programPoints.Id];
        if (existingPointsSetup != null && !existingPointsSetup.isEmpty()) {
            existingPointsSetup[0].Name = 'Point Program Setup';
            List<RecordType> pointSetupRecordType = [Select Id From RecordType where sobjecttype = 'Loyalty_Program_Setup__c' and name = 'Point Program Setup'];
            existingPointsSetup[0].RecordTypeId = pointSetupRecordType[0].Id;
            existingPointsSetup[0].Points_Per_Value_Spent__c = 23.0;
            existingPointsSetup[0].Value_Spent__c = 30.0;
            existingPointsSetup[0].Points_Validity_Days__c = 60.0;

            programSetups.add(existingPointsSetup[0]);
        }
        else {
            Loyalty_Program_Setup__c programPointsSetup = new Loyalty_Program_Setup__c();
            programPointsSetup.Name = 'Point Program Setup';
            programPointsSetup.Loyalty_Program__c = programPoints.Id;
            List<RecordType> pointSetupRecordType = [Select Id From RecordType where sobjecttype = 'Loyalty_Program_Setup__c' and name = 'Point Program Setup'];
            programPointsSetup.RecordTypeId = pointSetupRecordType[0].Id;
            programPointsSetup.Points_Per_Value_Spent__c = 23.0;
            programPointsSetup.Value_Spent__c = 30.0;
            programPointsSetup.Points_Validity_Days__c = 60.0;

            programSetups.add(programPointsSetup);
        }

        upsert programSetups;
        
        List<Loyalty_Program_Setup_Level__c> programSetupLevels = new List<Loyalty_Program_Setup_Level__c>();

        Loyalty_Program_Setup_Level__c programSpendSetupLevel = new Loyalty_Program_Setup_Level__c();
        programSpendSetupLevel.Achievable_Bought_Items__c = 4;
        programSpendSetupLevel.Achievable_Points__c = 50;
        programSpendSetupLevel.Achievable_Purchases__c = 5;
        programSpendSetupLevel.Is_Bought_Items_Mandatory__c = false;
        programSpendSetupLevel.Is_Points_Manadatory__c = true;
        programSpendSetupLevel.Is_Purchases_Mandatory__c = false;
        programSpendSetupLevel.Loyalty_Level__c = loyaltyLevel.Id;
        programSpendSetupLevel.Loyalty_Program_Setup__c = programSetups[0].Id;
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
        programSpendSetupLevel2.Loyalty_Program_Setup__c = programSetups[0].Id;
        programSpendSetupLevel2.Loyalty_Reward_Achievable__c = null;
        programSpendSetupLevel2.Name = 'Spend Gold level';

        programSetupLevels.add(programSpendSetupLevel2);

        insert programSetupLevels;
    }

    @IsTest static void testUtil_LoyaltyProgramCalculations() {
    	Loyalty_I_ProgramCalculations controller = new Loyalty_Util_ProgramCalculations();
    
    	System.assertNotEquals(controller,null); 
    }
    
    @IsTest static void testCalculatePointsProgram() {
        Loyalty_I_ProgramCalculations controller = new Loyalty_Util_ProgramCalculations();
        
        Test.startTest();
        List<Account> accounts = [SELECT Id from Account where Name='Test Account'];
        List<Opportunity> opptys = [SELECT Id from Opportunity where Name='Test Opp'];
        LoyaltyCalcWrappers.PointCalcResult pointCalcResult = controller.calculatePointsProgram(new List<LoyaltyWrappers.LoyaltyProductItem>(), opptys[0], 'Opportunity', accounts[0].Id, 500);
        System.debug(pointCalcResult);
    	System.assertNotEquals(pointCalcResult,null); 
        Test.stopTest();
    }

    @IsTest static void testCalculateSpendProgram() {
        Loyalty_I_ProgramCalculations controller = new Loyalty_Util_ProgramCalculations();
        
        Test.startTest();
        List<Account> accounts = [SELECT Id from Account where Name='Test Account'];
        List<Opportunity> opptys = [SELECT Id from Opportunity where Name='Test Opp'];
        LoyaltyCalcWrappers.SpendCalcResult spendCalcResult = controller.calculateSpendProgram(new List<LoyaltyWrappers.LoyaltyProductItem>(), opptys[0], 'Opportunity', accounts[0].Id, 500);
        System.debug(spendCalcResult);
    	System.assertNotEquals(spendCalcResult,null); 
        Test.stopTest();
    }
}