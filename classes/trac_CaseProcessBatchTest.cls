/**
* @Name trac_CaseProcessBatchTest
* @Author Piyush Bansal, Traction on Demand
* @Date January 1, 2019
*
* @Description Test class for trac_CaseProcessBatch
*/
@isTest
public class trac_CaseProcessBatchTest {
    static final TLTestFactory factory = new TLTestFactory();

    @TestSetup
    static void testSetup(){
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'][0];

        User testManager = (User) factory.createSObject(
                new User(
                        Alias = TLString.generateRandomString(6), Email = TLString.generateRandomEmail(),
                        EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                        LocaleSidKey = 'en_US', ProfileId = adminProfile.Id,
                        TimeZoneSidKey = 'America/Los_Angeles', Username = 'testUserBCaseProcessBatch@tractionondemand.com')
                , false);
        insert testManager;

        User testOwner = (User) factory.createSObject(
                new User(
                        Alias = TLString.generateRandomString(6), Email = TLString.generateRandomEmail(),
                        EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                        LocaleSidKey = 'en_US', ProfileId = adminProfile.Id,
                        TimeZoneSidKey = 'America/Los_Angeles', Username = 'testUserACaseProcessBatch@tractionondemand.com',
                        ManagerId = testManager.Id)
                , false);
        insert testOwner;

        //insert new List<User>{testManager, testOwner};

        Group newQueue = (Group) factory.createSObject(new Group(Name = 'Queue From Apex', Type = 'Queue'), true);
        QueueSobject queueSObject = (QueueSobject) factory.createSObject(new QueueSobject(QueueId = newQueue.Id, SobjectType = 'Case'), true);

        GroupMember groupMember = (GroupMember) factory.createSObject(
                new GroupMember(
                        GroupId = newQueue.Id,
                        UserOrGroupId = testManager.Id)
                , true);
        System.runAs(testOwner) {
            Case testCase = (Case) factory.createSObject(new Case(Subject = 'Name', Status = 'Follow Up', Follow_Up_Date__c = System.today() - 1) ,true );
            Case testCase2 = (Case) factory.createSObject(new Case(Subject = 'Test case 2', Status = 'New', Follow_Up_Date__c = System.today() - 1) ,true );

        }

    }

        @IsTest
    static void testMethod1() {


        User us = [SELECT Id FROM User WHERE Username = 'testUserACaseProcessBatch@tractionondemand.com'];

        Case testCase = [SELECT Id, Subject FROM Case WHERE Subject='Name' LIMIT 1];

        System.runAs(us){

            testCase.Subject = 'Test Case';
            update testCase;


            Test.loadData(Case.sObjectType, 'CaseTestRecords');

            Test.startTest();

            trac_CaseProcessBatch obj = new trac_CaseProcessBatch();
            Database.executeBatch(obj);

            Test.stopTest();
        }
    }

    @isTest
    static void testSchedulable()
    {
        Test.startTest();
        trac_CaseProcessBatch myClass = new trac_CaseProcessBatch ();
        String chron = '0 0 23 * * ?';
        system.schedule('Test Sched', chron, myClass);
        Test.stopTest();
    }

    @isTest
    static void testCloseCases()
    {
        List < sObject > ls = Test.loadData(Case.sObjectType, 'CaseTestRecords');
        trac_CaseProcessBatchHelper.closeNonResponsiveCases((List<Case>)ls);
    }
}