/*
   @Author: João Almeida
   @CreatedDate: 08/09/2020
   @Description: Contains the methods for each customer loyalty program type
 */
public class Loyalty_Util_ProgramCalculations implements Loyalty_I_ProgramCalculations {
	private class LoyaltyProgramCalculationsException extends Exception {}
	private Loyalty_Util_ProgramSetupDml programSetupDml;
	private Loyalty_Util_LoyaltyProgramDml programDml;

	public Loyalty_Util_ProgramCalculations() {
		this.programDml = new Loyalty_Util_LoyaltyProgramDml();
		this.programSetupDml = new Loyalty_Util_ProgramSetupDml();
	}

	/*
	   @Description: calculates the game program values, based on Loyalty Program Setup Rules
	       TODO joao almeida: build game program calculation logic
	   @param1: list of products related to the purchase
	   @param2: object related to the purchase (opportunity or order)
	   @param3: object name related to the purchase
	   @param4: account ID of the member
	   @param5: total value of the purchase
	   @Return: the game calculation results
	 */
	public LoyaltyCalcWrappers.GameCalcResult calculateGameProgram(List<LoyaltyWrappers.LoyaltyProductItem> productsData, SObject purchaseData, string objectName, Id accountId, decimal totalPurchaseValue) {
		LoyaltyCalcWrappers.GameCalcResult result = new LoyaltyCalcWrappers.GameCalcResult();

		return result;
	}

	/*
	   @Description: calculates the hybrid program values, based on Loyalty Program Setup Rules
	       TODO joao almeida: build hybrid program calculation logic
	   @param1: list of products related to the purchase
	   @param2: object related to the purchase (opportunity or order)
	   @param3: object name related to the purchase
	   @param4: account ID of the member
	   @param5: total value of the purchase
	   @Return: the hybrid calculation results
	 */
	public LoyaltyCalcWrappers.HybridCalcResult calculateHybridProgram(List<LoyaltyWrappers.LoyaltyProductItem> productsData, SObject purchaseData, string objectName, Id accountId, decimal totalPurchaseValue) {
		LoyaltyCalcWrappers.HybridCalcResult result = new LoyaltyCalcWrappers.HybridCalcResult();

		return result;
	}

	/*
	   @Description: calculates the paid program values, based on Loyalty Program Setup Rules
	       TODO joao almeida: build paid program calculation logic
	   @param1: list of products related to the purchase
	   @param2: object related to the purchase (opportunity or order)
	   @param3: object name related to the purchase
	   @param4: account ID of the member
	   @param5: total value of the purchase
	   @Return: the paid calculation results
	 */
	public LoyaltyCalcWrappers.PaidCalcResult calculatePaidProgram(List<LoyaltyWrappers.LoyaltyProductItem> productsData, SObject purchaseData, string objectName, Id accountId, decimal totalPurchaseValue) {
		LoyaltyCalcWrappers.PaidCalcResult result = new LoyaltyCalcWrappers.PaidCalcResult();

		return result;
	}

	/*
	   @Description: calculates the partnered program values, based on Loyalty Program Setup Rules
	       TODO joao almeida: build partnered program calculation logic
	   @param1: list of products related to the purchase
	   @param2: object related to the purchase (opportunity or order)
	   @param3: object name related to the purchase
	   @param4: account ID of the member
	   @param5: total value of the purchase
	   @Return: the partnered calculation results
	 */
	public LoyaltyCalcWrappers.PartneredCalcResult calculatePartneredProgram(List<LoyaltyWrappers.LoyaltyProductItem> productsData, SObject purchaseData, string objectName, Id accountId, decimal totalPurchaseValue) {
		LoyaltyCalcWrappers.PartneredCalcResult result = new LoyaltyCalcWrappers.PartneredCalcResult();

		return result;
	}

