({

    getLoyalty: function(component, helper, loyalty) {
        component.find("Id_spinner").set("v.class" , 'slds-show');
        component.set("v.noLoyaltyFound", false);
        component.set("v.isMerkleError", false);
        var caseRecordId = component.get("v.recordId");
        var action = component.get("c.getLoyalty");
        action.setParams({
            'email': loyalty.email,
            'loyaltyId': loyalty.external_customer_id,
            'recordId':  caseRecordId
        });
        return new Promise(function(resolve, reject) {
            action.setCallback(this,function(response) {
                component.find("Id_spinner").set("v.class" , 'slds-hide');
                var state = response.getState();

                if (component.isValid() && state === "SUCCESS") {
                    var result = response.getReturnValue();
                    if (result == null) {

                        reject(new Error("Connection Error"));
                    } else {
                        var statusCode = result.returnValuesMap['statusCode']
                        var str = result.returnValuesMap['body']
                        if(result.isSuccess && result.returnValuesMap['body']['success']) {
                            var merkle = str['data'];
                            loyalty.next_tier_name = merkle.next_tier_name
                            loyalty.member_attributes.ytd_spend = merkle.member_attributes.ytd_spend
                            loyalty.member_attributes.ly_tier = merkle.member_attributes.ly_tier
                            loyalty.first_name = merkle.first_name
                            loyalty.last_name = merkle.last_name
                            loyalty.email = merkle.email
                            resolve(loyalty)
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

                   reject(response);
                }
            });
            $A.enqueueAction(action);
        });
    },
    getLoyaltyUAD: function(component, helper, email, loyaltyId, phoneNum) {
        component.find("Id_spinner").set("v.class" , 'slds-show');
        component.set("v.isMerkleError", false);
        component.set("v.loyalty", null);
        var action = component.get("c.getLoyaltyUAD");
        action.setParams({
            'loyaltyId': loyaltyId,
            'email': email,
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
                        var statusCode = result.returnValuesMap['statusCode']
                        var str = result.returnValuesMap['body']
                        if(result.isSuccess && result.returnValuesMap['body']['success']) {
                            var returnVal = str;
                            for(var k in returnVal.data) returnVal[k] = returnVal.data[k];
                            if(returnVal.linked_partnerships === 'Airmiles')
                                component.set('v.linked_partnerships', true)
                            var conversionRate = component.get('v.conversionRate')
                            returnVal.lifetime_balance_in_dollars = returnVal.lifetime_balance * conversionRate
                            returnVal.balance_in_dollars = returnVal.balance * conversionRate
                            returnVal.top_tier_join_date = Date.parse(returnVal.top_tier_join_date)
                            resolve(returnVal)
                        } else if (helper.isValidResponse(statusCode))  {
                            var error = new Error(response.getError())
                            var body = JSON.parse(str)
                            error.isMerkleError = true
                            error.code = body.response_code
                            error.message = body.error_message
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
                } else {
                   reject(new Error(response.getError()[0].message));
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
    handleError : function(component, helper, error) {
        if(error.isMerkleError) {
            var statusCode = error.statusCode
            if ( statusCode && helper.isValidResponse(statusCode) ) {
                component.set("v.canRetry", false);
                component.set("v.responseCode", error.code);
                component.set("v.bodyMsg", error.message);
                component.set("v.isMerkleError", true);
            } else {
                component.set("v.canRetry", true);
                component.set("v.responseCode",  statusCode);
                component.set("v.bodyMsg", error.str);
                component.set("v.isMerkleError", true);
             }
        } else {
            component.set("v.isError", true);
            component.set("v.errorMsg", error);
        }
    },
    normalize: function(num) {
        if (!num) return "";
        return num.replace(/[^\d]/g, "");
    }

});