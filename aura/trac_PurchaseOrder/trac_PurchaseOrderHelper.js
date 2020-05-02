/**
 * Created by asolanki on 3/27/2020.
 */

({
    fetchOrderDetails : function (component,event,helper) {
        var apexAction = component.get("c.getPurchaseOrderLine");

        var order = component.get("v.order");
        var businessUnit = component.get("v.businessUnit");

        apexAction.setParams({
            "businessUnit": businessUnit,
            "orderNumber": (order) ? order.OrderNo : null,
            "DocumentType": (order) ? order.DocumentType : null
        });

        apexAction.setCallback(this, function (response) {
            var state = response.getState();

            if (component.isValid() && state === "SUCCESS") {
                var result = response.getReturnValue();

                if (result == null) {
                    component.set("v.errorMsg", "Connection Error");
                } else {
                    if (result.isSuccess) {
                        if (result.returnValuesMap ['orderResponse'] && result.returnValuesMap ['orderResponse'].Order && result.returnValuesMap ['orderResponse'].Order.length > 0) {
                            component.set("v.purchaseOrder", result.returnValuesMap['orderResponse']);
                        } else {
                            component.set("v.noOrderFound", true);
                        }
                    } else {
                        component.set("v.isError", true);
                        component.set("v.errorMsg", result.message);
                    }
                }
            } else {
                console.log("failed with state: " + state);
            }

            var spinner = component.find("spinner-wait");
            $A.util.removeClass(spinner, "slds-show");
            $A.util.addClass(spinner, "slds-hide");
        });

        $A.enqueueAction(apexAction);
    }
});