/**
* @name trac_CasePopControllerTest
* @author Daniel Labonte, Traction on Demand
* @date 2019-07-10
* @description unit tests for the trac_CasePopController class
*/

@IsTest
private class trac_CasePopControllerTest {
    
    public static final String PHONE_NUMBER = '3335550000';
    public static final String CALLED_NUMBER = '8885550000';
    public static final String PHONE_EXTENSION = '5560164';
    public static final String CALL_ID = '39447793';
    public static final String TIMESTAMP = String.valueOf(Datetime.now().getTime());
    public static final String CALL_UNIQUE_ID = 'VOICE.' + CALL_ID + '.' + TIMESTAMP + '.' + UserInfo.getUserId();
    public static final String BUSINESS_UNIT = 'MHF';
    
    @IsTest
    static void testCreateNewCase() {
        
        TLTestFactory factory = new TLTestFactory();
        
        ApexPages.currentPage().getParameters().put('jsonVarMap',createIVRString('OnWorkItemCreate','','inbound'));
        
        trac_CasePopController controller = new trac_CasePopController();
        controller.handleCtiEvent();
        
        System.assert(controller.recordId != null, 'No case record was created');
    }
    
    @IsTest
    static void testExistingCase() {
        
        TLTestFactory factory = new TLTestFactory();
        Case cs = (Case) factory.createSObject(new Case(CTI_Original_Call_ID__c = CALL_ID),true);
        
        ApexPages.currentPage().getParameters().put('jsonVarMap',createIVRString('OnWorkItemCreate','TRANSFER','inbound'));
        
        trac_CasePopController controller = new trac_CasePopController();
        controller.handleCtiEvent();
        
        Case updatedCase = [SELECT Id, Latest_Agent_Extension__c FROM Case WHERE Id = :cs.Id];
        System.assert(updatedCase.Latest_Agent_Extension__c == PHONE_EXTENSION, 'Case is not updated Successfully');
    }
    
    @IsTest
    static void testExistingCaseWithPhoneNumber() {
        
        TLTestFactory factory = new TLTestFactory();
        Case cs = (Case) factory.createSObject(new Case(SuppliedPhone = PHONE_NUMBER, Transferred_Number__c = CALLED_NUMBER),true);
        
        ApexPages.currentPage().getParameters().put('jsonVarMap',createIVRString('OnWorkItemCreate','TRANSFER','inbound'));
        
        trac_CasePopController controller = new trac_CasePopController();
        controller.handleCtiEvent();
        
        Case updatedCase = [SELECT Id, Latest_Agent_Extension__c FROM Case WHERE Id = :cs.Id];
        System.assert(updatedCase.Latest_Agent_Extension__c == PHONE_EXTENSION, 'Case is not updated Successfully');
        
    }
    
    @IsTest
    static void testAttachActivity() {
        TLTestFactory factory = new TLTestFactory();
        Case cs = (Case) factory.createSObject(new Case(CTI_Call_Unique_Id__c = CALL_UNIQUE_ID),true);
        
        Contact contact = (Contact) factory.createSObject(new Contact(),true);
        Task task = (Task) factory.createSObject(new Task(WhoId = contact.Id, Type = 'Call'),true);
        
        ApexPages.currentPage().getParameters().put('jsonVarMap',createIVRString('OnActivitySave','TRANSFER','inbound',task.Id));
        
        trac_CasePopController controller = new trac_CasePopController();
        controller.handleCtiEvent();
        
        Task updatedTask = [SELECT WhatId FROM Task WHERE Id = :task.Id];
        System.assert(updatedTask.WhatId == cs.Id, 'The call record did not get updated with the related case record');
    }
    
    
    static String createIVRString(String type, String callType, String direction) {
        return createIVRString(type,callType,direction,null);
    }
    
    static String createIVRString(String type, String callType, String direction, String activityId) {
        return '{"CnxType" : "ConnectsIntegrationEvent",' +
            '"eventType" : "'+ type +'",' +
            '"item": {' +
            '"AgentId" : "405",' +
            '"CallType" : "'+callType+'",' +
            '"Channel" : "VOICE",' +
            '"ConnectedTimeStamp" : "null",' +
            '"CorrelationData" : "",' +
            '"CreatedTimeStamp" : "'+TIMESTAMP+'",' +
            '"CrmData" : "",' +
            '"CrmId" : "",' +
            '"DNIS" : "'+PHONE_EXTENSION+'",' +
            '"Destination" : "'+PHONE_EXTENSION+'",' +
            '"DialedNumber" : "'+CALLED_NUMBER+'",' +
            '"Direction" : "'+direction+'",' +
            '"EndedTimeStamp" : "null",' +
            '"HoldTimeStamp" : "null",' +
            '"Id" : "'+CALL_ID+'",' +
            '"IsConsultCall" : "false",' +
            '"IsInternalCall" : "false",' +
            '"OutboundClassification" : "",' +
            '"PerVar1" : "12345",' +
            '"PerVar2" : "",' +
            '"PerVar3" : "MHF",' +
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
            '"Subject" : "Lord + Taylor",' +
            '"TimezoneOffset":240,' +
            '"UniqueId" : "VOICE.'+CALL_ID+'.'+TIMESTAMP+'.'+UserInfo.getUserId()+'",' +
            '"WrapedupTimeStamp" : "null"}' +
            (activityId != null ? ',"recordId" : "'+ activityId+'"' : '') +
            '}';
    }
   
    
    @isTest
    static void testTransferCase(){
        TLTestFactory factory = new TLTestFactory();
        Case cs = (Case) factory.createSObject(new Case(CTI_Call_Unique_Id__c = CALL_UNIQUE_ID + 'transfer'),true);
        
        Contact contact = (Contact) factory.createSObject(new Contact(),true);
        Event event = (Event) factory.createSObject(new Event(WhoId = contact.Id, Type = 'Call'),false);
        event.DurationInMinutes = 30;
        event.ActivityDateTime =  System.now();
        insert event;
        
        ApexPages.currentPage().getParameters().put('jsonVarMap',createIVRString('OnWorkItemCreate','CONSULT','outbound',event.Id));
        Map<String, Object> eventMap = (Map<String,Object>)JSON.deserializeUntyped(ApexPages.currentPage().getParameters().get('jsonVarMap'));
        trac_CasePopController controller = new trac_CasePopController();
        controller.currentCaseId = cs.Id;
        
        controller.handleCtiEvent();
        
        Case updatedCase = [SELECT Id, Transferred_Number__c, Call_Status__c, Latest_Agent_Extension__c, Transfer_Time__c FROM Case WHERE Id = :cs.Id];
        System.assert(updatedCase.Transferred_Number__c == CALLED_NUMBER, 'Case is not transferred Successfully');
        
    }
    
}