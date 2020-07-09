/**
* @description Helper for trac_CaseTrigger
* @author      Rajat Agrawal, Traction on Demand
* @date        2019-06-03
*/
public without sharing class trac_CaseTriggerHelper {

    public static Map<String, Status_Queue_Assignment_Setting__mdt> queueSettingByStatusBusinessUnit;
    public static Map<String, Status_Queue_Assignment_Setting__mdt> queueSettingByOtherFields;
    public static Map<String, Id> queueByDeveloperName;

    private static Boolean ranOnInsert = false;
    private static final String ORDER_NOT_FOUND = 'Order Not Found';

    public static void updateCaseOriginIfChat(List<Case> cases) {
        Map<String, Case_Type_Mapping__mdt> mapper = new Map<String, Case_Type_Mapping__mdt>();
        for (Case cse : cases) {
            if (String.isNotBlank(cse.Origin_Is_Chat__c) && cse.Origin_Is_Chat__c.equals('True')) {
                cse.Origin = trac_CaseConstants.STATUS_LIVE_AGENT;
                cse.Origin_Is_Chat__c = 'False';
            }
        }
    }

    public static void changeOwnerToStoreOperationsQueue(List<case> newCases, Map<Id, Case> oldCasesMap) {
        List<Group> queueList = new List<Group>();
        queueList = new List<Group>([SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = :trac_CaseConstants.QUEUE_STORE_OPERATIONS]);

        for (Case cs : newCases) {
            if (String.isNotBlank(cs.Origin)
                    && (cs.Origin.equals(trac_CaseConstants.ORIGIN_WEB_TO_CASE) || cs.Origin.equals(trac_CaseConstants.ORIGIN_CHAT))
                    && cs.Community_Case_Type__c != null
                    && cs.Community_Case_Type__c.equals(trac_CaseConstants.CASE_STORE_EXPERIENCE)) {
                if (oldCasesMap.isEmpty() && queueList != null && !queueList.isEmpty() && !cs.OwnerId.equals(queueList[0].Id)) {
                    ranOnInsert = True;
                } else if (!oldCasesMap.isEmpty() && ranOnInsert && queueList != null && !queueList.isEmpty() && !cs.OwnerId.equals(queueList[0].Id)) {
                    cs.OwnerId = queueList[0].Id;
                }
            }
        }
    }


    public static void changeOwnerForSpecificCommunityTopics(List<case> newCases, Map<Id, Case> oldCasesMap) {
        List<String> queues = new List<String>{
                trac_CaseConstants.QUEUE_MHF,
                trac_CaseConstants.QUEUE_MHF_REWARDS,
                trac_CaseConstants.QUEUE_MHF_FRENCH
        };
        Map<String, Id> queueMapping = new Map<String, Id>();

        for (Group queue : [SELECT Id,DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName IN:queues]) {
            queueMapping.put(queue.DeveloperName, queue.Id);
        }

        for (Case cs : newCases) {
            if (String.isNotBlank(cs.Origin)
                    && cs.Origin.equals(trac_CaseConstants.ORIGIN_WEB_TO_CASE)
                    && cs.RecordTypeId == TLSObj.getRecordTypeIdForName(Case.SObjectType, trac_CaseConstants.RECORD_TYPE_DEVNAME_SUPPORT_CASE)) {
                if (oldCasesMap.isEmpty() && queueMapping != null && !queueMapping.isEmpty()) {
                    ranOnInsert = True;
                } else if (!oldCasesMap.isEmpty()
                        && ranOnInsert
                        && queueMapping != null
                        && !queueMapping.isEmpty()) {
                    changeOwnerSpecificToHBCommunity(queueMapping, cs);
                }
            }
        }
    }

    public static void changeOwnerSpecificToHBCommunity(Map<String, Id> queueMapping, Case cse) {
        if (String.isNotBlank(cse.Case_Language__c) && cse.Case_Language__c.equals(trac_CaseConstants.CASE_LANGUAGE_ENGLISH)) {
            if (String.isNotBlank(cse.Community_Case_Type__c)
                    && cse.Community_Case_Type__c.equals(trac_CaseConstants.CASE_MAJOR_HOME_PURCHASES)
                    && queueMapping.containsKey(trac_CaseConstants.QUEUE_MHF)) {
                cse.OwnerId = queueMapping.get(trac_CaseConstants.QUEUE_MHF);
            } else if (String.isNotBlank(cse.Community_Case_Type__c)
                    && cse.Community_Case_Type__c.equals(trac_CaseConstants.CASE_HUDSON_BAY_REWARDS)
                    && queueMapping.containsKey(trac_CaseConstants.QUEUE_MHF_REWARDS)) {
                cse.OwnerId = queueMapping.get(trac_CaseConstants.QUEUE_MHF_REWARDS);
            }
        } else if (String.isNotBlank(cse.Case_Language__c) && cse.Case_Language__c.equals(trac_CaseConstants.CASE_LANGUAGE_FRENCH)) {
            if (String.isNotBlank(cse.Community_Case_Type__c)
                    && cse.Community_Case_Type__c.equals(trac_CaseConstants.CASE_MAJOR_HOME_PURCHASES)
                    && queueMapping.containsKey(trac_CaseConstants.QUEUE_MHF_FRENCH)) {
                cse.OwnerId = queueMapping.get(trac_CaseConstants.QUEUE_MHF_FRENCH);
            }
        }
    }


    public static void assignClickToCallCases(List<Case> cases, Map<Id, Case> oldMap) {
        Id recordTypeId;
        Id queueId;
        List<Group> queueList;
        Id userRoleId;
        List<UserRole> userRoleList;


        queueList = new List<Group>([SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = :trac_CaseConstants.QUEUE_CLICK_TO_CALL_CASE]);
        if (queueList != null && !queueList.isEmpty()) {
            queueId = queueList[0].Id;
        }

        userRoleList = new List<UserRole>([SELECT Id FROM UserRole WHERE Name = :trac_CaseConstants.ROLE_CC_LEADERSHIP]);
        if (userRoleList != null && !userRoleList.isEmpty()) {
            userRoleId = userRoleList[0].Id;
        }

        recordTypeId = trac_CaseConstants.RECORD_TYPE_ID_CLICK_TO_CALL_CASE;

        if (oldMap == null) {
            for (Case cse : cases) {
                if (cse.RecordTypeId == recordTypeId) {
                    cse.OwnerId = queueId;
                }
            }
        } else if (!oldMap.isEmpty()) {
            for (Case cse : cases) {
                if (oldMap.get(cse.Id).OwnerId != null && oldMap.get(cse.Id).OwnerId != cse.OwnerId && cse.OwnerId.equals(queueId) && UserInfo.getUserRoleId() != userRoleId) {
                    cse.addError('Insufficient Privileges! You don\'t have access to assign cases to Click to Call queue.');
                }
            }
        }
    }

    public static void keepOwnershipAndUpdateSteward(List<Case> cases) {

        for (Case cse : cases) {
            if (cse.RecordTypeId == TLSObj.getRecordTypeIdForName(Case.SObjectType, trac_CaseConstants.RECORD_TYPE_DEVNAME_SAKS) && !cse.Keep_Ownership__c) {
                cse.Keep_Ownership__c = True;
            }
            if (String.isBlank(cse.Case_Steward__c) && cse.Keep_Ownership__c && !String.valueOf(cse.OwnerId).startsWithIgnoreCase('00G')) {
                cse.Case_Steward__c = cse.OwnerId;
            }
        }
    }


    public static void mapCaseTypeFromCommunity(List<Case> cases) {
        Map<String, Case_Type_Mapping__mdt> mapper = new Map<String, Case_Type_Mapping__mdt>();
        for (Case_Type_Mapping__mdt mapping : [SELECT Community_Value__c, Map_to_Field__c, Map_to_Value__c FROM Case_Type_Mapping__mdt]) {
            mapper.put(mapping.Community_Value__c, mapping);
        }

        for (Case cs : cases) {
            if ((cs.Origin == 'Support Community' || cs.Origin == 'Live Agent') && cs.Community_Case_Type__c != null) {
                if (mapper.get(cs.Community_Case_Type__c) != null) {
                    Case_Type_Mapping__mdt thisMap = mapper.get(cs.Community_Case_Type__c);
                    cs.put(thisMap.Map_to_Field__c, thisMap.Map_to_Value__c);
                }
            }
        }
    }

    public static void updateBusinessUnit(List<Case> newList, Map<Id, Case> oldMap) {

        if (Trigger.size == 1 && newList[0].ContactId != null) {
            Contact con = new Contact(Id = newList[0].ContactId, Business_Unit__c = newList[0].Business_Unit__c);
            update con;
            return ;
        }

        Map<Id, Contact> contactMap = new Map<Id, Contact>();
        for (Case cs : newList) {
            if (cs.ContactId != null && (oldMap == null || oldMap.get(cs.Id).ContactId != cs.ContactId ||
                    oldMap.get(cs.Id).Business_Unit__c != cs.Business_Unit__c)) {
                contactMap.put(cs.ContactId, new Contact(Id = cs.ContactId, Business_Unit__c = cs.Business_Unit__c));
            }
        }

        if (!contactMap.isEmpty()) {
            update contactMap.values();
        }
    }

    public static void updateCaseOwner(List<Case> newList, Map<Id, Case> oldMap) {
        Id userId = UserInfo.getUserId();

        for (Case cs : newList) {
            if (cs.Status == 'Closed' && (oldMap == null || oldMap.get(cs.Id).Status != cs.Status)) {
                if (String.valueOf(cs.OwnerId).startsWithIgnoreCase('00G')) {
                    cs.OwnerId = userId;

                } else if (cs.Owner_When_First_Closed__c == null) {
                    cs.Owner_When_First_Closed__c = cs.OwnerId;
                }
                if (cs.Date_Time_First_Closed__c == null) {
                    cs.Date_Time_First_Closed__c = System.now();
                }
            }
        }
    }

    /**
* @description Checks if there is a Contact associated to the Case, create a new Contact otherwise
* @param       newList, List of new Case records being inserted
* @return      void
*/
    public static void checkContact(List<Case> newList) {

        List<Case> cases = new List<Case>();
        Map<Id, Contact> mapCaseToContact = new Map<Id, Contact>();
        Set<String> phones = new Set<String>();
        Set<String> emails = new Set<String>();
        Set<String> businessUnits = new Set<String>();
        Map<Id, Case> caseMap = new Map<Id, Case>();

        for (Case cs : newList) {

            if (cs.ContactId == null && cs.Origin != trac_CaseConstants.ORIGIN_CHAT) {
                caseMap.put(cs.Id, cs);
                Contact contact = new Contact(Phone = cs.SuppliedPhone, Email = cs.SuppliedEmail);

                if (!trac_WS_CustomerUtils.excludeFromProcesses(contact)) {
                    if (cs.SuppliedPhone != null) {
                        phones.add(cs.SuppliedPhone);
                    }
                    if (cs.SuppliedEmail != null) {
                        emails.add(cs.SuppliedEmail);
                    }
                    if (cs.Business_Unit__c != null) {
                        businessUnits.add(cs.Business_Unit__c);
                    }
                }
            }
        }

        if ((!emails.isEmpty() || !phones.isEmpty()) && !businessUnits.isEmpty()) {
            for (Contact con : [
                    SELECT Id, Phone, Email, Business_Unit__c
                    FROM Contact
                    WHERE (Email IN:emails OR Phone IN:phones) AND Business_Unit__c IN:businessUnits
            ]) {

                for (Case cs : caseMap.values()) {
                    if ((cs.SuppliedEmail == con.Email || cs.SuppliedPhone == con.Phone) && cs.Business_Unit__c == con.Business_Unit__c) {
                        Case updateCase = new Case(Id = cs.Id, ContactId = con.Id);
                        cases.add(updateCase);
                        caseMap.remove(cs.Id);
                    }
                }
            }

        }

        for (Case cs : caseMap.values()) {
            Contact con = createContact(cs);
            if (con != null) {
                mapCaseToContact.put(cs.Id, con);
            }
        }

        if (!mapCaseToContact.isEmpty()) {
            insert mapCaseToContact.values();

            for (Id caseId : mapCaseToContact.keySet()) {
                Case updateCase = new Case(Id = caseId, ContactId = mapCaseToContact.get(caseId).Id);
                cases.add(updateCase);
            }
        }
        update cases;
    }

    /**
* @description Returns a new Contact created from the specified Case record values
* @param       cs, Case record for which the Contact is to be created
* @return      Contact, the new Contact record to be inserted
*/
    private static Contact createContact(Case cs) {
        //Return null if all supplied fields are blank
        if (cs.SuppliedName == null && cs.SuppliedEmail == null && cs.SuppliedPhone == null) {
            return null;
        }

        Boolean conNamePopulated = false;
        Contact con = new Contact(
                RecordTypeId = trac_CaseConstants.RECORD_TYPE_ID_CUSTOMER_CONTACT
        );
        String name;
        List<String> splitName;
        //Check for Name
        if (cs.SuppliedName != null) {
            name = cs.SuppliedName;
            if (name.contains(',')) {
                splitName = name.split(',');
                if (splitName.size() > 1) {
                    con.FirstName = name.substringAfter(',').trim();
                    con.LastName = splitName[0];
                } else {
                    con.LastName = name;
                }
            } else {
                splitName = name.split(' ');
                if (splitName.size() > 1) {
                    con.FirstName = splitName[0];
                    con.LastName = name.substringAfter(' ');
                } else {
                    con.LastName = name;
                }
            }
            conNamePopulated = true;
        }
        //Check for Email
        if (cs.SuppliedEmail != null) {
            con.Email = cs.SuppliedEmail;
            if (!conNamePopulated) {
                con.LastName = cs.SuppliedEmail;
                conNamePopulated = true;
            }
        }
        //Check for Phone
        if (cs.SuppliedPhone != null) {
            con.Phone = cs.SuppliedPhone;
        }
        if (cs.Case_Language__c != null) {
            con.Language__c = cs.Case_Language__c;
        }
        if (cs.Origin != null) {
            con.Channel_Origin__c = cs.Origin;
        }

        if (!conNamePopulated) {
            con = null;
        }
        return con;
    }

    /**
* @description Checks if there is a Contact associated to the Case, create a new Contact otherwise
* @param       newList, List of new Case records being inserted
* @param       oldMap, Trigger.oldMap of Case
* @return      void
*/
    public static void updateLastCaseOnContact(List<Case> newList, Map<Id, Case> oldMap) {

        List<Contact> contacts = new List<Contact>();

        for (Case aCase : newList) {
            if (aCase.ContactId != null && (oldMap == null || aCase.ContactId != oldMap.get(aCase.Id).ContactId)) {
                contacts.add(new Contact(Id = aCase.ContactId, Last_Case__c = aCase.Id));
            }
        }

        if (!contacts.isEmpty()) {
            update contacts;
        }
    }

    /**
* @description If an Order Number is populated, search for an existing Case with the same Order Number, if found, set it as the parent Case
* @date        2019-06-10
* @param       newList, List of new Case records being inserted
* @param       oldMap, Trigger.oldMap of Case
* @return      void
*/
    public static void updateParentCase(List<Case> newList, Map<Id, Case> oldMap) {
        List<Case> cases = new List<Case>();
        Map<String, Set<Id>> mapOrderNoToCases = new Map<String, Set<Id>>();

        for (Case aCase : newList) {
            if (aCase.Order_Number__c != null && aCase.Order_Number__c != ORDER_NOT_FOUND && (oldMap == null || aCase.Order_Number__c != oldMap.get(aCase.Id).Order_Number__c)) {
                if (!mapOrderNoToCases.containsKey(aCase.Order_Number__c)) {
                    mapOrderNoToCases.put(aCase.Order_Number__c, new Set<Id>());
                }
                mapOrderNoToCases.get(aCase.Order_Number__c).add(aCase.Id);
            }
        }

        if (mapOrderNoToCases.isEmpty()) return ;

        for (Case aCase : [SELECT Id, Order_Number__c FROM Case WHERE Order_Number__c IN:mapOrderNoToCases.keySet() ORDER BY CreatedDate DESC]) {
            if (mapOrderNoToCases.containsKey(aCase.Order_Number__c)) {
                for (Id caseId : mapOrderNoToCases.get(aCase.Order_Number__c)) {
                    if (aCase.Id != caseId) {
                        Case cs = new Case(Id = caseId, ParentId = aCase.Id);
                        cases.add(cs);
                        if (mapOrderNoToCases.containsKey(aCase.Order_Number__c))
                            mapOrderNoToCases.remove(aCase.Order_Number__c);
                    }
                }
            }
        }

        if (!cases.isEmpty()) {
            update cases;
        }
    }


    /**
* @description update case queue or other field updates based on the change in status
* @param       newList, List of new Case records being inserted
* @param       oldMap, Trigger.oldMap of Case
*/
    public static void caseStatusAutomation(List<Case> newList, Map<Id, Case> oldMap) {
        List<Map<String, Status_Queue_Assignment_Setting__mdt>> queueSettingMapList = new List<Map<String, Status_Queue_Assignment_Setting__mdt>>();
        queueSettingMapList = mapQueueSettings();
        if (queueSettingMapList != null && !queueSettingMapList.isEmpty()) {
            queueSettingByOtherFields = queueSettingMapList[0];
            queueSettingByStatusBusinessUnit = queueSettingMapList[1];
            queueByDeveloperName = mapQueueNames();

            for (Case aCase : (List<Case>) TLTrigger.filterByFieldChanged(newList, oldMap, Case.Status)) {
                if ((aCase.RecordTypeId == TLSObj.getRecordTypeIdForName(Case.SObjectType, trac_CaseConstants.RECORD_TYPE_DEVNAME_SUPPORT_CASE) ||
                        aCase.RecordTypeId == TLSObj.getRecordTypeIdForName(Case.SObjectType, trac_CaseConstants.RECORD_TYPE_DEVNAME_OFF_5TH) ||
                        aCase.RecordTypeId == TLSObj.getRecordTypeIdForName(Case.SObjectType, trac_CaseConstants.RECORD_TYPE_DEVNAME_SAKS))) {
                    assignToQueue(aCase);
                    setIssueSystemStart(aCase);
                    setIssueSystemEnd(aCase, oldMap.get(aCase.Id));
                    setStatusClosed(aCase);
                }
            }
        }
    }

    public static void transferStewardship(List<Case> newList) {
        for (Case aCase : newList) {
            if (aCase.Transfer_Stewardship__c && aCase.Case_Steward__c != aCase.OwnerId && !String.valueOf(aCase.OwnerId).startsWithIgnoreCase('00G')) {
                aCase.Case_Steward__c = aCase.OwnerId;
            }
        }
    }


    /**
* @description populates a map with custom metadata types where the key is the Case Status field
* @return      map of string to Status Queue Assignment Setting custom metadata type
*/
    private static List<Map<String, Status_Queue_Assignment_Setting__mdt>> mapQueueSettings() {
        Map<String, Status_Queue_Assignment_Setting__mdt> typeCategorySettingMap = new Map<String, Status_Queue_Assignment_Setting__mdt>();
        Map<String, Status_Queue_Assignment_Setting__mdt> settingMap = new Map<String, Status_Queue_Assignment_Setting__mdt>();
        List<Map<String, Status_Queue_Assignment_Setting__mdt>> mapList = new List<Map<String, Status_Queue_Assignment_Setting__mdt>>();

        for (Status_Queue_Assignment_Setting__mdt queueSetting : [SELECT Case_Status__c, Queue__c, Ignore_on_Executive_Escalation__c, Business_Unit__c,Case_Type__c,Category__c,Sub_Category__c,Ignore_Metadata_Mapping__c,Transfer_Stewardship__c FROM Status_Queue_Assignment_Setting__mdt]) {
            if (queueSetting.Case_Type__c != null || queueSetting.Category__c != null || queueSetting.Sub_Category__c != null) {
                typeCategorySettingMap.put(queueSetting.Case_Status__c + queueSetting.Business_Unit__c + queueSetting.Case_Type__c + queueSetting.Category__c + queueSetting.Sub_Category__c, queueSetting);
            } else {
                settingMap.put(queueSetting.Case_Status__c + queueSetting.Business_Unit__c, queueSetting);
            }
        }
        mapList.add(typeCategorySettingMap);
        mapList.add(settingMap);
        return mapList;
    }


    /**
* @description populates a map with queue ids where the key is the developer name of the queue
* @return      map of ids to developer name
*/
    private static Map<String, Id> mapQueueNames() {
        Map<String, Id> queueMap = new Map<String, Id>();
        Set<String> StatusBusinessUnitSet = new Set<String>(TLList.collectStrings(queueSettingByStatusBusinessUnit.values(), 'Queue__c'));
        Set<String> otherFieldsSet = new Set<String>(TLList.collectStrings(queueSettingByOtherFields.values(), 'Queue__c'));

        for (Group queue : [
                SELECT Id, DeveloperName
                FROM Group
                WHERE Type = 'Queue'
                AND (DeveloperName IN :otherFieldsSet OR DeveloperName IN :StatusBusinessUnitSet )
        ]) {
            queueMap.put(queue.DeveloperName, queue.Id);
        }
        return queueMap;
    }


    /**
* @description sets the owner id field on a case to a queue based on the case status and the custom metadata type that drives the assignment
* @param       inCase case record to be assigned to a queue
*/
    private static void assignToQueue(Case inCase) {
        if (inCase != null
                && String.isNotBlank(inCase.Case_Type__c)
                && queueSettingByOtherFields != null
                && queueSettingByOtherFields.containsKey(inCase.Status + inCase.Business_Unit__c + inCase.Case_Type__c + inCase.Category__c + inCase.Subcategory__c)
                && queueSettingByOtherFields.get(inCase.Status + inCase.Business_Unit__c + inCase.Case_Type__c + inCase.Category__c + inCase.Subcategory__c) != null
                && (!inCase.Executive_Escalation_Owner__c || !queueSettingByOtherFields.get(inCase.Status + inCase.Business_Unit__c + inCase.Case_Type__c + inCase.Category__c + inCase.Subcategory__c).Ignore_on_Executive_Escalation__c)
                //&& !(queueSettingByOtherFields.get(inCase.Status + inCase.Business_Unit__c + inCase.Case_Type__c + inCase.Category__c + inCase.Subcategory__c).Ignore_Metadata_Mapping__c)
                && !inCase.Keep_Ownership__c) {

            String queueName = queueSettingByOtherFields.get(inCase.Status + inCase.Business_Unit__c + inCase.Case_Type__c + inCase.Category__c + inCase.Subcategory__c).Queue__c;
            if (String.isNotBlank(queueName) && queueByDeveloperName != null && !queueByDeveloperName.isEmpty() && queueByDeveloperName.containsKey(queueName)) {
                inCase.OwnerId = queueByDeveloperName.get(queueName);
                inCase.Transfer_Stewardship__c = queueSettingByOtherFields.get(inCase.Status + inCase.Business_Unit__c + inCase.Case_Type__c + inCase.Category__c + inCase.Subcategory__c).Transfer_Stewardship__c;
            }
        } else if (inCase != null
                && String.isNotBlank(inCase.Status)
                && String.isNotBlank(inCase.Business_Unit__c)
                && queueSettingByStatusBusinessUnit != null
                && queueSettingByStatusBusinessUnit.containsKey(inCase.Status + inCase.Business_Unit__c)
                && queueSettingByStatusBusinessUnit.get(inCase.Status + inCase.Business_Unit__c) != null
                && (!inCase.Executive_Escalation_Owner__c || !queueSettingByStatusBusinessUnit.get(inCase.Status + inCase.Business_Unit__c).Ignore_on_Executive_Escalation__c)
                //&& !(queueSettingByStatusBusinessUnit.get(inCase.Status + inCase.Business_Unit__c).Ignore_Metadata_Mapping__c)
                && !inCase.Keep_Ownership__c) {
            String queueName = queueSettingByStatusBusinessUnit.get(inCase.Status + inCase.Business_Unit__c).Queue__c;
            if (String.isNotBlank(queueName) && queueByDeveloperName != null && !queueByDeveloperName.isEmpty() && queueByDeveloperName.containsKey(queueName)) {
                inCase.OwnerId = queueByDeveloperName.get(queueName);
                inCase.Transfer_Stewardship__c = queueSettingByStatusBusinessUnit.get(inCase.Status + inCase.Business_Unit__c).Transfer_Stewardship__c;
            }
        } else if (inCase != null
                && String.isNotBlank(inCase.Status)
                && queueSettingByStatusBusinessUnit != null
                && queueSettingByStatusBusinessUnit.containsKey(inCase.Status + 'All')
                && queueSettingByStatusBusinessUnit.get(inCase.Status + 'All') != null
                && (!inCase.Executive_Escalation_Owner__c || !queueSettingByStatusBusinessUnit.get(inCase.Status + 'All').Ignore_on_Executive_Escalation__c)
                //&& !(queueSettingByStatusBusinessUnit.get(inCase.Status + 'All').Ignore_Metadata_Mapping__c)
                && !inCase.Keep_Ownership__c) {
            
            String queueName = queueSettingByStatusBusinessUnit.get(inCase.Status + 'All').Queue__c;
            if (String.isNotBlank(queueName) && queueByDeveloperName != null && !queueByDeveloperName.isEmpty() && queueByDeveloperName.containsKey(queueName)) {
                inCase.OwnerId = queueByDeveloperName.get(queueName);
                inCase.Transfer_Stewardship__c = queueSettingByStatusBusinessUnit.get(inCase.Status + inCase.Business_Unit__c).Transfer_Stewardship__c;
            }
        }
    }


    /**
* @description method to check entry logic for issue system start date and set the start time
* @param       inCase, case record to check
*/
    private static void setIssueSystemStart(Case inCase) {
        if (inCase.System_Issue_Start__c == null && inCase.Status == trac_CaseConstants.STATUS_SYSTEM_ISSUE) {
            inCase.System_Issue_Start__c = Datetime.now();
        }
    }


    /**
* @description method to check entry logic for issue system start date and set the start time
* @param       inCase, case record to check
* @param       oldCase, old case used to compare status value
*/
    private static void setIssueSystemEnd(Case inCase, Case oldCase) {
        if (inCase.System_Issue_Start__c != null
                && inCase.Status != trac_CaseConstants.STATUS_SYSTEM_ISSUE
                && oldCase.Status == trac_CaseConstants.STATUS_SYSTEM_ISSUE) {
            inCase.System_Issue_End__c = Datetime.now();
        }
    }


    /**
* @description method to check entry logic for date time first closed
* @param       inCase, case record to check
*/
    private static void setStatusClosed(Case inCase) {
        if (inCase.Status == trac_CaseConstants.STATUS_CLOSED) {
            inCase.Date_Time_First_Closed__c = inCase.Date_Time_First_Closed__c != null ? inCase.Date_Time_First_Closed__c : Datetime.now();
        }
    }

    public static void ownerChanged(List<Case> newList, Map<Id, Case> oldMap) {
        Group holdQueue = [SELECT Id FROM Group WHERE DeveloperName = 'Hold' AND Type = 'Queue'];
        List<Case> ownerChangedCases = new List<Case>();
        if (oldMap != null) {
            ownerChangedCases = TLTrigger.filterByFieldChanged(newList, oldMap, Case.OwnerId);
        } else {
            ownerChangedCases = newList;
        }

        for (Case aCase : ownerChangedCases) {
            if (String.valueOf(aCase.OwnerId).substring(0, 3) == '00G' && aCase.OwnerId != holdQueue.Id) {
                aCase.Previous_Queue_Owner_ID__c = aCase.OwnerId;
            }
        }
    }


    /**
* @description update the case routing to keep the case's created date when owner changes to a queue
* @param       newList, list of new case records
* @param       oldMap, map of old case records
*/
    public static void channelRouting(List<Case> newList, Map<Id, Case> oldMap) {
        List<Case> casesChangedOwner = TLTrigger.filterByFieldChanged(newList, oldMap, Case.OwnerId);
        Map<Id, Datetime> caseIdToCreatedDate = new Map<Id, Datetime>();
        for (Case c : casesChangedOwner) {
            if (String.valueOf(c.OwnerId).substring(0, 3) == '00G') {
                caseIdToCreatedDate.put(c.Id, c.CreatedDate);
            }
        }
        if (caseIdToCreatedDate.size() > 0) {
            updateServiceRoutings(caseIdToCreatedDate);
        }
    }

    public static void updateServiceRoutings(Map<Id, Datetime> caseIdToCreatedDate) {
        if (System.isFuture() || System.isBatch()) {
            updateServiceRoutingsSync(caseIdToCreatedDate);
        } else {
            updateServiceRoutingsAsync(caseIdToCreatedDate);
        }
    }

    /**
* @description get the related pending service routing record and update the custom requested datetime to the original datetime the case was created
* @param caseIdToCreatedDate - map of case id to datetime the case was created
*/
    @Future
    public static void updateServiceRoutingsAsync(Map<Id, Datetime> caseIdToCreatedDate) {
        updateServiceRoutingsSync(caseIdToCreatedDate);
    }

    public static void updateServiceRoutingsSync(Map<Id, Datetime> caseIdToCreatedDate) {
        List<PendingServiceRouting> serviceRoutings = [SELECT Id, WorkItemId FROM PendingServiceRouting WHERE WorkItemId IN :caseIdToCreatedDate.keySet()];
        for (PendingServiceRouting routing : serviceRoutings) {
            if (caseIdToCreatedDate.get(routing.WorkItemId) != null) {
                routing.CustomRequestedDateTime = caseIdToCreatedDate.get(routing.WorkItemId);
            }
        }
        if (serviceRoutings.size() > 0) update serviceRoutings;
    }

    /**
* @description Set business hours on the case based on Business Unit
* @param       newList, List of new Case records being inserted
* @return      void
*/
    public static void updateBusinessHours(List<Case> newList) {

        Map<String, Id> mapUnitToHour = new Map<String, Id>();
        for (Business_Unit_Business_Hours_Setting__mdt businessHoursSetting : [SELECT Id, Label, Business_Unit__c, Business_Hours__c FROM Business_Unit_Business_Hours_Setting__mdt]) {
            mapUnitToHour.put(businessHoursSetting.Label, businessHoursSetting.Business_Hours__c);
        }

        if (mapUnitToHour.isEmpty()) return ;

        for (Case cs : newList) {
            if (cs.Business_Unit__c != null) {
                if (mapUnitToHour.containsKey(cs.Business_Unit__c)) {
                    cs.BusinessHoursId = mapUnitToHour.get(cs.Business_Unit__c);
                } else if (cs.Business_Unit__c == trac_CaseConstants.BUSINESS_UNIT_MHF && cs.Case_Language__c != null) {
                    if (cs.Case_Language__c == trac_CaseConstants.CASE_LANGUAGE_ENGLISH && mapUnitToHour.containsKey(trac_CaseConstants.BUSINESS_HOURS_SETTING_MHF_ENGLISH)) {
                        cs.BusinessHoursId = mapUnitToHour.get(trac_CaseConstants.BUSINESS_HOURS_SETTING_MHF_ENGLISH);
                    } else if (cs.Case_Language__c == trac_CaseConstants.CASE_LANGUAGE_FRENCH && mapUnitToHour.containsKey(trac_CaseConstants.BUSINESS_HOURS_SETTING_MHF_FRENCH)) {
                        cs.BusinessHoursId = mapUnitToHour.get(trac_CaseConstants.BUSINESS_HOURS_SETTING_MHF_FRENCH);
                    }
                }
            }
        }
    }

    public static void setOrderInformation(List<Case> newCases, Map<Id, Case> oldCasesByIds) {
        Set<Id> caseIdsToGetOrderInfo = new Set<Id>();
        for (Case newCase : newCases) {
            if (!TLTrigger.wasRecordProcessed(newCase.Id, 'setOrderInformation')) {

                Case oldCase;

                if (oldCasesByIds.containsKey(newCase.Id)) {
                    oldCase = oldCasesByIds.get(newCase.Id);
                }

                //New Case with Order Number, Order Number changed or Case Closed
                if (newCase.Order_Number__c != null && newCase.Order_Number__c != ORDER_NOT_FOUND && (oldCase == null || oldCase.Order_Number__c != newCase.Order_Number__c || (newCase.IsClosed && !oldCase.IsClosed))) {
                    caseIdsToGetOrderInfo.add(newCase.Id);
                    TLTrigger.addRecordProcess(newCase.Id, 'setOrderInformation');
                }
            }
        }

        if (!caseIdsToGetOrderInfo.isEmpty()) {
            trac_WS_OrderUtils.setCaseOrderInformation(caseIdsToGetOrderInfo);
        }
    }

    public static void setOrderRefundCreditApproval(List<Case> newCases, Map<Id, Case> oldCasesByIds) {
        Map<String, Set<Id>> caseIdsByStatus = new Map<String, Set<Id>>();

        for (Case newCase : newCases) {
            if (!TLTrigger.wasRecordProcessed(newCase.Id, 'setOrderRefundCreditApproval')) {

                Case oldCase;
                if (oldCasesByIds.containsKey(newCase.Id)) {
                    oldCase = oldCasesByIds.get(newCase.Id);
                }

                if (oldCase == null || oldCase.Status != newCase.Status) {
                    if (!caseIdsByStatus.containsKey(newCase.Status)) {
                        caseIdsByStatus.put(newCase.Status, new Set<Id>());
                    }
                    caseIdsByStatus.get(newCase.Status).add(newCase.Id);
                }
            }
        }

        if (!caseIdsByStatus.isEmpty()) {
            filterAndUpdateORCs(caseIdsByStatus);
        }
    }

    private static void filterAndUpdateORCs(Map<String, Set<Id>> caseIdsByStatus) {
        List<Order_Refund_Credit__c> orderRefundCreditsToUpdate = new List<Order_Refund_Credit__c>();

        if (!caseIdsByStatus.isEmpty()) {
            Set<Id> caseIdsToQuery = new Set<Id>();
            List<Order_Refund_Credit_Case_Status_Setting__mdt> orderRefundCreditCaseStatusSettings = getOrderRefundCreditCaseStatusSettingsByStatus(caseIdsByStatus.keySet(), 'Set ORC Approval Status');

            for (Order_Refund_Credit_Case_Status_Setting__mdt orderRefundCreditCaseStatusSetting : orderRefundCreditCaseStatusSettings) {
                if (caseIdsByStatus.containsKey(orderRefundCreditCaseStatusSetting.Status__c)) {
                    caseIdsToQuery.addAll(caseIdsByStatus.get(orderRefundCreditCaseStatusSetting.Status__c));
                }
            }

            if (!caseIdsToQuery.isEmpty()) {
                List<Order_Refund_Credit__c> orderRefundCredits = getOrderRefundCreditsRequiringApprovalByCaseIds(caseIdsToQuery);
                for (Order_Refund_Credit__c orderRefundCredit : orderRefundCredits) {
                    if (orderRefundCredit.ORC_Status__c != trac_OrderRefundCreditConstants.STATUS_REQUIRES_APPROVAL) {
                        orderRefundCredit.ORC_Status__c = trac_OrderRefundCreditConstants.STATUS_REQUIRES_APPROVAL;
                        orderRefundCreditsToUpdate.add(orderRefundCredit);
                        TLTrigger.addRecordProcess(orderRefundCredit.Case__c, 'setOrderRefundCreditApproval');
                    }
                }
            }
        }

        if (!orderRefundCreditsToUpdate.isEmpty()) {
            update orderRefundCreditsToUpdate;
        }
    }

    private static List<Order_Refund_Credit_Case_Status_Setting__mdt> getOrderRefundCreditCaseStatusSettingsByStatus(Set<String> caseStatuses, String process) {
        List<Order_Refund_Credit_Case_Status_Setting__mdt> orderRefundCreditCaseStatusSettings = [
                SELECT Id, Status__c
                FROM Order_Refund_Credit_Case_Status_Setting__mdt
                WHERE Enabled__c = true AND Object__c = 'Case' AND Status__c IN :caseStatuses AND Process__c = :process
        ];
        return orderRefundCreditCaseStatusSettings;
    }

    private static List<Order_Refund_Credit__c> getOrderRefundCreditsRequiringApprovalByCaseIds(Set<Id> caseIds) {
        List<Order_Refund_Credit__c> orderRefundCreditCaseStatusSettings = [
                SELECT Id, Case__c, ORC_Status__c, Approval_Required__c
                FROM Order_Refund_Credit__c
                WHERE Case__c IN :caseIds AND Approval_Required__c = true AND ORC_Status__c != :trac_OrderRefundCreditConstants.STATUS_REQUIRES_APPROVAL
        ];
        return orderRefundCreditCaseStatusSettings;
    }

    public static void caseGiftCardQueueHandler(List<Case> newCaseList, Map<Id, Case> oldMap) {
        List<Case> caseList = new List<Case>();
        for (Case cs : newCaseList) {
            if ((String.isNotBlank(cs.Status) && cs.Status != oldMap.get(cs.Id).Status && cs.Status.equals(trac_CaseConstants.STATUS_POS_TEAM))) {
                caseList.add(cs);
            }
        }

        //Creating map of business unit + gift card to queue's developer name
        Map<String, String> bUnitQueueNameMap = new Map<String, String>();
        for (Gift_Card_Mapping__mdt gftCard : [SELECT Id, Business_Unit__c, Includes_Gift_Card__c, Queue_Developer_Name__c FROM Gift_Card_Mapping__mdt]) {
            bUnitQueueNameMap.put(gftCard.Business_Unit__c + '--' + gftCard.Includes_Gift_Card__c, gftCard.Queue_Developer_Name__c);
        }

        //Creating map of quene name to id
        Map<String, String> queueNameToIdMap = new Map<String, String>();
        for (Group grp : [SELECT Id, DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName IN:bUnitQueueNameMap.values()]) {
            queueNameToIdMap.put(grp.DeveloperName, grp.Id);
        }

        for (Case cs : caseList) {
            Boolean includesGiftCard = false;
            if (cs.ORC_Gift_Card_Amount__c != null && cs.ORC_Gift_Card_Amount__c > 0)
                includesGiftCard = true;
            if (bUnitQueueNameMap.containsKey(cs.Business_Unit__c + '--' + includesGiftCard) && !cs.Keep_Ownership__c) {
                String queueId = queueNameToIdMap.get(bUnitQueueNameMap.get(cs.Business_Unit__c + '--' + includesGiftCard));
                if (String.isNotBlank(queueId))
                    cs.OwnerId = queueId;
            }
        }
    }

    public static void removeBlockedContactFromCase(List<Case> newCaseList) {
        Map<Case, String> caseToContactIdMap = new Map<Case, String>();
        for (Case cs : newCaseList) {
            if (String.isNotBlank(cs.Origin) && !cs.Origin.equals('Phone')) {
                caseToContactIdMap.put(cs, cs.ContactId);
            }
        }

        List<String> ctiGenericNumbers = new List<String>();
        for (CTI_Generic_Number__mdt cti : [SELECT Phone_Number__c FROM CTI_Generic_Number__mdt]) {
            ctiGenericNumbers.add(cti.Phone_Number__c.replaceAll('[^0-9]', ''));
        }

        Map<Id, String> contactIdToPhoneMap = new Map <Id, String>();
        for (Contact c : [SELECT Id, Phone FROM Contact WHERE Id IN:caseToContactIdMap.values()]) {
            contactIdToPhoneMap.put(c.Id, c.Phone);
        }

        for (Case cs : caseToContactIdMap.keySet()) {
            if (contactIdToPhoneMap.containsKey(cs.ContactId)
                    && ctiGenericNumbers.contains(contactIdToPhoneMap.get(cs.ContactId))) {
                cs.ContactId = null;
            }
        }
    }

    public static void setTranscriptContact(List<Case> newCases, Map<Id, Case> oldCasesById) {

        List<LiveChatTranscript> liveChatTranscriptsToUpdate = new List<LiveChatTranscript>();

        Map<Id, Case> casesByIds = new Map<Id, Case>();
        for (Case newCase : newCases) {

            Case oldCase;
            if (oldCasesById.containsKey(newCase.Id)) {
                oldCase = oldCasesById.get(newCase.Id);
            }

            if (newCase.ContactId != null && (oldCase == null || oldCase.ContactId != newCase.ContactId)) {
                casesByIds.put(newCase.Id, newCase);
            }
        }

        if (!casesByIds.isEmpty()) {
            List<LiveChatTranscript> liveChatTranscripts = getLiveChatTranscriptsByCaseIds(casesByIds.keySet());

            for (LiveChatTranscript liveChatTranscript : liveChatTranscripts) {
                Case transcriptCase = casesByIds.get(liveChatTranscript.CaseId);

                if (transcriptCase.ContactId != null && transcriptCase.ContactId != liveChatTranscript.ContactId) {
                    liveChatTranscript.ContactId = transcriptCase.ContactId;
                    liveChatTranscriptsToUpdate.add(liveChatTranscript);
                }
            }
        }

        if (!liveChatTranscriptsToUpdate.isEmpty()) {
            update liveChatTranscriptsToUpdate;
        }
    }

    /**
* @author Nigel Rodrigues, Traction on Demand
* @description Updates loyalty info on case and associated Contact after inserting the case
*
* @param caseList
*/
    public static void updateLoyaltyInfoOnRelatedContact(List<Case> caseList) {
        List<Id> contactsToBeUpdated = new List<Id>();

        for (Case newCase : caseList) {
            if (newCase.ContactId != null) {
                contactsToBeUpdated.add(newCase.ContactId);
            }
        }
        try {
            if (System.isFuture() || System.isBatch()) {
                trac_UpdateLoyaltyInfoOnContact loyaltyInfo = new trac_UpdateLoyaltyInfoOnContact();
                loyaltyInfo.updateContacts(contactsToBeUpdated);
            } else {
                ID queueableJobID = System.enqueueJob(new trac_UpdateContactQueueable(contactsToBeUpdated));
            }

        } catch (Exception e) {
            System.debug('Exception thrown: ' + e.getMessage());
        }

    }

    private static List<LiveChatTranscript> getLiveChatTranscriptsByCaseIds(Set<Id> caseIds) {
        List<LiveChatTranscript> liveChatTranscripts = [
                SELECT Id, ContactId, CaseId
                FROM LiveChatTranscript
                WHERE CaseId IN :caseIds
        ];

        return liveChatTranscripts;
    }

    public static void setFeedOnCase(List<Case> caseList) {
        Set<Id> caseIds = new Set<Id>();
        for (Case cse : caseList) {
            caseIds.add(cse.Id);
        }
        if (System.isFuture() || System.isBatch()) {
            setFeedOnCaseSync(caseIds);
        } else {
            setFeedOnCaseAsync(caseIds);
        }
    }

    @Future
    private static void setFeedOnCaseAsync(Set<Id> caseIds) {
        setFeedOnCaseSync(caseIds);
    }


    private static void setFeedOnCaseSync(Set<Id> caseIds) {
        List<FeedItem> feedItems = new List<FeedItem>();
        List<Case> cases = getCasesByIds(caseIds);
        Set<String> caseOriginMetadata = new Set<string>();

        for (Case_Description_Origin_Settings__mdt mdt : [SELECT Id,Origin__c,Active__c FROM Case_Description_Origin_Settings__mdt WHERE Active__c = TRUE]) {
            caseOriginMetadata.add(mdt.Origin__c);
        }
        for (Case aCase : cases) {
            if (String.isNotBlank(aCase.Origin)
                    && String.isNotBlank(aCase.Description)
                    && caseOriginMetadata != null
                    && !caseOriginMetadata.isEmpty()
                    && caseOriginMetadata.contains(aCase.Origin)) {
                FeedItem post = new FeedItem();
                post.ParentId = aCase.Id;
                post.Body = aCase.Description;
                feedItems.add(post);
            }
        }
        if (!feedItems.isEmpty()) {
            insert feedItems;
        }
    }


    private static List<Case> getCasesByIds(Set<Id> caseIds) {
        List<Case> cases = [
                SELECT Id, Origin, Description
                FROM Case
                WHERE Id IN :caseIds
        ];
        return cases;
    }

    public static void searchAndAssociateContact(List<Case> newList, Map<Id, Case> oldMAp) {
        Map<String, Contact> caseContactMap = new Map<String, Contact>();
        List<Case> caseList = new List<Case>();
        String cases;
        for (Case caseObj : newList) {
            if (oldMap == null && caseObj.Business_Unit__c != null && caseObj.Order_Number__c != null && caseObj.ContactId == null) {
                caseList.add(caseObj);
            } else if (oldMap != null && caseObj.Business_Unit__c != null && caseObj.Order_Number__c != null
                    && caseObj.ContactId == null && caseObj.Order_Number__c != oldMap.get(caseObj.Id).Order_Number__c) {
                caseList.add(caseObj);
            }
        }
        if(caseList!=null && !caseList.isEmpty()){
            cases = JSON.serialize(caseList);
            searchAndAssociateContactFromOrder(cases);
        }
    }

    @future(callout=true)
    public static void searchAndAssociateContactFromOrder(String caseList) {

        Map<String, String> caseMap = new Map <String, String>();
        List<Contact> webServiceContacts = new List<Contact>();
        Map<String, Contact> fetchedContacts = new Map<String, Contact>();
        Map<Id, Contact> mapToUpdate = new Map<Id, Contact>();
        List<String> businessUnitList = new List<String>();
        List<String> emailList = new List<String>();

        List<Case> cases = (List<Case>) JSON.deserialize(caseList, List<Case>.class);

        for (Case aCase : cases) {
            Contact contact = new Contact(Business_Unit__c = aCase.Business_Unit__c, Order_Number__c = aCase.Order_Number__c);

            contact = trac_WS_CustomerUtils.getContactFromOrderByContact(contact);
            if (contact != null) {
                contact.System_Origin__c = trac_ContactConstants.ORIGIN_OMS;
                contact.Latest_System_Update__c = trac_ContactConstants.ORIGIN_UCID;
                contact.OMS_Update_Date__c = Datetime.now();

                contact.OwnerId = UserInfo.getUserId();
                contact.RecordTypeId = trac_CaseConstants.RECORD_TYPE_ID_CUSTOMER_CONTACT;
            }

            if(contact!=null && String.isNotBlank(contact.Business_Unit__c) && String.isNotBlank(contact.Email)){
                businessUnitList.add(contact.Business_Unit__c);
                emailList.add(contact.Email);
                webServiceContacts.add(contact);
                caseMap.put(contact.Business_Unit__c + contact.Email, aCase.Id);
            }
        }

        fetchedContacts = searchContactByBUAndEmail(businessUnitList,emailList);

        if(webServiceContacts!=null && !webServiceContacts.isEmpty()){
            for (Contact con : webServiceContacts) {
                if (fetchedContacts!=null && fetchedContacts.containsKey(con.Business_Unit__c + con.Email)) {
                    mapToUpdate.put(caseMap.get(con.Business_Unit__c + con.Email), fetchedContacts.get(con.Business_Unit__c + con.Email));
                } else {
                    mapToUpdate.put(caseMap.get(con.Business_Unit__c + con.Email), con);
                }
            }
        }


        if (mapToUpdate!=null && !mapToUpdate.isEmpty()) {
            upsert mapToUpdate.values();
            List<Case> updateCases = new List<Case>();
            for (Case aCase : cases) {
                // update a fresh instance of Case with limited properties, because the one from the JSON is stale
                //   (i.e. OwnerId has changed due to case assignment rules)
                updateCases.add(new Case(Id=aCase.Id, ContactId=mapToUpdate.get(aCase.Id).Id));
            }
            update updateCases;
        }


    }

    public static Map<String, Contact> searchContactByBUAndEmail(List<String> businessUnitList, List<String> emailList){
        Map<String, Contact> fetchedContacts = new Map<String, Contact>();
        if(businessUnitList!=null && !businessUnitList.isEmpty() && emailList!=null && !emailList.isEmpty()){
            for (Contact con : [SELECT Id,Business_Unit__c,Email FROM Contact WHERE Business_Unit__c IN :businessUnitList AND email IN :emailList]) {
                fetchedContacts.put(con.Business_Unit__c + con.Email, con);
            }
        }

        if(fetchedContacts!=null && !fetchedContacts.isEmpty()){
            return fetchedContacts;
        }else{
            return null;
        }
    }

}