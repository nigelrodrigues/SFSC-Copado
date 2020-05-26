/**
 * @description Client-side controller for trac_IssueAppeasement aura component
 * @author      Alex Kong, Traction on Demand
 * @date        2020-05-21
 */
({
    doInit: function(cmp, event, helper) {
        helper.calculateDisplayAmounts(cmp);
    },
    selectAmount: function(cmp, event, helper) {
        let selectedLabel = event.getSource().get("v.label");
        let amount = parseInt(selectedLabel.replace(",",""));
        console.log("amount: ", amount);
        cmp.set("v.selectedAmount", amount);
        cmp.set("v.selectedLabel", selectedLabel);
        helper.calculateDisplayAmounts(cmp);
    },
    submitAppeasement: function(cmp, event, helper) {
        var selectedAmount = cmp.get("v.selectedAmount");
        console.log("Submitting appeasement of " + selectedAmount + " points");

        // submit to server

        // handle response
    }
});