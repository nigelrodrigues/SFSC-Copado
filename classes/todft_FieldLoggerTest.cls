/**
 * @author Rishabh Garg, Traction on Demand 
 * @date 2019-01-04
 */
@isTest
private class todft_FieldLoggerTest {

    private static final Integer RECORDS_TO_CREATE = 1;

    @testSetup static void setupCustomSetting() {
        // Create common custom setting record for running trigger
        Field_Tracker_Settings__c settingRecord = new Field_Tracker_Settings__c();
        settingRecord.Trigger_Switch__c = true;
        settingRecord.SetupOwnerId = UserInfo.getOrganizationId();
        settingRecord.Time_Log_Owner__c = UserInfo.getUserId();
        insert settingRecord;
    }

    //inserting case records in bulk(50 records)
    private static Database.SaveResult[] createParentRecords(){
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get('Case');
        List<SObject> recordList = todft_TestDataFactory.createSObjects(targetType, RECORDS_TO_CREATE);
        List<Trigger_Record_Type__mdt> recordTypeName = [SELECT Record_Type_Name__c FROM Trigger_Record_Type__mdt WHERE Object_Name__c = 'Case' AND Enable__c = TRUE LIMIT 1];
        if (recordTypeName.size() > 0) {
            if (recordTypeName[0].Record_Type_Name__c != 'Master') { // RecordTypeId should be null if using the Master RT
                Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(recordTypeName[0].Record_Type_Name__c).getRecordTypeId();
                for (SObject lt : recordList) {
                    lt.put('RecordTypeId', recordTypeId);
                }
            }
        }
        Database.SaveResult[] updateResults = Database.insert(recordList, false);

        return updateResults;
    }

    //insert scenario where time log will be created when the parent record is created.
    @IsTest private static void createSObjectsRecordUtility(){
        Map<String, Set<String>> fieldMappingsByObject = new Map<String, Set<String>>();
        fieldMappingsByObject = todft_FieldLoggerUtils.fieldMappingsByObject;
        Test.startTest();
        Database.SaveResult[] updateResults = createParentRecords();
        Test.stopTest();
        List<Case_Time_Log__c> caseTimeLogRecords = [SELECT Id, Start_Time__c, End_Time__c, Owner_Type__c, Parent_Owner_User__c, Parent_Owner_User_New__c
        FROM Case_Time_Log__c WHERE End_Time__c = NULL];
        System.assertEquals(RECORDS_TO_CREATE, caseTimeLogRecords.size());

        for (Case_Time_Log__c caseTimeLog : caseTimeLogRecords) {
            System.assertNotEquals(null, caseTimeLog.Parent_Owner_User__c, 'The Parent_Owner_User__c should not be null in this scenario');
            System.assertEquals(null, caseTimeLog.Parent_Owner_User_New__c, 'The Parent_Owner_User_New__c should be null in this scenario');
        }

        List<Case_Time_Log__c> closedCaseTimeLogRecords = [SELECT Id, Start_Time__c, End_Time__c, Owner_Type__c
        FROM Case_Time_Log__c WHERE End_Time__c != NULL];
        System.assertEquals(0, closedCaseTimeLogRecords.size());
    }

