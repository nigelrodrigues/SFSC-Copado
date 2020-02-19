/**
 * @description Test class for trac_CaseReassignmentBatchHelper
 * @author      Rajat Agrawal, Traction on Demand
 * @date        2019-06-10
 */
@isTest
private class trac_CaseReassignmentBatchHelperTest {

    static final TLTestFactory factory = new TLTestFactory();
    static final String QUEUE_BAY = 'The Bay - Main';

    @isTest
    static void testReassignCases() {
        List<QueueSobject> queueSobjects = new List<QueueSobject>();
        queueSobjects = [SELECT Id, Queue.Id FROM QueueSobject WHERE Queue.Name = :QUEUE_BAY LIMIT 1];
        System.assertEquals(1, queueSobjects.size(), 'Queue not found.');

        Id queueId = queueSobjects[0].Queue.Id;
        Date today = Date.today();
        Case testCase = (Case) factory.createSObject(new Case(Status = 'New', Previous_Queue_Owner_ID__c = queueId), true);

        Test.startTest();
        trac_CaseReassignmentBatch csb = new trac_CaseReassignmentBatch();
        Database.executeBatch(csb);
        Test.stopTest();

        testCase = [SELECT Id, OwnerId FROM Case WHERE Id = :testCase.Id].get(0);
        System.assertEquals(queueId, testCase.OwnerId, 'Owner not updated successfully.');
    }
}