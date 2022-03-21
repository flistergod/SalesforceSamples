/*
   @Author: João Almeida
   @CreatedDate: 10/09/2020
   @Description: Controller class for loyaltyValue components
 */
public class Loyalty_Ctrl_LoyaltyValue {
    /*
        @Description: method to get summary of customer loyalty values
        @param1: loyalty program id
        @return: return the summary as serialized JSON
	*/
    @AuraEnabled
    public static string getCustomerLoyaltyInformation(Id accountId){
        Loyalty_Util_LoyaltyValueDml memberValueDml = new Loyalty_Util_LoyaltyValueDml();

        LoyaltyWrappers.CustomerLoyaltyValuesSummary summary = memberValueDml.getLoyaltyMemberValues(accountId);

        summary = getCustomerDetails(summary, accountId);

        return JSON.serialize(summary);
    }

    

	/*
	   @Description: gets more customer details
	   @param1: current summary object
	   @param1: account Id
	   @Return: the updated summary object
	 */
	private static LoyaltyWrappers.CustomerLoyaltyValuesSummary getCustomerDetails(LoyaltyWrappers.CustomerLoyaltyValuesSummary currentSummary, Id accountId) {
		integer total = 0;
        Loyalty_Util_OrderDml orderDml = new Loyalty_Util_OrderDml();
        Loyalty_Util_AccountDml accountDml = new Loyalty_Util_AccountDml();
        Loyalty_Util_ProgramMemberDml memberDml = new Loyalty_Util_ProgramMemberDml();
        
        Account accountData = accountDml.getAccountDataByAccountId(accountId);
		if (accountData != null) {
			total = accountData.Loyalty_Opportunity_Total_of_Purchases__c != null ? (integer)accountData.Loyalty_Opportunity_Total_of_Purchases__c : 0;
		}
		total += orderDml.getCountOrdersByAccountId(accountData.Id, true, 'Activated');

        currentSummary.PurchasesQuantity = total;
        currentSummary.CustomerName = accountData.Name;

        try {
            Loyalty_Program_Member__c memberData = memberDml.getCurrentCustomerLoyaltyLevel(accountId, null);
            currentSummary.CustomerLoyaltyLevel = memberData.Loyalty_Level__c != null ? memberData.Loyalty_Level__r.Name : System.Label.Loyalty_Customer_Summary;
        }
        catch (Exception ex) {
            currentSummary.CustomerLoyaltyLevel = System.Label.Loyalty_Customer_Summary;
        }

		return currentSummary;
	}
}