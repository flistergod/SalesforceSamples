({
    clickReimbursed: function(component, event, helper) {
        let expense = component.get("v.expense");
        let updateEvent = component.getEvent("updateExpense");
        updateEvent.setParams({ "expense": expense });
        updateEvent.fire();
    }
})