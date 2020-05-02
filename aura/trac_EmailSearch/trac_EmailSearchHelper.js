/**
 * Created by nrodrigues on 2/27/2020.
 */

({
    searchEmailsByOrderNumber : function(component, event, helper, orderNo, businessUnit) {

        component.set("v.isLoading", true);

        var startDate = component.find("orderStartDateInput").get("v.value");
        var endDate = component.find("orderEndDateInput").get("v.value");
        var email = component.get("v.email");


        var action = component.get("c.getAssociatedEmails");
        action.setParams({
            "orderNumber": orderNo,
            "businessUnit": businessUnit,
            "email": email,
            "startdate": startDate,
             "endDate": endDate
        });

        action.setCallback(this, function (response) {
            var state = response.getState();

            if (component.isValid() && state === "SUCCESS") {

                var result =  response.getReturnValue();

                if (result == null) {
                    component.set("v.errorMsg", "Connection Error");
                } else {
                    if(result.isSuccess) {
                        var emailsRetrieved = result.returnValuesMap['associatedEmails'];
                        if(!$A.util.isEmpty(emailsRetrieved)) {
                            if(component.get("v.orderNumber")){
                                component.set("v.emails", emailsRetrieved);
                                component.set("v.noEmailsFound",false);
                            }
                        }
                        else{
                            component.set("v.noEmailsFound",true);
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

    searchEmailsByOrderNumberAndEmail : function (component, event, helper)
    {
        component.set("v.isLoading", true);

        var orderNo = component.find("orderNumberInput").get("v.value");
        var email = component.find("emailInput").get("v.value");
        var startDate = component.find("orderStartDateInput").get("v.value");
        var endDate = component.find("orderEndDateInput").get("v.value");
        var businessUnit = component.get("v.caseRecord.Business_Unit__c");
        component.set("v.emails", null);

        var action = component.get("c.getAssociatedEmails");
        action.setParams({
            "orderNumber": orderNo,
            "businessUnit": businessUnit,
            "email": email,
            "startDate": startDate,
            "endDate": endDate
        });

        action.setCallback(this, function (response) {
            var state = response.getState();

            if (component.isValid() && state === "SUCCESS") {

                var result =  response.getReturnValue();

                if (result == null) {
                    component.set("v.errorMsg", "Connection Error");
                } else {
                    if(result.isSuccess) {
                        var emailsRetrieved = result.returnValuesMap['associatedEmails'];
                        if(!$A.util.isEmpty(emailsRetrieved)) {
                            if(orderNo || email){
                                component.set("v.emails", emailsRetrieved);
                                component.set("v.noEmailsFound",false);
                            }
                        }
                        else{
                            component.set("v.noEmailsFound",true);
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
    }
});