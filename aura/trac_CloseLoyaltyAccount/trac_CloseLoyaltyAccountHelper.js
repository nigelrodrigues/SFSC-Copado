({
    pauseAccount: function(component, event, helper, loyalty) {
        component.find("Id_spinner").set("v.class" , 'slds-show');
        var action = component.get("c.pauseLoyalty");
        action.setParams({
            'email': loyalty.email,
            'loyaltyId': loyalty.external_customer_id
        });

        action.setCallback(this, function (response) {
            component.find("Id_spinner").set("v.class" , 'slds-hide');
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {

                var result =  response.getReturnValue();
                if (result == null) {
                    component.set("v.errorMsg", "Connection Error");
                } else {

                    if(result.isSuccess) {
                        var returnVal = result.returnValuesMap['response'];
                        component.set('v.isSuccess', true)
                        component.set('v.isClose', true);
                        loyalty.status = 'paused'
                        component.set('v.loyalty', loyalty);
                        component.set('v.message', 'Successfully closed loyalty account');
                    } else if ( !result.isSuccess && result.returnValuesMap['response'] ) {
                        var returnVal = result.returnValuesMap['response'];
                        component.set('v.message', 'Something went wrong, please contact support');
                    } else {
                        component.set("v.isError", true);
                        component.set("v.errorMsg", result.message);
                        console.log('in failed')
                        component.set('v.message', 'Something went wrong, please contact support');

                    }
                }
            }
            else {
                console.log("failed with state: " + state);
            }
        });

        $A.enqueueAction(action);
    },

    updateLoyaltyPoints: function(component, event, helper, loyalty, points, eventType) {
        component.find("Id_spinner").set("v.class" , 'slds-show');
        var action = component.get("c.updateLoyaltyPoints");
        console.log(loyalty.external_customer_id)
        action.setParams({
            'email': loyalty.email,
            'loyaltyId': loyalty.external_customer_id,
            'points': points,
            'eventType': eventType,
        });

        action.setCallback(this, function (response) {
                    component.find("Id_spinner").set("v.class" , 'slds-hide');
                    var state = response.getState();
                    if (component.isValid() && state === "SUCCESS") {

                        var result =  response.getReturnValue();
                        console.log(result)
                        if (result == null) {
                            component.set("v.errorMsg", "Connection Error");
                        } else {

                            if(result.isSuccess) {
                                loyalty.balance = 0
                                loyalty.balance_in_dollars = 0
                                component.set('v.loyalty', loyalty);
                            } /*else if ( !result.isSuccess && result.returnValuesMap['response'] ) {

                            }*/ else {
                                component.set("v.isError", true);
                                component.set("v.errorMsg", result.message);
                                console.log('in failed')
                                component.set('v.message', 'Something went wrong, please contact support');

                            }
                        }
                    }
                    else {
                        console.log("failed with state: " + state);
                    }
                });

                $A.enqueueAction(action);
    },

});