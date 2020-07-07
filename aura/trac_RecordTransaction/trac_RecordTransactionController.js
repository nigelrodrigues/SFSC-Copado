/**
 * Created by gtorres on 6/5/2020.
 */


({
    updateTotalEarn: function(cmp, event, helper) {
        var TransactionSubtotal = helper.normalize(cmp.find("TransactionSubtotal").get("v.value"));
        var SubtotalExcludedItems = helper.normalize(cmp.find("SubtotalExcludedItems").get("v.value"));

        cmp.find("TransactionSubtotal").set("v.value", TransactionSubtotal)
        cmp.find("SubtotalExcludedItems").set("v.value", SubtotalExcludedItems)

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

    updateDateFromNumber: function(cmp, event, helper) {
        var transactionNumber = cmp.find("TransactionNumber").get("v.value");

        if(transactionNumber.length === 19) {
            var date = transactionNumber.substr(11).replace(/(\d{2})(\d{2})(\d{4})/, "$1/$2/$3");
            cmp.set("v.date", date);
        }
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

    },
    handleButtonChange: function(cmp, event, helper) {
        cmp.set("v.date", "");


    }
});