/**
 * Created by Jeremy on 2/2/2020.
 */

({

    handleRecordUpdated: function(component, event, helper) {
        helper.getCaseRecordType(component, helper);
    },

    handleLoad: function (component, event, helper) {
        component.set("v.isSpinner", false);
        component.set("v.isLoading", false);

    },

    handleSubmit: function (component, event, helper) {
        component.set("v.isSpinner", true);
        component.set("v.isLoading", true);
    },

    handleError: function (component, event, helper) {
        component.set("v.isSpinner", false);
        component.set("v.isLoading", false);
    },

    handleRadioChange: function (component, event, helper) {
        const step = event.getSource().get("v.value");
        if (step === "Close Case") {
            component.set("v.isClose", true);
            component.set("v.isFollowUp", false);
            component.find("caseStatus").set("v.value", "Closed");

            helper.setCriteriaBasedStatus(component, helper);
        }
        if (step === "Follow Up") {
            component.set("v.isClose", false);
            component.set("v.isFollowUp", true);
            component.find("caseFollowUpDate").set("v.value", helper.getFollowUpDate());
            component.find("caseFollowUpRequestedBy").set("v.value", $A.get("$SObjectType.CurrentUser.Id"));
            component.find("caseStatus").set("v.value", "Follow Up");
        }
        if (step === "Change Status") {
            component.set("v.isClose", false);
            component.set("v.isFollowUp", false);

            helper.setCriteriaBasedStatus(component, helper);
        }
    },

    handleSuccess: function (component, event, helper) {
        component.set("v.isSpinner", false);
        component.set("v.isLoading", false);

        const workspaceAPI = component.find("workspace");
        workspaceAPI.getEnclosingTabId().then(function (tabId) {
            workspaceAPI.closeTab({tabId});
        })
            .catch(function (error) {
                console.log(error);
            });
    }
});