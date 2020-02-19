/**
 * Created by Jeremy on 12/24/2018.
 */
({
    init: function(component, event, helper) {
        component.set('v.isLoading', false);
    },

    errorClose : function(component, event, helper) {
        component.set("v.isError", false);
    }
})