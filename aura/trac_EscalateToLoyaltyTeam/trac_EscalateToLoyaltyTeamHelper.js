/**
 * Created by nrodrigues on 6/10/2020.
 */

({
    MAX_FILE_SIZE: 4500000,
    CHUNK_SIZE: 750000,

    showToast: function (title,message, type) {
        var resultsToast = $A.get("e.force:showToast");
        resultsToast.setParams({
            "title": title,
            "message": message,
            "type": type
        });
        resultsToast.fire();
    },

    attachFile : function (component, event, helper) {

        var fileInput = component.find("fileUpload").get("v.files");

        if( fileInput ) {
            var file = fileInput[0];
            var self = this;

            if (file.size > self.MAX_FILE_SIZE) {
                component.set("v.fileName", 'Selected file size is too large. Maximum allowed file size is ' + (self.MAX_FILE_SIZE/1000000) + ' MB.\n' + ' Selected file size: ' + (file.size/1000000) + 'MB.');
                return;
            }

            var objFileReader = new FileReader();
            objFileReader.onload = $A.getCallback(function () {
                var fileContents = objFileReader.result;
                var base64 = 'base64,';
                var dataStart = fileContents.indexOf(base64) + base64.length;
                fileContents = fileContents.substring(dataStart);
                self.uploadProcess(component, file, fileContents);
            });

            objFileReader.readAsDataURL(file);
        }
    },

    uploadProcess: function(component, file, fileContents) {

        var startPosition = 0;
        var endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);
        this.uploadInChunk(component, file, fileContents, startPosition, endPosition, '');
    },


    uploadInChunk: function(component, file, fileContents, startPosition, endPosition, attachId) {
        var getchunk = fileContents.substring(startPosition, endPosition);
        var action = component.get("c.attachToCase");
        var caseRecord = component.get("v.caseRecord");

        action.setParams({
            parentId: caseRecord.Id,
            contentType: file.type,
            fileName: file.name,
            fileContentsToEncode: encodeURIComponent(getchunk)
        });

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
                            startPosition = endPosition;
                            endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);

                            if (startPosition < endPosition)
                            {
                                this.uploadInChunk(component, file, fileContents, startPosition, endPosition, attachId);
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
                console.error("failed with state: " + state);
            }

        });

        $A.enqueueAction(action);

    }
});