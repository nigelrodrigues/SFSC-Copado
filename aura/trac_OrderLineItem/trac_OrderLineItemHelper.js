({
    setDisabled: function(component) {
        var order = component.get("v.order");
        var orderLineItem = component.get("v.orderLineItem");

        /* var disabled = false;
         if (orderLineItem && orderLineItem.Status !== 'Created') {
             disabled = true;
         }

         if (!orderLineItem && order.Status !== 'Created') {
             disabled = true;
         }*/
        var disabled = true;
        if( orderLineItem &&
            (
                orderLineItem.Status === 'Released' ||
                orderLineItem.Status === 'Backordered' ||
                orderLineItem.Status === 'Hold Credit' ||
                orderLineItem.Status === 'Hold Risk' ||
                orderLineItem.Status === 'General Error' ||
                orderLineItem.Status === 'Created' ||
                orderLineItem.Status === 'Open' ||
                orderLineItem.Status === 'Ready For Backroom Pick' ||
                orderLineItem.Status === 'Scheduled'
            )
        )
        {
            disabled = false;
        }

        if ( !orderLineItem &&
            (
                order.Status === 'Released' ||
                order.Status === 'Backordered' ||
                order.Status === 'Hold Credit' ||
                order.Status === 'Hold Risk' ||
                order.Status === 'General Error' ||
                order.Status === 'Created' ||
                order.Status === 'Open' ||
                order.Status === 'Ready For Backroom Pick' ||
                order.Status === 'Scheduled'
            )
        )
        {
            disabled = false;
        }

        var businessUnit = component.get("v.businessUnit");
        if(businessUnit == 'Off 5th' || businessUnit == 'Saks') {
            if (!orderLineItem && order.Status === 'Released') {
                disabled = true;
            }
            if (orderLineItem && orderLineItem.Status === 'Released') {
                disabled = true;
            }
        }
        component.set("v.disabledCancel", disabled);
    },

    setActiveHold: function(component) {
        var orderLineItem = component.get("v.orderLineItem");

        if(orderLineItem.OrderHoldTypes.OrderHoldType) {
            for (var orderHoldType of orderLineItem.OrderHoldTypes.OrderHoldType){
                console.log(orderHoldType)
                if(orderHoldType.StatusDescription == 'Created') {
                    component.set("v.isActiveHold", true);
                }
            }
        }
    },

    handleShowOrderRefundCredit: function(component, event, helper) {
        let container = component.find("divBody");

        $A.createComponent(
            "c:trac_OrderRefundCredit",
            {
                "orderLineItem": component.get('v.orderLineItem'),
                "order": component.get('v.order'),
                "caseRecord": component.get('v.caseRecord'),
                "showButton": false
            },
            function(newComponent, status, errorMessage){
                //Add the new button to the body array
                if (status === "SUCCESS") {
                    let body = container.get("v.body");
                    $A.enqueueAction(newComponent.get('c.createOrderRefundCredit'));
                    body.push(newComponent);
                    container.set("v.body", body);
                    component.set('v.isLoading', false);
                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                    // Show offline error
                }
                else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                    // Show error message
                }
            });
    },

    handleShowCancelOrder: function(component, event, helper) {
        let container = component.find("divBody");
        component.set('v.isLoading', true);

        $A.createComponent(
            "c:trac_CancelOrder",
            {
                "orderLineItem": component.get('v.orderLineItem'),
                "order": component.get('v.order'),
                "caseRecord": component.get('v.caseRecord'),
                "businessUnit": component.get('v.businessUnit'),
                "showButton": false
            },
            function(newComponent, status, errorMessage){
                //Add the new button to the body array
                if (status === "SUCCESS") {
                    let body = container.get("v.body");
                    $A.enqueueAction(newComponent.get('c.doInit'));
                    $A.enqueueAction(newComponent.get('c.handleOpenModal'));
                    body.push(newComponent);
                    container.set("v.body", body);
                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                    // Show offline error
                }
                else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                    // Show error message
                }
                component.set('v.isLoading', false);
            });
    },

    handleShowAddNote: function(component, event, helper) {
        let container = component.find("divBody");

        $A.createComponent(
            "c:trac_AddNote",
            {
                "orderLineItem": component.get('v.orderLineItem'),
                "order": component.get('v.order'),
                "caseRecord": component.get('v.caseRecord'),
                "businessUnit": component.get('v.businessUnit'),
                "showButton": false
            },
            function(newComponent, status, errorMessage){
                //Add the new button to the body array
                if (status === "SUCCESS") {
                    let body = container.get("v.body");
                    $A.enqueueAction(newComponent.get('c.handleOpenModal'));
                    body.push(newComponent);
                    container.set("v.body", body);
                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                    // Show offline error
                }
                else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                    // Show error message
                }
            });
    },
});