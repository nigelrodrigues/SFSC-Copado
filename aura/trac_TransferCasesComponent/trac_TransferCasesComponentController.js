({
    goBack: function (component, event, helper) {
        window.history.back();
    },

    handleChange: function (component, event, helper) {
        var childComp = component.find('ownerLookup');
        childComp.callChild();
        component.set("v.icon", "standard:" + component.find('select').get('v.value'));
    },

    handleComponentEvent: function (component, event, helper) {
        var selectedRec = event.getParam("recordByEvent");
        component.set("v.OwnerId", selectedRec.Id);
    },

    handleConfirm: function (component, event, helper) {
        helper.updateOwner(component, event, helper);
    }
})