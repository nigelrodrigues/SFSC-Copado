/**
 * Utilities for Map processing and generation
 * @author Grant Adamson, Traction on Demand
 * @date 2017-05-01
 * @group TLMap
 * @modified Jeremy Horan, Traction on Demand, 2018-11-07 - Refactored into addToMap
 *           addToMap(Map<>, List<SObject>, String)
 *           - adds the value to an existing map using String fieldName as key
 *           addToMap(Map<>, List<SObject>, String, String)
 *           - adds the value to an existing map using String fieldName as key and second String fieldName as value
 *           addToMap(Map<Id/String, Decimal/Integer>, Decimal/Integer, Id/String)
 *           - adds the value to an existing map amount using key directly (Mathematical addition)
 */
public class TLMap {

    /**
     * Map field values to lists of SObjects (convenience method so you don't have to cast the map)
     * @param result The map
     * @param source The list used to create the map
     * @param field The field name of the key to put in the map
     */
    public static void addToMap(Map<Object, List<SObject>> result, List<SObject> source, String field) {
        for (SObject record : source) {
            Object key = (Object) record.get(field);
            if (!result.containsKey((key))) {
                result.put(key, new List<SObject>());
            }
            result.get(key).add(record);
        }
    }

    /**
     * Map field values to lists of SObjects (convenience method so you don't have to cast the map)
     * @param result The map
     * @param source The list used to create the map
     * @param field The field name of the key to put in the map
     */
    public static void addToMap(Map<Id, List<SObject>> result, List<SObject> source, String field) {
        for (SObject record : source) {
            Id key = (Id) record.get(field);
            if (!result.containsKey((key))) {
                result.put(key, new List<SObject>());
            }
            result.get(key).add(record);
        }
    }

    /**
     * Map field values to lists of SObjects (convenience method so you don't have to cast the map)
     * @param result The map
     * @param source The list used to create the map
     * @param field The field name of the key to put in the map
     */
    public static void addToMap(Map<String, List<SObject>> result, List<SObject> source, String field) {
        for (SObject record : source) {
            String key = (String) record.get(field);
            if (!result.containsKey((key))) {
                result.put(key, new List<SObject>());
            }
            result.get(key).add(record);
        }
    }

    /**
     * Map field values to lists of SObjects (convenience method so you don't have to cast the map)
     * @param result The map
     * @param source The list used to create the map
     * @param field The field name of the key to put in the map
     */
    public static void addToMap(Map<Decimal, List<SObject>> result, List<SObject> source, String field) {
        for (SObject record : source) {
            Decimal key = (Decimal) record.get(field);
            if (!result.containsKey((key))) {
                result.put(key, new List<SObject>());
            }
            result.get(key).add(record);
        }
    }

    /**
     * Map field values to lists of SObjects (convenience method so you don't have to cast the map)
     * @param result The map
     * @param source The list used to create the map
     * @param field The field name of the key to put in the map
     */
    public static void addToMap(Map<Date, List<SObject>> result, List<SObject> source, String field) {
        for (SObject record : source) {
            Date key = (Date) record.get(field);
            if (!result.containsKey((key))) {
                result.put(key, new List<SObject>());
            }
            result.get(key).add(record);
        }
    }

    /**
     * Map field values to lists of SObjects (convenience method so you don't have to cast the map)
     * @param result The map
     * @param source The list used to create the map
     * @param field The field name of the key to put in the map
     */
    public static void addToMap(Map<Datetime, List<SObject>> result, List<SObject> source, String field) {
        for (SObject record : source) {
            Datetime key = (Datetime) record.get(field);
            if (!result.containsKey((key))) {
                result.put(key, new List<SObject>());
            }
            result.get(key).add(record);
        }
    }

    /**
     * Map field values to SObjects (convenience method so you don't have to cast the map)
     * @param result The map
     * @param source The list to retrieve values (keys) and SObjects (values) from
     * @param field The field name of the key to put in the map
     */
    public static void addToMap(Map<Object, SObject> result, List<SObject> source, String field) {
        for (SObject record : source) {
            Object key = (Object) record.get(field);
            result.put(key, record);
        }
    }

    /**
     * Map field values to SObjects (convenience method so you don't have to cast the map)
     * @param result The map
     * @param source The list to retrieve values (keys) and SObjects (values) from
     * @param field The field name of the key to put in the map
     */
    public static void addToMap(Map<Id, SObject> result, List<SObject> source, String field) {
        for (SObject record : source) {
            Id key = (Id) record.get(field);
            result.put(key, record);
        }
    }

    /**
     * Map field values to SObjects (convenience method so you don't have to cast the map)
     * @param result The map
     * @param source The list to retrieve values (keys) and SObjects (values) from
     * @param field The field name of the key to put in the map
     */
    public static void addToMap(Map<String, SObject> result, List<SObject> source, String field) {
        for (SObject record : source) {
            String key = (String) record.get(field);
            result.put(key, record);
        }
    }

    /**
     * Map field values to SObjects (convenience method so you don't have to cast the map)
     * @param result The map
     * @param source The list to retrieve values (keys) and SObjects (values) from
     * @param field The field name of the key to put in the map
     */
    public static void addToMap(Map<Decimal, SObject> result, List<SObject> source, String field) {
        for (SObject record : source) {
            Decimal key = (Decimal) record.get(field);
            result.put(key, record);
        }
    }

