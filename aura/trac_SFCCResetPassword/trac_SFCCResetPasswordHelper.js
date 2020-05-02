/**
 * Created by nrodrigues on 1/21/2020.
 */

({
    sendResetMailToUser : function(component, event, helper)
    {

        var resetPasswordAction = component.get("c.resetPassword");

        var email = component.find("customerEmail").get("v.value");
        var businessUnit = component.get("v.caseRecord.Business_Unit__c");

        resetPasswordAction.setParams({
            email: email,
            businessUnit: businessUnit
        });

        component.set("v.Spinner", true);
        resetPasswordAction.setCallback(this, function (response) {
            var state = response.getState();

            if (state === 'SUCCESS'){
                this.showToast('The password reset link will be sent to the user.', 'success', 'Success!')
            } else {
                this.showToast('An error was encountered. Please try again.', 'warning', 'Warning');
            }

        });

        $A.enqueueAction(resetPasswordAction);
        component.set("v.Spinner", false);
        component.set("v.showModal", false);
    },

    showToast: function (message, type, title) {
        var resultsToast = $A.get("e.force:showToast");
        resultsToast.setParams({
            "title": title,
            "message": message,
            "type": type
        });
        resultsToast.fire();
    }
})