	/*
	   @Description: calculates the number of points for a specific purchase, based on Loyalty Program Setup Rules
	   	TODO joao almeida: change logic to comprehend the new program setup bonus rules
	   @param1: list of products related to the purchase
	   @param2: object related to the purchase (opportunity or order)
	   @param3: object name related to the purchase
	   @param4: account ID of the member
	   @param5: total value of the purchase
	   @Return: the points calculation result
	 */
	public LoyaltyCalcWrappers.PointCalcResult calculatePointsProgram(List<LoyaltyWrappers.LoyaltyProductItem> productsData, SObject purchaseData, string objectName, Id accountId, decimal totalPurchaseValue) {
		LoyaltyCalcWrappers.PointCalcResult result = new LoyaltyCalcWrappers.PointCalcResult();

        // LoyaltyWrappers.LoyaltyBonusCondition condition = (LoyaltyWrappers.LoyaltyBonusCondition)JSON.deserialize(newSetupRule.Object_Rules__c, LoyaltyWrappers.LoyaltyBonusCondition.class);
        // System.debug(condition.rules[1].rules);
		Loyalty_Program__c program = this.programDml.getLoyaltyProgramByType('Point Program');
		if (program != null) {
			system.debug(program.Id);
			Loyalty_Program_Setup__c programSetup = this.programSetupDml.getLoyaltyProgramSetupByProgramId(program.Id);
			if (programSetup != null) {
				result = calculatePurchaseLoyaltyValue(productsData, purchaseData, objectName, accountId, totalPurchaseValue, programSetup);
			}
		}

		return result;
	}

	/*
	   @Description: calculates the spend program values, based on Loyalty Program Setup Rules
	   	TODO joao almeida: change logic to comprehend the new program setup bonus rules
	   @param1: list of products related to the purchase
	   @param2: object related to the purchase (opportunity or order)
	   @param3: object name related to the purchase
	   @param4: account ID of the member
	   @param5: total value of the purchase
	   @Return: the spend calculation results
	 */
	public LoyaltyCalcWrappers.SpendCalcResult calculateSpendProgram(List<LoyaltyWrappers.LoyaltyProductItem> productsData, SObject purchaseData, string objectName, Id accountId, decimal totalPurchaseValue) {
		LoyaltyCalcWrappers.SpendCalcResult result = null;
		Loyalty_Program__c program = this.programDml.getLoyaltyProgramByType('Spend Program');
		if (program != null) {
			system.debug(program.Id);
			Loyalty_Program_Setup__c programSetup = this.programSetupDml.getLoyaltyProgramSetupByProgramId(program.Id);
			if (programSetup != null) {
				Loyalty_Util_ProgramMemberDml programMemberDml = new Loyalty_Util_ProgramMemberDml();
				Loyalty_Program_Member__c programMemberLevel = programMemberDml.getCurrentCustomerLoyaltyLevel(accountId, program.Id);
				result = calculateNewCustomerLoyaltyLevel(productsData, purchaseData, objectName, accountId, totalPurchaseValue, programSetup, programMemberLevel);
			}
		}

		return result;
	}

	/*
	   @Description: calculates the tiered program values, based on Loyalty Program Setup Rules
	       TODO joao almeida: build tiered program calculation logic
	   @param1: list of products related to the purchase
	   @param2: object related to the purchase (opportunity or order)
	   @param3: object name related to the purchase
	   @param4: account ID of the member
	   @param5: total value of the purchase
	   @Return: the tiered calculation results
	 */
	public LoyaltyCalcWrappers.TieredCalcResult calculateTieredProgram(List<LoyaltyWrappers.LoyaltyProductItem> productsData, SObject purchaseData, string objectName, Id accountId, decimal totalPurchaseValue) {
		LoyaltyCalcWrappers.TieredCalcResult result = new LoyaltyCalcWrappers.TieredCalcResult();

		return result;
	}

	/*
	   @Description: calculates the customer own values program values, based on Loyalty Program Setup Rules
	       TODO joao almeida: build customer own values program calculation logic
	   @param1: list of products related to the purchase
	   @param2: object related to the purchase (opportunity or order)
	   @param3: object name related to the purchase
	   @param4: account ID of the member
	   @param5: total value of the purchase
	   @Return: the customer own values calculation results
	 */
	public LoyaltyCalcWrappers.CustomerOwnValueCalcResult calculateCustomerOwnValuesBasedProgram(List<LoyaltyWrappers.LoyaltyProductItem> productsData, SObject purchaseData, string objectName, Id accountId, decimal totalPurchaseValue) {
		LoyaltyCalcWrappers.CustomerOwnValueCalcResult result = new LoyaltyCalcWrappers.CustomerOwnValueCalcResult();

		return result;
	}

