/**
 * Created by ragrawal on 7/5/2019.
 */
({
    /**
     * @description         Show toast with the given message, type, and title
     * @author              Rajat Agrawal, Traction on Demand
     * @param message       Message to display
     * @param type          Type of toast to display
     * @param title         Title of Toast message
     */
    showToast : function(message, type, title) {
        var resultsToast = $A.get("e.force:showToast");
        resultsToast.setParams({
            "title": title,
            "message": message,
            "type" : type
        });
        resultsToast.fire();
    },

    searchByOrderNumber : function(component, event, helper, orderNo) {
        var businessUnit = '';

        var action = component.get("c.getOrderDetails");
        action.setParams({
            "orderNo": orderNo,
            "businessUnit": businessUnit
        });

        action.setCallback(this, function (response) {
            var state = response.getState();

            if (component.isValid() && state === "SUCCESS") {

                var result =  response.getReturnValue();

                if (result == null) {
                    component.set("v.errorMsg", "Connection Error");
                } else {
                    if(result.isSuccess) {
                        if(!$A.util.isEmpty(result.returnValuesMap['orderDetails'])) {
                            component.set("v.order", result.returnValuesMap['orderDetails']);
                            helper.setUnresolvedHolds(component, event, helper);
                        }
                    } else {
                        component.set("v.isError", true);
                        component.set("v.errorMsg", result.message);
                    }
                }
            }
            else {
                console.log("failed with state: " + state);
            }
        });

        $A.enqueueAction(action);
    },

    setUnresolvedHolds : function(component, event, helper) {
        var order = component.get("v.order");
        var hasUnresolvedHolds = false;

        if (order && order.OrderHoldTypes && order.OrderHoldTypes.OrderHoldType) {
            console.log('order.OrderHoldTypes.OrderHoldType',order.OrderHoldTypes.OrderHoldType);
            var i;
            for (i = 0; i < order.OrderHoldTypes.OrderHoldType.length; i++) {
                console.log('order.OrderHoldTypes.OrderHoldType[i]',order.OrderHoldTypes.OrderHoldType[i]);
                if (order.OrderHoldTypes.OrderHoldType[i].StatusDescription !== "Resolved") {
                    hasUnresolvedHolds = true;
                    break;
                }
            }
        }
        component.set("v.hasUnresolvedHolds", hasUnresolvedHolds);
    }
})