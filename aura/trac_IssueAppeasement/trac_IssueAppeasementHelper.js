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

            var conversionRate = cmp.get('v.conversionRate')
            var appeaseValue = (appeasePoints * conversionRate).toFixed(2);
            cmp.set('v.appeaseValue', appeaseValue);

            var finalBalance = parseInt(cmp.get('v.pointsAvailable')) + appeasePoints;
            cmp.set('v.finalPointBalance', finalBalance);
        }
    },
    checkDisableButton: function(cmp) {
        var maxAppeasement = cmp.get('v.maxAppeasement');
        var allowUnlimited = cmp.get('v.allowUnlimited');
        var disableButton = (!allowUnlimited && maxAppeasement <= 0);
        cmp.set('v.disableButton', disableButton);
    },
    getProfileLimit: function(cmp) {
        var action = cmp.get('c.getProfileAppeasementLimit');
        action.setCallback(this, function (response) {
            var state = response.getState();

            if (cmp.isValid() && state === "SUCCESS") {
                var result = response.getReturnValue();

                if (typeof result !== undefined && result != null) {
                    cmp.set('v.profileName', result.profileName);
                    if (result.maxAppeasement === 'Unlimited') {
                        cmp.set('v.allowUnlimited', true);
                        cmp.set('v.maxAppeasement', 99999999);
                    } else {
                        cmp.set('v.allowUnlimited', false);
                        cmp.set('v.maxAppeasement', parseInt(result.maxAppeasement));
                    }
                    // enable / disable submit button appropriately
                    this.checkDisableButton(cmp);
                } else {
                    // unexpected error
                    cmp.set("v.isError", true);
                    cmp.set("v.errorMsg", "Unknown user profile");
                }
            }
        });
        $A.enqueueAction(action);
    },
    checkAppeasementValue: function(cmp) {
        var retval = true;
        var maxAppeasement = cmp.get('v.maxAppeasement');
        var allowUnlimited = cmp.get('v.allowUnlimited');
        var appeasePoints = cmp.get('v.appeasePoints');
        var inputCmp = cmp.find("amount");
        inputCmp.setCustomValidity("");
        // check < 0
        if (appeasePoints <= 0) {
            inputCmp.setCustomValidity("Invalid appeasement amount: " + appeasePoints);
            retval = false;
        }
        // check > max
        else if (!allowUnlimited) {
            if (appeasePoints > maxAppeasement) {
                inputCmp.setCustomValidity("Maximum appeasement is " + maxAppeasement);
                retval = false;
            }
        }
        inputCmp.reportValidity();
        return retval;
    },
    submitAppeasement: function(cmp, event, helper) {
        cmp.set('v.showSpinner', true);
        //this.checkDisableButton(cmp);
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
            //this.checkDisableButton(cmp);
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