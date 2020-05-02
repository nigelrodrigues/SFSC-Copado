/**
 * @author Nigel Rodrigues, Traction on Demand
 * @description Queueable batch class to call the trac_UpdateLoyaltyInfoOnContact class
 */

public with sharing class trac_UpdateContactQueueable implements Queueable, Database.AllowsCallouts{
    public List<Id> contactIds;

    public trac_UpdateContactQueueable(List<Id> contactIds) {
        this.contactIds = contactIds;
    }

    public void execute(QueueableContext context) {
        trac_UpdateLoyaltyInfoOnContact loyaltyInfo = new trac_UpdateLoyaltyInfoOnContact();
        loyaltyInfo.updateContacts(contactIds);
    }
}