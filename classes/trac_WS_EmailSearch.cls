public with sharing class trac_WS_EmailSearch {

    public String banner;
    public String email;
    public String order_number;
    public String start_date;
    public String end_date;
    Web_Service_Settings__c webServiceSettings = (!Test.isRunningTest()) ? Web_Service_Settings__c.getOrgDefaults() : trac_TestUtils.setupWebServiceSettings();
    public final String ENDPOINT = webServiceSettings.CNS_Email_Search_Endpoint__c;
    private HttpResponse res = new HttpResponse();
    public List<EmailSearchResponse> emailSearchResponses;
    public String jsonError;

    private Map<String, String> getParameters() {
        Map<String, String> extraParameters = new Map<String, String>();
        if( !String.isBlank(banner) ) {
            extraParameters.put('banner', banner);
        }
        if( !String.isBlank(email) ) {
            extraParameters.put('email', email);
        }
        if( !String.isBlank(order_number) ) {
            extraParameters.put('order_number', order_number);
        }
        if( !String.isBlank(start_date) ) {
            extraParameters.put('start_date', start_date);
        }
        if( !String.isBlank(end_date) ) {
            extraParameters.put('end_date', end_date);
        }
        extraParameters.put('environment','stqa');
        return extraParameters;
    }
    public Boolean send() {
        Map<String, String> additionalHeaders = new Map<String, String>();
        additionalHeaders.put('x-api-key', webServiceSettings.Email_Search_API_key__c);

        res = trac_WS_WebServiceHelper.sendGetRequest(ENDPOINT, getParameters(), true, additionalHeaders);
        if(trac_WS_WebServiceHelper.isValidResponse(res)) {
            emailSearchResponses = parse(res.getBody());
            return true;
        }
        else {
            jsonError = trac_WS_WebServiceHelper.getError(res);
        }
        return false;
    }

    public static List<EmailSearchResponse> parse(String json) {
        return (List<EmailSearchResponse>) System.JSON.deserialize(json, List<EmailSearchResponse>.class);
    }

    public class EmailSearchResponse {
        @AuraEnabled public String raw_payload;
        @AuraEnabled public Boolean sms_sent;
        @AuraEnabled public Boolean has_alternate;
        @AuraEnabled public Boolean message_success;
        @AuraEnabled public String sms_info;
        @AuraEnabled public String jms_id;
        @AuraEnabled public Integer id;
        @AuraEnabled public String createdAt;
        @AuraEnabled public String alternate_sentAt;
        @AuraEnabled public String primary_info;
        @AuraEnabled public String primary_sentAt;
        @AuraEnabled public String email_name;
        @AuraEnabled public Boolean sms_skipped;
        @AuraEnabled public Boolean primary_sent;
        @AuraEnabled public String primary_email;
        @AuraEnabled public Boolean message_error;
        @AuraEnabled public String alternate_email;
        @AuraEnabled public Boolean alternate_error;
        @AuraEnabled public String phone_number;
        @AuraEnabled public Boolean alternate_sent;
        @AuraEnabled public Boolean render_skipped;
        @AuraEnabled public Boolean message_skipped;
        @AuraEnabled public Boolean primary_error;
        @AuraEnabled public Boolean sms_error;
        @AuraEnabled public String sms_sentAt;
        @AuraEnabled public String banner;
        @AuraEnabled public String rendered_messages;
        @AuraEnabled public Boolean primary_skipped;
        @AuraEnabled public Boolean render_error;
        @AuraEnabled public String render_info;
        @AuraEnabled public Boolean render_success;
        @AuraEnabled public Boolean has_sms;
        @AuraEnabled public Boolean alternate_skipped;
        @AuraEnabled public String alternate_info;
        @AuraEnabled public Long order_number;
    }
}