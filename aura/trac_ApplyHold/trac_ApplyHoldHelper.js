/**
 * Created by akong on 8/13/2020.
 */

({
    applyHoldAndAddNote : function(component, helper) {


        component.set('v.isLoading', true);

        var notes = component.get("v.notes");
        var order = component.get("v.order");
        //var orderLineItem = component.get("v.orderLineItem");
        var caseRecord = component.get("v.caseRecord");
        var businessUnit = component.get("v.businessUnit");

        var apexAction = component.get("c.applyReviewNotesHold");

        apexAction.setParams({
            "businessUnit" : businessUnit,
            "orderNumber" : helper.getOrderNumber(order),
            //"primeLineNumber" : helper.getPrimeLineNumber(orderLineItem),
            "notes" : notes
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
                        helper.showToast("Note added and order hold applied", "success", "Success");
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

    // getPrimeLineNumber: function(orderLineItem) {
    //     var primeLineNumber;
    //
    //     if (orderLineItem) {
    //         primeLineNumber = orderLineItem.PrimeLineNo;
    //     }
    //
    //     return primeLineNumber;
    // },

    closeModal: function(component) {
        component.set("v.isModalOpen", false);
    },

    showToast : function(message, type, title) {
        var resultsToast = $A.get("e.force:showToast");
        resultsToast.setParams({
            "title": title,
            "message": message,
            "type" : type
        });
        resultsToast.fire();
    }
});