/**
 * Created by gtorres on 6/5/2020.
 */

({
    updateTotalEarn: function(cmp, event, helper) {
        var TransactionSubtotal = cmp.find("TransactionSubtotal").get("v.value");
        var SubtotalExcludedItems = cmp.find("SubtotalExcludedItems").get("v.value");
        var tier = cmp.get('v.loyalty.top_tier_name');
        var tier_multiplier = 1;
        if (tier === 'Hudson\'s Bay Rewards Plus') {
            tier_multiplier = 1.5;
        }
        else if (tier === 'Hudson\'s Bay Rewards VIP') {
            tier_multiplier = 2;
        }
        //Total Earn = (Subtotal - Exclusions)* tier_multiplier, where tier_multiplier = 2 for VIP, 1.5 for Plus, and 1 otherwise.
        var totalEarnValue = ((TransactionSubtotal - SubtotalExcludedItems) * tier_multiplier).toFixed(2);
        cmp.set('v.totalEarnValue', totalEarnValue);
    },

    handleSubmit: function(cmp, event, helper) {
        if (helper.validateForm(cmp)) {
            helper.submitRecordTransaction(cmp);
        }
    },

    handleCancel: function(cmp, event, helper) {
        helper.close(cmp);
    },

    doneRendering: function(cmp, event, helper) {
        //window.scrollTo(0,480);
        //scrollTo({top: 480, behavior: "smooth"});
    }
});