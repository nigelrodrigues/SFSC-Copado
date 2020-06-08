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
             if ( !result.isSuccess ) {
                component.set("v.responseCode", result.returnValuesMap['statusCode']);
                component.set("v.bodyMsg", result.returnValuesMap['body']);
                component.set("v.isMerkleError", true);
             }
        } else {
            component.set("v.isError", true);
            component.set("v.errorMsg", error.message);
        }
    }
});