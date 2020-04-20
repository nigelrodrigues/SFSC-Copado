/**
 * Created by jhoran on 3/3/2020.
 */

import {LightningElement, api, track, wire} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import getSPATypes from "@salesforce/apex/trac_SPA_CalculatorController.getSPATypes";
import setAdjustedOrderLineItem from "@salesforce/apex/trac_SPA_CalculatorController.setOrderAdjustments";

export default class TracSpaOrderLineItem extends LightningElement {
    @api orderlineitem;

    @track orderLineItemToAdjust;
    @track showModal = false;
    @track totalPrice = 0;
    @track refund = 0;
    @track typeValue = 'Sale_Price_Online_SPA';
    @track adjusted_amount_label = 'Subtracted Adjusted Amount:';
    @track adjusted_price_label = 'Adjusted Price:';
    @track total_price_label = "Total Price:";
    @track selectedAction = 'Update';

    @track maxDiscountPercent = 50;

    @track params = {
        actions: {visible: true, disabled: false},
        adjusted_amount: {visible: false, disabled: false},
        adjusted_price: {visible: true, disabled: false},
        adjusted_tax: {visible: true, disabled: true},
        calculate: {visible: true, disabled: false},
        extended_price: {visible: true, disabled: true},
        spa_comments: {visible: true, disabled: false},
        submit: {visible: true, disabled: false},
        types: {visible: true, disabled: false}
    };

    @track SPATypes = [{
        label: 'Sale Price Online (SPA)',
        value: 'Sale_Price_Online_SPA'
    }];

    @wire(getSPATypes)
    fetchSPATypes({data, error}) {
        let tempSpaTypes = [];

        if (data) {
            data.forEach(spaType => {
                tempSpaTypes.push({
                    label: spaType.Label,
                    value: spaType.DeveloperName
                });
            });
            this.SPATypes = tempSpaTypes;
        }
    }

    get actionOptions() {
        return [
            {label: "Update", value: "Update"},
            {label: "% Off", value: "Percent Off"},
            {label: "$ Off", value: "Dollar Off"}
        ];
    }

    get isCurrencyAction() {
        return (this.selectedAction === "Dollar Off" || this.selectedAction === "Update");
    }

    get isPercentAction() {
        return this.selectedAction === "Percent Off";
    }

    toggleModal(evt) {
        try {
            this.orderLineItemToAdjust = {...this.orderlineitem};
            this.orderLineItemToAdjust.line_details = {...this.orderlineitem.line_details};
            this.orderLineItemToAdjust.amounts = {...this.orderlineitem.amounts};
            this.orderLineItemToAdjust.customer = {...this.orderlineitem.customer};
            this.orderLineItemToAdjust.state = {...this.orderlineitem.state};
            this.orderLineItemToAdjust.log = {...this.orderlineitem.log};

            this.resetCalculator();
            this.openShowModal();
        }
        catch (error) {
            console.log('error',error);
        }
    }

    changeVisibility(param, isVisible, isEnabled) {
        if (isVisible !== null) {
            this.params[param].visible = isVisible;
        }

        if (isEnabled !== null) {
            this.params[param].disabled = !isEnabled;
        }
    }

    handleChangeAction(event) {
        console.log('Enter Method => handleChangeAction');
        this.selectedAction = event.detail.value;
        this.setUpCalculatorUI(this.typeValue);
    }

    handleTypeOptionsChange(selectedVal) {
        console.log('Enter Method => handleTypeOptionsChange');
        this.resetCalculator();
        if (selectedVal) {
            this.typeValue = selectedVal;
        }
        this.setUpCalculatorUI(selectedVal);
    }

    handleAmountChange(event) {
        console.log('Enter Method => handleAmountChange');
        const attrName = event.target.name;
        this.orderLineItemToAdjust.amounts[attrName] = event.detail.value;
    }

    handleAmountBlur(event) {//TODO: add this onblur of amount fields when it's ready to be tested
        console.log('Enter Method => handleAmountBlur');
        this.calculateAmounts();
    }

    handleStateChange(event) {
        console.log('Enter Method => handleStateChange');
        const attrName = event.target.name;
        this.orderLineItemToAdjust.state[attrName] = event.detail.value;
    }

