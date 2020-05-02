({
    
    createNewOrder : function(component, event, helper) {
        component.set("v.showModal", true);
    },

    afterScriptsLoaded : function(component, event, helper) {
    },

    openShoppingCart : function(component, event, helper) {
        component.set("v.isLoading", true);

        var caseRecord = component.get("v.caseRecord");

        if (caseRecord) {
                helper.openShoppingCartHelper(component, event, helper);
        } else {
            component.set("v.showModal", true);
            component.set("v.isLoading", false);
        }

    },

    openShoppingCartGuest : function(component, event, helper) {
        component.set("v.isLoading", true);
        helper.openShoppingCartHelper(component, event, helper, true);
    },

    createAccountAndOpenShoppingCart : function(component, event, helper) {
        component.set("v.isLoading", true);
        helper.openShoppingCartHelper(component, event, helper);
    },
    
    // this function automatic call by aura:waiting event  
    showSpinner : function(component, event, helper) {
        component.set("v.isLoading", true);
   	},
    
 	// this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
       	component.set("v.isLoading", false);
    },

    closeModal : function(component,event,helper){
        component.set("v.showModal", false);
    }
})