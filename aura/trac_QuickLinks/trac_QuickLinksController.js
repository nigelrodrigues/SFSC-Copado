/**
 * @description Client side controller for the component trac_QuickLinks
 * @author      Rajat Agrawal, Traction on Demand
 * @date        2019-07-02
 */
({
    /**
     * @description         Load the list of quick links when the component is initialized
     * @author              Rajat Agrawal, Traction on Demand
     * @param component     Component reference
     * @param event         Event reference
     * @param helper        Helper reference
     */
    doInit: function(component, event, helper) {
        var action = component.get("c.getQuickLinks");

        action.setCallback(this, function (response) {
            var state = response.getState();

            if (component.isValid() && state === "SUCCESS") {
                var returnVal = response.getReturnValue();
                component.set("v.externalLinks", returnVal);
            }
            else {
                $A.get("e.force:closeQuickAction").fire();
                var message = action.getError()[0].message;
                helper.showToast(message, "error", 'Error');
            }
        });

        $A.enqueueAction(action);
    },

    /**
     * @description         Navigate to the link clicked
     * @author              Rajat Agrawal, Traction on Demand
     * @param component     Component reference
     * @param event         Event reference
     */
    navigateToLink : function(component, event){
        var urlLink = event.target.getAttribute("data-label");
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": urlLink
        });
        urlEvent.fire();
    },
})