@isTest
private class Loyalty_Test_Util_LoyaltyLevelDml {
    @testSetup
    static void populateMockData() {
    }

    @IsTest static void testUtil_LoyaltyLevelDml() {
    	Loyalty_Util_LoyaltyLevelDml controller = new Loyalty_Util_LoyaltyLevelDml();
    
    	System.assertNotEquals(controller,null); 
    }
}