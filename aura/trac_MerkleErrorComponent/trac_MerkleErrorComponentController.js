({
    init: function(component, event, helper) {
    },

    errorClose : function(component, event, helper) {
        component.set("v.isMerkleError", false);
    },

    retry : function(component, event, helper) {
        component.set("v.isMerkleError", false);
    },
});