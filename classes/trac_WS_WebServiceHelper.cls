/**
 *  @description Helper Class to run common Web Service functionality
 *  @author 	 Jeremy Horan, Traction on Demand.
 *  @date        2017-05-02
 */
public with sharing class trac_WS_WebServiceHelper {
    public static final String GET_METHOD    = 'GET';
    public static final String PUT_METHOD    = 'PUT';
    public static final String POST_METHOD   = 'POST';
    public static final String PATCH_METHOD  = 'PATCH';
    public static final String DELETE_METHOD = 'DELETE';
    public static final String DEFAULT_SOURCE_ID = 'SFUAD';
    public static final String DEFAULT_ERROR = 'OOPS, looks like something went wrong. Please give this code to your administrator and we\'ll have it fixed as soon as possible: ';

    public static final Web_Service_Settings__c webServiceSettings = (!Test.isRunningTest()) ? Web_Service_Settings__c.getOrgDefaults() : trac_TestUtils.setupWebServiceSettings();

    public static Boolean doNotStripNulls;

    /**
     *  @description Creates a POST request JSON string and sends it by serializing an object
     *  @author      Jeremy Horan, Traction on Demand.
     *  @date        2016-04-22
     */
    public static HttpResponse sendPostRequest(String endpoint, Object requestWrapper ) {
        return sendPostRequest(endpoint, requestWrapper, null);
    }

    /**
     *  @description Creates a POST request JSON string and sends it by serializing an object
     *  @author      Jeremy Horan, Traction on Demand.
     *  @date        2016-04-22
     */
    public static HttpResponse sendPostRequest(String endpoint, Object requestWrapper, Map<String, String> additionalHeaders) {
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();

        req.setEndpoint(endpoint);
        req.setTimeout(Integer.valueOf(webServiceSettings.Timeout__c));
        req.setMethod(POST_METHOD);
        req.setHeader('Accept', 'application/json');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('x-api-key', webServiceSettings.API_Key__c);
        req.setHeader('x-source-app', DEFAULT_SOURCE_ID);

        if (additionalHeaders != null) {
            for (String key : additionalHeaders.keySet()) {
                req.setHeader(key, additionalHeaders.get(key));
            }
        }

        String jsonString = Json.serialize(requestWrapper);
        jsonString = cleanString(jsonString);
        if (doNotStripNulls != true) {
            jsonString = stripJsonNulls(jsonString);
        }

        req.setHeader('Content-Length', String.valueOf(jsonString.length()));
        req.setBody(jsonString);

        if (webServiceSettings.Debug__c) {
            System.debug('----> endpoint: ' + endpoint);
            System.debug('----> body: ' + jsonString);
        }

        try {
            res = http.send(req);
            res.setBody(fixString(res.getBody()));
            System.debug('res: ' + res);
            System.debug('res body: ' + res.getBody());
        }
        catch (Exception e) {
            System.debug('Error: ' + e.getMessage() + '\n' + e.getStackTraceString());
        }

        return res;
    }

    /**
     *  @description Creates a PUT request JSON string and sends it by serializing an object
     *  @author      Jeremy Horan, Traction on Demand.
     *  @date        2016-04-22
     */
    public static HttpResponse sendPutRequest(String endpoint, Object requestWrapper) {
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();

        req.setEndpoint(endpoint);
        req.setTimeout(Integer.valueOf(webServiceSettings.Timeout__c));
        req.setMethod(PUT_METHOD);
        req.setHeader('Accept', 'application/json');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('x-api-key', webServiceSettings.API_Key__c);
        req.setHeader('x-source-app', DEFAULT_SOURCE_ID);

        String jsonString = Json.serialize(requestWrapper);
        jsonString = cleanString(jsonString);
        jsonString = stripJsonNulls(jsonString);

        req.setHeader('Content-Length', String.valueOf(jsonString.length()));
        req.setBody(jsonString);

        if (webServiceSettings.Debug__c) {
            System.debug('endpoint:' + endpoint);
            System.debug('body: ' + jsonString);
        }

        try {
            res = http.send(req);
            res.setBody(fixString(res.getBody()));
        }
        catch (Exception e) {
            System.debug('Error: ' + e.getMessage() + '\n' + e.getStackTraceString());
        }
        return res;
    }

    /**
     *  @description Overloaded method for ease of use to default fix string
     *  @author      Jeremy Horan, Traction on Demand.
     *  @date        2017-08-22
     */
    public static HttpResponse sendGetRequest(String endpoint, Map<String, String> parameters) {
        return sendGetRequest(endpoint, parameters, true);
    }

    /**
     *  @description Overloaded method for ease of use and backwards compatibility
     *  @author      Jeremy Horan, Traction on Demand.
     *  @date        6/7/2018
     */
    public static HttpResponse sendGetRequest(String endpoint, Map<String, String> parameters, Boolean fixString) {
        return sendGetRequest(endpoint, parameters, fixString, new Map<String, String>());
    }

    /**
 *  @description Overloaded method for ease of use and backwards compatibility
 *  @author      Bryan Cantos, HBC.
 *  @date        6/8/2020
 */
    public static HttpResponse sendGetRequest(String endpoint, Map<String, String> parameters, Boolean fixString, Map<String, String> additionalHeaders) {
        return sendGetRequest(endpoint, parameters, fixString, additionalHeaders, null);
    }

    /**
     *  @description Creates GET request and sends it with additional parameters passed into URL
     *  @author      Jeremy Horan, Traction on Demand.
     *  @date        2016-04-22
     */
    public static HttpResponse sendGetRequest(String endpoint, Map<String, String> parameters, Boolean fixString, Map<String, String> additionalHeaders, Integer timeout) {
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();

        if (parameters != null) {
            Boolean isFirstParameter = true;
            for (String key : parameters.keySet()) {
                String encodedValue = String.isNotBlank(parameters.get(key)) ? EncodingUtil.urlEncode(parameters.get(key), 'UTF-8') : '';
                if (isFirstParameter) {

                    endpoint = endpoint + '?' + key + '=' + encodedValue;
                    isFirstParameter = false;
                }
                else {
                    endpoint = endpoint + '&' + key + '=' + encodedValue;

                }
            }
        }

        if (webServiceSettings.Debug__c) {
            System.debug('endpoint from service helper: ' + endpoint);
        }

        req.setEndpoint(endpoint);
        if(timeout == null) {
            req.setTimeout(Integer.valueOf(webServiceSettings.Timeout__c)) ;
        } else {
            req.setTimeout(timeout);
        }
        req.setMethod(GET_METHOD);
        //TODO: handle this on a per API basis
//        req.setHeader('Accept', 'application/json');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('x-api-key', webServiceSettings.API_Key__c);
        req.setHeader('x-source-app', DEFAULT_SOURCE_ID);

        if (additionalHeaders != null) {
            for (String key : additionalHeaders.keySet()) {
                req.setHeader(key, additionalHeaders.get(key));
            }
        }

        try {
            res = http.send(req);
            if (fixString) {
                res.setBody(fixString(res.getBody()));
            }
        }
        catch (Exception e) {
            System.debug('Error from helper: ' + e.getMessage() + '\n' + e.getStackTraceString());
        }

        return res;
    }

    /**
     *  @description Creates DELETE request and sends it with additional parameters passed into URL
     *  @author      Jeremy Horan, Traction on Demand.
     *  @date        2016-04-22
     */
    public static HttpResponse sendDeleteRequest(String endpoint, Map<String, String> parameters) {

        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();

        if (parameters != null) {
            Boolean isFirstParameter = true;
            for (String key : parameters.keySet()) {
                if (isFirstParameter) {
                    endpoint = endpoint + '?' + key + '=' + parameters.get(key);
                    isFirstParameter = false;
                }
                else {
                    endpoint = endpoint + '&' + key + '=' + parameters.get(key);
                }
            }
        }

        if (webServiceSettings.Debug__c) {
            System.debug('endpoint: ' + endpoint);
        }

        req.setEndpoint(endpoint);
        req.setTimeout(Integer.valueOf(webServiceSettings.Timeout__c));
        req.setMethod(DELETE_METHOD);
        req.setHeader('Accept', 'application/json');
        req.setHeader('Content-Type', 'application/json');

        try {
            res = http.send(req);
            res.setBody(fixString(res.getBody()));
        }
        catch (Exception e) {
            System.debug('Error: ' + e.getMessage() + '\n' + e.getStackTraceString());
        }
        return res;
    }

    /**
     *  @description Creates a DELETE request JSON string and sends it by serializing an object
     *  @author      Jeremy Horan, Traction on Demand.
     *  @date        2016-04-22
     */
    public static HttpResponse sendDeleteRequest(String endpoint, Object requestWrapper) {
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();

        req.setEndpoint(endpoint);
        req.setTimeout(Integer.valueOf(webServiceSettings.Timeout__c));
        req.setMethod(DELETE_METHOD);
        req.setHeader('Accept', 'application/json');
        req.setHeader('Content-Type', 'application/json');

        String jsonString = Json.serialize(requestWrapper);
        jsonString = cleanString(jsonString);
        jsonString = stripJsonNulls(jsonString);

        req.setBody(jsonString);

        if (webServiceSettings.Debug__c) {
            System.debug('endpoint:' + endpoint);
            System.debug('body: ' + jsonString);
        }

        try {
            res = http.send(req);
            res.setBody(fixString(res.getBody()));
        }
        catch (Exception e) {
            System.debug('Error: ' + e.getMessage() + '\n' + e.getStackTraceString());
        }
        return res;
    }

    /**
     *  @description Returns true if the response given back is valid
     *  @author      Jeremy Horan, Traction on Demand.
     *  @date        2016-04-22
     */
    public static Boolean isValidResponse(HttpResponse res) {
        return res != null && (res.getStatusCode() == 200 || res.getStatusCode() == 201 || res.getStatusCode() == 204);
    }

    /**
     *  @description Returns string of error in Responce
     *  @author      Jeremy Horan, Traction on Demand.
     *  @date        2016-04-22
     */
    public static String getError(HttpResponse res) {
        return res.getBody();
    }

    /**
     *  @description Cleans JSON string when creating request to handle reserved variable names in APEX
     *  @author      Jeremy Horan, Traction on Demand.
     *  @date        2016-04-22
     */
    public static String cleanString(String jsonString) {
        jsonString = jsonString.replaceAll('"date_x":', '"date":');
        jsonString = jsonString.replaceAll('"group_x":', '"group":');
        jsonString = jsonString.replaceAll('"number_x":', '"number":');
        jsonString = jsonString.replaceAll('"type_x":', '"type":');
        jsonString = jsonString.replaceAll('"class_x":', '"class":');
        jsonString = jsonString.replaceAll('"time_x":', '"time":');
        jsonString = jsonString.replaceAll('"currency_x":', '"currency":');
        jsonString = jsonString.replaceAll('"Currency_x":', '"Currency":');
        jsonString = jsonString.replaceAll('"Number_x":', '"Number":');
        jsonString = jsonString.replaceAll('"Date_x":', '"Date":');


        return jsonString;
    }

    /**
     *  @description fixes JSON string when receiving response to handle reserved variable names in APEX
     *  @author      Jeremy Horan, Traction on Demand.
     *  @date        2016-04-25
     */
    public static String fixString(String jsonString) {
        jsonString = jsonString.replaceAll('"date":', '"date_x":');
        jsonString = jsonString.replaceAll('"group":', '"group_x":');
        jsonString = jsonString.replaceAll('"number":', '"number_x":');
        jsonString = jsonString.replaceAll('"type":', '"type_x":');
        jsonString = jsonString.replaceAll('"class":', '"class_x":');
        jsonString = jsonString.replaceAll('"time":', '"time_x":');
        jsonString = jsonString.replaceAll('"currency":', '"currency_x":');
        jsonString = jsonString.replaceAll('"Currency":', '"Currency_x":');
        jsonString = jsonString.replaceAll('"Number":', '"Number_x":');
        jsonString = jsonString.replaceAll('"Date":', '"Date_x":');
        // For Commerce cloud: Create new account fields:
        jsonString = jsonString.replaceAll('"_v":', '"v":');
        jsonString = jsonString.replaceAll('"_type":', '"type":');
        jsonString = jsonString.replaceAll('"_resource_state":', '"resource_state":');

        return jsonString;
    }

    /**
     *  @description Remove nulls from JSON Strings to avoid errors for invalid field values
     *  @author      Jeremy Horan, Traction on Demand.
     *  @date        2016-06-07
     */
    public static String stripJsonNulls(String jsonString)
    {
        if(jsonString != null)
        {
            jsonString = jsonString.replaceAll('\"[^\"]*\":null',''); //basic removal of null values
            jsonString = jsonString.replaceAll('\"[^\"]*\": null,',''); //basic removal of null values
            jsonString = jsonString.replaceAll(',{2,}', ','); //remove duplicate/multiple commas
            jsonString = jsonString.replace('{,', '{'); //prevent opening brace from having a comma after it
            jsonString = jsonString.replace(',}', '}'); //prevent closing brace from having a comma before it
            jsonString = jsonString.replace(',[^\"]*}', '}'); //prevent closing brace from having a comma before it
            jsonString = jsonString.replace('[,', '['); //prevent opening bracket from having a comma after it
            jsonString = jsonString.replace(',]', ']'); //prevent closing bracket from having a comma before it
        }

        return jsonString;
    }

}