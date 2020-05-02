/**
 *  @description Utilities class for Customer APIs, contains methods to facilitate interacting with external data
 *  @author      Jeremy Horan, Traction on Demand.
 *  @date        6/10/2019
 */
public with sharing class trac_WS_CustomerUtils {

    private static final Integer DEFAULT_SEARCH_COUNT = 10;
    private static final String DEFAULT_SOURCE_CODE = trac_WS_WebServiceHelper.DEFAULT_SOURCE_ID;
    private static final String DEFAULT_BANNER_CODE = '4';
    private static final String DEFAULT_LANGUAGE_CODE = '0';
    private static final String EXTERNAL_ID_SFCC_ID = 'SFCC_GUID';
    private static final String EXTERNAL_ID_SFCC_CUSTOMER_NUMBER = 'SFCC';
    private static final String EXTERNAL_ID_LOYALTY = 'BM';

    private static Map<String, Map<String, Reference_Data__mdt>> referenceDataBySystemValueByType = trac_ReferenceData.getReferenceDataMappedByValueByType('UCID', 'System_Value__c');
    private static Map<String, Map<String, Reference_Data__mdt>> referenceDataBySalesforceValueByType = trac_ReferenceData.getReferenceDataMappedByValueByType('UCID', 'Salesforce_Value__c');

    public static void syncContactFromExternal(Id contactId) {
        Contact contact = getContactWithFields(contactId);

        syncContactFromExternal(contact);
    }

    public static void syncContactFromExternal(Contact contact) {

        trac_WS_GetCustomerDetails.GetCustomerDetailsResponse customerDetailsResponse = searchContactByEmail(contact);

        if (customerDetailsResponse != null && customerDetailsResponse.customerRecord != null && !customerDetailsResponse.customerRecord.isEmpty()) {

            Contact ucidContact = getContactFromSearchResponse(customerDetailsResponse);
            if (ucidContact != null) {
                Contact contactToUpdate = getUpdatedContact(contact, ucidContact);
                contactToUpdate.Latest_System_Update__c = trac_ContactConstants.ORIGIN_UCID;
                contactToUpdate.UCID_Update_Date__c = Datetime.now();
                try {
                    update contactToUpdate;
                } catch (Exception e) {

                }
            }
        } else {

            trac_WS_CreateCustomerDetails.CreateCustomerDetailsResponse createCustomerDetailsResponse = createContact(contact);
            if (createCustomerDetailsResponse != null && createCustomerDetailsResponse.customerRecord != null && createCustomerDetailsResponse.customerRecord.UCIDNumber != null) {
                contact.UCID_Number__c = createCustomerDetailsResponse.customerRecord.UCIDNumber;
                contact.Latest_System_Update__c = trac_ContactConstants.ORIGIN_SALESFORCE;
                contact.UCID_Update_Date__c = Datetime.now();
                update contact;
            }

        }
    }

    /*public static trac_WS_GetCustomerDetails.GetCustomerDetailsResponse searchContact(Id contactId) {
        Contact contact = getContactWithFields(contactId);
        return searchContact(contact);
    }*/

    public static trac_WS_GetCustomerDetails.GetCustomerDetailsResponse searchContact(Contact contact) {
        trac_WS_GetCustomerDetails customerDetails = new trac_WS_GetCustomerDetails();

        customerDetails.getCustomerDetailsRequest.contactDetails.firstName = getString(contact.FirstName);
        if (contact.LastName == null || contact.LastName != contact.Phone) {
            customerDetails.getCustomerDetailsRequest.contactDetails.lastName = getString(contact.LastName);
        }
        customerDetails.getCustomerDetailsRequest.contactDetails.address1 = getString(contact.MailingStreet);
        customerDetails.getCustomerDetailsRequest.contactDetails.city = getString(contact.MailingCity);
        customerDetails.getCustomerDetailsRequest.contactDetails.stateCode = getString(contact.MailingStateCode);
        customerDetails.getCustomerDetailsRequest.contactDetails.postCode = getString(contact.MailingPostalCode);
        customerDetails.getCustomerDetailsRequest.contactDetails.emailId = getString(contact.Email);
        customerDetails.getCustomerDetailsRequest.contactDetails.phoneNumber = getString(String.valueOf(TLString.getUnformattedPhoneNumber(contact.Phone)));

        customerDetails.getCustomerDetailsRequest.recordCount = DEFAULT_SEARCH_COUNT;
        customerDetails.getCustomerDetailsRequest.bannerCode = getInteger(getBannerCodeFromBusinessUnit(contact.Business_Unit__c));

        customerDetails.send();

        return customerDetails.getCustomerDetailsResponse;
    }

    public static trac_WS_GetCustomerDetails.GetCustomerDetailsResponse searchContactByEmail(Contact contact) {
        trac_WS_GetCustomerDetails customerDetails = new trac_WS_GetCustomerDetails();

        if (contact != null && contact.Email != null) {
            customerDetails.getCustomerDetailsRequest.contactDetails.emailId = getString(contact.Email);
            customerDetails.send();
        }

        return customerDetails.getCustomerDetailsResponse;
    }

    public static trac_WS_CreateCustomerDetails.CreateCustomerDetailsResponse createContact(Id contactId) {
        Contact contact = getContactWithFields(contactId);
        return createContact(contact);
    }

    public static trac_WS_CreateCustomerDetails.CreateCustomerDetailsResponse createContact(Contact contact) {
        trac_WS_CreateCustomerDetails createCustomerDetails = new trac_WS_CreateCustomerDetails();

        createCustomerDetails.createCustomerDetailsRequest.firstName = getString(contact.FirstName);
        createCustomerDetails.createCustomerDetailsRequest.lastName = getString(contact.LastName);
        createCustomerDetails.createCustomerDetailsRequest.prefix = getString(contact.Salutation);
        createCustomerDetails.createCustomerDetailsRequest.languagePrefCode = getInteger(getLanguageCodeFromLanguage(contact.Language__c));
        createCustomerDetails.createCustomerDetailsRequest.dateOfBirth = String.valueOf(contact.Birthdate);

        createCustomerDetails.createCustomerDetailsRequest.sourceId = getString(DEFAULT_SOURCE_CODE);
        createCustomerDetails.createCustomerDetailsRequest.bannerCode = getInteger(getBannerCodeFromBusinessUnit(contact.Business_Unit__c));
        createCustomerDetails.createCustomerDetailsRequest.emailActiveIND = getOptInCodeFromOptIn(contact.Email_Marketing__c);
        createCustomerDetails.createCustomerDetailsRequest.phoneActiveIND = getOptInCodeFromOptIn(contact.Phone_Marketing__c);
        createCustomerDetails.createCustomerDetailsRequest.addressActiveIND = getOptInCodeFromOptIn(contact.Mail_Marketing__c);

        createCustomerDetails.createCustomerDetailsRequest.accountDetails.emailId = getString(contact.Email);
        createCustomerDetails.createCustomerDetailsRequest.accountDetails.phoneDetails.phoneNumber = getLong(TLString.getUnformattedPhoneNumber(contact.Phone));

        createCustomerDetails.createCustomerDetailsRequest.accountDetails.contactDetails.address1 = getString(contact.MailingStreet);
        createCustomerDetails.createCustomerDetailsRequest.accountDetails.contactDetails.city = getString(contact.MailingCity);
        createCustomerDetails.createCustomerDetailsRequest.accountDetails.contactDetails.stateCode = getString(contact.MailingStateCode);
        createCustomerDetails.createCustomerDetailsRequest.accountDetails.contactDetails.postCode = getString(contact.MailingPostalCode);
        createCustomerDetails.createCustomerDetailsRequest.accountDetails.contactDetails.countryCode = getString(contact.MailingCountryCode);

        createCustomerDetails.send();

        return createCustomerDetails.createCustomerDetailsResponse;
    }

    public static trac_WS_UpdateCustomerDetails.UpdateCustomerDetailsResponse updateContact(Id contactId) {
        Contact contact = getContactWithFields(contactId);
        return updateContact(contact);
    }

    public static trac_WS_UpdateCustomerDetails.UpdateCustomerDetailsResponse updateContact(Contact contact) {
        trac_WS_UpdateCustomerDetails updateCustomerDetails = new trac_WS_UpdateCustomerDetails();

        if (contact != null) {
            updateCustomerDetails.updateCustomerDetailsRequest.UCIDNumber = getLong(contact.UCID_Number__c);

            updateCustomerDetails.updateCustomerDetailsRequest.firstName = getString(contact.FirstName);
            updateCustomerDetails.updateCustomerDetailsRequest.lastName = getString(contact.LastName);
            updateCustomerDetails.updateCustomerDetailsRequest.prefix = getString(contact.Salutation);
            updateCustomerDetails.updateCustomerDetailsRequest.languagePrefCode = getInteger(getLanguageCodeFromLanguage(contact.Language__c));
            updateCustomerDetails.updateCustomerDetailsRequest.dateOfBirth = String.valueOf(contact.Birthdate);

            updateCustomerDetails.updateCustomerDetailsRequest.sourceId = getString(DEFAULT_SOURCE_CODE);
            updateCustomerDetails.updateCustomerDetailsRequest.bannerCode = getInteger(getBannerCodeFromBusinessUnit(contact.Business_Unit__c));
            updateCustomerDetails.updateCustomerDetailsRequest.emailActiveIND = getOptInCodeFromOptIn(contact.Email_Marketing__c);
            updateCustomerDetails.updateCustomerDetailsRequest.phoneActiveIND = getOptInCodeFromOptIn(contact.Phone_Marketing__c);
            updateCustomerDetails.updateCustomerDetailsRequest.addressActiveIND = getOptInCodeFromOptIn(contact.Mail_Marketing__c);

            updateCustomerDetails.updateCustomerDetailsRequest.accountDetails.emailId = getString(contact.Email);
            updateCustomerDetails.updateCustomerDetailsRequest.accountDetails.phoneDetails.phoneNumber = getLong(TLString.getUnformattedPhoneNumber(contact.Phone));

            updateCustomerDetails.updateCustomerDetailsRequest.contactDetails.address1 = getString(contact.MailingStreet);
            updateCustomerDetails.updateCustomerDetailsRequest.contactDetails.city = getString(contact.MailingCity);
            updateCustomerDetails.updateCustomerDetailsRequest.contactDetails.stateCode = getString(contact.MailingStateCode);
            updateCustomerDetails.updateCustomerDetailsRequest.contactDetails.postCode = getString(contact.MailingPostalCode);
            updateCustomerDetails.updateCustomerDetailsRequest.contactDetails.countryCode = getString(contact.MailingCountryCode);

            Boolean success = updateCustomerDetails.send();

            if (success) {
                contact.Latest_System_Update__c = trac_ContactConstants.ORIGIN_SALESFORCE;
                contact.UCID_Update_Date__c = Datetime.now();
                update contact;
            }
        }

        return updateCustomerDetails.updateCustomerDetailsResponse;
    }

    public static Contact getContactFromSearchResponse(trac_WS_GetCustomerDetails.GetCustomerDetailsResponse customerDetailsResponse) {
        Contact contact;

        List<Contact> contacts = getContactsFromSearchResponse(customerDetailsResponse);

        if (contacts.size() == 1) {
            contact = contacts[0];
        }

        return contact;
    }

    public static List<Contact> getContactsFromSearchResponse(trac_WS_GetCustomerDetails.GetCustomerDetailsResponse customerDetailsResponse) {
        List<Contact> contacts = new List<Contact>();

        if (customerDetailsResponse != null & customerDetailsResponse.customerRecord != null) {
            for (trac_WS_GetCustomerDetails.res_customerRecordWrapper customerRecord : customerDetailsResponse.customerRecord) {
                contacts.add(getContactFromSearchResponse(customerRecord));
            }
        }

        return contacts;
    }

    public static Contact getContactFromSearchResponse(trac_WS_GetCustomerDetails.res_customerRecordWrapper customerRecord) {
        Contact contact = new Contact();

        if (customerRecord != null) {
            if (customerRecord.firstName != null) {
                contact.FirstName = customerRecord.firstName;
            }
            if (customerRecord.middleName != null) {
                contact.MiddleName = customerRecord.middleName;
            }
            if (customerRecord.lastName != null) {
                contact.LastName = customerRecord.lastName;
            }
            if (customerRecord.prefix != null) {
                contact.Salutation = customerRecord.prefix;
            }
            if (customerRecord.dateOfBirth != null) {
                contact.Birthdate = getDate(customerRecord.dateOfBirth);
            }
            if (customerRecord.bannerCode != null) {
                contact.Business_Unit__c = getBusinessUnitFromCode(String.valueOf(customerRecord.bannerCode));
            }
            if (customerRecord.UCIDNumber != null) {
                contact.UCID_Number__c = String.valueOf(customerRecord.UCIDNumber);
            }
            if (getUniqueExternalId(contact) != null) {
                contact.Unique_External_Id__c = getUniqueExternalId(contact);
            }

            if (customerRecord.languagePref != null) {
                contact.Language__c = getLanguageFromLanguageCode(customerRecord.languagePref);
            }

            if (customerRecord.externalId != null) {
                contact.SFCC_Customer_Id__c = getCommerceCloudId(customerRecord);
                contact.SFCC_Customer_Number__c = getCommerceCloudCustomerNumber(customerRecord);
                contact.Loyalty_Number__c = getLoyaltyId(customerRecord);
            }

            if (customerRecord.contactDetails != null) {
                if (getMailingStreetFromContactDetails(customerRecord.contactDetails) != null) {
                    contact.MailingStreet = getMailingStreetFromContactDetails(customerRecord.contactDetails);
                }

                if (customerRecord.contactDetails.city != null) {
                    contact.MailingCity = customerRecord.contactDetails.city;
                }
                if (customerRecord.contactDetails.stateCode != null) {
                    contact.MailingStateCode = customerRecord.contactDetails.stateCode;
                }
                if (customerRecord.contactDetails.postCode != null) {
                    contact.MailingPostalCode = customerRecord.contactDetails.postCode;
                }
                if (customerRecord.contactDetails.countryCode != null) {
                    contact.MailingCountryCode = customerRecord.contactDetails.countryCode;
                }

                if (customerRecord.contactDetails.emailId != null) {
                    contact.Email = customerRecord.contactDetails.emailId;
                }

                if (customerRecord.contactDetails.phoneDetails != null && customerRecord.contactDetails.phoneDetails.phoneNumber != null) {
                    contact.Phone = customerRecord.contactDetails.phoneDetails.phoneNumber;
                }
            }

        }

        return contact;
    }

    public static Contact getContactFromOrderByContact(Contact contact) {
        Contact orderContact;

        if (contact.Business_Unit__c != null && contact.Order_Number__c != null) {
            trac_WS_GetOrderDetails.GetOrderDetailsResponse orderDetailsResponse = trac_WS_OrderUtils.getOrderDetailsResponseFromOrderNumber(contact.Business_Unit__c, contact.Order_Number__c);
            orderContact = getContactFromOrderDetailResponse(orderDetailsResponse);
            if (orderContact != null) {
                orderContact.Business_Unit__c = contact.Business_Unit__c;
            }
        }

        return orderContact;
    }

    public static Contact getContactFromOrderDetailResponse(trac_WS_GetOrderDetails.GetOrderDetailsResponse orderDetailsResponse) {
        Contact contact;

        if (orderDetailsResponse != null && orderDetailsResponse.PersonInfoBillTo != null && orderDetailsResponse.PersonInfoBillTo.FirstName != null
                && orderDetailsResponse.PersonInfoBillTo.LastName != null && orderDetailsResponse.PersonInfoBillTo.EMailID != null) {
            contact = new Contact();
            contact.Title = orderDetailsResponse.PersonInfoBillTo.Title;
            contact.FirstName = orderDetailsResponse.PersonInfoBillTo.FirstName;
            contact.LastName = orderDetailsResponse.PersonInfoBillTo.LastName;
            contact.Email = orderDetailsResponse.PersonInfoBillTo.EMailID;
            contact.Phone = orderDetailsResponse.PersonInfoBillTo.DayPhone;
            contact.MailingCountryCode = orderDetailsResponse.PersonInfoBillTo.Country;
            contact.MailingStateCode = orderDetailsResponse.PersonInfoBillTo.State;
            contact.MailingPostalCode = orderDetailsResponse.PersonInfoBillTo.ZipCode;
            contact.MailingCity = orderDetailsResponse.PersonInfoBillTo.City;
            contact.MailingStreet = orderDetailsResponse.PersonInfoBillTo.AddressLine1;
            contact.Order_Number__c = orderDetailsResponse.OrderNo;

            if (orderDetailsResponse.PersonInfoBillTo.AddressLine2 != null) {
                contact.MailingStreet += ' ' + orderDetailsResponse.PersonInfoBillTo.AddressLine2;
            }

            if (orderDetailsResponse.PersonInfoBillTo.AddressLine3 != null) {
                contact.MailingStreet += ' ' + orderDetailsResponse.PersonInfoBillTo.AddressLine3;
            }
        }

        return contact;
    }

    private static Contact getUpdatedContact(Contact originalContact, Contact newContact) {

        if (originalContact.FirstName == null) {
            originalContact.FirstName = newContact.FirstName;
        }
        if (originalContact.MiddleName == null) {
            originalContact.MiddleName = newContact.MiddleName;
        }
        if (originalContact.LastName == null) {
            originalContact.LastName = newContact.LastName;
        }
        if (originalContact.Salutation == null) {
            originalContact.Salutation = newContact.Salutation;
        }
        if (originalContact.Birthdate == null) {
            originalContact.Birthdate = newContact.Birthdate;
        }
        if (originalContact.Business_Unit__c == null) {
            originalContact.Business_Unit__c = newContact.Business_Unit__c;
        }
        if (originalContact.UCID_Number__c == null) {
            originalContact.UCID_Number__c = newContact.UCID_Number__c;
        }
        if (originalContact.Unique_External_Id__c == null) {
            originalContact.Unique_External_Id__c = newContact.Unique_External_Id__c;
        }

        if (originalContact.Language__c == null) {
            originalContact.Language__c = newContact.Language__c;
        }

        if (originalContact.MailingStreet == null) {
            originalContact.MailingStreet = newContact.MailingStreet;
        }

        if (originalContact.MailingCity == null) {
            originalContact.MailingCity = newContact.MailingCity;
        }
        if (originalContact.MailingStateCode == null) {
            originalContact.MailingStateCode = newContact.MailingStateCode;
        }
        if (originalContact.MailingPostalCode == null) {
            originalContact.MailingPostalCode = newContact.MailingPostalCode;
        }
        if (originalContact.MailingCountryCode == null) {
            originalContact.MailingCountryCode = newContact.MailingCountryCode;
        }

        if (originalContact.Email == null) {
            originalContact.Email = newContact.Email;
        }

        if (originalContact.Phone == null) {
            originalContact.Phone = newContact.Phone;
        }
        if (originalContact.SFCC_Customer_Id__c == null) {
            originalContact.SFCC_Customer_Id__c = newContact.SFCC_Customer_Id__c;
        }

        return originalContact;
    }

    private static String getMailingStreetFromContactDetails(trac_WS_GetCustomerDetails.res_contactDetailsWrapper contactDetails) {
        String mailingStreet = '';
        if (contactDetails.address1 != null) {
            mailingStreet += contactDetails.address1;
        }
        if (contactDetails.address2 != null) {
            mailingStreet += contactDetails.address2;
        }
        if (contactDetails.address3 != null) {
            mailingStreet += contactDetails.address3;
        }
        if (mailingStreet == '') {
            mailingStreet = null;
        }

        return mailingStreet;
    }

    private static String getBusinessUnitFromCode(String businessUnitCode) {
        String businessUnit;

        if (referenceDataBySystemValueByType.containsKey('Banner Code')) {
            Map<String, Reference_Data__mdt> referenceDataByValue = referenceDataBySystemValueByType.get('Banner Code');

            if (referenceDataByValue.containsKey(businessUnitCode)) {
                businessUnit = referenceDataByValue.get(businessUnitCode).Salesforce_Value__c;
            }
        }

        return businessUnit;
    }

    private static String getBannerCodeFromBusinessUnit(String businessUnit) {
        String bannerCode;

        if (referenceDataBySalesforceValueByType.containsKey('Banner Code')) {
            Map<String, Reference_Data__mdt> referenceDataByValue = referenceDataBySalesforceValueByType.get('Banner Code');

            if (referenceDataByValue.containsKey(businessUnit)) {
                bannerCode = referenceDataByValue.get(businessUnit).System_Value__c;
            }
        }

        if (bannerCode == null) {
            bannerCode = DEFAULT_BANNER_CODE;
        }

        return bannerCode;
    }

    private static String getLanguageCodeFromLanguage(String language) {
        String languageCode;

        if (referenceDataBySalesforceValueByType.containsKey('Language Code')) {
            Map<String, Reference_Data__mdt> referenceDataByValue = referenceDataBySalesforceValueByType.get('Language Code');

            if (referenceDataByValue.containsKey(language)) {
                languageCode = referenceDataByValue.get(language).System_Value__c;
            }
        }

        if (languageCode == null) {
            languageCode = DEFAULT_LANGUAGE_CODE;
        }

        return languageCode;
    }

    private static String getLanguageFromLanguageCode(String languageCode) {
        String language;

        if (referenceDataBySystemValueByType.containsKey('Language Code')) {
            Map<String, Reference_Data__mdt> referenceDataByValue = referenceDataBySystemValueByType.get('Language Code');

            if (referenceDataByValue.containsKey(languageCode)) {
                language = referenceDataByValue.get(languageCode).Salesforce_Value__c;
            }
        }

        return language;
    }

    private static String getOptInCodeFromOptIn(String optIn) {
        String optInCode;

        if (referenceDataBySystemValueByType.containsKey('Opt In Code')) {
            Map<String, Reference_Data__mdt> referenceDataByValue = referenceDataBySalesforceValueByType.get('Opt In Code');

            if (referenceDataByValue.containsKey(optIn)) {
                optInCode = referenceDataByValue.get(optIn).System_Value__c;
            }
        }

        return optInCode;
    }

    private static String getOptInFromOptInCode(String optInCode) {
        String optIn;

        if (referenceDataBySystemValueByType.containsKey('Opt In Code')) {
            Map<String, Reference_Data__mdt> referenceDataByValue = referenceDataBySystemValueByType.get('Opt In Code');

            if (referenceDataByValue.containsKey(optInCode)) {
                optIn = referenceDataByValue.get(optInCode).Salesforce_Value__c;
            }
        }

        return optIn;
    }

    private static String getString(String stringValue) {
        String cleanStringValue;

        if (!String.isBlank(stringValue)) {
            cleanStringValue = stringValue;
        }

        return cleanStringValue;
    }

    private static Long getLong(String stringValue) {
        Long longValue;

        if (stringValue != null && stringValue.isNumeric()) {
            longValue = Long.valueOf(stringValue);
        }

        return longValue;
    }

    private static Integer getInteger(String stringValue) {
        Integer integerValue;

        if (stringValue != null && stringValue.isNumeric()) {
            integerValue = Integer.valueOf(stringValue);
        }

        return integerValue;
    }

    private static Date getDate(String stringValue) {
        Date dateValue;

        if (stringValue != null) {
            try {
                dateValue = Date.valueOf(stringValue.left(10));
            } catch (Exception e) {

            }
        }

        return dateValue;
    }

    public static String getUniqueExternalId(Contact contact) {
        String uniqueExternalId;

        if (contact.Business_Unit__c != null && contact.UCID_Number__c != null) {
            uniqueExternalId = contact.Business_Unit__c + '-' + contact.UCID_Number__c;
        }

        return uniqueExternalId;
    }

    public static String getCommerceCloudId(trac_WS_GetCustomerDetails.res_customerRecordWrapper customerRecordWrapper) {
        String commerceCloudId;

        if (customerRecordWrapper != null && customerRecordWrapper.externalId != null) {
            for (trac_WS_GetCustomerDetails.res_externalIdWrapper externalIdWrapper : customerRecordWrapper.externalId) {
                if (externalIdWrapper.extTypeCode == EXTERNAL_ID_SFCC_ID) {
                    commerceCloudId = externalIdWrapper.extTypeValue;
                }
            }
        }

        return commerceCloudId;
    }

    public static String getCommerceCloudCustomerNumber(trac_WS_GetCustomerDetails.res_customerRecordWrapper customerRecordWrapper) {
        String commerceCloudId;

        if (customerRecordWrapper != null && customerRecordWrapper.externalId != null) {
            for (trac_WS_GetCustomerDetails.res_externalIdWrapper externalIdWrapper : customerRecordWrapper.externalId) {
                if (externalIdWrapper.extTypeCode == EXTERNAL_ID_SFCC_CUSTOMER_NUMBER) {
                    commerceCloudId = externalIdWrapper.extTypeValue;
                }
            }
        }

        return commerceCloudId;
    }

    public static String getLoyaltyId(trac_WS_GetCustomerDetails.res_customerRecordWrapper customerRecordWrapper) {
        String loyaltyId;

        if (customerRecordWrapper != null && customerRecordWrapper.externalId != null) {
            for (trac_WS_GetCustomerDetails.res_externalIdWrapper externalIdWrapper : customerRecordWrapper.externalId) {
                if (externalIdWrapper.extTypeCode == EXTERNAL_ID_LOYALTY) {
                    loyaltyId = externalIdWrapper.extTypeValue;
                }
            }
        }

        return loyaltyId;
    }

    public static String clearCountryCode(String phoneNumber) {
        String phoneString = phoneNumber;

        if (phoneNumber != null && phoneNumber.startsWith('+1')) {
            phoneString = phoneNumber.removeStart('+1');
        }

        return phoneString;
    }

    public static Boolean excludeFromProcesses(Contact contact) {
        Boolean exclude = false;

        if (contact.Phone != null && (contact.Phone.contains('0000000000') || String.isBlank(contact.Phone) || contact.Phone == 'Unknown')) {
            exclude = true;
        }

        return exclude;
    }

    public static Contact getContactWithFields(Id contactId) {
        List<Contact> contacts = [
                SELECT Id, FirstName, LastName, MiddleName, Salutation, Email, Phone, Birthdate, Language__c, UCID_Number__c,
                        MailingStreet, MailingCity, MailingPostalCode, MailingStateCode, MailingCountryCode, Business_Unit__c,
                        Phone_Marketing__c, Email_Marketing__c, Mail_Marketing__c, Unique_External_Id__c, SFCC_Customer_Id__c
                FROM Contact
                WHERE Id = :contactId
        ];
        return (!contacts.isEmpty()) ? contacts[0] : null;
    }


}