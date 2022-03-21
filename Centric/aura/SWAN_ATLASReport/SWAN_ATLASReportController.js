({
    doInit: function(component, event, helper) {
        component.set('v.columns', [
            {label: 'Name', fieldName: 'name', type: 'text'},
            {label: 'Created Date', fieldName: 'CreatedDate', type: 'date',typeAttributes: {  
                                                                            day: 'numeric',  
                                                                            month: 'short',  
                                                                            year: 'numeric',  
                                                                            hour: '2-digit',  
                                                                            minute: '2-digit',  
                                                                            second: '2-digit',  
                                                                            hour12: true}},
            {label: 'Download File Link', fieldName: 'downloadLink', type: 'url', typeAttributes: { target: '_blank',label:'Download'}}
        ]);
		
        helper.getReportList(component,helper);
        var today = new Date();
        var frmDate = component.get("v.fromDate");
        console.log('v.fromDate='+component.get("v.fromDate"));
        if(frmDate == null)
		component.set("v.fromDate", today.getFullYear() + "-" + (today.getMonth() + 1) + "-" + today.getDate());
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.setTabLabel({
                tabId: focusedTabId,
                label: "ATLAS Report" //set label you want to set
            });
            workspaceAPI.setTabIcon({
                tabId: focusedTabId,
                icon: "utility:record", //set icon you want to set
                iconAlt: "ATLAS Report" //set label tooltip you want to set
            });
        })
        
    },
    runReport: function(component, event, helper) {
        helper.runATLASReport(component);
    },
    onNext : function(component, event, helper) {        
        var pageNumber = component.get("v.currentPageNumber");
        component.set("v.currentPageNumber", pageNumber+1);
        helper.buildData(component, helper);
    },
    
    onPrev : function(component, event, helper) {        
        var pageNumber = component.get("v.currentPageNumber");
        component.set("v.currentPageNumber", pageNumber-1);
        helper.buildData(component, helper);
    },
    
    processMe : function(component, event, helper) {
        component.set("v.currentPageNumber", parseInt(event.target.name));
        helper.buildData(component, helper);
    },
    
    onFirst : function(component, event, helper) {        
        component.set("v.currentPageNumber", 1);
        helper.buildData(component, helper);
    },
    
    onLast : function(component, event, helper) {        
        component.set("v.currentPageNumber", component.get("v.totalPages"));
        helper.buildData(component, helper);
    },
})