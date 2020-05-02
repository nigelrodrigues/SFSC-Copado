/**
 * Created by ragrawal on 7/2/2019.
 */
({
    /**
     * @description         Show toast with the given message, type, and title
     * @author              Rajat Agrawal, Traction on Demand
     * @param message       Message to display
     * @param type          Type of toast to display
     * @param title         Title of Toast message
     */
    showToast : function(message, type, title) {
        var resultsToast = $A.get("e.force:showToast");
        resultsToast.setParams({
            "title": title,
            "message": message,
            "type" : type
        });
        resultsToast.fire();
    },

    searchByOrderNumber : function(component, event, helper, orderNo) {
        var businessUnit = component.find("businessUnit").get("v.value");
        var postalCode = component.get("v.postalCode");
        if (!businessUnit) {
            var cs = component.get("v.caseRecord");
            businessUnit = cs.Business_Unit__c;
        }

        component.set("v.businessUnit", businessUnit);

        component.set("v.isLoading", true);

        var action = component.get("c.getOrderDetails");
        action.setParams({
            "orderNo": orderNo,
            "businessUnit": businessUnit,
            "postalCode" :postalCode
        });

        action.setCallback(this, function (response) {
            var state = response.getState();

            if (component.isValid() && state === "SUCCESS") {

                var result =  response.getReturnValue();

                if (result == null) {
                    component.set("v.errorMsg", "Connection Error");
                } else {
                    if(result.isSuccess) {
                        if(!$A.util.isEmpty(result.returnValuesMap['orderDetails'])) {
                            if(component.get("v.orderNumber")){
                                component.set("v.order", result.returnValuesMap['orderDetails']);
                            }else{
                                helper.linkToCase(component, orderNo);
                            }
                        }
                    } else {
                        component.set("v.isError", true);
                        component.set("v.errorMsg", result.message);
                    }
                }
            }
            else {
                console.log("failed with state: " + state);
            }
            component.set("v.isLoading", false);
        });

        $A.enqueueAction(action);
    },

    fetchPickListVal: function(component, fieldName, elementId) {
        var action = component.get("c.getselectOptions");

        component.set("v.isLoading", true);

        action.setParams({
            "objObject": component.get("v.objInfo"),
            "fld": fieldName
        });
        var opts = [];
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
                var cs = component.get("v.caseRecord");

                if (allValues != undefined && allValues.length > 0) {
                    opts.push({
                        class: "optionClass",
                        label: "--- None ---",
                        value: ""
                    });
                }
                for (var i = 0; i < allValues.length; i++) {
                    var selected = (cs.Business_Unit__c === allValues[i]);
                    opts.push({
                        class: "optionClass",
                        label: allValues[i],
                        value: allValues[i],
                        selected: selected
                    });
                }
                component.find(elementId).set("v.options", opts);
            }
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    },

    handleSearch : function (component, event, helper) {
        helper.resetResults(component);

        component.set("v.showError", false);
        if(helper.checkBlank(component, 'orderNumberInput') && helper.checkBlank(component, 'emailInput')){
            if(!component.find("phoneInput") || helper.checkBlank(component, 'phoneInput')){
                component.set("v.showError", true);
                return;
            }
        }
        if(component.find("creditCardInput")){
            var validity = component.find("creditCardInput").get("v.validity");
            if(validity.patternMismatch)   return;
        }
        var validity = component.find("orderNumberInput").get("v.validity");
        if(validity.patternMismatch)   return;
        component.set("v.isLoading", true);
        component.set("v.noOrdersFound", false);
        component.set("v.order", null);
        component.set("v.orders", null);
        var orderNo = component.find("orderNumberInput").get("v.value");
        if(!$A.util.isEmpty(orderNo)){
            helper.searchByOrderNumber(component, event, helper, orderNo);
            return;
        }

        var email = component.find("emailInput").get("v.value");
        var businessUnit = component.find("businessUnit").get("v.value");
        component.set("v.businessUnit", businessUnit);

        if(component.get("v.showAdvanceSearch")){
            var phone = component.find("phoneInput").get("v.value");
            var fromDate = component.find("orderDateFromInput").get("v.value");
            var toDate = component.find("orderDateToInput").get("v.value");
            var creditCard = component.find("creditCardInput").get("v.value");
            var upc = component.find("upcInput").get("v.value");
            var giftCard = component.find("giftCardNumberInput").get("v.value");
            var archievedOrder = component.find("archivedOrderInput").get("v.value") ? 'Y' : 'N';
            var draftOrder = component.find("draftOrderInput").get("v.value") ? 'Y' : 'N';
            var accountNumber = component.find('accountNumberInput').get("v.value");

            var action = component.get("c.getOrderListAdv");
            action.setParams({
                "email": email,
                "businessUnit": businessUnit,
                "phone": phone,
                "archivedOrder": archievedOrder,
                "draftOrder": draftOrder,
                "creditCard": creditCard,
                "upc": upc,
                "giftCard": giftCard,
                "fromOrderDate": fromDate,
                "toOrderDate": toDate
            });
        }
        else{
            var action = component.get("c.getOrderList");
            action.setParams({
                "email": email,
                "businessUnit": businessUnit,
                "accountNumber": accountNumber
            });
        }

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {

                var result =  response.getReturnValue();
                if (result == null) {
                    component.set("v.errorMsg", "Connection Error");
                } else {

                    if(result.isSuccess) {
                        var returnVal = result.returnValuesMap['orderList'];
                        if(!$A.util.isEmpty(returnVal) && returnVal.TotalOrderList !== '0'){
                            component.set("v.orderListResult", returnVal);
                            component.set("v.orders", returnVal.Order);
                        }
                        else{
                            component.set("v.noOrdersFound", true);
                        }
                    } else {
                        component.set("v.isError", true);
                        component.set("v.errorMsg", result.message);
                    }
                }
            }
            else {
                console.log("failed with state: " + state);
            }
            component.set("v.isLoading", false);
        });

        $A.enqueueAction(action);
    },

    checkBlank: function(component, field) {
        if (component.find(field).get("v.value") == null || component.find(field).get("v.value") == '') {
            return true;
        }
        else {
            return false;
        }
    },

    resetResults: function(component) {
        component.set("v.orderListResult", null);
        component.set("v.orders", null);
        component.set("v.order", null);
    },

    linkToCase : function (component, orderNo) {
        var action = component.get("c.updateCase");
        var caseRecord = component.get("v.caseRecord");
        var order = component.get("v.order");

        if (caseRecord && !caseRecord.Order_Number__c) {
            action.setParams({
                "caseId": caseRecord.Id,
                "orderNo": orderNo,
                "orderZipCode": (order && order.PersonInfoBillTo) ? order.PersonInfoBillTo.ZipCode : null
            });

            action.setCallback(this, function (response) {
                var state = response.getState();
                if (component.isValid() && state === "SUCCESS") {
                    $A.get('e.force:refreshView').fire();
                } else {
                    console.log("failed with state: " + state);
                }
            });

            $A.enqueueAction(action);
        }
    }
})