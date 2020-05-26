/**
 * Created by Jeremy on 2/2/2020.
 */

({
    getFollowUpDate: function () {
        var followUpDate = new Date();
        followUpDate.setDate(followUpDate.getDate() + 1);

        var d = new Date(followUpDate),
            month = '' + (d.getMonth() + 1),
            day = '' + d.getDate(),
            year = d.getFullYear();

        if (month.length < 2)
            month = '0' + month;
        if (day.length < 2)
            day = '0' + day;

        return [year, month, day].join('-');
    },

    setCriteriaBasedStatus: function (component, helper) {
        const caseRec = component.get("v.caseRecord");
        var recTypeName = component.get("v.caseRecTypeName");
        console.log('recTypeName: ' + recTypeName);
        console.log('caseRec.ORC_MNR_El_Salvador_Follow_Up__c: ' + caseRec.ORC_MNR_El_Salvador_Follow_Up__c);

        if(caseRec && recTypeName) {
            if (caseRec.ORC_Virtual_Gift_Card_Queue__c > 0) {
                component.find("caseStatus").set("v.value", "Virtual Gift Card Processing");
            }
            else if (caseRec.Open_ORC__c > 0 && recTypeName === 'bay') {
                if (caseRec.ORC_Missing_Item_or_No_Order__c > 0) {
                    component.find("caseStatus").set("v.value", "MNR Review");
                } else if (caseRec.ORC_Requiring_Approval_Count__c > 0 || caseRec.PayPal_ORC__c > 0) {
                    component.find("caseStatus").set("v.value", "Awaiting Service Excellence Review");
                } else {
                    component.find("caseStatus").set("v.value", "POS Team");
                }
            }
            else if(caseRec.ORC_Count__c == caseRec.ORC_Closed_Count__c && recTypeName === 'bay'){
                component.find("caseStatus").set("v.value", "Closed");
            }
            else if (recTypeName === 'saksoff5th') {
                if (caseRec.ORC_POS_Gift_Card_Saks_O5__c > 0) {
                    console.log('caseRec.ORC_MNR_El_Salvador_Follow_Up__c: ' + caseRec.ORC_MNR_El_Salvador_Follow_Up__c);
                    component.find("caseStatus").set("v.value", "POS Gift Card Processing");
                } else if (caseRec.ORC_Saks_O5_MNR_Review__c > 0) {
                    component.find("caseStatus").set("v.value", "MNR Review");
                } else if (caseRec.ORC_MNR_El_Salvador_Follow_Up__c > 0) {
                    component.find("caseStatus").set("v.value", "Risk Support El Salvador Team");
                }else if (caseRec.ORC_El_Salvador_Review__c > 0) {
                    component.find("caseStatus").set("v.value", "Risk Support El Salvador Team");
                } else if(caseRec.ORC_Jackson_POS__c > 0){
                    component.find("caseStatus").set("v.value", "Risk Support Jackson Team");
                } else if(caseRec.ORC_Count__c == caseRec.ORC_Closed_Count__c){
                    component.find("caseStatus").set("v.value", "Closed");
                }
            }
        }
    },

    getCaseRecordType: function (component, helper) {
        var action = component.get("c.getCaseRecordType");
        action.setParams({caseRecTypeId: component.get("v.caseRecord.RecordTypeId")});

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.caseRecTypeName", response.getReturnValue());
                helper.setCriteriaBasedStatus(component, helper);
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.error("Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.error("Unknown error");
                }
            }
        });
        
        $A.enqueueAction(action);
    },

    setCaseStatus : function(component, event, helper){
        console.log('HERE:');
        var action = component.get("c.getCaseDetails");
        action.setParams({recordId: component.get("v.recordId")});

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.caseRecord", response.getReturnValue());
                helper.setCriteriaBasedStatus(component, helper);

            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.error("Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.error("Unknown error");
                }
            }
        });

        $A.enqueueAction(action);
    }
});