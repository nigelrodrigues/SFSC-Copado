/**
 * Created by ragrawal on 7/3/2019.
 */
({
    doInit : function (component, event, helper) {
        if(component.get("v.callOrderDetailAPI")){
            var orderNo = component.get("v.order").OrderNo;
            helper.searchByOrderNumber(component, event, helper, orderNo);
        }
        helper.setUnresolvedHolds(component, event, helper);
    },

    showOrderLineItems : function (component, event, helper) {
        if(component.get("v.showLineItem")){
            component.set("v.showLineItem", false);
        }
        else{
            component.set("v.showLineItem", true);
        }
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
                console.log("failed with state: " + state);
            }
        });

        $A.enqueueAction(action);
    }
})