	private List<Loyalty_Program_Setup_Rules__c> getProgramSetupBonusRules(Id programSetupId) {
		Loyalty_Util_ProgramSetupRuleDml programSetupRulesDml = new Loyalty_Util_ProgramSetupRuleDml();
		List<Loyalty_Program_Setup_Rules__c> bonusRules = programSetupRulesDml.getProgramSetupRulesByProgramSetupId(programSetupId, true);

		return bonusRules;
	}

	/*
	   @Description: filters the object with the conditions defined
	   @param1: object related to the purchase
	   @param2: object name related to the purchase
	   @param3: the list of conditions
	   @Return: the filtered array of objects
	 */
	private List<SObject> filterPurchaseObjectByBonusRules(SObject purchaseData, string objectName, List<LoyaltyWrappers.LoyaltyBonusRule> conditionRules) {
		List<SObject> arrayPurchaseData = null;
		if (objectName == 'Opportunity') {
			arrayPurchaseData = new List<Opportunity>();
			arrayPurchaseData.add((Opportunity)purchaseData);
		}
		else if (objectName == 'Order') {
			arrayPurchaseData = new List<Order>();
			arrayPurchaseData.add((Order)purchaseData);
		}
		System.debug(conditionRules);
		for (LoyaltyWrappers.LoyaltyBonusRule config : conditionRules) {
			List<Loyalty_Util_ArrayFilter.Filter> filters = new List<Loyalty_Util_ArrayFilter.Filter>();
			for (LoyaltyWrappers.LoyaltyRuleConfiguration ruleConfig : config.ruleConfiguration) {
				filters.add(new Loyalty_Util_ArrayFilter.Filter(ruleConfig.fieldName, ruleConfig.fieldOperator,ruleConfig.fieldValue, ruleConfig.fieldValueType));
			}
			arrayPurchaseData = Loyalty_Util_ArrayFilter.filter(arrayPurchaseData, filters, config.innerGroupCondition);
		}
		return arrayPurchaseData;
	}

	/*
	   @Description: evaluates if the customer has access to the bonus by the behavior rules defined
	   @param1: behavior by counting of times he received the bonus
	   @param2: behaviour factor by months that have to pass by between the last time he received a bonus
	   @param3: account id
	   @param4: bonus rule id
	   @Return: true if he can have the bonus, false otherwise
	 */
	private Boolean evaluateCustomerBehaviour(Decimal behaviourCount, Decimal behaviourFactor, Id accountId, Id bonusRuleId) {
		Boolean customerCanWin = false;
		Loyalty_Util_MemberBonusDml memberBonusDml = new Loyalty_Util_MemberBonusDml();
		List<Loyalty_Member_Bonus__c> memberBonuses = memberBonusDml.getLoyaltyMemberBonusByAccountAndBonusRule(accountId, bonusRuleId);
		if (behaviourFactor != null && behaviourFactor != 0) {
			// the factor is by months
			integer subtractMonths = (integer)behaviourFactor * (-1);
			Date factorDate = system.today().addMonths(subtractMonths);
			integer countOfBonusesAssigned = 0;
			for (Loyalty_Member_Bonus__c bonus : memberBonuses) {
				if (bonus.Bonus_Assigned_Date__c != null && bonus.Bonus_Assigned_Date__c > factorDate) {
					countOfBonusesAssigned++;
				}
			}
			if (countOfBonusesAssigned < behaviourCount) {
				customerCanWin = true;
			}
		}
		else {
			if (memberBonuses.size() < behaviourCount) {
				customerCanWin = true;
			}
		}
		return customerCanWin;
	}

