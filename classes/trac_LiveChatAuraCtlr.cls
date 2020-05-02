/**
 * Created by Jeremy on 2/2/2020.
 */

public with sharing class trac_LiveChatAuraCtlr {

    @AuraEnabled
    public static TLAuraResponse getCaseId(String liveChatTranscriptId) {
        TLAuraResponse response = new TLAuraResponse(true);

        try {
            LiveChatTranscript liveChatTranscript = getLiveChatTranscriptById(liveChatTranscriptId);

            if (liveChatTranscript != null && liveChatTranscript.CaseId != null) {
                response.returnValuesMap.put('caseId', liveChatTranscript.CaseId);
            }

        } catch (Exception e) {
            response = new TLAuraResponse(false, e.getMessage() + '\n' + e.getStackTraceString());
        }

        return response;
    }

    private static LiveChatTranscript getLiveChatTranscriptById(String liveChatTranscriptId) {
        List<LiveChatTranscript> liveChatTranscripts = [
                SELECT Id, CaseId
                FROM LiveChatTranscript
                WHERE Id = :liveChatTranscriptId
        ];

        return (!liveChatTranscripts.isEmpty()) ? liveChatTranscripts[0] : null;
    }
}