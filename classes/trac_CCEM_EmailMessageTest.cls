/**
 *  @description Tests for trac_EmailMessage
 *  @author 	 Tanminder Rai, Traction on Demand.
 *  @date        5/19/2016
 */
@IsTest
private class trac_CCEM_EmailMessageTest {

    /**
     * Test that when a email message is sent to a closed case
     * a new case is a created and email message is re-parented
     */
    @IsTest static void test_closed_case() {

        Case testCase = trac_CCEM_TestUtils.createCases(1)[0];
        testCase.Status = 'Closed';
        insert testCase;

        List<EmailMessage> testMsg = trac_CCEM_TestUtils.createEmailMessages(1);
        testMsg[0].ParentId = testCase.Id;

        Test.startTest();
        insert testMsg;
        Test.stopTest();

        List<Case> resultCase = [SELECT Id FROM Case];
        List<EmailMessage> resultMsg= [SELECT Id, ParentId FROM EmailMessage WHERE Id =:testMsg[0].Id];

        System.assertEquals(2, resultCase.size(), 'A new case should be created.');
        System.assertNotEquals(testCase.Id, resultMsg[0].ParentId, 'The Email message should be re-parented to the new case');
    }

    /**
     *  @description Uses custom setting to specify a time that a case needs to be closed for before making a new one
     *  @author      Jeremy Horan, Traction on Demand.
     *  @date        4/30/2018
     */
    @IsTest static void test_closedCaseWithSetting() {

        Closed_Case_Email_Handler_Settings__c closedCaseEmailHandlerSettings = new Closed_Case_Email_Handler_Settings__c(
                Hours_Since_Closed_Internal__c = -10
        );
        insert closedCaseEmailHandlerSettings;

        Case testCase = trac_CCEM_TestUtils.createCases(1)[0];
        testCase.Status = 'Closed';
        insert testCase;

        List<EmailMessage> testMsg = trac_CCEM_TestUtils.createEmailMessages(1);
        testMsg[0].ParentId = testCase.Id;

        Test.startTest();
        insert testMsg;
        Test.stopTest();

        List<Case> resultCase = [SELECT Id,IsClosed FROM Case];
        List<EmailMessage> resultMsg= [SELECT Id, ParentId FROM EmailMessage WHERE Id =:testMsg[0].Id];

        System.assertEquals(2, resultCase.size(), 'A new case should be created.');
        System.assertNotEquals(testCase.Id, resultMsg[0].ParentId, 'The Email message should be re-parented to the new case');
    }

    /**
     *  @description Uses custom setting to specify a time that a case needs to be closed for before making a new one
     *               Shouldn't reparent if the case hasn't been closed long enough
     *  @author      Jeremy Horan, Traction on Demand.
     *  @date        4/30/2018
     */
    @IsTest static void test_closedCaseWithSettingNoReparent() {

        Closed_Case_Email_Handler_Settings__c closedCaseEmailHandlerSettings = new Closed_Case_Email_Handler_Settings__c(
                Hours_Since_Closed_Internal__c = 10,
                Hours_Since_Closed_External__c = 10
        );
        insert closedCaseEmailHandlerSettings;

        Case testCase = trac_CCEM_TestUtils.createCases(1)[0];
        testCase.Status = 'Closed';
        insert testCase;

        List<EmailMessage> testMsg = trac_CCEM_TestUtils.createEmailMessages(1);
        testMsg[0].ParentId = testCase.Id;

        Test.startTest();
        insert testMsg;
        Test.stopTest();

        List<Case> resultCase = [SELECT Id FROM Case];
        List<EmailMessage> resultMsg= [SELECT Id, ParentId FROM EmailMessage WHERE Id =:testMsg[0].Id];

        System.assertEquals(1, resultCase.size(), 'No new case should be created.');
        System.assertEquals(testCase.Id, resultMsg[0].ParentId, 'The Email message should not be re-parented to the new case');
    }

    /**
     * Test that when a email message is sent to a new case
     * no new case is created
     */
    @IsTest static void test_new_case() {

        Case testCase = trac_CCEM_TestUtils.createCases(1)[0];
        testCase.Status = 'New';
        insert testCase;

        List<EmailMessage> testMsg = trac_CCEM_TestUtils.createEmailMessages(1);
        testMsg[0].ParentId = testCase.Id;

        Test.startTest();
        insert testMsg;
        Test.stopTest();

        List<Case> resultCase = [SELECT Id FROM Case];
        List<EmailMessage> resultMsg= [SELECT Id, ParentId FROM EmailMessage WHERE Id =:testMsg[0].Id];

        System.assertEquals(1, resultCase.size(), 'A new case should not be created.');
        System.assertEquals(testCase.Id, resultMsg[0].ParentId, 'The Email message should have the same parent');
    }

}