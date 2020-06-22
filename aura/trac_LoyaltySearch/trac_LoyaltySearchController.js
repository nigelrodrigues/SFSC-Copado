({
    init: function (component, event, helper) {
        component.set('v.options', [
                                 { id: 1, label: 'Email', selected: true },
                                 { id: 2, label: 'Loyalty Account Number' }
                                // { id: 3, label: 'Phone Number' }
                             ]);


        if (component.get('v.refreshSearch')) {
            component.set('v.refreshSearch', false);
            component.set('v.customerLoyaltyId', component.get('v.loyalty.external_customer_id'));
        }
        let customerLoyaltyId = component.get('v.customerLoyaltyId');
        console.log('ID: ' + customerLoyaltyId);


        if( customerLoyaltyId ) {
            component.set("v.selectedValue", "2");
            component.find("loyaltyNumberInput").set("v.value", customerLoyaltyId);
            helper.getLoyalty(component, helper, null, customerLoyaltyId, null);


        }
        else
        {
            component.set('v.selectedValue', '1');
        }
    },
    loyaltySearch: function (component, event, helper) {
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


        helper.getLoyaltyUAD(component, helper, email, loyaltyId, phoneNum)
        .then(() => helper.getLoyalty(component, helper, email, loyaltyId, phoneNum))
        .catch(error => helper.handleError(component, helper, error))
    },


});