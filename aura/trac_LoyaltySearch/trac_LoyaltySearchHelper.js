({
    getLoyalty: function(component, email, loyaltyId, phoneNum) {
        component.find("Id_spinner").set("v.class" , 'slds-show');
        component.set("v.loyalty", null);
        component.set("v.noLoyaltyFound", false);
        component.set("v.isMerkleError", false);

        var action = component.get("c.getLoyalty");

        action.setParams({
            'email': email,
            'loyaltyId': loyaltyId
        });

        return new Promise(function(resolve, reject) {
            action.setCallback(this,function(response) {
                component.find("Id_spinner").set("v.class" , 'slds-hide');
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    if (result == null) {
                        reject(new Error("Connection Error"));
                    } else {
                        var isSuccess = result.returnValuesMap['body']['success']
                        if(result.isSuccess && isSuccess) {
                            var returnVal = result.returnValuesMap['body']['data'];
                            returnVal.lifetime_balance_in_dollars = returnVal.lifetime_balance / 200
                            returnVal.top_tier_join_date = Date.parse(returnVal.top_tier_join_date)
                            component.set('v.loyalty', returnVal);
                            resolve(returnVal)
                        } else {
                            var error = new Error(response.getError())
                            var str = result.returnValuesMap['body']
                            var body = JSON.parse(str)
                            error.result = result
                            error.code = body.data.code
                            error.message = body.data.message
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

    getLoyaltyUAD: function(component, email, loyaltyId, phoneNum) {
        component.find("Id_spinner").set("v.class" , 'slds-show');
        component.set("v.loyalty", null);
        component.set("v.noLoyaltyFound", false);
        component.set("v.isMerkleError", false);

        var action = component.get("c.getLoyaltyUAD");

        action.setParams({
            'email': email,
            'loyaltyId': loyaltyId,
            'phoneNum': phoneNum
        });

        return new Promise(function(resolve, reject) {
            action.setCallback(this,function(response) {
                component.find("Id_spinner").set("v.class" , 'slds-hide');
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    if (result == null) {
                        reject(new Error("Connection Error"));
                    } else {
                        var isSuccess = result.returnValuesMap['body']['success']
                        if(result.isSuccess && isSuccess) {
                            var returnVal = result.returnValuesMap['body'];
                            console.log(returnVal)
                            resolve(returnVal)
                        } else {
                            var error = new Error(response.getError())
                            var str = result.returnValuesMap['body']
                            var body = JSON.parse(str)
                            error.result = result
                            error.code = body.response_code
                            error.message = body.error_message
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

    isNotBlank: function(component, field) {
        if (component.find(field).get("v.value") == null || component.find(field).get("v.value") == '') {
            return false;
        }
        else {
            return true;
        }
    },

    isValidResponse: function (res) {
        return res != null && (res == 200 || res == 201 || res == 204);
    },

    handleError : function(component, error) {
        var result = error.result
        if(typeof result === 'object' && result != null) {
            var statusCode = result.returnValuesMap['statusCode']
            var str = result.returnValuesMap['body']
            if ( statusCode && this.isValidResponse(statusCode)  ) {
                var body = JSON.parse(str)
                component.set("v.canRetry", false);
                component.set("v.responseCode", error.code);
                component.set("v.bodyMsg", error.message);
                component.set("v.isMerkleError", true);
            } else {
                component.set("v.canRetry", true);
                component.set("v.responseCode",  statusCode);
                component.set("v.bodyMsg", str);
                component.set("v.isMerkleError", true);
             }
        } else {
            component.set("v.isError", true);
            component.set("v.errorMsg", error.message);
        }
    }
});