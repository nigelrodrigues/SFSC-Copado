/**
 * @description Trigger for Case Time Log object
 * @author      Abhishek Solanki, Traction on Demand
 * @date        2019-12-09
 */
trigger trac_CaseTimeLogTrigger on Case_Time_Log__c (before update, before insert) {
    try {
        if (Trigger.isBefore) {
            if (Trigger.isInsert) {
                trac_CaseTimeLogTriggerHelper.updateTeamLeadAndLocation(Trigger.new);
            } else if (Trigger.isUpdate) {
                trac_CaseTimeLogTriggerHelper.updateTeamLeadAndLocation(Trigger.new);
            }
        }
	} catch (Exception e) {
        System.debug(e.getMessage() + '\n' + e.getStackTraceString());
    }
}