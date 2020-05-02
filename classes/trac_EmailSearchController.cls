/**
 * @author Nigel Rodrigues, Traction on Demand
 * @description Controller to handle Email search based on order number or email
 */

public with sharing class trac_EmailSearchController {

    @AuraEnabled
    public static TLAuraResponse getAssociatedEmails(String businessUnit, String orderNumber, String email,
                                                    String startDate, String endDate)
    {
        TLAuraResponse response = new TLAuraResponse(true);
        trac_WS_EmailSearch request = new trac_WS_EmailSearch();
        try {

            if(businessUnit.equals('Hudson\'s Bay'))
                businessUnit = 'bay';
            else if(businessUnit.equals('Off 5th'))
                businessUnit = 'off5th';
            request.banner = businessUnit;
            if(orderNumber!=null)
                request.order_number = orderNumber;
            if(email!=null)
                request.email = email;
            if(startDate!=null)
                request.start_date = startDate;
            if(endDate!=null)
                request.end_date = endDate;

            request.send();
            response.returnValuesMap.put('associatedEmails',request.emailSearchResponses);
        }
        catch (Exception e) {
            Integration_Error__c integrationError = trac_IntegrationError.addError(new Integration_Error__c(
                    Description__c = e.getMessage() + '\n' + e.getStackTraceString(),
                    Endpoint__c = request.ENDPOINT,
                    //Request__c = JSON.serializePretty(request.getOrderDetailsRequest),
                    Service__c = 'Get Related Email Details'
            ));
            insert integrationError;

            String errorMessage = trac_WS_WebServiceHelper.DEFAULT_ERROR + integrationError.Id;
            response = new TLAuraResponse(false, errorMessage);
            System.debug('Error: ' + e.getMessage() +e.getStackTraceString());

        }

        return response;

    }

    @AuraEnabled
    public static TLAuraResponse retrieveEmailBody(String requestBodyId)
    {
        TLAuraResponse response = new TLAuraResponse(true);
        trac_WS_GetEmailBody request = new trac_WS_GetEmailBody();
        try {
            request.id = requestBodyId;
            String emailBody = request.getEmailBody();
            emailBody = emailBody.replace('style="width:100%','style="width:40%');
            response.returnValuesMap.put('emailBodyResponse',emailBody);
        }
        catch (Exception e) {
            Integration_Error__c integrationError = trac_IntegrationError.addError(new Integration_Error__c(
                    Description__c = e.getMessage() + '\n' + e.getStackTraceString(),
                    Endpoint__c = request.ENDPOINT,
                    Request__c = '',
                    Service__c = 'Retrieve Email Body'
            ));
            insert integrationError;

            String errorMessage = trac_WS_WebServiceHelper.DEFAULT_ERROR + integrationError.Id;
            response = new TLAuraResponse(false, errorMessage);
            System.debug('Error: ' + e.getMessage() +e.getStackTraceString());

        }

        return response;

    }

    @AuraEnabled
    public static TLAuraResponse resendEmailToCustomer(String requestId, String email)
    {
        TLAuraResponse response = new TLAuraResponse(true);
        Web_Service_Settings__c webServiceSettings = (!Test.isRunningTest()) ? Web_Service_Settings__c.getOrgDefaults() : trac_TestUtils.setupWebServiceSettings();
        final String ENDPOINT = webServiceSettings.CNS_Send_Email_Endpoint__c + requestId;

        trac_WS_ResendEmail resendEmail = new trac_WS_ResendEmail();
        try {
            resendEmail.payload_id = requestId;
            resendEmail.recipient = email;
            resendEmail.send();
            response.returnValuesMap.put('emailSent',resendEmail.resendEmailResponse.sent);
        }
        catch(Exception e)
        {
            Integration_Error__c integrationError = trac_IntegrationError.addError(new Integration_Error__c(
                   Description__c = e.getMessage() + '\n' + e.getStackTraceString(),
                   Endpoint__c = ENDPOINT,
                   //Request__c = JSON.serializePretty(request.getOrderDetailsRequest),
                   Service__c = 'Resend Email to Customer'
           ));
           insert integrationError;

           String errorMessage = trac_WS_WebServiceHelper.DEFAULT_ERROR + integrationError.Id;
           response = new TLAuraResponse(false, errorMessage);
            System.debug('Error: ' + e.getMessage() +e.getStackTraceString());
        }
        return response;
    }

}