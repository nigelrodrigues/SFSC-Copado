/**
 * @description Client-side controller for trac_IssueAppeasement aura component
 * @author      Alex Kong, Traction on Demand
 * @date        2020-05-21
 */
({
    doInit: function(cmp, event, helper) {
        cmp.set('v.isSpinner', true);
        cmp.set('v.isLoading', false);
        helper.calculateDisplayAmounts(cmp);
    },
    selectAmount: function(cmp, event, helper) {
        helper.calculateDisplayAmounts(cmp);
    },
    submitAppeasementForm: function(cmp, event, helper) {
        cmp.set('v.isLoading', true);
        var selectedAmount = cmp.get("v.selectedAmount");
        console.log("Submitting appeasement of " + selectedAmount + " points");

        // submit to server
        var action = cmp.get('c.submitAppeasement');

        var params = {
            contactId: cmp.get('v.contactId'),
            points: cmp.get('v.selectedAmount'),
            pointsAvailable: cmp.get('v.pointsAvailable')
        };
        console.log('params: ', params);
        action.setParams(params);

        action.setCallback(this, function (response) {
            console.log('inside action setCallback; response: ', response);
            cmp.set('v.isLoading', false);
            var state = response.getState();

            console.log('cmp.isValid: ' + cmp.isValid() + '; state: ' + state);
            if (cmp.isValid() && state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('result: ', result);

                if (typeof result !== undefined && result != null) {
                    if (result.isSuccess) {
                        // success, show success toast
                        helper.showToast(result.message, 'success', 'Appeasement Submitted');

                        // fire event to close the modal
                        helper.fireCloseModalEvent();
                    } else {
                        // failure, show error message
                        cmp.set("v.isError", true);
                        cmp.set("v.errorMsg", result.message);
                    }
                } else {
                    // unexpected error
                    cmp.set("v.isError", true);
                    cmp.set("v.errorMsg", "Connection Error");
                }
            }
        });
        $A.enqueueAction(action);
    }
});