	/*
	   @Description: calculates the customer points based on the bonus factor definitions
	   @param1: list of products related to the purchase
	   @param2: object related to the purchase (opportunity or order)
	   @param3: object name related to the purchase
	   @param4: account id
	   @param5: total value of the purchase
	   @param6: the bonus rule record
	   @Return: the bonus points calculated
	 */
	private decimal calculateBonusPoints(List<LoyaltyWrappers.LoyaltyProductItem> productsData, SObject purchaseData, string objectName, Id accountId, decimal totalPurchaseValue, Loyalty_Program_Setup_Rules__c rule) {
		decimal bonusPoints = 0;

		if (rule.Assign_Points_Factor__c != null && rule.Assign_Points_Factor__c > 0) {
			Loyalty_Util_ArrayFilter.Filter filter = null;
			if (rule.Assign_Points_Field_Value_Name__c != null) {
				List<String> splittedFieldNameType = rule.Assign_Points_Field_Value_Name__c.split('|');
				filter = new Loyalty_Util_ArrayFilter.Filter(splittedFieldNameType[0],rule.Assign_Points_Factor_Operator__c,''+rule.Assign_Points_Factor__c,splittedFieldNameType[1]);
			}
			else if (rule.Assign_Points_Factor_Type_Value__c != null) {
				Decimal factorTypeValue = 0;
				if (rule.Assign_Points_Factor_Type__c == 'Number of Purchases') {
					Loyalty_Util_OrderDml orderDml = new Loyalty_Util_OrderDml();
					Loyalty_Util_AccountDml accountDml = new Loyalty_Util_AccountDml();
					
					Account accountData = accountDml.getAccountDataByAccountId(accountId);
					if (accountData != null) {
						factorTypeValue = accountData.Loyalty_Opportunity_Total_of_Purchases__c != null ? (integer)accountData.Loyalty_Opportunity_Total_of_Purchases__c : 0;
					}
					factorTypeValue += orderDml.getCountOrdersByAccountId(accountData.Id, true, 'Activated');
				}
				else {
					factorTypeValue = productsData.size();
				}
				filter = new Loyalty_Util_ArrayFilter.Filter(factorTypeValue,rule.Assign_Points_Factor_Operator__c,rule.Assign_Points_Factor_Type_Value__c);

			}
			if (filter != null) {
				Object result = Loyalty_Util_ArrayFilter.Calculate(purchaseData, filter);
				try {
					if ((Boolean)result == true) {
						bonusPoints += rule.Assign_Points_Factor__c;
					}
				}
				catch(Exception ex) {
					bonusPoints += (integer)((Decimal)result * rule.Assign_Points_Factor__c);
				}
			}
		}
		else {
			bonusPoints += rule.Assign_Points__c;
		}

		return bonusPoints;
	}

	/*
	   @Description: calculates the customer points for a new purchase
	   @param1: list of products related to the purchase
	   @param2: object related to the purchase (opportunity or order)
	   @param3: object name related to the purchase
	   @param4: account ID of the member
	   @param5: total value of the purchase
	   @param6: the program setup record
	   @Return: the purchase points calculation results
	 */
	private LoyaltyCalcWrappers.PointCalcResult calculatePurchaseLoyaltyValue(List<LoyaltyWrappers.LoyaltyProductItem> productsData, SObject purchaseData, string objectName, Id accountId, decimal totalPurchaseValue, Loyalty_Program_Setup__c programSetup) {
		LoyaltyCalcWrappers.PointCalcResult result = new LoyaltyCalcWrappers.PointCalcResult();
		result.BonusRulesId = new List<String>();
		
		List<Loyalty_Program_Setup_Rules__c> bonusRules = this.getProgramSetupBonusRules(programSetup.Id);
		System.debug(bonusRules);
		decimal bonusPoints = 0;
		for (Loyalty_Program_Setup_Rules__c rule : bonusRules) {
			Boolean customerCanWin = true;
			if(rule.Customer_Behaviour_Count__c != null) {
				customerCanWin = this.evaluateCustomerBehaviour(rule.Customer_Behaviour_Count__c, rule.Customer_Behaviour_Factor__c, accountId, rule.Id);
			}
			if (customerCanWin) {
				LoyaltyWrappers.LoyaltyBonusCondition condition = (LoyaltyWrappers.LoyaltyBonusCondition)JSON.deserialize(rule.Object_Rules__c, LoyaltyWrappers.LoyaltyBonusCondition.class);
				if (condition.objectName == objectName) {
					List<SObject> arrayPurchaseData = filterPurchaseObjectByBonusRules(purchaseData, objectName, condition.rules);
					System.debug(arrayPurchaseData);
					if (arrayPurchaseData != null && !arrayPurchaseData.isEmpty()) {
						result.BonusRulesId.add(rule.Id);
						bonusPoints += this.calculateBonusPoints(productsData, purchaseData, objectName, accountId, totalPurchaseValue, rule);
					}
				}
			}
		}
		System.debug('bonus points: ');
		System.debug(bonusPoints);
		if (bonusPoints > 0) {
			result.Points = (integer)bonusPoints;
			result.ExpireDate = system.today().addDays((integer)programSetup.Points_Validity_Days__c);
			result.AccountId = accountId;
			result.BonusesAssignedDate = system.today();
		}
		else {
			result.Points = 0;
		}
		return result;
	}

