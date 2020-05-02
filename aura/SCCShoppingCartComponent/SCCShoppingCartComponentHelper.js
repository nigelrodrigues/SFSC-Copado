({
    openShoppingCartHelper : function(component, event, helper, isGuest) {
        var recordId = component.get('v.recordId');
        var objectName = component.get('v.sObjectName');

        var action = component.get('c.getAgentAccessToken');

        action.setParams({
            recordId: recordId
        });

        action.setCallback(this, function (response) {

            var state = response.getState();

            if (component.isValid() && state === "SUCCESS") {
                var result =  response.getReturnValue();

                if (result == null) {
                    component.set("v.errorMsg", "Connection Error");
                } else {
                    if(result.isSuccess) {

                        var SFCC_CustomerId_isBlank = result.returnValuesMap['isBlank'];
                        var sessionURL = result.returnValuesMap['storeSessionURL'];
                        var storefrontURL = result.returnValuesMap['storeFrontURL'];
                        var guestStoreFrontURL = result.returnValuesMap['guestStoreFrontURL'];
                        var token = result.returnValuesMap['customerAuthToken'];

                        if (SFCC_CustomerId_isBlank && isGuest!=true) {
                            component.set("v.showModal", false);
                            component.set("v.isLoading", false);
                            component.set("v.isError", true);
                            component.set("v.errorMsg", 'Please enter the SFCC Customer Id in the Contact record and try again.');
                        }
                        else{


                            if (!token && isGuest!=true) {
                                component.set("v.showModal", false);
                                component.set("v.isLoading", false);
                                component.set("v.isError", true);
                                component.set("v.errorMsg", 'The customer does not have valid credentials. Please contact the Administrator for valid SFCC credentials.');
                            } else if (sessionURL && storefrontURL) {
                                var $j = jQuery.noConflict();
                                $j.ajax({
                                    type: 'POST',
                                    url: sessionURL,
                                    headers: {
                                        'Authorization': token
                                    },
                                    dataType: 'json',
                                    data: {},
                                    xhrFields: {
                                        withCredentials: true
                                    },
                                    success: function (responseData, status, xhr) {
                                        if (!isGuest) {
                                            window.open(storefrontURL);
                                        } else {
                                            window.open(guestStoreFrontURL);
                                        }
                                        component.set("v.showModal", false);
                                    },
                                    error: function (request, status, error) {
                                        component.set("v.showModal", false);
                                        component.set("v.isLoading", false);
                                        component.set("v.isError", true);
                                        component.set("v.errorMsg", "Could not load storefront. Please check if the customer status is active.");
                                    }
                                });
                            } else {
                                console.error(response);
                            }
                        }
                    } else {
                        component.set("v.isError", true);
                        component.set("v.errorMsg", result.message);
                    }

                }
            } else {
                console.error("failed with state: " + state);
            }

            component.set("v.isLoading", false);
            $A.get('e.force:refreshView').fire();
        });
        $A.enqueueAction(action);
    },

    showToast: function(message, type, title) {
        var resultsToast = $A.get("e.force:showToast");
        resultsToast.setParams({
            "title": title,
            "message": message,
            "type" : type
        });
        resultsToast.fire();
    },

    unrender: function(component){
        this.superUnrender();
        component.destroy();
    }


})