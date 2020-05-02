/**
 * Created by nrodrigues on 3/3/2020.
 */

({
    openModal : function(component, event, helper)
    {
        console.log('In open modal');
        var emailRetrieved = component.get('v.email');
        console.log('email: ' + emailRetrieved);
        helper.getEmailBody(component, event, helper);
        component.set('v.showModal', true);
        component.find('customerEmailField').set('v.value', emailRetrieved);

    },
    closeModal : function (component, event, helper) {
        component.set('v.showModal', false);

    },
    resendEmail : function(component, event, helper){
        helper.resendEmailToUser(component, event, helper);
    }
});