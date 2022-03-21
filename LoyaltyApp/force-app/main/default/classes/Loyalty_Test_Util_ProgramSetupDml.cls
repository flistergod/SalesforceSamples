@isTest
private class Loyalty_Test_Util_ProgramSetupDml {
    private static Id testProgramId;
    private static Id testProgramSetupId;

    static void populateMockData() {
        List<Loyalty_Program__c> programs = new List<Loyalty_Program__c>();

        Loyalty_Program__c programPoints = new Loyalty_Program__c();
        programPoints.Type__c = 'Point Program';
        List<RecordType> pointRecordType = [Select Id From RecordType where sobjecttype = 'Loyalty_Program__c' and name = 'Point Program'];
        programPoints.RecordTypeId = pointRecordType[0].Id;
        programPoints.Program_Start_Date__c = system.today();
        programPoints.Program_End_Date__c = date.parse('27/12/2045');

        programs.add(programPoints);

        insert programs;

        testProgramId = programPoints.Id;

        List<Loyalty_Program_Setup__c> programSetups = new List<Loyalty_Program_Setup__c>();

        Loyalty_Program_Setup__c programPointsSetup = new Loyalty_Program_Setup__c();
        programPointsSetup.Loyalty_Program__c = programPoints.Id;
        List<RecordType> pointSetupRecordType = [Select Id From RecordType where sobjecttype = 'Loyalty_Program_Setup__c' and name = 'Point Program Setup'];
        programPointsSetup.RecordTypeId = pointSetupRecordType[0].Id;
        programPointsSetup.Points_Per_Value_Spent__c = 23;
        programPointsSetup.Value_Spent__c = 30;
        programPointsSetup.Points_Validity_Days__c = 60;

        programSetups.add(programPointsSetup);

        insert programSetups;

        testProgramSetupId = programPointsSetup.Id;
    }

    @IsTest static void testUtil_LoyaltyProgramSetupDml() {
    	Loyalty_Util_ProgramSetupDml controller = new Loyalty_Util_ProgramSetupDml();
    
    	System.assertNotEquals(controller,null); 
    }

    @IsTest static void testGetLoyaltyProgramSetupById() {
        Loyalty_Util_ProgramSetupDml controller = new Loyalty_Util_ProgramSetupDml();
        
        Test.startTest();
        populateMockData();
        Loyalty_Program_Setup__c programSetup = controller.getLoyaltyProgramSetupById(testProgramSetupId);
    
    	System.assertNotEquals(programSetup,null); 
        Test.stopTest();
    }

    @IsTest static void testGetLoyaltyProgramSetupByProgramId() {
        Loyalty_Util_ProgramSetupDml controller = new Loyalty_Util_ProgramSetupDml();
        
        Test.startTest();
        populateMockData();
        Loyalty_Program_Setup__c programSetup = controller.getLoyaltyProgramSetupByProgramId(testProgramId);
    
    	System.assertNotEquals(programSetup,null); 
        Test.stopTest();
    }

    @IsTest static void testGetLoyaltyProgramSetupByIdException() {
        Loyalty_Util_ProgramSetupDml controller = new Loyalty_Util_ProgramSetupDml();
        
        Test.startTest();
        populateMockData();
        try {
            Loyalty_Program_Setup__c programSetup = controller.getLoyaltyProgramSetupById('a032X00000VB2ccQAD');
            System.assertEquals(programSetup,null); 
        }
        catch(Exception ex) {
            System.assertNotEquals(ex,null);
        }
    
        Test.stopTest();
    }

    @IsTest static void testGetLoyaltyProgramSetupByProgramIdException() {
        Loyalty_Util_ProgramSetupDml controller = new Loyalty_Util_ProgramSetupDml();
        
        Test.startTest();
        populateMockData();
        try {
            Loyalty_Program_Setup__c programSetup = controller.getLoyaltyProgramSetupByProgramId('a002X00000ttFp1QAE');
            System.assertEquals(programSetup,null); 
        }
        catch(Exception ex) {
            System.assertNotEquals(ex,null);
        }
    
        Test.stopTest();
    }
}