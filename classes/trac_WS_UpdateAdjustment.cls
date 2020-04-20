/**
 *  @description Web Service Class for Updating Sales Price Adjustments By Id
 *  @author      Jeremy Horan, Traction on Demand.
 *  @date        2/10/2020
 */
public without sharing class trac_WS_UpdateAdjustment {
    private final String ENDPOINT = (trac_WS_WebServiceHelper.webServiceSettings.Base_Url__c != null) ?
            trac_WS_WebServiceHelper.webServiceSettings.Base_Url__c + trac_WS_WebServiceHelper.webServiceSettings.SPA_Update_Adjustment_Endpoint__c : trac_WS_WebServiceHelper.webServiceSettings.SPA_Update_Adjustment_Endpoint__c;
    private HttpResponse res = new HttpResponse();
    public String adjustmentId;
    public trac_Adjustment updateAdjustmentRequest;
    public trac_Adjustment updateAdjustmentResponse;
    public String jsonError;

    public Boolean send() {
        Boolean success = false;
        String dynamicEndpoint = (adjustmentId != null ? ENDPOINT.replace('{id}',adjustmentId) : ENDPOINT);
        res = trac_WS_WebServiceHelper.sendPutRequest(dynamicEndpoint, updateAdjustmentRequest);
        if(trac_WS_WebServiceHelper.isValidResponse(res)) {
            updateAdjustmentResponse = parse(res.getBody());
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