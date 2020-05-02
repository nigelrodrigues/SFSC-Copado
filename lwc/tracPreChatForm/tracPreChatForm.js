/**
 * @description Pre chat form for the hudson's bay community
 * @name tracPreChatForm
 * @author Daniel Labonte, Traction on Demand
 * @date 2019-08-29
 */

import {LightningElement, track, api, wire} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import strUserId from '@salesforce/apex/trac_ContactSupportFormController.getGuestUserId';

import {getPicklistValues} from 'lightning/uiObjectInfoApi';

import getCaseTypeValidations from '@salesforce/apex/trac_ContactSupportFormController.getCaseTypeValidations';
import {labels, fieldLabels} from './tracPreChatFormLabels';


import {getObjectInfo} from 'lightning/uiObjectInfoApi';
import CASE_OBJECT from '@salesforce/schema/Case';
import CASETYPE_FIELD from '@salesforce/schema/Case.Community_Case_Type__c';


const ORDER_CLASS = 'order-number custom-input-field';
const REQUIRED_CLASS = 'custom-required';


export default class PreChatForm extends LightningElement {
    @api get businessUnit(){
        return this._businessUnit;
    }
    set businessUnit(value){
        this._businessUnit = value;
    }

    @api get language(){
        return this._language;
    }
    set language(value){
        this._language = value;
    }

    @api caseRecordTypeId;

    @track caseTypePickValues;
    @wire(getObjectInfo, {objectApiName: CASE_OBJECT})
    objectInfo;

    @wire(getPicklistValues, {recordTypeId: '$caseRecordTypeId', fieldApiName: CASETYPE_FIELD})
    caseTypePicklistValues({ error, data }) {
        if (data) {
            const values = [...data.values];
            let index;
            for (var i = 0; i < values.length; i += 1) {
                if (values[i]['value'] === 'Store Experience') {
                    index = i;
                }
            }
            values.splice(index, 1);
            this.caseTypePickValues = values;
        } else if (error) {
         console.log('error  in callback');
        }
    }

    labels = labels;  // any visible UI text on the layout

    // lightning-input field labels
    placeholders = {
        email: fieldLabels.SuppliedEmail,
        firstName: fieldLabels.FirstName,
        lastName: fieldLabels.LastName,
        type: fieldLabels.Type,
        order: {
            optional: fieldLabels.OrderNumber + ' ' + labels.lblOptional,
            required: fieldLabels.OrderNumber
        },
        description: fieldLabels.Description + ' ' + labels.lblOptional
    };


    /*-------------------------- DOM Manipulation --------------------------*/
    @track editMode = true; // Boolean value for DOM to either render the edit page or the view page
    @track fieldCaseType; // String value set by the Case field "Case_Type__c" on the UI
    @track orderClass = ORDER_CLASS; // String value of the css class to identify the Order_Number__c field

    get isEditMode() {
        return this.editMode;
    }

    get orderFieldClassList() {
        return this.orderClass;
    }

    caseTypes = getCaseTypeValidations().then(result => {
        this.caseTypes = result;
    });


    /**
     * @description Actions taken when the case type picklist value is changed
     * @param event on change of the picklist "type"
     */
    handleOrderTypeChange(event) {
        this.handleTopicChange(event, 'Subject');
        this.fieldCaseType = event.target.value;
        const typeSelect = this.template.querySelector('.slds-select');
        const orderInputDiv = this.template.querySelector('.order-number');

        typeSelect.classList.remove('select-error');
        typeSelect.classList.remove('slds-has-error');

        let orderRequired = false;
        for (let i = 0; i < this.caseTypes.length; i++) {
            if (this.fieldCaseType === this.caseTypes[i]) {
                orderRequired = true;
                break;
            }
        }
        if (orderRequired) {
            this.orderClass = ORDER_CLASS + ' ' + REQUIRED_CLASS;
            orderInputDiv.label = this.placeholders.order.required;
        } else {
            this.orderClass = ORDER_CLASS;
            orderInputDiv.classList.remove('slds-has-error');
            orderInputDiv.label = this.placeholders.order.optional;
        }


    }

    @track hasError = false;

    @track caseId; // String of the case id that gets created
    @track busy = true; // Boolean value used to hide or show the loading spinner
    formFirstLoad = true; // Boolean value to only show the spinner while the component loads the first time

    get isBusy() {
        return this.busy;
    }


    /**
     * @description Show the spinner when the form first loads
     * @param event of the form load
     */
    handleFormLoad(event) {
        if (this.formFirstLoad) {
            this.busy = false;
            this.formFirstLoad = false;
        }
    }


    /**
     * @description Front end validation UX and form submitting
     * @param event of the form submit
     */
    handleFormSubmit(event) {
        event.preventDefault();

        this.busy = true;
        const requiredFields = this.template.querySelectorAll('.custom-required');
        let missingField = false;

        for (let i = 0; i < requiredFields.length; i++) {
            if (requiredFields[i].value === undefined || requiredFields[i].value === null || requiredFields[i].value === '') {
                missingField = true;
                if (!requiredFields[i].classList.contains('slds-has-error')) {
                    if(requiredFields[i].classList.contains('slds-select')) {
                        requiredFields[i].classList.add('select-error');
                    }
                    requiredFields[i].classList.add('slds-has-error');
                }
            } else {
                if (requiredFields[i].classList.contains('slds-has-error')) {
                    if(requiredFields[i].classList.contains('slds-select')) {
                        requiredFields[i].classList.remove('select-error');
                    }
                    requiredFields[i].classList.remove('slds-has-error');
                }
            }
        }

        const emailInput = this.template.querySelector('.email-input');
        if (/^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/.test(emailInput.value)){
            emailInput.classList.remove('slds-has-error');
        }else{
            missingField = true;
            emailInput.classList.add('slds-has-error');
        }

        if (missingField) {
            event.preventDefault();
            this.hasError = true;
            this.busy = false;
        } else {
            const fields = event.detail.fields;
            const inputs = this.template.querySelectorAll('.custom-input-field');

            inputs.forEach(field => {
                if (field.name !== undefined)
                    fields[field.name] = field.value;
            });

            fields.Business_Unit__c = this._businessUnit;
            fields.Case_Language__c = this._language;
            const customEvent = new CustomEvent('formsubmitaura', {detail: {fields}});

            this.dispatchEvent(customEvent);
        }
    }


    /**
     * @description Show toast with error message
     * @param event of the form error
     */
    handleFormError(event) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: labels.lblError,
                message: labels.lblCaseErrorMessage,
                variant: 'error',
            }),
        );
        this.busy = false;
    }


    /**
     * @description Attach files to the newly created Case record
     * @param event of the form success
     */
    handleFormSuccess(event) {
        this.caseId = event.detail.id;
        this.busy = false;
    }


    /*-------------------------- Event --------------------------*/
    /**
     * @description Calls function for raising a platform event
     * @param event on change of the subject field
     */
    handleSubjectChange(event) {
        this.handleTopicChange(event, 'Subject');
    }


    /**
     * @description Calls function for raising a platform event
     * @param event on change of the description field
     */
    handleDescriptionChange(event) {
        this.handleTopicChange(event, 'Description');
    }


    /**
     * @description Fires event to be caught by the aura component
     * @param event of the field change
     * @param field value of the field name
     */
    handleTopicChange(event, field) {
        const fieldValue = event.target.value;
        const customEvent = new CustomEvent('topicchange',
            {
                detail: {
                    modifiedField: field, modifiedFieldValue: fieldValue
                }
            });

        this.dispatchEvent(customEvent);
    }

}