    /**
     * Map field values to SObjects (convenience method so you don't have to cast the map)
     * @param result The map
     * @param source The list to retrieve values (keys) and SObjects (values) from
     * @param field The field name of the key to put in the map
     */
    public static void addToMap(Map<Date, SObject> result, List<SObject> source, String field) {
        for (SObject record : source) {
            Date key = (Date) record.get(field);
            result.put(key, record);
        }
    }

    /**
     * Map field values to SObjects (convenience method so you don't have to cast the map)
     * @param result The map
     * @param source The list to retrieve values (keys) and SObjects (values) from
     * @param field The field name of the key to put in the map
     */
    public static void addToMap(Map<Datetime, SObject> result, List<SObject> source, String field) {
        for (SObject record : source) {
            Datetime key = (Datetime) record.get(field);
            result.put(key, record);
        }
    }

    /**
     * Map field values to lists of SObjects (convenience method so you don't have to cast the map)
     * @param result The map
     * @param source The list used to create the map
     * @param field The field name of the key to put in the map
     * @param valueField The field name of the value to put in the map
     */
    public static void addToMap(Map<Object, List<Id>> result, List<SObject> source, String field, String valueField) {
        for (SObject record : source) {
            Object key = (Object) record.get(field);
            if (!result.containsKey((key))) {
                result.put(key, new List<Id>());
            }
            result.get(key).add((Id) record.get(valueField));
        }
    }

    /**
     * Map field values to lists of SObjects (convenience method so you don't have to cast the map)
     * @param result The map
     * @param source The list used to create the map
     * @param field The field name of the key to put in the map
     * @param valueField The field name of the value to put in the map
     */
    public static void addToMap(Map<Object, List<String>> result, List<SObject> source, String field, String valueField) {
        for (SObject record : source) {
            Object key = (Object) record.get(field);
            if (!result.containsKey((key))) {
                result.put(key, new List<String>());
            }
            result.get(key).add((String) record.get(valueField));
        }
    }

    /**
     * Map field values to lists of SObjects (convenience method so you don't have to cast the map)
     * @param result The map
     * @param source The list used to create the map
     * @param field The field name of the key to put in the map
     * @param valueField The field name of the value to put in the map
     */
    public static void addToMap(Map<Object, List<Decimal>> result, List<SObject> source, String field, String valueField) {
        for (SObject record : source) {
            Object key = (Object) record.get(field);
            if (!result.containsKey((key))) {
                result.put(key, new List<Decimal>());
            }
            result.get(key).add((Decimal) record.get(valueField));
        }
    }

    /**
     * Map field values to lists of SObjects (convenience method so you don't have to cast the map)
     * @param result The map
     * @param source The list used to create the map
     * @param field The field name of the key to put in the map
     * @param valueField The field name of the value to put in the map
     */
    public static void addToMap(Map<Object, List<Date>> result, List<SObject> source, String field, String valueField) {
        for (SObject record : source) {
            Object key = (Object) record.get(field);
            if (!result.containsKey((key))) {
                result.put(key, new List<Date>());
            }
            result.get(key).add((Date) record.get(valueField));
        }
    }

    /**
     * Map field values to lists of SObjects (convenience method so you don't have to cast the map)
     * @param result The map
     * @param source The list used to create the map
     * @param field The field name of the key to put in the map
     * @param valueField The field name of the value to put in the map
     */
    public static void addToMap(Map<Object, List<Datetime>> result, List<SObject> source, String field, String valueField) {
        for (SObject record : source) {
            Object key = (Object) record.get(field);
            if (!result.containsKey((key))) {
                result.put(key, new List<Datetime>());
            }
            result.get(key).add((Datetime) record.get(valueField));
        }
    }

    /**
     * Map field values to lists of SObjects (convenience method so you don't have to cast the map)
     * @param result The map
     * @param source The list used to create the map
     * @param field The field name of the key to put in the map
     * @param valueField The field name of the value to put in the map
     */
    public static void addToMap(Map<Id, List<Id>> result, List<SObject> source, String field, String valueField) {
        for (SObject record : source) {
            Id key = (Id) record.get(field);
            if (!result.containsKey((key))) {
                result.put(key, new List<Id>());
            }
            result.get(key).add((Id) record.get(valueField));
        }
    }

    /**
     * Map field values to lists of SObjects (convenience method so you don't have to cast the map)
     * @param result The map
     * @param source The list used to create the map
     * @param field The field name of the key to put in the map
     * @param valueField The field name of the value to put in the map
     */
    public static void addToMap(Map<Id, List<String>> result, List<SObject> source, String field, String valueField) {
        for (SObject record : source) {
            Id key = (Id) record.get(field);
            if (!result.containsKey((key))) {
                result.put(key, new List<String>());
            }
            result.get(key).add((String) record.get(valueField));
        }
    }

    /**
     * Map field values to lists of SObjects (convenience method so you don't have to cast the map)
     * @param result The map
     * @param source The list used to create the map
     * @param field The field name of the key to put in the map
     * @param valueField The field name of the value to put in the map
     */
    public static void addToMap(Map<Id, List<Decimal>> result, List<SObject> source, String field, String valueField) {
        for (SObject record : source) {
            Id key = (Id) record.get(field);
            if (!result.containsKey((key))) {
                result.put(key, new List<Decimal>());
            }
            result.get(key).add((Decimal) record.get(valueField));
        }
    }

