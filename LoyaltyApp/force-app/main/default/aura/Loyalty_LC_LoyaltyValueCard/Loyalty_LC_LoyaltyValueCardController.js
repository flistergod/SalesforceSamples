({
    doInit : function(component, event, helper) {
        var accountId = component.get("v.recordId");
        if(accountId){
            helper.getCustomerLoyaltyValuesInfo(component,accountId);
        }
    },

    gotoLoyaltyValuesList : function (component, event, helper) {
        var relatedListEvent = $A.get("e.force:navigateToRelatedList");
        relatedListEvent.setParams({
            "relatedListId": "Loyalty_Values__r",
            "parentRecordId": component.get("v.recordId")
        });
        relatedListEvent.fire();
    }
})