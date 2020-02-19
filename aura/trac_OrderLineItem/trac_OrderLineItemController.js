/**
 * Created by ragrawal on 7/3/2019.
 */
({
    openModel: function(component, event, helper) {
        component.set("v.isModalOpen", true);
    },

    closeModel: function(component, event, helper) {
        component.set("v.isModalOpen", false);
    },
})