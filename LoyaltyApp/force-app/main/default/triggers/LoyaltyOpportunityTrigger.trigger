trigger LoyaltyOpportunityTrigger on Opportunity (after update) {
    new Loyalty_Opportunity_th().run();
}