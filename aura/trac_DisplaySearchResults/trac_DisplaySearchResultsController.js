/**
 * Created by ragrawal on 6/20/2019.
 */
({
    doInit: function (component) {
        var uniqueId = component.get("v.caseContactExtKey");
        var cn = component.get("v.con");
        if(!$A.util.isEmpty(uniqueId) && !$A.util.isEmpty(cn.Unique_External_Id__c) && uniqueId == cn.Unique_External_Id__c){
            component.set("v.disableLinkToCase", true);
        }
        var recId = component.get("v.recordId");
        if (!$A.util.isEmpty(recId) && recId.startsWith("500")) {
            component.set("v.isCase", true);
        }
    },

    stampSFCCData: function (component, event, helper) {
        var action = component.get("c.stampSFCCCustomerNoAndId");
        action.setParams({
            'caseId' : component.get('v.recordId'),
            'cnt': component.get("v.con")
        });
        console.log('action.getParams: ', action.getParams());
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var sfccCustomerId = response.getReturnValue();
                helper.showToast('Website account connected to contact.', 'success', '');
                $A.get('e.force:refreshView').fire();
                helper.minimizeSearch(component);
            } else if (state === "INCOMPLETE") {
                helper.showToast('Response is Incomplete', 'error', 'Error');
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        helper.showToast("Error message: " + errors[0].message, 'error', 'Error');
                    }
                } else {
                    helper.showToast("Unknown error", 'error', 'Error');
                }
            }
        });
        $A.enqueueAction(action);
    },

    createOrImportCase: function (component, event, helper) {
        var action = component.get("c.upsertContact");
        action.setParams({
            'con': component.get("v.con")
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if (!$A.util.isEmpty(result)) {
                    component.set("v.con", result);
                    if (!component.get("v.isCase")) {
                        var createRecordEvent = $A.get('e.force:createRecord');
                        if (createRecordEvent) {
                            createRecordEvent.setParams({
                                'entityApiName': 'Case',
                                'defaultFieldValues': {
                                    'ContactId': result.Id,
                                    'Business_Unit__c': result.Business_Unit__c,
                                    'Order_Number__c': result.Order_Number__c
                                }
                            });
                            createRecordEvent.fire();
                            helper.minimizeSearch(component);
                            //$A.get('e.force:refreshView').fire();
                        } else {
                            alert("Case creation not supported!");
                        }
                    }
                    else {
                        helper.updateCase(component, event, helper);
                    }
                }
            } else if (state === "INCOMPLETE") {
                alert('Response is Incomplete');
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert("Error message: " +
                            errors[0].message);
                    }
                } else {
                    alert("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
})