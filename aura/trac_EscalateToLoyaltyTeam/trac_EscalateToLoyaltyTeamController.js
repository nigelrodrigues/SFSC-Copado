/**
 * Created by nrodrigues on 6/10/2020.
 */
({
    openForm : function(component, event, helper)
    {
        component.set("v.openLightningForm", true);
    },

    closeForm : function(component, event, helper)
    {
        component.set("v.isSpinner", false);
        component.set("v.isLoading", false);
        component.set("v.openLightningForm", false);

    },
    handleLoad: function (component, event, helper)
    {
        let caseRecord = component.get("v.caseRecord");
        let selectedTeam = component.get("v.selectedTeam");
        if( selectedTeam === 'operations')
        {
            component.find("caseStatus").set("v.value", "Open");
            component.find("caseType").set("v.value", "Rewards Escalation");
        }
        else
        {
            component.find("caseStatus").set("v.value", caseRecord.Status);
            component.set("v.showEscalationOptions", true);
        }
    },
    handleError: function (component, event, helper) {
        component.set("v.isSpinner", false);
        component.set("v.isLoading", false);
        console.error('ERROR:' + event.getParam("output").fieldErrors);
    },


    handleSubmit: function (component, event, helper)
    {
        let selectedTeam = component.get("v.selectedTeam");
        let keepCaseOpen = component.get("v.selectedForCaseClose");
        //let createNewCase = component.get("v.createNewCase");

        // For Loyalty Operations Team
        if ( selectedTeam === "operations")
        {
            component.find("caseType").set("v.value", "Rewards Escalation");
            component.set("v.showEscalationOptions", false);
            //component.set("v.createNewCase",   false);

            let fileUploaded = component.find("fileUpload");

            if ( fileUploaded && fileUploaded.get("v.files") && fileUploaded.get("v.files").length > 0) {
                helper.attachFile(component, event);
            }
        }
        // For Loyalty Escalations Team
        else if ( selectedTeam === "escalation")
        {
            event.preventDefault(); // stop form submission
            let eventFields = event.getParam("fields");

            // set new case fields
            let issueDescription = component.find("caseIssueDescription").get("v.value");
            let newCaseType = "Rewards";
            let newCaseCategory = component.find("escalateCategory").get("v.value");
            let newCaseSubCategory = null;
            component.set("v.issue", issueDescription);
            component.set("v.newCaseType", newCaseType);
            component.set("v.newCaseCategory", newCaseCategory);

            // set eventFields
            eventFields["Status"] = "Open";
            if (keepCaseOpen === "no") {
                // update original case with user generated data
                eventFields["Case_Type__c"] = newCaseType;
                eventFields["Category__c"] = newCaseCategory;
                eventFields["Subcategory__c"] = newCaseSubCategory;
                eventFields["Loyalty_Issue_Description__c"] = issueDescription;
            }

            // submit the escalateForm
            component.find('escalateForm').submit(eventFields);

            // attach file and complete case processing
            helper.attachFile(component, event, helper);
        }

        component.set("v.isSpinner", true);
        component.set("v.isLoading", true);
    },
    handleSuccess: function (component, event, helper)
    {
        component.set("v.isSpinner", false);
        component.set("v.isLoading", false);
        component.set("v.openLightningForm", false);
        let errorEncountered = component.get("v.isError");

        if( !errorEncountered )
        {
            let selectedTeam = component.get("v.selectedTeam");
            let keepCaseOpen = component.get("v.selectedForCaseClose");
            if( selectedTeam === "operations" )
            {
                helper.showToast('Success', 'The Case will be transferred to the Loyalty Operations Team', 'success');
                const workspaceAPI = component.find("workspace");
                workspaceAPI.getEnclosingTabId().then(function (tabId) {
                    workspaceAPI.closeTab({tabId});
                })
                .catch(function (error) {
                    console.error('Error in closing tab:' + error);
                });
            }

            if ( selectedTeam === "escalation")
            {
                if( keepCaseOpen==="no" )
                {
                    helper.showToast('Success', 'Case transferred to Loyalty Escalations Team', 'success');
                    const workspaceAPI = component.find("workspace");
                    workspaceAPI.getEnclosingTabId().then(function (tabId) {
                        workspaceAPI.closeTab({tabId});
                    })
                    .catch(function (error) {
                        console.error('Error in closing tab:' + error);
                    });
                }
            }
        }
    },

    handleFilesChange: function (component, event, helper)
    {
        let fileName = 'No File Selected..';

        if (event.getSource().get("v.files").length > 0)
        {
            fileName = event.getSource().get("v.files")[0]['name'];
        }
        component.set("v.fileName", fileName);
    },

    handleRadioChange: function (component, event, helper)
    {
        const step = event.getSource().get("v.value");
        let selectedTeam = component.get("v.selectedTeam");
        let caseRecord = component.get("v.caseRecord");
        let keepCaseOpen = component.get("v.selectedForCaseClose");
        if ( selectedTeam === "operations")
        {
            component.find("caseStatus").set("v.value", "Open");
            component.find("caseType").set("v.value", "Rewards Escalation");
            component.find("caseCategory").set("v.value", null);
            component.set("v.showEscalationOptions", false);
        }
        else if ( selectedTeam === "escalation" )
        {
            component.set("v.showEscalationOptions", true);
        }
    }
});