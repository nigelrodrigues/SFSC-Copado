/**
 * @name trac_PromoCodeSearch
 * @author Daniel Labonte, Traction on Demand
 * @date 2019-07-04
 * @description js controller for the Promo Code Search Component
 */

import { LightningElement, wire, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getCurrentCasePromoCode from '@salesforce/apex/trac_PromoCodeSearchController.getCurrentCasePromoCode';
import applyPromoCode from '@salesforce/apex/trac_PromoCodeSearchController.applyPromoCode';
import getPromoPicklistOptions from '@salesforce/apex/trac_PromoCodeSearchController.getPromoPicklistOptions';
import { labels } from './trac_PromoCodeSearchLabels';

import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import PROMO_CODE_REASON from '@salesforce/schema/Promo_Code__c.Promo_Code_Reason__c';
import PROMO_CODE_AMOUNT from '@salesforce/schema/Promo_Code__c.Amount_List__c';
import PROMO_CODE_OBJECT from '@salesforce/schema/Promo_Code__c';


const MAX_ALLOWED_PROMO_CODES = 1;

export default class PromoCodeSearch extends LightningElement {
    @api recordId;
    labels = labels;

    @wire(getObjectInfo,
          {
              objectApiName: PROMO_CODE_OBJECT
          }
        )
        objectInfo;

    @wire(getPicklistValues,
          {
              recordTypeId : '$objectInfo.data.defaultRecordTypeId',
              fieldApiName : PROMO_CODE_REASON
          }
        )
        reasonPicklistValues;

    @wire(getPicklistValues,
          {
              recordTypeId : '$objectInfo.data.defaultRecordTypeId',
              fieldApiName : PROMO_CODE_AMOUNT
          }
        )
        amountPicklistValues;
    
    @track isBusy = false;
    @track promoApplied = false;
    @track promoSearchAmount;
    @track promoReason;
    @track selectedPromoCode;

    handleAmountChange(e) {
        this.promoSearchAmount = e.detail.value;
    }

    handleReasonChange(e) {
        this.promoReason = e.detail.value;
    }

    handleSearchClick(e) {
        getCurrentCasePromoCode({'caseId': this.recordId}).then(result => {
            debugger;
            if (result >= MAX_ALLOWED_PROMO_CODES) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: labels.lblWarning,
                        message: labels.lblMaxPromoCodeMessage,
                        variant: 'warning'
                    })
                );
            }
            else {
                this.search(this.promoSearchAmount, this.promoReason);
            }
        });
    }

    search(value, reason) {
        if(value === undefined || value === '') {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: labels.lblError,
                    message: 'Please Select a Promo Code',
                    variant: 'error'
                })
            );
        }
        else if(reason === undefined || reason === '')
        {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: labels.lblError,
                    message: 'Please Select a Promo Code Reason',
                    variant: 'error'
                })
            );
        }
        else {
            this.isSearching = true;
            applyPromoCode({'value': value, 'reason': reason, 'caseId': this.recordId}).then(result => {

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