    /**
     * Map field values to lists of SObjects (convenience method so you don't have to cast the map)
     * @param result The map
     * @param source The list used to create the map
     * @param field The field name of the key to put in the map
     * @param valueField The field name of the value to put in the map
     */
    public static void addToMap(Map<Id, List<Date>> result, List<SObject> source, String field, String valueField) {
        for (SObject record : source) {
            Id key = (Id) record.get(field);
            if (!result.containsKey((key))) {
                result.put(key, new List<Date>());
            }
            result.get(key).add((Date) record.get(valueField));
        }
    }

    /**
     * Map field values to lists of SObjects (convenience method so you don't have to cast the map)
     * @param result The map
     * @param source The list used to create the map
     * @param field The field name of the key to put in the map
     * @param valueField The field name of the value to put in the map
     */
    public static void addToMap(Map<Id, List<Datetime>> result, List<SObject> source, String field, String valueField) {
        for (SObject record : source) {
            Id key = (Id) record.get(field);
            if (!result.containsKey((key))) {
                result.put(key, new List<Datetime>());
            }
            result.get(key).add((Datetime) record.get(valueField));
        }
    }

    /**
     * Map field values to lists of SObjects (convenience method so you don't have to cast the map)
     * @param result The map
     * @param source The list used to create the map
     * @param field The field name of the key to put in the map
     * @param valueField The field name of the value to put in the map
     */
    public static void addToMap(Map<String, List<Id>> result, List<SObject> source, String field, String valueField) {
        for (SObject record : source) {
            String key = (String) record.get(field);
            if (!result.containsKey((key))) {
                result.put(key, new List<Id>());
            }
            result.get(key).add((Id) record.get(valueField));
        }
    }

    /**
     * Map field values to lists of SObjects (convenience method so you don't have to cast the map)
     * @param result The map
     * @param source The list used to create the map
     * @param field The field name of the key to put in the map
     * @param valueField The field name of the value to put in the map
     */
    public static void addToMap(Map<String, List<String>> result, List<SObject> source, String field, String valueField) {
        for (SObject record : source) {
            String key = (String) record.get(field);
            if (!result.containsKey((key))) {
                result.put(key, new List<String>());
            }
            result.get(key).add((String) record.get(valueField));
        }
    }

    /**
     * Map field values to lists of SObjects (convenience method so you don't have to cast the map)
     * @param result The map
     * @param source The list used to create the map
     * @param field The field name of the key to put in the map
     * @param valueField The field name of the value to put in the map
     */
    public static void addToMap(Map<String, List<Decimal>> result, List<SObject> source, String field, String valueField) {
        for (SObject record : source) {
            String key = (String) record.get(field);
            if (!result.containsKey((key))) {
                result.put(key, new List<Decimal>());
            }
            result.get(key).add((Decimal) record.get(valueField));
        }
    }

    /**
     * Map field values to lists of SObjects (convenience method so you don't have to cast the map)
     * @param result The map
     * @param source The list used to create the map
     * @param field The field name of the key to put in the map
     * @param valueField The field name of the value to put in the map
     */
    public static void addToMap(Map<String, List<Date>> result, List<SObject> source, String field, String valueField) {
        for (SObject record : source) {
            String key = (String) record.get(field);
            if (!result.containsKey((key))) {
                result.put(key, new List<Date>());
            }
            result.get(key).add((Date) record.get(valueField));
        }
    }

    /**
     * Map field values to lists of SObjects (convenience method so you don't have to cast the map)
     * @param result The map
     * @param source The list used to create the map
     * @param field The field name of the key to put in the map
     * @param valueField The field name of the value to put in the map
     */
    public static void addToMap(Map<String, List<Datetime>> result, List<SObject> source, String field, String valueField) {
        for (SObject record : source) {
            String key = (String) record.get(field);
            if (!result.containsKey((key))) {
                result.put(key, new List<Datetime>());
            }
            result.get(key).add((Datetime) record.get(valueField));
        }
    }

    /**
     * Map field values to lists of SObjects (convenience method so you don't have to cast the map)
     * @param result The map
     * @param source The list used to create the map
     * @param field The field name of the key to put in the map
     * @param valueField The field name of the value to put in the map
     */
    public static void addToMap(Map<Decimal, List<Id>> result, List<SObject> source, String field, String valueField) {
        for (SObject record : source) {
            Decimal key = (Decimal) record.get(field);
            if (!result.containsKey((key))) {
                result.put(key, new List<Id>());
            }
            result.get(key).add((Id) record.get(valueField));
        }
    }

    /**
     * Map field values to lists of SObjects (convenience method so you don't have to cast the map)
     * @param result The map
     * @param source The list used to create the map
     * @param field The field name of the key to put in the map
     * @param valueField The field name of the value to put in the map
     */
    public static void addToMap(Map<Decimal, List<String>> result, List<SObject> source, String field, String valueField) {
        for (SObject record : source) {
            Decimal key = (Decimal) record.get(field);
            if (!result.containsKey((key))) {
                result.put(key, new List<String>());
            }
            result.get(key).add((String) record.get(valueField));
        }
    }

