/**
 * Created by nrodrigues on 6/10/2020.
 */

({
    MAX_FILE_SIZE: 25000000,
    attachFile : function (component, event, helper) {
        let fileInput = component.find("fileUpload").get("v.files");
        let createCase = component.get("v.selectedForCaseClose");
        console.log('fileInput: ', fileInput);
        console.log('createCase: ', createCase);
        if( fileInput )
        {
            console.log('inside file upload scenario');
            let file = fileInput[0];
            let self = this;
            console.log('file: ', file);

            if (file.size > self.MAX_FILE_SIZE) {
                component.set("v.fileName", 'Maximum size of the file is 25 MB.\n' + ' Selected file size: ' + (file.size/1000000) + 'MB.');
                return;
            }

            let objFileReader = new FileReader();
            objFileReader.onload = $A.getCallback(function () {
                let fileContents = objFileReader.result;
                let base64 = 'base64,';
                let dataStart = fileContents.indexOf(base64) + base64.length;
                fileContents = fileContents.substring(dataStart);
                console.log('About to call self.processCaseAndAttachment');
                self.processCaseAndAttachment(component, file, fileContents);
            });

            objFileReader.readAsDataURL(file);
        }
        else if( createCase === "yes" )
        {
            console.log('About to call this.processCaseAndAttachment');
            this.processCaseAndAttachment(component, null, null);
        }

    },

    processCaseAndAttachment: function(component, file, fileContents)
    {
        console.log('Inside processCaseAndAttachment');
        let caseRecord = component.get("v.caseRecord");
        let newCaseCreation = component.get("v.selectedForCaseClose");
        let issueEntered = component.get("v.issue");
        let newCaseType = component.get("v.newCaseType");
        let newCaseCategory = component.get("v.newCaseCategory");
        let newCaseSubcategory = component.get("v.newCaseSubcategory");
        let createCase = false;
        if( newCaseCreation === "yes") {
            createCase = true;
        }
        console.log('newCaseType: ' + newCaseType);
        console.log('newCaseCategory: ' + newCaseCategory);
        console.log('newCaseSubcategory: ' + newCaseSubcategory);
        console.log('issueEntered: ' + issueEntered);

        let action = component.get("c.createCaseAndAttachFile");
        let params = {
            caseRecord: caseRecord,
            contentType: null,
            fileName: null,
            fileContentsToEncode: null,
            cloneCase: createCase,
            loyaltyIssue : issueEntered,
            newCaseType : newCaseType,
            newCaseCategory : newCaseCategory,
            newCaseSubcategory : newCaseSubcategory
        };
        console.log('params A: ', params);
        if (file) {
            params.contentType = file.type;
            params.fileName = file.name;
            params.fileContentsToEncode = encodeURIComponent(fileContents.substring(0, fileContents.length));
        }
        console.log('params B: ', params);
        action.setParams(params);

        action.setCallback(this, function(response) {
            let state = response.getState();
            if (component.isValid() && state === "SUCCESS")
            {
                let result =  response.getReturnValue();
                if (result == null)
                {
                    component.set("v.errorMsg", "Connection Error");
                }
                else
                    {
                        if(result.isSuccess)
                        {
                            let retrievedCase = result.returnValuesMap['caseRecord'];

                            if ( retrievedCase )
                            {
                                this.showToast('Success', 'New Case created and transferred to Loyalty Escalations Team', 'success');
                                component.set("v.openLightningForm", false);
                            }
                        }
                        else
                            {
                            component.set("v.isError", true);
                            component.set("v.errorMsg", result.message);
                        }

                }

            }
            else {
                component.set("v.isError", true);
                component.set("v.errorMsg", 'Please try again.');

            }
            component.set("v.isSpinner", false);
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    },
    showToast: function (title,message, type) {
        let resultsToast = $A.get("e.force:showToast");

        resultsToast.setParams({
            "title": title,
            "message": message,
            "type": type
        });
        resultsToast.fire();
    }
});