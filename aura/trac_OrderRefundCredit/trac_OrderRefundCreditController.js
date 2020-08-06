/**
 * Created by jhoran on 7/3/2019.
 */
({
    createOrderRefundCredit: function(component, event, helper) {

        component.set("v.isModalOpen", true);
        component.find("Id_spinner").set("v.class" , 'slds-show');

        var caseRecord = component.get("v.caseRecord");
        console.log('ID: ' + caseRecord);
        var order = component.get("v.order");
        var orderLineItem = component.get("v.orderLineItem");
        component.find("orderRefundCreditCreator").getNewRecord(
            "Order_Refund_Credit__c", // sObject type (objectApiName)
            null,      // recordTypeId
            false,     // skip cache?
            $A.getCallback(function() {
                var record = component.get("v.newOrderRefundCredit");
                var error = component.get("v.newOrderRefundCreditError");
                if(error || (record === null)) {
                    console.log("Error initializing record template: " + error);
                    return;
                }
                component.set("v.simpleNewOrderRefundCredit.Case__c", caseRecord.Id);
                component.set("v.simpleNewOrderRefundCredit.Credit_Card_Alias__c", helper.getCreditCardAlias(order));
                component.set("v.simpleNewOrderRefundCredit.Full_Credit_Card_Number__c", helper.getLast4CardNumber(order));
                component.set("v.simpleNewOrderRefundCredit.Original_Gift_Card_Number__c", helper.getGiftCardNumber(order));
                component.set("v.simpleNewOrderRefundCredit.Method_of_Payment__c", helper.getMethodOfPayment(order));
                component.set("v.simpleNewOrderRefundCredit.Amount_Charged_to_Credit_Card__c", helper.getAmountChargedToCreditCard(order));
                component.set("v.simpleNewOrderRefundCredit.Amount_Charged_to_Gift_Card__c", helper.getAmountChargedToGiftCard(order));
                component.set("v.simpleNewOrderRefundCredit.Order_Number__c", helper.getOrderNumber(order));
                component.set("v.simpleNewOrderRefundCredit.Date_of_Sale__c", helper.getDateOfSale(order));
                component.set("v.simpleNewOrderRefundCredit.Shipping_Fee__c", helper.getShippingFee(order));
                component.set("v.simpleNewOrderRefundCredit.Country__c", helper.getBillingCountry(order));
                component.set("v.simpleNewOrderRefundCredit.State_Province__c", helper.getBillingState(order));
                component.set("v.simpleNewOrderRefundCredit.Zip_Postal_Code__c", helper.getBillingZipCode(order));
                component.set("v.simpleNewOrderRefundCredit.Amount_Charged_Full_Order__c", helper.getAmountChargedFullOrderSubtotal(order));
                component.set("v.simpleNewOrderRefundCredit.Amount_Charged_Item__c", helper.getUnitPriceAfterDiscounts(orderLineItem, order));
                component.set("v.simpleNewOrderRefundCredit.Quantity__c", helper.getItemQuantity(orderLineItem, order));
                component.set("v.simpleNewOrderRefundCredit.Shipping_Method__c", helper.getShippingMethod(orderLineItem, order));
                component.set("v.simpleNewOrderRefundCredit.SKU__c", helper.getSKU(orderLineItem, order));
                component.set("v.simpleNewOrderRefundCredit.UPC__c", helper.getUPC(orderLineItem, order));
                component.set("v.simpleNewOrderRefundCredit.OMS_Transaction_Number__c", helper.getTransactionNumber(orderLineItem, order));
                component.set("v.simpleNewOrderRefundCredit.Amount_Charged__c", helper.getAmountChargedSubtotal(helper, orderLineItem, order));
                component.set("v.simpleNewOrderRefundCredit.Amount_Charged_Tax__c", helper.getTaxCharged(orderLineItem, order));
                component.set("v.simpleNewOrderRefundCredit.Item_Name__c", helper.getItemName(orderLineItem, order));
                component.set("v.simpleNewOrderRefundCredit.Item_Description__c", helper.getItemDescription(orderLineItem, order));
                component.set("v.simpleNewOrderRefundCredit.Order_Items_Table__c", helper.getOrderItemsTable(order, helper));
                component.find("orderRefundCreditCreator").saveRecord(function(saveResult) {
                    if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                        var flow = component.find("flow");
                        var inputVariables = [
                            {
                                name : 'RecordID',
                                type : 'String',
                                value : saveResult.recordId
                            }
                        ];
                        flow.startFlow("Order_Refund_Credit", inputVariables);
                        component.find("Id_spinner").set("v.class" , 'slds-hide');
                    } else if (saveResult.state === "INCOMPLETE") {
                        // handle the incomplete state
                        console.log("User is offline, device doesn't support drafts.");
                    } else if (saveResult.state === "ERROR") {
                        // handle the error state
                        console.log('Problem saving contact, error: ' + JSON.stringify(saveResult.error));
                    } else {
                        console.log('Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
                    }
                });
            })
        );
    },
    handleOpenModal: function(component, event, helper) {
        component.set("v.isModalOpen", true);
    },
    handleCloseModal: function(component, event, helper) {
        component.set("v.isModalOpen", false);
    },
    handleStatusChange : function (component, event, helper) {
        if(event.getParam("status") === "FINISHED") {
            component.set("v.isModalOpen", false);
            helper.showToast("Order Refund Credit created!", "success", "Success");
        }
    }
})