    /**
     * Map field values to lists of SObjects (convenience method so you don't have to cast the map)
     * @param result The map
     * @param source The list used to create the map
     * @param field The field name of the key to put in the map
     * @param valueField The field name of the value to put in the map
     */
    public static void addToMap(Map<Decimal, List<Decimal>> result, List<SObject> source, String field, String valueField) {
        for (SObject record : source) {
            Decimal key = (Decimal) record.get(field);
            if (!result.containsKey((key))) {
                result.put(key, new List<Decimal>());
            }
            result.get(key).add((Decimal) record.get(valueField));
        }
    }

    /**
     * Map field values to lists of SObjects (convenience method so you don't have to cast the map)
     * @param result The map
     * @param source The list used to create the map
     * @param field The field name of the key to put in the map
     * @param valueField The field name of the value to put in the map
     */
    public static void addToMap(Map<Decimal, List<Date>> result, List<SObject> source, String field, String valueField) {
        for (SObject record : source) {
            Decimal key = (Decimal) record.get(field);
            if (!result.containsKey((key))) {
                result.put(key, new List<Date>());
            }
            result.get(key).add((Date) record.get(valueField));
        }
    }

    /**
     * Map field values to lists of SObjects (convenience method so you don't have to cast the map)
     * @param result The map
     * @param source The list used to create the map
     * @param field The field name of the key to put in the map
     * @param valueField The field name of the value to put in the map
     */
    public static void addToMap(Map<Decimal, List<Datetime>> result, List<SObject> source, String field, String valueField) {
        for (SObject record : source) {
            Decimal key = (Decimal) record.get(field);
            if (!result.containsKey((key))) {
                result.put(key, new List<Datetime>());
            }
            result.get(key).add((Datetime) record.get(valueField));
        }
    }

    /**
     * Map field values to lists of SObjects (convenience method so you don't have to cast the map)
     * @param result The map
     * @param source The list used to create the map
     * @param field The field name of the key to put in the map
     * @param valueField The field name of the value to put in the map
     */
    public static void addToMap(Map<Date, List<Id>> result, List<SObject> source, String field, String valueField) {
        for (SObject record : source) {
            Date key = (Date) record.get(field);
            if (!result.containsKey((key))) {
                result.put(key, new List<Id>());
            }
            result.get(key).add((Id) record.get(valueField));
        }
    }

    /**
     * Map field values to lists of SObjects (convenience method so you don't have to cast the map)
     * @param result The map
     * @param source The list used to create the map
     * @param field The field name of the key to put in the map
     * @param valueField The field name of the value to put in the map
     */
    public static void addToMap(Map<Date, List<String>> result, List<SObject> source, String field, String valueField) {
        for (SObject record : source) {
            Date key = (Date) record.get(field);
            if (!result.containsKey((key))) {
                result.put(key, new List<String>());
            }
            result.get(key).add((String) record.get(valueField));
        }
    }

    /**
     * Map field values to lists of SObjects (convenience method so you don't have to cast the map)
     * @param result The map
     * @param source The list used to create the map
     * @param field The field name of the key to put in the map
     * @param valueField The field name of the value to put in the map
     */
    public static void addToMap(Map<Date, List<Decimal>> result, List<SObject> source, String field, String valueField) {
        for (SObject record : source) {
            Date key = (Date) record.get(field);
            if (!result.containsKey((key))) {
                result.put(key, new List<Decimal>());
            }
            result.get(key).add((Decimal) record.get(valueField));
        }
    }

    /**
     * Map field values to lists of SObjects (convenience method so you don't have to cast the map)
     * @param result The map
     * @param source The list used to create the map
     * @param field The field name of the key to put in the map
     * @param valueField The field name of the value to put in the map
     */
    public static void addToMap(Map<Date, List<Date>> result, List<SObject> source, String field, String valueField) {
        for (SObject record : source) {
            Date key = (Date) record.get(field);
            if (!result.containsKey((key))) {
                result.put(key, new List<Date>());
            }
            result.get(key).add((Date) record.get(valueField));
        }
    }

    /**
     * Map field values to lists of SObjects (convenience method so you don't have to cast the map)
     * @param result The map
     * @param source The list used to create the map
     * @param field The field name of the key to put in the map
     * @param valueField The field name of the value to put in the map
     */
    public static void addToMap(Map<Date, List<Datetime>> result, List<SObject> source, String field, String valueField) {
        for (SObject record : source) {
            Date key = (Date) record.get(field);
            if (!result.containsKey((key))) {
                result.put(key, new List<Datetime>());
            }
            result.get(key).add((Datetime) record.get(valueField));
        }
    }

    /**
     * Map field values to lists of SObjects (convenience method so you don't have to cast the map)
     * @param result The map
     * @param source The list used to create the map
     * @param field The field name of the key to put in the map
     * @param valueField The field name of the value to put in the map
     */
    public static void addToMap(Map<Datetime, List<Id>> result, List<SObject> source, String field, String valueField) {
        for (SObject record : source) {
            Datetime key = (Datetime) record.get(field);
            if (!result.containsKey((key))) {
                result.put(key, new List<Id>());
            }
            result.get(key).add((Id) record.get(valueField));
        }
    }

