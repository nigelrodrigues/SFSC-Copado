/**
 * @author Nigel Rodrigues, Traction on Demand
 * @date 22-March-2020
 * @description Gets the email body of an email.
 */

public with sharing class trac_WS_GetEmailBody {
    public String email;
    public String order_number;
    public String id;
    Web_Service_Settings__c webServiceSettings = (!Test.isRunningTest()) ? Web_Service_Settings__c.getOrgDefaults() : trac_TestUtils.setupWebServiceSettings();
    public final String ENDPOINT = webServiceSettings.CNS_Get_Email_Body__c;

    private HttpResponse response = new HttpResponse();

    public String jsonError;

    private Map<String, String> getParameters() {
        Map<String, String> extraParameters = new Map<String, String>();
        extraParameters.put('environment','stqa');
        extraParameters.put('message_type','primary_email');
        extraParameters.put('id', id);
        return extraParameters;
    }

    public String getEmailBody()
    {
        //ENDPOINT = 'https://api.backoffice.giltaws.com/api-customer-notification/stqa/preview/email?id=' + requestId +'&environment=stqa&message_type=primary_email';
        Map<String, String> additionalHeaders = new Map<String, String>();
        additionalHeaders.put('x-api-key',webServiceSettings.Email_Search_API_key__c);
        HttpResponse response = trac_WS_WebServiceHelper.sendGetRequest(ENDPOINT , getParameters(),false, additionalHeaders);
        String bodyResponse = response.getBody();
        return bodyResponse;
    }

}