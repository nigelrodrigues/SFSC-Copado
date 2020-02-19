/**
 * Utilities for List processing and generation
 * @author Grant Adamson, Traction on Demand
 * @date 2017-05-01
 * @group TLList
 */
public class TLList {
    /**
     * Extracts Id values from source, for the field provided
     * @param source    The list to retrieve values from
     * @param field     The field to read values from
     * @return      Set of Ids extracted from source
     */
    public static Set<Id> collectIds(List<SObject> source, SObjectField field) {
        return collectIdsInternal(source, field);
    }

    /**
     * Extracts Id values from source, for the field provided
     * @param source : The list to retrieve values from
     * @param field : The field to read values from
     * @return      Set of Ids extracted from source
     */
    public static Set<Id> collectIds(List<SObject> source, String field) {
        return collectIdsInternal(source, field);
    }

    private static Set<Id> collectIdsInternal(List<SObject> source, Object field) {
        final Set<Id> result = new Set<Id>();

        Id value;
        for(SObject sobj : source) {
            value = (Id)TLShared.getFieldValue(sobj, field);

            if(value != null) {
                result.add(value);
            }
        }
        return result;
    }

    /**
    * Extracts String values from source, for the field provided
    * @param source    The list to retrieve values from
    * @param field     The field to read values from
    * @return      Set of Ids extracted from source
    */
    public static Set<String> collectStrings(List<SObject> source, SObjectField field) {
        return collectStringsInternal(source, field);
    }

    /**
    * Extracts String values from source, for the field provided
    * @param source    The list to retrieve values from
    * @param field     The field to read values from
    * @return      Set of Ids extracted from source
    */
    public static Set<String> collectStrings(List<SObject> source, String field) {
        return collectStringsInternal(source, field);
    }

    private static Set<String> collectStringsInternal(List<SObject> source, Object field) {
        final Set<String> result = new Set<String>();

        String value;
        for(SObject sobj : source) {
            value = (String)TLShared.getFieldValue(sobj, field);

            if(value != null) {
                result.add(value);
            }
        }
        return result;
    }

    /**
     * Combine a set of lists into a single set.
     * @param idSetLIst     The list of sets to combine.
     * @return              Set of Id containing all the Ids from the specified set list.
     */
    public static Set<Id> combineSetList(List<Set<Id>> idSetList) {
        final Set<Id> allIds = new Set<Id>();

        for (Set<Id> idSet : idSetList) {
            allIds.addAll(idSet);
        }

        allIds.remove(null);

        return allIds;
    }
}