/**
 * @description Apex controller for trac_RecordTransaction lightning component
 * @author Alex Kong, Traction on Demand
 * @date 2020-06-05
 */

public with sharing class trac_RecordTransactionController {

    private static final Map<String,String> mapTransactionOriginToChannel = new Map<String,String>{
            'website' => 'online',
            'pos' => 'pos'
    };

    private static final String DATETIME_FORMAT = 'yyyy-MM-dd HH:mm:ss z';

    /**
     * @description Submits a Record Event request (type=purchase) to Merkle API
     * @param params RecordTransactionParameters, inner class object of all params for this method:
     *  loyaltyNumber String, the external customer id
     *  email String, the customer email
     *  transactionOrigin String, the transaction origin (eg. 'website')
     *  orderNumber String, the order number
     *  transactionNumber String, the specific transaction or shipment number
     *  transactionDate String, the transaction date/time (expected format: Mar. 04, 2020, 06:31 a.m.)
     *  transactionSubtotal Decimal, the order subtotal
     *  exclusionSubtotal Decimal, the amount to exclude
     * @return TLAuraResponse object
     */
    @AuraEnabled
    public static TLAuraResponse recordTransaction(RecordTransactionParameters params) {
        TLAuraResponse response = new TLAuraResponse(true);

        validateParams(params, response);

        // any validation errors?
        if (response.isSuccess) {
            // no errors so far; callout to endpoint
            try {
                trac_WS_RecordLoyaltyEvent evt = new trac_WS_RecordLoyaltyEvent();
                evt.loyaltyId = params.loyaltyNumber;
                evt.email = params.email;
                evt.eventType = 'purchase';
                evt.value = params.transactionSubtotal - params.exclusionSubtotal;
                evt.eventId = params.transactionNumber;
                evt.originatedAt = params.transactionDateObj.formatGmt(DATETIME_FORMAT);
                evt.detail = params.orderNumber;
                evt.eventChannel = mapTransactionOriginToChannel.get( params.transactionOrigin );

                if (evt.send()) {
                    // successful callout
                    System.debug('evt.eventResponse: ' + evt.eventResponse);
                    response.message = 'Successfully recorded transaction ' + params.transactionNumber;
                    response.returnValuesMap.put('id', evt.eventResponse.data.id);
                    response.returnValuesMap.put('points', evt.eventResponse.data.points);
                } else {
                    // unsuccessful callout
                    response.isSuccess = false;
                    if (evt.eventResponse != null) {
                        response.message = evt.eventResponse.data.message;
                    } else {
                        response.message = evt.jsonError;
                        System.debug('JSON error response: ' + evt.jsonError);
                    }
                }
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        } else {
            response.message = 'You have errors in your form submission.';
        }

        return response;
    }

    private static Boolean validateParams(RecordTransactionParameters params, TLAuraResponse response) {
        if (String.isBlank(params.loyaltyNumber)) {
            response.isSuccess = false;
            response.returnValuesMap.put('loyaltyNumber', 'Loyalty Number missing');
        }
        if (String.isBlank(params.email)) {
            response.isSuccess = false;
            response.returnValuesMap.put('email', 'Email address missing');
        }
        if (String.isBlank(params.transactionOrigin)) {
            response.isSuccess = false;
            response.returnValuesMap.put('transactionOrigin', 'Transaction Origin missing');
        }
        if (String.isBlank(params.orderNumber)) {
            response.isSuccess = false;
            response.returnValuesMap.put('orderNumber', 'Order Number missing');
        }
        if (String.isBlank(params.transactionNumber)) {
            response.isSuccess = false;
            response.returnValuesMap.put('transactionNumber', 'Transaction Number missing');
        }
        Datetime trnDatetime;
        if (String.isBlank(params.transactionDate)) {
            response.isSuccess = false;
            response.returnValuesMap.put('transactionDate', 'Transaction Date missing');
        } else {
            // parse transactionDate using trac_WS_LoyaltyUtils.parseDateString()
            trnDatetime = trac_WS_LoyaltyUtils.parseDateString(params.transactionDate);
            if (trnDatetime == null) {
                // failed to parse transactionDate
                response.isSuccess = false;
                response.returnValuesMap.put('transactionDate', 'Invalid Transaction Date ' + params.transactionDate);
            } else {
                // successfully parsed transactionDate
                params.transactionDateObj = trnDatetime;
            }
        }
        if (params.transactionSubtotal == null || params.transactionSubtotal <= 0) {
            response.isSuccess = false;
            response.returnValuesMap.put('transactionSubtotal', 'Subtotal is invalid');
        }
        if (params.exclusionSubtotal == null) {
            params.exclusionSubtotal = 0.00;
        }

        return response.isSuccess;
    }

    public class RecordTransactionParameters {
        public String loyaltyNumber;
        public String email;
        public String transactionOrigin;
        public String orderNumber;
        public String transactionNumber;
        public String transactionDate;
        public Datetime transactionDateObj;
        public Decimal transactionSubtotal;
        public Decimal exclusionSubtotal;
    }
}