    /**
     * Map field values to lists of SObjects (convenience method so you don't have to cast the map)
     * @param result The map
     * @param source The list used to create the map
     * @param field The field name of the key to put in the map
     * @param valueField The field name of the value to put in the map
     */
    public static void addToMap(Map<Datetime, List<String>> result, List<SObject> source, String field, String valueField) {
        for (SObject record : source) {
            Datetime key = (Datetime) record.get(field);
            if (!result.containsKey((key))) {
                result.put(key, new List<String>());
            }
            result.get(key).add((String) record.get(valueField));
        }
    }

    /**
     * Map field values to lists of SObjects (convenience method so you don't have to cast the map)
     * @param result The map
     * @param source The list used to create the map
     * @param field The field name of the key to put in the map
     * @param valueField The field name of the value to put in the map
     */
    public static void addToMap(Map<Datetime, List<Decimal>> result, List<SObject> source, String field, String valueField) {
        for (SObject record : source) {
            Datetime key = (Datetime) record.get(field);
            if (!result.containsKey((key))) {
                result.put(key, new List<Decimal>());
            }
            result.get(key).add((Decimal) record.get(valueField));
        }
    }

    /**
     * Map field values to lists of SObjects (convenience method so you don't have to cast the map)
     * @param result The map
     * @param source The list used to create the map
     * @param field The field name of the key to put in the map
     * @param valueField The field name of the value to put in the map
     */
    public static void addToMap(Map<Datetime, List<Date>> result, List<SObject> source, String field, String valueField) {
        for (SObject record : source) {
            Datetime key = (Datetime) record.get(field);
            if (!result.containsKey((key))) {
                result.put(key, new List<Date>());
            }
            result.get(key).add((Date) record.get(valueField));
        }
    }

    /**
     * Map field values to lists of SObjects (convenience method so you don't have to cast the map)
     * @param result The map
     * @param source The list used to create the map
     * @param field The field name of the key to put in the map
     * @param valueField The field name of the value to put in the map
     */
    public static void addToMap(Map<Datetime, List<Datetime>> result, List<SObject> source, String field, String valueField) {
        for (SObject record : source) {
            Datetime key = (Datetime) record.get(field);
            if (!result.containsKey((key))) {
                result.put(key, new List<Datetime>());
            }
            result.get(key).add((Datetime) record.get(valueField));
        }
    }

    /**
     * Map field values to SObjects (convenience method so you don't have to cast the map)
     * @param result The map
     * @param source The list to retrieve values (keys) and SObjects (values) from
     * @param field The field name of the key to put in the map
     * @param valueField The field name of the value to put in the map
     */
    public static void addToMap(Map<Id, Id> result, List<SObject> source, String field, String valueField) {
        for (SObject record : source) {
            Id key = (Id) record.get(field);
            result.put(key, (Id) record.get(valueField));
        }
    }

    /**
     * Map field values to SObjects (convenience method so you don't have to cast the map)
     * @param result The map
     * @param source The list to retrieve values (keys) and SObjects (values) from
     * @param field The field name of the key to put in the map
     * @param valueField The field name of the value to put in the map
     */
    public static void addToMap(Map<Id, String> result, List<SObject> source, String field, String valueField) {
        for (SObject record : source) {
            Id key = (Id) record.get(field);
            result.put(key, (String) record.get(valueField));
        }
    }

    /**
     * Map field values to SObjects (convenience method so you don't have to cast the map)
     * @param result The map
     * @param source The list to retrieve values (keys) and SObjects (values) from
     * @param field The field name of the key to put in the map
     * @param valueField The field name of the value to put in the map
     */
    public static void addToMap(Map<Id, Decimal> result, List<SObject> source, String field, String valueField) {
        for (SObject record : source) {
            Id key = (Id) record.get(field);
            result.put(key, (Decimal) record.get(valueField));
        }
    }

    /**
     * Map field values to SObjects (convenience method so you don't have to cast the map)
     * @param result The map
     * @param source The list to retrieve values (keys) and SObjects (values) from
     * @param field The field name of the key to put in the map
     * @param valueField The field name of the value to put in the map
     */
    public static void addToMap(Map<Id, Date> result, List<SObject> source, String field, String valueField) {
        for (SObject record : source) {
            Id key = (Id) record.get(field);
            result.put(key, (Date) record.get(valueField));
        }
    }

    /**
     * Map field values to SObjects (convenience method so you don't have to cast the map)
     * @param result The map
     * @param source The list to retrieve values (keys) and SObjects (values) from
     * @param field The field name of the key to put in the map
     * @param valueField The field name of the value to put in the map
     */
    public static void addToMap(Map<Id, Datetime> result, List<SObject> source, String field, String valueField) {
        for (SObject record : source) {
            Id key = (Id) record.get(field);
            result.put(key, (Datetime) record.get(valueField));
        }
    }

    /**
     * Map field values to SObjects (convenience method so you don't have to cast the map)
     * @param result The map
     * @param source The list to retrieve values (keys) and SObjects (values) from
     * @param field The field name of the key to put in the map
     * @param valueField The field name of the value to put in the map
     */
    public static void addToMap(Map<String, Id> result, List<SObject> source, String field, String valueField) {
        for (SObject record : source) {
            String key = (String) record.get(field);
            result.put(key, (Id) record.get(valueField));
        }
    }

