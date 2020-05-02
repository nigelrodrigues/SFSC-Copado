/**
 * @name trac_CasePopController
 * @author Daniel Labonte, Traction on Demand
 * @date 2019-07-10
 * @description apex controller for the trac_CasePop vf page that creates a new case record based on parameters from the CTI
 */

public without sharing class trac_CasePopController {
    public String recordId { get; set; } // record id of the newly created case
    public String currentCaseId { get; set; } // record id of the newly created case

    // all mappings from ivr paramaters to sobject fields (sames ivr param can updated multiple sobject type records)
    public List<CTI_Variable_Mapping__mdt> varMappings = [SELECT CTI_Parameter_Name__c, SObject__c, Field__c, Indirect_Mapping__c FROM CTI_Variable_Mapping__mdt];

    /**
     * constructor
     */
    public trac_CasePopController() {
    }

    /**
     * @description create a new case from the IVR parameters to be popped to the screen on call inbound connect
     * @return null
     */
    public PageReference handleCtiEvent() {
        recordId = null;

        Map<String, Object> event = (Map<String, Object>) JSON.deserializeUntyped(ApexPages.currentPage().getParameters().get('jsonVarMap'));
        Object eventType = event.get('eventType');

        if (eventType == 'OnWorkItemCreate') {
            findOrCreateCase(event.get('item'));
        } else if (eventType == 'OnActivitySave') {
            attachActivity(String.valueOf(event.get('recordId')), (Map<String, Object>) event.get('item'));
        }
        return null;
    }

    /**
     * @description creates a case based on the incoming call and ivr's mapped using custom metadata types
     * @param event json object from the cti event
     */
    public void findOrCreateCase(Object event) {
        String eventString = JSON.serialize(event);
        Map<String, Object> pageParams = (Map<String, Object>) JSON.deserializeUntyped(eventString);

        String callType = String.valueOf(pageParams.get('CallType'));
        String callDirection = String.valueOf(pageParams.get('Direction'));
        String phoneNumber = trac_WS_CustomerUtils.clearCountryCode(String.valueOf(pageParams.get('Sender')));
        String agentExtension = String.valueOf(pageParams.get('Destination'));

        if (existingCase(String.valueOf(pageParams.get('UniqueId'))) != null) {
            return;
        }

        Boolean wasTransferred = handleTransferLogic(pageParams, callType, callDirection, phoneNumber);

        if (!wasTransferred && callDirection == 'inbound' && callType != 'CONSULT') {
            createCase(pageParams, eventString, phoneNumber);
        }
    }

    private void createCase(Map<String, Object> pageParams, String eventString, String phoneNumber) {
        Case aCase = new Case(Origin = 'Phone', OwnerId = UserInfo.getUserId(), SuppliedPhone = phoneNumber);

        String agentExtension = String.valueOf(pageParams.get('Destination'));

        mapCaseFieldsFromIVR(aCase, pageParams);

        if (eventString != null) {
            aCase.IVR_Log__c = eventString.left(131072);
        }

        if (phoneNumber != null && aCase.Business_Unit__c != null) {
            try {
                if (!isGenericNumber(phoneNumber)) {
                    System.debug('phoneNumber: ' + phoneNumber);
                    System.debug('aCase.Business_Unit__c: ' + aCase.Business_Unit__c);
                    System.debug('aCase.Order_Number__c: ' + aCase.Order_Number__c);

                    Contact caseContact = getContactFromSearch(phoneNumber, aCase.Business_Unit__c, aCase.Order_Number__c);

                    System.debug('caseContact: ' + caseContact);

                    if (caseContact != null && caseContact.LastName != null) {
                        Contact fetchedContact = new Contact();
                        fetchedContact = searchContactByBUAndEmail(caseContact);
                        if(fetchedContact!=null){
                            aCase.ContactId = fetchedContact.Id;
                        }else{
                            upsert caseContact;
                            aCase.ContactId = caseContact.Id;
                        }
                    }
                }
            } catch (Exception e) {
                Integration_Error__c integrationError = trac_IntegrationError.addError(new Integration_Error__c(
                        Description__c = e.getMessage() + '\n' + e.getStackTraceString(),
                        Service__c = 'CTI'
                ));
                insert integrationError;
            }
        }

        String callId = String.valueOf(pageParams.get('Id'));

        if (callId != null) {
            aCase.CTI_Original_Call_ID__c = callId;
        }

        aCase.Call_Status__c = trac_CaseConstants.CALL_STATUS_ANSWERED;
        aCase.Latest_Agent_Extension__c = agentExtension;

        upsert aCase;
        this.recordId = aCase.Id;
        this.currentCaseId = aCase.Id;
    }


    public static Contact searchContactByBUAndEmail(Contact caseContact){
        List<Contact> conList = new List<Contact>();
        if(String.isNotBlank(caseContact.Business_Unit__c) && String.isNotBlank(caseContact.Email)){
            conList = [SELECT Id,Business_Unit__c,Email FROM Contact WHERE Business_Unit__c =: caseContact.Business_Unit__c AND Email =: caseContact.Email];
        }

        if(conList!=null && !conList.isEmpty()){
            return conList[0];
        }else{
            return null;
        }
    }

    private void mapCaseFieldsFromIVR(Case aCase, Map<String, Object> pageParams) {
        // Preload this map for using in the loop
        Map<String, SObjectType> globalDescribed = Schema.getGlobalDescribe();
        Set<Id> ctiVariableMappingIds = new Set<Id>();
        for (CTI_Variable_Mapping__mdt ctiVariableMapping : varMappings) {
            ctiVariableMappingIds.add(ctiVariableMapping.Id);
        }

        Map<Id, Map<String, CTI_Field_Value_Mapping__mdt>> fieldValueMapByValueByParentIds = getFieldValueMapByValueByParentIds(ctiVariableMappingIds);

        for (CTI_Variable_Mapping__mdt ctiVariableMapping : varMappings) {

            String sObjectName = ctiVariableMapping.SObject__c;
            String field = ctiVariableMapping.Field__c;
            String ctiValue = String.valueOf(pageParams.get(ctiVariableMapping.CTI_Parameter_Name__c));
            DescribeFieldResult fieldResult = globalDescribed.get(sObjectName).getDescribe().fields.getMap().get(field).getDescribe();

            if (fieldResult.getSoapType().name() != 'ID' && sObjectName == String.valueOf(aCase.getSObjectType())) {
                aCase.put(
                        field,
                        getChildFieldValue(ctiVariableMapping, ctiValue, fieldValueMapByValueByParentIds)
                );
            }
        }

        if (aCase.Order_Number__c == '0000000000' || aCase.Order_Number__c == 'Order Not Found') {
            aCase.Order_Number__c = null;
        }

        if (aCase.Business_Unit__c == null && aCase.Subject != null && aCase.Subject.startsWith('Lord + Taylor')) {
            aCase.Business_Unit__c = 'Lord + Taylor';
        }

        if (aCase.Order_Number__c != null && aCase.Order_Number__c != '0000000000' && aCase.Order_Number__c != 'Order Not Found' && !String.isBlank(aCase.Order_Number__c)) {
            Case openOrderCase = findOpenCaseByOrderNumber(aCase.Order_Number__c);

            if (openOrderCase != null) {
                aCase.Id = openOrderCase.Id;
            }
        }
    }

    /**
     * @description  Need to find if the incoming number is among one of the pre-existing generic numbers fetched from CTI Generic Number metadata
     * @param phoneNumber the incoming number
     * @return boolean true if phone number is generic
     */
    public static Boolean isGenericNumber(String phoneNumber) {
        Boolean isGenericNumber = false;
        if (String.isNotBlank(phoneNumber)) {
            for (CTI_Generic_Number__mdt genericNumber : [SELECT Phone_Number__c FROM CTI_Generic_Number__mdt]) {
                if (String.isNotBlank(genericNumber.Phone_Number__c) && phoneNumber.equalsIgnoreCase(genericNumber.Phone_Number__c.replaceAll('[^0-9]', ''))) {
                    isGenericNumber = true;
                }
            }
        }
        return isGenericNumber;
    }

    public static Contact getContactFromSearch(String phoneNumber, String businessUnit, String orderNumber) {
        Contact contact = new Contact(Phone = phoneNumber, Business_Unit__c = businessUnit, Order_Number__c = orderNumber);

        if (!trac_WS_CustomerUtils.excludeFromProcesses(contact)) {
            contact = trac_WS_CustomerUtils.getContactFromOrderByContact(contact);
            if (contact != null) {
                contact.System_Origin__c = trac_ContactConstants.ORIGIN_OMS;
                contact.Channel_Origin__c = trac_ContactConstants.CHANNEL_PHONE;
                contact.Latest_System_Update__c = trac_ContactConstants.ORIGIN_UCID;
                contact.OMS_Update_Date__c = Datetime.now();
            }
        }

        contact.OwnerId = UserInfo.getUserId();
        contact.RecordTypeId = trac_CaseConstants.RECORD_TYPE_ID_CUSTOMER_CONTACT;

        return contact;
    }

    /**
     * @description when an ivr's value isn't to be stamped on a record field, but rather it determines a preset value, this uses custom metadata to get the actual value to set
     * @param parent the parent mapping metadata definition
     * @param parentVarValue the value of the ivr sent in from the cti event
     * @return string of the value to set the sobject field
     */
    public String getChildFieldValue(CTI_Variable_Mapping__mdt parent, String parentVarValue, Map<Id, Map<String, CTI_Field_Value_Mapping__mdt>> fieldValueMapByValueByParentIds) {
        String fieldValue;

        if (!parent.Indirect_Mapping__c) {
            fieldValue = parentVarValue;
        } else {
            CTI_Field_Value_Mapping__mdt fieldValueMapping;
            if (fieldValueMapByValueByParentIds != null && fieldValueMapByValueByParentIds.containsKey(parent.Id) && fieldValueMapByValueByParentIds.get(parent.Id).containsKey(parentVarValue)) {
                fieldValueMapping = fieldValueMapByValueByParentIds.get(parent.Id).get(parentVarValue);

                if (fieldValueMapping.Field_Value__c != null) {
                    fieldValue = fieldValueMapping.Field_Value__c;
                }
            }
        }

        return fieldValue;
    }

    public static Map<Id, Map<String, CTI_Field_Value_Mapping__mdt>> getFieldValueMapByValueByParentIds(Set<Id> parentIds) {
        Map<Id, Map<String, CTI_Field_Value_Mapping__mdt>> fieldValueMapByValueByParentIds = new Map<Id, Map<String, CTI_Field_Value_Mapping__mdt>>();

        List<CTI_Field_Value_Mapping__mdt> fieldValueMappings = [
                SELECT Field_Value__c, Parent_Mapping__c, CTI_Value__c
                FROM CTI_Field_Value_Mapping__mdt
                WHERE Parent_Mapping__c IN :parentIds AND CTI_Value__c != null
        ];

        for (CTI_Field_Value_Mapping__mdt fieldValueMapping : fieldValueMappings) {
            if (!fieldValueMapByValueByParentIds.containsKey(fieldValueMapping.Parent_Mapping__c)) {
                fieldValueMapByValueByParentIds.put(fieldValueMapping.Parent_Mapping__c, new Map<String, CTI_Field_Value_Mapping__mdt>());
            }
            fieldValueMapByValueByParentIds.get(fieldValueMapping.Parent_Mapping__c).put(fieldValueMapping.CTI_Value__c, fieldValueMapping);
        }

        return fieldValueMapByValueByParentIds;
    }


    private Boolean handleTransferLogic(Map<String, Object> pageParams, String callType, String callDirection, String phoneNumber) {
        Boolean wasTransferred = false;

        String dialedNumber = String.valueOf(pageParams.get('DialedNumber'));
        String agentExtension = String.valueOf(pageParams.get('Destination'));

        if (callType == 'CONSULT' && callDirection == 'outbound') {
            transferCase(pageParams);
            wasTransferred = true;
        }
        else if (!wasTransferred && callType == 'TRANSFER') {
            String originalCallId = String.valueOf(pageParams.get('Id'));

            Case transferredCase = findTransferredCase(originalCallId);

            if (transferredCase != null) {
                updateCaseTransferInformation(transferredCase, agentExtension);
                wasTransferred = true;
            }
        }

        if (!wasTransferred && isTransfer(dialedNumber)) {
            Case transferredCase = findTransferredCase(phoneNumber, dialedNumber);

            if (transferredCase != null) {
                updateCaseTransferInformation(transferredCase, agentExtension);
                wasTransferred = true;
            }
        }

        return wasTransferred;
    }

    private Boolean isTransfer(String phoneNumber) {
        Boolean isTransfer = false;

        if (phoneNumber != null && phoneNumber.startsWith('888')) {
            return true;
        }

        return isTransfer;
    }

    public void transferCase(Map<String, Object> pageParams) {

        if (currentCaseId != null) {

            Case existingCase = new Case(Id = currentCaseId);

            String dialedNumber = String.valueOf(pageParams.get('DialedNumber'));
            String agentExtension = String.valueOf(pageParams.get('Sender'));

            existingCase.Call_Status__c = trac_CaseConstants.CALL_STATUS_TRANSFERRED;
            existingCase.Transferred_Number__c = dialedNumber;
            existingCase.Latest_Agent_Extension__c = agentExtension;
            existingCase.Transfer_Time__c = Datetime.now();

            update existingCase;
        }
    }

    private void updateCaseTransferInformation(Case transferredCase, String agentExtension) {
        transferredCase.Call_Status__c = trac_CaseConstants.CALL_STATUS_ANSWERED;
        transferredCase.Latest_Agent_Extension__c = agentExtension;

        update transferredCase;
        this.recordId = transferredCase.Id;
        this.currentCaseId = transferredCase.Id;
    }

    /**
     * @description check for existing cases based on the unique id generated by the cti
     * @param callUniqueId cti call identifier
     * @return boolean if a case already exists for the current call
     */
    public static Case existingCase(String callUniqueId) {
        try {
            return [SELECT Id FROM Case WHERE CTI_Call_Unique_Id__c = :callUniqueId AND CTI_Call_Unique_Id__c != NULL LIMIT 1];
        }
        catch (Exception e) {
            return null;
        }
    }

    public Case findTransferredCase(String originalCallId) {
        List<Case> cases = [
                SELECT Id
                FROM Case
                WHERE CTI_Original_Call_ID__c = :originalCallId
                ORDER BY Transfer_Time__c DESC LIMIT 1
        ];
        return (!cases.isEmpty()) ? cases[0] : null;
    }

    public Case findTransferredCase(String phoneNumber, String transferredNumber) {
        List<Case> cases = [
                SELECT Id
                FROM Case
                WHERE SuppliedPhone = :phoneNumber AND Transferred_Number__c = :transferredNumber
                ORDER BY Transfer_Time__c DESC LIMIT 1
        ];
        return (!cases.isEmpty()) ? cases[0] : null;
    }

    public Case findOpenCaseByOrderNumber(String orderNumber) {
        List<Case> cases = [SELECT Id FROM Case WHERE Order_Number__c = :orderNumber AND IsClosed = false ORDER BY LastModifiedDate DESC LIMIT 1];
        return (!cases.isEmpty()) ? cases[0] : null;
    }

    /**
     * @description associate the activity to the case that was created when the call connected
     * @param activityId
     * @return
     */
    public void attachActivity(String activityId, Map<String,Object> event) {
        String uniqueCallId = String.valueOf(event.get('UniqueId'));
        Case existingCase = existingCase(uniqueCallId);
        if (existingCase != null && existingCase.Id != null) {
            update new Task(Id = activityId, WhatId = existingCase.Id);
        }
        else {
            attachActivityAsync(activityId, uniqueCallId);
        }
    }

    @Future
    private static void attachActivityAsync(String activityId, String uniqueCallId) {
        Case existingCase = existingCase(uniqueCallId);
        if (existingCase != null && existingCase.Id != null) {
            update new Task(Id = activityId, WhatId = existingCase.Id);
        }
    }

}