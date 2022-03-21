@ IsTest
public class IndicativeQuotePriceMatrixDomainTest {
    private static Boolean noArgConstructorInvoked = false;
    
    private static Boolean beforeInsertInvoked = false;
    private static List<SObject> beforeInsertRecords;
    private static Boolean beforeUpdateInvoked = false;
    private static List<SObject> beforeUpdateRecords;
    private static Boolean afterUpdateInvoked = false;
    private static List<SObject> afterUpdateRecords;
    
    
    public static void setNoArgConstructorInvoked(boolean val){
        noArgConstructorInvoked = val;
    }
    
    //==================================================================================================================
    // Test setup and utility
    //==================================================================================================================
    
    @TestSetup
    private static void setup() {
        setIndicativeQuotePriceMatrix();
    }
    
    private static void setIndicativeQuotePriceMatrix(){
        List<IndicativeQuotePriceMatrix__c> listIQPM = new List<IndicativeQuotePriceMatrix__c>();
        listIQPM.add(new IndicativeQuotePriceMatrix__c(
            Status__c = 'Active',
            Version__c = 1,
            ChargeRate__c='20',
            Mounting__c = 'Wall', 
            Sockets__c = '3',
            Distance__c = '20',
            Civils__c = 'Hard',
            SpotPrice__c = 25565,
            HigherRangePrice__c = 30000,
            LowerRangePrice__c = 25000));
        insert listIQPM;
    }
    
    //==================================================================================================================
    // Construction test cases
    //==================================================================================================================
    
    @ IsTest
    private static void shouldUpdateIQPM(){
        try{
            List<IndicativeQuotePriceMatrix__c> listIQPM = new List<IndicativeQuotePriceMatrix__c>();
            listIQPM = [SELECT Status__c, Version__c, ChargeRate__c, Mounting__c, Sockets__c, Distance__c, Civils__c, SpotPrice__c, HigherRangePrice__c, LowerRangePrice__c FROM IndicativeQuotePriceMatrix__c WHERE SpotPrice__c = 25565];
            IndicativeQuotePriceMatrix__c IQPM = listIQPM[0];
            IQPM.SpotPrice__c=25570;
            update IQPM;
            System.assert(true);
        }catch (DmlException e) {
            System.debug('An unexpected error has occurred: ' + e.getMessage());
            System.assert(false);
        }
    }
    
    @ IsTest
    private static void shouldGetObjectType(){
        IndicativeQuotePriceMatrixDomain domain = new IndicativeQuotePriceMatrixDomain();
        System.assertEquals(IndicativeQuotePriceMatrix__c.SObjectType,domain.getSObjectType());
    }
    
    
    
}