    /**
     * Map field values to SObjects (convenience method so you don't have to cast the map)
     * @param result The map
     * @param source The list to retrieve values (keys) and SObjects (values) from
     * @param field The field name of the key to put in the map
     * @param valueField The field name of the value to put in the map
     */
    public static void addToMap(Map<String, String> result, List<SObject> source, String field, String valueField) {
        for (SObject record : source) {
            String key = (String) record.get(field);
            result.put(key, (String) record.get(valueField));
        }
    }

    /**
     * Map field values to SObjects (convenience method so you don't have to cast the map)
     * @param result The map
     * @param source The list to retrieve values (keys) and SObjects (values) from
     * @param field The field name of the key to put in the map
     * @param valueField The field name of the value to put in the map
     */
    public static void addToMap(Map<String, Decimal> result, List<SObject> source, String field, String valueField) {
        for (SObject record : source) {
            String key = (String) record.get(field);
            result.put(key, (Decimal) record.get(valueField));
        }
    }

    /**
     * Map field values to SObjects (convenience method so you don't have to cast the map)
     * @param result The map
     * @param source The list to retrieve values (keys) and SObjects (values) from
     * @param field The field name of the key to put in the map
     * @param valueField The field name of the value to put in the map
     */
    public static void addToMap(Map<String, Date> result, List<SObject> source, String field, String valueField) {
        for (SObject record : source) {
            String key = (String) record.get(field);
            result.put(key, (Date) record.get(valueField));
        }
    }

    /**
     * Map field values to SObjects (convenience method so you don't have to cast the map)
     * @param result The map
     * @param source The list to retrieve values (keys) and SObjects (values) from
     * @param field The field name of the key to put in the map
     * @param valueField The field name of the value to put in the map
     */
    public static void addToMap(Map<String, Datetime> result, List<SObject> source, String field, String valueField) {
        for (SObject record : source) {
            String key = (String) record.get(field);
            result.put(key, (Datetime) record.get(valueField));
        }
    }

    /**
     * Map field values to SObjects (convenience method so you don't have to cast the map)
     * @param result The map
     * @param source The list to retrieve values (keys) and SObjects (values) from
     * @param field The field name of the key to put in the map
     * @param valueField The field name of the value to put in the map
     */
    public static void addToMap(Map<Decimal, Id> result, List<SObject> source, String field, String valueField) {
        for (SObject record : source) {
            Decimal key = (Decimal) record.get(field);
            result.put(key, (Id) record.get(valueField));
        }
    }

    /**
     * Map field values to SObjects (convenience method so you don't have to cast the map)
     * @param result The map
     * @param source The list to retrieve values (keys) and SObjects (values) from
     * @param field The field name of the key to put in the map
     * @param valueField The field name of the value to put in the map
     */
    public static void addToMap(Map<Decimal, String> result, List<SObject> source, String field, String valueField) {
        for (SObject record : source) {
            Decimal key = (Decimal) record.get(field);
            result.put(key, (String) record.get(valueField));
        }
    }

    /**
     * Map field values to SObjects (convenience method so you don't have to cast the map)
     * @param result The map
     * @param source The list to retrieve values (keys) and SObjects (values) from
     * @param field The field name of the key to put in the map
     * @param valueField The field name of the value to put in the map
     */
    public static void addToMap(Map<Decimal, Decimal> result, List<SObject> source, String field, String valueField) {
        for (SObject record : source) {
            Decimal key = (Decimal) record.get(field);
            result.put(key, (Decimal) record.get(valueField));
        }
    }

    /**
     * Map field values to SObjects (convenience method so you don't have to cast the map)
     * @param result The map
     * @param source The list to retrieve values (keys) and SObjects (values) from
     * @param field The field name of the key to put in the map
     * @param valueField The field name of the value to put in the map
     */
    public static void addToMap(Map<Decimal, Date> result, List<SObject> source, String field, String valueField) {
        for (SObject record : source) {
            Decimal key = (Decimal) record.get(field);
            result.put(key, (Date) record.get(valueField));
        }
    }

    /**
     * Map field values to SObjects (convenience method so you don't have to cast the map)
     * @param result The map
     * @param source The list to retrieve values (keys) and SObjects (values) from
     * @param field The field name of the key to put in the map
     * @param valueField The field name of the value to put in the map
     */
    public static void addToMap(Map<Decimal, Datetime> result, List<SObject> source, String field, String valueField) {
        for (SObject record : source) {
            Decimal key = (Decimal) record.get(field);
            result.put(key, (Datetime) record.get(valueField));
        }
    }

    /**
     * Map field values to SObjects (convenience method so you don't have to cast the map)
     * @param result The map
     * @param source The list to retrieve values (keys) and SObjects (values) from
     * @param field The field name of the key to put in the map
     * @param valueField The field name of the value to put in the map
     */
    public static void addToMap(Map<Date, Id> result, List<SObject> source, String field, String valueField) {
        for (SObject record : source) {
            Date key = (Date) record.get(field);
            result.put(key, (Id) record.get(valueField));
        }
    }

    /**
     * Map field values to SObjects (convenience method so you don't have to cast the map)
     * @param result The map
     * @param source The list to retrieve values (keys) and SObjects (values) from
     * @param field The field name of the key to put in the map
     * @param valueField The field name of the value to put in the map
     */
    public static void addToMap(Map<Date, String> result, List<SObject> source, String field, String valueField) {
        for (SObject record : source) {
            Date key = (Date) record.get(field);
            result.put(key, (String) record.get(valueField));
        }
    }

