({
    doInit : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        if(recordId){
            helper.getLoyaltyProgramSetupId(component,recordId);
        }
    }
})