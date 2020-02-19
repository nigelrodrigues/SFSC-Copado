/**
 *  @description Email Message Trigger
 *  @author 	 Jeremy Horan, Traction on Demand.
 *  @date        2016-12-23
 */
trigger trac_CCEM_EmailMessage on EmailMessage (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if (Trigger.isInsert && Trigger.isBefore){
        trac_CCEM_EmailMessage.createNewCaseIfClosed(Trigger.new);
    }
}