/**
 *  @description Helper for trac_LiveChatTranscript trigger
 *  @author      Jeremy Horan, Traction on Demand.
 *  @date        2/2/2020
 */
public without sharing class trac_LiveChatTranscriptHelper {

    public static void setContactToCaseContact(List<LiveChatTranscript> newLiveChatTranscripts, Map<Id, LiveChatTranscript> oldLiveChatTranscriptsById) {

        Map<Id, List<LiveChatTranscript>> liveChatTranscriptsByCaseIds = new Map<Id, List<LiveChatTranscript>>();

        for (LiveChatTranscript liveChatTranscript : newLiveChatTranscripts) {

            LiveChatTranscript oldLiveChatTranscript;
            if (oldLiveChatTranscriptsById.containsKey(liveChatTranscript.Id)) {
                oldLiveChatTranscript = oldLiveChatTranscriptsById.get(liveChatTranscript.Id);
            }

            if (liveChatTranscript.CaseId != null && (oldLiveChatTranscript == null || oldLiveChatTranscript.CaseId != liveChatTranscript.CaseId)) {
                if (!liveChatTranscriptsByCaseIds.containsKey(liveChatTranscript.CaseId)) {
                    liveChatTranscriptsByCaseIds.put(liveChatTranscript.CaseId, new List<LiveChatTranscript>());
                }
                liveChatTranscriptsByCaseIds.get(liveChatTranscript.CaseId).add(liveChatTranscript);
            }
        }

        if (!liveChatTranscriptsByCaseIds.isEmpty()) {
            List<Case> cases = getCasesByIds(liveChatTranscriptsByCaseIds.keySet());
            for (Case aCase : cases) {
                List<LiveChatTranscript> liveChatTranscripts = liveChatTranscriptsByCaseIds.get(aCase.Id);
                for (LiveChatTranscript liveChatTranscript : liveChatTranscripts) {
                    if (liveChatTranscript.ContactId != aCase.ContactId) {
                        liveChatTranscript.ContactId = aCase.ContactId;
                    }
                }
            }
        }
    }

    private static List<Case> getCasesByIds (Set<Id> caseIds) {
        List<Case> cases = [
                SELECT Id, ContactId
                FROM Case
                WHERE Id IN :caseIds
        ];

        return cases;
    }
}