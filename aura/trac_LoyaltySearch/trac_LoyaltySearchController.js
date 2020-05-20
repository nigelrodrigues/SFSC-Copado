({
    init: function (component, event, helper) {
        component.set('v.options', [
                                 { id: 1, label: 'Email', selected: true },
                                 { id: 2, label: 'Loyalty Account Number' },
                                 { id: 3, label: 'Phone Number' }
                             ]);
        component.set('v.selectedValue', '1');
    },

    loyaltySearch: function (component, event, helper) {
        var loyalty = null;
        var email = null;
        var loyaltyId = null;
        var phoneNum = null;

        if(component.get('v.selectedValue') == '1' && helper.isNotBlank(component, 'emailInput')) {
            email = component.find('emailInput').get("v.value");
        } else if (component.get('v.selectedValue') == '2' && helper.isNotBlank(component, 'loyaltyNumberInput')) {
            loyaltyId = component.find('loyaltyNumberInput').get("v.value");
        } else if (component.get('v.selectedValue') == '3' && helper.isNotBlank(component, 'phoneNumberInput')) {
            phoneNum = component.find('phoneNumberInput').get("v.value");
        }

        helper.getLoyalty(component, email, loyaltyId, phoneNum)
    },

    testingApi: function (component, event, helper) {
        console.log("in testignAPi")
        component.find("Id_spinner").set("v.class" , 'slds-show');
        component.set("v.loyalty", null);
        component.set("v.noLoyaltyFound", false);

        var action = component.get("c.testAPI");

        action.setCallback(this, function (response) {
            console.log(response)
            component.find("Id_spinner").set("v.class" , 'slds-hide');
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {

                console.log('in success')
                var result =  response.getReturnValue();
                console.log(result)
                console.log(result.returnValuesMap['loyalty'])
                if (result == null) {
                    component.set("v.errorMsg", "Connection Error");
                } else {

                    if(result.isSuccess) {
                        var returnVal = result.returnValuesMap['loyalty']['data'];
                        console.log(returnVal)
                    }  else {
                        console.log('in failed')
                    }
                }
            }
            else {
                console.log("failed with state: " + state);
            }
        });

        $A.enqueueAction(action);
    }
});