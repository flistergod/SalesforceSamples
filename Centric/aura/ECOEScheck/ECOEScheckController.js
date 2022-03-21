({

    doInit : function(component, event, helper) {
    
    //Setup the call to the Apex Controller and also pass one parameter
    
    var action = component.get("c.CallIPService");
    var idlist=[];
    idlist.push(component.get("v.recordId"));
    action.setParams({"IPname":"ECOES_ECOESMPAN" , "SPID": idlist});
    
    // Configure response handler
    
    action.setCallback(this, function(response) {
    
        var state = response.getState();
        
        // Prepare a toast UI message
        
        var resultsToast = $A.get("e.force:showToast");
        
        if(state === "SUCCESS") {
        
            resultsToast.setParams({
            
            "title": "ECOES fetch – Success",
            "type": "success",
            "message": "ECOES response received and Service point and Premise updated successfully.."
            
            });
        
        } 
        else if (state == "ERROR"){
        
            var errors = response.getError();
            
            if (errors) {
            
                if (errors[0] && errors[0].message) {
                
                    resultsToast.setParams({
                    
                    "title": "ECOES fetch - Error",
                    "type": "error",
                    "message": "ECOES response returned an error: " + errors[0].message
                    
                    });
                
                }
            
            } 
            else {
            
                resultsToast.setParams({
                
                "title": "ECOES fetch - Unknown Error",
                "type": "error",
                "message": "ECOES response or Service point/Premise update returned an error: " + state
                
                });
            
            }
        
        } 
        else {
        
            resultsToast.setParams({
            
            "title": "ECOES fetch - Unknown Error",
            "type": "error",
            "message": "ECOES response or Service point/Premise update returned an error: " + state
            
            });
        
        }
        
        resultsToast.fire();
        
        //This is the key to getting the page to refresh
        
        $A.get("e.force:refreshView").fire();
        
        //This closes the Action Window
        
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        
        dismissActionPanel.fire();
    
    });
    
    //This calls the Apex Controller and the code will restart on the setCallback line.
    
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