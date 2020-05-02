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
            console.log('order.OrderHoldTypes.OrderHoldType', order.OrderHoldTypes.OrderHoldType);
            var i;
            for (i = 0; i < order.OrderHoldTypes.OrderHoldType.length; i++) {
                console.log('order.OrderHoldTypes.OrderHoldType[i]', order.OrderHoldTypes.OrderHoldType[i]);
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
    }
})