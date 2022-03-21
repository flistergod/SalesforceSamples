/*
   @Author: João Almeida
   @CreatedDate: 08/09/2020
   @Description: Implementation of the methods to manage customer loyalty values (points, discounts, etc.)
 */
public class Loyalty_Util_ManageLoyaltyValue implements Loyalty_I_ManageLoyaltyValue {
	private Loyalty_I_ProgramCalculations programCalcs;
	private class ManageLoyaltyValueException extends Exception {}

	public Loyalty_Util_ManageLoyaltyValue() {
		this.programCalcs = new Loyalty_Util_ProgramCalculations();
	}

	/*
	   @Description: calls all the methods necessary to process the customer loyalty values and updates them
	   @param1: the opportunities won
	 */
	public void processCustomerOpptyLoyaltyValues(List<Opportunity> opptiesWon) {
		LoyaltyCalcWrappers calcWrappers = new LoyaltyCalcWrappers();
		Loyalty_Util_OpportunityLineItemDml opptyLineItemDml = new Loyalty_Util_OpportunityLineItemDml();

		for (Opportunity oppty : opptiesWon) {
			calcWrappers = processValuesForEachCustomer(calcWrappers, opptyLineItemDml.getOpptyLineItemsByOpptyId(oppty.Id), oppty, 'Opportunity', oppty.AccountId, oppty.Amount, 0);
		}
		storeCustomerLoyaltyCalculatedValues(calcWrappers);
	}

	/*
	   @Description: calls all the methods necessary to process the customer loyalty values and updates them
	   @param1: the finished orders
	 */
	public void processCustomerOrderLoyaltyValues(List<Order> orders) {
		LoyaltyCalcWrappers calcWrappers = new LoyaltyCalcWrappers();
		Loyalty_Util_OrderItemDml orderItemDml = new Loyalty_Util_OrderItemDml();

		for (Order order : orders) {
			calcWrappers = processValuesForEachCustomer(calcWrappers, orderItemDml.getOrderItemsByOrderId(order.Id), order, 'Order', order.AccountId, order.TotalAmount, 0);
		}
		storeCustomerLoyaltyCalculatedValues(calcWrappers);
	}

