/**
 * Created by nrodrigues on 6/10/2020.
 */

({
    MAX_FILE_SIZE: 25000000,

    attachFile : function (component, event, helper) {

        var fileInput = component.find("fileUpload").get("v.files");
        var createCase = component.get("v.selectedForCaseClose");


        if( fileInput )
        {
            var file = fileInput[0];
            var self = this;

            if (file.size > self.MAX_FILE_SIZE) {
                component.set("v.fileName", 'Maximum size of the file is 25 MB.\n' + ' Selected file size: ' + (file.size/1000000) + 'MB.');
                return;
            }

            var objFileReader = new FileReader();
            objFileReader.onload = $A.getCallback(function () {
                var fileContents = objFileReader.result;
                var base64 = 'base64,';
                var dataStart = fileContents.indexOf(base64) + base64.length;
                fileContents = fileContents.substring(dataStart);
                self.processCaseAndAttachment(component, file, fileContents);
            });

            objFileReader.readAsDataURL(file);
        }
        else if( createCase === "yes" )
        {
            this.processCaseAndAttachment(component, null, null);
        }

    },

    processCaseAndAttachment: function(component, file, fileContents)
    {
        let caseRecord = component.get("v.caseRecord");
        let newCaseCreation = component.get("v.selectedForCaseClose");
        let createCase = false;


        if( newCaseCreation === "yes")
            createCase = true;

        let action = component.get("c.createCaseAndAttachFile");

        if( file )
        {
            let fileContent = fileContents.substring(0, fileContents.length);

            action.setParams({
                caseRecord: caseRecord,
                contentType: file.type,
                fileName: file.name,
                fileContentsToEncode: encodeURIComponent(fileContent),
                cloneCase: createCase
            });
        }
        else
        {
            action.setParams({
                caseRecord: caseRecord,
                contentType: null,
                fileName: null,
                fileContentsToEncode: null,
                cloneCase: createCase
            });
        }

        action.setCallback(this, function(response) {

            var state = response.getState();
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
                            var retrievedCase = result.returnValuesMap['caseRecord'];
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
        var resultsToast = $A.get("e.force:showToast");
        resultsToast.setParams({
            "title": title,
            "message": message,
            "type": type
        });
        resultsToast.fire();
    }
});