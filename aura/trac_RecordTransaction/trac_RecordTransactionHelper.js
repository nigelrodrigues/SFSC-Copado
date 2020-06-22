/**
 * Created by gtorres on 6/5/2020.
 */

({
    validateForm: function(cmp) {
        var result = true;
        var transactionSubtotal = cmp.find("TransactionSubtotal").get("v.value").trim();
        var exclusionSubtotal = cmp.find("SubtotalExcludedItems").get("v.value").trim();

        var errorValuesMap = {};
        if (isNaN(transactionSubtotal) || transactionSubtotal=='') {
            result = false;
            errorValuesMap['TransactionSubtotal'] = 'Transaction Subtotal is invalid';
        }
        if (isNaN(exclusionSubtotal) || exclusionSubtotal=='') {
            result = false;
            errorValuesMap['SubtotalExcludedItems'] = 'Subtotal of Excluded Items is invalid';
        }

        if (!result) {
            this.showErrorSummary(cmp, 'You have errors in your form submission.', errorValuesMap);
        }
        return result;
    },

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
        var transactionOrigin =  cmp.get('v.TransactionOriginValue');
        var orderNumber = '';
        var transactionNumber = '';
        var transactionDate = cmp.find("TransactionDate").get("v.value");
        var transactionSubtotal = cmp.find("TransactionSubtotal").get("v.value").trim();
        var exclusionSubtotal = cmp.find("SubtotalExcludedItems").get("v.value").trim();

        if (transactionOrigin === 'Website') {
            orderNumber = cmp.find("OrderNumber").get("v.value");
            transactionNumber = cmp.find("TransactionNumber").get("v.value");
        }
        else {
            transactionNumber = cmp.find("TransactionNumberMhfStore").get("v.value") +
                                cmp.find("StoreNumberMhfStore").get("v.value") +
                                cmp.find("TerminalNumberMhfStore").get("v.value");
        }
        var myRecordTransactionParameters = {
            caseRecordId: cmp.get('v.caseRecordId'),
            loyaltyNumber: cmp.get('v.loyalty.external_customer_id'),
            email: cmp.get('v.loyalty.email'),
            transactionOrigin: transactionOrigin,
            orderNumber: orderNumber,
            transactionNumber: transactionNumber,
            transactionDate: transactionDate,
            transactionSubtotal: transactionSubtotal,
            exclusionSubtotal: exclusionSubtotal
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
                        var appEvent = $A.get("e.c:trac_LoyaltyRefreshEvent");
                        appEvent.setParams({"LoyaltyNumber" : cmp.get('v.loyalty.external_customer_id') });
                        var totalSpent = parseFloat(transactionSubtotal) - parseFloat(exclusionSubtotal);
                        appEvent.setParams({"LoyaltyNumber" : cmp.get('v.loyalty.external_customer_id') });
                        var actions_needed_for_next_tier = cmp.get('v.loyalty.actions_needed_for_next_tier');
                        var extendendDelay = false;
                        if (!isNaN(totalSpent) && !isNaN(actions_needed_for_next_tier)) {
                            extendendDelay = totalSpent >= actions_needed_for_next_tier;
                        }
                        if (extendendDelay) {
                            cmp.set('v.spinner', true);
                            setTimeout(function() {
                                cmp.set('v.spinner', false);
                                appEvent.fire();
                                this.close(cmp);
                            },10000);
                        }
                        else {
                            appEvent.fire();
                            this.close(cmp);
                        }
                    }
                    else {
                        this.showErrorSummary(cmp, result.message, result.returnValuesMap);
                    }
                }
                else {
                    this.showErrorSummary(cmp, 'Connection Error', null);
                }
            }
            else {

            }
        });
        $A.enqueueAction(action);
    },
});