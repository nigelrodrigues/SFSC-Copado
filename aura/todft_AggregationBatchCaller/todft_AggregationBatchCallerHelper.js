({
    callAggregationBatch : function (component, event, helper) {
        var action = component.get("c.callAggregationBatch");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "Aggregation Process started successfully, you will get an email notification when batch is processed."
                    });
                    toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    }
});