    handleChangeAdjustmentType(event) {
        console.log('Enter Method => handleChangeAdjustmentType');
        this.typeValue = event.detail.value;
        try {
            this.setUpCalculatorUI(event.detail.value);
        }
        catch (error) {
            console.log('error',error);
        }
    }

    setUpCalculatorUI(selectedValue) {
        console.log('Enter Method => setUpCalculatorUI');

        this.resetLabels();
        this.resetValues();
        this.resetUI();

        this.setUpCalculatorLabels(selectedValue);
        this.setUpCalculatorValues(selectedValue);
        this.changeAdjustedLabel();
    }

    setUpCalculatorLabels(selectedValue) {
        console.log('Enter Method => setUpCalculatorLabels');
        switch (selectedValue) {

            case "Tax_Accommodation_Exempt":
                this.taxTemplate();
                break;

            case "Gift_Wrap_Issues":
            case "Return_Label_Fee":
            case "Shipping_Refunds_ACC_PRO":
                this.adjusted_price_label = "Adjusted Fee:";
                this.total_price_label = "Total Fee:";
                this.presetAmountTemplate();
                break;

            case "X10_PRO":
            case "X15_off_ACC":
            case "X20_off_ACC":
                this.percentTemplate();
                this.setPredefinedCalcUI()
                break;

            case "X20_Off_PRO":
            case "X30_Off_PRO":
                this.dollarTemplate();
                this.setPredefinedCalcUI()
                break;

            case "Exchange_SPA":
                this.dollarTemplate();
                break;

            case "Associate_Discount_PRO":
                this.percentTemplate();
                break;

            case "BOGO_PRO":
                this.updateTemplate();
                break;

            case "MORE_PRO":
                this.percentTemplate();
                break;

            case "Other_Dollar_off_PRO":
                this.dollarTemplate();
                break;

            case "Price_Match_CPM":
                this.updateTemplate();
                break;

            default:
                this.defaultTemplate();
        }
    }

    setUpCalculatorValues(selectedValue) {
        console.log('Enter Method => setUpCalculatorValues');

        let extendedPrice = parseFloat(this.orderLineItemToAdjust.amounts.extended_price);
        let lineTax = parseFloat(this.orderLineItemToAdjust.amounts.line_tax);
        let shippingFee = parseFloat(this.orderLineItemToAdjust.amounts.shipping_fee);
        let shippingTax = parseFloat(this.orderLineItemToAdjust.amounts.shipping_tax);
        let returnLabelFee = parseFloat(this.orderLineItemToAdjust.amounts.return_label_fee);
        let giftWrapFee = parseFloat(this.orderLineItemToAdjust.amounts.gift_wrap_fee);

        switch (selectedValue) {

            case "Tax_Accommodation_Exempt":
                this.orderLineItemToAdjust.amounts.adjusted_price = extendedPrice;
                this.orderLineItemToAdjust.amounts.adjusted_tax = lineTax;
                break;

            case "Gift_Wrap_Issues":
                this.orderLineItemToAdjust.amounts.adjusted_price = extendedPrice - giftWrapFee;
                this.orderLineItemToAdjust.amounts.adjusted_amount = giftWrapFee;
                break;

            case "Return_Label_Fee":
                this.orderLineItemToAdjust.amounts.adjusted_price = extendedPrice - returnLabelFee;
                this.orderLineItemToAdjust.amounts.adjusted_amount = returnLabelFee;
                this.orderLineItemToAdjust.amounts.adjusted_tax = 0;
                break;

            case "Shipping_Refunds_ACC_PRO":
                this.orderLineItemToAdjust.amounts.adjusted_price = extendedPrice - shippingFee;
                this.orderLineItemToAdjust.amounts.adjusted_tax = lineTax - shippingTax;
                this.orderLineItemToAdjust.amounts.adjusted_amount = shippingFee;
                break;

            case "X10_PRO":
                this.orderLineItemToAdjust.amounts.adjusted_amount = 10;
                break;

            case "X15_off_ACC":
                this.orderLineItemToAdjust.amounts.adjusted_amount = 15;
                break;

            case "X20_off_ACC":
            case "X20_Off_PRO":
                this.orderLineItemToAdjust.amounts.adjusted_amount = 20;
                break;

            case "X30_Off_PRO":
                this.orderLineItemToAdjust.amounts.adjusted_amount = 30;
                break;

            case "Exchange_SPA":
            case "Associate_Discount_PRO":
            case "MORE_PRO":
            case "Other_Dollar_off_PRO":
                this.orderLineItemToAdjust.amounts.adjusted_amount = 0;
                break;

            case "Price_Match_CPM":
                this.updateTemplate();
                break;

            default:
                this.defaultTemplate();
        }

        this.calculateAmounts();
    }

