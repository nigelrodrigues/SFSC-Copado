/**
 *  @description Customer Update Service (UCID)
 *  @author      Jeremy Horan, Traction on Demand.
 *  @date        6/3/2019
 */
public class trac_WS_UpdateCustomerDetails {
    private final String ENDPOINT = (trac_WS_WebServiceHelper.webServiceSettings.Base_Url__c != null) ?
            trac_WS_WebServiceHelper.webServiceSettings.Base_Url__c + trac_WS_WebServiceHelper.webServiceSettings.UCID_Update_Endpoint__c : trac_WS_WebServiceHelper.webServiceSettings.UCID_Update_Endpoint__c;
    private HttpResponse res = new HttpResponse();
    public UpdateCustomerDetailsRequest updateCustomerDetailsRequest;
    public UpdateCustomerDetailsResponse updateCustomerDetailsResponse;
    public String jsonError;

    public trac_WS_UpdateCustomerDetails() {
        updateCustomerDetailsRequest = new UpdateCustomerDetailsRequest();
    }

    public Boolean send() {
        return false;
        /*
         * Chris Shinnimin, Traction on Demand:
         * Temporarily (possibly?) removing the PUT (Update) API call, as per James Cortois Oct. 1, 2019
         * See Jira ticket UAD-1104
         *
        res = trac_WS_WebServiceHelper.sendPutRequest(ENDPOINT, updateCustomerDetailsRequest);
        if(trac_WS_WebServiceHelper.isValidResponse(res)) {
            updateCustomerDetailsResponse = parse(res.getBody());
            return true;
        }
        else {
            jsonError = trac_WS_WebServiceHelper.getError(res);
            System.debug('Error: ' + trac_WS_WebServiceHelper.getError(res));

            try {
                updateCustomerDetailsResponse = parse(res.getBody());
            }
            catch (Exception e) {

            }
        }
        return false;
        *
        * END Jira ticket UAD-1104
        */
    }
    public static UpdateCustomerDetailsResponse parse(String json) {
        return (UpdateCustomerDetailsResponse) System.JSON.deserialize(json, UpdateCustomerDetailsResponse.class);
    }

    public class UpdateCustomerDetailsRequest {
        public String firstName;
        public String lastName;
        public String middleInitial;
        public String suffix;
        public String prefix;
        public Integer languagePrefCode;
        public String genderType;
        public String dateOfBirth;
        public req_contactDetailsWrapper contactDetails;
        public req_accountDetailsWrapper accountDetails;
        public Long UCIDNumber;
        public String sourceId;
        public Integer bannerCode;
        public String emailActiveIND;
        public String phoneActiveIND;
        public String addressActiveIND;

        public UpdateCustomerDetailsRequest() {
            contactDetails = new req_contactDetailsWrapper();
            accountDetails = new req_accountDetailsWrapper();
        }
    }

    public class UpdateCustomerDetailsResponse {
        public res_customerRecord customerRecord;
        public String TimeStamp;
        public String FlowName;
        public String ErrorLocation;
        public String ErrorCode;
        public String ErrorText;
        public String ErrorDescription;
    }

    public class req_contactDetailsWrapper {
        public String address1;
        public String address2;
        public String address3;
        public String city;
        public String stateCode;
        public String postCode;
        public String postalPlusFour;
        public String countryCode;
        public String addressType;
    }

    public class req_accountDetailsWrapper {
        public List<req_externalIdWrapper> externalId;
        public String emailId;
        public req_phoneDetailsWrapper phoneDetails;

        public req_accountDetailsWrapper() {
            externalId = new List<req_externalIdWrapper>();
            phoneDetails = new req_phoneDetailsWrapper();
        }
    }

    public class req_externalIdWrapper {
        public String key;
        public String value;
    }

    public class req_phoneDetailsWrapper {
        public Long phoneNumber;
        public Integer countryCode;
        public String phoneNumberType;
    }

    public class res_customerRecord {
        public String UCIDNumber;
    }
}