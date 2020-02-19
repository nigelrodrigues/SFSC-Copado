/**
 * @name trac_CasePopControllerTest
 * @author Daniel Labonte, Traction on Demand
 * @date 2019-07-10
 * @description unit tests for the trac_CasePopController class
 */

@IsTest
private class trac_CasePopControllerTest {

    public static final String PHONE_NUMBER = '3335550000';
    public static final String CALLED_NUMBER = '1115550000';
    public static final String PHONE_EXTENSION = '5560164';
    public static final String CALL_ID = '39447793';
    public static final String TIMESTAMP = String.valueOf(Datetime.now().getTime());
    public static final String CALL_UNIQUE_ID = 'VOICE.' + CALL_ID + '.' + TIMESTAMP + '.' + UserInfo.getUserId();

    @IsTest
    static void testCreateNewCase() {
        ApexPages.currentPage().getParameters().put('jsonVarMap',createIVRString('OnWorkItemCreate'));

        trac_CasePopController controller = new trac_CasePopController();
        controller.handleCtiEvent();

        System.assert(controller.recordId != null, 'No case record was created');
    }

    @IsTest
    static void testAttachActivity() {
        TLTestFactory factory = new TLTestFactory();
        Case cs = (Case) factory.createSObject(new Case(CTI_Call_Unique_Id__c = CALL_UNIQUE_ID),true);

        Contact contact = (Contact) factory.createSObject(new Contact(),true);
        Task task = (Task) factory.createSObject(new Task(WhoId = contact.Id, Type = 'Call'),true);

        ApexPages.currentPage().getParameters().put('jsonVarMap',createIVRString('OnActivitySave',task.Id));

        trac_CasePopController controller = new trac_CasePopController();
        controller.handleCtiEvent();

        Task updatedTask = [SELECT WhatId FROM Task WHERE Id = :task.Id];
        System.assert(updatedTask.WhatId == cs.Id, 'The call record did not get updated with the related case record');
    }

    static String createIVRString(String type) {
        return createIVRString(type,null);
    }

    static String createIVRString(String type, String activityId) {
        return '{"CnxType" : "ConnectsIntegrationEvent",' +
                '"eventType" : "'+ type +'",' +
                '"item": {' +
                '"AgentId" : "405",' +
                '"CallType" : "PREROUTE_ACD_IN",' +
                '"Channel" : "VOICE",' +
                '"ConnectedTimeStamp" : "null",' +
                '"CorrelationData" : "",' +
                '"CreatedTimeStamp" : "'+TIMESTAMP+'",' +
                '"CrmData" : "",' +
                '"CrmId" : "",' +
                '"DNIS" : "'+PHONE_EXTENSION+'",' +
                '"Destination" : "'+PHONE_EXTENSION+'",' +
                '"DialedNumber" : "'+CALLED_NUMBER+'",' +
                '"Direction" : "inbound",' +
                '"EndedTimeStamp" : "null",' +
                '"HoldTimeStamp" : "null",' +
                '"Id" : "'+CALL_ID+'",' +
                '"IsConsultCall" : "false",' +
                '"IsInternalCall" : "false",' +
                '"OutboundClassification" : "",' +
                '"PerVar1" : "",' +
                '"PerVar2" : "",' +
                '"PerVar3" : "",' +
                '"PerVar4" : "",' +
                '"PerVar5" : "",' +
                '"PerVar6" : "",' +
                '"PerVar7" : "",' +
                '"PerVar8" : "",' +
                '"PerVar9" : "",' +
                '"PerVar10" : "",' +
                '"SelectedWrapupReason" : "",' +
                '"Sender" : "'+PHONE_NUMBER+'",' +
                '"Service" : "",' +
                '"State" : "OFFERED",' +
                '"Subject" : "",' +
                '"TimezoneOffset":240,' +
                '"UniqueId" : "VOICE.'+CALL_ID+'.'+TIMESTAMP+'.'+UserInfo.getUserId()+'",' +
                '"WrapedupTimeStamp" : "null"}' +
                (activityId != null ? ',"recordId" : "'+ activityId+'"' : '') +
                '}';
    }

}