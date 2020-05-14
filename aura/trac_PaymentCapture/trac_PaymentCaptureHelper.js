/**
 * Created by jhoran on 1/31/2020.
 */
({
    updatePaymentMethodsApex : function(component, event, helper) {

        var apexAction = component.get("c.updatePaymentMethods");

        var order = component.get("v.order");
        var newPaymentMethods = component.get("v.newPaymentMethods");

        apexAction.setParams({
            "enterpriseCode": order.EnterpriseCode,
            "orderNumber": order.OrderNo,
            "paymentMethodJson": JSON.stringify(newPaymentMethods)
        });

        apexAction.setCallback(this, function(response) {
            var state = response.getState();

            if (component.isValid() && state === "SUCCESS") {
                var result =  response.getReturnValue();
                if (result == null) {
                    component.set("v.isError", true);
                    component.set("v.errorMsg", "Connection Error");
                } else {

                    if(result.isSuccess) {
                        let returnValues  = result.returnValuesMap['orderPaymentResponse'].orderPayResponse;
                        let isSuccess = result.returnValuesMap['orderPaymentResponse'].isSuccess;


                        if(returnValues && isSuccess ){
                            helper.showToast("Payment Updated Successfully", "success","Success");
                            $A.get("e.c:trac_RefreshOrderEvent").fire();
                            component.set("v.isModalOpen", false);
                        }else if(returnValues && !isSuccess){
                            let errorComplied = '';


                            if(returnValues.PaymentMethods && returnValues.PaymentMethods.PaymentMethod){
                                for(let i=0; i<returnValues.PaymentMethods.PaymentMethod.length; i++){
                                    if(returnValues.PaymentMethods.PaymentMethod[i].ResponseCode){
                                        errorComplied = errorComplied + 'Payment Method ' + (i+1) + ' - ' + returnValues.PaymentMethods.PaymentMethod[i].ResponseCode;
                                    }
                                }

                                if(returnValues.PaymentMethods.PaymentMethod[i].AuthReturnMessage != 'Approved') {
                                    errorComplied = errorComplied + ' Please confirm the payment details or try a different payment method.';
                                }
                            }

                            if(errorComplied){
                                component.set("v.isError", true);
                                component.set("v.errorMsg", errorComplied);
                            }else{
                                component.set("v.isError", true);
                                component.set("v.errorMsg", "Payment Update Failed - " + (returnValues.FraudCheckResponseCode ? returnValues.FraudCheckResponseCode : "") + " " + (returnValues.FraudCheckResponseMessages ? returnValues.FraudCheckResponseMessages.FraudCheckResponseMessage[0].Text : returnValues.ResposneMessage));
                            }
                        }
                    } else {
                        component.set("v.isLoading", false);
                        component.set("v.isError", true);
                       
                        component.set("v.errorMsg", result.message);
                    }
                }
            } else {
                console.log("failed with state: " + state);
            }

            component.set("v.isLoading", false);
        });

        $A.enqueueAction(apexAction);
    },

    showToast : function(message, type, title) {
        var resultsToast = $A.get("e.force:showToast");
        resultsToast.setParams({
            "title": title,
            "message": message,
            "type" : type
        });
        resultsToast.fire();
    },

    calculateTotals : function(component, event, helper) {

        var existingPaymentValues = component.get('v.order.PaymentMethods.PaymentMethod');
        console.log('existingPaymentValues');
        console.log(existingPaymentValues);

        var paymentList = [];
        if(existingPaymentValues) {
            for (var payment of existingPaymentValues)
                paymentList.push(payment);

            var allExistingPayments = 0.00;

            for (var i = 0; i < paymentList.length; i++) {
                allExistingPayments += parseFloat(paymentList[i].TotalCharged);
            }
        }

        var newPaymentMethods = component.get("v.newPaymentMethods");
        var sumOfPayments = 0.00;
        if (newPaymentMethods && newPaymentMethods.length > 0) {
            sumOfPayments = helper.sumPayment(newPaymentMethods);
        }

        var order = component.get("v.order");
        if (order && order.PriceInfo && order.PriceInfo.TotalAmount) {
            var orderAmount = parseFloat(order.PriceInfo.TotalAmount);

            var paymentRemaining = orderAmount - sumOfPayments - allExistingPayments;
            if(paymentRemaining < 0 )
                paymentRemaining = 0;
            component.set("v.paymentRemaining", paymentRemaining);
            var addPaymentCmp = component.find('trac_AddPaymentMethodCmp');
            if(addPaymentCmp){
                addPaymentCmp.paymentRemainingUpdateCall(paymentRemaining);
            }
        }
    },

    sumPayment : function(newPaymentMethods) {
        var totalValue = 0.00;

        for (var i = 0; i < newPaymentMethods.length; i++) {
            if (newPaymentMethods && newPaymentMethods[i] && newPaymentMethods[i].RequestAmount) {
                totalValue += parseFloat(newPaymentMethods[i].RequestAmount);
            }
        }

        return totalValue;
    }
})