/**
 * Created by ragrawal on 7/3/2019.
 */
({
    doInit: function(component, event, helper) {
        helper.setDisabled(component);


        // Set Preorder status
        let orderlineItem = component.get('v.orderLineItem');
        if (orderlineItem &&
            orderlineItem.LineType &&
            orderlineItem.LineType ==='PREORDER' &&
            orderlineItem.Extn &&
            orderlineItem.Extn.ExtnEstimatedShipDate
        )
        {
            // date comes in reverse order YYYY-MM-DD
            const months = ["Jan", "Feb", "Mar","April", "May", "June", "July", "Aug", "Sep", "Oct", "Nov", "Dec"];


            let latestExpectedShipDate = orderlineItem.Extn.ExtnEstimatedShipDate;
            let preorderBadge = 'PREORDER - ' +
                months[latestExpectedShipDate.substring(5,7)-1] + ' ' + // Month
                latestExpectedShipDate.substring(8,10) + ', ' + // DD
                latestExpectedShipDate.substring(0,4) ;       //YYYY
            component.set('v.preorderBadge', preorderBadge);
        }


        if( orderlineItem.OrderHoldTypes && orderlineItem.OrderHoldTypes.OrderHoldType )
        {
            var isActive = component.get("v.isActiveHold");
            for (let orderlineItemHoldType of orderlineItem.OrderHoldTypes.OrderHoldType)
            {
                if(orderlineItemHoldType.StatusDescription === 'Created' && !isActive)
                {
                    component.set("v.isActiveHold", true);
                }
            }
        }
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