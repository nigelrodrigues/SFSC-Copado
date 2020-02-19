/**
 * Created by ragrawal on 7/2/2019.
 */
({
    doInit: function (component, event, helper) {
        helper.fetchPickListVal(component, 'Business_Unit__c', 'businessUnit');
        var orderNo = component.get("v.orderNumber");
        var cs = component.get("v.caseRecord");
        if (orderNo !== null && !$A.util.isEmpty(orderNo)) {
            if (component.find("orderNumberInput")) {
                component.find("orderNumberInput").set("v.value", orderNo);
            }
            if (component.find("emailInput") && cs.Contact) {
                component.find("emailInput").set("v.value", cs.Contact.Email);
            }
            helper.searchByOrderNumber(component, event, helper, orderNo);
        }
        /*else{
            var action = component.get("c.searchOrders");
        }*/
    },

    formPress: function (component, event, helper) {
        if (event.which == 13) {
            helper.handleSearch(component, event, helper);
        }
    },

    onPicklistChange: function (component, event, helper) {
        var pickVal = event.getSource().get("v.value");
    },

    advanceSearch: function (component, event, helper) {
        if (component.get("v.showAdvanceSearch")) {
            component.set("v.showAdvanceSearch", false);
        }
        else {
            component.set("v.showAdvanceSearch", true);
            var cs = component.get("v.caseRecord");
            if (component.find("phoneInput") && cs.Contact && cs.Contact.Phone != null) {
                component.find("phoneInput").set("v.value", cs.Contact.Phone);
            }
        }
    },

    handleSearch: function (component, event, helper) {
        helper.handleSearch(component, event, helper);
    },

    handleRefreshEvent: function (component, event, helper) {
        helper.handleSearch(component, event, helper);
    }
})