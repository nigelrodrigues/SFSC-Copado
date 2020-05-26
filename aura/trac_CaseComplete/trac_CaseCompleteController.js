/**
 * Created by Jeremy on 2/2/2020.
 */

({

    handleRecordUpdated: function(component, event, helper) {
        helper.getCaseRecordType(component, helper);
        helper.setCaseStatus(component, event, helper);
    },

    handleLoad: function (component, event, helper) {
        component.set("v.isSpinner", false);
        component.set("v.isLoading", false);
        console.log('v.recordLoadError: ' + component.get('v.recordLoadError'));


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

            helper.setCaseStatus(component, helper);
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

            helper.setCaseStatus(component, helper);
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