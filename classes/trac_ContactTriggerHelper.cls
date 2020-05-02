/**
 * @description Helper for trac_ContactTrigger
 * @author      Rajat Agrawal, Traction on Demand
 * @date        2019-06-04
 */
public without sharing class trac_ContactTriggerHelper {

    /**
     * @description search Salesforce for a matching Account, if found, the Contact will be linked to the Account,
     *              otherwise an Account will be created
     * @param       newList, List of new Contact records being inserted
     * @param       oldMap, Trigger.oldMap of Contact
     * @return      void
     */
    public static void checkAccount(List<Contact> newList, Map<Id, Contact> oldMap) {

        Map<Id, Contact> contactMap = new Map<Id, Contact>();
        Set<String> ucIds = new Set<String>();
        Set<String> phones = new Set<String>();
        Set<String> emails = new Set<String>();

        for (Contact con : newList) {
            if (con.RecordTypeId == trac_CaseConstants.RECORD_TYPE_ID_CUSTOMER_CONTACT &&
                    (oldMap == null || oldMap.get(con.Id).UCID_Number__c != con.UCID_Number__c ||
                    oldMap.get(con.Id).Email != con.Email || oldMap.get(con.Id).Phone != con.Phone))
            {
                contactMap.put(con.Id, con);
                if (con.UCID_Number__c != null) {
                    ucIds.add(con.UCID_Number__c);
                }
                if (con.Email != null) {
                    emails.add(con.Email);
                }
                if (con.Phone != null) {
                    phones.add(con.Phone);
                }
            }
        }

        if (contactMap.isEmpty()) return ;

        List<Contact> updateContacts = new List<Contact>();

        for (Account acc : [
                SELECT Id, UCID_Number__c, Email__c, Phone
                FROM Account
                WHERE UCID_Number__c IN:ucIds OR Email__c IN:emails OR Phone IN:phones
        ]) {
            for (Contact con : contactMap.values()) {
                if (con.UCID_Number__c == acc.UCID_Number__c) {
                    updateContacts.add(new Contact(Id = con.Id, AccountId = acc.Id));
                    contactMap.remove(con.Id);
                } else if (con.Email == acc.Email__c) {
                    updateContacts.add(new Contact(Id = con.Id, AccountId = acc.Id));
                    contactMap.remove(con.Id);
                } else if (con.Phone == acc.Phone) {
                    updateContacts.add(new Contact(Id = con.Id, AccountId = acc.Id));
                    contactMap.remove(con.Id);
                }
            }
        }

        if (contactMap.isEmpty()) {
            update updateContacts;
            return ;
        }

        Map<Id, Account> mapContactToAccount = new Map<Id, Account>();

        for (Contact con : contactMap.values()) {
            mapContactToAccount.put(con.Id, createAccount(con));
        }
        insert mapContactToAccount.values();

        for (Id conId : mapContactToAccount.keySet()) {
            updateContacts.add(new Contact(Id = conId, AccountId = mapContactToAccount.get(conId).Id));
        }
        update updateContacts;
    }

    /**
     * @description Returns a new Account created from the specified Contact record values
     * @param       con, Contact record for which the Account is to be created
     * @return      Account, the new Account record to be inserted
     */
    private static Account createAccount(Contact con) {
        Account account = new Account();

        account.UCID_Number__c = con.UCID_Number__c;
        account.Email__c = con.Email;
        account.Phone = con.Phone;
        account.BillingStreet = con.MailingStreet;
        account.BillingCity = con.MailingCity;
        account.BillingPostalCode = con.MailingPostalCode;
        account.BillingStateCode = con.MailingStateCode;
        account.BillingCountryCode = con.MailingCountryCode;
        account.ShippingStreet = con.MailingStreet;
        account.ShippingCity = con.MailingCity;
        account.ShippingPostalCode = con.MailingPostalCode;
        account.ShippingStateCode = con.MailingStateCode;
        account.ShippingCountryCode = con.MailingCountryCode;

        if (con.FirstName != null) {
            account.Name = con.FirstName + ' ' + con.LastName;
        }
        else {
            account.Name = con.LastName;
        }

        return account;
    }

    public static void copyBillingAddress(List<Contact> contacts) {
        for (Contact contact : contacts) {
            if (contact.OtherStreet == null) {
                contact.OtherStreet = contact.MailingStreet;
            }
            if (contact.OtherCity == null) {
                contact.OtherCity = contact.MailingCity;
            }
            if (contact.OtherPostalCode == null) {
                contact.OtherPostalCode = contact.MailingPostalCode;
            }
            if (contact.OtherCountryCode == null) {
                contact.OtherCountryCode = contact.MailingCountryCode;
            }
            if (contact.OtherStateCode == null && contact.OtherCountryCode != null && contact.OtherCountryCode.equals(contact.MailingCountryCode)) {
                contact.OtherStateCode = contact.MailingStateCode;
            }
            if (contact.Mailing_First_Name__c == null) {
                contact.Mailing_First_Name__c = contact.FirstName;
            }
            if (contact.Mailing_Last_Name__c == null) {
                contact.Mailing_Last_Name__c = contact.LastName;
            }
            if (contact.Mailing_Email__c == null) {
                contact.Mailing_Email__c = contact.Email;
            }
            if (contact.Mailing_Phone__c == null) {
                contact.Mailing_Phone__c = contact.Phone;
            }
        }
    }

    /**
     * @description
     * @param       newList, List of new Contact records being inserted
     * @param       oldMap, Trigger.oldMap of Contact
     * @return      void
     */
    public static void mergeWithUCID(List<Contact> newList, Map<Id, Contact> oldMap) {

        if (newList.size() == 1) {
            Contact con = newList[0];

            if (contactShouldBeProcessed(con) && !TLTrigger.wasRecordProcessed(con.Id, 'mergeWithUCID')) {
                //Filter list when a UCID field is updated
                List<String> fieldsList = new List<String>{
                        'Salutation', 'FirstName', 'LastName', 'MailingStreet', 'MailingCity', 'MailingPostalCode', 'MailingStateCode', 'MailingCountryCode',
                        'Business_Unit__c', 'Language__c', 'Birthdate', 'Email', 'Phone', 'Phone_Marketing__c', 'Email_Marketing__c', 'Mail_Marketing__c'
                };
                List<Contact> conList = (List<Contact>) TLTrigger.filterByFieldsChanged(newList, oldMap, fieldsList);

                if (conList == null || conList.isEmpty()) return ;

                TLTrigger.addRecordProcess(con.Id, 'mergeWithUCID');

                if (con.UCID_Number__c == null) {
                    mergeContact(con.Id, true);
                } else {
                    mergeContact(con.Id, false);
                }
            }
        }
    }

    private static Boolean contactShouldBeProcessed(Contact contact) {
        Boolean shouldBeProcessed = true;

        if (contact.RecordTypeId != trac_CaseConstants.RECORD_TYPE_ID_CUSTOMER_CONTACT || contact.Business_Unit__c == null) {
            shouldBeProcessed = false;
        }

        if (trac_WS_CustomerUtils.excludeFromProcesses(contact)) {
            shouldBeProcessed = false;
        }

        return shouldBeProcessed;
    }

    public static void mergeContact(Id conId, Boolean mergeCon) {
        if (System.isBatch() || System.isFuture()) {
            //mergeContactSync(conId, mergeCon);//TODO: move to queueable to allow chaining
        } else {
            mergeContactAsync(conId, mergeCon);
        }
    }

    @Future(callout=true)//TODO: move to queueable to allow chaining
    public static void mergeContactAsync(Id conId, Boolean mergeCon) {
        mergeContactSync(conId, mergeCon);
    }

    public static void mergeContactSync(Id conId, Boolean mergeCon) {
        if (mergeCon) {
            trac_WS_CustomerUtils.syncContactFromExternal(conId);
        } else {
            trac_WS_CustomerUtils.updateContact(conId);
        }
    }

    public static void mergeOnUniqueExternalId(List<Contact> contacts, Map<Id, Contact> oldContactsByIds) {
        Map<String, Contact> contactsByExternalIds = new Map<String, Contact>();

        for (Contact contact : contacts) {

            Contact oldContact;

            if (oldContactsByIds.containsKey(contact.Id)) {
                oldContact = oldContactsByIds.get(contact.Id);
            }

            if (contact.Unique_External_Id__c != null && (oldContact == null || (contact.Unique_External_Id__c != oldContact.Unique_External_Id__c))) {
                contactsByExternalIds.put(contact.Unique_External_Id__c, contact);
            }
        }

        if (!contactsByExternalIds.isEmpty()) {
            List<Contact> matchingContacts = getContactsByUniqueExternalIds(contactsByExternalIds.keySet());

            Map<String, List<Contact>> matchingContactsByExternalIds = new Map<String, List<Contact>>();
            TLMap.addToMap(matchingContactsByExternalIds, matchingContacts, 'Unique_External_Id__c');

            for (Contact contact : contactsByExternalIds.values()) {
                List<Contact> matchingContactsToMerge = new List<Contact>();
                Contact masterContact;
                if (matchingContactsByExternalIds.containsKey(contact.Unique_External_Id__c)) {
                    for (Contact matchingContact : matchingContactsByExternalIds.get(contact.Unique_External_Id__c)) {
                        if (matchingContact.Id != contact.Id) {
                            matchingContactsToMerge.add(matchingContact);
                            masterContact = populateEmptyContactFields(contact, matchingContact);
                            masterContact.Id = contact.Id;
                        }
                    }
                }

                if (!matchingContactsToMerge.isEmpty() && masterContact != null) {
                    try {
                        while (matchingContactsToMerge.size() > 2) {
                            matchingContactsToMerge.remove(matchingContactsToMerge.size() -1);
                        }
                        List<Database.MergeResult> mergeResults = Database.merge(masterContact, matchingContactsToMerge);
                    } catch (Exception e) {
                        System.debug(e.getMessage() + '\n' + e.getStackTraceString());
                    }
                }
            }
        }
    }

    private static Contact populateEmptyContactFields(Contact contactToPopulate, Contact duplicateContact) {
        Contact contact = new Contact();

        if (contactToPopulate.FirstName == null && duplicateContact.FirstName != null) {
            contact.FirstName = duplicateContact.FirstName;
        }
        if (contactToPopulate.LastName == null && duplicateContact.LastName != null) {
            contact.LastName = duplicateContact.LastName;
        }
        if (contactToPopulate.Salutation == null && duplicateContact.Salutation != null) {
            contact.Salutation = duplicateContact.Salutation;
        }
        if (contactToPopulate.Email == null && duplicateContact.Email != null) {
            contact.Email = duplicateContact.Email;
        }
        if (contactToPopulate.Phone == null && duplicateContact.Phone != null) {
            contact.Phone = duplicateContact.Phone;
        }
        if (contactToPopulate.Birthdate == null && duplicateContact.Birthdate != null) {
            contact.Birthdate = duplicateContact.Birthdate;
        }
        if (contactToPopulate.Language__c == null && duplicateContact.Language__c != null) {
            contact.Language__c = duplicateContact.Language__c;
        }
        if (contactToPopulate.MailingStreet == null && duplicateContact.MailingStreet != null) {
            contact.MailingStreet = duplicateContact.MailingStreet;
        }
        if (contactToPopulate.MailingCity == null && duplicateContact.MailingCity != null) {
            contact.MailingCity = duplicateContact.MailingCity;
        }
        if (contactToPopulate.MailingPostalCode == null && duplicateContact.MailingPostalCode != null) {
            contact.MailingPostalCode = duplicateContact.MailingPostalCode;
        }
        if (contactToPopulate.MailingStateCode == null && duplicateContact.MailingStateCode != null) {
            contact.MailingStateCode = duplicateContact.MailingStateCode;
        }
        if (contactToPopulate.MailingCountryCode == null && duplicateContact.MailingCountryCode != null) {
            contact.MailingCountryCode = duplicateContact.MailingCountryCode;
        }
        if (contactToPopulate.Business_Unit__c == null && duplicateContact.Business_Unit__c != null) {
            contact.Business_Unit__c = duplicateContact.Business_Unit__c;
        }
        if (contactToPopulate.Phone_Marketing__c == null && duplicateContact.Phone_Marketing__c != null) {
            contact.Phone_Marketing__c = duplicateContact.Phone_Marketing__c;
        }
        if (contactToPopulate.Email_Marketing__c == null && duplicateContact.Email_Marketing__c != null) {
            contact.Email_Marketing__c = duplicateContact.Email_Marketing__c;
        }
        if (contactToPopulate.Mail_Marketing__c == null && duplicateContact.Mail_Marketing__c != null) {
            contact.Mail_Marketing__c = duplicateContact.Mail_Marketing__c;
        }

        return contact;
    }

    private static List<Contact> getContactsByUniqueExternalIds(Set<String> externalIds) {
        List<Contact> contacts = [
                SELECT Id, Unique_External_Id__c, FirstName, LastName, Salutation, Email, Phone, Birthdate, Language__c,
                        MailingStreet, MailingCity, MailingPostalCode, MailingStateCode, MailingCountryCode, Business_Unit__c,
                        Phone_Marketing__c, Email_Marketing__c, Mail_Marketing__c
                FROM Contact
                WHERE Unique_External_Id__c IN :externalIds
                ORDER BY LastModifiedDate ASC
        ];
        return contacts;
    }

    public static void setUniqueExternalId(List<Contact> contacts) {
        for (Contact contact : contacts) {
            if (contact.Business_Unit__c != null && contact.UCID_Number__c != null) {
                contact.Unique_External_Id__c = trac_WS_CustomerUtils.getUniqueExternalId(contact);
            }
        }
    }

    public static void setBusinessUnit(List<Contact> contacts) {
        for (Contact contact : contacts) {
            if (contact.Business_Unit__c != null && contact.Business_Unit__c == trac_ContactConstants.BUSINESS_UNIT_MHF) {
                contact.Business_Unit__c = trac_ContactConstants.BUSINESS_UNIT_BAY;
            }
        }
    }

    public static void setClickToDial(List<Contact> contacts, Map<Id, Contact> oldContactsByIds) {
        for (Contact contact : contacts) {

            Contact oldContact;

            if (oldContactsByIds.containsKey(contact.Id)) {
                oldContact = oldContactsByIds.get(contact.Id);
            }

            if (contact.Business_Unit__c != null && contact.Phone != null && (oldContact == null || contact.Click_To_Dial__c == null || (contact.Phone != oldContact.Phone) || (contact.Business_Unit__c != oldContact.Business_Unit__c))) {
                contact.Click_To_Dial__c = trac_PhoneUtils.getPhoneWithPrefix(contact);
            }
        }
    }

    public static void clearCountryCode(List<Contact> contacts) {
        for (Contact contact : contacts) {

            if (contact.Phone != null && contact.Phone.startsWith('+1')) {
                contact.Phone = trac_WS_CustomerUtils.clearCountryCode(contact.Phone);
            }
        }
    }
}