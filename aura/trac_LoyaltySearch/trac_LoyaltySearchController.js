({
    init: function (component, event, helper) {
        component.set('v.options', [
                                 { id: 1, label: 'Email', selected: true },
                                 { id: 2, label: 'Loyalty Account Number' }
                                // { id: 3, label: 'Phone Number' }
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

});