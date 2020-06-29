({
    pauseAccount: function(component, event, helper, loyalty, close_member)  {
        component.find("Id_spinner").set("v.class" , 'slds-show');
        var action = component.get("c.pauseLoyalty");
        action.setParams({
            'email': loyalty.email,
            'loyaltyId': loyalty.external_customer_id,
            'close_member': close_member
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
                        var statusCode = result.returnValuesMap['statusCode']
                        var str = result.returnValuesMap['body']
                        if(result.isSuccess && result.returnValuesMap['body']['success']) {
                            var returnVal = result.returnValuesMap['body'];
                            component.set('v.isSuccess', true)
                            component.set('v.isClose', true);
                            loyalty.status = 'paused'
                            if(loyalty.balance > 0 )
                                loyalty.balance = 0
                                loyalty.balance_in_dollars = 0
                            component.set('v.loyalty', loyalty);
                            component.set('v.message', 'Successfully closed loyalty account');
                            resolve(true)
                        } else if (helper.isValidResponse(statusCode)) {
                            var error = new Error(response.getError())
                            var body = JSON.parse(str)
                            error.isMerkleError = true
                            error.code = body.data.code
                            error.message = body.data.message
                            error.statusCode = statusCode
                            reject(error)
                        } else {
                            var error = new Error(response.getError())
                            error.statusCode = statusCode
                            error.str = str
                            error.isMerkleError = true
                            reject(error)
                        }
                    }
                }
                else {
                    reject(new Error(response.getError()[0].message));
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
                    reject(new Error(response.getError()[0].message));
                }
            });

            $A.enqueueAction(action);
        });
    },

    isValidResponse: function (res) {
        return res != null && (res == 200 || res == 201 || res == 204);
    },

    handleError : function(component, helper, error) {
        component.set("v.isModalOpen", false);
        if(error.isMerkleError) {
            var statusCode = error.statusCode
            if (statusCode && this.isValidResponse(statusCode) ) {
                component.set("v.canRetry", false);
                component.set("v.responseCode", error.code);
                component.set("v.bodyMsg", error.message);
                component.set("v.isMerkleError", true);
            } else if ( statusCode && !this.isValidResponse(statusCode) ) {
                component.set("v.canRetry", true);
                component.set("v.responseCode",  statusCode);
                component.set("v.bodyMsg", error.str);
                component.set("v.isMerkleError", true);
            }
        } else {
            component.set("v.isError", true);
            component.set("v.errorMsg", error);
        }
    }

});