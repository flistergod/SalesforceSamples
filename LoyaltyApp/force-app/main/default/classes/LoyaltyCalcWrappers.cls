public class LoyaltyCalcWrappers {
    public class GameCalcResult {
        public string AccountId;
        public string BonusRuleId;
    }

    public class HybridCalcResult {
        public string AccountId;
        public string BonusRuleId;
    }

    public class PaidCalcResult {
        public string AccountId;
        public string BonusRuleId;
    }

    public class PartneredCalcResult {
        public string AccountId;
        public string BonusRuleId;
    }

    public class PointCalcResult {
        public integer Points;
        public Date ExpireDate;
        public string AccountId;
        public string MemberId;
        public List<string> BonusRulesId;
        public Date BonusesAssignedDate;
    }

    public class SpendCalcResult {
        public string AccountId;
        public List<string> BonusRulesId;
        public Date BonusesAssignedDate;
        public string MemberId;
        public string LoyaltyRewardId;
        public integer SpendPoints;
        public Date ExpireDate;
        public integer AccumulatedSpendPoints;
        public string NewLoyaltyLevelId;
        public string NewLoyaltyLevelName;
    }

    public class TieredCalcResult {
        public string AccountId;
        public string BonusRuleId;
    }

    public class CustomerOwnValueCalcResult {
        public string AccountId;
        public string BonusRuleId;
    }

    public List<GameCalcResult> gameCalcResults;
    public List<HybridCalcResult> hybridCalcResults;
    public List<PaidCalcResult> paidCalcResults;
    public List<PartneredCalcResult> partneredCalcResults;
    public List<PointCalcResult> pointCalcResults;
    public List<SpendCalcResult> spendCalcResults;
    public List<TieredCalcResult> tieredCalcResults;
    public List<CustomerOwnValueCalcResult> customerOwnValueCalcResults;
}