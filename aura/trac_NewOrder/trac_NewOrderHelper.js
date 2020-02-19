/**
 * Created by jhoran on 7/4/2019.
 */
({
    createNewOrderApex : function(component, helper, contactId) {

        var apexAction = component.get("c.createNewOrder");

        var recordId = component.get('v.recordId');

        apexAction.setParams({
            "caseId": recordId,
            "contactId": contactId
        });

        apexAction.setCallback(this, function(response) {
            var state = response.getState();

            if (component.isValid() && state === "SUCCESS") {
                var result =  response.getReturnValue();

                if (result == null) {
                    component.set("v.errorMsg", "Connection Error");
                } else {
                    if(result.isSuccess) {
                        component.set("v.isError", false);
                        var orderNumber = result.returnValuesMap['orderNumber'];
                        var username = result.returnValuesMap['username'];

                        helper.showToast("Order #" + orderNumber + " Created", "success", "You will be redirected shortly");

                        var cs = component.get("v.caseRecord");
                        var businessUnit = (cs.Business_Unit__c === 'Hudson\'s Bay') ? 'BAY' : 'LT';//TODO: move to Label or something configurable
                        var urlLink = $A.get("$Label.c.OMS_LT_BAY_Login") + '?';
                        if (username) {
                            urlLink += "UserId=" + username + '&';
                        }
                        urlLink += "OrderNo=" + orderNumber + '&EnterpriseCode=' + businessUnit + '&DocumentType=0001';
                        helper.copyToClipboard(orderNumber);
                        $A.get('e.force:refreshView').fire();
                        helper.navigateToLink(urlLink);
                    } else {
                        component.set("v.isError", true);
                        component.set("v.errorMsg", result.message);
                    }
                }
            } else {
                console.log("failed with state: " + state);
            }

            component.set("v.isLoading", false);
        });

        $A.enqueueAction(apexAction);
    },

    showToast : function(message, type, title) {
        var resultsToast = $A.get("e.force:showToast");
        resultsToast.setParams({
            "title": title,
            "message": message,
            "type" : type
        });
        resultsToast.fire();
    },

    navigateToLink : function(urlLink){
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": urlLink
        });
        urlEvent.fire();
    },

    copyToClipboard : function (stringToCopy) {
        var el = document.createElement('textarea');
        el.value = stringToCopy;
        el.setAttribute('readonly', '');
        el.style = {position: 'absolute', left: '-9999px'};
        document.body.appendChild(el);
        el.select();
        document.execCommand('copy');
        document.body.removeChild(el);
    },

    validateForm : function(component, event, helper) {
        var caseRecord = component.get('v.caseRecord');
        var fields = event.getParam('fields');

        if (caseRecord && fields) {
            var isError = false;

            var mailingCountry = fields.MailingCountryCode;
            var billingCountry = fields.OtherCountryCode;
            var businessUnit = caseRecord.Business_Unit__c;

            if (!fields.FirstName) {
                isError = true;
                component.set('v.errorMsg', 'First Name is required to place an order');
            }
            else if (!fields.LastName) {
                isError = true;
                component.set('v.errorMsg', 'Last Name is required to place an order');
            }
            else if (!fields.Email) {
                isError = true;
                component.set('v.errorMsg', 'A valid Email is required to place an order');
            }
            else if (!fields.Phone) {
                isError = true;
                component.set('v.errorMsg', 'A valid Phone number is required to place an order');
            }
            else if (!fields.Mailing_First_Name__c) {
                isError = true;
                component.set('v.errorMsg', 'Mailing First Name is required to place an order');
            }
            else if (!fields.Mailing_Last_Name__c) {
                isError = true;
                component.set('v.errorMsg', 'Mailing Last Name is required to place an order');
            }
            else if (!fields.Mailing_Email__c) {
                isError = true;
                component.set('v.errorMsg', 'A valid Mailing Email is required to place an order');
            }
            else if (!fields.Mailing_Phone__c) {
                isError = true;
                component.set('v.errorMsg', 'A valid Mailing Phone number is required to place an order');
            }
            else if (fields.MailingStreet == null) {
                isError = true;
                component.set('v.errorMsg', 'Please enter a valid Contact with a full address: Street, City, State, Country and Postal Code');
            }
            else if (fields.MailingCity == null) {
                isError = true;
                component.set('v.errorMsg', 'Please enter a valid Contact with a full address: Street, City, State, Country and Postal Code');
            }
            else if (fields.MailingCountryCode == null) {
                isError = true;
                component.set('v.errorMsg', 'Please enter a valid Contact with a full address: Street, City, State, Country and Postal Code');
            }
            else if (fields.MailingStateCode == null) {
                isError = true;
                component.set('v.errorMsg', 'Please enter a valid Contact with a full address: Street, City, State, Country and Postal Code');
            }
            else if (fields.MailingPostalCode == null) {
                isError = true;
                component.set('v.errorMsg', 'Please enter a valid Contact with a full address: Street, City, State, Country and Postal Code');
            }
            else if (fields.OtherStreet == null) {
                isError = true;
                component.set('v.errorMsg', 'Please enter a valid Contact with a full address: Street, City, State, Country and Postal Code');
            }
            else if (fields.OtherCity == null) {
                isError = true;
                component.set('v.errorMsg', 'Please enter a valid Contact with a full address: Street, City, State, Country and Postal Code');
            }
            else if (fields.OtherCountryCode == null) {
                isError = true;
                component.set('v.errorMsg', 'Please enter a valid Contact with a full address: Street, City, State, Country and Postal Code');
            }
            else if (fields.OtherStateCode == null) {
                isError = true;
                component.set('v.errorMsg', 'Please enter a valid Contact with a full address: Street, City, State, Country and Postal Code');
            }
            else if (fields.OtherPostalCode == null) {
                isError = true;
                component.set('v.errorMsg', 'Please enter a valid Contact with a full address: Street, City, State, Country and Postal Code');
            }
            else if (businessUnit === 'Lord + Taylor' && mailingCountry !== 'US') {
                isError = true;
                component.set("v.errorMsg", 'Lord + Taylor Only Ships to US address, please place this order via BorderFree to ship internationally');
            }
            else if (businessUnit === 'Lord + Taylor' && (billingCountry !== 'US' && billingCountry !== 'CA' && billingCountry !== 'UK')) {
                isError = true;
                component.set("v.errorMsg", 'Lord + Taylor only accepts US, Canada and UK billing countries');
            }
            else if (businessUnit === 'Hudson\'s Bay' && mailingCountry !== 'CA') {
                isError = true;
                component.set("v.errorMsg", 'The Bay Only Ships to Canadian address');
            }
            else if (businessUnit === 'Hudson\'s Bay' && (billingCountry !== 'US' && billingCountry !== 'CA' && billingCountry !== 'UK')) {
                isError = true;
                component.set("v.errorMsg", 'The Bay only accepts US, Canada and UK billing countries');
            }
            else if (businessUnit !== 'Hudson\'s Bay' && businessUnit !== 'Lord + Taylor') {
                isError = true;
                component.set("v.errorMsg", 'A valid business unit is required to place an order');
            }

            if (isError) {
                event.preventDefault();
                component.set("v.isError", true);
                component.set("v.isLoading", false);
            }
        }
    }
})