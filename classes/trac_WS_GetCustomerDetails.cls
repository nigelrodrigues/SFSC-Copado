/**
 *  @description Customer Query Service (UCID)
 *  @author      Jeremy Horan, Traction on Demand.
 *  @date        6/3/2019
 *
 *  @Modifications
 *  Rank and Order UCID Search Results - Piyush Bansal January 21,2020
 */
public with sharing class trac_WS_GetCustomerDetails {
    private final String ENDPOINT = (trac_WS_WebServiceHelper.webServiceSettings.Base_Url__c != null) ?
            trac_WS_WebServiceHelper.webServiceSettings.Base_Url__c + trac_WS_WebServiceHelper.webServiceSettings.UCID_Query_Endpoint__c : trac_WS_WebServiceHelper.webServiceSettings.UCID_Query_Endpoint__c;
    private HttpResponse res = new HttpResponse();
    public GetCustomerDetailsRequest getCustomerDetailsRequest;
    public GetCustomerDetailsResponse getCustomerDetailsResponse;
    public String jsonError;

    public trac_WS_GetCustomerDetails() {
        getCustomerDetailsRequest = new GetCustomerDetailsRequest();
    }

    public Boolean send() {
        res = trac_WS_WebServiceHelper.sendPostRequest(ENDPOINT, getCustomerDetailsRequest);
        if(trac_WS_WebServiceHelper.isValidResponse(res)) {
            getCustomerDetailsResponse = parse(res.getBody());
            return true;
        }
        else {
            jsonError = trac_WS_WebServiceHelper.getError(res);
            System.debug('Error: ' + trac_WS_WebServiceHelper.getError(res));

            try {
                getCustomerDetailsResponse = parse(res.getBody());
            }
            catch (Exception e) {

            }
        }
        return false;
    }
    public static GetCustomerDetailsResponse parse(String json) {
        return (GetCustomerDetailsResponse) System.JSON.deserialize(json, GetCustomerDetailsResponse.class);
    }

    public class GetCustomerDetailsRequest {
        public req_contactDetailsWrapper contactDetails;
        public req_accountDetailsWrapper accountDetails;
        public Integer recordCount;
        public Integer bannerCode;


        public GetCustomerDetailsRequest() {
            contactDetails = new req_contactDetailsWrapper();
            accountDetails = new req_accountDetailsWrapper();
        }
    }

    public class GetCustomerDetailsResponse {
        public List<res_customerRecordWrapper> customerRecord;
        public String responseMsg;
        public String TimeStamp;
        public String FlowName;
        public String ErrorLocation;
        public String ErrorCode;
        public String ErrorText;
        public String ErrorDescription;
    }

    public class req_contactDetailsWrapper {
        public String firstName;
        public String lastName;
        public String address1;
        public String address2;
        public String address3;
        public String city;
        public String stateCode;
        public String postCode;
        public String postalPlusFour;
        public String countryCode;
        public String addressType;
        public String emailId;
        public String phoneNumber;
    }
    public class req_accountDetailsWrapper {
        public List<req_externalIdWrapper> externalId;
        public String emailId;
        public req_phoneDetailsWrapper phoneDetails;
        public Long UCIDNumber;

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
        public Integer phoneNumber;
        public Integer countryCode;
        public String phoneNumberType;
    }

    public class res_customerRecordWrapper {
        public String firstName;
        public String middleName;
        public String lastName;
        public String prefix;
        public String gender;
        public String dateOfBirth;
        public String suffix;
        public String languagePref;
        public Integer bannerCode;
        public Long UCIDNumber;
        public String sourceCode;
        public List<res_externalIdWrapper> externalId;
        public res_contactDetailsWrapper contactDetails;
        public List<res_cardDetailsWrapper> cardDetails;
        public String primary_cardholder_IND;
    }
    public class res_externalIdWrapper {
        public String extTypeCode;
        public String extTypeValue;
    }
    public class res_contactDetailsWrapper {
        public String address1;
        public String address2;
        public String address3;
        public String city;
        public String stateCode;
        public String postCode;
        public String postalPlusFour;
        public String countryCode;
        public String addressType;
        public String emailId;
        public res_phoneDetailsWrapper phoneDetails;
    }
    public class res_phoneDetailsWrapper {
        public String phoneNumber;
        public Integer countryCode;
    }
    public class res_cardDetailsWrapper {
        public String type;
        public String tokenValue;
        public String lastFour;
        public String expiryMonth;
        public String expiryYear;
    }
}