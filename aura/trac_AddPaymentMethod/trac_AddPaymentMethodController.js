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
        component.find("paymentFieldDayPhone").set("v.value", "");
        component.find("paymentFieldEmail").set("v.value", "");
    },

    handleAmount: function (component, event, helper) {
        let paymentRemaining = component.get("v.paymentRemaining");
        let amt              = component.get("v.paymentMethod.RequestAmount");
        let amountError      = component.find("reqAmt");
        let parseNum = (n) => !isNaN(n) ? parseFloat(n).toFixed(2).toString() : '0.00';
        if (amt > paymentRemaining) {
            amountError.setCustomValidity(
                `Amount ($${parseNum(amt)}) cannot be greater than outstanding balance ($${parseNum(paymentRemaining)})`);
        } else {
            amountError.setCustomValidity("");
        }
        amountError.reportValidity();
    },

    handleSubmit: function (component, event, helper) {
        event.preventDefault();
        component.set("v.isLoading", true);

        let paymentType = component.get('v.paymentMethod.PaymentType');
        if (paymentType === 'GIFT_CARD') {
            let checkBalance    = component.find('checkBalance').get('v.value');
            let amountDue       = component.find('reqAmt').get('v.value');
            let giftCardBalance = component.get("v.giftCardBalance");
            let displayWarning  = component.get('v.displayWarning');
            let difference      = giftCardBalance ? amountDue - giftCardBalance : 0;

            if (checkBalance === 'Unknown') {
                component.set("v.isError", true);
                component.set("v.errorMsg", 'Please check the balance of gift card before saving.');
            } else if (difference > 0 && displayWarning) {
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
        let paymentType = component.get('v.paymentMethod.PaymentType');
        let cardType    = component.get('v.paymentMethod.CreditCardType');
        console.log('p: ' + paymentType + ' and c: ' + cardType);
        if (paymentType === 'GIFT_CARD') {
            cardType = 'EGC';
        } else if (paymentType === 'PVT_CREDIT_CARD') {
            cardType = 'SAKS';
        } else if (['EGC', 'SAKS', undefined].includes(cardType)) {
            cardType = 'VISA';
        }
        console.log('p: ' + paymentType + ' and c: ' + cardType);
        component.set('v.paymentMethod.CreditCardType', cardType);
    },

    handleCreditChange: function (component, event, helper) {
    },

    handleCheckBalance: function (component, event, helper) {
        component.set("v.isLoading", true);
        helper.getGiftCardBalanceApex(component, event, helper);
    },

    creditCardFormat: function (component, event, helper) {
        let creditCardNo   = component.get("v.creditCardNumber");
        let creditCardComp = component.find("creditCardNum");
        let maskedCC       = component.get("v.maskedCCNumber");

        if (creditCardNo && creditCardComp) {
            let creditCardNoWithoutSpaces = creditCardNo.split(" ").join("");

            let parts = [];
            for (let i = 0, len = creditCardNoWithoutSpaces.length; i < len; i += 4) {
                parts.push(creditCardNoWithoutSpaces.substring(i, i + 4));
            }

            let ccNumberWithSpaces = parts.join(" ");

            if (ccNumberWithSpaces.length < 10|| ccNumberWithSpaces.includes("X")) {
                creditCardComp.setCustomValidity("Credit Card number must be a valid length");
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
        let ccNumber = component.get("v.creditCardNumber");
        if (ccNumber && [4, 9, 14].includes(ccNumber.length)) {
            ccNumber += ' ';
            component.set("v.creditCardNumber", ccNumber);
        }
    },

    onChangeExpiryHandler: function (component, event, helper) {
        let ccExpiry = component.get("v.paymentMethod.CreditCardExpDate");
        if (ccExpiry.length === 2) {
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
                    expiryError.setCustomValidity("Expiration date must be in the future");
                } else {
                    expiryError.setCustomValidity("");
                }
                expiryError.reportValidity();
            }
        }
    },

    useExistingAddressChange: function (component, event, helper) {
        let useExisting = component.get("v.useExistingBillingAddress");
        component.set("v.useExistingBillingAddress", useExisting);
    },

    handleCloseModel: function (component, event, helper) {
        component.set("v.isLoading", false);
        component.set("v.isModalOpen", false);
    },

    updatePaymentRemaining: function (component, event, helper) {
        let params = event.getParam('arguments');
        if (params) {
            const paymentRemaining = params.paymentRemaining;
            const paymentMethod    = component.get("v.paymentMethod");

            paymentMethod.RequestAmount = paymentRemaining.toFixed(2).toString();

            component.set("v.paymentMethod", paymentMethod);
        }
    },

    handlePaymentEdit: function (component, event, helper) {
        const paymentMethod = event.getParam("paymentMethod");
        component.set("v.indexVal", event.getParam("indexVal"));

        component.set("v.isModalOpen", true);
        component.set("v.isEdit", true);
        component.set("v.useExistingBillingAddress", false);

        component.find("paymentFieldFirstName").set("v.value", paymentMethod.PersonInfoBillTo.FirstName);
        component.find("paymentFieldLastName").set("v.value", paymentMethod.PersonInfoBillTo.LastName);
        component.find("paymentFieldDayPhone").set("v.value", paymentMethod.PersonInfoBillTo.DayPhone);
        component.find("paymentFieldAddress").set("v.value", "");
        component.find("paymentFieldEmail").set("v.value", paymentMethod.PersonInfoBillTo.EMailID);

        let maskedCC = "XXXXXXXXXXXX" + paymentMethod.DisplayCreditCardNo;
        let maskedCCWithSpaces = "XXXX XXXX XXXX " + paymentMethod.DisplayCreditCardNo;
        component.set("v.maskedCCNumber", maskedCC);
        component.set("v.creditCardNumber", maskedCCWithSpaces);
        component.set("v.paymentMethod", paymentMethod);
    }
});