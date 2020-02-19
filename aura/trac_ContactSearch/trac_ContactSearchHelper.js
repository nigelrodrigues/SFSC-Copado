/**
 * Created by ragrawal on 6/17/2019.
 */
({
    SearchHelper: function(component, event) {
        component.set("v.Message", false);

        // show spinner message
        component.find("Id_spinner").set("v.class" , 'slds-show');
        var action = component.get("c.getContacts");
        action.setParams({
            'contact': component.get("v.contactRecord")
        });
        action.setCallback(this, function(response) {
            // hide spinner when response coming from server
            component.find("Id_spinner").set("v.class" , 'slds-hide');
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.isModalOpen", true);
                /*var utilityAPI = component.find("utilitybar");
                utilityAPI.minimizeUtility();*/
                var storeResponse = response.getReturnValue();
                // if storeResponse size is 0 ,display no record found message on screen.
                if (storeResponse.length == 0) {
                    component.set("v.Message", true);
                } else {
                    component.set("v.Message", false);
                }

                // set numberOfRecord attribute value with length of return value from server
                component.set("v.TotalNumberOfRecord", storeResponse.length);

                // set searchResult list with return value from server.
                component.set("v.searchResult", storeResponse);

            }else if (state === "INCOMPLETE") {
                alert('Response is Incompleted');
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert("Error message: " +
                            errors[0].message);
                    }
                } else {
                    alert("Unknown error");
                }
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

    checkBlank: function(component, fields) {
        var notValid = true;
        for (var item in fields) {
            if (notValid && (fields[item].get("v.value") == null || fields[item].get("v.value") == '')) {
                continue;
            }
            else {
                return false;
            }
        }
        return true;
        /*if (component.find(field).get("v.value") == null || component.find(field).get("v.value") == '') {
            return true;
        }
        else {
            return false;
        }*/
    },
    linkContactAndCase: function(component,caseRecordId,conId)
    {
        var action = component.get("c.linkContactWithCase");
        action.setParams({
            caseId: caseRecordId,
            contactId : conId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                //this.openSubTab(component,caseRecordId,conId);
                location.reload();
            }
            else if (state === "INCOMPLETE") {
                console.error('INCOMPLETE');
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });

        $A.enqueueAction(action);

    },

    openSubTab: function(component,caseId,conId)
    {
        location.reload();
       /* var workspaceAPI = component.find("workspace");
        console.log('/lightning/r/Case/'+caseId+'/view');
        workspaceAPI.openTab({
            url: '/lightning/r/Case/'+caseId+'/view',
            focus: true
        }).then(function(response) {
            console.log(conId);
            console.log('/lightning/r/Contact/'+conId+'/view');
            workspaceAPI.openSubtab({
                parentTabId: response,
                url: '/lightning/r/Contact/'+conId+'/view',
                focus: true
            });
        })
            .catch(function(error) {
                console.log('Error in refresh');
                console.log(error);
            });*/

    },
})