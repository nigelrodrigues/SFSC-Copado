/**
 *  @description Trigger for LiveChatTranscript object
 *  @author      Jeremy Horan, Traction on Demand.
 *  @date        2/2/2020
 */
trigger trac_LiveChatTranscript on LiveChatTranscript (before insert, before update, after insert, after update) {
    try {
        if (Trigger.isBefore) {
            if (Trigger.isInsert) {
                System.debug('About to update case contact - on LiveChat Transcript insert');
                trac_LiveChatTranscriptHelper.setContactToCaseContact(Trigger.new, new Map<Id, LiveChatTranscript>());
                System.debug('Just updated case contact - on LiveChat Transcript insert');
            } else if (Trigger.isUpdate) {
                System.debug('About to update case contact - on LiveChat Transcript update');
                trac_LiveChatTranscriptHelper.setContactToCaseContact(Trigger.new, Trigger.oldMap);
                System.debug('Just updated case contact - on LiveChat Transcript update');
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