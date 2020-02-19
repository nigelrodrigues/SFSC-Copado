/**
 * Created by ragrawal on 6/20/2019.
 */
({
    updateCase: function (component, event, helper) {
        var action = component.get("c.updateCase");
        action.setParams({
            'con': component.get("v.con"),
            'caseId': component.get("v.recordId")
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(!$A.util.isEmpty(result)){
                    helper.minimizeSearch(component);
                    window.location.reload();
                    //$A.get('e.force:refreshView').fire();
                }

            }else if (state === "INCOMPLETE") {
                alert('Response is Incompleted');
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert("Error message: " +
                            errors[0].message);
                    }
                } else {
                    alert("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },

    minimizeSearch: function (component) {
        var cmpEvent = component.getEvent("closeModalEvent");
        cmpEvent.setParams({"closeModal" : false});
        cmpEvent.fire();
    }
})