    setPredefinedCalcUI() {
        console.log('Enter Method => setPredefinedCalcUI');
        this.changeVisibility('adjusted_amount', null, false);
        this.changeVisibility('adjusted_price', true, false);
    }

    changeAdjustedLabel() {
        console.log('Enter Method => changeAdjustedLabel');
        switch (this.selectedAction) {
            case "Percent Off":
                this.orderLineItemToAdjust.amounts.adjust_type = "Percent";
                this.adjusted_amount_label = "Percent Off Amount:";
                break;
            case "Dollar Off":
                this.orderLineItemToAdjust.amounts.adjust_type = "Dollar";
                this.adjusted_amount_label = "Subtracted Dollar Amount:";
                break;
            default:
                this.orderLineItemToAdjust.amounts.adjust_type = "Update";
                this.adjusted_amount_label = "Subtracted Adjusted Amount:";
        }
    }

    defaultTemplate() {
        console.log('Enter Method => defaultTemplate');

        this.resetLabels();
        this.resetValues();
        this.resetUI();

        switch (this.selectedAction) {
            case "Percent Off":
            case "Dollar Off":
                this.changeVisibility('adjusted_amount', true, true);
                this.changeVisibility('adjusted_price', true, false);
                break;
            default: {
                this.changeVisibility('adjusted_amount', false, false);
                this.changeVisibility('adjusted_price', true, true);
            }
        }
    }

    taxTemplate() {
        console.log('Enter Method => taxTemplate');
        this.selectedAction = "Update";

        this.changeVisibility('actions', null, false);
        this.changeVisibility('adjusted_amount', false, false);
        this.changeVisibility('adjusted_price', null, false);
        this.changeVisibility('adjusted_tax', null, true);
    }

    feeTemplate() {
        console.log('Enter Method => feeTemplate');
        this.adjusted_amount_label = "Subtracted Adjusted Amount:";
        this.selectedAction = "Update";

        this.changeVisibility('extended_price', true, false);
        this.changeVisibility('actions', null, false);
        this.changeVisibility('adjusted_amount', true, false);
        this.changeVisibility('adjusted_price', null, false);
        this.changeVisibility('adjusted_tax', null, false);
    }


    percentTemplate() {
        console.log('Enter Method => percentTemplate');
        this.adjusted_amount_label = "Percent Off Amount:";
        this.selectedAction = "Percent Off";

        this.changeVisibility('extended_price', true, false);
        this.changeVisibility('actions', null, false);
        this.changeVisibility('adjusted_amount', true, true);
        this.changeVisibility('adjusted_price', null, false);
        this.changeVisibility('adjusted_tax', null, false);
    }

    dollarTemplate() {
        console.log('Enter Method => dollarTemplate');
        this.adjusted_amount_label = "Subtracted Dollar Amount:";
        this.orderLineItemToAdjust.amounts.adjusted_amount = 0;
        this.selectedAction = "Dollar Off";
        this.totalPrice = 0;
        this.orderLineItemToAdjust.amounts.total_diff = 0;

        this.changeVisibility('extended_price', true, false);
        this.changeVisibility('actions', null, false);
        this.changeVisibility('adjusted_amount', true, true);
        this.changeVisibility('adjusted_price', null, false);
        this.changeVisibility('adjusted_tax', null, false);
    }

    updateTemplate() {
        console.log('Enter Method => updateTemplate');
        this.resetLabels();
        this.orderLineItemToAdjust.amounts.adjusted_amount = 0;
        this.selectedAction = "Update";
        this.totalPrice = 0;
        this.orderLineItemToAdjust.amounts.total_diff = 0;
        this.orderLineItemToAdjust.amounts.adjusted_price = this.orderLineItemToAdjust.amounts.extended_price;

        this.changeVisibility('actions', null, false);
        this.changeVisibility('adjusted_amount', false, false);
        this.changeVisibility('adjusted_price', null, true);
        this.changeVisibility('adjusted_tax', null, false);
    }

