/**
 * Created by akong on 6/11/2020.
 */

import {LightningElement, api, track} from 'lwc';

export default class TracLoyaltyTransactionHistoryRow extends LightningElement {
    @api transactionData;
    @track showDetails;

    // component init
    connectedCallback() {
        this.showDetails = this.transactionData.showDetails;
    }

    toggleData(event) {
        this.showDetails = !this.showDetails;
    }

    get iconChevron() {
        return this.showDetails ? 'utility:chevrondown' : 'utility:chevronright';
    }
}