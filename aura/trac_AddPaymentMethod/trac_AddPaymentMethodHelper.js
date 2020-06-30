/**
 * Created by jhoran on 2/27/2020.
 */
({
    addPaymentMethod: function (component, event, helper) {
        let fields        = event.getParam('fields');
        let paymentMethod = component.get("v.paymentMethod");
        let order         = component.get("v.order");

        if (paymentMethod && fields && order) {
            paymentMethod.ChargeType = "AUTHORIZATION";
            paymentMethod.MaxChargeLimit = paymentMethod.RequestAmount;

            paymentMethod.PersonInfoBillTo = {};

            if (!component.get("v.useExistingBillingAddress")) {
                paymentMethod.PersonInfoBillTo.FirstName = fields.FirstName;
                paymentMethod.PersonInfoBillTo.LastName = fields.LastName;
                paymentMethod.PersonInfoBillTo.EMailID = order.PersonInfoBillTo.EMailID;
                paymentMethod.PersonInfoBillTo.DayPhone = order.PersonInfoBillTo.MobilePhone;

                paymentMethod.PersonInfoBillTo.Country = fields.OtherCountryCode;
                paymentMethod.PersonInfoBillTo.State = fields.OtherStateCode;
                paymentMethod.PersonInfoBillTo.ZipCode = fields.OtherPostalCode;
                paymentMethod.PersonInfoBillTo.City = fields.OtherCity;
                paymentMethod.PersonInfoBillTo.AddressLine1 = fields.OtherStreet;
            } else {
                paymentMethod.PersonInfoBillTo.FirstName = order.PersonInfoBillTo.FirstName;
                paymentMethod.PersonInfoBillTo.LastName = order.PersonInfoBillTo.LastName;
                paymentMethod.PersonInfoBillTo.EMailID = order.PersonInfoBillTo.EMailID;
                paymentMethod.PersonInfoBillTo.DayPhone = order.PersonInfoBillTo.MobilePhone;

                paymentMethod.PersonInfoBillTo.Country = order.PersonInfoBillTo.Country;
                paymentMethod.PersonInfoBillTo.State = order.PersonInfoBillTo.State;
                paymentMethod.PersonInfoBillTo.ZipCode = order.PersonInfoBillTo.ZipCode;
                paymentMethod.PersonInfoBillTo.City = order.PersonInfoBillTo.City;
                paymentMethod.PersonInfoBillTo.AddressLine1 = order.PersonInfoBillTo.AddressLine1;
            }

            let creditCardNumber = component.get("v.creditCardNumber");
            if (creditCardNumber && creditCardNumber.length >= 4) {
                creditCardNumber = creditCardNumber.replace(/ +?/g, '');
                paymentMethod.DisplayCreditCardNo = creditCardNumber.substr(creditCardNumber.length - 4);
            } else {
                paymentMethod.DisplayCreditCardNo = '';
            }

            const paymentType = component.get('v.paymentMethod.PaymentType');
            if (paymentType === 'GIFT_CARD') {
                const giftCardNumber = component.find('giftCardNumber').get('v.value');
                if (giftCardNumber) {
                    paymentMethod.DisplaySvcNo = giftCardNumber.substr(giftCardNumber.length - 4);
                }
            } else {
                paymentMethod.DisplaySvcNo = '';
            }

            component.set("v.creditCardNumber", creditCardNumber);
            component.set("v.paymentMethod", paymentMethod);

            const giftCardTypes = ["GIFT_CARD", "HBGC", "HBRGC"];

            if (giftCardTypes.includes(paymentMethod.PaymentType)) {
                helper.addPaymentMethodEvent(component, event, helper);
            } else {
                helper.tokenizeAndAddPaymentMethod(component, event, helper, paymentMethod);
            }
        }
    },

    tokenizeAndAddPaymentMethod: function (component, event, helper) {

        let paymentMethod    = component.get("v.paymentMethod");
        let creditCardNumber = component.get("v.creditCardNumber");
        let maskedCC         = component.get("v.maskedCCNumber");
        let isEditMode       = component.get("v.isEdit");
        if (!isEditMode) {
            helper.callApexToTokenize(component, event, helper, paymentMethod, creditCardNumber);
        } else if (maskedCC && creditCardNumber !== maskedCC) {
            helper.callApexToTokenize(component, event, helper, paymentMethod, creditCardNumber);
        } else if (paymentMethod.CreditCardNo) {
            helper.addPaymentMethodEvent(component, event, helper);
        }
    },

    callApexToTokenize: function(component, event, helper, paymentMethod, creditCardNumber){
        let apexAction = component.get("c.tokenizeData");

        apexAction.setParams({
            "dataToTokenize": creditCardNumber
        });
        apexAction.setCallback(this, function (response) {
            let state = response.getState();

            if (component.isValid() && state === "SUCCESS") {
                let result = response.getReturnValue();

                if (result == null) {
                    component.set("v.isError", true);
                    component.set("v.errorMsg", "Connection Error");
                } else {
                    if (result.isSuccess) {
                        paymentMethod.CreditCardNo = result.returnValuesMap['token'];
                        component.set("v.paymentMethod", paymentMethod);

                        helper.addPaymentMethodEvent(component, event, helper);
                    } else {
                        component.set("v.isError", true);
                        component.set("v.errorMsg", result.message);
                    }
                }
            } else {
                console.log("failed with state: " + state);
            }

            component.set("v.isLoading", false);
        });

        $A.enqueueAction(apexAction);
    },

    getGiftCardBalanceApex: function (component, event, helper) {
        let apexAction    = component.get("c.getGiftCardBalance");
        let order         = component.get("v.order");
        let paymentMethod = component.get("v.paymentMethod");
        let giftCard      = component.get("v.giftCard");

        giftCard.number_x = paymentMethod.SvcNo;
        giftCard.pin = paymentMethod.GiftCardPin;

        apexAction.setParams({
            "enterpriseCode": order.EnterpriseCode,
            "cardType": paymentMethod.PaymentType,
            "giftCardJSON": JSON.stringify(giftCard)
        });

        apexAction.setCallback(this, function (response) {
            let state = response.getState();

            if (component.isValid() && state === "SUCCESS") {
                let result = response.getReturnValue();

                if (result == null) {
                    component.set("v.isError", true);
                    component.set("v.errorMsg", "Connection Error");
                } else {
                    if (result.isSuccess) {
                        component.set("v.giftCardBalance", result.returnValuesMap['funds_available']);

                    } else {
                        component.set("v.isError", true);
                        component.set("v.errorMsg", result.message);
                    }
                }
            } else {
                console.log("failed with state: " + state);
            }

            component.set("v.isLoading", false);
        });

        $A.enqueueAction(apexAction);
    },

    addPaymentMethodEvent: function (component, event, helper) {

        let paymentMethod = component.get("v.paymentMethod");
        let isEditMode    = component.get("v.isEdit");
        let appEvent      = $A.get("e.c:trac_PaymentMethodAddedEvent");

        if (isEditMode) {
            component.set("v.isEdit",false);
            let indexVal = component.get("v.indexVal");
            appEvent.setParams({
                "paymentMethod": paymentMethod,
                "mode": false,
                "indexVar": indexVal
            });
        } else {
            component.set("v.isEdit",false);
            appEvent.setParams({
                "paymentMethod": paymentMethod,
                "mode": true
            });
        }

        appEvent.fire();

        helper.clearForm(component, event, helper);
        component.set("v.isModalOpen", false);
        component.set("v.isLoading", false);
    },

    clearForm: function (component, event, helper) {
        component.set("v.useExistingBillingAddress", false);
        component.set("v.creditCardNumber", "");
        component.set("v.paymentMethod.CreditCardType", "");
        component.set("v.paymentMethod.PaymentType", "");
        component.set("v.paymentMethod.CreditCardName", "");
        component.set("v.paymentMethod.CreditCardExpDate", "");
        component.set("v.paymentMethod.CVVAuthCode", "");
        component.find("paymentFieldFirstName").set("v.value", "");
        component.find("paymentFieldLastName").set("v.value", "");
    }
});