    presetAmountTemplate() {
        console.log('Enter Method => taxTemplate');
        this.selectedAction = "Update";

        this.changeVisibility('actions', null, false);
        this.changeVisibility('adjusted_amount', true, false);
        this.changeVisibility('adjusted_price', true, false);
        this.changeVisibility('adjusted_tax', true, false);
    }

    calculateAmounts() {
        console.log('Enter Method => calculateAmounts');

        try {
            let extendedPrice = parseFloat(this.orderLineItemToAdjust.amounts.extended_price);
            let lineTax = parseFloat(this.orderLineItemToAdjust.amounts.line_tax);
            let adjustedAmount = parseFloat(this.orderLineItemToAdjust.amounts.adjusted_amount);
            let adjustedTax = parseFloat(this.orderLineItemToAdjust.amounts.adjusted_tax);

            let maximumDiscountedAmount = extendedPrice * (this.maxDiscountPercent / 100);

            switch (this.selectedAction) {
                case "Percent Off":
                    let discountAmount = extendedPrice * (adjustedAmount / 100);
                    this.orderLineItemToAdjust.amounts.adjusted_price = extendedPrice - discountAmount;
                    break;
                case "Dollar Off":
                    this.orderLineItemToAdjust.amounts.adjusted_price = extendedPrice - adjustedAmount;
                    break;
                default:
            }

            this.adjustTax();

            let myPrice = parseFloat(this.orderLineItemToAdjust.amounts.adjusted_price);
            let myTax = parseFloat(this.orderLineItemToAdjust.amounts.adjusted_tax);

            this.totalPrice = myPrice + myTax;
            this.orderLineItemToAdjust.amounts.total_diff = (extendedPrice + lineTax) - this.totalPrice;

            this.validateAdjustment();
        }
        catch (error) {
            console.log('error', error);
        }
    }

    adjustTax() {
        console.log('Enter Method => adjustTax');
        try {
            let newTax = 0;
            let adjustedPrice = parseFloat(this.orderLineItemToAdjust.amounts.adjusted_price);
            let adjustedTax = parseFloat(this.orderLineItemToAdjust.amounts.adjusted_tax);

            let lineTax = parseFloat(this.orderLineItemToAdjust.amounts.line_tax);
            let extendedPrice = parseFloat(this.orderLineItemToAdjust.amounts.extended_price);
            let taxPercent = lineTax / extendedPrice;

            if (!adjustedPrice) {
                adjustedPrice = 0;
            }

            newTax = taxPercent * adjustedPrice;//TODO: Vertex tax adjustment will go here future state

            switch (this.typeValue) {
                case "Tax_Accommodation_Exempt": //Tax Accommodation/Exempt
                case "Shipping_Refunds_ACC_PRO": //shipping
                case "Return_Label_Fee": //returns
                    break;

                default:
                    this.orderLineItemToAdjust.amounts.adjusted_tax = newTax;
            }
        }
        catch (error) {
            console.log('error',error);
        }
    }

    validateAdjustment() {
        let isValid = true;

        let extendedPrice = parseFloat(this.orderLineItemToAdjust.amounts.extended_price);
        let lineTax = parseFloat(this.orderLineItemToAdjust.amounts.line_tax);
        let adjustedAmount = parseFloat(this.orderLineItemToAdjust.amounts.adjusted_amount);
        let adjustedPrice = parseFloat(this.orderLineItemToAdjust.amounts.adjusted_price);
        let adjustedTax = parseFloat(this.orderLineItemToAdjust.amounts.adjusted_tax);

        let maximumDiscountAmount = extendedPrice * (this.maxDiscountPercent / 100);
        let adjustedRefund = (extendedPrice + lineTax) - (adjustedPrice + adjustedTax);
        let adjustedDiscount = extendedPrice - adjustedPrice;
        let adjustedTaxDiscount = lineTax - adjustedTax;

        if (adjustedPrice < 0) {
            this.showNotification("Negative Price", "Adjusted Price Can't be Negative!", "error");
            isValid = false;
        }
        else if (adjustedTax < 0) {
            this.showNotification("Negative Tax", "Adjusted Tax Can't be Negative!", "error");
            isValid = false;
        }
        else if (adjustedRefund < 0 || adjustedDiscount < 0) {
            this.showNotification("Negative Adjustment", "Adjusted Price Greater than the Ext Price!", "error");
            isValid = false;
        }
        if (adjustedTaxDiscount < 0) {
            this.showNotification("Negative Adjustment", "Adjusted Tax Greater than the Line Tax!", "error");
            isValid = false;
        }
        else if (adjustedDiscount > maximumDiscountAmount) {//TODO: add admin permissions here
            this.showNotification('Refund Over Limit', 'No Refunds Higher Than ' + this.maxDiscountPercent.toString() + '%', 'error');
            isValid = false;
        }
        else if (this.selectedAction === "Percent Off" && this.isFloat(adjustedAmount)) {
            this.showNotification('ERROR', 'Percent amount must be a whole number!', 'error');
            isValid = false;
        }

        if (isValid) {
            this.changeVisibility('submit', null, true);
        }
        else {
            this.changeVisibility('submit', null, false);
        }

        return isValid;
    }

