/**
 * @description Client-side controller for trac_IssueAppeasement aura component
 * @author      Alex Kong, Traction on Demand
 * @date        2020-05-21
 */
({
    doInit: function(cmp, event, helper) {
        var pointsAvailable = cmp.get('v.loyalty.balance');
        pointsAvailable = $A.util.isEmpty(pointsAvailable) ? 0 : parseInt(pointsAvailable);
        cmp.set('v.pointsAvailable', pointsAvailable);
        helper.calculateAmounts(cmp);
        helper.getProfileLimit(cmp);
    },
    changeAmount: function(cmp, event, helper) {
        console.log('Inside changeAmount');
        helper.calculateAmounts(cmp);
        var inputCmp = cmp.find("amount");
        inputCmp.setCustomValidity("");
        inputCmp.reportValidity();
    },
    submitAppeasementForm: function(cmp, event, helper) {
        // check validity
        if (cmp.find('amount').get('v.validity').valid) {
            // form field is valid, do one final check on max appeasement amount
            if (helper.checkAppeasementValue(cmp)) {
                // all good, submit the appeasement
                helper.submitAppeasement(cmp, event, helper);
            }
        }
    },
    formPress: function (cmp, event, helper) {
        if (event.key === 'Enter') {
            $A.enqueueAction(cmp.get('c.submitAppeasementForm'));
        }
    },
});