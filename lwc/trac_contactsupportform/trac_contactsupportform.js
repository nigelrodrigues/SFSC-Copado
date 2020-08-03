/**
 * @Name trac_contactsupportform
 * @Author Daniel Labonte, Traction on Demand
 * @Date June 12, 2019
 *
 * @Description trac_ContactSupportForm
 */
import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import strUserId from '@salesforce/apex/trac_ContactSupportFormController.getGuestUserId';

import { getPicklistValues } from 'lightning/uiObjectInfoApi';

import getCaseTypeValidations from '@salesforce/apex/trac_ContactSupportFormController.getCaseTypeValidations';
/*import getCaseTypePicklistValues from '@salesforce/apex/trac_ContactSupportFormController.getCaseTypeValues';*/
import attachFilesToCase from '@salesforce/apex/trac_ContactSupportFormController.attachFilesToCase';

import { labels, fieldLabels } from './trac_contactsupportformlabels';




import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import CASE_OBJECT from '@salesforce/schema/Case';
import CASETYPE_FIELD from '@salesforce/schema/Case.Case_Type__c';






const ORDER_CLASS = 'order-number custom-input-field';
const POSTAL_CODE_CLASS = 'postal-code custom-input-field';
const REQUIRED_CLASS = 'custom-required';


export default class trac_ContactSupportForm extends LightningElement {

    @wire(getObjectInfo, { objectApiName: CASE_OBJECT })
    objectInfo;
    @wire(getPicklistValues, { recordTypeId: '$_caseRecordTypeId', fieldApiName: CASETYPE_FIELD})
    caseTypePicklistValues;


    labels = labels;  // any visible UI text on the layout
    subtitle = {
        Q : labels.lblSubtitle.split('\n')[0],
        A : labels.lblSubtitle.split('\n')[1]
    };

    // lightning-input field labels
    placeholders = {
        email : fieldLabels.SuppliedEmail,
        name : fieldLabels.Name,
        type : fieldLabels.Type,
        order : {
            optional : fieldLabels.OrderNumber + ' ' + labels.lblOptional,
            required : fieldLabels.OrderNumber
        },
        postalCode : {
            optional : fieldLabels.PostalCode + ' ' + labels.lblOptional,
            required : fieldLabels.PostalCode
        },
        subject : fieldLabels.Subject,
        description : fieldLabels.Description + ' ' + labels.lblOptional,
    };

    @api businessUnit;
    @api language;
    @api get caseRecordTypeId(){
        return this._caseRecordTypeId;
    }
    set caseRecordTypeId(value){
        this._caseRecordTypeId = value;
    }

    /*@track caseTypeValues = getCaseTypePicklistValues({businessUnitValue : this.businessUnit}).then(result => {
        this.caseTypeValues = result;
    });*/


    get caseTypeOptions() {
        console.log('caseType--'+this.caseTypePicklistValues);
        return this.caseTypePicklistValues;
    }




    /*-------------------------- DOM Manipulation --------------------------*/
    @track editMode = true; // Boolean value for DOM to either render the edit page or the view page
    //guest = isGuest; // Boolean value used to decipher logged in user from guest user
    @track fieldCaseType; // String value set by the Case field "Case_Type__c" on the UI
    @track orderClass = ORDER_CLASS; // String value of the css class to identify the Order_Number__c field
    @track postalCodeClass = POSTAL_CODE_CLASS;
    defaultOrigin = 'Support Community';

    get isEditMode() {
        return this.editMode;
    }

    get orderFieldClassList() {
        return this.orderClass;
    }

    get postalCodeFieldClassList() {
        return this.postalCodeClass;
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
        this.fieldCaseType = event.detail.value;
        const orderInputDiv = this.template.querySelector('.order-number');
        const postalCodeInputDiv = this.template.querySelector('.postal-code');

        let orderRequired = false;
        for (let i = 0; i < this.caseTypes.length; i++) {
            if (this.fieldCaseType === this.caseTypes[i]) {
                orderRequired = true;
                break;
            }
        }
        if (orderRequired) {
            this.orderClass = ORDER_CLASS + ' ' + REQUIRED_CLASS;
            this.postalCodeClass = POSTAL_CODE_CLASS + ' ' + REQUIRED_CLASS;
            orderInputDiv.label = this.placeholders.order.required;
            postalCodeInputDiv.label = this.placeholders.postalCode.required;
            // orderErrorDiv.classList.add('custom-message');
        } else {
            this.orderClass = ORDER_CLASS;
            this.postalCodeClass = POSTAL_CODE_CLASS;
            // orderErrorDiv.classList.remove('custom-message');
            orderInputDiv.classList.remove('slds-has-error');
            postalCodeInputDiv.classList.remove('slds-has-error');
            orderInputDiv.label = this.placeholders.order.optional;
            postalCodeInputDiv.label = this.placeholders.postalCode.optional;
            // orderErrorDiv.classList.add('custom-hidden');
        }

    }




