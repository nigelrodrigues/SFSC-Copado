/**
* @description Test class for trac_CaseTimeLogTrigger
* @author      Abhishek Solanki, Traction on Demand
* @date        2019-12-13
*/
@IsTest
public class trac_CaseTimeLogTriggerHelperTest {
    static final TLTestFactory factory = new TLTestFactory();
    
    @TestSetup
    static void setupTestData(){
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'][0];

        User supervisor = (User) factory.createSObject(new User(
            Username = TLString.generateRandomString(10) + '@supervisor.com',
            Email = 'test@username.com',
            ProfileId = adminProfile.Id,
            Lastname = 'Test',
            Alias = 'test123',
            TimeZoneSidKey = 'America/Chicago',
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_US'
        ), true);
        User caseOwner = (User) factory.createSObject(new User(
                Username = TLString.generateRandomString(10) + '@username.com',
                Email = 'owner@username.com',
                ProfileId = adminProfile.Id,
                Lastname = 'owner',
                Alias = 'owner123',
                ManagerId=supervisor.Id,
                Agent_Location__c = 'Cebu',
                TimeZoneSidKey = 'America/Chicago',
                LanguageLocaleKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                LocaleSidKey = 'en_US'
        ), true);
        factory.createSObject(new Case(
            Subject='Test Subject',
            Origin='Phone',
            Status='New',
            OwnerId=caseOwner.Id
        ), true);
    }
    
    @IsTest
    static void test_updateTeamLeadAndLocation() {
        Case_Time_Log__c newCaseTimeLog = (Case_Time_Log__c) factory.createSObject(new Case_Time_Log__c(),false);
        List<Case> caseList = new List<Case>([SELECT Id,Case_Owner_Supervisor_ID__c,Case_Owner_Location__c FROM Case WHERE Subject = 'Test Subject']);
        if(caseList!=null && !caseList.isEmpty()){
            newCaseTimeLog.Case__c = caseList[0].Id;
        }
        Test.startTest();
        Insert newCaseTimeLog;
        Test.stopTest();
        List<Case_Time_Log__c> ctlList = new List<Case_Time_Log__c>([SELECT Agent_Team_Lead__c,Agent_Location__c FROM Case_Time_Log__c WHERE Id =: newCaseTimeLog.Id]);
        System.assertEquals(caseList[0].Case_Owner_Supervisor_ID__c, ctlList[0].Agent_Team_Lead__c, 'Case Owner Supervisor succesfully mapped to Agent Team Lead of Case Time Log');
        System.assertEquals(caseList[0].Case_Owner_Location__c,  ctlList[0].Agent_Location__c, 'Case Owner Location succesfully mapped to Agent Location of Case Time Log');
    }
}