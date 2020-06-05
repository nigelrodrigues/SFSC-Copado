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

    @AuraEnabled
    public static TLAuraResponse recordTransaction(String loyaltyNumber, String email, String transactionOrigin, String orderNumber, String transactionNumber, Decimal transactionSubtotal, Decimal exclusionSubtotal) {
        TLAuraResponse response = new TLAuraResponse(true);

        // validation
        if (String.isBlank(loyaltyNumber)) {
            response.isSuccess = false;
            response.returnValuesMap.put('loyaltyNumber', 'Loyalty Number missing');
        }
        if (String.isBlank(email)) {
            response.isSuccess = false;
            response.returnValuesMap.put('email', 'Email address missing');
        }
        if (String.isBlank(transactionOrigin)) {
            response.isSuccess = false;
            response.returnValuesMap.put('transactionOrigin', 'Transaction Origin missing');
        }
        if (String.isBlank(orderNumber)) {
            response.isSuccess = false;
            response.returnValuesMap.put('orderNumber', 'Order Number missing');
        }
        if (String.isBlank(transactionNumber)) {
            response.isSuccess = false;
            response.returnValuesMap.put('transactionNumber', 'Transaction Number missing');
        }
        if (transactionSubtotal == null || transactionSubtotal <= 0) {
            response.isSuccess = false;
            response.returnValuesMap.put('transactionSubtotal', 'Subtotal is invalid');
        }
        if (exclusionSubtotal == null) {
            exclusionSubtotal = 0.00;
        }

        // callout to Merkle API to award points
        try {
            if (response.isSuccess) {
                // no errors so far; callout to endpoint
                trac_WS_RecordLoyaltyEvent evt = new trac_WS_RecordLoyaltyEvent();
                evt.loyaltyId = loyaltyNumber;
                evt.email = email;
                evt.eventType = 'purchase';
                evt.value = transactionSubtotal - exclusionSubtotal;
                evt.eventId = transactionNumber;
                //evt.originatedAt = transactionDate;
                evt.detail = orderNumber;
                evt.eventChannel = mapTransactionOriginToChannel.get( transactionOrigin );

                if (evt.send()) {
                    // successful callout
                    response.message = 'Successfully recorded transaction ' + transactionNumber;
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
            } else {
                response.message = 'You have errors in your form submission.';
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return response;
    }
}