/**
* @description Trigger for EmailMessage object
* @author      Piyush Bansal, Traction on Demand
* @date        2019-12-12
*/
trigger trac_EmailMessageTrigger on EmailMessage (after insert, before insert) {

    if(Trigger.isInsert) {
        if( Trigger.isAfter) {
            trac_EmailMessageTriggerHelper.emailsOnCase(Trigger.New);
        }
        if (Trigger.isBefore){
            trac_EmailMessageTriggerHelper.createNewCaseIfClosed(Trigger.new);
            trac_EmailMessageTriggerHelper.redirectSaksMailsToSteward(Trigger.new);
        }
    }
}