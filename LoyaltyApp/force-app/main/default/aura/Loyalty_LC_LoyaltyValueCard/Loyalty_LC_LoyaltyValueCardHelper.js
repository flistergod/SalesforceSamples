({
    getCustomerLoyaltyValuesInfo : function(component, accountId){
        var action = component.get("c.getCustomerLoyaltyInformation");
        action.setParams({
            accountId : accountId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                let summaryData = JSON.parse(response.getReturnValue());
                component.set("v.LoyaltyValuesSummary",summaryData);
            }
            else if (state === "INCOMPLETE") {
				// do something
			}
			else if (state === "ERROR") {
				var errors = response.getError();
				var evt = $A.get("e.c:LoyaltyGlobalEvent");
				evt.setParams({ "MethodName": "DealWithError"});
				evt.setParams({ "MethodParams": {param1: errors}});
				evt.fire();
			}
        });
        $A.enqueueAction(action);
    },
})