    /*
	   @Description: determines if the customer reached a new loyalty level
	   @param1: list of products related to the purchase
	   @param2: object related to the purchase (opportunity or order)
	   @param3: object name related to the purchase
	   @param4: account ID of the member
	   @param5: total value of the purchase
	   @param6: the program setup record
	   @param7: the program member record with related loyalty level record if it exists
	   @Return: the calculated spend program data
	 */
	private LoyaltyCalcWrappers.SpendCalcResult calculateNewCustomerLoyaltyLevel(List<LoyaltyWrappers.LoyaltyProductItem> productsData, SObject purchaseData, string objectName, Id accountId, decimal totalPurchaseValue, Loyalty_Program_Setup__c programSetup, Loyalty_Program_Member__c currentProgramMemberLevel) {
		LoyaltyCalcWrappers.SpendCalcResult spendResult = null;
		Loyalty_Util_LoyaltyValueDml loyaltyMemberValueDml = new Loyalty_Util_LoyaltyValueDml();
        LoyaltyWrappers.CustomerLoyaltyValuesSummary loyaltyValuesSummary = null;
        LoyaltyCalcWrappers.PointCalcResult currentPurchasePoints = null;
        integer newTotalSpendPoints = 0;
		integer numBoughtItems = calculateTotalBoughtItems(currentProgramMemberLevel, productsData);
		integer numPurchases = calculateNumberPurchases(currentProgramMemberLevel);
        try {
            loyaltyValuesSummary = loyaltyMemberValueDml.getLoyaltyMemberValues(accountId);
			currentPurchasePoints = calculatePurchaseLoyaltyValue(productsData, purchaseData, objectName, accountId, totalPurchaseValue, programSetup);
			newTotalSpendPoints = (loyaltyValuesSummary != null ? loyaltyValuesSummary.SpendPoints : 0) + currentPurchasePoints.Points;
        }
        catch(Exception ex) {

        }

		Loyalty_I_ManageLevels manageLoyaltyLevels = new Loyalty_Util_ManageLevels();
        Loyalty_Program_Setup_Level__c nextLevelReached = manageLoyaltyLevels.calculateNewCustomerLoyaltyLevel(newTotalSpendPoints, numBoughtItems, numPurchases, accountId, programSetup, currentProgramMemberLevel);
		// for (Loyalty_Program_Setup_Level__c setupLevel : programSetupLevels) {
		// 	boolean boughtItemsAchieved = true;
		// 	boolean pointsAchieved = true;
        //     boolean numPurchasesAchieved = true;
        //     System.debug(newTotalSpendPoints + ' achievable points: ' + setupLevel.Achievable_Points__c);
        //     System.debug(numBoughtItems + ' achievable bought items: ' + setupLevel.Achievable_Bought_Items__c);
        //     System.debug(numPurchases + ' achievable purchases: ' + setupLevel.Achievable_Purchases__c);
		// 	if (setupLevel.Is_Bought_Items_Mandatory__c) {
		// 		if (numBoughtItems < setupLevel.Achievable_Bought_Items__c
		// 			|| (nextLevelReached != null && nextLevelReached.Is_Bought_Items_Mandatory__c && nextLevelReached.Achievable_Bought_Items__c > setupLevel.Achievable_Bought_Items__c)
		// 			) {
		// 			boughtItemsAchieved = false;
		// 		}
		// 	}
		// 	if (setupLevel.Is_Points_Manadatory__c) {
		// 		if (newTotalSpendPoints < setupLevel.Achievable_Points__c
		// 			|| (nextLevelReached != null && nextLevelReached.Is_Points_Manadatory__c && nextLevelReached.Achievable_Points__c > setupLevel.Achievable_Points__c)
		// 			) {
		// 			pointsAchieved = false;
		// 		}
		// 	}
		// 	if (setupLevel.Is_Purchases_Mandatory__c) {
		// 		if (numPurchases < setupLevel.Achievable_Purchases__c
		// 			|| (nextLevelReached != null && nextLevelReached.Is_Purchases_Mandatory__c && nextLevelReached.Achievable_Purchases__c > setupLevel.Achievable_Purchases__c)
		// 			) {
		// 			numPurchasesAchieved = false;
		// 		}
		// 	}
		// 	System.debug(boughtItemsAchieved);
		// 	System.debug(pointsAchieved);
		// 	System.debug(numPurchasesAchieved);
		// 	System.debug(numPurchases);
		// 	if (boughtItemsAchieved && pointsAchieved && numPurchasesAchieved) {
		// 		nextLevelReached = setupLevel;
		// 	}
		// }
		// System.debug('levelreached: ');
		// System.debug(nextLevelReached);
		spendResult = new LoyaltyCalcWrappers.SpendCalcResult();
		spendResult.AccountId = accountId;
		spendResult.MemberId = currentProgramMemberLevel.Id;
		spendResult.SpendPoints = currentPurchasePoints.Points;
		spendResult.ExpireDate = currentPurchasePoints.ExpireDate;
		spendResult.BonusRulesId = currentPurchasePoints.BonusRulesId;
		spendResult.BonusesAssignedDate = currentPurchasePoints.BonusesAssignedDate;
		spendResult.AccumulatedSpendPoints = newTotalSpendPoints;
		if (nextLevelReached != null && (currentProgramMemberLevel.Loyalty_Level__c == null || nextLevelReached.Loyalty_Level__c != currentProgramMemberLevel.Loyalty_Level__r.Id)) {
			spendResult.LoyaltyRewardId = nextLevelReached.Loyalty_Reward_Achievable__c;
			spendResult.NewLoyaltyLevelId = nextLevelReached.Loyalty_Level__c;
			spendResult.NewLoyaltyLevelName = nextLevelReached.Loyalty_Level__r.Name;
		}
		System.debug('spend calc results: ');
		System.debug(spendResult);
		return spendResult;
	}

