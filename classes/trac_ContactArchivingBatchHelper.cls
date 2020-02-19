/**
 * @description Helper class for trac_ContactArchivingBatch class
 * @author      Rajat Agrawal, Traction on Demand
 * @date        2019-06-11
 */
public with sharing class trac_ContactArchivingBatchHelper {

    /**
     * @description delete contacts (and related cases and accounts)
     * @param       contacts, Contact records to be deleted
     * @return      void
     */
    public static void deleteContacts(List<Contact> contacts) {
        Set<Id> accIds = new Set<Id>();
        List<SObject> deleteRecords = new List<SObject>();

        for (Contact contact : contacts) {
            deleteRecords.addAll(contact.Cases);
            accIds.add(contact.AccountId);
        }

        delete deleteRecords;
        delete contacts;
        deleteRecords.clear();

        for (Account acc : [SELECT Id, (SELECT Id FROM Contacts) FROM Account WHERE Id IN: accIds]) {
            if(acc.Contacts.isEmpty()){
                deleteRecords.add(acc);
            }
        }

        delete deleteRecords;
    }

}