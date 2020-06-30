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
        component.find("caseStatus").set("v.value", "Open");
        var selectedTeamue = component.get("v.selectedTeam");
        if( selectedTeamue === 'operations')
        {
            component.find("caseType").set("v.value", "Rewards Escalation");
            component.set("v.enableCategory", true);
        }
        else
        {
            component.set("v.enableCategory", false);
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
        let closeCase = component.get("v.selectedForCaseClose");
        if ( selectedTeam === "operations")
        {
            component.find("caseType").set("v.value", "Rewards Escalation");
            component.set("v.showEscalationOptions", false);
            component.set("v.createNewCase",   false);


            var fileUploaded = component.find("fileUpload");
            if ( fileUploaded && fileUploaded.get("v.files") && fileUploaded.get("v.files").length > 0) {
                helper.attachFile(component, event);
            }


        }
        if ( selectedTeam === "escalation")
        {
            event.preventDefault(); // stop form submission

            let eventFields = event.getParam("fields");

            // For option - No, close case.
            if( closeCase==="no" )
            {
                component.set("v.enableCategory", true);
                eventFields["Case_Type__c"] = "Rewards";
                eventFields["Category__c"] = "Goodwill Points";
                eventFields["Subcategory__c"] = "Requires Approval";
                eventFields["Loyalty_Issue_Description__c"]  = component.find("caseIssueDescription").get("v.value");


                component.find('escalateForm').submit(eventFields);
                helper.attachFile(component, event, helper);
            }
            else
            {


                let issueEntered = component.find("caseIssueDescription").get("v.value");
                eventFields["Loyalty_Issue_Description__c"]  = issueEntered;
                component.find('escalateForm').submit(eventFields);
                component.set("v.issue", issueEntered);

                helper.attachFile(component, event, helper);
            }
        }

        component.set("v.isSpinner", true);
        component.set("v.isLoading", true);
    },
    handleSuccess: function (component, event, helper)
    {


        component.set("v.isSpinner", false);
        component.set("v.isLoading", false);
        component.set("v.openLightningForm", false);
        var errorEncountered = component.get("v.isError");


        if( !errorEncountered )
        {
            let selectedTeam = component.get("v.selectedTeam");
            let closeCase = component.get("v.selectedForCaseClose");


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

                if( closeCase==="no" )
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

        var fileName = 'No File Selected..';
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
        let closeCase = component.get("v.selectedForCaseClose");
        if ( selectedTeam === "operations")
        {
            component.set("v.enableCategory", true);
            component.find("caseType").set("v.value", "Rewards Escalation");
            component.find("caseCategory").set("v.value", null);
            component.set("v.showEscalationOptions", false);
            component.set("v.createNewCase",   false);
        }
        if ( selectedTeam === "escalation" )
        {
            component.set("v.enableCategory", false);
            component.set("v.showEscalationOptions", true);
        }


    }
});