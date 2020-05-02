/**
 * Created by Jeremy on 3/17/2020.
 */

({
    handleOpenModal: function(component, event, helper) {
        component.set("v.isModalOpen", true);
    },

    handleCloseModal: function(component, event, helper) {
        component.set("v.isModalOpen", false);
    },

    handleRefundUpdate: function(component, event, helper) {
        component.set('v.isLoading', true);
        helper.refundUpdateApex(component, helper);
    }
});