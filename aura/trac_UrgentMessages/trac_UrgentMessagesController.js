({
    getContents : function(component) {  
        var action = component.get("c.getUrgentMessages");

        var recordId = component.get('v.recordId');
        if (recordId) {
            action.setParams({
                "recordId": recordId
            });
        }

       action.setCallback(this, function(response) {
           var state = response.getState();
           if (state === "SUCCESS") {
               component.set("v.contents", response.getReturnValue());
           }
       });
       $A.enqueueAction(action);                
	}
})