    /**
     * Map field values to SObjects (convenience method so you don't have to cast the map)
     * @param result The map
     * @param source The list to retrieve values (keys) and SObjects (values) from
     * @param field The field name of the key to put in the map
     * @param valueField The field name of the value to put in the map
     */
    public static void addToMap(Map<Date, Decimal> result, List<SObject> source, String field, String valueField) {
        for (SObject record : source) {
            Date key = (Date) record.get(field);
            result.put(key, (Decimal) record.get(valueField));
        }
    }

    /**
     * Map field values to SObjects (convenience method so you don't have to cast the map)
     * @param result The map
     * @param source The list to retrieve values (keys) and SObjects (values) from
     * @param field The field name of the key to put in the map
     * @param valueField The field name of the value to put in the map
     */
    public static void addToMap(Map<Date, Date> result, List<SObject> source, String field, String valueField) {
        for (SObject record : source) {
            Date key = (Date) record.get(field);
            result.put(key, (Date) record.get(valueField));
        }
    }

    /**
     * Map field values to SObjects (convenience method so you don't have to cast the map)
     * @param result The map
     * @param source The list to retrieve values (keys) and SObjects (values) from
     * @param field The field name of the key to put in the map
     * @param valueField The field name of the value to put in the map
     */
    public static void addToMap(Map<Date, Datetime> result, List<SObject> source, String field, String valueField) {
        for (SObject record : source) {
            Date key = (Date) record.get(field);
            result.put(key, (Datetime) record.get(valueField));
        }
    }

    /**
     * Map field values to SObjects (convenience method so you don't have to cast the map)
     * @param result The map
     * @param source The list to retrieve values (keys) and SObjects (values) from
     * @param field The field name of the key to put in the map
     * @param valueField The field name of the value to put in the map
     */
    public static void addToMap(Map<Datetime, Id> result, List<SObject> source, String field, String valueField) {
        for (SObject record : source) {
            Datetime key = (Datetime) record.get(field);
            result.put(key, (Id) record.get(valueField));
        }
    }

    /**
     * Map field values to SObjects (convenience method so you don't have to cast the map)
     * @param result The map
     * @param source The list to retrieve values (keys) and SObjects (values) from
     * @param field The field name of the key to put in the map
     * @param valueField The field name of the value to put in the map
     */
    public static void addToMap(Map<Datetime, String> result, List<SObject> source, String field, String valueField) {
        for (SObject record : source) {
            Datetime key = (Datetime) record.get(field);
            result.put(key, (String) record.get(valueField));
        }
    }

    /**
     * Map field values to SObjects (convenience method so you don't have to cast the map)
     * @param result The map
     * @param source The list to retrieve values (keys) and SObjects (values) from
     * @param field The field name of the key to put in the map
     * @param valueField The field name of the value to put in the map
     */
    public static void addToMap(Map<Datetime, Decimal> result, List<SObject> source, String field, String valueField) {
        for (SObject record : source) {
            Datetime key = (Datetime) record.get(field);
            result.put(key, (Decimal) record.get(valueField));
        }
    }

    /**
     * Map field values to SObjects (convenience method so you don't have to cast the map)
     * @param result The map
     * @param source The list to retrieve values (keys) and SObjects (values) from
     * @param field The field name of the key to put in the map
     * @param valueField The field name of the value to put in the map
     */
    public static void addToMap(Map<Datetime, Date> result, List<SObject> source, String field, String valueField) {
        for (SObject record : source) {
            Datetime key = (Datetime) record.get(field);
            result.put(key, (Date) record.get(valueField));
        }
    }

    /**
     * Map field values to SObjects (convenience method so you don't have to cast the map)
     * @param result The map
     * @param source The list to retrieve values (keys) and SObjects (values) from
     * @param field The field name of the key to put in the map
     * @param valueField The field name of the value to put in the map
     */
    public static void addToMap(Map<Datetime, Datetime> result, List<SObject> source, String field, String valueField) {
        for (SObject record : source) {
            Datetime key = (Datetime) record.get(field);
            result.put(key, (Datetime) record.get(valueField));
        }
    }

    /**
     * Sets or adds given amount to the value stored at the given key.
     * Starts at zero, treats null amount as 0, guarantees
     *
     * @param theMap The map
     * @param key The key
     * @param amount Add the given amount to the key, starts from 0 if key is not present, treats nulls as 0s
     */
    public static void addToMap(Map<Id, Decimal> theMap, Decimal amount, Id key) {
        Decimal currentValue = theMap.get(key);
        if (currentValue == null) {
            currentValue = 0;
        }
        if (amount == null) {
            amount = 0;
        }
        theMap.put(key, currentValue + amount);
    }

    /**
     * Sets or adds given amount to the value stored at the given key.
     * Starts at zero, treats null amount as 0, guarantees
     *
     * @param theMap The map
     * @param key The key
     * @param amount Add the given amount to the key, starts from 0 if key is not present, treats nulls as 0s
     */
    public static void addToMap(Map<String, Decimal> theMap, Decimal amount, String key) {
        Decimal currentValue = theMap.get(key);
        if (currentValue == null) {
            currentValue = 0;
        }
        if (amount == null) {
            amount = 0;
        }
        theMap.put(key, currentValue + amount);
    }

