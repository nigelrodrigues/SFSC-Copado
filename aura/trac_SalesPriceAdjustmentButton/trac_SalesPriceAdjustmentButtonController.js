/**
 * Created by jhoran on 3/2/2020.
 */
({
    handleOpenModal: function(component, event, helper) {
        component.set("v.isModalOpen", true);
    },

    handleCloseModal: function(component, event, helper) {
        component.set("v.isModalOpen", false);
    },
    openOldSpa: function(component, event, helper) {
        window.open('http://jxn-ms-ccwebx1/SPA/Input.aspx', '_blank');
    }
})