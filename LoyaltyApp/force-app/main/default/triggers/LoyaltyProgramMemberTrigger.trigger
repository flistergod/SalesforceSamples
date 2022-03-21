trigger LoyaltyProgramMemberTrigger on Loyalty_Program_Member__c (before insert) {
    new LoyaltyProgramMember_th().run();
}