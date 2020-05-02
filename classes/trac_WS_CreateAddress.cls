/**
 * @author Nigel Rodrigues, Traction on Demand
 * @description Add an address for newly created commerce cloud customer.
 */

public with sharing class trac_WS_CreateAddress {


    private HttpResponse res = new HttpResponse();
    public AddressRequest addressRequest;
    public AddressResponse addressResponse;
    public Map<String, String> additionalHeaders;
    public String jsonError;

    public trac_WS_CreateAddress()
    {
        addressRequest  = new AddressRequest();
        addressResponse = new AddressResponse();
        additionalHeaders = new Map<String, String>();
    }

    public TLAuraResponse send(String customerId, String businessUnit, String phone, String zipCode)
    {
        TLAuraResponse response = new TLAuraResponse(true);
        String agentAccessToken = SCCCommerceCloudConnect.connectToCommerceCloud(businessUnit);
        additionalHeaders.put('Authorization', 'Bearer ' + agentAccessToken);
        SCCCommerceCloudConnect.businessUnit = businessUnit;
        String ENDPOINT = SCCCommerceCloudConnect.siteBaseUrl + '/s/' + SCCCommerceCloudConnect.siteId;
        ENDPOINT += '/dw/shop/v19_1/customers/' + customerId + '/addresses';
        addressRequest.phone = phone;
        addressRequest.postal_code = zipCode;
        addressRequest.address_id = 'home_address';
        addressRequest.address1 = ' ';
        addressRequest.city = ' ';
        addressRequest.country_code = ' ';
        addressRequest.state_code = ' ';
        addressRequest.first_name = ' ';
        addressRequest.last_name = ' ';

        try {

            res = trac_WS_WebServiceHelper.SendPostRequest(ENDPOINT, addressRequest,additionalHeaders);
            if (trac_WS_WebServiceHelper.isValidResponse(res)) {
                addressResponse = parse(res.getBody());
                System.debug('Valid:');
                return response;
            } else {
                jsonError = trac_WS_WebServiceHelper.getError(res);
                System.debug('Error: ' + trac_WS_WebServiceHelper.getError(res));
                Integration_Error__c integrationError = trac_IntegrationError.addError(new Integration_Error__c(
                        Description__c = trac_WS_WebServiceHelper.getError(res),
                        Endpoint__c = ENDPOINT,
                        Request__c = JSON.serializePretty(addressRequest),
                        Service__c = 'Create address for new commerce cloud user. SFCC Customer ID: ' + customerId
                ));
                insert integrationError;
                String errorMessage = 'There was an error in saving the address for the user. ' +
                        'You can continue with Order on Behalf. Please give the ID to your Administrator: ' + integrationError.Id;
                response = new TLAuraResponse(false, errorMessage);
            }
        }
        catch(Exception e)
        {
            System.debug('in catch');
            Integration_Error__c integrationError = trac_IntegrationError.addError(new Integration_Error__c(
                    Description__c = e.getMessage() + '\n' + e.getStackTraceString(),
                    Endpoint__c = ENDPOINT,
                    Request__c = JSON.serializePretty(addressRequest),
                    Service__c = 'Create address for new commerce cloud user'
            ));
            insert integrationError;
            String errorMessage = 'There was an error in saving the address for the user. ' +
                    'You can continue with Order on Behalf. Please give the ID to your Administrator: ' + integrationError.Id;
            response = new TLAuraResponse(false, errorMessage);
        }
        
        return response;
    }

    public static AddressResponse parse(String json) {
        return (AddressResponse) System.JSON.deserialize(json, AddressResponse.class);
    }


    public class AddressRequest {
        public String address_id;
        public String address1;
        public String address2;
        public String city;
        public String company_name;
        public String country_code;
        public String first_name;
        public String job_title;
        public String last_name;
        public String phone;
        public String postal_code;
        public String post_box;
        public Boolean preferred;
        public String salutation;
        public String second_name;
        public String state_code;
        public String title;
    }
    public class AddressResponse {
        public String v;
        public String resource_state;
        public String type;
        public String address1;
        public String address2;
        public String address_id;
        public String city;
        public String company_name;
        public String country_code;
        public String first_name;
        public String full_name;
        public String job_title;
        public String last_name;
        public String phone;
        public String postal_code;
        public String post_box;
        public Boolean preferred;
        public String salutation;
        public String second_name;
        public String state_code;
        public String title;
    }

}