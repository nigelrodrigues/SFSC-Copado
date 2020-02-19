/**
 * Created by jhoran on 7/4/2019.
 */
({
    navigateToWebcom : function(component, event, helper){

        var apexAction = component.get("c.getUserId");

        apexAction.setCallback(this, function(response) {
            var state = response.getState();
            component.set("v.isLoading", false);

            if (component.isValid() && state === "SUCCESS") {
                var result =  response.getReturnValue();

                if (result == null) {
                    component.set("v.errorMsg", "Connection Error");
                } else {
                    if(result.isSuccess) {
                        component.set("v.isError", false);

                        var cs = component.get("v.caseRecord");

                        var username = result.returnValuesMap['username'];

                        var businessUnit = (cs.Business_Unit__c === 'Hudson\'s Bay') ? 'BAY' : 'LT';//TODO: move to Label or something configurable
                        var urlLink = $A.get("$Label.c.OMS_LT_BAY_Login") + '?';
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

    navigateToNarvar : function(component, event, helper){
        var cs = component.get("v.caseRecord");
        var urlLink = '';
        if(cs.Business_Unit__c === 'Hudson\'s Bay'){
            urlLink = $A.get("$Label.c.Hudson_s_Bay_Narvar");
            if($A.util.isEmpty(cs.Case_Language__c) || cs.Case_Language__c === 'English'){
                urlLink += "?locale=en_CA&usertype=BAY081017";
            }
            else if(cs.Case_Language__c === 'French'){
                urlLink += "?locale=fr_CA&usertype=BAY081017";
            }
        }
        else if(cs.Business_Unit__c === 'Lord + Taylor'){
            urlLink = $A.get("$Label.c.Lord_Taylor_Narvar");
            urlLink += "?usertype=LT081017";
        }
        if (cs.Order_Number__c) {
            urlLink += '&order=' + cs.Order_Number__c;
        }
        if (cs.Order_Billing_Postal_Code__c) {
            urlLink += '&bzip=' + cs.Order_Billing_Postal_Code__c;
        }
        helper.navigateToSubtab(component, urlLink);
    },

    recordUpdated : function(component, event, helper) {

        var changeType = event.getParams().changeType;

        if (changeType === "CHANGED" && component.find("forceRecord")) {
            component.find("forceRecord").reloadRecord();
        }
    }
})