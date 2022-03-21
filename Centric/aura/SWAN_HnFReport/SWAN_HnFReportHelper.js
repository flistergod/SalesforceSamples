({
	getReportList: function(component,helper) 
    {
        var action = component.get('c.getReportData');
        var self = this;
        action.setParams({
            fromDate : component.get("v.fromDate")
        });
        action.setCallback(this, function(actionResult) {
            component.set('v.reportList', actionResult.getReturnValue());
            helper.buildData(component,helper);
        });
		$A.enqueueAction(action);
	},
    getUserProfileInfo: function(component){
        var action = component.get('c.getUserProfileInfo');
         action.setCallback(this, function(actionResult) {
            component.set('v.sysAdmin', actionResult.getReturnValue());
        });
		$A.enqueueAction(action);
    },
    runATLASReport: function(component) 
    {
        var action = component.get('c.runATLASReport');
        var self = this;
        action.setCallback(this, function(actionResult) {
            $A.get('e.force:refreshView').fire();
            
        });
		$A.enqueueAction(action);
	},
	
	/*
     * this function will build table data
     * based on current page selection
     * */
    buildData : function(component, helper) {
        var data = [];
        var pageNumber = component.get("v.currentPageNumber");
        var pageSize = component.get("v.pageSize");
        var allData = component.get("v.reportList");
        var x = (pageNumber-1)*pageSize;
        
        //creating data-table data
        for(; x<(pageNumber)*pageSize; x++){
			console.log(x);
            if(allData!=null && allData[x]){
            	data.push(allData[x]);
            }
        }
        component.set("v.data", data);
        
        helper.generatePageList(component, pageNumber);
    },
    
    /*
     * this function generate page list
     * */
    generatePageList : function(component, pageNumber){
        pageNumber = parseInt(pageNumber);
        console.log(pageNumber);
        var pageList = [];
        var pageSize = parseInt(component.get("v.pageSize"));
        var allDataLength = (component.get("v.reportList")!=null?parseInt(component.get("v.reportList").length):0);
        var totalPages = Math.ceil(allDataLength/pageSize);
        component.set("v.totalPages",totalPages);
        if(totalPages > 1){
            if(totalPages <= 10){
                var counter = 2;
                for(; counter < (totalPages); counter++){
                    pageList.push(counter);
                } 
            } else{
                if(pageNumber < 5){
                    pageList.push(2, 3, 4, 5, 6);
                } else{
                    if(pageNumber>(totalPages-5)){
                        pageList.push(totalPages-5, totalPages-4, totalPages-3, totalPages-2, totalPages-1);
                    } else{
                        pageList.push(pageNumber-2, pageNumber-1, pageNumber, pageNumber+1, pageNumber+2);
                    }
                }
            }
        }
        component.set("v.pageList", pageList);
    },
})