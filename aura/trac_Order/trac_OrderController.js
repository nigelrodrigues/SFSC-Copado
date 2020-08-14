/**
 * Created by ragrawal on 7/3/2019.
 */
({
    doInit : function (component, event, helper) {
        let order = component.get("v.order");
        helper.setUnresolvedHolds(component, event, helper);
        helper.spaBusinessUnit(component, event, helper);

        helper.setChannel(component, event, helper, order)
        helper.setCancelabilityMap(component, event, helper);
        helper.setActiveHold(component, event, helper);
        // For Cancel button in Order Actions
        let businessUnit = component.get("v.businessUnit");
        //let orderlineItems = order.OrderLines.OrderLine;

        if( order.Status === 'Released' ||
            order.Status === 'Backordered' ||
            order.Status === 'Hold Credit' ||
            order.Status === 'Hold Risk' ||
            order.Status === 'General Error' ||
            order.Status === 'Created' ||
            order.Status === 'Open' ||
            order.Status === 'Scheduled')
        {
            component.set("v.disableCancelBtn", false);
        }
        if(businessUnit && (businessUnit == 'Off 5th' || businessUnit == 'Saks'))
        {
            if (order.Status === 'Released') {
                component.set("v.disableCancelBtn", true);
            }
        }


    },
    showOrderLineItems : function (component, event, helper) {
        if(component.get("v.showLineItem")){
            component.set("v.showLineItem", false);
        }
        else{
            component.set("v.showLineItem", true);
        }
    },
    handleImport : function (component, event, helper) {
        let action = component.get("c.updateCase");
        let caseRecord = component.get("v.caseRecord");
        let order = component.get("v.order");
        action.setParams({
            "caseId": caseRecord.Id,
            "orderNo": order.OrderNo,
            "orderZipCode": (order.PersonInfoBillTo) ? order.PersonInfoBillTo.ZipCode : null
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                $A.get('e.force:refreshView').fire();
            }
            else {
                console.log("failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    },
    handleAdditionalInfo: function (component, event, helper) {
        if (component.get("v.showAdditionalInfo")) {
            component.set("v.showAdditionalInfo", false);
        }
        else {
            component.set("v.showAdditionalInfo", true);
        }
    },

    handleActions : function (component, event, helper) {

        let selectedAction = event.getParam("value");
        let order = component.get("v.order");
        let caseRecord = component.get("v.caseRecord");
        let businessUnit = component.get("v.businessUnit");
        let recordId = component.get("v.caseRecord.Id");


        switch(selectedAction)
        {
            case "cancelOrder":
                $A.createComponent(
                    "c:trac_CancelOrder",
                    {
                        "isModalOpen": true,
                        "order": order,
                        "caseRecord": caseRecord,
                        "businessUnit": businessUnit,
                        "showButton": false
                    },
                    function(newCmp, status, errorMessage)
                    {
                        helper.setBody(component, event, helper, newCmp, status, errorMessage);
                    }
                );
                break;


            case "addNote":
                $A.createComponent(
                    "c:trac_AddNote",
                    {
                        "isModalOpen": true,
                        "order": order,
                        "caseRecord": caseRecord,
                        "businessUnit": businessUnit,
                        "showButton": false
                    },
                    function(newCmp, status, errorMessage)
                    {
                        helper.setBody(component, event, helper, newCmp, status, errorMessage);

                    }
                );
                break;
            case "salesPriceAdjustment":
                $A.createComponent(
                    "c:trac_SalesPriceAdjustmentButton",

                    {
                        "isModalOpen": true,
                        "order": order,
                        "caseRecord": caseRecord,

                        "recordId": recordId,

                        "showButton": false
                    },
                    function(newCmp, status, errorMessage)
                    {
                        helper.setBody(component, event, helper, newCmp, status, errorMessage);
                    }
                );
                break;

            case "orderRefundCredit":
                let action = component.find("componentORC");
                component.find('componentORC').set('v.caseRecord', caseRecord);
                component.find('componentORC').set('v.order', order);
                component.find('componentORC'). set('v.showButton', false);
                action.createORC();
                break;
            case "paymentCapture":
                $A.createComponent(
                    "c:trac_PaymentCapture",
                    {
                        "isModalOpen": true,
                        "order": order,
                        "caseRecord": caseRecord,
                        "recordId": recordId,
                        "showButton": false
                    },
                    function(newCmp, status, errorMessage)
                    {
                        helper.setBody(component, event, helper, newCmp, status, errorMessage);
                    }
                );
                break;
            case "orderReturnFee":
                $A.createComponent(
                    "c:trac_OrderReturnFee",
                    {
                        "isModalOpen": true,
                        "order": order,
                        "caseRecord": caseRecord,
                        "showButton": false
                    },
                    function(newCmp, status, errorMessage)
                    {
                        helper.setBody(component, event, helper, newCmp, status, errorMessage);
                    }
                );
                break;

            case "linkToCase":
                let linkOrderToCase = component.get('c.handleImport');
                $A.enqueueAction(linkOrderToCase);
                break;
        }
    }
})