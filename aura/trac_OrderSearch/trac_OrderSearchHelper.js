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
        var postalCode = component.find("postalInput").get("v.value");
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
                        if(!$A.util.isEmpty(result.returnValuesMap['orderDetails']) && result.returnValuesMap['orderDetails']['ResponseCode'] === '0') {
                            if(component.get("v.orderNumber")){
                                component.set("v.showWarning", false);
                                component.set("v.order", result.returnValuesMap['orderDetails']);
                            }else{
                                component.set("v.showWarning", false);
                                helper.linkToCase(component, orderNo, postalCode);
                            }
                        } else if (helper.isBetweenRange(component.get("v.range"), orderNo)) {
                            helper.linkToCase(component, orderNo, postalCode);
                            component.set("v.showWarning", true);
                        }
                    } else {
                        component.set("v.isError", true);
                        component.set("v.errorMsg", result.message);
                    }
                }
            }
            else {
                console.error("failed with state: " + state);
            }
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    },
    fetchPickListVal: function(component, fieldName, elementId) {
        let action = component.get("c.getselectOptions");
        component.set("v.isLoading", true);
        action.setParams({
            "objObject": component.get("v.objInfo"),
            "fld": fieldName
        });
        let opts = [];
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                let allValues = response.getReturnValue();
                let cs = component.get("v.caseRecord");
                if (allValues != undefined && allValues.length > 0) {
                    opts.push({
                        class: "optionClass",
                        label: "--- None ---",
                        value: ""
                    });
                }
                for (let i = 0; i < allValues.length; i++) {
                    let selected = (cs.Business_Unit__c === allValues[i]);
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
            let validity = component.find("creditCardInput").get("v.validity");
            if(validity.patternMismatch)   return;
        }
        let validity = component.find("orderNumberInput").get("v.validity");
        if(validity.patternMismatch)   return;
        component.set("v.isLoading", true);
        component.set("v.noOrdersFound", false);
        component.set("v.order", null);
        component.set("v.orders", null);
        let orderNo = component.find("orderNumberInput").get("v.value");
        if(!$A.util.isEmpty(orderNo)){
            helper.searchByOrderNumber(component, event, helper, orderNo);
            return;
        }
        let email = component.find("emailInput").get("v.value");
        let businessUnit = component.find("businessUnit").get("v.value");
        component.set("v.businessUnit", businessUnit);
        if(component.get("v.showAdvanceSearch")){
            let phone = component.find("phoneInput").get("v.value");
            let fromDate = component.find("orderDateFromInput").get("v.value");
            let toDate = component.find("orderDateToInput").get("v.value");
            let creditCard = component.find("creditCardInput").get("v.value");
            let upc = component.find("upcInput").get("v.value");
            let giftCard = component.find("giftCardNumberInput").get("v.value");
            let archievedOrder = component.find("archivedOrderInput").get("v.value") ? 'Y' : 'N';
            let draftOrder = component.find("draftOrderInput").get("v.value") ? 'Y' : 'N';
            let accountNumber = component.find('accountNumberInput').get("v.value");
            let action = component.get("c.getOrderListAdv");
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
            let action = component.get("c.getOrderList");
            action.setParams({
                "email": email,
                "businessUnit": businessUnit,
                "accountNumber": accountNumber
            });
        }
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                let result =  response.getReturnValue();
                if (result == null) {
                    component.set("v.errorMsg", "Connection Error");
                } else {
                    if(result.isSuccess) {
                        let returnVal = result.returnValuesMap['orderList'];
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
                console.error("failed with state: " + state);
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
    linkToCase : function (component, orderNo, postalCode) {
        let action = component.get("c.updateCase");
        let caseRecord = component.get("v.caseRecord");
        let order = component.get("v.order");
        if (caseRecord && !caseRecord.Order_Number__c) {
            if(!postalCode)
                postalCode = null;
            let zipCode = (order && order.PersonInfoBillTo) ? order.PersonInfoBillTo.ZipCode : postalCode;
            action.setParams({
                "caseId": caseRecord.Id,
                "orderNo": orderNo,
                "orderZipCode": zipCode
            });
            action.setCallback(this, function (response) {
                let state = response.getState();
                if (component.isValid() && state === "SUCCESS") {
                    $A.get('e.force:refreshView').fire();
                } else {
                    console.error("failed with state: " + state);
                }
            });
            $A.enqueueAction(action);
        }
    },
    setRange : function(component, event, helper) {
        let action = component.get("c.getOrderNumberRange");
        component.set("v.isLoading", true);
        action.setParams({
            "label": 'Digital Blue Martini'
        });
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                let range = response.getReturnValue();
               component.set("v.range", range);
            }
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    },
    setBlueMartiniLink : function(component, event, helper) {
        let action = component.get("c.getBlueMartiniLink");
        component.set("v.isLoading", true);
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                let link = response.getReturnValue();
               component.set("v.link", link);
            }


            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    },

    isBetweenRange : function (rangeStr, number) {
        let ranges = rangeStr.split("-");

        return (ranges[0] <= number && ranges[1] >= number ) ? true : false
    }
})