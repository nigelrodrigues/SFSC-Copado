/**
 * Created by ragrawal on 7/3/2019.
 */
({

    doInit: function(component, event, helper) {
        helper.setDisabled(component);
        helper.setActiveHold(component);
    },

    openModel: function(component, event, helper) {
        component.set("v.isModalOpen", true);
    },
    closeModel: function(component, event, helper) {
        component.set("v.isModalOpen", false);
    },


    resetDisabled: function(component, event, helper) {
        console.log('Inside resetDisabled');
        helper.setDisabled(component);
    },


    toggleTracking: function(component, event, helper) {
        var showTrackingInfo = component.get("v.showTrackingInfo");
        component.set("v.showTrackingInfo", !showTrackingInfo);
    },

    handleMenuSelect: function(component, event, helper) {
        var selectedMenuItemValue = event.getParam("value");

        switch (selectedMenuItemValue) {
          case 'cancel':
            helper.handleShowCancelOrder(component, event, helper);
            break;
          case 'refund':
            component.set('v.isLoading', true);
            helper.handleShowOrderRefundCredit(component, event, helper);
//            component.set('v.isLoading', false);
            break;
          case 'note':
            helper.handleShowAddNote(component, event, helper);
            break;
          case 'track':
            $A.enqueueAction(component.get('c.toggleTracking'));
            break;
        }
    }
})