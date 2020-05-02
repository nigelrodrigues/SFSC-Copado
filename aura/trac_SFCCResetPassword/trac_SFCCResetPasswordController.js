/**
 * Created by nrodrigues on 1/7/2020.
 */

({

        // this function automatic call by aura:waiting event
        showSpinner: function(component, event, helper) {
            // make Spinner attribute true for display loading spinner
            component.set("v.Spinner", true);
        },

        // this function automatic call by aura:doneWaiting event
        hideSpinner : function(component,event,helper){
            // make Spinner attribute to false for hide loading spinner
            component.set("v.Spinner", false);
        },

        openModal : function(component,event,helper){

            component.set("v.showModal", true);
            var contactEmail = component.get("v.caseRecord.Contact.Email");
            component.find("customerEmail").set("v.value", contactEmail);
        },

        closeModal : function(component, event, helper) {
            component.set("v.showModal", false);
        },


        handleLoad : function(cmp, event, helper) {

            var recUi = event.getParam("recordUi");

            console.log(recUi.record.id);

            console.log('EMAIL BEFORE LOAD:' + recUi.record.fields["Case"].Contact.Email);

            component.find("resetEmail").set("v.value" , recUi.record.fields["Case"].Contact.Email);

        },

        resetUserPassword : function (component, event, helper) {
            console.log('In reset controller');
            helper.sendResetMailToUser(component, event, helper);
        }

    })