	/*
	   @Description: deals with calculations for each customer program types
	   @param1: the already calculated values
	   @param2: set of product ID's related to the purchase
	   @param3: customer account ID
	   @param4: purchase amount value
	   @return: the updated calculated values object
	 */
	private LoyaltyCalcWrappers processValuesForEachCustomer(LoyaltyCalcWrappers calcWrappers, List<LoyaltyWrappers.LoyaltyProductItem> productsData, SObject purchaseData, string objectName, Id accountId, decimal purchaseAmount, integer customerTotalPurchases) {
		Loyalty_Util_LoyaltyProgramDml loyaltyProgramDml = new Loyalty_Util_LoyaltyProgramDml();
		Loyalty_Util_ProgramMemberDml programMemberDml = new Loyalty_Util_ProgramMemberDml();
		Set<String> memberProgramTypes = new Set<String>();
		try {
			memberProgramTypes = programMemberDml.getCustomerLoyaltyProgramTypesByAccountId(accountId);
			System.debug(memberProgramTypes);
		}
		catch(Exception ex) {
			System.debug(ex.getMessage());
		}
		for (String programType : memberProgramTypes) {
			switch on programType {
				When 'Card Program' {
					if (calcWrappers.gameCalcResults == null) {
						calcWrappers.gameCalcResults = new List<LoyaltyCalcWrappers.GameCalcResult>();
					}
					LoyaltyCalcWrappers.GameCalcResult result = this.programCalcs.calculateGameProgram(productsData, purchaseData, objectName, accountId, purchaseAmount);
				}
				When 'Hybrid Program' {
					if (calcWrappers.hybridCalcResults == null) {
						calcWrappers.hybridCalcResults = new List<LoyaltyCalcWrappers.HybridCalcResult>();
					}
					LoyaltyCalcWrappers.HybridCalcResult result = this.programCalcs.calculateHybridProgram(productsData, purchaseData, objectName, accountId, purchaseAmount);
				}
				When 'Paid Program' {
					if (calcWrappers.paidCalcResults == null) {
						calcWrappers.paidCalcResults = new List<LoyaltyCalcWrappers.PaidCalcResult>();
					}
					LoyaltyCalcWrappers.PaidCalcResult result = this.programCalcs.calculatePaidProgram(productsData, purchaseData, objectName, accountId, purchaseAmount);
				}
				When 'Partnered Program' {
					if (calcWrappers.partneredCalcResults == null) {
						calcWrappers.partneredCalcResults = new List<LoyaltyCalcWrappers.PartneredCalcResult>();
					}
					LoyaltyCalcWrappers.PartneredCalcResult result = this.programCalcs.calculatePartneredProgram(productsData, purchaseData, objectName, accountId, purchaseAmount);
				}
				When 'Point Program' {
					if (calcWrappers.pointCalcResults == null) {
						calcWrappers.pointCalcResults = new List<LoyaltyCalcWrappers.PointCalcResult>();
					}
					LoyaltyCalcWrappers.PointCalcResult result = this.programCalcs.calculatePointsProgram(productsData, purchaseData, objectName, accountId, purchaseAmount);
					calcWrappers.pointCalcResults = mergeDuplicatedPointsAccountByDates(calcWrappers.pointCalcResults, result);
				}
				When 'Spend Program' {
					if (calcWrappers.spendCalcResults == null) {
						calcWrappers.spendCalcResults = new List<LoyaltyCalcWrappers.SpendCalcResult>();
					}
					LoyaltyCalcWrappers.SpendCalcResult result = this.programCalcs.calculateSpendProgram(productsData, purchaseData, objectName, accountId, purchaseAmount);
					if (result != null) {
						calcWrappers.spendCalcResults = mergeDuplicatedSpendPointsAccountByDates(calcWrappers.spendCalcResults, result);
					}
				}
				When 'Tiered Program' {
					if (calcWrappers.tieredCalcResults == null) {
						calcWrappers.tieredCalcResults = new List<LoyaltyCalcWrappers.TieredCalcResult>();
					}
					LoyaltyCalcWrappers.TieredCalcResult result = this.programCalcs.calculateTieredProgram(productsData, purchaseData, objectName, accountId, purchaseAmount);
				}
				When 'Value Program' {
					if (calcWrappers.customerOwnValueCalcResults == null) {
						calcWrappers.customerOwnValueCalcResults = new List<LoyaltyCalcWrappers.CustomerOwnValueCalcResult>();
					}
					LoyaltyCalcWrappers.CustomerOwnValueCalcResult result = this.programCalcs.calculateCustomerOwnValuesBasedProgram(productsData, purchaseData, objectName, accountId, purchaseAmount);
				}
				When else {
					System.Debug('processCustomerOpptyLoyaltyValues - Program type logic not implemented: ' + programType);
				}
			}
		}
		return calcWrappers;
	}

	/*
	   @Description: checks which calculated values are to be stored
	   TODO joao almeida: create the insert/update methods missing
	   @param1: the calculated values object
	 */
	private void storeCustomerLoyaltyCalculatedValues(LoyaltyCalcWrappers calcWrappers) {
		if (calcWrappers.gameCalcResults != null && !calcWrappers.gameCalcResults.isEmpty()) {
		}
		if (calcWrappers.hybridCalcResults != null && !calcWrappers.hybridCalcResults.isEmpty()) {
		}
		if (calcWrappers.paidCalcResults != null && !calcWrappers.paidCalcResults.isEmpty()) {
		}
		if (calcWrappers.partneredCalcResults != null && !calcWrappers.partneredCalcResults.isEmpty()) {
		}
		if (calcWrappers.pointCalcResults != null && !calcWrappers.pointCalcResults.isEmpty()) {
			processCustomerLoyaltyPoints(calcWrappers.pointCalcResults);
		}
		if (calcWrappers.spendCalcResults != null && !calcWrappers.spendCalcResults.isEmpty()) {
			processCustomerLoyaltySpendProgram(calcWrappers.spendCalcResults);
		}
		if (calcWrappers.tieredCalcResults != null && !calcWrappers.tieredCalcResults.isEmpty()) {
		}
		if (calcWrappers.customerOwnValueCalcResults != null && !calcWrappers.customerOwnValueCalcResults.isEmpty()) {
		}
	}

