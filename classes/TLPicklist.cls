/**
 *  @description Utilities for Picklist fields
 *  @author      Jeremy Horan, Traction on Demand.
 *  @date        10/30/2018
 */
public class TLPicklist {

    private static Map<String, Map<String, List<String>>> cachedDependantPicklistValuesByField = new Map<String, Map<String, List<String>>>();

    /**
     *  @description Returns picklist labels in a list of strings for input object and field, returns empty list if invalid field/object
     *  @author      Bejal Lewis, Traction on Demand.
     *  @date        2018-03-19
     */
    public static List<String> getPicklistLabels(String sObjectApiName, String fieldApiName) {
        List<String> pickListLabels = new List<String>();

        try {
            Map<String, Schema.SObjectField> fieldsByName = Schema.getGlobalDescribe().get(sObjectApiName).getDescribe().fields.getMap();

            Schema.DescribeFieldResult fieldResult = fieldsByName.get(fieldApiName).getDescribe();
            List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();

            for(Schema.PicklistEntry pickListValue : picklistEntries) {
                pickListLabels.add(pickListValue.getLabel());
            }
        }
        catch (Exception e) {
            System.debug('Error in get picklist labels: line' + e.getLineNumber() + ', ' + e.getMessage());
        }

        return pickListLabels;
    }

    /**
     *  @description Returns picklist API values in a list of strings for input object and field, returns empty list if invalid field/object
     *  @author      Jeremy Horan, Traction on Demand.
     *  @date        10/30/2018
     */
    public static List<String> getPicklistValues(String sObjectApiName, String fieldApiName) {
        List<String> pickListValues = new List<String>();

        try {
            Map<String, Schema.SObjectField> fieldsByName = Schema.getGlobalDescribe().get(sObjectApiName).getDescribe().fields.getMap();

            Schema.DescribeFieldResult fieldResult = fieldsByName.get(fieldApiName).getDescribe();
            List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();

            for(Schema.PicklistEntry pickListValue : picklistEntries) {
                pickListValues.add(pickListValue.getValue());
            }
        }
        catch (Exception e) {
            System.debug('Error in get picklist values: line' + e.getLineNumber() + ', ' + e.getMessage());
        }

        return pickListValues;
    }

    /**
     *  @description Picklist Comparison tool that builds a list of picklist values and valid options for each
     *               for dependant picklists
     *  @author 	 Jeremy Horan, Traction on Demand.
     *  @date        2017-04-03
     */
    public static Map<String,List<String>> getDependantPicklistValuesByFieldName (String picklistObjectName, String picklistControllingFieldName, String picklistDependentFieldName) {
        String mapKey = picklistObjectName + picklistControllingFieldName + picklistDependentFieldName;

        if (cachedDependantPicklistValuesByField.containsKey(mapKey)) {
            return cachedDependantPicklistValuesByField.get(mapKey);
        }

        Map<String,List<String>> objectResults = new Map<String,List<String>>();
        //get the string to sObject global map
        Map<String,Schema.SObjectType> objectGlobalMap = Schema.getGlobalDescribe();
        //get the type being dealt with
        Schema.SObjectType pType = objectGlobalMap.get(picklistObjectName);
        Map<String, Schema.SObjectField> objectFieldMap = pType.getDescribe().fields.getMap();
        //get the control values
        List<Schema.PicklistEntry> controllingPicklistEntries = objectFieldMap.get(picklistControllingFieldName).getDescribe().getPicklistValues();
        //get the dependent values
        List<Schema.PicklistEntry> dependentPicklistEntries = objectFieldMap.get(picklistDependentFieldName).getDescribe().getPicklistValues();
        //iterate through the values and get the ones valid for the controlling field name
        Bitset objectBitSet = new Bitset();
        //set up the results
        for (Integer picklistControllingIndex = 0; picklistControllingIndex < controllingPicklistEntries.size(); picklistControllingIndex++) {
            //get the pointer to the entry
            Schema.PicklistEntry controllingPicklistEntry = controllingPicklistEntries[picklistControllingIndex];
            //get the label
            String pControllingLabel = controllingPicklistEntry.getLabel();
            //create the entry with the label
            objectResults.put(pControllingLabel,new List<String>());
        }
        //check the dependent values
        for (Integer picklistDependentIndex=0; picklistDependentIndex<dependentPicklistEntries.size(); picklistDependentIndex++) {
            //get the pointer to the dependent index
            Schema.PicklistEntry dependentPicklistEntry = dependentPicklistEntries[picklistDependentIndex];
            //get the valid for
            String picklistEntryStructure = JSON.serialize(dependentPicklistEntry);
            PicklistDetails objectDependentPicklistEntry = (PicklistDetails)JSON.deserialize(picklistEntryStructure, PicklistDetails.class);
            //iterate through the controlling values
            for (Integer picklistControllingIndex=0; picklistControllingIndex<controllingPicklistEntries.size(); picklistControllingIndex++) {
                if (objectDependentPicklistEntry.validFor == null || objectBitSet.fitBit(objectDependentPicklistEntry.validFor,picklistControllingIndex)) {
                    //get the label
                    String pControllingLabel = controllingPicklistEntries[picklistControllingIndex].getLabel();
                    objectResults.get(pControllingLabel).add(objectDependentPicklistEntry.label);
                }
            }
        }

        cachedDependantPicklistValuesByField.put(mapKey, objectResults);

        return objectResults;
    }

