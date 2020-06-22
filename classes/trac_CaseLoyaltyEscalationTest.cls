/**
 * Created by nrodrigues on 6/15/2020.
 */

@IsTest
private class trac_CaseLoyaltyEscalationTest {

    @IsTest
    static void testAttachToCase() {
        TLTestFactory factory = new TLTestFactory();
        Case testCase = (Case)factory.createSObject(new Case(
                                Type = 'Returns'
                        ), true);

        String fileName = 'Test File';
        String fileContents = 'Test File Contents';
        String fileType ='png';
        TLAuraResponse response = trac_CaseLoyaltyEscalation.attachToCase(testCase.Id, fileName, fileContents, fileType);

        List<Attachment> attachmentList = [SELECT Id, ParentId FROM Attachment LIMIT 100];
        System.assertEquals(1, attachmentList.size());
        System.assertEquals(true, response.isSuccess);
        System.assertEquals(testCase.Id, attachmentList.get(0).ParentId);

    }
}