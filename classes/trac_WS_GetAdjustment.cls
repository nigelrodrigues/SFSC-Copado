/**
 *  @description Web Service Class for Getting Sales Price Adjustments By Id
 *  @author      Jeremy Horan, Traction on Demand.
 *  @date        2/10/2020
 */
public without sharing class trac_WS_GetAdjustment {
    private final String ENDPOINT = (trac_WS_WebServiceHelper.webServiceSettings.Base_Url__c != null) ?
            trac_WS_WebServiceHelper.webServiceSettings.Base_Url__c + trac_WS_WebServiceHelper.webServiceSettings.SPA_Get_Adjustment_Endpoint__c : trac_WS_WebServiceHelper.webServiceSettings.SPA_Get_Adjustment_Endpoint__c;
    private HttpResponse res = new HttpResponse();
    public String adjustmentId;
    public trac_Adjustment getAdjustmentResponse;
    public String jsonError;

    public Boolean send() {
        Boolean success = false;
        String dynamicEndpoint = (adjustmentId != null ? ENDPOINT.replace('{id}',adjustmentId) : ENDPOINT);
        res = trac_WS_WebServiceHelper.sendGetRequest(dynamicEndpoint, null);
        if(trac_WS_WebServiceHelper.isValidResponse(res)) {
            getAdjustmentResponse = parse(res.getBody());
            success = true;
        }
        else {
            jsonError = trac_WS_WebServiceHelper.getError(res);
            System.debug('Error: ' + trac_WS_WebServiceHelper.getError(res));
        }
        return success;
    }
    public static trac_Adjustment parse(String json) {
        return (trac_Adjustment) System.JSON.deserialize(json, trac_Adjustment.class);
    }
}