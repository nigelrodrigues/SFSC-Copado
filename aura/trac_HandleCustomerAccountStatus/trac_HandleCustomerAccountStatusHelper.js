/**
 * Created by nrodrigues on 1/28/2020.
 */

({
    getAccountStatus : function (component, event, helper) {

        var action = component.get("c.getCustomerAccountStatus");
        var caseBusinessUnit = component.get("v.caseRecord.Business_Unit__c");
        var SFFCustomerId = component.get("v.caseRecord.Contact.SFCC_Customer_Id__c");

        action.setParams({
            businessUnit: caseBusinessUnit,
            customerId: SFFCustomerId
        });

        action.setCallback(this, function (response) {

            var state = response.getState();
            component.set("v.isLoading", true);

            if (component.isValid() && state === "SUCCESS")
            {
                var result =  response.getReturnValue();

                if (result == null)
                {
                    component.set("v.errorMsg", "Connection Error");
                }
                else
                    {
                    if(result.isSuccess)
                    {
                        component.set("v.isLoading", false);
                        component.set("v.isError", false);
                        var enabled = result.returnValuesMap['enabled'];
                        if(enabled)
                        {
                            component.set("v.isAccountActive", true);
                            //component.set("v.customerStatus", "Active");
                            /*component.find("option").set("v.value", 'Active');*/

                        }
                        else
                        {
                            component.set("v.isAccountActive", false);
                            //component.set("v.customerStatus", "Inactive");
                           /* component.find("option").set("v.value", 'Inactive');*/
                        }

                    } else {
                        component.set("v.isError", true);
                        component.set("v.errorMsg", "Error encountered when getting the customer account status");
                    }
                }
            } else {
                console.error("failed with state: " + state);
            }
            component.set("v.isLoading", false);
        });


        $A.enqueueAction(action);
    },

    updateCustomerAccount : function (component, event, helper) {
        component.set('v.isLoading', true);
        var fetchedStatus = component.find("customerStatus").get("v.value");

        var statusToUpdate;

        if(fetchedStatus === 'Active')
        {
            statusToUpdate = {
                'enabled' : true
            };

        }
        else
        {
            statusToUpdate = {
                'enabled' : false
            };
            console.log('set to false');
        }

        var recordId = component.get('v.recordId');
        var action = component.get('c.getToken');

        action.setParams({
            recordId: recordId
        });

        action.setCallback(this, function (response) {

            var state = response.getState();

            if (component.isValid() && state === "SUCCESS") {

                var result =  response.getReturnValue();
                var token  = result.returnValuesMap['agentAccessToken'];
                token = 'Bearer ' + token;
                var storeSessionURL = result.returnValuesMap['storeSessionURL']
                                        + component.get('v.caseRecord.Contact.SFCC_Customer_Id__c') ;

                console.log('storeSessionURL ====>  ' + storeSessionURL);
                if (result == null)
                {
                    component.set("v.errorMsg", "Connection Error");
                }
                else {
                    if(result.isSuccess) {

                        if (token) {

                            var $j = jQuery.noConflict();
                            $j.ajax({
                                type: 'PATCH',
                                url: storeSessionURL,
                                contentType : "application/json",
                                headers: {
                                    'Authorization': token
                                },
                                dataType: 'json',
                                data: JSON.stringify(statusToUpdate),
                                xhrFields: {
                                    withCredentials: true
                                },
                                success: function (responseData, status, xhr) {
                                    component.set("v.showModal", false);

                                    var resultsToast = $A.get("e.force:showToast");
                                    resultsToast.setParams({
                                        "title": 'Success!',
                                        "message": 'The customer status was updated successfully',
                                        "type": 'success'
                                    });
                                    resultsToast.fire();

                                },
                                error: function (request, status, error) {
                                    component.set("v.showModal", false);
                                    component.set("v.isLoading", false);
                                    component.set("v.isError", true);
                                    component.set("v.errorMsg", 'There was an error in updating the status. Please contact administrator.');
                                }
                            });


                        } else {
                            console.error('ERRORRRRRRRR'+response);
                        }
                    } else {

                        component.set("v.showModal", false);
                        component.set("v.isLoading", false);
                        component.set("v.isError", true);
                        component.set("v.errorMsg", result.message);
                    }
                }
            } else {
                console.error("failed with state: " + state);
            }
            component.set('v.isLoading', false);

        });
        $A.enqueueAction(action);
    }


});