/**
 * Created by jhoran on 7/17/2019.
 */
({



    doInit: function(component, event, helper) {
        helper.setDisabled(component);
    },

    handleOpenModal: function(component, event, helper) {
        component.set("v.isModalOpen", true);
    },

    handleCloseModal: function(component, event, helper) {
        helper.closeModal(component);
    },

    handleCancelOrder: function(component, event, helper) {
        component.set('v.isLoading', true);
        helper.cancelOrderApex(component, helper);
    }
})