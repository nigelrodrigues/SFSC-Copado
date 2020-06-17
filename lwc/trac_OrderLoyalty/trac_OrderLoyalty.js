/**
 * Created by akong on 6/17/2020.
 */

import {LightningElement, api} from 'lwc';

export default class TracOrderLoyalty extends LightningElement {

    @api order;
    displayTotalPointsLabel;
    displayTotalPointsValue;
    items;

    connectedCallback() {
        if (typeof this.order.Extn.ExtnPointsLost !== undefined && typeof this.order.Extn.ExtnPointsLost > 0) {
            this.displayTotalPointsLabel = 'Total Points Lost';
            this.displayTotalPointsValue = this.order.Extn.ExtnPointsLost;
        } else {
            this.displayTotalPointsLabel = 'Total Points Earned';
            this.displayTotalPointsValue = this.order.Extn.ExtnPointsEarned;
        }

        this.items = {};
        console.log('this.order.OrderLines.length: ', this.order.OrderLines.length);
        // for (let i=0; i<this.order.OrderLines.length; i++) {
        //     let item = {};
        //     let orderLine = this.order.OrderLines[i];
        //     console.log('orderLine: ', orderLine);
        //     item.ItemId = orderLine.Item.ItemId;
        //     item.ItemShortDesc = orderLine.Item.ItemShortDesc;
        //     item.Status = orderLine.Item.Status;
        //     items[item.itemId] = item;
        // }
        // console.log('items: ', items);
    }
}