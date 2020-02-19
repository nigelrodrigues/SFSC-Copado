/**
 * @name trac_PromoCodeSearch
 * @author Daniel Labonte, Traction on Demand
 * @date 2019-07-04
 * @description js controller for the Promo Code Search Component
 */

import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getCurrentCasePromoCode from '@salesforce/apex/trac_PromoCodeSearchController.getCurrentCasePromoCode';
import applyPromoCode from '@salesforce/apex/trac_PromoCodeSearchController.applyPromoCode';
import getPromoPicklistOptions from '@salesforce/apex/trac_PromoCodeSearchController.getPromoPicklistOptions';
import { labels } from './trac_PromoCodeSearchLabels';

const MAX_ALLOWED_PROMO_CODES = 1;

export default class PromoCodeSearch extends LightningElement {
    @api recordId;
    labels = labels;
    @track isBusy = false;
    @track promoApplied = false;
    @track initialSearchAmount;
    @track selectedPromoCode;
    @track picklistOptions = [ {
        "value" : "$5.00",
        "label" : "$5.00"
    }, {
        "value" : "5%",
        "label" : "5%"
    }, {
        "value" : "$10.00",
        "label" : "$10.00"
    }, {
        "value" : "10%",
        "label" : "10%"
    }, {
        "value" : "$15.00",
        "label" : "$15.00"
    }, {
        "value" : "15%",
        "label" : "15%"
    }, {
        "value" : "$20.00",
        "label" : "$20.00"
    }, {
        "value" : "20%",
        "label" : "20%"
    }, {
        "value" : "$25.00",
        "label" : "$25.00"
    }, {
        "value" : "25%",
        "label" : "25%"
    }, {
        "value" : "$30.00",
        "label" : "$30.00"
    }, {
        "value" : "30%",
        "label" : "30%"
    }, {
        "value" : "$35.00",
        "label" : "$35.00"
    }, {
        "value" : "35%",
        "label" : "35%"
    }, {
        "value" : "$40.00",
        "label" : "$40.00"
    }, {
        "value" : "40%",
        "label" : "40%"
    }, {
        "value" : "$45.00",
        "label" : "$45.00"
    }, {
        "value" : "45%",
        "label" : "45%"
    }, {
        "value" : "$50.00",
        "label" : "$50.00"
    }, {
        "value" : "50%",
        "label" : "50%"
    }, {
        "value" : "$55.00",
        "label" : "$55.00"
    }, {
        "value" : "55%",
        "label" : "55%"
    }, {
        "value" : "$60.00",
        "label" : "$60.00"
    }, {
        "value" : "60%",
        "label" : "60%"
    }, {
        "value" : "$65.00",
        "label" : "$65.00"
    }, {
        "value" : "65%",
        "label" : "65%"
    }, {
        "value" : "$70.00",
        "label" : "$70.00"
    }, {
        "value" : "70%",
        "label" : "70%"
    }, {
        "value" : "$75.00",
        "label" : "$75.00"
    }, {
        "value" : "75%",
        "label" : "75%"
    }, {
        "value" : "$80.00",
        "label" : "$80.00"
    }, {
        "value" : "80%",
        "label" : "80%"
    }, {
        "value" : "$85.00",
        "label" : "$85.00"
    }, {
        "value" : "85%",
        "label" : "85%"
    }, {
        "value" : "$90.00",
        "label" : "$90.00"
    }, {
        "value" : "90%",
        "label" : "90%"
    }, {
        "value" : "$95.00",
        "label" : "$95.00"
    }, {
        "value" : "95%",
        "label" : "95%"
    }, {
        "value" : "$100.00",
        "label" : "$100.00"
    }, {
        "value" : "100%",
        "label" : "100%"
    }, {
        "value" : "Free Next Day Delivery",
        "label" : "Free Next Day Delivery"
    }, {
        "value" : "Free Rush Delivery",
        "label" : "Free Rush Delivery"
    }, {
        "value" : "Free Saturday Delivery",
        "label" : "Free Saturday Delivery"
    }, {
        "value" : "Free Standard Shipping",
        "label" : "Free Standard Shipping"
    } ];

//TODO: figure out how to make this work properly
    // get picklistOptions() {
    //     getPromoPicklistOptions().then(result => {
    //         var options = result.returnValuesMap['picklistOptions'];
    //         console.log('options',options);
    //         return options;
    //     });
    // }

    handleInitialAmountChange(e) {
        this.initialSearchAmount = e.detail.value;
    }

    handleSearchClick(e) {
        getCurrentCasePromoCode({'caseId': this.recordId}).then(result => {
            if (result >= MAX_ALLOWED_PROMO_CODES) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: labels.lblWarning,
                        message: labels.lblMaxPromoCodeMessage,
                        variant: 'warning'
                    })
                );
            } else {
                console.log('this.initialSearchAmount',this.initialSearchAmount);
                this.search(this.initialSearchAmount);
            }
        });
    }

    search(value) {
        console.log('value',value);
        if(value === undefined || value === '') {
        } else {
            this.isSearching = true;
            applyPromoCode({'value': value, 'caseId': this.recordId}).then(result => {

                console.log('result',result);
                if (result == null) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: labels.lblError,
                            message: 'Connection Error',
                            variant: 'error'
                        })
                    );
                } else {
                    if(result.isSuccess) {
                        this.selectedPromoCode = result.returnValuesMap['promoCode'];
                        this.promoApplied = true;
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: labels.lblSuccess,
                                message: labels.lblSuccessMessageSingular,
                                variant: 'success'
                            })
                        );
                    } else {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: labels.lblError,
                                message: result.message,
                                variant: 'error'
                            })
                        );
                    }
                }
                this.isSearching = false;
            });
        }
    }
}