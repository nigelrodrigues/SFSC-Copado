/**
 * Created by jhoran on 7/4/2019.
 */
({
    navigateToWebcom: function (component, event, helper) {

        var apexAction = component.get("c.getUserId");

        apexAction.setCallback(this, function (response) {
            var state = response.getState();
            component.set("v.isLoading", false);

            if (component.isValid() && state === "SUCCESS") {
                var result = response.getReturnValue();

                if (result == null) {
                    component.set("v.errorMsg", "Connection Error");
                } else {
                    if (result.isSuccess) {
                        component.set("v.isError", false);

                        var cs = component.get("v.caseRecord");

                        var username = result.returnValuesMap['username'];

                        var businessUnit;
                        var urlLink;

                        if (cs.Business_Unit__c === 'Saks') {
                            businessUnit = 'SAKS'
                            urlLink = $A.get("$Label.c.OMS_SAKS_Login") + '?';
                        } else if (cs.Business_Unit__c === 'Off 5th') {
                            businessUnit = 'OFF5';
                            urlLink = $A.get("$Label.c.OMS_OFF5_Login") + '?';
                        } else if (cs.Business_Unit__c === 'Lord + Taylor') {
                            businessUnit = 'LT';
                            urlLink = $A.get("$Label.c.OMS_LT_BAY_Login") + '?';
                        } else if (cs.Business_Unit__c === 'Hudson\'s Bay') {
                            businessUnit = 'BAY';
                            urlLink = $A.get("$Label.c.OMS_LT_BAY_Login") + '?';
                        }else {
                            component.set("v.isError", true);
                            component.set("v.errorMsg", 'Please select a Business Unit from O5,Saks,LT & Bay');
                            return;
                        }

                        if (username) {
                            urlLink += "UserId=" + username + '&';
                        }
                        urlLink += "OrderNo=" + cs.Order_Number__c + '&EnterpriseCode=' + businessUnit + '&DocumentType=0001';

                        helper.navigateToLink(urlLink);
                    } else {
                        component.set("v.isError", true);
                        component.set("v.errorMsg", result.message);
                    }
                }
            } else {
                console.log("failed with state: " + state);
            }
        });

        $A.enqueueAction(apexAction);
    },

    navigateToNarvar: function (component, event, helper) {
        var cs = component.get("v.caseRecord");
        var urlLink = '';

        var action = component.get("c.getNarvarLinks");
        action.setParams({
            "businessUnit": cs.Business_Unit__c,
            "language": cs.Case_Language__c
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var result = response.getReturnValue();
                if (result != null) {
                    urlLink = result;
                    if (cs.Order_Number__c) {
                        urlLink = urlLink.replace(/{ORDERNUMBER}/, cs.Order_Number__c);
                    }
                    if (cs.Order_Billing_Postal_Code__c) {
                        urlLink = urlLink.replace(/{ZIPCODE}/, cs.Order_Billing_Postal_Code__c);
                    }
                    helper.navigateToSubtab(component, urlLink);
                }
            } else {
                console.log("failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    },

    recordUpdated: function (component, event, helper) {

        var changeType = event.getParams().changeType;

        if (changeType === "CHANGED" && component.find("forceRecord")) {
            component.find("forceRecord").reloadRecord();
        }
    },

})