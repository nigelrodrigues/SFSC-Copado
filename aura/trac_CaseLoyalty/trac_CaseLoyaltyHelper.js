({
    getConversionRateHelper: function(component, helper) {
        component.find("Id_spinner").set("v.class" , 'slds-show');
        component.set("v.isMerkleError", false);
        var action = component.get("c.getConversionRate");
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
                            var returnVal = str
                            component.set('v.conversionRate', Number(returnVal.conversion_rate))
                            resolve(returnVal)
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
    }
});