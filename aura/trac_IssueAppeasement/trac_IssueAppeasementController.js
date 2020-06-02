/**
 * @description Client-side controller for trac_IssueAppeasement aura component
 * @author      Alex Kong, Traction on Demand
 * @date        2020-05-21
 */
({
    doInit: function(cmp, event, helper) {
        cmp.set('v.showSpinner', false);
        var pointsAvailable = cmp.get('v.loyalty.balance');
        pointsAvailable = $A.util.isEmpty(pointsAvailable) ? 0 : parseInt(pointsAvailable);
        cmp.set('v.pointsAvailable', pointsAvailable);
        helper.calculateAmounts(cmp);
    },
    selectAmount: function(cmp, event, helper) {
        helper.calculateAmounts(cmp);
    },
    submitAppeasementForm: function(cmp, event, helper) {
        // check validity
        if (cmp.find('amount').get('v.validity').valid) {
            helper.submitAppeasement(cmp, event, helper);
        }
    },
    formPress: function (cmp, event, helper) {
        if (event.key === 'Enter') {
            $A.enqueueAction(cmp.get('c.submitAppeasementForm'));
        }
    },
});