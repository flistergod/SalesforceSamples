({
    getLoyaltyProgramSetupId : function(component, recordId){
        var action = component.get("c.getProgramSetupId");
        action.setParams({
            programId : recordId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var setupId = response.getReturnValue();
                component.set("v.loyaltyProgramSetupId", setupId);
              }
        });
        $A.enqueueAction(action);
    },
    
    getLoyaltyProgramSetupRecordTypeId : function(component, programId){
        var action = component.get("c.getProgramSetupRecordTypeId");
        action.setParams({
            programId : programId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                console.log(response.getReturnValue());
                var recordTypeId = response.getReturnValue().RecordTypeId;
                var setupId = response.getReturnValue().Id;
        		component.set("v.loyaltyProgramSetupRecordTypeId", recordTypeId);//"0122X000000VeONQA0"
                component.set("v.loyaltyProgramSetupId", setupId);
                console.log(recordTypeId);
              }
        });
        $A.enqueueAction(action);
    }
})