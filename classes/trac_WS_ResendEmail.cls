/**
 * Created by nrodrigues on 3/3/2020.
 * @author Nigel Rodrigues, Traction on Demand
 * @date 3-March-2020
 * @description Class which resends an email to a customer.
 */

public with sharing class trac_WS_ResendEmail {
    //private String ENDPOINT = 'https://api.backoffice.giltaws.com/api-customer-notification/stqa/resend_rendered_message/' ;
    private HttpResponse res = new HttpResponse();
    public String payload_id;
    public String recipient;
    public ResendEmailRequest resendEmailRequest;
    public ResendEmailResponse resendEmailResponse;
    public String jsonError;

    private Map<String, String> getParameters() {
        Map<String, String> extraParameters = new Map<String, String>();
        if(payload_id != null)
        {
            extraParameters.put('id', payload_id);
        }
        if(recipient != null)
        {
            extraParameters.put('recipient', recipient);
        }
        extraParameters.put('environment', 'stqa');
        extraParameters.put('message_type', 'primary_email');


        return extraParameters;
    }

    public Boolean send() {
        Web_Service_Settings__c webServiceSettings = (!Test.isRunningTest()) ? Web_Service_Settings__c.getOrgDefaults() : trac_TestUtils.setupWebServiceSettings();
        final String ENDPOINT = webServiceSettings.CNS_Send_Email_Endpoint__c + payload_id;

        Map<String, String> additionalHeaders = new Map<String, String>();
        webServiceSettings = (!Test.isRunningTest()) ? Web_Service_Settings__c.getOrgDefaults() : trac_TestUtils.setupWebServiceSettings();
        additionalHeaders.put('x-api-key',webServiceSettings.Email_Search_API_key__c);

        res = trac_WS_WebServiceHelper.SendGetRequest(ENDPOINT, getParameters(),true,additionalHeaders);
        if(trac_WS_WebServiceHelper.isValidResponse(res)) {
            resendEmailResponse = parse(res.getBody());
            System.debug('Response: ' + res.getBody());
            return true;
        }
        else {
            jsonError = trac_WS_WebServiceHelper.getError(res);
            System.debug('Error: ' + trac_WS_WebServiceHelper.getError(res));
        }
        return false;
    }
    public static ResendEmailResponse parse(String json) {
        return (ResendEmailResponse) System.JSON.deserialize(json, ResendEmailResponse.class);
    }

    public class ResendEmailRequest {
    }
    public class ResendEmailResponse {
        public Integer sent;
    }

}