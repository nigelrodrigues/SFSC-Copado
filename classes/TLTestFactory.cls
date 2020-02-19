/**
 * Factory class for generating SObjects based on field defaults
 * Adapted from https://github.com/dhoechst/Salesforce-Test-Factory
 *
 * @author Grant Adamson, Traction on Demand
 * @date 2018-03-08
 * @group TLTestFactory
 */
@IsTest
public class TLTestFactory {
    @TestVisible
    private static final String NO_CONFIG_CLASS_WARN = 'No TLTestFactoryConfig class found. Only methods with ' +
            'ValuesProvider classes passed as a parameter will execute successfully';
    @TestVisible
    private static final String NO_DEFAULTS_PROVIDER_ERROR = 'No ValuesProvider found for SObject provided: {0}. ' +
            'Either pass a ValuesProvider class type when calling or register an additional class ' +
            'in TLTestFactoryConfiguration';
    @TestVisible
    private static final String UNABLE_TO_INITIALIZE_DEFAULTS_CLASS_ERROR = 'Unable to get an instance of the ' +
            'ValuesProvider class specified. Does it implement the TLTestFactory.ValuesProvider interface?';
    @TestVisible
    private static final String NULL_SOBJECT_ERROR = 'SObject cannot be null';
    @TestVisible
    private static final String INVALID_NUMBER_OF_OBJECTS_ERROR =
            'Number of objects must be a non-zero, positive integer';

    @TestVisible
    private static String configurationClassName = 'TLTestFactoryConfig';

    @TestVisible
    private Map<SObjectType, Type> valuesProviders;

    /**
     * Default constructor. Will search for a class named "TLTestFactoryConfig" to determine ValuesProviders
     */
    public TLTestFactory() {
        try {
            final Type t = Type.forName(configurationClassName);
            final Configuration config = (Configuration)t.newInstance();
            valuesProviders = config.getValuesProviders();
        } catch(Exception e) {
            valuesProviders = new Map<SObjectType,Type>();
            System.debug(System.LoggingLevel.WARN, NO_CONFIG_CLASS_WARN);
        }
    }

    /**
     * Config constructor. Will use ValuesProviders returned in config object instance
     *
     * @param config Config instance
     */
    public TLTestFactory(Configuration config) {
        valuesProviders = config.getValuesProviders();
    }

    public SObject createSObject(SObject sObj) {
        return createSObjects(new ConfigOptions(sObj, 1, null, false))[0];
    }

    public SObject createSObject(SObject sObj, Boolean doInsert) {
        return createSObjects(new ConfigOptions(sObj, 1, null, doInsert))[0];
    }

    public SObject createSObject(SObject sObj, ValuesProvider valuesProv) {
        return createSObjects(new ConfigOptions(sObj, 1, valuesProv, false))[0];
    }

    public SObject createSObject(SObject sObj, ValuesProvider valuesProv, Boolean doInsert) {
        return createSObjects(new ConfigOptions(sObj, 1, valuesProv, doInsert))[0];
    }

    public List<SObject> createSObjects(SObject sObj, Integer numberOfObjects) {
        return createSObjects(new ConfigOptions(sObj, numberOfObjects, null, false));
    }

    public List<SObject> createSObjects(SObject sObj, Integer numberOfObjects, Boolean doInsert) {
        return createSObjects(new ConfigOptions(sObj, numberOfObjects, null, doInsert));
    }

    public List<SObject> createSObjects(SObject sObj, Integer numberOfObjects, ValuesProvider valuesProv) {
        return createSObjects(new ConfigOptions(sObj, numberOfObjects, valuesProv, false));
    }

    public List<SObject> createSObjects(SObject sObj, Integer numberOfObjects, ValuesProvider valuesProv,
            Boolean doInsert) {

        return createSObjects(new ConfigOptions(sObj, numberOfObjects, valuesProv, doInsert));
    }

    private List<SObject> createSObjects(ConfigOptions options) {
        List<SObject> newSObjects;

        final SObject newObj = options.sObj;
        final ValuesProvider valuesProv = getValuesProviderInstance(options);

        addFieldDefaults(newObj, valuesProv);

        if (options.numberOfObjects > 1) {
            newSObjects = createSObjectList(newObj, valuesProv, options.numberOfObjects);
        } else {
            newSObjects = new List<SObject>{ newObj };
        }

        if(options.doInsert) {
            insert newSObjects;
        }

        return newSObjects;
    }

