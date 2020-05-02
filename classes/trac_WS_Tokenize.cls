/**
 *  @description API Class for tokenization via TokenEx
 *  @author      Jeremy Horan, Traction on Demand.
 *  @date        2/5/2020
 */
public with sharing class trac_WS_Tokenize {

    public final String ENDPOINT = trac_WS_WebServiceHelper.webServiceSettings.Tokenex_Endpoint__c;

    private HttpResponse res = new HttpResponse();
    public TokenizeRequest tokenizeRequest;
    public TokenizeResponse tokenizeResponse;
    public String jsonError;

    public trac_WS_Tokenize() {
        tokenizeRequest = new TokenizeRequest();
    }

    public Boolean send() {
        Boolean success = false;

        res = trac_WS_WebServiceHelper.sendPostRequest(ENDPOINT, tokenizeRequest);
        if(trac_WS_WebServiceHelper.isValidResponse(res)) {
            tokenizeResponse = parse(res.getBody());
            success = true;
        }
        else {
            try {
                tokenizeResponse = parse(res.getBody());
            } catch (Exception e) {}
            jsonError = trac_WS_WebServiceHelper.getError(res);
            System.debug('Error: ' + trac_WS_WebServiceHelper.getError(res));
        }
        return success;
    }
    public static TokenizeResponse parse(String json) {
        return (TokenizeResponse) System.JSON.deserialize(json, TokenizeResponse.class);
    }

    public class TokenizeRequest {
        public String APIKey;
        public String TokenExID;
        public String Data;
        public Integer TokenScheme;
    }
    public class TokenizeResponse {
        public String Error;
        public String ReferenceNumber;
        public Boolean Success;
        public String Token;
    }
}