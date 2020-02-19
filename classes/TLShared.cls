/**
 * Helper methods used by the various TL* Library classes
 * @author Grant Adamson, Traction on Demand
 * @date 2017-05-01
 */
public class TLShared {
    /**
     * Given an sobject and field (either a String or SObjectField), return the value from that field
     * Used by TLList, TLMap, and TLTrigger to support both String and SObjectField versions of various methods
     * @param sobj  SObject to extract field value from
     * @param field The field to query, either in string or SObjectField form
     * @return      The field value
     */
    public static Object getFieldValue(SObject sobj, Object field) {
        if (sobj == null) {
            return null;
        }
        if(field instanceof SObjectField) {
            return sobj.get((SObjectField)field);
        } else {
            return getFieldValue(sobj, (String)field);
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
}