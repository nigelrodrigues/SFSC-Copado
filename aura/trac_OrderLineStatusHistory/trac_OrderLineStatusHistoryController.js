/**
 * Created by jhoran on 2/4/2020.
 */
({
    doInit: function (component) {
        var apexAction = component.get("c.getLineHistory");

        var order = component.get("v.order");
        var orderLineItem = component.get("v.orderLineItem");
        var businessUnit = component.get("v.businessUnit");

        apexAction.setParams({
            "businessUnit" : businessUnit,
            "orderNumber" : (order) ? order.OrderNo : null,
            "lineItemNumber" : (orderLineItem) ? orderLineItem.PrimeLineNo : null
        });

        apexAction.setCallback(this, function(response) {
            var state = response.getState();

            if (component.isValid() && state === "SUCCESS") {
                var result =  response.getReturnValue();

                if (result == null) {
                    component.set("v.errorMsg", "Connection Error");
                } else {
                    if(result.isSuccess) {
                        component.set("v.orderLineHistory", result.returnValuesMap['lineStatusHistory'].LineStatusHistory);
                    } else {
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
    }
})