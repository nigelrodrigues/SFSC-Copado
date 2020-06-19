/**
 * @author Nigel Rodrigues, Traction on Demand
 * @date 4-June-2020
 * @description To get the customer's transaction history
 */

public with sharing class trac_WS_LoyaltyEvent {

    public static final String LEDGER_TITLE_TIER_VISIT_COUNTER = 'Tier Visit Counter';

    public final String ENDPOINT = ''+trac_WS_WebServiceHelper.webServiceSettings.Bay_Loyalty_Base_Endpoint__c
            + trac_WS_WebServiceHelper.webServiceSettings.Bay_Event_History__c;
    private final String SECRET_KEY = trac_WS_WebServiceHelper.webServiceSettings.Bay_Loyalty_Secret_Key__c;
    private final String UUID = trac_WS_WebServiceHelper.webServiceSettings.Bay_Loyalty_UUID__c;
    private HttpResponse res = new HttpResponse();
    public EventRequest eventRequest;
    public EventResponse eventResponse;
    public String jsonError;
    Map<String, String> params =  new Map<String, String>();
    Map<String, String> additionalHeaders = new Map<String, String>();

    public Boolean send(String email, String externalcustomerId) {
        additionalHeaders.put('x-api-key', trac_WS_WebServiceHelper.webServiceSettings.Bay_Loyalty_X_API_Key__c);
        additionalHeaders.put('x-apigw-api-id', trac_WS_WebServiceHelper.webServiceSettings.Bay_Loyalty_X_APIGW_API_ID__c);

        params.put('uuid', UUID);
        if( !String.isBlank(email)) {
            params.put('email', email);
        }
        if( !String.isBlank(externalCustomerId)) {
            params.put('external_customer_id', externalCustomerId);
        }
        params.put('points_detail', 'true');

        String sig = trac_WS_LoyaltyUtils.generateHash(SECRET_KEY, params);
        params.put('sig', sig);

        res = trac_WS_WebServiceHelper.SendGetRequest(ENDPOINT, params, false, additionalHeaders);
        if(trac_WS_WebServiceHelper.isValidResponse(res)) {
            System.debug('Event response: ' + res.getBody());
            eventResponse = parse(res.getBody());
            eventResponse.populateDisplayFields();
            return true;
        }
        else {
            jsonError = trac_WS_WebServiceHelper.getError(res);
            System.debug('Error: ' + trac_WS_WebServiceHelper.getError(res));
        }
        return false;
    }
    
    public static EventResponse parse(String json) {
        return (EventResponse) System.JSON.deserialize(json, EventResponse.class);
    }

    public class EventRequest {
    }
    
    public class res_dataWrapper {
        
        @AuraEnabled public Boolean showDetails = false;
        @AuraEnabled public Integer id;
        @AuraEnabled public String event_id;
        @AuraEnabled public Integer customer_id;
        @AuraEnabled public String email;
        @AuraEnabled public String event_type;
        @AuraEnabled public Integer status;
        @AuraEnabled public String detail;
        @AuraEnabled public String created_at;
        @AuraEnabled public String originated_at;
        @AuraEnabled public String updated_at;
        @AuraEnabled public String value;
        @AuraEnabled public Decimal points;
        @AuraEnabled public String external_customer_id;
        @AuraEnabled public String channel;
        @AuraEnabled public String sub_channel;
        @AuraEnabled public Integer tier_id;
        @AuraEnabled public String display_detail;
        @AuraEnabled public String display_sub_detail;
        @AuraEnabled public res_ruleWrapper rule;
        @AuraEnabled public String display_points_redeemed;
        @AuraEnabled public String display_points_earned;
        @AuraEnabled public Integer net_points;
    }
    public class res_ruleWrapper {
        @AuraEnabled public Integer id;
        @AuraEnabled public String rule_type;
        @AuraEnabled public List<res_ledgerWrapper> ledger;
    }
    public class res_ledgerWrapper {
        @AuraEnabled public Integer id;
        @AuraEnabled public String ledger_type;
        @AuraEnabled public String title;
        @AuraEnabled public Decimal points;
        @AuraEnabled public String display_points;
        //@AuraEnabled public res_dataWrapper data; // this is not the correct "data" specification, need to use a dedicated ledgerData subclass
    }
    public class res_event_paramsWrapper {
        @AuraEnabled public String event_type;
        @AuraEnabled public Integer reference_id;
        @AuraEnabled public String event_id;
    }
    public class EventResponse {
        @AuraEnabled public List<res_dataWrapper> data;
        @AuraEnabled public Boolean success;

        /**
        * @description Loops through data and populates display fields based on current instantiated values
        */
        private void populateDisplayFields() {
            if (!data.isEmpty()) {


                // use netPoints to record running tally
                Integer netPoints = 0;

                // iterate through list in reverse order, updating and stashing netPoints as we go
                for (Integer i=data.size()-1; i>=0; i--) {
                    // current row
                    res_dataWrapper row = data[i];

                    // netPoints
                    netPoints += Integer.valueOf(row.points);
                    row.net_points = netPoints;



                    // populate display_sub_detail
                    if (row.channel == 'pos') {
                        row.display_sub_detail = 'Store ' + row.sub_channel + ' - ' + row.channel.toUpperCase();
                    } else {
                        row.display_sub_detail = String.isBlank(row.channel) ? row.channel : row.channel.capitalize();
                    }

                    // populate display_points_redeemed
                    row.display_points_redeemed = ((row.points != null && row.points < 0) ? String.valueOf(row.points) : '0' );

                    // populate display_points_earned
                    row.display_points_earned = ((row.points != null && row.points > 0) ? '+' + row.points : '0');

                    // populate rule.ledger.display_points_earned
                    if (row.rule != null && row.rule.ledger != null) {

                        List<res_ledgerWrapper> newLedger = new List<res_ledgerWrapper>();
                        for (res_ledgerWrapper ledgerRow : row.rule.ledger) {
                            // filter out Tier Visit Counter ledger rows
                            if (ledgerRow.title != LEDGER_TITLE_TIER_VISIT_COUNTER) {
                                Decimal ledgerPoints = ledgerRow.points != null ? ledgerRow.points : 0;
                                ledgerRow.display_points = (ledgerPoints >= 0 ? '+' : '') + Integer.valueOf(ledgerRow.points);
                                newLedger.add( ledgerRow );
                            }
                        }
                        row.rule.ledger = newLedger;

                    }
                }
            }
        }
    }
}