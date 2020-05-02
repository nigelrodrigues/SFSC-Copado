/**
 * @author Nigel Rodrigues, Traction on Demand
 * @description Class for handling creation of new Commerce Cloud user
 * @date 17-January-2020
 */

public with sharing class trac_HandleCommerceCloudAccount {


    /**
     * @description Agent can create a new user in Commerce Cloud
     *
     * @param email
     * @param lastName
     * @param businessUnit
     * @param contactId
     */
    @AuraEnabled
    public static TLAuraResponse createNewUser( String email, String firstName, String lastName, String businessUnit, String contactId) {
        String agentAccessToken = SCCCommerceCloudConnect.connectToCommerceCloud(businessUnit);
        TLAuraResponse response = new TLAuraResponse(true);
        SCCCommerceCloudConnect.businessUnit = businessUnit;
        String ENDPOINT = SCCCommerceCloudConnect.siteBaseUrl + '/s/' + SCCCommerceCloudConnect.siteId + '/dw/shop/v19_1/customers';
        try {
            trac_WS_HandleAccount newAccount = new trac_WS_HandleAccount();
            newAccount.accountReq.customer.login = lastName + System.currentTimeMillis();
            newAccount.accountReq.customer.email = email;
            newAccount.accountReq.customer.last_name = lastName;
            newAccount.accountReq.customer.first_name = firstName;

            newAccount.additionalHeaders.put('Authorization', 'Bearer ' + agentAccessToken);
            newAccount.businessUnit = businessUnit;

            response = newAccount.createNewSFCCAccount();
            if (response.isSuccess) {
                Contact relatedContact = new Contact(Id = contactId);

                relatedContact.SFCC_Customer_Number__c = newAccount.accountResp.customer_no;
                relatedContact.SFCC_Customer_Id__c = newAccount.accountResp.customer_id;
                System.debug('SFCC_Customer_Number__c: ' + relatedContact.SFCC_Customer_Number__c);
                System.debug('relatedContact.SFCC_Customer_Id__c : ' + relatedContact.SFCC_Customer_Id__c );
                update relatedContact;
                response.returnValuesMap.put('SFCC_customerId', newAccount.accountResp.customer_id);
                response.returnValuesMap.put('SFCC_customerNo', newAccount.accountResp.customer_id);
            }
        }
        catch(Exception e)
        {
            Integration_Error__c integrationError = trac_IntegrationError.addError(new Integration_Error__c(
                    Description__c = e.getMessage() + '\n' + e.getStackTraceString(),
                    Endpoint__c = ENDPOINT,
                    Request__c = ' ',
                    Service__c = 'Create new Commerce Cloud account'
            ));
            insert integrationError;

            String errorMessage = trac_WS_WebServiceHelper.DEFAULT_ERROR + integrationError.Id;
            response = new TLAuraResponse(false, errorMessage);
        }
        return response;
    }

    /**
     * @description Agent can reset the password of an existing user
     *
     * @param email
     * @param businessUnit
     */
    @AuraEnabled
    public static void resetPassword( String email, String businessUnit) {
        String agentAccessToken = SCCCommerceCloudConnect.connectToCommerceCloud(businessUnit);
        SCCCommerceCloudConnect.businessUnit = businessUnit;
        String ENDPOINT = SCCCommerceCloudConnect.siteBaseUrl + '/s/' + SCCCommerceCloudConnect.siteId + '/dw/shop/v19_1/customers/password_reset';

        try {
            trac_WS_HandleAccount newAccount = new trac_WS_HandleAccount();
            newAccount.businessUnit = businessUnit;
            newAccount.additionalHeaders.put('x-dw-client-id', SCCCommerceCloudConnect.sfccClientId);
            newAccount.additionalHeaders.put('Authorization', 'Bearer ' + agentAccessToken);

            newAccount.resetPassword(email);
        }
        catch(Exception e)
        {
            Integration_Error__c integrationError = trac_IntegrationError.addError(new Integration_Error__c(
                    Description__c = e.getMessage() + '\n' + e.getStackTraceString(),
                    Endpoint__c = ENDPOINT,
                    //Request__c = 'Request performed by sending PATCH request in aura component trac_HandleCustomerAccountStatus',
                    Service__c = 'Reset customer password'
            ));
            insert integrationError;
        }

    }

    /**
     * @description Agent can get the current status of customer account.
     * @date 7-February-2020
     * @param customerId
     * @param businessUnit
     */
    @AuraEnabled
    public static TLAuraResponse getCustomerAccountStatus( String customerId, String businessUnit) {

        TLAuraResponse response = new TLAuraResponse(true);
        String agentAccessToken = SCCCommerceCloudConnect.connectToCommerceCloud(businessUnit);
        SCCCommerceCloudConnect.businessUnit = businessUnit;
        String ENDPOINT = SCCCommerceCloudConnect.siteBaseUrl + '/s/' + SCCCommerceCloudConnect.siteId
                + '/dw/shop/v19_1/customers/' + customerId +'?expand=addresses,paymentinstruments';
        System.debug('ENDPOINT: ' + ENDPOINT);

        try {
            trac_WS_HandleAccount existingAccount = new trac_WS_HandleAccount();

            existingAccount.businessUnit = businessUnit;
            existingAccount.additionalHeaders.put('expand', 'addresses,paymentinstruments');
            existingAccount.additionalHeaders.put('Authorization', 'Bearer ' + agentAccessToken);

            response = existingAccount.getCustomerStatus(customerId);
        }
        catch(Exception e)
        {
            Integration_Error__c integrationError = trac_IntegrationError.addError(new Integration_Error__c(
                    Description__c = e.getMessage() + '\n' + e.getStackTraceString(),
                    Endpoint__c = ENDPOINT,
                    //Request__c = 'Request performed by sending PATCH request in aura component trac_HandleCustomerAccountStatus',
                    Service__c = 'Get Customer Account status'
            ));
            insert integrationError;

            String errorMessage = trac_WS_WebServiceHelper.DEFAULT_ERROR + integrationError.Id;
            response = new TLAuraResponse(false, errorMessage);
        }

        return response;
    }

    /**
     * @description Agent can update the status of customer account.
     *
     * @param status
     * @param customerNumber
     *
     * @return
     */
    @AuraEnabled
    public static TLAuraResponse getToken(String recordId) {
        TLAuraResponse response = new TLAuraResponse(true);
        String storeSessionURL='';

        try{
            Case aCase = getCaseById(recordId);


            if (aCase != null) {
                if (String.isBlank(aCase.Contact.SFCC_Customer_Id__c))
                    response.returnValuesMap.put('isBlank', true);

                SCCCommerceCloudConnect.businessUnit = aCase.Business_Unit__c;

                storeSessionURL = SCCCommerceCloudConnect.siteBaseUrl + '/s/' + SCCCommerceCloudConnect.siteId + '/dw/shop/v17_4/sessions';
                storeSessionURL = storeSessionURL.replace('sessions','customers/');
                response.returnValuesMap.put('storeSessionURL', storeSessionURL);

                String agentAccessToken = SCCCommerceCloudConnect.connectToCommerceCloud(aCase.Business_Unit__c);
                response.returnValuesMap.put('agentAccessToken', agentAccessToken);
            }

        }
        catch(Exception e)
        {
            Integration_Error__c integrationError = trac_IntegrationError.addError(new Integration_Error__c(
                    Description__c = e.getMessage() + '\n' + e.getStackTraceString(),
                    Endpoint__c = storeSessionURL,
                    Request__c = 'Request performed by sending PATCH request in aura component trac_HandleCustomerAccountStatus',
                    Service__c = 'Update Customer Account status'
            ));
            insert integrationError;

            String errorMessage = trac_WS_WebServiceHelper.DEFAULT_ERROR + integrationError.Id;
            response = new TLAuraResponse(false, errorMessage);
        }

        return response;
    }


    /**
     * Create address for the customer after commerce cloud account is created.
     *
     * @param customerId
     * @param phone
     * @param zipCode
     * @param businessUnit
     *
     * @return
     */
    @AuraEnabled
    public static TLAuraResponse createAddress(String customerId, String phone, String zipCode, String businessUnit)
    {
        TLAuraResponse response = new TLAuraResponse(true);

        trac_WS_HandleAccount newAccount = new trac_WS_HandleAccount();
        response = newAccount.createAddress(customerId, businessUnit, phone, zipcode);
        return response;
    }

    private static Case getCaseById(Id recordId) {

        List<Case> records = [
                SELECT Id, ContactId, Contact.Id, Contact.SFCC_Customer_Id__c, Contact.SFCC_Customer_Number__c, Contact.Email,
                        ContactEmail, Business_Unit__c
                FROM Case
                WHERE Id = :recordId
        ];
        return records.isEmpty() ? null : records[0];
    }




}