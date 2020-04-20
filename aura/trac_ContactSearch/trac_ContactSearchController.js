/**
 * @description Client side controller for the component trac_ContactSearch
 * @author      Rajat Agrawal, Traction on Demand
 * @date        2019-06-17
 */
({
    doInit: function(component) {

        if(!$A.util.isEmpty(component.get("v.recordId")) && component.find("businessUnit")){
            var action = component.get("c.getBusinessUnit");

            action.setParams({
                "caseId": component.get("v.recordId")
            });

            action.setCallback(this, function (response) {
                var state = response.getState();

                if (component.isValid() && state === "SUCCESS") {
                    var returnVal = response.getReturnValue();
                    if(!$A.util.isEmpty(returnVal)){
                        if(!$A.util.isEmpty(returnVal.Business_Unit__c)){
                            component.find("businessUnit").set("v.value", returnVal.Business_Unit__c);
                            var contact = component.get("v.contactRecord");
                            contact.Business_Unit__c = returnVal.Business_Unit__c;
                            component.set("v.contactRecord", contact);
                        }
                        if(!$A.util.isEmpty(returnVal.Contact.Unique_External_Id__c)){
                            component.set("v.caseContactExtKey", returnVal.Contact.Unique_External_Id__c);
                        }
                    }
                }
                else {
                    console.log("failed with state: " + state);
                }
            });

            $A.enqueueAction(action);
        }
    },

    formPress: function (component, event, helper) {
        if (event.which === 13) {
            component.set("v.showError", false);
            var contactFields = component.find("contactField");
            if(helper.validateForm(component, contactFields)){
                helper.searchHelper(component, event);
            }
            else {
                component.set("v.showError", true);
            }
        }
    },

    businessUnitChanged: function(component, event, helper) {
        var busUnit = event.getSource().get("v.value");
        var con = component.get("v.contactRecord");
        con.Business_Unit__c = busUnit;
        component.set("v.contactRecord", con);
    },

    openModel: function(component, event, helper) {
        // Set isModalOpen attribute to true
        component.set("v.isModalOpen", true);
    },

    closeModel: function(component, event, helper) {
        // Set isModalOpen attribute to false
        component.set("v.isModalOpen", false);
        component.set("v.Message", false);
        component.set("v.createNewContact",false);
    },

    /**
     * @description         Handles the Search button
     * @author              Rajat Agrawal, Traction on Demand
     * @param component     Component reference
     * @param event         Event reference
     * @param helper        Helper reference
     */
    search: function(component, event, helper) {
        component.set("v.showError", false);

        var contactFields = component.find("contactField");
        if(helper.validateForm(component, contactFields)){
            helper.searchHelper(component, event);
        }
        else {
            component.set("v.showError", true);
        }
    },



    handleCloseModalEvent: function(component, event, helper) {
        var closeModal = event.getParam("closeModal");
        component.set("v.isModalOpen", closeModal);
        if(!closeModal){
            var utilityAPI = component.find("utilitybar");
            utilityAPI.minimizeUtility();
        }
    },

    createContact: function (component) {

        var con = component.get("v.contactRecord");
        var bu = '';
        if (component.find("businessUnit")) {
            bu = component.find("businessUnit").get("v.value");
        }
        var createRecordEvent = $A.get('e.force:createRecord');
        if (createRecordEvent) {
            createRecordEvent.setParams({
                'entityApiName': 'Contact',
                'defaultFieldValues': {
                    'Email': con.Email,
                    'Phone': con.Phone,
                    'Order_Number__c': con.Order_Number__c,
                    'FirstName': con.FirstName,
                    'LastName': con.LastName,
                    'MailingCity': con.MailingCity,
                    'MailingState': con.MailingState,
                    'MailingPostalCode': con.MailingPostalCode,
                    'Business_Unit__c': bu
                }
            });

            createRecordEvent.fire();

            component.set("v.isModalOpen", false);
            var utilityAPI = component.find("utilitybar");
            utilityAPI.minimizeUtility();

        }

    },

    newContact: function (component) {
        component.set("v.createNewContact",true);
        component.set("v.isModalOpen",false);
    },

    handleSuccess: function(component,event,helper)
    {
        component.set("v.isModalOpen", false);
        component.set("v.createNewContact",false);
        var caseId = component.get("v.recordId");
        var payload = event.getParams().response;
        var contactId = payload.id;
        component.find('notifLib').showToast({
            "variant": "success",
            "title": "Contact Created"
        });
        helper.linkContactAndCase(component,caseId,contactId);
    },

    handleLoad : function(component, event, helper){
        var con = component.get('v.contactRecord');
        component.find('last_name').set('v.value', con.LastName);
        component.find('fname').set('v.value', con.FirstName);
        component.find('email').set('v.value',con.Email);
        component.find('phone').set('v.value',con.Phone);
        var bunit = con.Business_Unit__c;
        if(bunit === 'MHF') {
            bunit = 'Hudson\'s Bay';
        }
        component.find('bunit').set('v.value', bunit);

    },

})