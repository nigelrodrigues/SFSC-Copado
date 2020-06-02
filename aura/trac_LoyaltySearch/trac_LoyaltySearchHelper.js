({
    getLoyalty: function (component, email, loyaltyId, phoneNum) {
        component.find("Id_spinner").set("v.class" , 'slds-show');
        component.set("v.loyalty", null);
        component.set("v.noLoyaltyFound", false);

        var action = component.get("c.getLoyalty");

        action.setParams({
            'email': email,
            'loyaltyId': loyaltyId
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
                        var returnVal = result.returnValuesMap['loyalty']['data'];
                        component.set('v.loyalty', returnVal);
                    } else if ( result.returnValuesMap['statusCode'] == 404) {
                        component.set("v.noLoyaltyFound", true);
                    } else {
                        component.set("v.isError", true);
                        component.set("v.errorMsg", result.message);
                    }
                }
            }
            else {
                console.log("failed with state: " + state);
            }
        });

        $A.enqueueAction(action);
    },

    isNotBlank: function(component, field) {
        if (component.find(field).get("v.value") == null || component.find(field).get("v.value") == '') {
            return false;
        }
        else {
            return true;
        }
    },
});