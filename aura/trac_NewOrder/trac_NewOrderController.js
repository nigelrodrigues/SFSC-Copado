/**
 * Created by jhoran on 7/4/2019.
 */
({
    newOrder: function(component, event, helper) {
        helper.checkBusinessUnit(component, event, helper);
    },

    handleLoad: function(component, event, helper) {
        component.set('v.isLoading', false);
    },

    handleSubmit: function(component, event, helper) {
        component.set('v.isLoading', true);
        helper.validateForm(component, event, helper);
    },

    handleError: function(component, event, helper) {
        component.set('v.showSpinner', false);
    },

    handleSuccess: function(component, event, helper) {
        component.set('v.isLoading', true);

        var response = event.getParam('response');
        var contactId = response.id;

        helper.createNewOrderApex(component, helper, contactId);
        component.set('v.showModal', false);
    },

    closeModel: function(component, event, helper) {
        component.set("v.showModal", false);
    }
})