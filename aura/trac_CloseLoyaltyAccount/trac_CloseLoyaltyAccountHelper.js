({
    pauseAccount: function(component, event, helper, loyalty)  {
        component.find("Id_spinner").set("v.class" , 'slds-show');
        var action = component.get("c.pauseLoyalty");
        action.setParams({
            'email': loyalty.email,
            'loyaltyId': loyalty.external_customer_id
        });

        return new Promise(function(resolve, reject) {
            action.setCallback(this, function (response) {
                component.find("Id_spinner").set("v.class" , 'slds-hide');
                var state = response.getState();
                if (component.isValid() && state === "SUCCESS") {
                    var result =  response.getReturnValue();
                    if (result == null) {
                        reject(new Error("Connection Error"));
                    } else {
                        if(result.isSuccess) {
                            var returnVal = result.returnValuesMap['body'];
                            component.set('v.isSuccess', true)
                            component.set('v.isClose', true);
                            loyalty.status = 'paused'
                            component.set('v.loyalty', loyalty);
                            component.set('v.message', 'Successfully closed loyalty account');
                            resolve(true)
                        } else {
                            var error = new Error(response.getError())
                            error.result = result
                            reject(error)
                        }
                    }
                }
                else {
                    reject(new Error(response.getError()));
                }
            });

            $A.enqueueAction(action);
        });
    },

    updateLoyaltyPoints: function(component, event, helper, loyalty, points, eventType) {
        component.find("Id_spinner").set("v.class" , 'slds-show');
        component.set("v.isMerkleError", false);

        var action = component.get("c.updateLoyaltyPoints");
        action.setParams({
            'email': loyalty.email,
            'loyaltyId': loyalty.external_customer_id,
            'points': points,
            'eventType': eventType,
        });

        return new Promise(function(resolve, reject) {
            action.setCallback(this, function (response) {
                component.find("Id_spinner").set("v.class" , 'slds-hide');
                var state = response.getState();
                if (component.isValid() && state === "SUCCESS") {
                    var result =  response.getReturnValue();
                    if (result == null) {
                        reject(new Error("Connection Error"));
                    } else {
                        if(result.isSuccess) {
                            loyalty.balance = 0
                            loyalty.balance_in_dollars = 0
                            component.set('v.loyalty', loyalty);
                            resolve(loyalty)
                        } else {
                            var error = new Error(response.getError())
                            error.result = result
                            reject(error)
                        }
                    }
                } else {
                    reject(new Error(response.getError()));
                }
            });

            $A.enqueueAction(action);
        });
    },

    isValidResponse: function (res) {
        return res != null && (res == 200 || res == 201 || res == 204);
    },

    handleError : function(component, error) {
        component.set("v.isModalOpen", false);
        var result = error.result
        if(typeof result === 'object' && result != null) {
            var statusCode = result.returnValuesMap['statusCode']
             if ( statusCode && !this.isValidResponse(statusCode) ) {
                component.set("v.responseCode", statusCode);
                component.set("v.bodyMsg", result.returnValuesMap['body']);
                component.set("v.isMerkleError", true);
             }
        } else {
            component.set("v.isError", true);
            component.set("v.errorMsg", error.message);
        }
    }

});