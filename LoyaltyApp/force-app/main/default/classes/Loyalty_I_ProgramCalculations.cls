/*
   @Author: João Almeida
   @CreatedDate: 11/09/2020
   @Description: loyalty program calculations Interface to define each program calculation methods
 */
public interface Loyalty_I_ProgramCalculations {
  LoyaltyCalcWrappers.GameCalcResult calculateGameProgram(List<LoyaltyWrappers.LoyaltyProductItem> productsData, SObject purchaseData, string objectName, Id accountId, decimal totalPurchaseValue);
  LoyaltyCalcWrappers.HybridCalcResult calculateHybridProgram(List<LoyaltyWrappers.LoyaltyProductItem> productsData, SObject purchaseData, string objectName, Id accountId, decimal totalPurchaseValue);
  LoyaltyCalcWrappers.PaidCalcResult calculatePaidProgram(List<LoyaltyWrappers.LoyaltyProductItem> productsData, SObject purchaseData, string objectName, Id accountId, decimal totalPurchaseValue);
  LoyaltyCalcWrappers.PartneredCalcResult calculatePartneredProgram(List<LoyaltyWrappers.LoyaltyProductItem> productsData, SObject purchaseData, string objectName, Id accountId, decimal totalPurchaseValue);
  LoyaltyCalcWrappers.PointCalcResult calculatePointsProgram(List<LoyaltyWrappers.LoyaltyProductItem> productsData, SObject purchaseData, string objectName, Id accountId, decimal totalPurchaseValue);
  LoyaltyCalcWrappers.SpendCalcResult calculateSpendProgram(List<LoyaltyWrappers.LoyaltyProductItem> productsData, SObject purchaseData, string objectName, Id accountId, decimal totalPurchaseValue);
  LoyaltyCalcWrappers.TieredCalcResult calculateTieredProgram(List<LoyaltyWrappers.LoyaltyProductItem> productsData, SObject purchaseData, string objectName, Id accountId, decimal totalPurchaseValue);
  LoyaltyCalcWrappers.CustomerOwnValueCalcResult calculateCustomerOwnValuesBasedProgram(List<LoyaltyWrappers.LoyaltyProductItem> productsData, SObject purchaseData, string objectName, Id accountId, decimal totalPurchaseValue);
}