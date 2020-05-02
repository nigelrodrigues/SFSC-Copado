/**
* @Name trac_CaseProcessBatchHelper
* @Author Piyush Bansal, Traction on Demand
* @Date January 1, 2019
*
* @Description Helper class for trac_CaseProcessBatch
*/
public class trac_CaseProcessBatchHelper {

    public static void closeNonResponsiveCases(List<Case> cases) {
        for (Case cs : cases) {
            cs.Status = trac_CaseConstants.STATUS_NON_RESPONSIVE_CUSTOMER;
        }
        update cases;
    }

    public static void flagInactiveCases(List<Case> cases) {
        for (Case cs : cases) {
            cs.No_Activity_on_Case__c = true;
        }
        update cases;
    }

    public static void reAssignUserIdToManagerQueue(List<Case> cases) {
        Map<String, String> ownerIdToQueueIdMap = getUserIdToQueueIdMap(cases);
        for (Case cs : cases) {
            if (ownerIdToQueueIdMap.containsKey(cs.Case_Owner_Supervisor_ID__c)) {
                cs.OwnerId = ownerIdToQueueIdMap.get(cs.Case_Owner_Supervisor_ID__c);
                cs.Follow_Up_Misses__c = cs.Follow_Up_Misses__c == null ? 1 : (cs.Follow_Up_Misses__c + 1);
            }
        }
        update cases;
    }

    private static Map<String, String> getUserIdToQueueIdMap(List<Case> cases) {
        Set<String> ownerIdSet = new Set<String>();
        Map<String, String> ownerIdToQueueIdMap = new Map<String, String> ();
        Map<String, List<String>> ownerIdToGroupIdMap = new Map<String, List<String>> ();
        for (Case cs : cases) {
            ownerIdSet.add(cs.Case_Owner_Supervisor_ID__c);
        }
        //get associated groups
        for (GroupMember grpMember : [SELECT GroupId, UserOrGroupId FROM GroupMember WHERE UserOrGroupId IN:ownerIdSet AND Group.Type = 'Regular' AND GroupId != NULL]) {
            String userOrGroupId = String.valueOf(grpMember.UserOrGroupId).left(15);
            if (!ownerIdToGroupIdMap.containsKey(grpMember.GroupId)) {
                ownerIdToGroupIdMap.put(grpMember.GroupId, new List<String>());
            }
            ownerIdToGroupIdMap.get(grpMember.GroupId).add(userOrGroupId);
        }

        for (GroupMember grpMember : [
                SELECT GroupId, UserOrGroupId, Group.Type
                FROM GroupMember
                WHERE (UserOrGroupId IN:ownerIdSet OR UserOrGroupId IN:ownerIdToGroupIdMap.keySet()) AND Group.Type = 'Queue' AND GroupId != NULL
        ]) {

            String userOrGroupId = String.valueOf(grpMember.UserOrGroupId).left(15);

            if (ownerIdToGroupIdMap.containsKey(grpMember.UserOrGroupId)) {
                for (String users : ownerIdToGroupIdMap.get(grpMember.UserOrGroupId)) {
                    ownerIdToQueueIdMap.put(users, grpMember.GroupId);
                }
            } else if (ownerIdSet.contains(grpMember.UserOrGroupId)) {
                ownerIdToQueueIdMap.put(userOrGroupId, grpMember.GroupId);
            }
        }
        return ownerIdToQueueIdMap;
    }
}