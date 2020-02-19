/**
 *  @description Lightning controller for trac_NewOrder
 *  @author      Jeremy Horan, Traction on Demand.
 *  @date        7/4/2019
 */
public without sharing class trac_NewOrderCtlr {

    @AuraEnabled
    public static TLAuraResponse createNewOrder(String caseId, String contactId) {
        TLAuraResponse response = new TLAuraResponse(true);

        try {
            Case aCase = getCaseFromId(caseId);
            Contact contact = aCase.Contact;

            if (aCase.ContactId == null && contactId != null) {
                contact = getContactFromId(contactId);
            }

            trac_WS_CreateOrder createOrder = new trac_WS_CreateOrder();

            createOrder.createOrderRequest.Order.Action = trac_WS_OrderUtils.getCreateAction();
            createOrder.createOrderRequest.Order.AuthorizedClient = trac_WS_OrderUtils.getEnterpriseCodeFromBusinessUnit(aCase.Business_Unit__c);
            createOrder.createOrderRequest.Order.DocumentType = trac_WS_OrderUtils.getOrderType();
            createOrder.createOrderRequest.Order.EnterpriseCode = trac_WS_OrderUtils.getEnterpriseCodeFromBusinessUnit(aCase.Business_Unit__c);
            createOrder.createOrderRequest.Order.EntryType = trac_WS_OrderUtils.getNewOrderEntryType();
            createOrder.createOrderRequest.Order.OrderDate =trac_WS_OrderUtils.getFormattedDatetime(Datetime.now());

            if (contact != null && validateContact(contact)) {
                createOrder.createOrderRequest.Order.CustomerEMailID = contact.Email;
                createOrder.createOrderRequest.Order.BillToID = contact.Email; //TODO: validate the contact exists in OMS and use existing account if possible

                createOrder.createOrderRequest.Order.PersonInfoBillTo = getBillingAddressWrapperFromContact(contact);
                createOrder.createOrderRequest.Order.PersonInfoShipTo = getMailingAddressWrapperFromContact(contact);

                Boolean success = createOrder.send();

                if (success &&  createOrder.createOrderResponse != null && createOrder.createOrderResponse.OrderNo != null) {
                    aCase.Order_Number__c = createOrder.createOrderResponse.OrderNo;
                    update aCase;

                    User user = getUserById(UserInfo.getUserId());

                    if (user != null && user.EmployeeNumber != null) {
                        response.returnValuesMap.put('username', user.EmployeeNumber);
                    }
                    response.returnValuesMap.put('orderNumber', createOrder.createOrderResponse.OrderNo);
                }
                else {
                    Integration_Error__c integrationError = trac_IntegrationError.addError(new Integration_Error__c(
                            Description__c = createOrder.jsonError,
                            Endpoint__c = createOrder.ENDPOINT,
                            Request__c = JSON.serializePretty(createOrder.createOrderRequest),
                            Service__c = 'Create Order'
                    ));
                    insert integrationError;

                    response = new TLAuraResponse(false, 'Looks like there\'s a problem with OMS, give your admin this  error ID: ' + integrationError.Id);
                }
            }
            else {
                response = new TLAuraResponse(false, 'Please enter a valid Contact with a full address: Street, City, State, Country and Postal Code');
            }

            if (aCase.ContactId == null && contactId != null) {
                aCase.ContactId = contactId;
                update aCase;
            }

        } catch (Exception e) {
            response = new TLAuraResponse(false, e.getMessage() + '\n' + e.getStackTraceString());
        }

        return response;
    }

    @AuraEnabled
    public static TLAuraResponse getUserId() {
        TLAuraResponse response = new TLAuraResponse(true);

        User user = getUserById(UserInfo.getUserId());

        if (user != null && user.EmployeeNumber != null) {
            response.returnValuesMap.put('username', user.EmployeeNumber);
        }

        return response;
    }

    private static trac_WS_CreateOrder.req_AddressWrapper getMailingAddressWrapperFromContact(Contact contact) {
        trac_WS_CreateOrder.req_AddressWrapper addressWrapper = new trac_WS_CreateOrder.req_AddressWrapper();

        if (contact != null) {
            addressWrapper.AddressLine1 = contact.MailingStreet;
            addressWrapper.City = contact.MailingCity;
            addressWrapper.Country = contact.MailingCountryCode;
            addressWrapper.State = contact.MailingStateCode;
            addressWrapper.ZipCode = contact.MailingPostalCode;
            addressWrapper.DayPhone = TLString.getUnformattedPhoneNumber(contact.Mailing_Phone__c);
            addressWrapper.EMailID = contact.Mailing_Email__c;
            addressWrapper.FirstName = contact.Mailing_First_Name__c;
            addressWrapper.LastName = contact.Mailing_Last_Name__c;
        }

        return addressWrapper;
    }

    private static trac_WS_CreateOrder.req_AddressWrapper getBillingAddressWrapperFromContact(Contact contact) {
        trac_WS_CreateOrder.req_AddressWrapper addressWrapper = new trac_WS_CreateOrder.req_AddressWrapper();

        if (contact != null) {
            addressWrapper.AddressLine1 = contact.OtherStreet;
            addressWrapper.City = contact.OtherCity;
            addressWrapper.Country = contact.OtherCountryCode;
            addressWrapper.State = contact.OtherStateCode;
            addressWrapper.ZipCode = contact.OtherPostalCode;
            addressWrapper.DayPhone = TLString.getUnformattedPhoneNumber(contact.Phone);
            addressWrapper.EMailID = contact.Email;
            addressWrapper.FirstName = contact.FirstName;
            addressWrapper.LastName = contact.LastName;
        }

        return addressWrapper;
    }

    private static Boolean validateContact(Contact contact) {
        Boolean isValid = true;

        if (contact == null) {
            isValid = false;
        }
        if (contact.MailingStreet == null) {
            isValid = false;
        }
        if (contact.MailingCity == null) {
            isValid = false;
        }
        if (contact.MailingCountryCode == null) {
            isValid = false;
        }
        if (contact.MailingStateCode == null) {
            isValid = false;
        }
        if (contact.MailingPostalCode == null) {
            isValid = false;
        }
        if (contact.OtherStreet == null) {
            isValid = false;
        }
        if (contact.OtherCity == null) {
            isValid = false;
        }
        if (contact.OtherCountryCode == null) {
            isValid = false;
        }
        if (contact.OtherStateCode == null) {
            isValid = false;
        }
        if (contact.OtherPostalCode == null) {
            isValid = false;
        }

        return isValid;
    }

    private static Contact getContactFromId(String contactId) {
        List<Contact> contacts = [
                SELECT Id, FirstName, LastName, MailingStreet, MailingCity, MailingCountryCode, MailingStateCode, MailingPostalCode,
                        OtherStreet, OtherCity, OtherCountryCode, OtherStateCode, OtherPostalCode, Phone, Email, Mailing_First_Name__c, Mailing_Last_Name__c,
                        Mailing_Email__c, Mailing_Phone__c
                FROM Contact
                WHERE Id = :contactId
        ];

        return (!contacts.isEmpty()) ? contacts[0] : null;
    }

    private static Case getCaseFromId(String caseId) {
        List<Case> cases = [
                SELECT Id, Business_Unit__c, ContactId, Contact.FirstName, Contact.LastName, Contact.MailingStreet,
                        Contact.MailingCity, Contact.MailingCountryCode, Contact.MailingStateCode, Contact.MailingPostalCode,
                        Contact.OtherStreet, Contact.OtherCity, Contact.OtherCountryCode, Contact.OtherStateCode,
                        Contact.OtherPostalCode, Contact.Phone, Contact.Email, Contact.Mailing_First_Name__c, Contact.Mailing_Last_Name__c,
                        Contact.Mailing_Email__c, Contact.Mailing_Phone__c
                FROM Case
                WHERE Id = :caseId
        ];

        return (!cases.isEmpty()) ? cases[0] : null;
    }

    private static User getUserById(Id userId) {
        List<User> users = [
                SELECT Id, EmployeeNumber
                FROM User
                WHERE Id = :userId
        ];
        return (!users.isEmpty()) ? users[0] : null;
    }
}