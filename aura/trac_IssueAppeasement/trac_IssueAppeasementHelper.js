/**
 * Created by akong on 5/21/2020.
 */

({
    showToast: function(message, type, title) {
        var resultsToast = $A.get("e.force:showToast");
        resultsToast.setParams({
            "title": title,
            "message": message,
            "type" : type
        });
        resultsToast.fire();
    },
    calculateAmounts: function(cmp) {
        var appeasePoints = cmp.get('v.appeasePoints');
        if (!$A.util.isEmpty(appeasePoints)) {
            appeasePoints = parseInt(appeasePoints);

            var appeaseValue = (appeasePoints / 200).toFixed(2);
            cmp.set('v.appeaseValue', appeaseValue);

            var finalBalance = parseInt(cmp.get('v.pointsAvailable')) + appeasePoints;
            cmp.set('v.finalPointBalance', finalBalance);
        }
    },
    submitAppeasement: function(cmp, event, helper) {
        cmp.set('v.showSpinner', true);
        var appeasePoints = cmp.get("v.appeasePoints");

        // submit to server
        var action = cmp.get('c.submitAppeasement');

        var params = {
            loyaltyNumber: cmp.get('v.loyalty.external_customer_id'),
            email: cmp.get('v.loyalty.email'),
            points: cmp.get('v.appeasePoints'),
            pointsAvailable: cmp.get('v.pointsAvailable')
        };
        action.setParams(params);

        action.setCallback(this, function (response) {
            cmp.set('v.showSpinner', false);
            var state = response.getState();

            if (cmp.isValid() && state === "SUCCESS") {
                var result = response.getReturnValue();

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
    },
    fireCloseModalEvent: function() {
        var appEvent = $A.get("e.c:trac_CloseModalApplicationEvent");
        appEvent.setParams({"closeModal" : true});
        appEvent.fire();
    }
});