    private ValuesProvider getValuesProviderInstance(ConfigOptions options) {
        if(options.valuesProv != null) {
            return options.valuesProv;
        } else {
            return getValuesProviderInstanceFromProvidersMap(options);
        }
    }

    private ValuesProvider getValuesProviderInstanceFromProvidersMap(ConfigOptions options) {
        ValuesProvider valuesProvider;

        if (isValueProviderAvailable(options.sObjType)) {
            valuesProvider = getValuesProvider(options.sObjType);
        }

        return valuesProvider;
    }

    private Boolean isValueProviderAvailable(SObjectType sObjType) {
        return valuesProviders.containsKey(sObjType);
    }

    private ValuesProvider getValuesProvider(SObjectType sObjType) {
        ValuesProvider valuesProvider;

        if (valuesProviders.containsKey(sObjType)) {
            valuesProvider = (ValuesProvider)valuesProviders.get(sObjType).newInstance();
        }

        return valuesProvider;
    }

    private void addFieldDefaults(SObject sobj, ValuesProvider vp) {
        if (vp != null) {
            final Map<SObjectField, Object> defaults = vp.getFieldValues();
            final Map<String, Object> populatedFields = sobj.getPopulatedFieldsAsMap();

            for (Schema.SObjectField field : defaults.keySet()) {
                if (!populatedFields.containsKey(String.valueOf(field))) {
                    sobj.put(field, defaults.get(field));
                }
            }
        }
    }

    private List<SObject> createSObjectList(SObject newObj, ValuesProvider vp, Integer numberOfObjects) {
        final List<SObject> sObjs = new List<SObject>();
        final SObjectField nameField;

        if (vp != null) {
            nameField = vp.getNameField();
        }

        SObject clonedSObj;
        for (Integer i = 0; i < numberOfObjects; i++) {
            clonedSObj = newObj.clone(false, true);

            if(nameField != null) {
                clonedSObj.put(nameField, (String)clonedSObj.get(nameField) + ' ' + i);
            }
            sObjs.add(clonedSObj);
        }
        return sObjs;
    }

    /**
     * Data transfer object to hold configuration settings from the various create* methods
     * Also does basic validation on settings
     */
    private class ConfigOptions {
        private SObject sObj;
        private SObjectType sObjType;
        private Integer numberOfObjects;
        private ValuesProvider valuesProv;
        private Boolean doInsert;

        private ConfigOptions(SObject sObj, Integer numberOfObjects, ValuesProvider valuesProv, Boolean doInsert) {
            checkSObject(sObj);
            this.sObj = sObj;

            this.sObjType = sObj.getSObjectType();

            checkNumberOfObjects(numberOfObjects);
            this.numberOfObjects = numberOfObjects;

            this.valuesProv = valuesProv;
            this.doInsert = (doInsert != null ? doInsert : false);
        }

        private void checkSObject(SObject sObj) {
            if(sObj == null) {
                throw new TestFactoryException(NULL_SOBJECT_ERROR);
            }
        }

        private void checkNumberOfObjects(Integer numberOfObjects) {
            if(numberOfObjects < 1) {
                throw new TestFactoryException(INVALID_NUMBER_OF_OBJECTS_ERROR);
            }
        }
    }

    private class TestFactoryException extends Exception {}

    /**
     * Interface for defining configuration classes for TLTestFactory
     * The default TLTestFactoryConfig class implements this. Alternative configurations can be defined by implementing
     * the interface and passing an instance of the implementing class to the TLTestFactory constructor
     */
    public interface Configuration {
        /**
         * Method that returns a map of FieldDefaults provider classes (specified by type name) by SObjectType
         *
         * @return Map of Schema.SObjectType to Type (Where type is a class implementing TLTestFactory.FieldDefaults)
         */
        Map<SObjectType,Type> getValuesProviders();
    }

    /**
     * Interface for defining values providers used by TLTestFactory to populate SObject fields
     */
    public interface ValuesProvider {
        /**
         * Method that returns a map of field values by SObjectField, that will be applied to an SObject
         *
         * @return Map of Schema.SObjectField to Object
         */
        Map<Schema.SObjectField, Object> getFieldValues();

        /**
         * Method that returns the "Name" field for the SObject that the class provides values for
         * This is used when requesting multiple SObjects at once, to determine what field will have an incremented
         * suffix applied to it, like "Account 0", "Account 1", etc. Return null when no field is applicable.
         *
         * @return Schema.SObjectField corresponding to the Object's name field, or null
         */
        Schema.SObjectField getNameField();
    }
}