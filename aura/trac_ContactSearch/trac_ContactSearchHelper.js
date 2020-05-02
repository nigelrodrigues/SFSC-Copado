/**
 * Created by ragrawal on 6/17/2019.
 */
({
    searchHelper: function(component, event, helper) {
        component.set("v.Message", false);
        component.find("Id_spinner").set("v.class" , 'slds-show');
        
        var action = component.get("c.getContacts");
        action.setParams({
            'contact': component.get("v.contactRecord")
        });
        action.setCallback(this, function(response) {
            component.find("Id_spinner").set("v.class" , 'slds-hide');
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.isModalOpen", true);
                
                var storeResponse = response.getReturnValue();
                // if storeResponse size is 0 ,display no record found message on screen.
                if (storeResponse.length === 0) {
                    component.set("v.Message", true);
                } else {
                    component.set("v.Message", false);
                }
                if (storeResponse.length === 1) {
                    component.set("v.isModalOpen", false);
                    var caseId = component.get("v.recordId");
                    var contact = storeResponse[0];
                    if (caseId && contact) {
                        helper.linkContactAndCase(component, caseId, contact.Id);
                    }
                }else if( storeResponse.length!=null && storeResponse.length>25 ) {
                    component.set("v.TotalNumberOfRecord", 25);
                    var partialResults = storeResponse.slice(0, 25);
                    component.set("v.searchResult", partialResults);
                    component.set("v.isPartial", true);
                } else if (storeResponse.length!=null && storeResponse.length<25) {
                    component.set("v.TotalNumberOfRecord", storeResponse.length);
                    component.set("v.searchResult", storeResponse);
                    component.set("v.isPartial", false);
                }
            }else if (state === "INCOMPLETE") {
                alert('Response is incomplete');
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

    testEmail: function(component,email){
        if(/^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,20})+$/.test(email)){
            component.set("v.errorMessage","Please specify at least one more search criteria for detailed search.");
            return true;
        }else{
            component.set("v.errorMessage","You have entered an invalid email format.");
            return false;
        }
    },

    validateEmail: function(component,contactFields){
        if(!Array.isArray(contactFields) && contactFields.get("v.type") === "email" && contactFields.get("v.value")){
            return this.testEmail(component,contactFields.get("v.value"));
        }else if(Array.isArray(contactFields)){
            let isValidEmail = true;
            for (var contactField in contactFields) {
                if (contactFields[contactField] && contactFields[contactField].get('v.class') && contactFields[contactField].get('v.class').includes('required-fields') && contactFields[contactField].get("v.type") === "email" && contactFields[contactField].get("v.value")) {
                    isValidEmail = this.testEmail(component,contactFields[contactField].get("v.value"));
                }
                if(!isValidEmail){
                    break;
                }
            }
            return isValidEmail;
        }

    },

    validateRequiredFields: function(component,contactFields){
        if(!Array.isArray(contactFields) && !contactFields.get("v.value")){
            component.set("v.errorMessage","Please enter a value in Email to perform search");
            return false;
        }else if(!Array.isArray(contactFields) && contactFields.get("v.value")){
            component.set("v.errorMessage","Please specify at least one more search criteria for detailed search.");
            return true;
        }else if(Array.isArray(contactFields)){
            let isBlank = true;
            for (var contactField in contactFields) {
                if (contactFields[contactField] && contactFields[contactField].get('v.class') && contactFields[contactField].get('v.class').includes('required-fields') && contactFields[contactField].get("v.value")) {
                    isBlank =false;
                    break;
                }
            }
            if(isBlank){
                component.set("v.errorMessage","Please specify at least one search criteria among required fields - Email, Phone, Order Number,Last Name");
                return false;
            }else{
                component.set("v.errorMessage","Please specify at least one more search criteria for detailed search.");
                return true;
            }
        }
    },


    validateForm: function(component, contactFields) {
        let isValid = true;
        isValid = this.validateRequiredFields(component,contactFields);
        if(isValid){
            isValid = this.validateEmail(component,contactFields);
        }
        return isValid;
    },
    
    linkContactAndCase: function(component,caseRecordId,conId) {
        var action = component.get("c.linkContactWithCase");
        action.setParams({
            caseId: caseRecordId,
            contactId : conId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                //location.reload();
                $A.get('e.force:refreshView').fire();
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
    
    openSubTab: function(component,caseId,conId) {
        location.reload();
    }
})