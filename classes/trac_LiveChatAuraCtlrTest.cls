/**
 * Created by nrodrigues on 4/28/2020.
 */

@IsTest
private class trac_LiveChatAuraCtlrTest {
    @IsTest
    static void testGetCaseId() {

        Case newCase = new Case();
        insert newCase;

        LiveChatVisitor visitor = new LiveChatVisitor();
        insert visitor;

        LiveChatTranscript liveChatTranscript = new LiveChatTranscript(CaseId= newCase.Id, LiveChatVisitorId=visitor.Id);
        insert liveChatTranscript;

        TLAuraResponse response = new TLAuraResponse(true);

        Test.startTest();
        response = trac_LiveChatAuraCtlr.getCaseId(liveChatTranscript.Id);
        Test.stopTest();

        System.assertEquals(newCase.Id, response.returnValuesMap.get('caseId'));

    }
}