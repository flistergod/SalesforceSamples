@isTest
private class Loyalty_Test_OpportunityUpdated {

    @testSetup
    static void populateMockData() {

        /**
         * Define customer data
         */
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
            oppty.Amount = 1000;

            oppties.add(oppty);
        }
        insert oppties;

        /**
         * Create the available programs and the loyalty levels
         */
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

        List<Loyalty_Level__c> loyaltyLevels = new List<Loyalty_Level__c>();

        Loyalty_Level__c loyaltyLevel = new Loyalty_Level__c();
		loyaltyLevel.Name = 'Silver Customer';
        loyaltyLevels.add(loyaltyLevel);
        
        Loyalty_Level__c loyaltyLevel2 = new Loyalty_Level__c();
		loyaltyLevel2.Name = 'Gold Customer';
        loyaltyLevels.add(loyaltyLevel2);
        
        Loyalty_Level__c loyaltyLevel3 = new Loyalty_Level__c();
		loyaltyLevel3.Name = 'Platinum Customer';
        loyaltyLevels.add(loyaltyLevel3);

        Loyalty_Level__c loyaltyLevel4 = new Loyalty_Level__c();
		loyaltyLevel4.Name = 'Ultimate Customer';
        loyaltyLevels.add(loyaltyLevel4);

        insert loyaltyLevels;

        /**
         * Create program members
         */
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

        /**
         * Create programs setups
         */
        List<Loyalty_Program_Setup__c> programSetups = new List<Loyalty_Program_Setup__c>();
        List<Loyalty_Program_Setup__c> existingSpendSetup = [SELECT Id FROM Loyalty_Program_Setup__c WHERE Loyalty_Program__c =: programSpend.Id];
        if (existingSpendSetup != null && !existingSpendSetup.isEmpty()) {
            existingSpendSetup[0].Name = 'Spend Program Setup';
            List<RecordType> spendSetupRecordType = [Select Id From RecordType where sobjecttype = 'Loyalty_Program_Setup__c' and name = 'Spend Program Setup'];
            existingSpendSetup[0].RecordTypeId = spendSetupRecordType[0].Id;
            existingSpendSetup[0].Points_Per_Value_Spent__c = 23;
            existingSpendSetup[0].Value_Spent__c = 30;
            existingSpendSetup[0].Points_Validity_Days__c = 600;

            programSetups.add(existingSpendSetup[0]);
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

        /**
         * Create program setup level for each loyalty level related to spend program
         */
        List<Loyalty_Program_Setup_Level__c> programSetupLevels = new List<Loyalty_Program_Setup_Level__c>();

        Loyalty_Program_Setup_Level__c programSpendSetupLevel1 = new Loyalty_Program_Setup_Level__c();
        programSpendSetupLevel1.Achievable_Bought_Items__c = 4;
        programSpendSetupLevel1.Achievable_Points__c = 50;
        programSpendSetupLevel1.Achievable_Purchases__c = 5;
        programSpendSetupLevel1.Is_Bought_Items_Mandatory__c = false;
        programSpendSetupLevel1.Is_Points_Manadatory__c = true;
        programSpendSetupLevel1.Is_Purchases_Mandatory__c = false;
        programSpendSetupLevel1.Loyalty_Level__c = loyaltyLevel.Id;
        programSpendSetupLevel1.Loyalty_Program_Setup__c = programSetups[0].Id;
        programSpendSetupLevel1.Loyalty_Reward_Achievable__c = null;
        programSpendSetupLevel1.Name = 'Spend silver level';

        programSetupLevels.add(programSpendSetupLevel1);

        
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

        Loyalty_Program_Setup_Level__c programSpendSetupLevel3 = new Loyalty_Program_Setup_Level__c();
        programSpendSetupLevel3.Achievable_Bought_Items__c = 70;
        programSpendSetupLevel3.Achievable_Points__c = 1000;
        programSpendSetupLevel3.Achievable_Purchases__c = 50;
        programSpendSetupLevel3.Is_Bought_Items_Mandatory__c = true;
        programSpendSetupLevel3.Is_Points_Manadatory__c = true;
        programSpendSetupLevel3.Is_Purchases_Mandatory__c = true;
        programSpendSetupLevel3.Loyalty_Level__c = loyaltyLevel3.Id;
        programSpendSetupLevel3.Loyalty_Program_Setup__c = programSetups[0].Id;
        programSpendSetupLevel3.Loyalty_Reward_Achievable__c = null;
        programSpendSetupLevel3.Name = 'Spend Platinum level';

        programSetupLevels.add(programSpendSetupLevel3);

        Loyalty_Program_Setup_Level__c programSpendSetupLevel4 = new Loyalty_Program_Setup_Level__c();
        programSpendSetupLevel4.Achievable_Bought_Items__c = 70;
        programSpendSetupLevel4.Achievable_Points__c = 1000;
        programSpendSetupLevel4.Achievable_Purchases__c = 100;
        programSpendSetupLevel4.Is_Bought_Items_Mandatory__c = false;
        programSpendSetupLevel4.Is_Points_Manadatory__c = false;
        programSpendSetupLevel4.Is_Purchases_Mandatory__c = true;
        programSpendSetupLevel4.Loyalty_Level__c = loyaltyLevel4.Id;
        programSpendSetupLevel4.Loyalty_Program_Setup__c = programSetups[0].Id;
        programSpendSetupLevel4.Loyalty_Reward_Achievable__c = null;
        programSpendSetupLevel4.Name = 'Spend Ultimate level';

        programSetupLevels.add(programSpendSetupLevel4);

        insert programSetupLevels;
    }

    @isTest
    static void testOpportunityIsWon() {
        Test.startTest();
        List<OpportunityStage> wonStages = [SELECT Id, ApiName, MasterLabel FROM OpportunityStage WHERE IsWon = true];

        List<Opportunity> oppties = [SELECT Id, StageName FROM Opportunity WHERE IsWon = false];
        for (Opportunity oppty: oppties) {
            oppty.StageName = wonStages[0].ApiName;
        }

        update oppties;

        Long startTime = DateTime.now().getTime();
        Long finishTime = DateTime.now().getTime();
        while ((finishTime - startTime) < 9000) {
            //sleep for 9s
            finishTime = DateTime.now().getTime();
        }
        List<Loyalty_Value__c> testValue = [SELECT Id FROM Loyalty_Value__c];
        List<Loyalty_Program_Member__c> testMember = [SELECT Id, Loyalty_Level__c, Loyalty_Level__r.Name FROM Loyalty_Program_Member__c];
        
        System.assertNotEquals(testValue,null);
        System.assertNotEquals(testMember,null);

        Test.stopTest();
    }
}