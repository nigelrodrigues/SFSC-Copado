/**
 * Created by jhoran on 1/31/2020.
 */
({
    handleInit: function (component, event, helper) {

        helper.calculateTotals(component, event, helper);
    },

    handleLoad: function (component, event, helper) {
        component.set("v.isLoading", false);
    },

    handleSubmit: function (component, event, helper) {
        component.set("v.isLoading", false);
    },

    handleOpenModal: function (component, event, helper) {
        component.set("v.isModalOpen", true);
    },

    handlePaymentChange: function (component, event, helper) {

    },

    handleCreditChange: function (component, event, helper) {

    },

    handleCloseModel: function (component, event, helper) {
        component.set("v.isModalOpen", false);
    },

    handlePaymentAddedEvent: function (component, event, helper) {
        var paymentMethod = event.getParam("paymentMethod");
        var mode = event.getParam("mode");
        var newPaymentMethods = component.get("v.newPaymentMethods");
        if (mode) {
            newPaymentMethods.push(paymentMethod);
        } else {
            let index = event.getParam("indexVar");
            newPaymentMethods.splice(index, 1);
            newPaymentMethods.push(paymentMethod);
        }

        component.set("v.newPaymentMethods", newPaymentMethods);
        helper.calculateTotals(component, event, helper);
    },

    handleDeletePaymentEvent: function (component, event, helper) {
        var paymentMethods = component.get("v.newPaymentMethods");
        var index = event.getParam("paymentMethodIndex");
        paymentMethods.splice(index, 1);

        component.set("v.newPaymentMethods", paymentMethods);
        helper.calculateTotals(component, event, helper);
    },

    handleUpdatePaymentMethods: function (component, event, helper) {
        component.set("v.isLoading", true);
        component.set("v.isSpinner", true);
        helper.updatePaymentMethodsApex(component, event, helper);
    }
})