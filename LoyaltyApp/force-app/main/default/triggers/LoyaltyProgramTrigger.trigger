trigger LoyaltyProgramTrigger on Loyalty_Program__c (after insert) {
    new LoyaltyProgram_th().run();
}