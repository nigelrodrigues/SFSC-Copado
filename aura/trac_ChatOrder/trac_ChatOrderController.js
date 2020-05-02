/**
 * Created by Jeremy on 2/2/2020.
 */

({
    doInit : function (component, event, helper) {
        var apexAction = component.get("c.getCaseId");

        var recordId = component.get('v.recordId');

        apexAction.setParams({
            "liveChatTranscriptId": recordId,
        });

        apexAction.setCallback(this, function(response) {
            var state = response.getState();

            if (component.isValid() && state === "SUCCESS") {
                var result =  response.getReturnValue();

                if (result == null) {
                    component.set("v.errorMsg", "Connection Error");
                } else {
                    if(result.isSuccess) {
                        component.set("v.caseId", result.returnValuesMap['caseId']);
                    } else {
                        component.set("v.isError", true);
                        component.set("v.errorMsg", result.message);
                    }
                }
            } else {
                console.log("failed with state: " + state);
            }

            component.set("v.isLoading", false);
        });

        $A.enqueueAction(apexAction);
    }
});