({
	doInit : function(component, event, helper) {
		var offerPackId = component.get("v.recordId");
        console.log('==>'+offerPackId);
        var action = component.get("c.insertAttachment");
		action.setParams({ OfferPackId : offerPackId });
		action.setCallback(this, function(response) {
        	var state = response.getState();
            if (state === "SUCCESS") {
                // Alert the user with the value returned 
                // from the server
                var retValue = response.getReturnValue();
                console.log("From server:");
                console.log(retValue);
                component.set("v.WRP",retValue);   
                // You would typically fire a event here to trigger 
                // client-side notification that the server-side 
                // action is complete
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        // $A.enqueueAction adds the server-side action to the queue.
		$A.enqueueAction(action);
    },
    
    // this function automatic call by aura:waiting event  
    showSpinner: function(component, event, helper) {
       // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
    },
    
    // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
     // make Spinner attribute to false for hide loading spinner    
       component.set("v.Spinner", false);
    }
})