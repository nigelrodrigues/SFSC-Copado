/**
 * Created by nrodrigues on 6/10/2020.
 */

({
    displayPopup : function (component, event, helper) {
        component.set("v.showPopup", true);
    },
    closePopup : function (component, event, helper) {
        component.set("v.isSpinner", false);
        component.set("v.isLoading", false);
        component.set("v.showPopup", false);

    },
    handleLoad: function (component, event, helper) {
        component.find("caseStatus").set("v.value", "Open");
        component.find("caseType").set("v.value", "Rewards Escalation");
        component.find("caseCategory").set("v.value", null);

    },
    handleError: function (component, event, helper) {
        component.set("v.isSpinner", false);
        component.set("v.isLoading", false);
        console.error('ERROR:' + event.getParam("output").fieldErrors);
    },

    handleSubmit: function (component, event, helper) {

        var fileUploaded = component.find("fileUpload");
        if ( fileUploaded && fileUploaded.get("v.files") && fileUploaded.get("v.files").length > 0) {
            helper.attachFile(component, event);
        }

        component.set("v.isSpinner", true);
        component.set("v.isLoading", true);
    },

    handleSuccess: function (component, event, helper) {
        component.set("v.isSpinner", false);
        component.set("v.isLoading", false);
        component.set("v.showPopup", false);

        helper.showToast('Success','The Case will be transferred to the Loyalty Team','success');

        const workspaceAPI = component.find("workspace");
        workspaceAPI.getEnclosingTabId().then(function (tabId) {
            workspaceAPI.closeTab({tabId});
        })
            .catch(function (error) {
                console.error('Error in closing tab:' + error);
            });
    },

    handleFilesChange: function (component, event, helper) {
        var fileName = 'No File Selected..';
        if (event.getSource().get("v.files").length > 0) {
            fileName = event.getSource().get("v.files")[0]['name'];
        }
        component.set("v.fileName", fileName);
    }
});