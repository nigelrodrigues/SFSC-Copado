/**
 * Created by nrodrigues on 3/3/2020.
 */

({
    getEmailBody : function (component, event, helper) {
        var Id = component.get('v.id');

        var action = component.get('c.retrieveEmailBody');

        console.log('IDL '+Id);
        action.setParams({
            "requestBodyId": Id
        });

        action.setCallback(this, function (response) {
            var state = response.getState();

            if (component.isValid() && state === "SUCCESS") {

                var result =  response.getReturnValue();

                if (result == null) {
                    component.set("v.errorMsg", "Connection Error");
                } else {
                    if(result.isSuccess) {

                        var emailBodyResponse = result.returnValuesMap['emailBodyResponse'];
                        if(!$A.util.isEmpty(emailBodyResponse)) {
                            component.set('v.emailBody', emailBodyResponse);
                        }
                        else{

                        }
                    } else {
                        component.set("v.isError", true);
                        component.set("v.errorMsg", result.message);
                    }
                }
            }
            else {
                console.log("failed with state: " + state);
            }

        });

        $A.enqueueAction(action);

    },

    resendEmailToUser : function (component, event, helper) {
        var Id = component.get('v.id');
        var email = component.find('customerEmailField').get('v.value');

        var action = component.get('c.resendEmailToCustomer');

        action.setParams({
            "requestId": Id,
            "email": email
        });

        action.setCallback(this, function (response) {
            var state = response.getState();

            if (component.isValid() && state === "SUCCESS") {

                var result =  response.getReturnValue();

                if (result == null) {
                    component.set("v.errorMsg", "Connection Error");
                } else {
                    if(result.isSuccess) {

                        var emailSentValue = result.returnValuesMap['emailSent'];
                        console.log('emailSentValue' + emailSentValue);
                        if(emailSentValue === 1) {
                            helper.showToast('Email will be sent to the customer', 'success', 'Resend Email operation successful')
                        }
                        else{
                            helper.showToast('An error was encountered', 'error', 'Please try again')
                        }
                    } else {
                        component.set("v.isError", true);
                        component.set("v.errorMsg", result.message);
                    }
                }
            }
            else {
                console.log("failed with state: " + state);
            }
        });

        $A.enqueueAction(action);
        component.set('v.showModal', false);

    },

    showToast : function(message, type, title) {
        var resultsToast = $A.get("e.force:showToast");
        resultsToast.setParams({
            "title": title,
            "message": message,
            "type" : type
        });
        resultsToast.fire();
    }
});