/**
 * Created by jhoran on 7/5/2019.
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
        helper.addNoteApex(component, helper);
    }
})