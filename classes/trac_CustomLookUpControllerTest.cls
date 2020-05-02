/**
 * Created by nrodrigues on 4/28/2020.
 */

@isTest
private with sharing class trac_CustomLookUpControllerTest {

    static final TLTestFactory factory = new TLTestFactory();

    @IsTest
    static void testForQueue() {
        Group newQueue = (Group) factory.createSObject(new Group(Name = 'Queue From Apex', Type = 'Queue'), true);
        QueueSobject queueSObject = (QueueSobject) factory.createSObject(new QueueSobject(QueueId = newQueue.Id, SobjectType = 'Case'), true);

        List<Group> testQueueList = trac_CustomLookUpController.fetchLookUpValues('Queue From Apex', 'Queue');
        System.assertEquals(1, testQueueList.size());
    }

    @isTest
    static void testForUser() {
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'][0];

        User testUser = (User) factory.createSObject(
                new User(
                        Alias = TLString.generateRandomString(6), Email = TLString.generateRandomEmail(),
                        EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                        LocaleSidKey = 'en_US', ProfileId = adminProfile.Id,
                        TimeZoneSidKey = 'America/Los_Angeles', Username = 'testUserBCaseProcessBatch@tractionondemand.com')
                , false);
        insert testUser;

        List<User> userList = trac_CustomLookUpController.fetchLookUpValues('Testing', 'User');
        System.assertEquals(1, userList.size());

    }
}