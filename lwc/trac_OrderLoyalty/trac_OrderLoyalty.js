/**
 * Created by akong on 6/17/2020.
 */

import {LightningElement, api} from 'lwc';

export default class TracOrderLoyalty extends LightningElement {

    @api order;
    shipments;
    displayTotalPointsLabel;
    displayTotalPointsValue;

    connectedCallback() {
        // calculate total point label and value
        console.log('this.order.Extn: ', this.order.Extn);
        if (typeof this.order.Extn.ExtnPointsLost !== 'undefined' && this.order.Extn.ExtnPointsLost > 0) {
            this.displayTotalPointsLabel = 'Total Points Lost';
            this.displayTotalPointsValue = this.order.Extn.ExtnPointsLost;
        } else {
            this.displayTotalPointsLabel = 'Total Points Earned';
            this.displayTotalPointsValue = this.order.Extn.ExtnPointsEarned;
        }

        // prepare primeLines map
        var primeLines = {};
        console.log('typeof this.order.OrderLines: ' + typeof this.order.OrderLines);
        if (typeof this.order.OrderLines.OrderLine !== 'undefined' && this.order.OrderLines.OrderLine.length > 0) {
            console.log('this.order.OrderLines.OrderLine.length: ', this.order.OrderLines.OrderLine.length);
            for (let i=0; i < this.order.OrderLines.OrderLine.length; i++) {
                let primeLine = {};
                let orderLine = this.order.OrderLines.OrderLine[i];
                console.log('orderLine: ', orderLine);
                console.log('orderLine.ItemDetails: ', orderLine.ItemDetails);
                console.log('orderLine.ItemDetails.PrimaryInformation.ShortDescription: ' + orderLine.ItemDetails.PrimaryInformation.ShortDescription);
                primeLine.ShortDescription = orderLine.ItemDetails.PrimaryInformation.ShortDescription;
                console.log('orderLine.Status: ' + orderLine.Status);
                primeLine.Status = orderLine.Status;
                console.log('orderLine.PrimeLineNo: ' + orderLine.PrimeLineNo);
                primeLine.UnitPrice = orderLine.LinePriceInfo.UnitPrice;
                primeLine.ExtendedPrice = orderLine.LineOverallTotals.ExtendedPrice;
                console.log('primeLine: ' + primeLine);
                primeLines[orderLine.PrimeLineNo] = primeLine;
            }
        }
        console.log('primeLines: ', primeLines);

        // loop over shipments to fill out fields from primeLines
        this.shipments = [];
        console.log('typeof this.order.Shipments.Shipment: ' + typeof this.order.Shipments.Shipment);
        console.log('this.order.Shipments.Shipment.length: ' + this.order.Shipments.Shipment.length);
        if (typeof this.order.Shipments.Shipment !== 'undefined' && this.order.Shipments.Shipment.length > 0) {
            for (var i=0; i< this.order.Shipments.Shipment.length; i++) {
                var shipment = this.order.Shipments.Shipment[i];

                // instantiate newShipment
                var newShipment = {};

                // begin populating
                newShipment.ShipNode = shipment.ShipNode.ShipNode;
                newShipment.ShipmentNo = shipment.ShipmentNo;
                newShipment.InvoiceNo = shipment.InvoiceNo;
                newShipment.ExtnLoyaltyNo = shipment.Extn.ExtnLoyaltyNo;
                newShipment.ExtnLoyaltyTier = shipment.Extn.ExtnLoyaltyTier;
                newShipment.ExtnPointsEarned = shipment.Extn.ExtnPointsEarned;

                // loop over order invoice list
                newShipment.InvoiceNo = '';
                if (typeof shipment.OrderInvoiceList.OrderInvoice !== 'undefined' && shipment.OrderInvoiceList.OrderInvoice.length > 0) {
                    for (let x=0; x<shipment.OrderInvoiceList.OrderInvoice.length; x++) {
                        let invoice = shipment.OrderInvoiceList.OrderInvoice[x];
                        newShipment.InvoiceNo += (newShipment.InvoiceNo.length>0 ? ', ' : '') + invoice.InvoiceNo;
                    }
                }

                // loop over shipment lines
                newShipment.ShipmentLines = [];
                console.log('typeof shipment.ShipmentLines.ShipmentLine: ' + typeof shipment.ShipmentLines.ShipmentLine);
                console.log('shipment.ShipmentLines.ShipmentLine.length: ' + shipment.ShipmentLines.ShipmentLine.length);
                if (typeof shipment.ShipmentLines.ShipmentLine !== 'undefined' && shipment.ShipmentLines.ShipmentLine.length > 0) {
                    for (let x=0; x<shipment.ShipmentLines.ShipmentLine.length; x++) {
                        let shipmentLine = shipment.ShipmentLines.ShipmentLine[x];
                        let primeLine = primeLines[shipmentLine.PrimeLineNo];
                        let newShipmentLine = {};
                        newShipmentLine.ItemID = shipmentLine.ItemID;
                        newShipmentLine.Quantity = shipmentLine.Quantity;
                        newShipmentLine.PrimeLineNo = shipmentLine.PrimeLineNo;

                        console.log('primeLine.ShortDescription: ' + primeLine.ShortDescription);
                        try {
                            newShipmentLine.ShortDescription = primeLine.ShortDescription;
                            newShipmentLine.UnitPrice = primeLine.UnitPrice;
                            newShipmentLine.Status = primeLine.Status;
                            newShipmentLine.Idx = shipment.ShipmentNo + '-' + x;
                        } catch (error) {
                            console.error(error);
                        }
                        //this.order.Shipments.Shipment[i].ShipmentLines.ShipmentLine[x].Idx = shipment.ShipmentNo + '-' + i;
                        //console.log('this.order.Shipments.Shipment[i].ShipmentLines.ShipmentLine[x].Idx: ' + this.order.Shipments.Shipment[i].ShipmentLines.ShipmentLine[x].Idx);
                        newShipment.ShipmentLines.push( newShipmentLine );
                    }
                }
                this.shipments.push( newShipment );
            }
            console.log('this.order.Shipments.Shipment: ', this.order.Shipments.Shipment);
        }
    }
}