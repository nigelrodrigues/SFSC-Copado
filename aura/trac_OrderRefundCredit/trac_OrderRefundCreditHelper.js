/**
 * Created by jhoran on 7/3/2019.
 */
({
    getCreditCardAlias: function(order) {
        var creditCardAlias;

        if (order && order.PaymentMethods && order.PaymentMethods.PaymentMethod && order.PaymentMethods.PaymentMethod.length > 0) {
            var i;
            for (i = 0; i < order.PaymentMethods.PaymentMethod.length; i++) {
                if (order.PaymentMethods.PaymentMethod[i].CreditCardNo) {
                    creditCardAlias = order.PaymentMethods.PaymentMethod[i].CreditCardNo;
                }
            }
        }

        return creditCardAlias;
    },
    getLast4CardNumber: function(order) {
        var fullCreditCardNumber;

        if (order && order.PaymentMethods && order.PaymentMethods.PaymentMethod && order.PaymentMethods.PaymentMethod.length > 0) {
            var i;
            for (i = 0; i < order.PaymentMethods.PaymentMethod.length; i++) {
                if (order.PaymentMethods.PaymentMethod[i].DisplayCreditCardNo) {
                    fullCreditCardNumber = '************' + order.PaymentMethods.PaymentMethod[i].DisplayCreditCardNo;
                }
            }
        }

        return fullCreditCardNumber;
    },
    getMethodOfPayment: function(order) {
        var methodOfPayment;

        if (order && order.PaymentMethods && order.PaymentMethods.PaymentMethod && order.PaymentMethods.PaymentMethod.length > 0) {
            methodOfPayment = order.PaymentMethods.PaymentMethod[0].PaymentType;
            var i;
            for (i = 0; i < order.PaymentMethods.PaymentMethod.length; i++) {
                if (order.PaymentMethods.PaymentMethod[i].CreditCardType) {
                    methodOfPayment = order.PaymentMethods.PaymentMethod[i].CreditCardType;
                    break;
                }
            }
        }

        return methodOfPayment;
    },
    getGiftCardNumber: function(order) {
        var giftCardNumber;

        if (order && order.PaymentMethods && order.PaymentMethods.PaymentMethod && order.PaymentMethods.PaymentMethod.length > 0) {

            var i;
            for (i = 0; i < order.PaymentMethods.PaymentMethod.length; i++) {
                if (order.PaymentMethods.PaymentMethod[i].SvcNo) {
                    giftCardNumber = order.PaymentMethods.PaymentMethod[i].SvcNo;
                    break;
                }
            }
        }

        return giftCardNumber;
    },
    getOrderNumber: function(order) {
        var orderNumber;

        if (order) {
            orderNumber = order.OrderNo;
        }

        return orderNumber;
    },
    getSKU: function(orderLineItem, order) {
        var sku;

        if (orderLineItem && orderLineItem.Item) {
            sku = orderLineItem.Item.ItemID;
        }

        return sku;
    },
    getUPC: function(orderLineItem, order) {
        var upc;

        if (orderLineItem && orderLineItem.Item && orderLineItem.Item.ItemAliasList) {
            var i;
            for (i = 0; i < orderLineItem.Item.ItemAliasList.length; i++) {
                if (orderLineItem.Item.ItemAliasList[i].AliasName && orderLineItem.Item.ItemAliasList[i].AliasValue && orderLineItem.Item.ItemAliasList[i].AliasName === "ACTIVE_UPC") {
                    upc = orderLineItem.Item.ItemAliasList[i].AliasValue;
                    break;
                }
            }
        }

        return upc;
    },
    getTransactionNumber: function(orderLineItem, order) {
        var transactionNumber;

        if (orderLineItem && orderLineItem.Extn) {
            transactionNumber = orderLineItem.Extn.ExtnTransactionID;
        }

        return transactionNumber;
    },
    getDateOfSale: function(order) {
        var dateOfSale;

        if (order) {
            dateOfSale = order.OrderDate;
        }

        return dateOfSale;
    },
    getShippingMethod: function(orderLineItem, order) {
        var shippingMethod;

        if (orderLineItem) {
            shippingMethod = orderLineItem.SCAC;
        }

        return shippingMethod;
    },
    getOrderLineShippingFee: function(orderLineItem, order) {
        var shippingFee;

        if (orderLineItem && orderLineItem.LineCharges && orderLineItem.LineCharges.LineCharge) {
            var i;
            for (i = 0; i < orderLineItem.LineCharges.LineCharge.length; i++) {
                if (orderLineItem.LineCharges.LineCharge[i].ChargeCategory === "SHIPPINGCHARGE" && orderLineItem.LineCharges.LineCharge[i].ChargeAmount && orderLineItem.LineCharges.LineCharge[i].ChargeAmount > 0) {
                    shippingFee = orderLineItem.LineCharges.LineCharge[i].ChargeAmount;
                    break;
                }
            }
        }

        return shippingFee;
    },
    getShippingFee: function(order) {
        var shippingFee;

        if (order && order.OverallTotals) {
            shippingFee = order.OverallTotals.GrandShippingTotal;
        }

        return shippingFee;
    },
    getAmountChargedFullOrderSubtotal: function(order) {
        var amountCharged;

        if (order && order.OverallTotals && order.OverallTotals.LineSubTotal) {
            amountCharged = order.OverallTotals.LineSubTotal;
        }
        if (order && order.OverallTotals && order.OverallTotals.GrandDiscount) {
            amountCharged -= order.OverallTotals.GrandDiscount;
        }

        return amountCharged;
    },
    getLineAmountChargedSubtotal: function(orderLineItem, order) {
        var amountCharged;

        if (orderLineItem && orderLineItem.LineOverallTotals && orderLineItem.LineOverallTotals.ExtendedPrice) {
            amountCharged = orderLineItem.LineOverallTotals.ExtendedPrice;

            if (orderLineItem && orderLineItem.LineCharges && orderLineItem.LineCharges.LineCharge) {
                var i;
                for (i = 0; i < orderLineItem.LineCharges.LineCharge.length; i++) {
                    if (orderLineItem.LineCharges.LineCharge[i].ChargeCategory === "DISCOUNT" && orderLineItem.LineCharges.LineCharge[i].ChargeAmount && orderLineItem.LineCharges.LineCharge[i].ChargeAmount > 0) {
                        amountCharged -= orderLineItem.LineCharges.LineCharge[i].ChargeAmount;
                    }
                }
            }
        }

        return amountCharged;
    },
    getAmountChargedSubtotal: function(helper, orderLineItem, order) {
        var amountCharged;

        if (orderLineItem) {
            amountCharged = helper.getLineAmountChargedSubtotal(orderLineItem, order);
        }
        else if (order) {
            amountCharged = helper.getAmountChargedFullOrderSubtotal(order);
        }

        return amountCharged;
    },
    getUnitPrice: function(orderLineItem, order) {
        var listPrice;

        if (orderLineItem && orderLineItem.LinePriceInfo && orderLineItem.LinePriceInfo.UnitPrice) {
            listPrice = orderLineItem.LinePriceInfo.UnitPrice;
        }

        return listPrice;
    },
    getUnitPriceAfterDiscounts: function(orderLineItem, order) {
        var listPrice;

        if (orderLineItem && orderLineItem.LinePriceInfo && orderLineItem.LinePriceInfo.UnitPrice) {
            listPrice = orderLineItem.LinePriceInfo.UnitPrice;

            if (orderLineItem && orderLineItem.LineCharges && orderLineItem.LineCharges.LineCharge) {
                var i;
                for (i = 0; i < orderLineItem.LineCharges.LineCharge.length; i++) {
                    if (orderLineItem.LineCharges.LineCharge[i].ChargeCategory === "DISCOUNT" && orderLineItem.LineCharges.LineCharge[i].ChargePerUnit && orderLineItem.LineCharges.LineCharge[i].ChargePerUnit > 0) {
                        listPrice -= orderLineItem.LineCharges.LineCharge[i].ChargePerUnit;
                    }
                }
            }
        }

        return listPrice;
    },
    getTaxCharged: function(orderLineItem, order) {
        var taxAmount;

        if (orderLineItem && orderLineItem.LinePriceInfo && orderLineItem.LinePriceInfo.Tax) {
            taxAmount = orderLineItem.LinePriceInfo.Tax;
        }
        else if (!orderLineItem && order && order.OverallTotals && order.OverallTotals.GrandTax) {
            taxAmount = order.OverallTotals.GrandTax;
        }

        return taxAmount;
    },
    getAmountChargedToCreditCard: function(order) {
        var amountCharged = 0;

        if (order && order.PaymentMethods && order.PaymentMethods.PaymentMethod && order.PaymentMethods.PaymentMethod.length > 0) {
            var i;
            for (i = 0; i < order.PaymentMethods.PaymentMethod.length; i++) {
                if ((order.PaymentMethods.PaymentMethod[i].CreditCardNo || order.PaymentMethods.PaymentMethod[i].CreditCardType === 'PAYPAL') && (order.PaymentMethods.PaymentMethod[i].TotalCharged || order.PaymentMethods.PaymentMethod[i].TotalAuthorized)) {
                    if (order.PaymentMethods.PaymentMethod[i].TotalCharged > 0) {
                        amountCharged += order.PaymentMethods.PaymentMethod[i].TotalCharged;
                    }
                    else if (order.PaymentMethods.PaymentMethod[i].TotalAuthorized > 0) {
                        amountCharged += order.PaymentMethods.PaymentMethod[i].TotalAuthorized;
                    }
                }
            }
        }

        return amountCharged;
    },
    getAmountChargedToGiftCard: function(order) {
        var amountCharged = 0;

        if (order && order.PaymentMethods && order.PaymentMethods.PaymentMethod && order.PaymentMethods.PaymentMethod.length > 0) {

            var i;
            for (i = 0; i < order.PaymentMethods.PaymentMethod.length; i++) {
                if (order.PaymentMethods.PaymentMethod[i].DisplaySvcNo && order.PaymentMethods.PaymentMethod[i].TotalCharged) {
                    amountCharged += order.PaymentMethods.PaymentMethod[i].TotalCharged;
                }
            }
        }

        return amountCharged;
    },
    getBillingZipCode: function(order) {
        var billingZipCode;

        if (order && order.PersonInfoBillTo && order.PersonInfoBillTo.ZipCode) {
            billingZipCode = order.PersonInfoBillTo.ZipCode
        }

        return billingZipCode;
    },
    getBillingState: function(order) {
        var billingState;

        if (order && order.PersonInfoBillTo && order.PersonInfoBillTo.State) {
            billingState = order.PersonInfoBillTo.State
        }

        return billingState;
    },
    getBillingCountry: function(order) {
        var billingCountry;

        if (order && order.PersonInfoBillTo && order.PersonInfoBillTo.Country) {
            billingCountry = order.PersonInfoBillTo.Country
        }

        return billingCountry;
    },
    getItemQuantity: function(orderLineItem, order) {
        var itemQuantity;

        if (orderLineItem && orderLineItem.OrderedQty) {
            itemQuantity = orderLineItem.OrderedQty;
        }

        return itemQuantity;
    },
    getItemUnitPrice: function(orderLineItem, order) {
        var itemUnitPrice;

        if (orderLineItem && orderLineItem.LinePriceInfo && orderLineItem.LinePriceInfo.UnitPrice) {
            itemUnitPrice = orderLineItem.LinePriceInfo.UnitPrice;
        }

        return itemUnitPrice;
    },
    getItemName: function(orderLineItem, order) {
        var itemName;

        if (orderLineItem && orderLineItem.ItemDetails && orderLineItem.ItemDetails.PrimaryInformation) {
            itemName = orderLineItem.ItemDetails.PrimaryInformation.ShortDescription;
        }
        else if (!orderLineItem) {
            itemName = 'Full Order';
        }

        return itemName;
    },
    getItemDescription: function(orderLineItem, order) {
        var itemDescription;

        if (orderLineItem && orderLineItem.ItemDetails && orderLineItem.ItemDetails.PrimaryInformation) {
            itemDescription = orderLineItem.ItemDetails.PrimaryInformation.Description;
        }

        return itemDescription;
    },
    getOrderItemsTable: function(order, helper) {
        var orderItemsTable = '<table style="border: 1px solid black">';
        orderItemsTable += '<tr>';
        orderItemsTable += '<th>Transaction ID / Invoice Number</th>';
        orderItemsTable += '<th>SKN</th>';
        orderItemsTable += '<th>UPC</th>';
        orderItemsTable += '<th>Shipping Fee</th>';
        orderItemsTable += '</tr>';

        if (order && order.OrderLines && order.OrderLines.OrderLine) {
            var i;
            for (i = 0; i < order.OrderLines.OrderLine.length; i++) {
                var orderLineItem = order.OrderLines.OrderLine[i];
                var transactionId = helper.getTransactionNumber(orderLineItem, order);
                var sku = helper.getSKU(orderLineItem, order);
                var upc = helper.getUPC(orderLineItem, order);
                var shippingFee = helper.getOrderLineShippingFee(orderLineItem, order);

                orderItemsTable += '<tr>';
                orderItemsTable += ((transactionId) ? ('<td>' + transactionId + '</td>') : '<td></td>');
                orderItemsTable += ((sku) ? ('<td>' + sku + '</td>') : '<td></td>');
                orderItemsTable += ((upc) ? ('<td>' + upc + '</td>') : '<td></td>');
                orderItemsTable += ((shippingFee) ? ('<td>' + shippingFee + '</td>') : '<td></td>');
                orderItemsTable += '</tr>';
            }
        }

        orderItemsTable += '</table>';

        return orderItemsTable;
    }
})