    resetCalculator() {
        console.log('Enter Method => resetCalculator');
        this.resetLabels();
        this.typeValue = "Sale_Price_Online_SPA";
        this.selectedAction = "Update";
        this.orderLineItemToAdjust.amounts.adjust_type = "Update";
        this.resetValues();
        this.resetUI();
    }

    resetValues() {
        console.log('Enter Method => resetValues');
        this.orderLineItemToAdjust.amounts.extended_price = this.orderlineitem.amounts.extended_price;
        this.orderLineItemToAdjust.amounts.adjusted_price = this.orderlineitem.amounts.extended_price;
        this.orderLineItemToAdjust.amounts.adjusted_tax = this.orderlineitem.amounts.line_tax;
        this.orderLineItemToAdjust.amounts.adjusted_amount = 0;
        this.orderLineItemToAdjust.amounts.total_diff = 0;

        let myPrice = parseFloat(this.orderLineItemToAdjust.amounts.adjusted_price);
        let myTax = parseFloat(this.orderLineItemToAdjust.amounts.adjusted_tax);

        this.totalPrice = parseFloat(myPrice + myTax);
    }

    resetUI() {
        console.log('Enter Method => resetUI');
        this.changeVisibility('actions', true, true);
        this.changeVisibility('adjusted_amount', false, true);
        this.changeVisibility('adjusted_price', true, true);
        this.changeVisibility('adjusted_tax', true, false);
        this.changeVisibility('calculate', true, true);
        this.changeVisibility('extended_price', true, false);
        this.changeVisibility('spa_comments', true, true);
        this.changeVisibility('submit', null, true);
        this.changeVisibility('types', null, true);
    }

    resetLabels() {
        console.log('Enter Method => resetLabels');
        this.adjusted_amount_label = "Subtracted Adjusted Amount:";
        this.adjusted_price_label = "Adjusted Price:";
        this.total_price_label = "Total Price:";
    }

    handleSubmit() {
        console.log('Enter Method => handleSubmit');
        let isValid = this.validateAdjustment();
        if (isValid) {
            this.fixVariableTypes();
            //Call Apex Here
            setAdjustedOrderLineItem({
                adjustmentId: this.orderLineItemToAdjust.id.toString(),
                requestJSON: JSON.stringify(this.orderLineItemToAdjust)
            }).then(result => {
                if (result) {
                    this.dispatchEvent(new CustomEvent('refreshspa'));
                    this.showNotification('SUCCESS', 'Record Updated Successfully', 'success');
                } else {
                    this.showNotification('ERROR', result, 'error');
                }
                this.closeModal();
            }).catch(error => {
                console.log('error', error);
                this.closeModal();
            })
        }
    }

    fixVariableTypes() {
        const amountKeys = Object.keys(this.orderLineItemToAdjust.amounts);
        for (const key of amountKeys) {
            if (key !== "adjust_type") {
                this.orderLineItemToAdjust.amounts[key] = parseFloat(this.orderLineItemToAdjust.amounts[key]);
            }
        }
    }

    showNotification(title, message, variant) {
        const evt = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(evt);
    }

    isFloat(n) {
        return Number(n) === n && n % 1 !== 0;
    }

    openShowModal() {
        this.showModal = true;
    }

    closeModal() {
        this.showModal = false;
    }
}