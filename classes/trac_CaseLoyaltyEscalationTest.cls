/**
 * Created by nrodrigues on 6/15/2020.
 */

@IsTest
private class trac_CaseLoyaltyEscalationTest {

    @IsTest
    static void testAssignToOperationsTeam() {
        TLTestFactory factory = new TLTestFactory();
        Case testCase = (Case)factory.createSObject(new Case(
                                Type = 'Returns'
                        ), true);

        String fileName = 'Test File';
        String fileContents = 'Test File Contents';
        String fileType ='png';

        TLAuraResponse response = trac_CaseLoyaltyEscalation.createCaseAndAttachFile(testCase, fileName, fileContents, fileType, false, 'test issue');


        List<Attachment> attachmentList = [SELECT Id, ParentId FROM Attachment LIMIT 100];
        System.assertEquals(1, attachmentList.size());
        System.assertEquals(true, response.isSuccess);
        System.assertEquals(testCase.Id, attachmentList.get(0).ParentId);

    }

    @IsTest
    static void testAssignToEscalationsTeam() {
        TLTestFactory factory = new TLTestFactory();
        Case testCase = (Case)factory.createSObject(new Case(
                Type = 'Returns'
        ), true);

        String fileName = 'Test File';
        String fileContents = 'Test File Contents';
        String fileType ='png';

        TLAuraResponse response = trac_CaseLoyaltyEscalation.createCaseAndAttachFile(testCase, fileName, fileContents, fileType, true, null);


        // Retrieve cloned case
        Case newCase = [SELECT Id FROM Case WHERE Id!=:testCase.Id LIMIT 1];

        // Attachment should be created for new case
        List<Attachment> attachmentList = [SELECT Id, ParentId FROM Attachment LIMIT 100];
        System.assertEquals(1, attachmentList.size());
        System.assertEquals(true, response.isSuccess);
        System.assertEquals(newCase.Id, attachmentList.get(0).ParentId);

    }
}