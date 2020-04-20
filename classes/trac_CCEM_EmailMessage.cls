/**
 *  @description Email Message Trigger functionality
 *  @author      Jeremy Horan, Traction on Demand.
 *  @date        2016-12-23
 */
public with sharing class trac_CCEM_EmailMessage {
    /**
     *  @description Handles insert of EmailMessages
     *  @author      Tanminder Rai, Traction on Demand.
     *  @date        5/19/2016
     */
    public static void createNewCaseIfClosed(List<EmailMessage> emailMessages) {

        Closed_Case_Email_Handler_Settings__c closedCaseEmailHandlerSettings = Closed_Case_Email_Handler_Settings__c.getOrgDefaults();
        Integer hoursSinceClosed = (Integer) getHoursSinceClosed(closedCaseEmailHandlerSettings);
        Set<String> fieldsToQuery = getFieldsToQuery(closedCaseEmailHandlerSettings);

        Map<Id, EmailMessage> caseToEmailMsgMap = getCaseToEmailMsgMap(emailMessages);
        List<Case> parentCases = trac_CCEM_CaseSelector.getCasesByIds(caseToEmailMsgMap.keySet(), fieldsToQuery);

        //If the case is already closed, clone the case
        List<Case> casesToInsert = new List<Case>();
        for(Case pCase : parentCases) {
            if (pCase.IsClosed && pCase.ClosedDate != null && pCase.ClosedDate.addHours(hoursSinceClosed) <= Datetime.now()) {
                
                Case newCase = pCase.clone(false, true);
                newCase.ParentId = pCase.Id;

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

        try {
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
        } catch (Exception e) {
            Integration_Error__c integrationError = trac_IntegrationError.addError(new Integration_Error__c(
                    Description__c = e.getMessage() + '\n' + e.getStackTraceString(),
                    Service__c = 'Closed Case Email Message Trigger'
            ));
            insert integrationError;
        }
    }

    /**
     *  @description Pulls how long since the case was closed that should create a new case
     *  @author      Jeremy Horan, Traction on Demand.
     *  @date        4/30/2018
     */
    private static Decimal getHoursSinceClosed(Closed_Case_Email_Handler_Settings__c closedCaseEmailHandlerSettings) {
        Decimal hoursSinceClosed = 0;

        if (closedCaseEmailHandlerSettings != null && closedCaseEmailHandlerSettings.Hours_Since_Closed__c != null) {
            hoursSinceClosed = closedCaseEmailHandlerSettings.Hours_Since_Closed__c;
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
        for(EmailMessage em : emailMessages) {
            if (String.isNotBlank(em.ParentId) && em.Incoming) {
                caseToEmailMsgMap.put(em.ParentId, em);
            }
        }
        return caseToEmailMsgMap;
    }
}