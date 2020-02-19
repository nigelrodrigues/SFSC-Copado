/**
 * @description Test class for CopyCaseButtonController
 * @author      Rajat Agrawal, Traction on Demand
 * @date        2019-06-06
 */
@isTest
private class CopyCaseButtonControllerTest {

    private static final Id caseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Support Case').getRecordTypeId();

    @isTest
    static void testCloneCase() {
        final TLTestFactory factory = new TLTestFactory();

        Account test_Account = (Account)factory.createSObject(new Account(), true);
        Contact test_Contact = (Contact)factory.createSObject(new Contact(), true);

        Case test_Case = (Case)factory.createSObject(new Case(
                ContactId = test_Contact.Id,
                AccountId = test_Account.Id,
                Type = 'Returns',
                RecordTypeId = caseRecTypeId
        ), true);

        Test.startTest();
        Id newCaseId = CopyCaseButtonController.cloneCase(test_Case);
        Test.stopTest();

        List<Case> cases = [SELECT Id, ParentId, Type FROM Case WHERE Id =: newCaseId];
        System.assertEquals(1, cases.size(), 'Case not copied successfully.');
        System.assertEquals(test_Case.Id, cases[0].ParentId, 'New Case fields not populated correctly.');
    }
}