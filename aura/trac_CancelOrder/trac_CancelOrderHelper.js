/**
 * Created by jhoran on 7/17/2019.
 */
({
    cancelOrderApex : function(component, helper) {

        component.set('v.isLoading', true);

        var cancelReason = component.get("v.cancelReason");
        var order = component.get("v.order");
        var orderLineItem = component.get("v.orderLineItem");
        var caseRecord = component.get("v.caseRecord");
        var cancelReasonCode = component.get("v.cancelReasonCode");
        var quantityToCancel = component.get("v.quantityToCancel");
        var businessUnit = component.get("v.businessUnit");

        var apexAction = component.get("c.cancelOrder");

        apexAction.setParams({
            "caseRecord" : caseRecord,
            "businessUnit" : businessUnit,
            "orderNumber" : helper.getOrderNumber(order),
            "primeLineNumber" : helper.getPrimeLineNumber(orderLineItem),
            "cancelReason" : cancelReason,
            "cancelReasonCode" : cancelReasonCode,
            "quantityToCancel" : quantityToCancel
        });

        apexAction.setCallback(this, function(response) {
            var state = response.getState();
            component.set("v.isLoading", false);

            if (component.isValid() && state === "SUCCESS") {
                var result =  response.getReturnValue();

                if (result == null) {
                    component.set("v.errorMsg", "Connection Error");
                } else {
                    if(result.isSuccess) {
                        component.set("v.isError", false);
                        helper.showToast("Order Cancelled", "success", "Success");
                        helper.closeModal(component);
                        $A.get("e.c:trac_RefreshOrderEvent").fire();
                    } else {
                        component.set("v.isError", true);
                        component.set("v.errorMsg", result.message);
                    }
                }
            } else {
                console.log("failed with state: " + state);
            }
        });

        $A.enqueueAction(apexAction);
    },

    getOrderNumber: function(order) {
        var orderNumber;

        if (order) {
            orderNumber = order.OrderNo;
        }

        return orderNumber;
    },

    getPrimeLineNumber: function(orderLineItem) {
        var primeLineNumber;

        if (orderLineItem) {
            primeLineNumber = orderLineItem.PrimeLineNo;
        }

        return primeLineNumber;
    },

    closeModal: function(component) {
        component.set("v.isModalOpen", false);
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

    /*
    Modified by Nigel Rodrigues, Traction on Demand, 10-Jan-2019
     */
    setDisabled: function(component) {


        var order = component.get("v.order");
        var orderLineItem = component.get("v.orderLineItem");

       /* var disabled = false;
        if (orderLineItem && orderLineItem.Status !== 'Created') {
            disabled = true;
        }

        if (!orderLineItem && order.Status !== 'Created') {
            disabled = true;
        }*/
       var disabled = true;
       if( orderLineItem &&
           (
               orderLineItem.Status === 'Released' ||
               orderLineItem.Status === 'Backordered' ||
               orderLineItem.Status === 'Hold Credit' ||
               orderLineItem.Status === 'Hold Risk' ||
               orderLineItem.Status === 'General Error' ||
               orderLineItem.Status === 'Created' ||
               orderLineItem.Status === 'Open' ||
               orderLineItem.Status === 'Ready For Backroom Pick' ||
               orderLineItem.Status === 'Scheduled'
           )
       )
       {
           disabled = false;
       }

        if ( !orderLineItem &&
            (
                order.Status === 'Released' ||
                order.Status === 'Backordered' ||
                order.Status === 'Hold Credit' ||
                order.Status === 'Hold Risk' ||
                order.Status === 'General Error' ||
                order.Status === 'Created' ||
                order.Status === 'Open' ||
                order.Status === 'Ready For Backroom Pick' ||
                order.Status === 'Scheduled'
            )
        )
        {
            disabled = false;
        }
        var businessUnit = component.get("v.businessUnit");
        if(businessUnit == 'Off 5th' || businessUnit == 'Saks') {
            if (!orderLineItem && order.Status === 'Released') {
                disabled = true;
            }
            if (orderLineItem && orderLineItem.Status === 'Released') {
                disabled = true;
            }
        }
        component.set("v.disabled", disabled);
    },

    getQuantityOptions: function(component) {
        var orderLine = component.get("v.orderLineItem");
        if (orderLine) {
            var quantity = orderLine.OrderedQty;

            if (quantity) {
                var options = [];
                for (var i = quantity; i > 0; i--) {
                    options.push({'label': String(i), 'value': String(i)});
                }
                component.set("v.quantityOptions", options);
                component.set("v.quantityToCancel", quantity);
            }
        }
    }
})