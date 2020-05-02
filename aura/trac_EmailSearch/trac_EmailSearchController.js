/**
 * Created by nrodrigues on 2/27/2020.
 */

({
    doInit : function(component, event, helper)
    {
        var caseOrderNumber = component.get("v.orderNumber");
        console.log('caseOrderNumber: ' + caseOrderNumber);
        var cs = component.get("v.caseRecord");
        var businessUnit = component.get("v.caseRecord.Business_Unit__c");

        if (caseOrderNumber !== null && !$A.util.isEmpty(caseOrderNumber) && !$A.util.isEmpty(businessUnit)) {
            if (component.find("orderNumberInput")) {
                component.find("orderNumberInput").set("v.value", caseOrderNumber);
            }
            if (component.find("emailInput") && cs.Contact) {
                component.find("emailInput").set("v.value", cs.Contact.Email);
            }
            helper.searchEmailsByOrderNumber(component, event, helper, caseOrderNumber, businessUnit);
        }
    },

    handleSearch : function(component, event, helper)
    {

        helper.searchEmailsByOrderNumberAndEmail(component, event, helper);
    }

});