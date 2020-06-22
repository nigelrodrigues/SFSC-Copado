/**
 * Created by gtorres on 6/5/2020.
 */

({
    close: function(cmp) {
        cmp.get('v.openButton').set('v.disabled', false);
        cmp.set('v.openButton', null);
        cmp.destroy();
    },

    showToast: function(message, type, title) {
        var resultsToast = $A.get("e.force:showToast");
        resultsToast.setParams({
            "title": title,
            "message": message,
            "type" : type
        });
        resultsToast.fire();
    },

    showErrorSummary: function(cmp, message, returnValuesMap) {
        cmp.set("v.showError", true);
        cmp.set("v.errorMessage", message);
        if (returnValuesMap != null) {
            var details = '';
            Object.keys(returnValuesMap).forEach(function(key) {
                console.log(key, returnValuesMap[key]);
                details += '<li>' + returnValuesMap[key] + '</li>';
            });
            cmp.set("v.errorDetails", details);
        }
    },

    submitRecordTransaction: function(cmp) {
        cmp.set('v.spinner', true);

        var action = cmp.get('c.recordTransaction');

        var myRecordTransactionParameters = {
            loyaltyNumber: cmp.get('v.loyalty.external_customer_id'),
            email: cmp.get('v.loyalty.email'),
            transactionOrigin: cmp.get('v.TransactionOriginValue'),
            orderNumber: cmp.find("OrderNumber").get("v.value"),
            transactionNumber: cmp.find("TransactionNumber").get("v.value"),
            transactionDate: cmp.find("TransactionDate").get("v.value"),
            transactionSubtotal: cmp.find("TransactionSubtotal").get("v.value"),
            exclusionSubtotal: cmp.find("SubtotalExcludedItems").get("v.value")
        };

        action.setParams({
            "params": myRecordTransactionParameters
        });

        cmp.set("v.showError", false);

        action.setCallback(this, function (response) {
            cmp.set('v.spinner', false);
            var state = response.getState();

            if (cmp.isValid() && state === "SUCCESS") {
                var result = response.getReturnValue();

                if (typeof result !== undefined && result != null) {
                    if (result.isSuccess) {
                        this.showToast(result.message, 'success', 'Transaction Submitted');
                        this.close(cmp);
                    }
                    else {
                        this.showErrorSummary(cmp, result.message, result.returnValuesMap);
                    }
                }
                else {
                    this.showErrorSummary(cmp, 'Connection Error', null);
                }
            }
        });
        $A.enqueueAction(action);
    },
});