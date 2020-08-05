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
    showToast: function (message, type, title) {
        var resultsToast = $A.get("e.force:showToast");
        resultsToast.setParams({
            "title": title,
            "message": message,
            "type": type
        });
        resultsToast.fire();
    },
    setUnresolvedHolds: function (component, event, helper) {
        var order = component.get("v.order");
        var hasUnresolvedHolds = false;
        if (order && order.OrderHoldTypes && order.OrderHoldTypes.OrderHoldType) {
            var i;
            for (i = 0; i < order.OrderHoldTypes.OrderHoldType.length; i++) {
                if (order.OrderHoldTypes.OrderHoldType[i].StatusDescription !== "Resolved") {
                    hasUnresolvedHolds = true;
                    break;
                }
            }
        }
        component.set("v.hasUnresolvedHolds", hasUnresolvedHolds);
    },
    spaBusinessUnit: function (component, event, helper) {
        var order = component.get("v.order");
        let validSpaBusinessUnit = false;
        if(order && order.EnterpriseCode && (order.EnterpriseCode === ('SAKS') || order.EnterpriseCode === ('OFF5'))) {
            validSpaBusinessUnit = true;
        }
        component.set("v.validSpaBusinessUnit", validSpaBusinessUnit);
    },


    setBody : function (component, event, helper, newCmp, status, errorMessage)
    {
        if (status === "SUCCESS")
        {
            let body = component.get("v.body");
            body.push(newCmp);
            component.set("v.body", body);
        }
        else if (status === "INCOMPLETE")
        {
            console.log("No response from server or client is offline.")
        }
        else if (status === "ERROR")
        {
            console.log("Error: " + errorMessage);
        }
    },
    setChannel : function(component, event, helper, order) {
        var action = component.get("c.getOrderNumberRange");
        component.set("v.isLoading", true);
        action.setParams({
            "label": 'Digital Blue Martini'
        });
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var rangeStr = response.getReturnValue();
                var ranges = rangeStr.split("-");
                if( helper.isBetweenRange(rangeStr, order.OrderNo) ) {
                    component.set("v.channel", "Digital Blue Martini");
                } else {
                    component.set("v.channel", "Digital");
                }
            }
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    },
    setCancelabilityMap: function(component, event, helper) {
        console.log('Inside setCancelabilityMap');
        var businessUnit = component.get('v.businessUnit');
        var action = component.get("c.getOrderLineCancelabilityByStatus");
        action.setParams({
            "businessUnit": businessUnit
        });
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                console.log('response.getReturnValue(): ', response.getReturnValue());
                component.set('v.cancelabilityMap', response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    isBetweenRange : function (rangeStr, number) {
        var ranges = rangeStr.split("-");
        return (ranges[0] <= number && ranges[1] >= number ) ? true : false
    }
})