    //update scenario where time log will be created/updated when parent record is created/updated via assignment rule
    @IsTest private static void createUpdateSObjectsRecordUtility(){
        Test.startTest();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get('Case');
        List<SObject> recordList = todft_TestDataFactory.createSObjects(targetType, RECORDS_TO_CREATE);
        Group testGroup = new Group(Name='test group', Type='Queue');
        insert testGroup;
        System.runAs(new User(Id=UserInfo.getUserId())){
            QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Case');
            insert testQueue;
            QueuesObject testQueueForTimeLog = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Case_Time_Log__c');
            insert testQueueForTimeLog;
            GroupMember member = new GroupMember();
            member.UserOrGroupId = UserInfo.getUserId();
            member.GroupId = testGroup.Id;
            insert member;
        }
        insert recordList;
        for(SObject record : recordList){
            record.put('OwnerId', testGroup.Id);
        }
        update recordList;
        Test.stopTest();
        List<Case_Time_Log__c> caseTimeLogRecords = [SELECT Id, Start_Time__c, End_Time__c, Owner_Type__c, Parent_Owner_User__c, Parent_Owner_User_New__c
        FROM Case_Time_Log__c WHERE End_Time__c = NULL];
        System.assertEquals(RECORDS_TO_CREATE, caseTimeLogRecords.size());

        for (Case_Time_Log__c caseTimeLog : caseTimeLogRecords) {
            System.assertEquals(null, caseTimeLog.Parent_Owner_User__c, 'The Parent_Owner_User__c should be null in this scenario');
            System.assertEquals(null, caseTimeLog.Parent_Owner_User_New__c, 'The Parent_Owner_User_New__c should be null in this scenario');
        }

        List<Case_Time_Log__c> closedCaseTimeLogRecords = [SELECT Id, Start_Time__c, End_Time__c, Owner_Type__c
        FROM Case_Time_Log__c WHERE End_Time__c != NULL];
        System.assertEquals(0, closedCaseTimeLogRecords.size());
        List<Case_Time_Log__c> queueCaseTimeLogRecords = [SELECT Id, Start_Time__c, End_Time__c, Owner_Type__c
        FROM Case_Time_Log__c WHERE End_Time__c = NULL AND Owner_Type__c = 'Queue'];
        System.assertEquals(RECORDS_TO_CREATE, queueCaseTimeLogRecords.size());
    }

    //update scenario where time log record is created & updated when parent record is updated
    @IsTest private static void updateCaseParentRecords(){
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];

