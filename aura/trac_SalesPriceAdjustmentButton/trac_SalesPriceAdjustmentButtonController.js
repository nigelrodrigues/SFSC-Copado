/**
 * Created by jhoran on 3/2/2020.
 */
({
    handleOpenModal: function(component, event, helper) {
        component.set("v.isModalOpen", true);
    },

    handleCloseModal: function(component, event, helper) {
        component.set("v.isModalOpen", false);
    }
})