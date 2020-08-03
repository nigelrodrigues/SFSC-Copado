/**
 * Created by jhoran on 2/24/2020.
 */
({
    handleInit: function (component, event, helper) {
        const order = component.get("v.order");

        let paymentMethod = {};
        let giftCard = {};

        if (order && order.PriceInfo) {
            paymentMethod.RequestAmount = order.PriceInfo.TotalAmount;
            giftCard.currency_code = order.PriceInfo.Currency_x;
        }

        component.set("v.paymentMethod", paymentMethod);
        component.set("v.giftCard", giftCard);
    },

    handleLoad: function (component, event, helper) {
        component.set("v.isLoading", false);
        component.find("paymentFieldFirstName").set("v.value", "");
        component.find("paymentFieldLastName").set("v.value", "");
        component.find("paymentFieldEmail").set("v.value", "");
        component.find("paymentFieldDayPhone").set("v.value", "");
        },

    handleAmount: function (component, event, helper) {
        let paymentRemaining = component.get("v.paymentRemaining");
        var amt = component.get("v.paymentMethod.RequestAmount");
        let amountError = component.find("reqAmt");
        if (amt > paymentRemaining) {
            amountError.setCustomValidity("Amount cannot be greater than outstanding balance.");
        } else {
            amountError.setCustomValidity("");
        }
        amountError.reportValidity();
    },

    handleSubmit: function (component, event, helper) {
        event.preventDefault();
        component.set("v.isLoading", true);

        var paymentType = component.get('v.paymentMethod.PaymentType');
        if(paymentType === 'GIFT_CARD') {
            var amountDue = component.find('reqAmt').get('v.value');
            var giftCardBalance = component.get("v.giftCardBalance");

            var difference = 0;
            if (giftCardBalance) {
                difference = amountDue - giftCardBalance;
            }
            var displayWarning = component.get('v.displayWarning');

            var checkBalance = component.find('checkBalance').get('v.value');
            if(checkBalance === 'Unknown')
            {
                component.set("v.isError", true);
                component.set("v.errorMsg", 'Please check the balance of gift card before saving.');
            }
            else if (difference > 0 && displayWarning) {
                component.set("v.isError", true);
                component.set("v.heading", 'Notification: Balance Amount');
                component.set("v.errorMsg", 'Gift card will be applied. Balance amount is ' + difference.toFixed(2).toString());
                component.find('reqAmt').set('v.value', giftCardBalance);
                component.set('v.displayWarning', false);
            } else {
                helper.addPaymentMethod(component, event, helper);
            }
        }
        else
        {
            helper.addPaymentMethod(component, event, helper);
        }

    },

    handleOpenModal: function (component, event, helper) {
        component.set('v.displayWarning', true);
        component.set('v.paymentMethod.GiftCardPin', '');
        component.set('v.paymentMethod.SvcNo', '');
        component.set("v.isModalOpen", true);
        component.set('v.giftCardBalance','');
    },

    handlePaymentChange: function (component, event, helper) {

    },

    handleCreditChange: function (component, event, helper) {

    },

    handleCheckBalance: function (component, event, helper) {
        component.set("v.isLoading", true);
        helper.getGiftCardBalanceApex(component, event, helper);
    },

    creditCardFormat: function (component, event, helper) {
        let creditCardNo = component.get("v.creditCardNumber");
        let creditCardComp = component.find("creditCardNum");
        let maskedCC = component.get("v.maskedCCNumber");

        if (creditCardNo && creditCardComp) {
            let creditCardNoWithoutSpaces = creditCardNo.split(" ").join("");

            let parts = [];
            for (let i = 0, len = creditCardNoWithoutSpaces.length; i < len; i += 4) {
                parts.push(creditCardNoWithoutSpaces.substring(i, i + 4));
            }

            let ccNumberWithSpaces = parts.join(" ");

            if (ccNumberWithSpaces.length != 19 || ccNumberWithSpaces.includes("X")) {
                creditCardComp.setCustomValidity("Credit Card number should be equals to 16 digits!");
            } else {
                component.set("v.creditCardNumber", ccNumberWithSpaces);
                creditCardComp.setCustomValidity("");
            }

            if (maskedCC) {
                let maskedCCWithoutSpaces = maskedCC;
                let maskedCCparts = [];
                for (let j = 0, leng = maskedCCWithoutSpaces.length; j < leng; j += 4) {
                    maskedCCparts.push(maskedCCWithoutSpaces.substring(j, j + 4));
                }
                let maskedCCWithSpaces = maskedCCparts.join(" ");

                if (ccNumberWithSpaces.includes("X") && maskedCCWithSpaces !== ccNumberWithSpaces) {
                    creditCardComp.setCustomValidity("Please re-enter the card number without X");
                }  else {
                    component.set("v.creditCardNumber", ccNumberWithSpaces);
                    creditCardComp.setCustomValidity("");
                }

            }

            creditCardComp.reportValidity();
        }
    },

    onChangeCCHandler: function (component, event, helper) {
        var ccNumber = component.get("v.creditCardNumber");
        if (ccNumber.length == 4 || ccNumber.length == 9 || ccNumber.length == 14) {
            ccNumber += ' ';
            component.set("v.creditCardNumber", ccNumber);
        }
    },

    onChangeExpiryHandler: function (component, event, helper) {
        var ccExpiry = component.get("v.paymentMethod.CreditCardExpDate");
        if (ccExpiry.length == 2) {
            ccExpiry += '/';
            component.set("v.paymentMethod.CreditCardExpDate", ccExpiry);
        }
    },

    validateExpiryDate: function (component, event, helper) {
        let expiryError = component.find("expiryDate");
        let enteredExpiryDate = component.get("v.paymentMethod.CreditCardExpDate");

        if (enteredExpiryDate) {
            if (enteredExpiryDate.includes('/')) {
                let enteredMonth = enteredExpiryDate.split('/')[0] - 1;
                let enteredYear = enteredExpiryDate.split('/')[1];
                let expiryComparison = new Date(enteredYear, enteredMonth);

                if (expiryComparison < new Date()) {
                    expiryError.setCustomValidity("Expiry date must be in the future!");
                } else {
                    expiryError.setCustomValidity("");
                }
                expiryError.reportValidity();
            }
        }
    },

    useExistingAddressChange: function (component, event, helper) {
        let useExisting = component.get("v.useExistingBillingAddress");
        useExisting = !useExisting;
        component.set("v.useExistingBillingAddress", useExisting);
    },

    handleCloseModel: function (component, event, helper) {
        component.set("v.isLoading", false);
        component.set("v.isModalOpen", false);
    },

    updatePaymentRemaining: function (component, event, helper) {
        var params = event.getParam('arguments');
        if (params) {
            var paymentRemaining = params.paymentRemaining;
            var paymentMethod = component.get("v.paymentMethod");

            paymentMethod.RequestAmount = paymentRemaining.toFixed(2).toString();

            component.set("v.paymentMethod", paymentMethod);
        }
    },

    handlePaymentEdit: function (component, event, helper) {
        var paymentMethod = event.getParam("paymentMethod");
        component.set("v.indexVal", event.getParam("indexVal"));

        component.set("v.isModalOpen", true);
        component.set("v.isEdit", true);
        component.set("v.useExistingBillingAddress", false);

        component.find("paymentFieldFirstName").set("v.value", paymentMethod.PersonInfoBillTo.FirstName);
        component.find("paymentFieldLastName").set("v.value", paymentMethod.PersonInfoBillTo.LastName);
        component.find("paymentFieldEmail").set("v.value", paymentMethod.PersonInfoBillTo.EMailID);
        component.find("paymentFieldDayPhone").set("v.value", paymentMethod.PersonInfoBillTo.DayPhone);
        component.find("paymentFieldAddress").set("v.value", "");

        let maskedCC = "XXXXXXXXXXXX" + paymentMethod.DisplayCreditCardNo;
        let maskedCCWithSpaces = "XXXX XXXX XXXX " + paymentMethod.DisplayCreditCardNo;
        component.set("v.maskedCCNumber", maskedCC);
        component.set("v.creditCardNumber", maskedCCWithSpaces);
        component.set("v.paymentMethod", paymentMethod);
    }
});