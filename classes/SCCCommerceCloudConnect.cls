/**
* Connection class to SFCC(Salesforce Commerce Cloud) and pull related information
* 
*
* @author  Neeraj Yadav
* @version 1.0
* @since   2017-11-06 
*/
public without sharing class SCCCommerceCloudConnect {

    public static String businessUnit;

    /* specified site id on commerce cloud */
    public static String siteId {
        get { 
            if(String.isBlank(siteId) && businessUnit != null ) {
                String query = SCCQueryUtilClass.getInstance()
                                          .getQueryInstance()
                                          .setObjectName('SFCC_Configuration__mdt')
                                          .setRelatedFields(new Set<String>{'Id', 'DeveloperName', 'Store_ID__c'})
                                          .setClause('Business_Unit__c', '=', '\'' + String.escapeSingleQuotes(businessUnit) + '\'')
                                          .setLimit('1')
                                          .getQuery();
                List<SFCC_Configuration__mdt> objList = (List<SFCC_Configuration__mdt>)SCCQueryUtilClass.getRecords(query);

                if ( !objList.isEmpty()) {
                    siteId = objList[0].Store_ID__c;
                }
            }
            return siteId;
        }
        set;
    }
    
    /* specified customer list id on commerce cloud */
    public static String listId {
        get {           
            if(String.isBlank(listId) && businessUnit != null ) {
                String query = SCCQueryUtilClass.getInstance()
                                          .getQueryInstance()
                                          .setObjectName('SFCC_Configuration__mdt')
                                          .setRelatedFields(new Set<String>{'Id', 'DeveloperName', 'Customer_List_ID__c'})
                                          .setClause('Business_Unit__c', '=', '\'' + String.escapeSingleQuotes(businessUnit) + '\'')
                                          .setLimit('1')
                                          .getQuery();
                List<SFCC_Configuration__mdt> objList = (List<SFCC_Configuration__mdt>)SCCQueryUtilClass.getRecords(query);

                if ( !objList.isEmpty()) {
                    listId = objList[0].Customer_List_ID__c;
                }
            }           
            return listId;
        }
        set;
    }
    
    /* specified base url for commerce cloud platform to connect */
    public static String siteBaseUrl {
        get {           
            if(String.isBlank(siteBaseUrl) && businessUnit != null ) {
                String query = SCCQueryUtilClass.getInstance()
                                          .getQueryInstance()
                                          .setObjectName('SFCC_Configuration__mdt')
                                          .setRelatedFields(new Set<String>{'Id', 'DeveloperName', 'Storefront_URL__c'})
                                          .setClause('Business_Unit__c', '=', '\'' + String.escapeSingleQuotes(businessUnit) + '\'')
                                          .setLimit('1')
                                          .getQuery();
                List<SFCC_Configuration__mdt> objList = (List<SFCC_Configuration__mdt>)SCCQueryUtilClass.getRecords(query);
                if ( !objList.isEmpty()) {
                    siteBaseUrl = objList[0].Storefront_URL__c;
                }
            }
            return siteBaseUrl;
        }
        set;
    }
    
    /* specified client_id for doing connection with sfcc */
    public static String sfccClientId {
        get {
            if(String.isBlank(sfccClientId) && businessUnit != null ) {
                String query = SCCQueryUtilClass.getInstance()
                                          .getQueryInstance()
                                          .setObjectName('SFCC_Configuration__mdt')
                                          .setRelatedFields(new Set<String>{'Id', 'DeveloperName', 'Client_Id__c'})
                                          .setClause('Business_Unit__c', '=', '\'' + String.escapeSingleQuotes(businessUnit) + '\'')
                                          .setLimit('1')
                                          .getQuery();
                List<SFCC_Configuration__mdt> objList = (List<SFCC_Configuration__mdt>)SCCQueryUtilClass.getRecords(query);

                if ( !objList.isEmpty()) {
                    sfccClientId = objList[0].Client_Id__c;
                }
            }
            return sfccClientId;
        }
        set;
    }
    
    /* specified client_id for doing connection with sfcc */
    public static String sfccClientSecret {
        get {           
            if(String.isBlank(sfccClientSecret) && businessUnit != null) {
                String query = SCCQueryUtilClass.getInstance()
                                          .getQueryInstance()
                                          .setObjectName('SFCC_Configuration__mdt')
                                          .setRelatedFields(new Set<String>{'Id', 'DeveloperName', 'Client_Secret__c'})
                                          .setClause('Business_Unit__c', '=', '\'' + String.escapeSingleQuotes(businessUnit) + '\'')
                                          .setLimit('1')
                                          .getQuery();
                List<SFCC_Configuration__mdt> objList = (List<SFCC_Configuration__mdt>)SCCQueryUtilClass.getRecords(query);

                if ( !objList.isEmpty()) {
                    sfccClientSecret = objList[0].Client_Secret__c;
                }
            }
            return sfccClientSecret;
        }
        set;
    }

    public static String sfccDefaultCustomerId {
        get {
            if(String.isBlank(sfccDefaultCustomerId) && businessUnit != null) {
                String query = SCCQueryUtilClass.getInstance()
                        .getQueryInstance()
                        .setObjectName('SFCC_Configuration__mdt')
                        .setRelatedFields(new Set<String>{'Id', 'DeveloperName', 'Default_Customer_Id__c'})
                        .setClause('Business_Unit__c', '=', '\'' + String.escapeSingleQuotes(businessUnit) + '\'')
                        .setLimit('1')
                        .getQuery();

                List<SFCC_Configuration__mdt> objList = (List<SFCC_Configuration__mdt>)SCCQueryUtilClass.getRecords(query);
                System.debug('objList: ' + objList);

                if ( !objList.isEmpty()) {
                    sfccDefaultCustomerId = objList[0].Default_Customer_Id__c;
                }
            }
            return sfccDefaultCustomerId;
        }
        set;
    }


    /**
    * This method used for set connection to commerce cloud and return the access_token.
    * @return String.
    */
    public static String connectToCommerceCloud(String businessUnitString) {
        String token = '';

        businessUnit = businessUnitString;

        User user = getCurrentUser();

        if (user != null && user.SFCC_Username__c != null && user.SFCC_Password__c != null) {
            String authString = EncodingUtil.base64Encode(Blob.valueOf(user.SFCC_Username__c + ':' + user.SFCC_Password__c +':' + sfccClientSecret));

            HttpRequest req = new HttpRequest();
            req.setEndpoint(siteBaseUrl + '/dw/oauth2/access_token?client_id=' + sfccClientId);
            req.setHeader('Authorization', 'Basic ' + authString);
            req.setMethod('POST');
            req.setTimeout(Integer.valueOf(trac_WS_WebServiceHelper.webServiceSettings.Timeout__c));
            req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            req.setBody('grant_type=urn:demandware:params:oauth:grant-type:client-id:dwsid:dwsecuretoken');
            Http https = new Http();

            HttpResponse res = https.send(req);

            Map<String, Object> jsonMap = (Map<String, Object>) System.JSON.deserializeUntyped(res.getBody());
            if (jsonMap.containsKey('access_token')) {
                token = (String) jsonMap.get('access_token');
            }
        }
        return token;

    }

    /**
    * This method used for set connection to commerce cloud and return the access_token.
    * @return String.
    */
    public static String connectToCommerceCloud2ProfileOperations() {

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:SFCCClientCreds/dw/oauth2/access_token');
        req.setMethod('POST');
        req.setTimeout(Integer.valueOf(trac_WS_WebServiceHelper.webServiceSettings.Timeout__c));
        req.setHeader('Authorization', 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(sfccClientId + ':' + sfccClientSecret)));
        req.setHeader('Content-Type','application/x-www-form-urlencoded');
        req.setBody('grant_type=client_credentials');
        Http https = new Http();
        HttpResponse res = https.send(req);
        Map<String, Object> jsonMap = (Map<String, Object>)System.JSON.deserializeUntyped(res.getBody());
        if(jsonMap.containsKey('access_token')) {
            return (String)jsonMap.get('access_token');
        }
        return '';
        
    }    
  
    public static String getCustomerAuthToken(String agentToken, String scccustomerid){

        String customerAuthToken = null;

        HttpRequest req = new HttpRequest();

        String relUrl = '/s/'+ siteId +'/dw/shop/v17_4/customers/';
        if (scccustomerid == null) {
            scccustomerid = sfccDefaultCustomerId;
        }

        if (scccustomerid != null) {
            relUrl += scccustomerid + '/';
            req.setBody('{"type" : "credentials"}');
        }
        else {
            req.setBody('{"type" : "guest"}');
            req.setHeader('x-dw-client-id', sfccClientId);
        }
        relUrl += 'auth';

		req.setEndpoint(siteBaseUrl + relUrl);
		req.setMethod('POST');
        req.setTimeout(Integer.valueOf(trac_WS_WebServiceHelper.webServiceSettings.Timeout__c));
        req.setHeader('Content-Type','application/json');
        req.setHeader('Content-Length', '0');
        req.setHeader('Authorization', 'Bearer '+agentToken);

		Http https = new Http();
		HttpResponse res = https.send(req);
        customerAuthToken = res.getHeader('Authorization');

		return customerAuthToken;
    }
    
    /**
    * This method used for pulling selected order details from commerce cloud.
    * @param orderNumber: String
    * @param accessToken: String
    * @return String.
    */
    public static String getOrderDetails(String orderNumber, String accessToken) {
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(siteBaseUrl + '/s/' + siteId + '/dw/shop/v17_8/orders/' + orderNumber);
        req.setMethod('GET');
        req.setTimeout(Integer.valueOf(trac_WS_WebServiceHelper.webServiceSettings.Timeout__c));
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Content-Type', 'application/json; charset=UTF-8');
        Http h = new Http();
        HttpResponse res = h.send(req);

        return res.getBody();
        
    }    
    
    /**
    * This method used for pulling selected customer details from commerce cloud using customer no.
    * @param customerNumber: String
    * @param accessToken: String
    * @return String.
    */
    public static String getCustomerDetails(String customerNumber, String accessToken) {
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(siteBaseUrl + '/s/-/dw/data/v17_8/customer_lists/' + listId + '/customers/' + customerNumber);
        req.setMethod('GET');
        req.setTimeout(Integer.valueOf(trac_WS_WebServiceHelper.webServiceSettings.Timeout__c));
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Content-Type', 'application/json; charset=UTF-8');
        Http h = new Http();
        HttpResponse res = h.send(req);

        return res.getBody();

    }
    
    /**
     * Unused method hence commented
    * This method used for pulling selected customer details from commerce cloud using customer ID.
    * @param customerNumber: String
    * @param accessToken: String
    * @return String.
    */
    public static String getCustomerDetailsById(String customerId, String accessToken) {
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(siteBaseUrl + '/s/' + siteId + '/dw/shop/v18_3/customers/' + customerId +'?expand=addresses,paymentinstruments');
        req.setMethod('GET');
        req.setTimeout(Integer.valueOf(trac_WS_WebServiceHelper.webServiceSettings.Timeout__c));
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Content-Type', 'application/json; charset=UTF-8');
        Http h = new Http();
        HttpResponse res = h.send(req);

        return res.getBody();

    }

    
    public static String getAddressDetails(String customerNumber, String accessToken) { 
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(siteBaseUrl + '/s/-/dw/data/v17_8/customer_lists/' + listId + '/customers/' + customerNumber + '/addresses');
        req.setMethod('GET');
        req.setTimeout(Integer.valueOf(trac_WS_WebServiceHelper.webServiceSettings.Timeout__c));
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Content-Type', 'application/json; charset=UTF-8');
        Http h = new Http();
        HttpResponse res = h.send(req);
        return res.getBody();

    }

	public static String postAddressDetails(String body, String customerNumber, String accessToken) {
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(siteBaseUrl + '/s/-/dw/data/v17_8/customer_lists/' + listId + '/customers/' + customerNumber + '/addresses');
        req.setMethod('POST');
        req.setTimeout(Integer.valueOf(trac_WS_WebServiceHelper.webServiceSettings.Timeout__c));
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Content-Type', 'application/json; charset=UTF-8');
		req.setBody(body);
        Http h = new Http();
        HttpResponse res = h.send(req);
        return res.getBody();

    }
    
    /**
    * This method used for pulling selected customer profile details from commerce cloud.
    * @param email: String
    * @param accessToken: String
    * @return String.
    */
    public static String searchCustomerByEmail(String email, String accessToken) {
        
        if(String.isEmpty(email)){
            throw new CalloutException('Empty mandatory parameters');
        }
        HttpRequest req = new HttpRequest();
        req.setEndpoint(siteBaseUrl + '/s/-/dw/data/v17_8/customer_lists/' + listId + '/customer_search');
        req.setMethod('POST');
        req.setTimeout(Integer.valueOf(trac_WS_WebServiceHelper.webServiceSettings.Timeout__c));
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Content-Type', 'application/json; charset=UTF-8');
        String body = '{"query":{"text_query":{"fields":["email", "phone_home", "phone_business", "phone_mobile"],"search_phrase":"' + email + '"}}}';
        req.setBody(body);
        Http h = new Http();
        HttpResponse res = h.send(req);

        return res.getBody();

    }
    
    /**
    * This method used for pushing selected customer profile to update to commerce cloud.
    * @param body: String
    * @param customerNo: String
    * @param accessToken: String
    * @return String.
    */
    public static HttpResponse updateCCCustomerProfile(String body, String customerNo, String accessToken) {
        
        if(String.isEmpty(body) || String.isEmpty(customerNo)){
            throw new CalloutException('Empty mandatory parameters');
        }
        HttpRequest req = new HttpRequest();
        req.setEndpoint(siteBaseUrl + '/s/-/dw/data/v17_8/customer_lists/' + listId + '/customers/' + customerNo);
        req.setMethod('POST');
        req.setTimeout(Integer.valueOf(trac_WS_WebServiceHelper.webServiceSettings.Timeout__c));
	    req.setHeader('x-dw-http-method-override', 'PATCH');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Content-Type', 'application/json; charset=UTF-8');
        req.setBody(body);
        Http h = new Http();
        HttpResponse res = h.send(req);

        return res;

    }    
    

	/**
    * This method used for pushing selected order to update to commerce cloud.
    * @param body: String
    * @param orderNo: String
    * @param accessToken: String
    * @return String.
    */
    public static String pushOrderDetails(String body, String orderNo, String accessToken) {
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(siteBaseUrl + '/s/' + siteId + '/dw/shop/v18_3/orders/' + orderNo);
        req.setMethod('POST');
        req.setTimeout(Integer.valueOf(trac_WS_WebServiceHelper.webServiceSettings.Timeout__c));
        req.setHeader('x-dw-http-method-override', 'PATCH');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Content-Type', 'application/json; charset=UTF-8');
        //String body = '{"c_crmid":"' + contactId + '"}';
        req.setBody(body);
        Http h = new Http();
        HttpResponse res = h.send(req);
        return res.getBody();
    }

    public static User getCurrentUser() {
        List<User> users = [
                SELECT Id, SFCC_Username__c, SFCC_Password__c
                FROM User
                WHERE Id = :UserInfo.getUserId()
        ];

        return (!users.isEmpty()) ? users[0] : null;
    }
}