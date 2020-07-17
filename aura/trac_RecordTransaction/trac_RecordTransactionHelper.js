/**
 * Created by gtorres on 6/5/2020.
 */

({
    validateForm: function(cmp) {
        var result = true;
        var transactionSubtotalInput = cmp.find("TransactionSubtotal");
        var exclusionSubtotalInput = cmp.find("SubtotalExcludedItems");
        var transactionSubtotal = transactionSubtotalInput.get("v.value").trim();
        var exclusionSubtotal = exclusionSubtotalInput.get("v.value").trim();
        var errorValuesMap = {};
        if (isNaN(transactionSubtotal) || transactionSubtotal=='' || !transactionSubtotalInput.checkValidity() ) {
            result = false;
            errorValuesMap['TransactionSubtotal'] = 'Transaction Subtotal is invalid';
        }
        if (isNaN(exclusionSubtotal) || exclusionSubtotal=='' || !exclusionSubtotalInput.checkValidity()) {
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

    showToast: function(message, type, title, duration) {

        var resultsToast = $A.get("e.force:showToast");
        resultsToast.setParams({
            "title": title,
            "message": message,
            "type" : type
        });


        if (duration != null) {
            resultsToast.setParams({
                "duration": duration
            });
        }
        resultsToast.fire();
    },


    showErrorSummary: function(cmp, message, returnValuesMap) {
        cmp.set("v.showError", true);
        cmp.set("v.errorMessage", message);
        if (returnValuesMap != null) {
            var details = '';
            Object.keys(returnValuesMap).forEach(function(key) {

                if(key != 'validForm') {
                    details += '<li>' + returnValuesMap[key] + '</li>';
                }

            });
            cmp.set("v.errorDetails", details);
        }
    },
    submitRecordTransaction: function(cmp, helper) {
        cmp.set('v.spinner', true);


        var action = cmp.get('c.recordTransaction');
        var transactionOrigin =  cmp.get('v.TransactionOriginValue');
        var orderNumber = '';
        var transactionNumber = '';
        var transactionDate = cmp.get("v.date");


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
            exclusionSubtotal: exclusionSubtotal,
            totalEarn: cmp.get('v.totalEarnValue')


        };
        action.setParams({
            "params": myRecordTransactionParameters,
            "dateToCompare": null
        });
        cmp.set("v.showError", false);

        action.setCallback(this, function (response) {
            cmp.set('v.spinner', false);
            var result = response.getReturnValue();

            if (!helper.isMerkleErrorHandled(cmp, cmp.getReference("c.handleSubmit"), response) ) {
                if(result.isSuccess && result.returnValuesMap['body']['success']) {
                    this.proceedWithSuccessfulTransaction(cmp, transactionSubtotal, exclusionSubtotal, result);
                }
                else if (result.returnValuesMap['validForm'] !=null && !result.returnValuesMap['validForm'])  {
                    this.showErrorSummary(cmp, result.message, result.returnValuesMap);
                }
            }


        });
        $A.enqueueAction(action);
    },
    proceedWithSuccessfulTransaction: function(cmp, transactionSubtotal, exclusionSubtotal, result) {


        var appEvent = $A.get("e.c:trac_LoyaltyRefreshEvent");
        appEvent.setParams({"LoyaltyNumber" : cmp.get('v.loyalty.external_customer_id') });
        var totalSpent = parseFloat(transactionSubtotal) - parseFloat(exclusionSubtotal);
        appEvent.setParams({"LoyaltyNumber" : cmp.get('v.loyalty.external_customer_id') });
        var actions_needed_for_next_tier = cmp.get('v.loyalty.actions_needed_for_next_tier');
        var tierUpgrade = false;
        if (!isNaN(totalSpent) && !isNaN(actions_needed_for_next_tier)) {
          tierUpgrade = totalSpent >= actions_needed_for_next_tier;
        }
        if (tierUpgrade){
          this.showToast(result.message, 'success', 'Transaction Submitted', 8000);
          this.showToast('The new account tier might take a couple of minutes to be processed', 'info', 'Account Tier', 8000);
        }
        else {
          this.showToast(result.message, 'success', 'Transaction Submitted');
        }

        appEvent.fire();
        this.close(cmp);
    },

    normalize: function(number) {
        if (!number) return "";
        return number.replace(/[^\d]/g, "");
    }
});