({
	doInit : function(component, event, helper) {
		helper.getUserInfo(component, event, helper);
	},
    
  handleSuccess : function(component, event, helper) {
    var recordId = component.get("{!v.recordId}");
    var navService = component.find("navService");

    var pageReference = {
        type: 'standard__recordPage',
        attributes: {
            "recordId": recordId,
            "objectApiName": "Contact",
            "actionName": "view"
        }
    }
    event.preventDefault(); 
    navService.navigate(pageReference);  
    }    
})