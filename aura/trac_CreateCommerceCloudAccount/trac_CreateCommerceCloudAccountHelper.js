/**
 * Created by nrodrigues on 1/17/2020.
 */

({
    createAccountHelper : function(component, event, helper) {
        var email          = component.find('email').get("v.value");
        var firstName      = component.find('firstName').get("v.value");
        var lastName       = component.find('lastName').get("v.value");
        var phoneInput     = component.find("phoneInputValue").get("v.value");
        var zipCodeInput   = component.find("zipInputValue").get("v.value");
        var businessUnit   = component.get("v.caseRecord.Business_Unit__c");
        var contactInput   = component.get("v.caseRecord.Contact.Id");

        var action = component.get("c.createNewUser");

        action.setParams({
            email: email,
            lastName: lastName,
            firstName: firstName,
            businessUnit: businessUnit,
            contactId: contactInput

        });

        action.setCallback(this, function (response) {

            var state = response.getState();
            component.set("v.isLoading", true);

            if (component.isValid() && state === "SUCCESS")
            {
                var result =  response.getReturnValue();

                if (result == null) {
                    component.set("v.errorMsg", "Connection Error");
                } else {
                    if(result.isSuccess) {
                        console.log('Account created');
                        component.set("v.isError", false);
                        this.showToast("Account Created", "success", "Success");

                        var sfcc_CustomerId = result.returnValuesMap['SFCC_customerId'];
                        var sfcc_CustomerNo = result.returnValuesMap['SFCC_customerNo'];

                        var cmpEvent = component.getEvent("OBONewAccount");
                        cmpEvent.setParams({
                            "customerId" :  sfcc_CustomerId
                        });
                        cmpEvent.fire();

                        if( phoneInput!= '' || zipCodeInput!='') {
                            helper.createAddress(component, sfcc_CustomerId, phoneInput, zipCodeInput, businessUnit);
                        }
                    } else {
                        component.set("v.isError", true);
                        component.set("v.errorMsg", result.message);
                    }
                }
            } else {
                console.log("failed with state: " + state);
            }
            component.set("v.isLoading", false);
            component.set("v.showModal", false);
        });

        $A.enqueueAction(action);
    },

    createAddress : function(component, customerId, phone, zip, businessUnit)
    {
        var action = component.get("c.createAddress");

        action.setParams({
            customerId: customerId,
            phone: phone,
            zipCode: zip,
            businessUnit: businessUnit

        });

        action.setCallback(this, function (response) {

            var state = response.getState();
            component.set("v.isLoading", true);

            if (component.isValid() && state === "SUCCESS")
            {
                var result =  response.getReturnValue();

                if (result == null) {
                    component.set("v.errorMsg", "Connection Error");
                } else {
                    if(result.isSuccess) {
                        component.set("v.isError", false);

                    } else {
                        component.set("v.isError", true);
                        component.set("v.errorMsg", result.message);
                    }
                }
            } else {
                console.error("failed with state: " + state);
            }
            component.set("v.isLoading", false);
        });

        $A.enqueueAction(action);
    },

    showToast: function(message, type, title) {
        var resultsToast = $A.get("e.force:showToast");
        resultsToast.setParams({
            "title": title,
            "message": message,
            "type" : type
        });
        resultsToast.fire();
    }
});