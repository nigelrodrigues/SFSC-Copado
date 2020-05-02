/**
 *  @description Order Refund Credit Trigger Handler, contains methods called by the ORC trigger
 *  @author      Jeremy Horan, Traction on Demand.
 *  @date        8/9/2019
 */
public without sharing class trac_OrderRefundCreditHelper {

    /**
     * @description Flag case if the ORCs are open
     * @param       newOrderRefundCredits, List of new ORC records
     *              oldOrderRefundCreditsByIds, Map of Id vs old ORC records
     * @return      void
     */
    public static void flagCaseIfOpenORC(List<Order_Refund_Credit__c> newOrderRefundCredits, Map<Id, Order_Refund_Credit__c> oldOrderRefundCreditsByIds){
        List<Case> casesToUpdate = new List<Case>();
        try{
            for(Order_Refund_Credit__c orderRefundCredit : newOrderRefundCredits){
                if(String.isNotBlank(orderRefundCredit.ORC_Status__c) && (oldOrderRefundCreditsByIds.isEmpty() || orderRefundCredit.ORC_Status__c != oldOrderRefundCreditsByIds.get(orderRefundCredit.Id).ORC_Status__c)){
                    Case cse = new Case();
                    cse.Id = orderRefundCredit.Case__c;
                    if(orderRefundCredit.ORC_Status__c.equals(trac_OrderRefundCreditConstants.STATUS_REQUIRES_APPROVAL) ||
                                    orderRefundCredit.ORC_Status__c.equals(trac_OrderRefundCreditConstants.STATUS_APPROVED) ||
                                    orderRefundCredit.ORC_Status__c.equals(trac_OrderRefundCreditConstants.STATUS_NEW) ||
                                    orderRefundCredit.ORC_Status__c.equals(trac_OrderRefundCreditConstants.STATUS_IN_PROGRESS))
                    {
                        cse.Is_ORC_Open__c = true;
                    }else{
                        cse.Is_ORC_Open__c = false;
                    }
                    casesToUpdate.add(cse);
                }
            }

            if(casesToUpdate!=null && !casesToUpdate.isEmpty()){
                update casesToUpdate;
            }
        }catch(Exception err){
            System.debug(err.getMessage() + '\n' + err.getStackTraceString());
        }
    }

    /**
     * @description Close Case Based on ORC being Closed
     * @param       newOrderRefundCredits, List of new ORC records
     *              oldOrderRefundCreditsByIds, Map of Id vs old ORC records
     * @return      void
     */
    public static void closeCase(List<Order_Refund_Credit__c> newOrderRefundCredits, Map<Id, Order_Refund_Credit__c> oldOrderRefundCreditsByIds){
        Set<Id> caseIdSet = new Set<Id>();
        List<Case> casesToClose = new List<Case>();
        List<String> orcStatusList = new List<String>{trac_OrderRefundCreditConstants.STATUS_REQUIRES_APPROVAL, trac_OrderRefundCreditConstants.STATUS_DECLINED, trac_OrderRefundCreditConstants.STATUS_DRAFT};
        try{
            for(Order_Refund_Credit__c orderRefundCredit : newOrderRefundCredits){
                if(String.isNotBlank(orderRefundCredit.ORC_Status__c) && orderRefundCredit.ORC_Status__c.equals(trac_OrderRefundCreditConstants.STATUS_CLOSED) && (oldOrderRefundCreditsByIds.isEmpty() || orderRefundCredit.ORC_Status__c != oldOrderRefundCreditsByIds.get(orderRefundCredit.Id).ORC_Status__c)){
                    caseIdSet.add(orderRefundCredit.Case__c);
                }
            }
            for(Order_Refund_Credit__c orc : [SELECT Id,ORC_Status__c,Case__c FROM Order_Refund_Credit__c WHERE ORC_Status__c NOT IN : orcStatusList AND Case__c IN :caseIdSet]){
                if(String.isNotBlank(orc.ORC_Status__c) && !orc.ORC_Status__c.equals(trac_OrderRefundCreditConstants.STATUS_CLOSED)){
                    caseIdSet.remove(orc.Case__c);
                }
            }
            for(Id caseId : caseIdSet){
                Case caseRec = new Case();
                caseRec.Id = caseId;
                caseRec.Status = trac_CaseConstants.STATUS_CLOSED;
                casesToClose.add(caseRec);
            }

            if(casesToClose!=null && !casesToClose.isEmpty()){
                update casesToClose;
            }
    }catch(Exception err){
            System.debug(err.getMessage() + '\n' + err.getStackTraceString());
        }
    }

    /**
     * @description Post comment on parent case with Transaction number
     * @param       newOrderRefundCreditsByIds, Map of Id vs new ORC records
     * @return      void
     */
    public static void postOnParentCase(Map<Id, Order_Refund_Credit__c> newOrderRefundCreditsByIds, Map<Id, Order_Refund_Credit__c> oldOrderRefundCreditsByIds){
        List<FeedItem> feedItems = new List<FeedItem>();
        try{
            for(Id orcId : newOrderRefundCreditsByIds.keySet()){
                if(!TLTrigger.wasRecordProcessed(orcId, 'postOnParentCase')){
                    if(String.isNotBlank(newOrderRefundCreditsByIds.get(orcId).ORC_Status__c) && newOrderRefundCreditsByIds.get(orcId).ORC_Status__c.equals(trac_OrderRefundCreditConstants.STATUS_CLOSED) && String.isNotBlank(newOrderRefundCreditsByIds.get(orcId).Transaction_Number__c) && (newOrderRefundCreditsByIds.get(orcId).ORC_Status__c != oldOrderRefundCreditsByIds.get(orcId).ORC_Status__c || newOrderRefundCreditsByIds.get(orcId).Transaction_Number__c!= oldOrderRefundCreditsByIds.get(orcId).Transaction_Number__c)){
                        String bodyFromLabel = Label.Refund_Processed;
                        bodyFromLabel = bodyFromLabel.replace('{Name}', newOrderRefundCreditsByIds.get(orcId).Name);
                        bodyFromLabel = bodyFromLabel.replace('{Transaction_Number__c}', newOrderRefundCreditsByIds.get(orcId).Transaction_Number__c);
                        bodyFromLabel = bodyFromLabel.replace('{Amount_to_Refund__c}', String.valueOf(newOrderRefundCreditsByIds.get(orcId).Amount_to_Refund__c));
                        FeedItem post = new FeedItem();
                        post.ParentId = newOrderRefundCreditsByIds.get(orcId).Case__c;
                        post.Body = bodyFromLabel;
                        feedItems.add(post);
                        TLTrigger.addRecordProcess(orcId, 'postOnParentCase');
                    }
                }
            }

            if(feedItems!=null && !feedItems.isEmpty()){
                insert feedItems;
            }
        }catch(Exception err){
            System.debug(err.getMessage() + '\n' + err.getStackTraceString());
        }
    }


    public static void setCaseStatus(List<Order_Refund_Credit__c> newOrderRefundCredits, Map<Id, Order_Refund_Credit__c> oldOrderRefundCreditsByIds) {
        Map<String, Set<Id>> caseIdsByStatus = new Map<String, Set<Id>>();

        for (Order_Refund_Credit__c newOrderRefundCredit : newOrderRefundCredits) {
            if (!TLTrigger.wasRecordProcessed(newOrderRefundCredit.Id, 'setCaseStatus')) {

                Order_Refund_Credit__c oldOrderRefundCredit;
                if (oldOrderRefundCreditsByIds.containsKey(newOrderRefundCredit.Id)) {
                    oldOrderRefundCredit = oldOrderRefundCreditsByIds.get(newOrderRefundCredit.Id);
                }

                if (newOrderRefundCredit.Case__c != null && (oldOrderRefundCredit == null || oldOrderRefundCredit.ORC_Status__c != newOrderRefundCredit.ORC_Status__c)) {
                    if (!caseIdsByStatus.containsKey(newOrderRefundCredit.ORC_Status__c)) {
                        caseIdsByStatus.put(newOrderRefundCredit.ORC_Status__c, new Set<Id>());
                    }
                    caseIdsByStatus.get(newOrderRefundCredit.ORC_Status__c).add(newOrderRefundCredit.Case__c);
                }
            }
        }

        if (!caseIdsByStatus.isEmpty()) {
            filterAndUpdateCases(caseIdsByStatus);
        }
    }

    public static void setApprovedBy(List<Order_Refund_Credit__c> newOrderRefundCredits, Map<Id, Order_Refund_Credit__c> oldOrderRefundCreditsByIds) {
        for (Order_Refund_Credit__c newOrderRefundCredit : newOrderRefundCredits) {

            Order_Refund_Credit__c oldOrderRefundCredit;
            if (oldOrderRefundCreditsByIds.containsKey(newOrderRefundCredit.Id)) {
                oldOrderRefundCredit = oldOrderRefundCreditsByIds.get(newOrderRefundCredit.Id);
            }

            if (newOrderRefundCredit.ORC_Status__c == trac_OrderRefundCreditConstants.STATUS_APPROVED && (oldOrderRefundCredit == null || oldOrderRefundCredit.ORC_Status__c != newOrderRefundCredit.ORC_Status__c)) {
                newOrderRefundCredit.Approved_By__c = UserInfo.getUserId();
            }
        }
    }

    private static void filterAndUpdateCases(Map<String, Set<Id>> caseIdsByStatus) {
        List<Case> casesToUpdate = new List<Case>();

        if (!caseIdsByStatus.isEmpty()) {
            Set<Id> caseIdsToQuery = new Set<Id>();
            List<Order_Refund_Credit_Case_Status_Setting__mdt> orderRefundCreditCaseStatusSettings = getOrderRefundCreditCaseStatusSettingsByStatus(caseIdsByStatus.keySet(), 'Set Case Status');

            for (Order_Refund_Credit_Case_Status_Setting__mdt orderRefundCreditCaseStatusSetting : orderRefundCreditCaseStatusSettings) {
                if (caseIdsByStatus.containsKey(orderRefundCreditCaseStatusSetting.Status__c)) {
                    caseIdsToQuery.addAll(caseIdsByStatus.get(orderRefundCreditCaseStatusSetting.Status__c));
                }
            }

            if (!caseIdsToQuery.isEmpty()) {
                Map<Id, List<Order_Refund_Credit__c>> orderRefundCreditsByCaseIds = new Map<Id, List<Order_Refund_Credit__c>>();
                List<Order_Refund_Credit__c> orderRefundCredits = getOrderRefundCreditsByCaseIds(caseIdsToQuery);

                for (Order_Refund_Credit__c orderRefundCredit : orderRefundCredits) {
                    if (!orderRefundCreditsByCaseIds.containsKey(orderRefundCredit.Case__c)) {
                        orderRefundCreditsByCaseIds.put(orderRefundCredit.Case__c, new List<Order_Refund_Credit__c>());
                    }
                    orderRefundCreditsByCaseIds.get(orderRefundCredit.Case__c).add(orderRefundCredit);
                }

                for (Id caseId : orderRefundCreditsByCaseIds.keySet()) {
                    String caseStatus = getStatusFromOrderRefundCredits(orderRefundCreditsByCaseIds.get(caseId));
                    if (caseStatus != null) {
                        Case caseToUpdate = new Case(Id = caseId, Status = caseStatus);

                        caseToUpdate.Trigger_Approval_Override__c = caseStatus == trac_CaseConstants.STATUS_POS_TEAM;

                        casesToUpdate.add(caseToUpdate);
                        TLTrigger.addRecordProcess(caseId, 'setCaseStatus');
                    }
                }
            }
        }

        if (!casesToUpdate.isEmpty()) {
            update casesToUpdate;
        }
    }

    private static String getStatusFromOrderRefundCredits(List<Order_Refund_Credit__c> orderRefundCredits) {
        String status;

        Boolean hasNoDeclinedStatuses = true;
        for (Order_Refund_Credit__c orderRefundCredit : orderRefundCredits) {
            if (orderRefundCredit.ORC_Status__c == trac_OrderRefundCreditConstants.STATUS_DECLINED) {
                hasNoDeclinedStatuses = false;
                break;
            }
        }

        status = (hasNoDeclinedStatuses) ? trac_CaseConstants.STATUS_POS_TEAM : trac_CaseConstants.STATUS_TEAM_ASSISTANCE_NEEDED;

        return status;
    }

    private static List<Order_Refund_Credit_Case_Status_Setting__mdt> getOrderRefundCreditCaseStatusSettingsByStatus(Set<String> orderRefundCreditStatuses, String process) {
        List<Order_Refund_Credit_Case_Status_Setting__mdt> orderRefundCreditCaseStatusSettings = [
                SELECT Id, Status__c
                FROM Order_Refund_Credit_Case_Status_Setting__mdt
                WHERE Enabled__c = true AND Object__c = 'Order Refund Credit' AND Status__c IN :orderRefundCreditStatuses AND Process__c = :process
        ];
        return orderRefundCreditCaseStatusSettings;
    }

    private static List<Order_Refund_Credit__c> getOrderRefundCreditsByCaseIds(Set<Id> caseIds) {
        List<Order_Refund_Credit__c> orderRefundCreditCaseStatusSettings = [
                SELECT Id, Case__c, ORC_Status__c, Approval_Required__c
                FROM Order_Refund_Credit__c
                WHERE Case__c IN :caseIds
        ];
        return orderRefundCreditCaseStatusSettings;
    }
}