    /**
     * Sets or adds given amount to the value stored at the given key.
     * Starts at zero, treats null amount as 0, guarantees
     *
     * @param theMap The map
     * @param key The key
     * @param amount Add the given amount to the key, starts from 0 if key is not present, treats nulls as 0s
     */
    public static void addToMap(Map<Id, Integer> theMap, Integer amount, Id key) {
        Integer currentValue = theMap.get(key);
        if (currentValue == null) {
            currentValue = 0;
        }
        if (amount == null) {
            amount = 0;
        }
        theMap.put(key, currentValue + amount);
    }

    /**
     * Sets or adds given amount to the value stored at the given key.
     * Starts at zero, treats null amount as 0, guarantees
     *
     * @param theMap The map
     * @param key The key
     * @param amount Add the given amount to the key, starts from 0 if key is not present, treats nulls as 0s
     */
    public static void addToMap(Map<String, Integer> theMap, Integer amount, String key) {
        Integer currentValue = theMap.get(key);
        if (currentValue == null) {
            currentValue = 0;
        }
        if (amount == null) {
            amount = 0;
        }
        theMap.put(key, currentValue + amount);
    }


    /***** Deprecated *****/

    /**
     * Given a list of SObjects, generate a map of record Id to a field value
     * @param   source          List of SObjects to generate the map from
     * @param   field           Field to be used for the map values
     * @return                  Map of Id to field values
     */
    public static Map<Id, Object> mapByIdToField(List<SObject> source, SObjectField field) {
        return mapByIdToFieldInternal(source, field, false);
    }

    /**
     * Given a list of SObjects, generate a map of record Id to a field value
     * @param   source          List of SObjects to generate the map from
     * @param   field           Field to be used for the map values
     * @param   excludeNulls    Exclude null field values if set to true
     * @return                  Map of Id to field values
     */
    public static Map<Id, Object> mapByIdToField(List<SObject> source, String field, Boolean excludeNulls) {
        return mapByIdToFieldInternal(source, field, excludeNulls);
    }

    /**
     * Given a list of SObjects, generate a map of record Id to a field value
     * @param   source          List of SObjects to generate the map from
     * @param   field           Field to be used for the map values
     * @return                  Map of Id to field values
     */
    public static Map<Id, Object> mapByIdToField(List<SObject> source, String field) {
        return mapByIdToFieldInternal(source, field, false);
    }

    /**
     * Given a list of SObjects, generate a map of record Id to a field value
     * @param   source          List of SObjects to generate the map from
     * @param   field           Field to be used for the map values
     * @param   excludeNulls    Exclude null field values if set to true
     * @return                  Map of Id to field values
     */
    public static Map<Id, Object> mapByIdToField(List<SObject> source, SObjectField field, Boolean excludeNulls) {
        return mapByIdToFieldInternal(source, field, excludeNulls);
    }

    private static Map<Id, Object> mapByIdToFieldInternal(List<SObject> source, Object field, Boolean excludeNulls) {
        final Map<Id, Object> result = new Map<Id, Object>();

        Object value;
        for(SObject sobj : source) {
            value = TLShared.getFieldValue(sobj, field);

            if(!excludeNulls || value != null) {
                result.put(sobj.Id, value);
            }
        }

        return result;
    }

    /**
     * Given a list of SObjects, generate a map of a field value to an Id
     * @param   source          List of SObjects to generate the map from
     * @param   field           Field to be used for the map keys
     * @return                  Map of Id to field values
     */
    public static Map<Id, Id> mapByIdFieldToId(List<SObject> source, SObjectField field) {
        return mapByIdFieldToIdInternal(source, field, false);
    }

    /**
     * Given a list of SObjects, generate a map of a field value to an Id
     * @param   source          List of SObjects to generate the map from
     * @param   field           Field to be used for the map keys
     * @param   excludeNulls    Exclude null field values if set to true
     * @return                  Map of Id to field values
     */
    public static Map<Id, Id> mapByIdFieldToId(List<SObject> source, String field, Boolean excludeNulls) {
        return mapByIdFieldToIdInternal(source, field, excludeNulls);
    }

    /**
     * Given a list of SObjects, generate a map of a field value to an Id
     * @param   source          List of SObjects to generate the map from
     * @param   field           Field to be used for the map keys
     * @return                  Map of Id to field values
     */
    public static Map<Id, Id> mapByIdFieldToId(List<SObject> source, String field) {
        return mapByIdFieldToIdInternal(source, field, false);
    }

    /**
     * Given a list of SObjects, generate a map of a field value to an Id
     * @param   source          List of SObjects to generate the map from
     * @param   field           Field to be used for the map keys
     * @param   excludeNulls    Exclude null field values if set to true
     * @return                  Map of Id to field values
     */
    public static Map<Id, Id> mapByIdFieldToId(List<SObject> source, SObjectField field, Boolean excludeNulls) {
        return mapByIdFieldToIdInternal(source, field, excludeNulls);
    }

    private static Map<Id, Id> mapByIdFieldToIdInternal(List<SObject> source, Object field, Boolean excludeNulls) {
        //TODO: Check field type is Id for provided field
        final Map<Id, Id> result = new Map<Id, Id>();

        Object key;
        for(SObject sobj : source) {
            key = TLShared.getFieldValue(sobj, field);

            if(!excludeNulls || key != null) {
                result.put((Id)key, sobj.Id);
            }
        }

        return result;
    }

}