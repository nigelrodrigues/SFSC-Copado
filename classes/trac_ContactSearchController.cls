/**
 * @description Apex controller for trac_ContactSearch lightning component
 * @author      Rajat Agrawal, Traction on Demand
 * @date        2019-06-017
 */
public without sharing class trac_ContactSearchController {

    /**
     * @description Get the contact records
     * @param
     * @return      list of contact records found
     */
    @AuraEnabled
    public static List<Contact> getContacts(Contact contact) {
        List<Contact> contacts = new List<Contact>();

        if (contact == null) {
            return contacts;
        }
        if (contact.Order_Number__c == null) {
            contacts.addAll(getSalesforceContacts(contact));
        }

        if (isUcidSearch(contact)) {
            trac_WS_GetCustomerDetails.GetCustomerDetailsResponse response = trac_WS_CustomerUtils.searchContact(contact);
            List<Contact> ucidContacts = new List<Contact>();
            if( response != null ) {
                ucidContacts = trac_WS_CustomerUtils.getContactsFromSearchResponse(response);

                for (Contact ucidContact : ucidContacts) {
                    ucidContact.System_Origin__c = trac_ContactConstants.ORIGIN_UCID;
                    ucidContact.Channel_Origin__c = 'Search';
                    ucidContact.Latest_System_Update__c = trac_ContactConstants.ORIGIN_UCID;
                    ucidContact.UCID_Update_Date__c = Datetime.now();
                }
            }
            contacts.addAll(ucidContacts);
        }

        if (contact.Order_Number__c != null && contact.Business_Unit__c != null) {
            Contact orderContact = trac_WS_CustomerUtils.getContactFromOrderByContact(contact);
            if (orderContact != null) {
                orderContact.System_Origin__c = trac_ContactConstants.ORIGIN_OMS;
                orderContact.Channel_Origin__c = 'Search';
                orderContact.Latest_System_Update__c = trac_ContactConstants.ORIGIN_OMS;
                contacts.add(orderContact);
            }
        }

        contacts = filterContactsByUcidNumber(contacts);
        contacts = sortContacts(contacts);


        return contacts;
    }

    @AuraEnabled
    public static Case getBusinessUnit(Id caseId) {
        List<Case> cases = new List<Case>();
        cases = [SELECT Id, Business_Unit__c, ContactId, Contact.Unique_External_Id__c FROM Case WHERE Id = :caseId];
        if (cases.isEmpty()) {
            return null;
        } else {
            return cases[0];
        }
    }


    @AuraEnabled
    public static Contact upsertContact(Contact con) {
        con.Is_UCID_Update__c = true;

        /*
         * Chris Shinnimin, Traction on Demand:
         * Add OwnerId and RecordType as per JF Oct. 10, 2019
         * (no Jira ticket, branch = temp/hotfix)
         */
        con.OwnerId = UserInfo.getUserId();
        con.RecordTypeId = trac_CaseConstants.RECORD_TYPE_ID_CUSTOMER_CONTACT;

        try {
            if (con.Id == null && con.UCID_Number__c != null && con.Business_Unit__c != null) {
                con.Unique_External_Id__c = trac_WS_CustomerUtils.getUniqueExternalId(con);
                Schema.SObjectField externalId = Contact.fields.Unique_External_Id__c;
                Database.upsert(con, externalId);
            } else {
                upsert con;
            }
            return con;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Id updateCase(Contact con, Id caseId) {
        Case aCase = getCaseById(caseId);
        if (caseId != null && con != null) {
            aCase.ContactId = con.Id;

            if (aCase.Business_Unit__c == null) {
                aCase.Business_Unit__c = con.Business_Unit__c;
            }

            try {
                update aCase;
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
        }

        return aCase.Id;
    }

    @AuraEnabled
    public static Id linkContactWithCase(Id contactId, Id caseId) {
        Contact contact = new Contact(Id = contactId);
        Case cs = new Case(
                Id = caseId,
                ContactId = contact.Id
        );

        try {
            update cs;
            return cs.Id;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static Boolean isUcidSearch(Contact contact) {
        Boolean isUcidSearch = false;

        if (!String.isBlank(contact.Email) || !String.isBlank(contact.Phone) || !String.isBlank(contact.FirstName) || !String.isBlank(contact.LastName)
                || !String.isBlank(contact.MailingCity) || !String.isBlank(contact.MailingStateCode) || !String.isBlank(contact.MailingPostalCode)) {
            isUcidSearch = true;
        }

        return isUcidSearch;
    }

    public static List<String> genericNumbers = new List<String>();
    private static List<Contact> getSalesforceContacts(Contact contact) {
        List<Contact> contacts = new List<Contact>();

        String queryString = buildQuery(contact);
        queryString = excludeGenericPhoneContacts(queryString);
        if (queryString != null) {
            contacts = Database.query(queryString);
        }

        return contacts;
    }

    /**
     * @description  Excluding all the contacts having Generic CTI Phone numbers on them from the query string
     * @param queryString query obtained by buildQuery method
     * @return String query returned upon filtering generic CTI numbers
     */
    private static String excludeGenericPhoneContacts(String queryString) {

        for (CTI_Generic_Number__mdt genericNumber : [SELECT Phone_Number__c FROM CTI_Generic_Number__mdt]) {
            genericNumbers.add(genericNumber.Phone_Number__c.replaceAll('[^0-9]',''));
        }
        if (!genericNumbers.isEmpty() && String.isNotBlank(queryString)) {
            if (queryString.containsIgnoreCase('WHERE')) {
                if (queryString.containsIgnoreCase('LIMIT')) {
                    queryString = queryString.substring(0, queryString.indexOf('LIMIT')) + ' AND Phone NOT IN: genericNumbers '+ ' ' + queryString.substring(queryString.indexOf('LIMIT'));
                } else {
                    queryString += ' AND Phone NOT IN: genericNumbers';
                }
            } else {
                if (queryString.containsIgnoreCase('LIMIT')) {
                    queryString = queryString.substring(0, queryString.indexOf('LIMIT')) + ' WHERE Phone NOT IN: genericNumbers '+ ' ' + queryString.substring(queryString.indexOf('LIMIT'));
                } else {
                    queryString += ' WHERE Phone NOT IN: genericNumbers';
                }
            }
        }
        return queryString;
    }

    public static String buildQuery(Contact con) {

        List<String> fieldsToQuery = new List<String>{
                'Id', 'FirstName', 'LastName', 'Email', 'Phone', 'Birthdate', 'MailingStreet', 'MailingCity', 'MailingState',
                'MailingStateCode', 'MailingPostalCode', 'MailingCountryCode', 'UCID_Number__c', 'Unique_External_Id__c', 'Business_Unit__c',
                'SFCC_Customer_Id__c'
        };

        List<String> fieldsToSearch = new List<String>{
                'FirstName', 'LastName', 'Email', 'Phone', 'MailingCity', 'MailingStateCode', 'MailingPostalCode', 'MailingState', 'Business_Unit__c'
        };

        TLQueryBuilder queryBuilder = new TLQueryBuilder();
        queryBuilder.setObject('Contact');
        queryBuilder.setFields(fieldsToQuery);
        queryBuilder.setLogicalOperator(TLQueryBuilder.AND_OPERATOR);
        queryBuilder.setLimit(50);

        Boolean isValidQuery = false;
        for (String field : fieldsToSearch) {
            if ((field == 'MailingStateCode' || field == 'MailingState') && con.MailingState != null && !String.isEmpty(con.MailingState)) {
                if (con.MailingState.length() == 2) {
                    queryBuilder.baseOperator.addCondition(new TLQueryBuilder.Condition('MailingStateCode', TLQueryBuilder.EQUALS_OPERATOR, getCleanString(con.MailingState)));
                } else {
                    queryBuilder.baseOperator.addCondition(new TLQueryBuilder.Condition('MailingState', TLQueryBuilder.EQUALS_OPERATOR, getCleanString(con.MailingState)));
                }
                isValidQuery = true;
            } else if (con.get(field) != null && !String.isEmpty(String.valueOf(con.get(field)))) {
                queryBuilder.baseOperator.addCondition(new TLQueryBuilder.Condition(field, TLQueryBuilder.EQUALS_OPERATOR, getCleanString(con.get(field))));
                isValidQuery = true;
            }

        }

        if (isValidQuery) {
            queryBuilder.baseOperator.addCondition(new TLQueryBuilder.Condition('LastName', TLQueryBuilder.NOT_EQUALS_OPERATOR, 'null', 'TypeBoolean'));
        }

        return (isValidQuery) ? queryBuilder.build() : null;
    }

    private static List<Contact> filterContactsByUcidNumber(List<Contact> contacts) {
        List<Contact> filteredContacts = new List<Contact>();

        Map<String, Contact> contactsByUcidNumber = new Map<String, Contact>();

        for (Contact contact : contacts) {
            if (contact.UCID_Number__c != null) {
                contactsByUcidNumber.put(contact.UCID_Number__c, contact);
            } else {
                filteredContacts.add(contact);
            }
        }

        if (!contactsByUcidNumber.isEmpty()) {
            filteredContacts.addAll(contactsByUcidNumber.values());
        }

        return filteredContacts;
    }

    private static String getCleanString(Object objectValue) {
        String stringValue;

        if (objectValue != null) {
            stringValue = String.escapeSingleQuotes(String.valueOf(objectValue));
        }

        return stringValue;
    }

    private static Case getCaseById(String caseId) {
        List<Case> cases = [
                SELECT Id, ContactId, Business_Unit__c
                FROM Case
                WHERE Id = :caseId
        ];
        return (!cases.isEmpty()) ? cases[0] : null;
    }

    private static List<Contact> sortContacts(List<Contact> contacts) {
        List<Contact> sortedContacts = new List<Contact>();

        Map<String, List<Contact_Search_Score_Setting__mdt>> contactSearchScoreSettingsByFieldApiName = getContactSearchScoreSettingsByFieldApiName();

        List<ContactWrapper> contactWrappers = new List<ContactWrapper>();
        for (Contact contact : contacts) {
            ContactWrapper contactWrapper = new ContactWrapper(contact, contactSearchScoreSettingsByFieldApiName);
            contactWrappers.add(contactWrapper);
        }

        contactWrappers.sort();

        for (ContactWrapper contactWrapper : contactWrappers) {
            sortedContacts.add(contactWrapper.contact);
        }

        return sortedContacts;
    }

    private static Map<String, List<Contact_Search_Score_Setting__mdt>> getContactSearchScoreSettingsByFieldApiName() {
        Map<String, List<Contact_Search_Score_Setting__mdt>> contactSearchScoreSettingsByFieldApiName = new Map<String, List<Contact_Search_Score_Setting__mdt>>();

        List<Contact_Search_Score_Setting__mdt> contactSearchScoreSettings = [
                SELECT Id, Field_API_Name__c, Field_Value__c, Is_Populated__c, Score__c
                FROM Contact_Search_Score_Setting__mdt
                WHERE Active__c = true
        ];

        for (Contact_Search_Score_Setting__mdt contactSearchScoreSetting : contactSearchScoreSettings) {
            if (!contactSearchScoreSettingsByFieldApiName.containsKey(contactSearchScoreSetting.Field_API_Name__c)) {
                contactSearchScoreSettingsByFieldApiName.put(contactSearchScoreSetting.Field_API_Name__c, new List<Contact_Search_Score_Setting__mdt>());
            }
            contactSearchScoreSettingsByFieldApiName.get(contactSearchScoreSetting.Field_API_Name__c).add(contactSearchScoreSetting);
        }

        return contactSearchScoreSettingsByFieldApiName;
    }

    public class ContactWrapper  implements Comparable {
        Contact contact;
        Decimal dataCompletionScore;

        public ContactWrapper(Contact contactToWrap, Map<String, List<Contact_Search_Score_Setting__mdt>> contactSearchScoreSettingsByFieldApiName) {
            contact = contactToWrap;

            setScore(contactSearchScoreSettingsByFieldApiName);
        }

        private void setScore(Map<String, List<Contact_Search_Score_Setting__mdt>> contactSearchScoreSettingsByFieldApiName) {
            dataCompletionScore = 0;

            for (String fieldApiName : contactSearchScoreSettingsByFieldApiName.keySet()) {
                if (contact.isSet(fieldApiName)) {


                    List<Contact_Search_Score_Setting__mdt> contactSearchScoreSettings = contactSearchScoreSettingsByFieldApiName.get(fieldApiName);

                    Decimal fieldScore = 0;
                    for (Contact_Search_Score_Setting__mdt contactSearchScoreSetting : contactSearchScoreSettings) {
                        if (contactSearchScoreSetting.Score__c != null) {
                            if ((contactSearchScoreSetting.Is_Populated__c && contact.get(fieldApiName) != null) || (contact.get(fieldApiName) != null && contactSearchScoreSetting.Field_Value__c == String.valueOf(contact.get(fieldApiName)))) {
                                fieldScore += contactSearchScoreSetting.Score__c;
                            }
                        }
                    }
                    dataCompletionScore += fieldScore;
                }
            }
        }

        public Integer compareTo(Object compareTo) {
            Integer hasLowerScore = 0;

            ContactWrapper contactToCompare = (ContactWrapper) compareTo;

            if (dataCompletionScore > contactToCompare.dataCompletionScore) {
                hasLowerScore = -1;
            } else if (dataCompletionScore < contactToCompare.dataCompletionScore) {
                hasLowerScore = 1;
            }

            return hasLowerScore;
        }
    }
}