    /**
     *  @description Picklist Wrapper
     *  @author 	 Jeremy Horan, Traction on Demand.
     *  @date        2017-04-03
     */
    public class PicklistDetails {
        public String active       {get;set;}
        public String defaultValue {get;set;}
        public String label        {get;set;}
        public String value        {get;set;}
        public String validFor     {get;set;}
    }

    /**
     *  @description Bit Mapping Tool - Used to find codes for dependant picklist fields
     *  @author 	 Jeremy Horan, Traction on Demand.
     *  @date        2017-04-03
     */
    public class Bitset {
        public Map<String, Integer> AlphaNumCharCodes {get;set;}
        public Map<String, Integer> Base64CharCodes   {get;set;}

        public Bitset() {
            findCharacterCodes();
        }

        /**
         *  @description Defines Character codes to be used in comparisons
         *  @author 	 Jeremy Horan, Traction on Demand.
         *  @date        2017-04-03
         */
        private void findCharacterCodes() {
            AlphaNumCharCodes = new Map<String,Integer>{
                    'A'=>65,'B'=>66,'C'=>67,'D'=>68,'E'=>69,'F'=>70,'G'=>71,'H'=>72,'I'=>73,'J'=>74,
                    'K'=>75,'L'=>76,'M'=>77,'N'=>78,'O'=>79,'P'=>80,'Q'=>81,'R'=>82,'S'=>83,'T'=>84,
                    'U'=>85,'V'=> 86,'W'=>87,'X'=>88,'Y'=>89,'Z'=>90
            };
            Base64CharCodes = new Map<String, Integer>();
            //lower case
            Set<String> pUpperCase = AlphaNumCharCodes.keySet();
            for (String pKey : pUpperCase) {
                //the difference between upper case and lower case is 32
                AlphaNumCharCodes.put(pKey.toLowerCase(),AlphaNumCharCodes.get(pKey)+32);
                //Base 64 alpha starts from 0 (The ascii charcodes started from 65)
                Base64CharCodes.put(pKey,AlphaNumCharCodes.get(pKey) - 65);
                Base64CharCodes.put(pKey.toLowerCase(),AlphaNumCharCodes.get(pKey) - (65) + 26);
            }
            //numerics
            for (Integer i=0; i<=9; i++) {
                AlphaNumCharCodes.put(string.valueOf(i),i+48);
                //base 64 numeric starts from 52
                Base64CharCodes.put(string.valueOf(i), i + 52);
            }
            // Special chars
            Base64CharCodes.put('+', 62);
            Base64CharCodes.put('/', 63);
        }

        /**
         *  @description Compares Bits to find if value is valid
         *  @author 	 Jeremy Horan, Traction on Demand.
         *  @date        2017-04-03
         */
        public Boolean fitBit(String pValidFor,Integer n) {
            //the list of bytes
            List<Integer> pBytes = new List<Integer>();
            //multiply by 6 since base 64 uses 6 bits
            Integer bytesBeingUsed = (pValidFor.length() * 6)/8;
            //will be used to hold the full decimal value
            Integer pFullValue = 0;
            //must be more than 1 byte
            if (bytesBeingUsed <= 1)
                return false;
            //calculate the target bit for comparison
            Integer bit = 7 - (Math.mod(n,8));
            //calculate the octet that has in the target bit
            Integer targetOctet = (bytesBeingUsed - 1) - (n >> bytesBeingUsed);
            //the number of bits to shift by until we find the bit to compare for true or false
            Integer shiftBits = (targetOctet * 8) + bit;
            //get the base64bytes
            for (Integer i=0;i<pValidFor.length();i++) {
                //get current character value
                pBytes.Add((Base64CharCodes.get((pValidFor.Substring(i, i+1)))));
            }
            //calculate the full decimal value
            for (Integer i = 0; i < pBytes.size(); i++) {
                Integer pShiftAmount = (pBytes.size()-(i+1))*6;//used to shift by a factor 6 bits to get the value

                pFullValue = pFullValue + (pBytes[i] << (pShiftAmount));
            }
            //shift to the bit which will dictate true or false
            Integer tBitVal = ((Integer)(Math.Pow(2, shiftBits)) & pFullValue) >> shiftBits;
            return  tBitVal == 1;
        }
    }
}