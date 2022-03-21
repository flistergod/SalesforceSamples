/*
   @Author: João Almeida
   @CreatedDate: 08/09/2020
   @Description: Opportunity trigger logic. Implemented methods with logic
 */
public class Loyalty_Opportunity_tl {
	private Loyalty_Opportunity_th handler;

	public Loyalty_Opportunity_tl(Loyalty_Opportunity_th handler) {
		this.handler = handler;
	}

    /*
	   @Description: checks that the opportunity was updated to won
	 */
	public void processCustomerLoyaltyValues() {
		Loyalty_I_ManageLoyaltyValue processOpptyValues = new Loyalty_Util_ManageLoyaltyValue();

		List<Opportunity> opptiesWon = new List<Opportunity>();
		for(Opportunity oppty : handler.getNewMap().values()) {
			Opportunity oldValues = handler.getOldMap().get(oppty.Id);
			if (oldValues != null && oldValues.IsWon != oppty.IsWon && oppty.IsWon) {
				opptiesWon.add(oppty);
			}
		}
		processOpptyValues.processCustomerOpptyLoyaltyValues(opptiesWon);
	}
}