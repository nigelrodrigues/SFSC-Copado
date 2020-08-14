/**
 * Created by akong on 8/13/2020.
 */

({
    handleOpenModal: function(component, event, helper) {
        component.set("v.isModalOpen", true);
    },

    handleCloseModal: function(component, event, helper) {
        helper.closeModal(component);
    },

    handleAddNote: function(component, event, helper) {
        component.set('v.isLoading', true);
        helper.applyHoldAndAddNote(component, helper);
    }
});