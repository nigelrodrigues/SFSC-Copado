public with sharing class ShoppingCartAuraController {

    @AuraEnabled
    public static TLAuraResponse getAgentAccessToken(String recordId)
    {
        TLAuraResponse response = new TLAuraResponse(true);
        try{
            Case aCase = getCaseById(recordId);

            if (aCase != null)
            {
                if(String.isBlank(aCase.Contact.SFCC_Customer_Id__c))
                    response.returnValuesMap.put('isBlank', true);

                SCCCommerceCloudConnect.businessUnit = aCase.Business_Unit__c;

                response = setStoreSessionURL(response);
                response = setGuestStoreFrontURL(response);

                String agentAccessToken = SCCCommerceCloudConnect.connectToCommerceCloud(aCase.Business_Unit__c);

                if ( !String.isBlank(agentAccessToken))
                {
                    response = setCustomerAuthToken(agentAccessToken, aCase, response);
                }
            }
            else if (aCase != null && aCase.ContactId != null && aCase.Contact != null)
            {
                response.returnValuesMap.put('contact', aCase.Contact);
            }
            else
            {
                response = new TLAuraResponse(false, 'No Case Found');
            }
        }
        catch(Exception e)
        {
            Integration_Error__c integrationError = trac_IntegrationError.addError(new Integration_Error__c(
                    Description__c = e.getMessage() + '\n' + e.getStackTraceString(),
                    Endpoint__c = String.valueOf(setStoreSessionURL(response).returnValuesMap.get('storeSessionURL')),
                    Request__c = '',
                    Service__c = 'Get Agent Access Token'
            ));
            insert integrationError;

            String errorMessage = trac_WS_WebServiceHelper.DEFAULT_ERROR + integrationError.Id;
            response = new TLAuraResponse(false, errorMessage);
            System.debug('Error: ' + e.getMessage() +e.getStackTraceString());
        }

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

    private static TLAuraResponse setGuestStoreFrontURL(TLAuraResponse response)
    {
        String storeFrontURL = SCCCommerceCloudConnect.siteBaseUrl + '/on/demandware.store/Sites-' + SCCCommerceCloudConnect.siteId + '-Site';
        response.returnValuesMap.put('storeFrontURL', storeFrontURL);

        String guestStoreFrontURL = storeFrontURL + '/en_US/Login-Logout';
        response.returnValuesMap.put('guestStoreFrontURL', guestStoreFrontURL);

        return response;
    }

    private static TLAuraResponse setStoreSessionURL(TLAuraResponse response)
    {
        String storeSessionURL = SCCCommerceCloudConnect.siteBaseUrl + '/s/' + SCCCommerceCloudConnect.siteId + '/dw/shop/v17_4/sessions';
        response.returnValuesMap.put('storeSessionURL', storeSessionURL);
        return response;
    }

    private static TLAuraResponse setCustomerAuthToken(String agentAccessToken, Case aCase, TLAuraResponse response)
    {
        String customerAuthToken;
        if (aCase.Contact != null)
        {
            customerAuthToken = SCCCommerceCloudConnect.getCustomerAuthToken(agentAccessToken, aCase.Contact.SFCC_Customer_Id__c);
            response.returnValuesMap.put('customerAuthToken', customerAuthToken);
        }

        else {
            customerAuthToken = SCCCommerceCloudConnect.getCustomerAuthToken(agentAccessToken, null);
            response.returnValuesMap.put('customerAuthToken', customerAuthToken);
            response.returnValuesMap.put('agentAccessToken', agentAccessToken);
        }
        return response;
    }


}