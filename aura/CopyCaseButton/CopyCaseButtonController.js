/**
 * @description Client side controller for the component CopyCaseButton
 * @author      Rajat Agrawal, Traction on Demand
 * @date        2019-06-06
 */
({
    /**
     * @description         Handles the confirm button
     * @author              Rajat Agrawal, Traction on Demand
     * @param component     Component reference
     * @param event         Event reference
     * @param helper        Helper reference
     */
    handleConfirm : function (component, event, helper) {
        helper.cloneCase(component, event, helper);
    },

    /**
     * @description             Handles the cancel button
     * @author                  Rajat Agrawal, Traction on Demand
     */
    handleCancel: function() {
        $A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire();
    }
})