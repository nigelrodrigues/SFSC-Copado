/**
 * @description: Controller for SPA Calculator
 * @author     : Piyush Bansal, Traction on Demand.
 * @date       : 02/11/2020
 */
import {LightningElement, track, api, wire} from "lwc";
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import getOrderLineItems from "@salesforce/apex/trac_SPA_CalculatorController.getOrderAdjustments";

export default class TracSpaCalculator extends LightningElement {
    @api orderNumber;
    @track orderLineItems = [];

    handleOrderNumberChange(evt) {
        this.orderNumber = evt.target.value;
    }

    handleRefreshSPA(evt) {
        this.getOrder();
    }

    getOrder() {
        if (this.orderNumber) {
            getOrderLineItems({
                orderNumber: this.orderNumber
            })
            .then(result => {
                this.orderLineItems = result;
                if (result && result.length === 0) {
                    this.showNotification('No Results', 'No Orders were found matching that order number', 'warning');
                }
            })
            .catch(err => {
                this.error = err;
            });
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
}