    /*-------------------------- File handling --------------------------*/
    @track uploadedFiles = []; //JSON object of the updloaded files, used for pills
    acceptedFileFormats = ['.pdf','.png','.jpg','.jpeg','.txt']; // List of acceptable file formats to attach

    get fileList() {
        return this.uploadedFiles;
    }



    /**
     * @description Populates the list of uploaded files so that the pills appear on the UI
     * @param event of the file upload completed
     */
    handleUploadFinished(event) {
        const files = event.detail.files;
        for(let i = 0; i < files.length; i++) {
            this.uploadedFiles.push({
                name: files[i].documentId,
                label: files[i].name,
                type: 'icon',
                iconName: 'standard:file',
                alternativeText: files[i].name
            });
        }
        this.uploadedFiles = JSON.parse(JSON.stringify(this.uploadedFiles));
    }


    /**
     * @description Removes the file from the list and in turn removes the pill from the UI
     * @param event of the pill being removed
     */
    handleRemoveFile(event) {
        this.uploadedFiles.splice(event.detail.index, 1);
        this.uploadedFiles = JSON.parse(JSON.stringify(this.uploadedFiles));
    }




    /*-------------------------- Form handling --------------------------*/
    // Hudson Bay guest user id
    userId = strUserId().then(result => {
        this.userId = result;
    });

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
        if(this.formFirstLoad) {
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
        // const fields = this.template.querySelectorAll('lightning-input-field.custom-required');
        const requiredFields = this.template.querySelectorAll('.custom-required');
        // const errorLabels = this.template.querySelectorAll('.custom-message');
        let missingField = false;

        for(let i = 0; i < requiredFields.length; i++) {
            if (requiredFields[i].value === undefined || requiredFields[i].value === null || requiredFields[i].value === '') {
                missingField = true;
                if(!requiredFields[i].classList.contains('slds-has-error')) {
                    requiredFields[i].classList.add('slds-has-error');
                    // errorLabels[i].classList.remove('custom-hidden');
                }
            } else {
                if(requiredFields[i].classList.contains('slds-has-error')) {
                    requiredFields[i].classList.remove('slds-has-error');
                    // errorLabels[i].classList.add('custom-hidden');
                }
            }
        }

        if(missingField) {
            console.log('Inside handleFormSubmit');
            event.preventDefault();
            this.dispatchEvent(
                new ShowToastEvent({
                    title: labels.lblError,
                    message: labels.lblCaseErrorMessage,
                    variant: 'error',
                }),
            );
            this.busy = false;
        } else {
            const fields = event.detail.fields;
            const inputs = this.template.querySelectorAll('.custom-input-field');

            inputs.forEach(field => {
                fields[field.name] = field.value;
            });

            fields.Business_Unit__c = this.businessUnit;
            fields.Case_Language__c = this.language;
            fields.RecordTypeId = this.caseRecordTypeId;
            fields.Origin = this.defaultOrigin;

            console.log(JSON.stringify(fields));

            /**
             * UDB-2 workaround for https://trailblazer.salesforce.com/issues_view?id=a1p3A000001GN1gQAG
             */
            alert(labels.lblCreatedTitle + " " + labels.lblCreatedSubtitle);
            let redirectUrl = './contactsupport';
            console.log('Rediredcting to ' + redirectUrl);
            window.open(redirectUrl,'_top');
            /**
             * END UDB-2 workaround
             */

            this.template.querySelector('lightning-record-edit-form').submit(fields);
        }
        // this.busy = false;
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
        console.log('SUCCESS');

        if(this.uploadedFiles != null && this.uploadedFiles.length > 0) {
            attachFilesToCase({caseId: this.caseId, uploadedFileIds: this.uploadedFiles})
                .then(resultErrors => {
                    if (resultErrors === 'false') {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: labels.lblSuccess,
                                message: labels.lblCaseSuccessMessage,
                                variant: 'success',
                            }),
                        );
                    } else {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: labels.lblFileError,
                                message: labels.lblFileErrorMessage + ': ' + resultErrors,
                                variant: 'info',
                            }),
                        );
                    }
                })
                .catch(error => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: labels.lblFileError,
                            message: labels.lblFileErrorMessage,
                            variant: 'info',
                        }),
                    );
                });
        }
        this.editMode = false;
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
        this.handleTopicChange(event,'Description');
    }


    /**
     * @description Fires event to be caught by the aura component
     * @param event of the field change
     * @param field value of the field name
     */
    handleTopicChange(event, field) {
        const fieldValue = event.detail.value;
        const customEvent = new CustomEvent('topicchange',
            { detail: {
                    modifiedField: field, modifiedFieldValue: fieldValue}
            });

        this.dispatchEvent(customEvent);
    }

}