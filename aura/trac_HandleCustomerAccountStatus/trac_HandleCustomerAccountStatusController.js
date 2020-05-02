/**
 * Created by nrodrigues on 1/28/2020.
 */

({
    displayAccountStatus : function(component, event, helper)
    {
        component.set("v.isLoading", true);
        helper.getAccountStatus(component,event,helper);
        component.set("v.showModal", true);

    },

    updateAccount : function(component, event, helper)
    {
        var selectedStatus = component.find("customerStatus").get("v.value");
        console.log('Selected status: ' + selectedStatus);
        helper.updateCustomerAccount(component, helper, event);
    },

    closeModal : function(component, event, helper){
        component.set("v.showModal", false);
        component.set("v.isLoading", false);
    },

    showSpinner : function(component, event, helper) {
        component.set("v.isLoading", true);
    },

    hideSpinner : function(component,event,helper){
        component.set("v.isLoading", false);
    }
});