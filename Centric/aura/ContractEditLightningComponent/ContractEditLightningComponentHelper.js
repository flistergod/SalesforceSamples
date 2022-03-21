({
    getUserInfo : function(component, event, helper) {
        var action = component.get('c.getUserProfileData');
        action.setCallback(this, function(actionResult) {
            component.set('v.sysAdmin', actionResult.getReturnValue());
            console.log(component.get("v.sysAdmin"));
            
        });
		$A.enqueueAction(action);
    }
})