	/*
	   @Description: deals with duplicated points calculation results
	   @param1: the already calculated points
	   @param2: the new calculation
	   @return: the final list of calculations
	 */
	private List<LoyaltyCalcWrappers.PointCalcResult> mergeDuplicatedPointsAccountByDates(List<LoyaltyCalcWrappers.PointCalcResult> pointCalcResults, LoyaltyCalcWrappers.PointCalcResult newCalc) {
		boolean toInsert = true;
		for (LoyaltyCalcWrappers.PointCalcResult currentResult : pointCalcResults) {
			if (currentResult.AccountId == newCalc.AccountId && currentResult.ExpireDate == newCalc.ExpireDate) {
				currentResult.Points += newCalc.Points;
				toInsert = false;
			}
		}
		if (toInsert) {
			pointCalcResults.add(newCalc);
		}
		return pointCalcResults;
	}

	/*
	   @Description: deals with duplicated spend points calculation results
	   @param1: the already calculated points
	   @param2: the new calculation
	   @return: the final list of calculations
	 */
	private List<LoyaltyCalcWrappers.SpendCalcResult> mergeDuplicatedSpendPointsAccountByDates(List<LoyaltyCalcWrappers.SpendCalcResult> spendCalcResults, LoyaltyCalcWrappers.SpendCalcResult newCalc) {
		boolean toInsert = true;
		for (LoyaltyCalcWrappers.SpendCalcResult currentResult : spendCalcResults) {
			if (currentResult.AccountId == newCalc.AccountId && currentResult.ExpireDate == newCalc.ExpireDate) {
				currentResult.SpendPoints += newCalc.SpendPoints;
				toInsert = false;
			}
		}
		if (toInsert) {
			spendCalcResults.add(newCalc);
		}
		return spendCalcResults;
	}

	/*
	   @Description: creates the objects with the customer loyalty points
	   @param1: the calculated points
	 */
	private void processCustomerLoyaltyPoints(List<LoyaltyCalcWrappers.PointCalcResult> pointCalcResults) {
		List<Loyalty_Value__c> values = new List<Loyalty_Value__c>();
		List<Loyalty_Member_Bonus__c> memberBonuses = new List<Loyalty_Member_Bonus__c>();
		Map<Id,Set<Date> > expireDates = new Map<Id,Set<Date> >();
		Loyalty_Util_LoyaltyValueDml loyaltyValueDml = new Loyalty_Util_LoyaltyValueDml();

		for (LoyaltyCalcWrappers.PointCalcResult calcResult : pointCalcResults) {
			long currentTimeStamp = datetime.now().getTime();

			Set<Date> currentAccount = expireDates.get(calcResult.AccountId);
			if (currentAccount != null) {
				currentAccount.add(calcResult.ExpireDate);
				expireDates.put(calcResult.AccountId,currentAccount);
			}
			else {
				expireDates.put(calcResult.AccountId,new Set<Date> {calcResult.ExpireDate});
			}

			Loyalty_Value__c loyaltyValue = new Loyalty_Value__c();
			loyaltyValue.Expiration_Date__c = calcResult.ExpireDate;
			loyaltyValue.Customer_Points__c = calcResult.Points;
			loyaltyValue.Customer_Spend_Points__c = 0;
			loyaltyValue.Program_Member__c = calcResult.MemberId;
			loyaltyValue.Name = calcResult.AccountId+currentTimeStamp;

			values.add(loyaltyValue);

			for (String bonusRuleId : calcResult.BonusRulesId) {
				Loyalty_Member_Bonus__c newMemberBonus = new Loyalty_Member_Bonus__c();
				newMemberBonus.Loyalty_Program_Setup_Rule__c = bonusRuleId;
				newMemberBonus.Bonus_Assigned_Date__c = calcResult.BonusesAssignedDate;
				newMemberBonus.Loyalty_Value__r = new Loyalty_Value__c(Name=calcResult.AccountId+currentTimeStamp);
				newMemberBonus.Account__c = calcResult.AccountId;

				memberBonuses.add(newMemberBonus);
			}
		}

		loyaltyValueDml.upsertCustomerLoyaltyPoints(values, memberBonuses, expireDates);
	}

