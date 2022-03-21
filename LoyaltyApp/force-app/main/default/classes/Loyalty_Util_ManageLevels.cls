public with sharing class Loyalty_Util_ManageLevels implements Loyalty_I_ManageLevels {
    public Loyalty_Util_ManageLevels() {

    }

    /*
	   @Description: determines if the customer can achieve a new loyalty level
       @param1: the customer spend points if any
       @param2: the customer total bought items if any
       @param3: the customer total purchases if any
       @param4: the customer account id
       @param5: the customer loyalty program setup record
       @param6: the customer program member record
	   @Return: the new level if reached, null otherwise
	 */
    public Loyalty_Program_Setup_Level__c calculateNewCustomerLoyaltyLevel(integer customerTotalSpendPoints, integer customerTotalBoughtItems, integer customerTotalPurchases, Id accountId, Loyalty_Program_Setup__c programSetup, Loyalty_Program_Member__c customerProgramMember) {
        Loyalty_Program_Setup_Level__c nextLevelReached = null;
        Loyalty_Program_Setup_Level__c memberLevelSetup = null;
        List<Loyalty_Program_Setup_Level__c> programSetupLevels = null;
        Loyalty_Util_ProgramSetupLevelDml programSetupLevelDml = new Loyalty_Util_ProgramSetupLevelDml();

        try {
            if (customerProgramMember != null && customerProgramMember.Loyalty_Level__c != null) {
                memberLevelSetup = programSetupLevelDml.getProgramSetupLevelByLoyaltyLevelId(customerProgramMember.Loyalty_Level__r.Id);
            }

            programSetupLevels = programSetupLevelDml.getNextProgramSetupLevels(programSetup.Id, memberLevelSetup);
        }
        catch(Exception ex) {

        }

        for (Loyalty_Program_Setup_Level__c setupLevel : programSetupLevels) {
			boolean boughtItemsAchieved = true;
			boolean pointsAchieved = true;
            boolean numPurchasesAchieved = true;
            System.debug(customerTotalSpendPoints + ' achievable points: ' + setupLevel.Achievable_Points__c);
            System.debug(customerTotalBoughtItems + ' achievable bought items: ' + setupLevel.Achievable_Bought_Items__c);
            System.debug(customerTotalPurchases + ' achievable purchases: ' + setupLevel.Achievable_Purchases__c);
			if (setupLevel.Is_Bought_Items_Mandatory__c) {
				if (customerTotalBoughtItems < setupLevel.Achievable_Bought_Items__c
					|| (nextLevelReached != null && nextLevelReached.Is_Bought_Items_Mandatory__c && nextLevelReached.Achievable_Bought_Items__c > setupLevel.Achievable_Bought_Items__c)
					) {
					boughtItemsAchieved = false;
				}
			}
			if (setupLevel.Is_Points_Manadatory__c) {
				if (customerTotalSpendPoints < setupLevel.Achievable_Points__c
					|| (nextLevelReached != null && nextLevelReached.Is_Points_Manadatory__c && nextLevelReached.Achievable_Points__c > setupLevel.Achievable_Points__c)
					) {
					pointsAchieved = false;
				}
			}
			if (setupLevel.Is_Purchases_Mandatory__c) {
				if (customerTotalPurchases < setupLevel.Achievable_Purchases__c
					|| (nextLevelReached != null && nextLevelReached.Is_Purchases_Mandatory__c && nextLevelReached.Achievable_Purchases__c > setupLevel.Achievable_Purchases__c)
					) {
					numPurchasesAchieved = false;
				}
			}
			System.debug(boughtItemsAchieved);
			System.debug(pointsAchieved);
			System.debug(numPurchasesAchieved);
			System.debug(customerTotalPurchases);
			if (boughtItemsAchieved && pointsAchieved && numPurchasesAchieved) {
				nextLevelReached = setupLevel;
			}
		}
		System.debug('levelreached: ');
        System.debug(nextLevelReached);
        
        return nextLevelReached;
    }
}