public class LoyaltyWrappers {
    public class CustomerLoyaltyValuesSummary {
        public integer Points;
        public Date NextExpiringPointsDate;
        public Date NextExpiringDiscountsDate;
        public integer ExpiringPoints;
        public integer ExpiredPoints;
        public integer UsedPoints;
        public integer SpendPoints;
        public decimal ExpiringDiscounts;
        public string CustomerName;
        public integer PurchasesQuantity;
        public string CustomerLoyaltyLevel;
    }

    public class LoyaltyProductItem {
        public Id ProductId;
        public string ProductName;
        public string ProductFamily;
        public boolean IsFromOpportunity;
        public Id OpportunityId;
        public Id OpportunityLineItemId;
        public boolean IsFromOrder;
        public Id OrderId;
        public Id OrderItemId;
        public decimal Quantity;
        public decimal UnitPrice;
        public decimal TotalPrice;
        public Id PricebookEntryId;
        public string PricebookEntryName;
    }

    public class LoyaltyProgramSetup {
        public Id ProgramSetupId;
        public Id ProgramId;
        public string ProgramName;
    }

    public class LoyaltyBonusCondition {
        public String objectName;
        public List<LoyaltyBonusRule> rules;
    }

    public class LoyaltyBonusRule {
        public integer groupId;
        public String innerGroupCondition;
        public List<LoyaltyRuleConfiguration> ruleConfiguration;
    }

    public class LoyaltyRuleConfiguration {
        public String fieldName;
        public String fieldValueType;
        public String fieldOperator;
        public String fieldValue;
    }
}