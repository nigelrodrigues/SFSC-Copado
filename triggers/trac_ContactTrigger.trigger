/**
 * @description Trigger for Contact object
 * @author      Rajat Agrawal, Traction on Demand
 * @date        2019-06-04
 */
trigger trac_ContactTrigger on Contact (before insert, before update, after insert, after update) {

    if (Trigger.isBefore && Trigger.isInsert) {
        trac_ContactTriggerHelper.copyBillingAddress(Trigger.new);
        trac_ContactTriggerHelper.setBusinessUnit(Trigger.new);
        trac_ContactTriggerHelper.clearCountryCode(Trigger.new);
        trac_ContactTriggerHelper.setClickToDial(Trigger.new, new Map<Id, Contact>());
        trac_ContactTriggerHelper.setUniqueExternalId(Trigger.new);
    }
    else if (Trigger.isBefore && Trigger.isUpdate) {
        trac_ContactTriggerHelper.copyBillingAddress(Trigger.new);
        trac_ContactTriggerHelper.setBusinessUnit(Trigger.new);
        trac_ContactTriggerHelper.clearCountryCode(Trigger.new);
        trac_ContactTriggerHelper.setClickToDial(Trigger.new, Trigger.oldMap);
        trac_ContactTriggerHelper.setUniqueExternalId(Trigger.new);
    }
    else if(Trigger.isAfter && Trigger.isInsert){
        trac_ContactTriggerHelper.mergeOnUniqueExternalId(Trigger.new, new Map<Id, Contact>());
        trac_ContactTriggerHelper.checkAccount(Trigger.new, Trigger.oldMap);
        if(Trigger.size == 1){
            trac_ContactTriggerHelper.mergeWithUCID(Trigger.new, Trigger.oldMap);
        }
    }
    else if (Trigger.isAfter && Trigger.isUpdate) {
        trac_ContactTriggerHelper.mergeOnUniqueExternalId(Trigger.new, Trigger.oldMap);
        trac_ContactTriggerHelper.checkAccount(Trigger.new, Trigger.oldMap);
        if(Trigger.size == 1){
            trac_ContactTriggerHelper.mergeWithUCID(Trigger.new, Trigger.oldMap);
        }
    }

}