        User usr = new User(Username='rgarg@mail.com',
                Email='rgarg@mail.com',
                Alias='rgarg',
                CommunityNickname='rgarg',
                TimeZoneSidKey='America/Los_Angeles',
                LocaleSidKey='en_US',
                EmailEncodingKey='ISO-8859-1',
                ProfileId=testProfile.Id,
                LanguageLocaleKey='en_US',
                FirstName='Rishabh',
                LastName='Garg');
        insert usr;
        System.runAs(usr){

            Database.SaveResult[] updateResults = createParentRecords();
            List<Case_Time_Log__c> caseTimeLogRecords = [SELECT Id, Start_Time__c, End_Time__c, Owner_Type__c
            FROM Case_Time_Log__c WHERE End_Time__c = NULL];
            System.assertEquals(RECORDS_TO_CREATE, caseTimeLogRecords.size());
            List<Case_Time_Log__c> closedCaseTimeLogRecords = [SELECT Id, Start_Time__c, End_Time__c, Owner_Type__c
            FROM Case_Time_Log__c WHERE End_Time__c != NULL];
            System.assertEquals(0, closedCaseTimeLogRecords.size());
            Test.startTest();
            List<SObject> parentRecordToUpdate = new List<SObject>();
            // Iterate through each returned result
            for(Integer i=0;i<updateResults.size();i++){
                if (updateResults.get(i).isSuccess()){
                    Id objectRecordId = updateResults.get(i).getId();
                    String sObjName = objectRecordId.getSObjectType().getDescribe().getName();
                    sObject sObj = Schema.getGlobalDescribe().get(sObjName).newSObject();
                    sObj.put('Id', updateResults.get(i).getId());
                    sObj.put('Status', 'Working');
                    sObj.put('OwnerId', usr.Id);
                    parentRecordToUpdate.add(sObj);
                }
            }
            todft_FieldLogger.isParentRecordCreated = false;
            Database.SaveResult[] updateParentRecords = Database.update(parentRecordToUpdate, false);
            Test.stopTest();
            closedCaseTimeLogRecords = [SELECT Id, Start_Time__c, End_Time__c, Owner_Type__c, Parent_Owner_User__c, Parent_Owner_User_New__c
                                        FROM Case_Time_Log__c WHERE End_Time__c != NULL];
            //System.assert(false,'closedCaseTimeLogRecords @@'+closedCaseTimeLogRecords);
            System.assertEquals(RECORDS_TO_CREATE, closedCaseTimeLogRecords.size());
            for (Case_Time_Log__c caseTimeLog : closedCaseTimeLogRecords) {
                System.assertNotEquals(null, caseTimeLog.Parent_Owner_User__c, 'The Parent_Owner_User__c should not be null in this scenario');
                System.assertNotEquals(null, caseTimeLog.Parent_Owner_User_New__c, 'The Parent_Owner_User_New__c should not be null in this scenario');
            }
        }
    }

    //Testing functionality of updating parent record using omni channel assignment
    //and tracking the changes by creating & updating time logs
    @IsTest private static void createAgentWorkRecords(){
        Database.SaveResult[] updateResults = createParentRecords();
        Test.startTest();
        List<SObject> parentRecordToUpdate = new List<SObject>();
        // Iterate through each returned result
        for(Integer i=0;i<updateResults.size();i++){
            if (updateResults.get(i).isSuccess()){
                Id objectRecordId = updateResults.get(i).getId();
                String sObjName = objectRecordId.getSObjectType().getDescribe().getName();
                sObject sObj = Schema.getGlobalDescribe().get(sObjName).newSObject();
                sObj.put('Id', updateResults.get(i).getId());
                Database.DMLOptions dmo = new Database.DMLOptions();
                dmo.assignmentRuleHeader.useDefaultRule= true;
                sObj.setOptions(dmo);
                parentRecordToUpdate.add(sObj);
            }
        }
        Database.SaveResult[] updateParentRecords = Database.update(parentRecordToUpdate, false);
        //Schema.SObjectType targetTypeAgentWork = Schema.getGlobalDescribe().get('AgentWork');
        List<SObject> workAgentList = new List<SObject>();

        try {
            // ELU: avoid creating the dependencies for installation and for runtime
            if(!UserInfo.isCurrentUserLicensed('ServiceChannel')){
                return;
            }
        } catch (Exception e) {
        }

        // ELU: avoid creating a dependency for omni channel object
        try {
            ServiceChannel serviceChannelRecord = [SELECT Id FROM ServiceChannel WHERE RelatedEntity = 'Case' LIMIT 1];

            for (Integer i = 0; i < updateParentRecords.size(); i++) {
                sObject sObj = Schema.getGlobalDescribe().get('AgentWork').newSObject();
                sObj.put('WorkItemId', updateParentRecords.get(i).getId());
                sObj.put('ServiceChannelId', serviceChannelRecord.Id);
                sObj.put('UserId', UserInfo.getUserId());
                sObj.put('ShouldSkipCapacityCheck', true);
                workAgentList.add(sObj);
            }
            todft_FieldLogger.isParentRecordCreated = false;
        }
        catch(Exception ex){

        }

        Database.SaveResult[] insertAgentWorkList = Database.insert(workAgentList, false);
        try {
            insert workAgentList;
            List<Case_Time_Log__c> queueCaseTimeLogRecords = [SELECT Id, Start_Time__c, End_Time__c, Owner_Type__c
            FROM Case_Time_Log__c WHERE End_Time__c != NULL AND Owner_Type__c = 'Queue'];
            System.assertEquals(RECORDS_TO_CREATE, queueCaseTimeLogRecords.size());
        }
        catch (DmlException e) {
            if (e.getMessage().contains('FIELD_INTEGRITY_EXCEPTION')) {
                //exception occurs if current user is not logged into Omni-Channel. exit test.
                return;
            }
        }
        Test.stopTest();
    }

    @IsTest private static void coverTriggerHandler(){
        todft_TriggerHandlerBase thb = new todft_TriggerHandlerBase();
        thb.handleAfterInsert();
        thb.handleAfterUpdate();
        todft_TriggerHandlerBase.triggerSwitch = false;
        todft_TriggerHandlerBase.triggerHandler(new todft_TriggerHandlerBase());
    }
}