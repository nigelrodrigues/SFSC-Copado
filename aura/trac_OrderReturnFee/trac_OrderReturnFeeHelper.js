/**
 * Created by Jeremy on 3/17/2020.
 */

({
    refundUpdateApex : function(component, helper) {

        component.set('v.isLoading', true);

        let order = component.get("v.order");
        let refundShippingCharge = component.get("v.refundShippingCharge");
        let chargePrepaidShippingLabel = component.get("v.chargePrepaidShippingLabel");

        let apexAction = component.get("c.updateOrderReturnFee");

        apexAction.setParams({
            "enterpriseCode" : order.EnterpriseCode,
            "orderNumber" : order.OrderNo,
            "refundShippingCharge" : refundShippingCharge,
            "chargePrepaidShippingLabel" : chargePrepaidShippingLabel
        });

        apexAction.setCallback(this, function(response) {
            let state = response.getState();

            if (component.isValid() && state === "SUCCESS") {
                let result =  response.getReturnValue();

                if (result == null) {
                    component.set("v.errorMsg", "Connection Error");
                } else {
                    if(result.isSuccess) {
                        component.set("v.isError", false);
                        helper.showToast("Refund Options Updated", "success", "Success");
                        $A.get("e.c:trac_RefreshOrderEvent").fire();
                        component.set("v.isModalOpen", false);
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
    },

    showToast: function(message, type, title) {
        let resultsToast = $A.get("e.force:showToast");
        resultsToast.setParams({
            "title": title,
            "message": message,
            "type" : type
        });
        resultsToast.fire();
    }
});