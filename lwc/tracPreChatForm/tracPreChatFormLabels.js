/**
 * @description ${DESCRIPTION}
 * @name tracPreChatFormLabels
 * @author Daniel Labonte, Traction on Demand
 * @date 2019-08-29
 */

import lblLanguage from '@salesforce/label/c.Language';
import lblTitle from '@salesforce/label/c.Title';
import lblSubtitle from '@salesforce/label/c.Subtitle';
import lblReceipt from '@salesforce/label/c.Attach_Receipt';
import lblCreatedTitle from '@salesforce/label/c.Created_Title';
import lblCreatedSubtitle from '@salesforce/label/c.Created_Subtitle';
import lblCreatedSummary from '@salesforce/label/c.Created_Summary';
import lblNullFieldMessage from '@salesforce/label/c.Null_Field_Message';
import lblRequired from '@salesforce/label/c.Required';
import lblOptional from '@salesforce/label/c.Optional';
import lblSuccess from '@salesforce/label/c.Success';
import lblSubmit from '@salesforce/label/c.Submit';
import lblError from '@salesforce/label/c.Error';
import lblFileError from '@salesforce/label/c.File_Error';
import lblCaseSuccessMessage from '@salesforce/label/c.Case_Create_Success_Message';
import lblCaseErrorMessage from '@salesforce/label/c.Case_Create_Error_Message';
import lblFileErrorMessage from '@salesforce/label/c.File_Error_Message';
import lblChatButton from '@salesforce/label/c.Chat_Button';
import lblGenericErrorMessage from '@salesforce/label/c.Generic_Error_Message';
import lblNone from '@salesforce/label/c.None';
import SuppliedEmail from '@salesforce/label/c.Case_Field_Email_Address';
import FirstName from '@salesforce/label/c.Case_Field_First_Name';
import LastName from '@salesforce/label/c.Case_Field_Last_Name';
import Type from '@salesforce/label/c.Case_Field_Type';
import OrderNumber from '@salesforce/label/c.Case_Field_Order_Number';
import Subject from '@salesforce/label/c.Case_Field_Subject';
import Description from '@salesforce/label/c.Case_Field_Description';


const labels = {
    lblLanguage,
    lblTitle,
    lblSubtitle,
    lblReceipt,
    lblCreatedTitle,
    lblCreatedSubtitle,
    lblCreatedSummary,
    lblNullFieldMessage,
    lblSubmit,
    lblRequired,
    lblOptional,
    lblSuccess,
    lblError,
    lblFileError,
    lblGenericErrorMessage,
    lblCaseSuccessMessage,
    lblCaseErrorMessage,
    lblFileErrorMessage,
    lblChatButton,
    lblNone,
};

const fieldLabels = {
    SuppliedEmail,
    FirstName,
    LastName,
    Type,
    OrderNumber,
    Subject,
    Description
};

export { labels, fieldLabels };