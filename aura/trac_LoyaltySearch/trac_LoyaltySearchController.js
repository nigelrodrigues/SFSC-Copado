({
    init: function (component, event, helper) {
        component.set('v.options', [
                                 { id: 1, label: 'Email', selected: true },
                                 { id: 2, label: 'Loyalty Account Number' },
                                 { id: 3, label: 'Phone Number' }
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
            helper.getLoyaltyUAD(component, helper, null, customerLoyaltyId, null)
            .then(loyalty => helper.getLoyalty(component, helper, loyalty))
            .then(loyalty => component.set('v.loyalty', loyalty))
            .catch(error => helper.handleError(component, helper, error))

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

        var emailInput = component.find('emailInput')
        var loyaltyNumberInput = component.find('loyaltyNumberInput')
        var phoneNumberInput = component.find('phoneNumberInput')

        if(component.get('v.selectedValue') == '1' && emailInput.get("v.validity").valid) {
            email = component.find('emailInput').get("v.value");
        } else if (component.get('v.selectedValue') == '2' && loyaltyNumberInput.get("v.validity").valid) {
            loyaltyId = component.find('loyaltyNumberInput').get("v.value");
        } else if (component.get('v.selectedValue') == '3' && phoneNumberInput.get("v.validity").valid) {
            phoneNum = component.find('phoneNumberInput').get("v.value").replace(/[^\d]/g, "");
        }

        helper.getLoyaltyUAD(component, helper, email, loyaltyId, phoneNum)
        .then(loyalty => helper.getLoyalty(component, helper, loyalty))
        .then(loyalty => component.set('v.loyalty', loyalty))
        .catch(error => helper.handleError(component, helper, error))
    },

    handlePhoneChange: function(component, event, helper) {
        var phoneNumberInput = component.find('phoneNumberInput')

        var phone = helper.normalize(phoneNumberInput.get('v.value'))
        phone = (phone.length != 10) ? phone :
                    phone.replace(/(\d{3})(\d{3})(\d{4})/, "($1) $2-$3");
        phoneNumberInput.set('v.value', phone)
    },

    handleAccountNumberChange: function(component, event, helper) {
        var loyaltyNumberInput = component.find('loyaltyNumberInput')
        var accNum = helper.normalize(loyaltyNumberInput.get('v.value'))
        loyaltyNumberInput.set('v.value', accNum)
    },

});