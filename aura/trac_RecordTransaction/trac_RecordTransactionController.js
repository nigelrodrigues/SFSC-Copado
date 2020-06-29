/**
 * Created by gtorres on 6/5/2020.
 */


({
    updateTotalEarn: function(cmp, event, helper) {
        var TransactionSubtotal = cmp.find("TransactionSubtotal").get("v.value");
        var SubtotalExcludedItems = cmp.find("SubtotalExcludedItems").get("v.value");


        var tier = cmp.get('v.loyalty.top_tier_name').toLowerCase();
        var tier_multiplier = 1;
        if (tier === 'hudson\'s bay rewards plus') {
            tier_multiplier = 1.5;
        }
        else if (tier === 'hudson\'s bay rewards vip') {
            tier_multiplier = 2;
        }
        var totalEarnValue = ((TransactionSubtotal - SubtotalExcludedItems) * tier_multiplier);
        cmp.set('v.totalEarnValue', totalEarnValue);
    },

    handleSubmit: function(cmp, event, helper) {
        if (helper.validateForm(cmp)) {
            helper.submitRecordTransaction(cmp, helper);

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