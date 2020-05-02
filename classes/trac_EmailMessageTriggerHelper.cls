/**
* @description Helper for trac_EmailMessageTrigger
* @author      Piyush Bansal, Traction on Demand
* @date        2019-12-12
*/

public with sharing class trac_EmailMessageTriggerHelper {


    /**
    *  @description Check if incoming email from Saks customer, If true redirect mail to Case Steward
    *  @author      Abhishek Solanki, Traction on Demand.
    *  @date        02/28/2019
    */
    public static void redirectSaksMailsToSteward(List<EmailMessage> newEmailMessageList) {
        Set<String> fromAddressSet = new Set<String>();
        Set<Id> caseIdSet = new Set<Id>();
        for (EmailMessage emailMsg : newEmailMessageList) {
            if (emailMsg.Incoming && ((String) (emailMsg.ParentId)).startsWith('500')) {
                caseIdSet.add(emailMsg.ParentId);
            }
        }

        Map<Id, Case> idCaseMap = new Map<Id, Case>([SELECT Id,Keep_Ownership__c,RecordTypeId,Status,Case_Steward__c,Case_Steward__r.Email,OwnerId FROM Case WHERE Id IN:caseIdSet]);
        List<Messaging.SingleEmailMessage> MessageList = new List<Messaging.SingleEmailMessage>();

        if (idCaseMap != null && !idCaseMap.isEmpty()) {
            for (EmailMessage emailMsg : newEmailMessageList) {
                if (emailMsg.Incoming
                        && ((String) (emailMsg.ParentId)).startsWith('500')
                        && idCaseMap.containsKey(emailMsg.ParentId)
                        && idCaseMap.get(emailMsg.ParentId).Keep_Ownership__c
                        && idCaseMap.get(emailMsg.ParentId).Case_Steward__c != null
                        && idCaseMap.get(emailMsg.ParentId).OwnerId != null
                        && idCaseMap.get(emailMsg.ParentId).Case_Steward__c == idCaseMap.get(emailMsg.ParentId).OwnerId) {
                    MessageList.add(createEmailMessages(idCaseMap.get(emailMsg.ParentId).Case_Steward__r.Email,
                            emailMsg.Subject,
                            emailMsg.HtmlBody));

                }
            }

            if (!MessageList.isEmpty()){
                Messaging.sendEmail(MessageList);
            }
        }
    }

    public static Messaging.SingleEmailMessage createEmailMessages(String toEmail, String subject, String Body) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        String[] to = new String[]{
                toEmail
        };
        email.setToAddresses(to);
        email.setSubject(subject);
        email.setHtmlBody(Body);
        return email;
    }

    /**
*  @description Sort all the email message records associated with a case for deletion
*  @author      Piyush  Bansal, Traction on Demand.
*  @date        12/19/2019
*/
    public static void emailsOnCase(List<EmailMessage> newEmailMessageList) {
        Set<String> fromAddressSet = new Set<String>();
        for (EmailMessage emailMsg : newEmailMessageList) {
            if (emailMsg.Incoming && ((String) (emailMsg.ParentId)).startsWith('500')) {
                fromAddressSet.add(emailMsg.FromAddress);
            }
        }
        Datetime now = Datetime.now(); //Current DateTime
        deleteDuplicateEmailToCase(fromAddressSet, now.addMinutes(trac_CaseConstants.MINUTES));
    }

    /**
*  @description Deleting all cases created from same address within 5 minutes
*  @author      Piyush  Bansal, Traction on Demand.
*  @date        12/19/2019
*/
    @Future
    public static void deleteDuplicateEmailToCase(Set<String> fromAddressSet, Datetime fiveMinutesBefore) {

        Map<String, Case> checkCaseMap = new Map<String, Case>();
        List<Case> duplicateCases = new List<Case>();
        List<Case> casesWithin5Min = new List<Case>([
                SELECT Id,Origin,CaseNumber,SuppliedEmail,SuppliedName,Description,Subject
                FROM Case
                WHERE (CreatedDate >= :fiveMinutesBefore) AND (SuppliedEmail IN:fromAddressSet) AND ParentId = NULL
                ORDER BY CreatedDate ASC
        ]);

        for (Case checkCase : casesWithin5Min) {
            if (checkCaseMap.containsKey(checkCase.SuppliedEmail + '-' + checkCase.SuppliedName + '-' + checkCase.Subject + '-' + checkCase.Description)) {
                duplicateCases.add(checkCase);
            } else {
                checkCaseMap.put(checkCase.SuppliedEmail + '-' + checkCase.SuppliedName + '-' + checkCase.Subject + '-' + checkCase.Description, checkCase);
            }
        }
        //Deleting all Duplicate Cases within 5 min boundary time
        if (duplicateCases.size() > 0) {
            Database.DeleteResult[] results = Database.delete(duplicateCases, false) ;
        }
    }

    /**
*  @description Handles insert of EmailMessages
*  @author      Tanminder Rai, Traction on Demand.
*  @date        5/19/2016
*/
    public static void createNewCaseIfClosed(List<EmailMessage> emailMessages) {
        Closed_Case_Email_Handler_Settings__c closedCaseEmailHandlerSettings = Closed_Case_Email_Handler_Settings__c.getOrgDefaults();
        Integer hoursSinceClosedInt = (Integer) getHoursSinceClosedInt(closedCaseEmailHandlerSettings);
        Integer hoursSinceClosedExt = (Integer) getHoursSinceClosedExt(closedCaseEmailHandlerSettings);

        // Integer hoursSinceClosed=
        Set<String> fieldsToQuery = getFieldsToQuery(closedCaseEmailHandlerSettings);
        Map<Id, Integer> caseHoursMap = new Map<Id, Integer>();
        //fetching metadata
        List<Case_Origin_Mapping_Settings__mdt> caseMappingMetaDataList = [SELECT Business_Unit__c, Case_Origin__c, Inbound_Email_Address__c, Is_Default__c FROM Case_Origin_Mapping_Settings__mdt];
        Map<Id, String> caseIdToCaseOriginMap = new Map<Id, String>();
        Map<Id, EmailMessage> caseToEmailMsgMap = getCaseToEmailMsgMap(emailMessages);
        Map<String, String> caseOriginMetadataAddressMap = getCaseOriginMetadataAddressMap();
        Map<String, String> caseOriginMetadataBUMap = getCaseOriginMetadataBUMap();

        for (EmailMessage em : caseToEmailMsgMap.values()) {
            if (em.FromAddress != null && em.FromAddress.contains('hbc.com')) {
                caseHoursMap.put(em.ParentId, hoursSinceClosedInt);
            } else {
                caseHoursMap.put(em.ParentId, hoursSinceClosedExt);
            }

            for (String emailAddress : caseOriginMetadataAddressMap.keySet()) {
                if (em.ToAddress != null && em.ToAddress.contains(emailAddress)) {
                    caseIdToCaseOriginMap.put(em.ParentId, caseOriginMetadataAddressMap.get(emailAddress));
                }
            }
        }

        List<Case> parentCases = trac_CCEM_CaseSelector.getCasesByIds(caseToEmailMsgMap.keySet(), fieldsToQuery);
        for (Case pCase : parentCases) {
            if (!caseIdToCaseOriginMap.containsKey(pCase.Id)) {
                for (String mdBusinessUnit : caseOriginMetadataBUMap.keySet()) {
                    if (mdBusinessUnit != '' && pCase.Business_Unit__c != null && pCase.Business_Unit__c.equals(mdBusinessUnit) && caseOriginMetadataBUMap != null) {
                        caseIdToCaseOriginMap.put(pCase.Id, caseOriginMetadataBUMap.get(mdBusinessUnit));
                    }
                }
            }
        }
        //If the case is already closed, clone the case
        List<Case> casesToInsert = new List<Case>();

        for (Case pCase : parentCases) {

            if (caseHoursMap.containsKey(pCase.Id)) {
                if (pCase.IsClosed && pCase.ClosedDate != null && pCase.ClosedDate.addHours(caseHoursMap.get(pCase.Id)) <= Datetime.now()) {
                    Case newCase = pCase.clone(false, true);
                    newCase.ParentId = pCase.Id;
                    if (caseIdToCaseOriginMap.containsKey(pCase.Id)) {
                        newCase.Origin = caseIdToCaseOriginMap.get(pCase.Id);
                    } else {
                        newCase.Origin = 'Email - Store Operation';

                    }

                    if (closedCaseEmailHandlerSettings != null && closedCaseEmailHandlerSettings.Default_Status__c != null) {
                        newCase.Status = closedCaseEmailHandlerSettings.Default_Status__c;
                    }

                    if (closedCaseEmailHandlerSettings != null && closedCaseEmailHandlerSettings.Re_Run_Assignment_Rules__c) {
                        Database.DMLOptions dmlOptions = new Database.DMLOptions();
                        dmlOptions.assignmentRuleHeader.useDefaultRule = true;
                        newCase.setOptions(dmlOptions);
                    }

                    casesToInsert.add(newCase);
                }
            }
        }
        if (casesToInsert.size() > 0) {
            insert casesToInsert;
        }
        //Re-parent the email message to the new case
        for (Case newCase : casesToInsert) {
            EmailMessage em = caseToEmailMsgMap.get(newCase.ParentId);
            em.ParentId = newCase.Id;
            if (em.HtmlBody != null) {
                em.HtmlBody = em.HtmlBody.replaceAll(newCase.Id, newCase.ParentId);
            }
            if (em.TextBody != null) {
                em.TextBody = em.TextBody.replaceAll(newCase.Id, newCase.ParentId);
            }
        }
    }

    /**
*  @description Pulls how long since the case was closed that should create a new case
*  @author      Jeremy Horan, Traction on Demand.
*  @date        4/30/2018
*/
    private static Decimal getHoursSinceClosedInt(Closed_Case_Email_Handler_Settings__c closedCaseEmailHandlerSettings) {
        Decimal hoursSinceClosed = 0;

        if (closedCaseEmailHandlerSettings != null && closedCaseEmailHandlerSettings.Hours_Since_Closed_Internal__c != null) {
            hoursSinceClosed = closedCaseEmailHandlerSettings.Hours_Since_Closed_Internal__c;
        }

        return hoursSinceClosed;
    }

    private static Decimal getHoursSinceClosedExt(Closed_Case_Email_Handler_Settings__c closedCaseEmailHandlerSettings) {
        Decimal hoursSinceClosed = 0;

        if (closedCaseEmailHandlerSettings != null && closedCaseEmailHandlerSettings.Hours_Since_Closed_External__c != null) {
            hoursSinceClosed = closedCaseEmailHandlerSettings.Hours_Since_Closed_External__c;
        }

        return hoursSinceClosed;
    }
    /**
*  @description Adds fields from the custom setting to be cloned to the new cases
*  @author      Jeremy Horan, Traction on Demand.
*  @date        4/3/2019
*/
    private static Set<String> getFieldsToQuery(Closed_Case_Email_Handler_Settings__c closedCaseEmailHandlerSettings) {
        Set<String> fieldsToQuery = new Set<String>();

        if (closedCaseEmailHandlerSettings != null && closedCaseEmailHandlerSettings.Fields_To_Clone__c != null) {
            List<String> fields = closedCaseEmailHandlerSettings.Fields_To_Clone__c.remove(' ').split(',');

            for (String field : fields) {
                fieldsToQuery.add(field);
            }
        }
        return fieldsToQuery;
    }


    /**
    *  @description Get a Map of case Ids to email messages
    *  @author      Tanminder Rai, Traction on Demand.
    *  @date        2016-12-23
    */
    private static Map<Id, EmailMessage> getCaseToEmailMsgMap(List<EmailMessage> emailMessages) {
        Map<Id, EmailMessage> caseToEmailMsgMap = new Map<Id, EmailMessage>();
        for (EmailMessage em : emailMessages) {
            if (String.isNotBlank(em.ParentId) && em.Incoming) {
                caseToEmailMsgMap.put(em.ParentId, em);
            }

        }
        return caseToEmailMsgMap;
    }
    /**
     * @description Get a Map of Email Address to Case Origin from Custom Metadata
     * @author      Piyush Bansal, Traction on Demand.
     * @date        2019-03-05
     */
    private static Map<String, String> getCaseOriginMetadataAddressMap() {
        Map<String, String> caseOriginMetadataAddressMap = new Map<String, String>();
        for (Case_Origin_Mapping_Settings__mdt md : [SELECT Business_Unit__c, Case_Origin__c, Inbound_Email_Address__c, Is_Default__c FROM Case_Origin_Mapping_Settings__mdt]) {
            if (md.Inbound_Email_Address__c != null) {
                caseOriginMetadataAddressMap.put(md.Inbound_Email_Address__c, md.Case_Origin__c);
            }
        }
        return caseOriginMetadataAddressMap;
    }

    /**
     * @description Get a Map of Business Unit to Case Origin from Custom Metadata
     * @author      Piyush Bansal, Traction on Demand.
     * @date        2019-03-05
     */
    private static Map<String, String> getCaseOriginMetadataBUMap() {
        Map<String, String> caseOriginMetadataBUMap = new Map<String, String>();
        for (Case_Origin_Mapping_Settings__mdt md : [SELECT Business_Unit__c, Case_Origin__c, Inbound_Email_Address__c, Is_Default__c FROM Case_Origin_Mapping_Settings__mdt]) {
            if (md.Business_Unit__c != null && md.Is_Default__c) {
                caseOriginMetadataBUMap.put(md.Business_Unit__c, md.Case_Origin__c);
            }
        }
        return caseOriginMetadataBUMap;
    }
}