/**
 * Created by ragrawal on 6/20/2019.
 */
({
    updateCase: function (component, event, helper) {
        component.find("Id_spinner").set("v.class" , 'slds-show');

        var action = component.get("c.updateCase");
        action.setParams({
            'con': component.get("v.con"),
            'caseId': component.get("v.recordId")
        });

        action.setCallback(this, function(response) {
            component.find("Id_spinner").set("v.class" , 'slds-hide');

            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(!$A.util.isEmpty(result)){
                    helper.minimizeSearch(component);
                    $A.get('e.force:refreshView').fire();
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
    },

    showToast: function(message, type, title) {
        var resultsToast = $A.get("e.force:showToast");
        resultsToast.setParams({
            "title": title,
            "message": message,
            "type" : type
        });
        resultsToast.fire();
    },
});