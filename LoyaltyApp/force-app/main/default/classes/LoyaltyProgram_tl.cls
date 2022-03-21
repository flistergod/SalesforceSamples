/*
   @Author: André Cunha
   @CreatedDate: 07/07/2020
   @Description: Loyalty program trigger logic. Implemented methods with logic
 */
public class LoyaltyProgram_tl {
    private LoyaltyProgram_th handler;

    public LoyaltyProgram_tl(LoyaltyProgram_th handler) {
        this.handler = handler;
    }

    public void createLoyaltyProgramSetup(){

        Set<String> programTypes = new Set<String>();

        for(Loyalty_Program__c loyaltyProgram : handler.getNewMap().values()){
            if(loyaltyProgram.Type__c != null && loyaltyProgram.Type__c != ''){
                String loyaltySetupType = loyaltyProgram.Type__c + ' Setup';
                programTypes.add(loyaltySetupType.replaceAll(' ','_'));
            }
        }

        Map<String,RecordType> mapRecordTypes = new Map<String,RecordType>();

        for(RecordType rt : [SELECT id,Name,DeveloperName,SobjectType From RecordType WHERE DeveloperName IN :programTypes AND IsActive = TRUE]){
            mapRecordTypes.put(rt.name,rt);    
        }

        List<Loyalty_Program_Setup__c> loyaltyProgramSetups = new List<Loyalty_Program_Setup__c>();

        for(Loyalty_Program__c loyaltyProgram : handler.getNewMap().values()){
            if(loyaltyProgram.Type__c != null && loyaltyProgram.Type__c != ''){
                String loyaltySetupType = loyaltyProgram.Type__c + ' Setup';

                Loyalty_Program_Setup__c newSetup = new Loyalty_Program_Setup__c();
                newSetup.RecordTypeId = mapRecordTypes.get(loyaltySetupType).id;
                newSetup.Loyalty_Program__c = loyaltyProgram.id;
                newSetup.Name = loyaltySetupType;
                newSetup.Active__c = true;

                loyaltyProgramSetups.add(newSetup);
            }
        }

        Database.SaveResult[] srSetups = Database.insert(loyaltyProgramSetups);


    }
}