	/*
	   @Description: creates the objects with the customer loyalty spend data
	   @param1: the calculated spend data
	 */
	private void processCustomerLoyaltySpendProgram(List<LoyaltyCalcWrappers.SpendCalcResult> spendCalcResults) {
		List<Loyalty_Value__c> values = new List<Loyalty_Value__c>();
		List<Loyalty_Member_Bonus__c> memberBonuses = new List<Loyalty_Member_Bonus__c>();
		List<Loyalty_Reward_Value__c> rewardValues = new List<Loyalty_Reward_Value__c>();
		List<Loyalty_Program_Member__c> customersNewLevel = new List<Loyalty_Program_Member__c>();
		Map<Id,Set<Date> > expireDates = new Map<Id,Set<Date> >();
		Loyalty_Util_LoyaltyValueDml loyaltyValueDml = new Loyalty_Util_LoyaltyValueDml();
		Loyalty_Util_ProgramMemberDml programMemberDml = new Loyalty_Util_ProgramMemberDml();
		Loyalty_Util_RewardValueDml loyaltyRewardValueDml = new Loyalty_Util_RewardValueDml();

		for (LoyaltyCalcWrappers.SpendCalcResult calcResult : spendCalcResults) {
			long currentTimeStamp = datetime.now().getTime();

			Set<Date> currentAccount = expireDates.get(calcResult.AccountId);
			if (currentAccount != null) {
				currentAccount.add(calcResult.ExpireDate);
				expireDates.put(calcResult.AccountId,currentAccount);
			}
			else {
				expireDates.put(calcResult.AccountId,new Set<Date> {calcResult.ExpireDate});
			}

			Loyalty_Value__c loyaltyValue = new Loyalty_Value__c();
			loyaltyValue.Expiration_Date__c = calcResult.ExpireDate;
			loyaltyValue.Customer_Points__c = 0;
			loyaltyValue.Customer_Spend_Points__c = calcResult.SpendPoints;
			loyaltyValue.Program_Member__c = calcResult.MemberId;
			loyaltyValue.Name = calcResult.AccountId+currentTimeStamp;

			values.add(loyaltyValue);

			for (String bonusRuleId : calcResult.BonusRulesId) {
				Loyalty_Member_Bonus__c newMemberBonus = new Loyalty_Member_Bonus__c();
				newMemberBonus.Loyalty_Program_Setup_Rule__c = bonusRuleId;
				newMemberBonus.Bonus_Assigned_Date__c = calcResult.BonusesAssignedDate;
				newMemberBonus.Loyalty_Value__r = new Loyalty_Value__c(Name=calcResult.AccountId+currentTimeStamp);
				newMemberBonus.Account__c = calcResult.AccountId;

				memberBonuses.add(newMemberBonus);
			}

			if (calcResult.NewLoyaltyLevelId != null && !String.isBlank(calcResult.NewLoyaltyLevelId)) {

				if (calcResult.LoyaltyRewardId != null && !String.isBlank(calcResult.LoyaltyRewardId)) {
					Loyalty_Reward_Value__c loyaltyRewardValue = new Loyalty_Reward_Value__c();
					loyaltyRewardValue.Name = 'Spend';
					loyaltyRewardValue.Loyalty_Reward__c = calcResult.LoyaltyRewardId;
					loyaltyRewardValue.Loyalty_Value__r = new Loyalty_Value__c(Name=calcResult.AccountId+currentTimeStamp);

					rewardValues.add(loyaltyRewardValue);
				}

				Loyalty_Program_Member__c toUpdateLevel = new Loyalty_Program_Member__c();
				toUpdateLevel.Id = calcResult.MemberId;
				toUpdateLevel.Loyalty_Level__c = calcResult.NewLoyaltyLevelId;

				customersNewLevel.add(toUpdateLevel);
			}
		}
		loyaltyValueDml.upsertCustomerLoyaltyPoints(values, memberBonuses, expireDates);
		programMemberDml.updateCustomerProgramMembers(customersNewLevel);
		loyaltyRewardValueDml.insertLoyaltyRewardValues(rewardValues);
	}
}