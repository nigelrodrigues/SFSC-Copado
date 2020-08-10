({
    setDisabled: function(component) {


        var orderLineItem = component.get("v.orderLineItem");
        var disabled = true;
        var cancelabilityMap = component.get('v.cancelabilityMap');
        if (cancelabilityMap != null && typeof cancelabilityMap[orderLineItem.Status] === 'boolean') {
            disabled = !cancelabilityMap[orderLineItem.Status];
        }
        component.set("v.disabledCancel", disabled);
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