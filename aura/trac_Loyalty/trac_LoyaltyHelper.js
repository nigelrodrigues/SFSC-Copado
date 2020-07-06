({
    handleSaveChangesHelper: function(component, helper, loyalty, firstName, lastName, email) {
        component.find("Id_spinner").set("v.class" , 'slds-show');
        component.set("v.isMerkleError", false);

        var action = component.get("c.lsUpdateProfile");

        var new_email = (email === loyalty.email) ? null : email
        var params = {
            loyalty_id: loyalty.external_customer_id,
            email: loyalty.email,
            new_email: new_email,
            first_name: firstName,
            last_name: lastName
        };

        action.setParams({
            'params': params
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
                            var returnVal = result.returnValuesMap['body']['data'];
                            loyalty.first_name = firstName
                            loyalty.last_name = lastName
                            loyalty.email = email
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

    showToast: function(message, type, title) {
        var resultsToast = $A.get("e.force:showToast");
        resultsToast.setParams({
            "title": title,
            "message": message,
            "type" : type
        });
        resultsToast.fire();
    },
});