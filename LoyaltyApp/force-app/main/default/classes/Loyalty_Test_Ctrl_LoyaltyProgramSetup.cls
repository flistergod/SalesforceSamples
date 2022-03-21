@isTest
private class Loyalty_Test_Ctrl_LoyaltyProgramSetup {
    @testSetup
    static void populateMockData() {List<Loyalty_Program__c> programs = new List<Loyalty_Program__c>();

        Loyalty_Program__c programPoints = new Loyalty_Program__c();
        programPoints.Type__c = 'Point Program';
        List<RecordType> pointRecordType = [Select Id From RecordType where sobjecttype = 'Loyalty_Program__c' and name = 'Point Program'];
        programPoints.RecordTypeId = pointRecordType[0].Id;
        programPoints.Program_Start_Date__c = system.today();
        programPoints.Program_End_Date__c = date.parse('27/12/2045');

        programs.add(programPoints);

        insert programs;

        Loyalty_Program_Setup__c pointsSetup = new Loyalty_Program_Setup__c();
        pointsSetup.Name = 'Point Program Setup';
        List<RecordType> pointSetupRecordType = [Select Id From RecordType where sobjecttype = 'Loyalty_Program_Setup__c' and name = 'Point Program Setup'];
        pointsSetup.RecordTypeId = pointSetupRecordType[0].Id;
        pointsSetup.Points_Per_Value_Spent__c = 23.0;
        pointsSetup.Value_Spent__c = 30.0;
        pointsSetup.Points_Validity_Days__c = 60.0;
        pointsSetup.Active__c = true;
        pointsSetup.Loyalty_Program__c = programPoints.Id;

        insert pointsSetup;
    }

    @isTest
    static void testGetProgramSetupId() {
        
        Test.startTest();
        List<Loyalty_Program__c> programs = [SELECT Id, Name FROM Loyalty_Program__c];
        
        Id programSetupId = Loyalty_Ctrl_LoyaltyProgramSetup.getProgramSetupId(programs[0].Id);
        System.assertNotEquals(programSetupId,null);

        Test.stopTest();
    }

    @isTest
    static void getProgramSetupRecordTypeId() {
        
        Test.startTest();
        List<Loyalty_Program__c> programs = [SELECT Id, Name FROM Loyalty_Program__c];
        
        Loyalty_Program_Setup__c programSetup = Loyalty_Ctrl_LoyaltyProgramSetup.getProgramSetupRecordTypeId(programs[0].Id);
        System.assertNotEquals(programSetup,null);

        Test.stopTest();

    }
}