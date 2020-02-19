/**
 * @description Test class for trac_CaseTriggerHelper
 * @author      Rajat Agrawal, Traction on Demand
 * @date        2019-06-03
 */
@isTest
private class trac_CaseTriggerHelperTest {

    static final TLTestFactory factory = new TLTestFactory();

    @isTest
    static void testCheckContact() {
        Contact con = (Contact) factory.createSObject(new Contact(
                Phone = '1234567890',
                Email = 'con@test.com',
                Business_Unit__c = 'MHF',
            	MailingStreet = 'TestStreet',
            	MailingCity = 'TestCity',
            	MailingPostalCode = '123456',
            	MailingCountryCode = 'US',
            	MailingStateCode = 'CA'
        ), true);

        List<Case> cases = new List<Case>();

        cases.add((Case) factory.createSObject(new Case(
                SuppliedPhone = '1234567890',
                SuppliedEmail = 'con@test.com',
                Business_Unit__c = 'MHF'
        ), false));

        cases.add((Case) factory.createSObject(new Case(
                SuppliedName = 'First Last'
        ), false));
        
         cases.add((Case) factory.createSObject(new Case(
                SuppliedName = 'First,Last'
        ), false));

        cases.add((Case) factory.createSObject(new Case(
                SuppliedName = 'OnlyLast'
        ), false));
        
        cases.add((Case) factory.createSObject(new Case(
                SuppliedEmail = 'test@abc.com'
            
        ), false));

        Test.startTest();
        insert cases;
        Test.stopTest();

        for (Case aCase : [SELECT Id, ContactId FROM Case]) {
            System.assert(aCase.ContactId != null, 'Contact not created for case.');
        }
    }

    @isTest
    static void caseGiftCardQueueHandlerTest() {
        Case cse = (Case) factory.createSObject(new Case(Status = trac_CaseConstants.STATUS_NEW, Business_Unit__c =trac_CaseConstants.BUSINESS_UNIT_MHF), true);

        Order_Refund_Credit__c orderRefundCredit = (Order_Refund_Credit__c) factory.createSObject(new Order_Refund_Credit__c(
                Case__c = cse.Id,
                Amount_Charged__c = 50.00,
                Price_Override__c = 1.00,
                New_GC_Amount__c = 50
        ), true);
        Test.startTest();
        cse.Status = trac_CaseConstants.STATUS_POS_TEAM;
        update cse;
        Test.stopTest();

        List<Group> queueList = new List<Group>([SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName =: trac_CaseConstants.QUEUE_POS_MHF_GIFT_CARD]);
        List<Case> cases = new List<Case>([SELECT Id,OwnerId FROM Case WHERE Id =: cse.Id]);
        System.assertEquals(queueList[0].Id, cases[0].OwnerId , 'Case Owner updated to Gift Card Queue');
    }

    @isTest
    static void testUpdateLastCaseOnContact() {
        List<Case> cases = new List<Case>();

        Test.startTest();
        Case cs = (Case) factory.createSObject(new Case(SuppliedName = 'First Last'), true);
        Test.stopTest();

        List<Contact> contacts = new List<Contact>();
        contacts = [SELECT Id FROM Contact WHERE Last_Case__c =: cs.Id];
        System.assertEquals(1, contacts.size(), 'Last Case on Contact not updated.');
    }

    @isTest
    static void testUpdateParentCase() {
        Case parentCase = (Case) factory.createSObject(new Case(Order_Number__c = '12345678'), true);

        Test.startTest();
        Case childCase = (Case) factory.createSObject(new Case(Order_Number__c = '12345678'), true);
        Test.stopTest();

        childCase = [SELECT Id, ParentId FROM Case WHERE Id =: childCase.Id].get(0);
        System.assertEquals(parentCase.Id, childCase.ParentId, 'Parent not updated successfully.');
    }

    @IsTest
    static void testCaseStatusAutomation() {
        Case cs = (Case)factory.createSObject(
                new Case(
                    RecordTypeId=TLSObj.getRecordTypeIdForName(Case.SObjectType ,trac_CaseConstants.RECORD_TYPE_DEVNAME_SUPPORT_CASE),
                    Status=trac_CaseConstants.STATUS_NEW),
                true);

        String previousOwnerId = [SELECT OwnerId FROM Case WHERE Id = :cs.Id].OwnerId;
        
        Test.startTest();
        cs.Status = trac_CaseConstants.STATUS_PENDING_FRAUD_TEAM;
        update cs;
        Test.stopTest();

        Case updatedCase = [SELECT Id, OwnerId FROM Case WHERE Id = :cs.Id];
        System.assertNotEquals(previousOwnerId, updatedCase.OwnerId, 'The owner was not updated!');
    }

    @IsTest
    static void test_setOrderRefundCreditApproval() {
        Case parentCase = (Case) factory.createSObject(new Case(Status = trac_CaseConstants.STATUS_NEW), true);

        Order_Refund_Credit__c orderRefundCredit = (Order_Refund_Credit__c) factory.createSObject(new Order_Refund_Credit__c(
                Case__c = parentCase.Id,
                Amount_Charged__c = 20000.00,
                Price_Override__c = 1.00
        ), true);

        parentCase.Status = trac_CaseConstants.STATUS_AWAITING_SERVICE_EXCELLENCE_REVIEW;
        update parentCase;

        Order_Refund_Credit__c queriedOrderRefundCredit = [SELECT Id, ORC_Status__c FROM Order_Refund_Credit__c WHERE Id = :orderRefundCredit.Id];

        System.assertNotEquals(orderRefundCredit.ORC_Status__c, queriedOrderRefundCredit.ORC_Status__c, 'Status should\'ve been updated by Case status change');
    }

    @IsTest
    static void testSetTranscriptContact() {
        Contact testContact = (Contact) factory.createSObject(new Contact(), true);
        Case testCase = (Case) factory.createSObject(new Case(ContactId = testContact.Id), true);

        LiveChatVisitor testLiveChatVisitor = (LiveChatVisitor) factory.createSObject(new LiveChatVisitor(), true);
        LiveChatTranscript testLiveChatTranscript = (LiveChatTranscript) factory.createSObject(new LiveChatTranscript(LiveChatVisitorId = testLiveChatVisitor.Id, CaseId = testCase.Id), true);

        LiveChatTranscript queriedLiveChatTranscript = [SELECT Id, ContactId FROM LiveChatTranscript WHERE Id = :testLiveChatTranscript.Id];

        System.assertEquals(testContact.Id, queriedLiveChatTranscript.ContactId, 'Transcript contact should match case contact');
    }

    @IsTest
    static void testSetTranscriptContactUpdate() {
        Contact testContact = (Contact) factory.createSObject(new Contact(), true);
        Case testCase = (Case) factory.createSObject(new Case(), true);

        LiveChatVisitor testLiveChatVisitor = (LiveChatVisitor) factory.createSObject(new LiveChatVisitor(), true);
        LiveChatTranscript testLiveChatTranscript = (LiveChatTranscript) factory.createSObject(new LiveChatTranscript(LiveChatVisitorId = testLiveChatVisitor.Id, CaseId = testCase.Id), true);

        testCase.ContactId = testContact.Id;
        update testCase;

        LiveChatTranscript queriedLiveChatTranscript = [SELECT Id, ContactId FROM LiveChatTranscript WHERE Id = :testLiveChatTranscript.Id];

        System.assertEquals(testContact.Id, queriedLiveChatTranscript.ContactId, 'Transcript contact should match case contact');
    }
}