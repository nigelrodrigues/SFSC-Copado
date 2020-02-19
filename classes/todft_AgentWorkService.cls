/**
 * @author Rishabh Garg, Traction on Demand 
 * @date 2019-01-02
 */
public with sharing class todft_AgentWorkService {

    /**
     * @description update the sobject owner through omni channel route configuration and assignment rule
     * @param agentWorkRecords - Records being processed
     */
    public static void updateOwnerOfRecords(List<SObject> agentWorkRecords, Map<Id, SObject> oldAgentWorkMap){

        if(agentWorkRecords != null && !agentWorkRecords.isEmpty()){
            //This map will store sobject name associated to set of sobject record Ids
            //that agent is working on (i.e. WorkItemId)  in omni channel
            Map<String, Set<Id>> sObjectNameToSetOfRecordIdsMap = new Map<String, Set<Id>>();
            for(SObject record : agentWorkRecords){
                if(String.valueOf(record.get('Status')) == 'Assigned' && String.valueOf(record.get('WorkItemId')) != null){
                    Id objectRecordId = (Id)record.get('WorkItemId');
                    String sObjName = objectRecordId.getSObjectType().getDescribe().getName();
                    if(String.isNotBlank(sObjName)){
                        if(!sObjectNameToSetOfRecordIdsMap.containsKey(sObjName)){
                            sObjectNameToSetOfRecordIdsMap.put(sObjName, new Set<Id>());
                        }
                        sObjectNameToSetOfRecordIdsMap.get(sObjName).add(objectRecordId);
                    }
                }
            }
            if(sObjectNameToSetOfRecordIdsMap != null && !sObjectNameToSetOfRecordIdsMap.isEmpty()){
                List<SObject> parentRecordList = new List<SObject>();
                Map<String, List<Field_Tracker_Mapping__mdt>> settingsByObject = new Map<String, List<Field_Tracker_Mapping__mdt>>();
                Map<String, Set<String>> fieldMappingsByObject = new Map<String, Set<String>>();
                settingsByObject = todft_FieldLoggerUtils.settingsByObject;
                fieldMappingsByObject = todft_FieldLoggerUtils.fieldMappingsByObject;
                //Since there may be a case when an agent can be assigned to multiple records, may be of different sobject
                //so we filled the map with sObject name related to set of Sobject record Ids and track the changes done
                //through omni channel assignment. Hence we were forced to query inside loop (iterating over map) and
                //get the updated record so that we can manage or track recently done changes/updation via omni channel assignment.
                for(String objectName : sObjectNameToSetOfRecordIdsMap.keySet()){
                    if(sObjectNameToSetOfRecordIdsMap.get(objectName) != null && !sObjectNameToSetOfRecordIdsMap.get(objectName).isEmpty()){
                        List<Id> objectRecordList = new List<Id>();
                        objectRecordList.addAll(sObjectNameToSetOfRecordIdsMap.get(objectName));
                        List<String> objectFieldsToTrack = new List<String>();
                        if(fieldMappingsByObject.get(objectName) == null){
                            return;
                        }

                        objectFieldsToTrack.addAll(fieldMappingsByObject.get(objectName));
                        String query = 'SELECT Id, OwnerId, Owner.Name';
                        if(objectFieldsToTrack != null && !objectFieldsToTrack.isEmpty()){
                            String fieldsFromMetadata = String.join(objectFieldsToTrack, ',');
                            query += ', ' + fieldsFromMetadata;
                        }
                        query += ' FROM ' + objectName + ' Where Id IN ';
                        query += ':objectRecordList';
                        List<SObject> records = Database.query(query);
                        if(records != null && !records.isEmpty()){
                            parentRecordList.addAll(records);
                        }
                    }
                }
                if(parentRecordList != null && !parentRecordList.isEmpty()){
                    //Here also we called the method inside loop
                    //as we have to track the changes of the parent object and create/update record of the respective time log object
                    //(i.e. make an entry in the time log object if there is any field update in parent object
                    //during omni channel assignment)
                    for(String objectName : sObjectNameToSetOfRecordIdsMap.keySet()){
                        todft_FieldLogger.executeForWorkAgent(objectName, parentRecordList, true);
                    }
                }
            }
        }
    }
}