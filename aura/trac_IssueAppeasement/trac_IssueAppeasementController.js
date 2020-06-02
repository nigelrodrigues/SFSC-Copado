/**
 * @description Client-side controller for trac_IssueAppeasement aura component
 * @author      Alex Kong, Traction on Demand
 * @date        2020-05-21
 */
({
    doInit: function(cmp, event, helper) {
        //cmp.set('v.isSpinner', false); // don't use the base component spinner
        cmp.set('v.showSpinner', false);
        var pointsAvailable = cmp.get('v.loyalty.balance'); //cmp.get('v.loyalty.authorized_points_balance');
        console.log('v.loyalty: ', cmp.get('v.loyalty'));
        console.log('pointsAvailable A: ', pointsAvailable);
        pointsAvailable = $A.util.isEmpty(pointsAvailable) ? 0 : parseInt(pointsAvailable);
        cmp.set('v.pointsAvailable', pointsAvailable);
        console.log('pointsAvailable B: ', pointsAvailable);
        helper.calculateAmounts(cmp);
    },
    selectAmount: function(cmp, event, helper) {
        helper.calculateAmounts(cmp);
    },
    submitAppeasementForm: function(cmp, event, helper) {
        cmp.set('v.showSpinner', true);
        var appeasePoints = cmp.get("v.appeasePoints");
        console.log("Submitting appeasement of " + appeasePoints + " points");

        // submit to server
        var action = cmp.get('c.submitAppeasement');

        var params = {
            //contactId: cmp.get('v.contactId'),
            loyaltyNumber: cmp.get('v.loyalty.external_customer_id'),
            email: cmp.get('v.loyalty.email'),
            points: cmp.get('v.appeasePoints'),
            pointsAvailable: cmp.get('v.pointsAvailable')
        };
        console.log('params: ', params);
        action.setParams(params);

        action.setCallback(this, function (response) {
            console.log('inside action setCallback; response: ', response);
            cmp.set('v.showSpinner', false);
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