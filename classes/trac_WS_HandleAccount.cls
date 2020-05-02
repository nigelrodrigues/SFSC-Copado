/**
 * @description Creates a new account in Commerce Cloud (on behalf of an agent), password reset and getting customer details.
 * @author Nigel Rodrigues, Traction on Demand
 * @date 17-January-2020
 */

public with sharing class trac_WS_HandleAccount {
    private String ENDPOINT = ' ';
    private HttpResponse res = new HttpResponse();
    public AccountRequest accountReq;
    public AccountResponse accountResp;
    public PasswordReset passwordReq;
    public String jsonError;
    public Map<String, String> additionalHeaders;
    public String businessUnit;
    public CustomerErrorResponse errorResponse;
    public CustomerDetails customerDetails;

    public trac_WS_HandleAccount()
    {
        accountReq = new AccountRequest();
        accountResp = new AccountResponse();
        additionalHeaders = new Map<String, String>();
        passwordReq = new PasswordReset();
        errorResponse = new CustomerErrorResponse();
        customerDetails = new CustomerDetails();
    }

    // Create a Commerce Cloud account
    public TLAuraResponse createNewSFCCAccount() {

        TLAuraResponse response = new TLAuraResponse(true);
		SCCCommerceCloudConnect.businessUnit = businessUnit;
        ENDPOINT = SCCCommerceCloudConnect.siteBaseUrl + '/s/' + SCCCommerceCloudConnect.siteId + '/dw/shop/v19_1/customers';
        
        res = trac_WS_WebServiceHelper.sendPostRequest(ENDPOINT, accountReq, additionalHeaders);


        if(trac_WS_WebServiceHelper.isValidResponse(res)) {
            accountResp = parse(res.getBody());
            return response;
        }
        else {

            jsonError = trac_WS_WebServiceHelper.getError(res);
            System.debug('Error: ' + trac_WS_WebServiceHelper.getError(res));
            errorResponse = parse(res.getBody(), '');
            if(errorResponse.fault.message.contains('Authorization')) {

                Integration_Error__c integrationError = trac_IntegrationError.addError(new Integration_Error__c(
                        Description__c = res.getBody(),
                        Endpoint__c = ENDPOINT,
                        Request__c = ' ',
                        Service__c = 'Create new Commerce Cloud account: Invalid credentials'
                ));
                insert integrationError;

                response = new TLAuraResponse(false, 'Your SFCC credentials are invalid. ' +
                        'Please contact your Administrator to setup the right credentials. Error ID: ' + integrationError.Id);
            }
            else{
                response = new TLAuraResponse(false, errorResponse.fault.message);
            }
        }

        return response;
    }

    // Password Reset
    public Boolean resetPassword(String email) {
        passwordReq.identification = email;
        passwordReq.type = 'email';
        SCCCommerceCloudConnect.businessUnit = businessUnit;
        ENDPOINT = SCCCommerceCloudConnect.siteBaseUrl + '/s/' + SCCCommerceCloudConnect.siteId + '/dw/shop/v19_1/customers/password_reset';

        res = trac_WS_WebServiceHelper.sendPostRequest(ENDPOINT, passwordReq, additionalHeaders);
        if(trac_WS_WebServiceHelper.isValidResponse(res)) {
            return true;
        }
        else {
            jsonError = trac_WS_WebServiceHelper.getError(res);
        }
        return false;
    }
    // Get Customer Status
    public TLAuraResponse getCustomerStatus(String customerId)
    {
        TLAuraResponse response = new TLAuraResponse(true);
        SCCCommerceCloudConnect.businessUnit = businessUnit;
        ENDPOINT = SCCCommerceCloudConnect.siteBaseUrl + '/s/' + SCCCommerceCloudConnect.siteId
                + '/dw/shop/v19_1/customers/' + customerId +'?expand=addresses,paymentinstruments';
        res = trac_WS_WebServiceHelper.sendGetRequest(ENDPOINT, null , true,additionalHeaders);

        if(trac_WS_WebServiceHelper.isValidResponse(res)) {
            customerDetails = parse(res.getBody(), 1);
            response.returnValuesMap.put('enabled', customerDetails.enabled);
            return response;
        }
        else {
            jsonError = trac_WS_WebServiceHelper.getError(res);
        }
        return response;
    }

   public TLAuraResponse createAddress(String customerId, String businessUnit, String phone, String zipCode)
   {
       trac_WS_CreateAddress createdAccount = new trac_WS_CreateAddress();
       TLAuraResponse response = createdAccount.send(customerId, businessUnit, phone, zipCode);
       return response;
   }

    public static AccountResponse parse(String json) {
        return (AccountResponse) System.JSON.deserialize(json, AccountResponse.class);
    }

    public static CustomerDetails parse(String json, Integer example) {
        return (CustomerDetails) System.JSON.deserialize(json, CustomerDetails.class);
    }

    public static CustomerErrorResponse parse(String json, String error) {
        return (CustomerErrorResponse) System.JSON.deserialize(json, CustomerErrorResponse.class);
    }



    public class req_customerWrapper {
        public String login;
        public String email;
        public String last_name;
        public String first_name;
    }
    public class AccountRequest {
        public req_customerWrapper customer;

        public AccountRequest()
        {
            customer = new req_customerWrapper();
        }
    }
    public class AccountResponse {
        public String v;
        public String type;
        public String resource_state;
        public String auth_type;
        public String creation_date;
        public String customer_id;
        public String customer_no;
        public String email;
        public Boolean enabled;
        public String last_modified;
        public String last_name;
        public String login;
    }


    public class CustomerErrorResponse{
        public String v;
        public req_faultWrapper fault;
        public CustomerErrorResponse()
        {
            fault = new req_faultWrapper();
        }
    }
    public class req_faultWrapper{
        public req_arguments arguments;
        public String type;
        public String message;
        public req_faultWrapper()
        {
            arguments = new req_arguments();
        }
    }
    public class req_arguments{
        public String email;

    }
    // Password Reset classes
    public class PasswordReset{
        public String type;
        public String identification;
    }

    // Customer Details classes
    public class res_addressesWrapper {
        public String type;
        public String address1;
        public String address_id;
        public String city;
        public String country_code;
        public String creation_date;
        public String full_name;
        public String last_modified;
        public String last_name;
        public String postal_code;
        public Boolean preferred;
        public String state_code;
        public String suite;
    }
    public class CustomerDetails {
        public String v;
        public String type;
        public String resource_state;
        public List<res_addressesWrapper> addresses;
        public String auth_type;
        public String birthday;
        public String company_name;
        public String creation_date;
        public String customer_id;
        public String customer_no;
        public String email;
        public Boolean enabled;
        public String fax;
        public String first_name;
        public Integer gender;
        public String job_title;
        public String last_modified;
        public String last_name;
        public String last_visit_time;
        public String login;
        public String note;
        public String phone_business;
        public String phone_home;
        public String phone_mobile;
        public String preferred_locale;
        public String previous_visit_time;
        public String salutation;
        public String second_name;
        public String suffix;
        public String title;
        public String c_accountModifiedDate;
        public Boolean c_emailOptIn;
        public String c_hudsonReward;
        public Boolean c_isCanadianCustomer;
        public Boolean c_isLegacyCustomer;
        public String c_lastImportedDate;
        public String c_lastModifiedCustom;
        public String c_legacyPasswordHash;
        public String c_preferredLanguage;
        public Boolean c_saksAvenueOptIn;
        public Boolean c_saksAvenueOptInCA;
        public Boolean c_saksOptIn;
        public Boolean c_saksOptInCA;
        public Decimal c_ucidNo;
    }

}