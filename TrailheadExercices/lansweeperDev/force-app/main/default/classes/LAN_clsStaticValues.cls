public with sharing class LAN_clsStaticValues {
    public static final String OPPORTUNITY_RT_DEVELOPERNAME_PARENT = 'LAN_Parent_Opportunity';
    public static final Id OPPORTUNITY_RT_ID_PARENT = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(OPPORTUNITY_RT_DEVELOPERNAME_PARENT).getRecordTypeId();
    public static final String OPPORTUNITY_RT_DEVELOPERNAME_NEWLOGO = 'LAN_New_Logo';
    public static final Id OPPORTUNITY_RT_ID_NEWLOGO = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(OPPORTUNITY_RT_DEVELOPERNAME_NEWLOGO).getRecordTypeId();
    public static final List<String> lstDiscountFields = new List<String>{
        'SBQQ__TotalCustomerDiscountAmount__c', 'SBQQ__AdditionalDiscountAmount__c',
        'LAN_AppliedPerpetualAccountDiscount_f__c', 'LAN_AppliedSalesChanDiscount_FirstYear__c'
    };
}