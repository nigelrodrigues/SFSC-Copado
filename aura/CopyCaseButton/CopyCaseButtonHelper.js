/**
 * @description Helper for the Client side controller for the CopyCaseButton component
 * @author      Rajat Agrawal, Traction on Demand
 * @date        2019-06-06
 */
({/**
     * @description         Clone the current Case record
     * @author              Rajat Agrawal, Traction on Demand
     * @param component     Component reference
     * @param event         Event reference
     * @param helper        Helper reference
     */
    cloneCase: function (component, event, helper) {
        component.set("v.isLoading", true);
        var action = component.get("c.cloneCase");
        var caseRecord = component.get("v.caseRecord");

        action.setParams({
            "cs": caseRecord
        });

        action.setCallback(this, function (response) {
            var state = response.getState();

            if (component.isValid() && state === "SUCCESS") {
                var returnVal = response.getReturnValue();
                component.set("v.isLoading", false);
                $A.get("e.force:closeQuickAction").fire();
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": returnVal
                });
                navEvt.fire();
                $A.get('e.force:refreshView').fire();
            }
            else {
                component.set("v.isLoading", false);
                $A.get("e.force:closeQuickAction").fire();
                var message = action.getError()[0].message;
                helper.showToast(message, "error", 'Error');
            }
        });

        $A.enqueueAction(action);
    },

    /**
     * @description         Show toast with the given message, type, and title
     * @author              Rajat Agrawal, Traction on Demand
     * @param message       Message to display
     * @param type          Type of toast to display
     * @param title         Title of Toast message
     */
    showToast : function(message, type, title) {
        var resultsToast = $A.get("e.force:showToast");
        resultsToast.setParams({
            "title": title,
            "message": message,
            "type" : type
        });
        resultsToast.fire();
    },
})