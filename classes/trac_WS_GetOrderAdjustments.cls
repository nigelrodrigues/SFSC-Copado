/**
 *  @description Web Service Class for Getting Sales Price Adjustments By Order Number
 *  @author      Jeremy Horan, Traction on Demand.
 *  @date        2/10/2020
 */
public without sharing class trac_WS_GetOrderAdjustments {
    private final String ENDPOINT = (trac_WS_WebServiceHelper.webServiceSettings.Base_Url__c != null) ?
            trac_WS_WebServiceHelper.webServiceSettings.Base_Url__c + trac_WS_WebServiceHelper.webServiceSettings.SPA_Get_Order_Adjustments_Endpoint__c : trac_WS_WebServiceHelper.webServiceSettings.SPA_Get_Order_Adjustments_Endpoint__c;
    private HttpResponse res = new HttpResponse();
    public String orderNumber;
    public List<trac_Adjustment> getOrderAdjustmentsResponse;
    public String jsonError;

    public Boolean send() {
        Boolean success = false;
        String dynamicEndpoint = (orderNumber != null ? ENDPOINT.replace('{orderNumber}',orderNumber) : ENDPOINT);
        res = trac_WS_WebServiceHelper.sendGetRequest(dynamicEndpoint, null);
        if(trac_WS_WebServiceHelper.isValidResponse(res)) {
            system.debug('Response >> '+res.getBody());
            getOrderAdjustmentsResponse = parse(res.getBody());
            success = true;
        }
        else {
            jsonError = trac_WS_WebServiceHelper.getError(res);
            System.debug('Error: ' + trac_WS_WebServiceHelper.getError(res));
        }
        return success;
    }

    public static List<trac_Adjustment> parse(String json) {
        return (List<trac_Adjustment>) System.JSON.deserialize(json, List<trac_Adjustment>.class);
    }
}