	/*
	   @Description: calculates the quantity of bought items in the purchase
	   @param1: list of products related to the purchase
	   @Return: the total quantity of bought items
	 */
	private integer calculateTotalBoughtItems(Loyalty_Program_Member__c currentMemberLevel, List<LoyaltyWrappers.LoyaltyProductItem> productsData) {
		integer total = 0;

		
		if (currentMemberLevel != null) {
			// +1 is the current purchase
		   total = currentMemberLevel.Member__r.Loyalty_Oppty_Bought_Items_Quantity__c != null ? (integer)currentMemberLevel.Member__r.Loyalty_Oppty_Bought_Items_Quantity__c : 0;
	   	}
		if (productsData != null) {
			for (LoyaltyWrappers.LoyaltyProductItem product : productsData) {
				total += product.Quantity != null ? (integer)product.Quantity : 0;
			}
		}
		return total;
	}

	/*
	   @Description: calculates the total of purchases made by the customer
	   @param1: current Member data
	   @Return: the total quantity of purchases
	 */
	private integer calculateNumberPurchases(Loyalty_Program_Member__c currentMemberLevel) {
		integer total = 0;
		Loyalty_Util_OrderDml orderDml = new Loyalty_Util_OrderDml();

		if (currentMemberLevel != null) {
			 // +1 is the current purchase
			total = currentMemberLevel.Member__r.Loyalty_Opportunity_Total_of_Purchases__c != null ? (integer)currentMemberLevel.Member__r.Loyalty_Opportunity_Total_of_Purchases__c + 1 : 1;
		}
		total += orderDml.getCountOrdersByAccountId(currentMemberLevel.Member__c, true, 'Activated');

		return total;
	}
}