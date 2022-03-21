@isTest
private class Loyalty_Test_Util_LoyaltyValueDml {
    @testSetup
    static void populateMockData() {
    }

    @IsTest static void testUtil_LoyaltyValueDml() {
    	Loyalty_Util_LoyaltyValueDml controller = new Loyalty_Util_LoyaltyValueDml();
    
    	System.assertNotEquals(controller,null); 
    }
}