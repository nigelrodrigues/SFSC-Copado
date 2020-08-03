/**
 *  @description Trigger for LiveChatTranscript object
 *  @author      Jeremy Horan, Traction on Demand.
 *  @date        2/2/2020
 */
trigger trac_LiveChatTranscript on LiveChatTranscript (before insert, before update, after insert, after update) {
    try {
        if (Trigger.isBefore) {
            if (Trigger.isInsert) {
                trac_LiveChatTranscriptHelper.setContactToCaseContact(Trigger.new, new Map<Id, LiveChatTranscript>());
            } else if (Trigger.isUpdate) {
                trac_LiveChatTranscriptHelper.setContactToCaseContact(Trigger.new, Trigger.oldMap);
            }
        } else if (Trigger.isAfter) {
            if (Trigger.isInsert) {

            } else if (Trigger.isUpdate) {

            }
        }
    } catch (Exception e) {
        System.debug(e.getMessage() + '\n' + e.getStackTraceString());
    }
}