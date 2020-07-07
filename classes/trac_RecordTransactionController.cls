/**
 * @description Apex controller for trac_RecordTransaction lightning component
 * @author Alex Kong, Traction on Demand
 * @date 2020-06-05
 */

public with sharing class trac_RecordTransactionController {



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


     *  @param dateToCompare Date comparision for transaction date. Difference cannot be greater than 90 days
     *  will default to today's date if null
     * @return TLAuraResponse object
     */
    @AuraEnabled
    public static TLAuraResponse recordTransaction(RecordTransactionParameters params, Date dateToCompare) {
        TLAuraResponse response = new TLAuraResponse(true);
        if(dateToCompare == null) dateToCompare = System.today();
        validateParams(params, response, dateToCompare);


        // any validation errors?
        if (response.isSuccess) {
            // no errors so far; callout to endpoint
            try {
                trac_WS_RecordLoyaltyEvent evt = new trac_WS_RecordLoyaltyEvent();
                evt.loyaltyId = params.loyaltyNumber;
                evt.email = params.email;
                evt.eventType = 'purchase';

                evt.value = params.totalEarn;
                evt.eventId = params.transactionNumber;
                evt.originatedAt = params.transactionDateObj.formatGmt(DATETIME_FORMAT);


                switch on params.transactionOrigin.toLowerCase() {
                    when 'website' {
                        evt.detail = 'Manual points award for order ' + params.orderNumber;
                    }
                    when 'store' {
                        evt.detail = 'Manual points award for in-store purchase';
                    }
                    when 'mhf' {
                        evt.detail = 'Manual points award for MHF purchase';
                    }
                }
                evt.eventChannel = 'UAD';
                Case aCase = getCase(params.caseRecordId);
                evt.subChannel = aCase != null ? aCase.CaseNumber : '';
                User aUser = getUser(UserInfo.getUserId());
                evt.subChannelDetail = aUser != null ? aUser.Email : '';
                if (evt.send()) {
                    // successful callout


                    response.returnValuesMap.put('body', evt.eventResponse);


                    response.message = 'Successfully recorded transaction ' + params.transactionNumber;
                    response.returnValuesMap.put('id', evt.eventResponse.data.id);
                    response.returnValuesMap.put('points', evt.eventResponse.data.points);
                } else {
                    // unsuccessful callout
                    response.isSuccess = false;


                    response.returnValuesMap.put('body', evt.getBody());


                    if (evt.eventResponse != null) {
                        response.message = evt.eventResponse.data.message;
                    } else {
                        response.message = evt.jsonError;



                    }
                }
                response.returnValuesMap.put('statusCode', evt.getStatusCode());



            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        } else {
            response.message = 'You have errors in your form submission.';
        }

        return response;
    }



    private static User getUser(Id userId) {
        List<User> users = [
                SELECT Id, Email
                FROM User
                WHERE Id = :userId
        ];
        return (!users.isEmpty()) ? users[0] : null;
    }

    private static Case getCase(Id caseId) {
        List<Case> cases = [
                SELECT CaseNumber
                FROM Case
                WHERE Id = :caseId
        ];
        return (!cases.isEmpty()) ? cases[0] : null;
    }


    private static Boolean validateParams(RecordTransactionParameters params, TLAuraResponse response, Date dateToCompare) {

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

        if (String.isBlank(params.orderNumber) && params.transactionOrigin == 'Website') {

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


            Date trnDate = trnDatetime == null ? null : Date.newinstance(trnDatetime.year(), trnDatetime.month(), trnDatetime.day());
            if (trnDatetime == null) {
                // failed to parse transactionDate
                response.isSuccess = false;
                response.returnValuesMap.put('transactionDate', 'Invalid Transaction Date: ' + params.transactionDate);


            } else if (trnDate > dateToCompare) {
                response.isSuccess = false;
                response.returnValuesMap.put('transactionDate', 'Transaction Date cannot be future: ' + params.transactionDate);
            } else if(trnDate.daysBetween(dateToCompare) > 90) {
                response.isSuccess = false;
                response.returnValuesMap.put('transactionDate', 'Transaction Date cannot be more than 90 days old: ' + params.transactionDate);


            } else {
                // successfully parsed transactionDate
                params.transactionDateObj = trnDatetime;
            }
        }
        if (params.transactionSubtotal == null || params.transactionSubtotal <= 0) {
            response.isSuccess = false;

            response.returnValuesMap.put('transactionSubtotal', 'Transaction Subtotal is invalid');
        }
        if (params.exclusionSubtotal < 0) {
            response.isSuccess = false;
            response.returnValuesMap.put('exclusionSubtotal', 'Subtotal of Excluded Items is invalid');

        }
        if (params.exclusionSubtotal == null) {
            params.exclusionSubtotal = 0.00;
        }


        if(params.totalEarn < 0) {
            response.isSuccess = false;
            response.returnValuesMap.put('total earn', 'Total Earn cannot be negative');
        }

        response.returnValuesMap.put('validForm', response.isSuccess);


        return response.isSuccess;
    }

    public class RecordTransactionParameters {
        @AuraEnabled

        public String caseRecordId {get; set;}
        @AuraEnabled

        public String loyaltyNumber {get; set;}
        @AuraEnabled
        public String email {get; set;}
        @AuraEnabled
        public String transactionOrigin {get; set;}
        @AuraEnabled
        public String orderNumber {get; set;}
        @AuraEnabled
        public String transactionNumber {get; set;}
        @AuraEnabled
        public String transactionDate {get; set;}


        public Datetime transactionDateObj;
        @AuraEnabled
        public Decimal transactionSubtotal {get; set;}
        @AuraEnabled
        public Decimal exclusionSubtotal {get; set;}

        @AuraEnabled
        public Decimal totalEarn {get; set;}

    }
}