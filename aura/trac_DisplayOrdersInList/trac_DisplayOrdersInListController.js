/**
 * Created by ragrawal on 7/3/2019.
 */
({
    showOrderDetails : function(component, event, helper, orderNo) {
        if(component.get("v.showOrderDetails")){
            component.set("v.actualOrder", null);
            component.set("v.showOrderDetails", false);
            return;
        }
        var businessUnit = component.get("v.businessUnit");
        var orderNo = event.getSource().get("v.value");
        var caseRecord = component.get("v.caseRecord");
        var action = component.get("c.getOrderDetails");
        action.setParams({
            "businessUnit": businessUnit,
            "orderNo": orderNo
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {

                var result =  response.getReturnValue();

                if (result == null) {
                    helper.showToast('Connection Error', "error", 'Error');
                } else {
                    if(result.isSuccess) {
                        if(!$A.util.isEmpty(result.returnValuesMap['orderDetails'])) {
                            component.set("v.actualOrder", result.returnValuesMap['orderDetails']);
                            component.set("v.showOrderDetails", true);
                        }
                    } else {
                        helper.showToast(result.message, "error", 'Error');
                    }
                }
            }
            else {
                console.log("failed with state: " + state);
            }
        });

        $A.enqueueAction(action);
    },

    handleImport : function (component, event, helper) {
        var action = component.get("c.updateCase");
        var caseRecord = component.get("v.caseRecord");
        var order = component.get("v.order");

        action.setParams({
            "caseId": caseRecord.Id,
            "orderNo": order.OrderNo
        });

        action.setCallback(this, function (response) {
            var state = response.getState();

            if (component.isValid() && state === "SUCCESS") {
                $A.get('e.force:refreshView').fire();
            }
            else {
                var message = action.getError()[0].message;
                helper.showToast(message, "error", 'Error');
            }
        });

        $A.enqueueAction(action);
    }
})