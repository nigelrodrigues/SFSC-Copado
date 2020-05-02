/**
 * Created by nrodrigues on 1/17/2020.
 */

({
    createAccount : function(component, event, helper) {

        component.set("v.isLoading", true);

        var sfccCustomerId = component.get('v.caseRecord.Contact.SFCC_Customer_Id__c');

        var businessUnit = component.get("v.caseRecord.Business_Unit__c");
        if( businessUnit === null )
        {
            component.set("v.showModal", false);
            component.set("v.isLoading", false);
            component.set("v.isError", true);
            component.set("v.errorMsg", 'Please select a Business Unit.');
        }
        else {
            helper.createAccountHelper(component, event, helper);
        }
    },

    openModal : function(component,event,helper){

        component.set("v.showModal", true);

        var contactPhone = component.get("v.caseRecord.Contact.Phone");
        component.find("phoneInputValue").set("v.value", contactEmail);

        var zipCode = component.get("v.caseRecord.Contact.MailingPostalCode");
        component.find("zipInputValue").set("v.value", zipCode);


    },

    closeModal : function(component, event, helper){
        component.set("v.showModal", false);
    },

    showSpinner : function(component, event, helper) {
        component.set("v.isLoading", true);
    },

    // this function automatic call by aura:doneWaiting event
    hideSpinner : function(component,event,helper){
        component.set("v.isLoading", false);
    }

});