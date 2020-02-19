/**
 *  @description Tests for trac_LiveChatTranscriptHelper
 *  @author      Jeremy Horan, Traction on Demand.
 *  @date        2/2/2020
 */
@IsTest
private class trac_LiveChatTranscriptHelperTest {

    static final TLTestFactory factory = new TLTestFactory();

    @IsTest
    static void testSetContactToCaseContact() {

        Contact testContact = (Contact) factory.createSObject(new Contact(), true);
        Case testCase = (Case) factory.createSObject(new Case(ContactId = testContact.Id), true);

        LiveChatVisitor testLiveChatVisitor = (LiveChatVisitor) factory.createSObject(new LiveChatVisitor(), true);
        LiveChatTranscript testLiveChatTranscript = (LiveChatTranscript) factory.createSObject(new LiveChatTranscript(LiveChatVisitorId = testLiveChatVisitor.Id, CaseId = testCase.Id), true);

        LiveChatTranscript queriedLiveChatTranscript = [SELECT Id, ContactId FROM LiveChatTranscript WHERE Id = :testLiveChatTranscript.Id];

        System.assertEquals(testContact.Id, queriedLiveChatTranscript.ContactId, 'Transcript contact should match case contact');
    }

    @IsTest
    static void testSetContactToCaseContactUpdate() {

        Contact testContact = (Contact) factory.createSObject(new Contact(), true);
        Case testCase = (Case) factory.createSObject(new Case(ContactId = testContact.Id), true);

        LiveChatVisitor testLiveChatVisitor = (LiveChatVisitor) factory.createSObject(new LiveChatVisitor(), true);
        LiveChatTranscript testLiveChatTranscript = (LiveChatTranscript) factory.createSObject(new LiveChatTranscript(LiveChatVisitorId = testLiveChatVisitor.Id), true);

        testLiveChatTranscript.CaseId = testCase.Id;
        update testLiveChatTranscript;

        LiveChatTranscript queriedLiveChatTranscript = [SELECT Id, ContactId FROM LiveChatTranscript WHERE Id = :testLiveChatTranscript.Id];

        System.assertEquals(testContact.Id, queriedLiveChatTranscript.ContactId, 'Transcript contact should match case contact');
    }
}