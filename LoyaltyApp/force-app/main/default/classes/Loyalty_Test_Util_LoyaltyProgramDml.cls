@isTest
private class Loyalty_Test_Util_LoyaltyProgramDml {
    private static Id testProgramId;

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
    }

    @IsTest static void testUtil_LoyaltyProgramDml() {
    	Loyalty_Util_LoyaltyProgramDml controller = new Loyalty_Util_LoyaltyProgramDml();
    
    	System.assertNotEquals(controller,null); 
    }

    @IsTest static void testGetLoyaltyProgramByType() {
        Loyalty_Util_LoyaltyProgramDml controller = new Loyalty_Util_LoyaltyProgramDml();
        
        Test.startTest();
        populateMockData();
        Loyalty_Program__c programSetup = controller.getLoyaltyProgramByType('Point Program');
    
    	System.assertNotEquals(programSetup,null); 
        Test.stopTest();
    }

    @IsTest static void testGetLoyaltyProgramByTypeException() {
        Loyalty_Util_LoyaltyProgramDml controller = new Loyalty_Util_LoyaltyProgramDml();
        
        Test.startTest();
        populateMockData();
        try {
            Loyalty_Program__c programSetup = controller.getLoyaltyProgramByType('');
            System.assertEquals(programSetup,null); 
        }
        catch(Exception ex) {
            System.assertNotEquals(ex,null);
        }
    
        Test.stopTest();
    }

    @IsTest static void testGetTypePickListValuesList() {
        Loyalty_Util_LoyaltyProgramDml controller = new Loyalty_Util_LoyaltyProgramDml();
        
        Test.startTest();
        populateMockData();
        List<String> pickListValuesList= controller.getTypePickListValuesList();
        System.assertNotEquals(pickListValuesList,null);

        Test.stopTest();
    }
}