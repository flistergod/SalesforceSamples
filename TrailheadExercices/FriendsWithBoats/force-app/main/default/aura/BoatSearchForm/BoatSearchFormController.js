({
    doInit : function(component, event, helper) {
        //Get the boat Types
        helper.LoadBoatTypes(component,event);
        var seb=component.get("v.selectedBoatType");
        console.log("Seleted boat in doint :"+seb);
        var isEnabled=$A.get("e.force:createRecord");
        if(isEnabled){
            component.set("v.isNewButtonAvailable",true);
        }
    },
   
    onboatTypechange :function(component, event, helper) {
       
        component.set("v.selectedBoatType", component.find("boatTypes").get("v.value"));
        let action = component.get("c.getBoatType");
       // console.log(JSON.stringify(action));
       
	
    
        action.setCallback(this, function(response){
			let state = response.getState();
			console.log(state);
            if (state === "SUCCESS") {
				
				
					console.log('u did it');
				  
				  cmp.set("v.fileData", "");
            }else{console.log('u didnt it');}
        });
        $A.enqueueAction(action);


       
    }, 
    createBoat: function(component,event){
       
        var boatTypeId=component.get("v.selectedBoatType");
        var createRecordEvent=$A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName":"Boat__c",
            "defaultFieldValues": {'BoatType__c': boatTypeId}
        });
        console.log("boatTypeId"+boatTypeId);
        createRecordEvent.fire();
    },
   
    onFormSubmit : function(component,event) {
        var boatTypeId = component.find("boatTypes").get("v.value");
        var data = {
            "boatTypeId" : boatTypeId
        };
       
        var formsubmit = component.getEvent("formsubmit");
        formsubmit.setParams({
            "formData" :data
        });
       
        formsubmit.fire();
    },
})