/**
 * Utility methods for manipulating SObjects
 * @author Grant Adamson, Traction on Demand
 * @date 2017-08-01
 * @modified Jeremy Horan, Traction on Demand - 2018-11-07
 * @group TLSObj
 */
public class TLSObj {
    private static final String INVALID_RT_FOR_SOBJ_MSG = 'Invalid record type name "{0}" for SObject type "{1}"';

    /**
     * Given a source object, destination object, and a map of Destination to Source SObjectField, copy the values from
     * the source object to the destination. NOTE: Does not perform type checking; field types must be compatible
     * @param srcObj    Source SObject
     * @param destObj   Destination SObject
     * @param fieldMap  Map of SObjectField => SObjectField. SOURCE field is the key, DESTINATION field is the value
     */
    public static void copyUsingMapping(SObject srcObj, SObject destObj, Map<SObjectField, SObjectField> fieldMap) {
        SObjectField destField;
        for(SObjectField srcField : fieldMap.keySet()) {
            destField = fieldMap.get(srcField);

            destObj.put(destField, srcObj.get(srcField));
        }
    }

    /**
     * Given a source object, destination object, and a map of Destination to Source SObjectField, compare the values
     * from the source object to the destination.
     *
     * @param srcObj    Source SObject
     * @param destObj   Destination SObject
     * @param fieldMap  Map of SObjectField => SObjectField. SOURCE field is the key, DESTINATION field is the value
     *
     * @return  Returns TRUE if all fields match, otherwise FALSE
     */
    public static Boolean isEqualUsingMapping(SObject srcObj, SObject destObj,
            Map<SObjectField, SObjectField> fieldMap) {

        SObjectField destField;
        for(SObjectField srcField : fieldMap.keySet()) {
            destField = fieldMap.get(srcField);

            if(srcObj.get(srcField) != destObj.get(destField)) {
                return false;
            }
        }

        return true;
    }

    /**
     * Given an SObjectType and a Record Type name, return the Id corresponding to the record type
     * Invalid RT names will throw an exception
     * @param   sobjType    The SObject Type to retrieve the record type Id for
     * @param   rtName      The name of the Record Type
     * @return              The Id of the Record Type
     */
    public static Id getRecordTypeIdForName(SObjectType sobjType, String rtName) {
        RecordTypeInfo rtInfo = sobjType.getDescribe().getRecordTypeInfosByDeveloperName().get(rtName);

        if (rtInfo == null) {
            throw new TLSObjException(rtName, sobjType);
        }

        return rtInfo.getRecordTypeId();
    }

    /**
     * @param source The source record
     * @param destination The destination record
     * @param sourceToDestinationMapping The [source field] to [destination field] map to copy from source to destination
     */
    public static void copyFieldValues(SObject source, SObject destination,
            Map<String, SObjectField> sourceToDestinationMapping) {
        for (String sourceField : sourceToDestinationMapping.keySet()) {
            destination.put(sourceToDestinationMapping.get(sourceField), getFieldValue(source, sourceField));
        }
    }

    /**
	 * Get field value for the given record (works across parent relationships like Contact.Account.Name)
	 * @param obj The record
	 * @param field The field
	 * @return the field value or null if given field is invalid
	 */
    public static Object getFieldValue(SObject obj, String field) {
        List<String> fields = field.split('\\.');
        Integer numFields = fields.size() - 1;
        for (Integer i = 0; i < numFields; i++) {
            if (obj == null) {
                break;
            }
            obj = obj.getSObject(fields[i]);
        }

        if (obj == null) {
            return null;
        }

        return obj.get(fields[numFields]);
    }

    private class TLSObjException extends Exception {

        private TLSObjException(String rtName, SObjectType sobjType) {
            setMessage(String.format(INVALID_RT_FOR_SOBJ_MSG, new String[]{ rtName, String.valueOf(sobjType) }));
        }
    }
}