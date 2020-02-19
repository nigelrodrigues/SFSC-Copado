/**
 * Created by Jeremy on 6/5/2019.
 */

({
    redirectToMessage: function(component, event, helper) {

        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get('v.message').Id
        });
        navEvt.fire();
    }
});