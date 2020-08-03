/**
 * Created by asolanki on 3/31/2020.
 */
({
    onDelete: function (component, event, helper) {
        let paymentIndex = event.getSource().get("v.value");

        var compEvent = component.getEvent("trac_NewPaymentMethodDeleteEvent");
        compEvent.setParams({"paymentMethodIndex": paymentIndex});
        compEvent.fire();
    },

    onEdit: function (component, event, helper) {
        let paymentMethodVal = event.getSource().get("v.value");
        var appEvent = $A.get("e.c:trac_NewPaymentMethodEditEvent");
        appEvent.setParams({
            "paymentMethod": paymentMethodVal,
            "indexVal": event.getSource().get("v.name")
        });
        appEvent.fire();
    }
})