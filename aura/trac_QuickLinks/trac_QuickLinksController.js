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
                var result = response.getReturnValue();
                if(result.isSuccess) {
                    if(!$A.util.isEmpty(result.returnValuesMap['externalLinkSettings'])) {
                        var returnVal = result.returnValuesMap['externalLinkSettings'];
                        component.set("v.externalLinksTheBay", returnVal["Bay"]);
                        component.set("v.externalLinksLT", returnVal["LT"]);
                        component.set("v.externalLinksSaks", returnVal["Saks"]);
                        component.set("v.externalLinksOff5th", returnVal["Off5th"]);
                        component.set("v.externalLinksMHF", returnVal["MHF"]);

                        component.set("v.defaultTab", result.returnValuesMap['defaultTab']);
                    }
                }

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
            "url": urlLink,
            "target": "_blank"
        });
        urlEvent.fire();
    },
})