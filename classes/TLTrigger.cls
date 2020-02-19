/**
 * Utility methods for trigger processing
 * @author Grant Adamson, Traction on Demand
 * @date 2017-05-01
 * @group TLTrigger
 */
public class TLTrigger {

    private static Map<Id, Set<String>> processesByRecordIds = new Map<Id, Set<String>>();

    /**
     *  @description Checks if a record has already gone through the process provided in execution context
     *  @author      Jeremy Horan, Traction on Demand.
     *  @date        10/19/2018
     *  @param       recordId    Record Id to check
     *  @param       processName Process to check
     */
    public static Boolean wasRecordProcessed(Id recordId, String processName) {
        Boolean wasProcessed = false;

        if (processesByRecordIds.containsKey(recordId)
                && processesByRecordIds.get(recordId).contains(processName)) {
            wasProcessed = true;
        }

        return wasProcessed;
    }

    /**
     *  @description Adds a process that has been run on the record in execution context
     *  @author      Jeremy Horan, Traction on Demand.
     *  @date        10/19/2018
     *  @param       recordId    Record Id to add
     *  @param       processName Process to add
     */
    public static void addRecordProcess(Id recordId, String processName) {
        if (!processesByRecordIds.containsKey(recordId)) {
            processesByRecordIds.put(recordId, new Set<String>());
        }
        processesByRecordIds.get(recordId).add(processName);
    }

    /**
     * Given a list of SObjects, their corresponding "oldMap" values, and a field, return only the records where
     * the field value is different
     * @param   records         List of SObject from Trigger.new or equivalent
     * @param   existingRecords Map of Id to SObject, from Trigger.oldMap or equivalent
     * @param   field           SObjectField to compare values on
     * @return                  Filtered list of SObjects
     */
    public static List<SObject> filterByFieldChanged(List<SObject> records, Map<Id, SObject> existingRecords,
            SObjectField field) {

        return filterByFieldChangedInternal(records, existingRecords, field);
    }

    /**
     * Given a list of SObjects, their corresponding "oldMap" values, and a field, return only the records where
     * the field value is different
     * @param   records         List of SObject from Trigger.new or equivalent
     * @param   existingRecords Map of Id to SObject, from Trigger.oldMap or equivalent
     * @param   field           SObjectField to compare values on
     * @return                  Filtered list of SObjects
     */
    public static List<SObject> filterByFieldChanged(List<SObject> records, Map<Id, SObject> existingRecords,
            String field) {

        return filterByFieldChangedInternal(records, existingRecords, field);
    }

    private static List<SObject> filterByFieldChangedInternal(List<SObject> records, Map<Id, SObject> existingRecords,
            Object field) {

        final List<SObject> filteredList = new List<SObject>();

        SObject existing;
        for(SObject sobj : records) {
            existing = existingRecords.get(sobj.Id);

            if(isFieldChanged(sobj, existing, field)) {
                filteredList.add(sobj);
            }
        }

        return filteredList;
    }

    private static Boolean isFieldChanged(SObject sobj, SObject existing, Object field) {
        return TLShared.getFieldValue(sobj, field) != TLShared.getFieldValue(existing, field);
    }

    public static List<SObject> filterByFieldsChanged(List<SObject> records, Map<Id, SObject> existingRecords,
            List<String> fields) {

        return filterByFieldsChangedInternal(records, existingRecords, fields);
    }

    private static List<SObject> filterByFieldsChangedInternal(List<SObject> records, Map<Id, SObject> existingRecords,
            List<Object> fields) {

        final List<SObject> filteredList = new List<SObject>();

        SObject existing;
        for(SObject sobj : records) {
            if (existingRecords != null) {
                existing = existingRecords.get(sobj.Id);
            }

            for (Object field : fields) {
                if(isFieldChanged(sobj, existing, field)) {
                    filteredList.add(sobj);
                    break;
                }
            }
        }

        return filteredList;
    }
}