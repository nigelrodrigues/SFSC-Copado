/**
 * @author Steve Doucette, Traction on Demand 
 * @date 2/20/2019
 */
public with sharing class todft_FieldLoggerUtils {

	// Constants
	public static final String APPNAME = 'FIELD TRACKER';

	// Used to filter records by recordType
	public static Map<String, List<Trigger_Record_Type__mdt>> recordTypeSettingsByObject {
		get {
			if (recordTypeSettingsByObject == null) {
				recordTypeSettingsByObject = new Map<String, List<Trigger_Record_Type__mdt>>();

				for (Trigger_Record_Type__mdt mapping : [
						SELECT Object_Name__c,
								Record_Type_Name__c, Enable__c
						FROM Trigger_Record_Type__mdt
				]) {
					if (!recordTypeSettingsByObject.containsKey(mapping.Object_Name__c)) {
						recordTypeSettingsByObject.put(mapping.Object_Name__c, new List<Trigger_Record_Type__mdt>());
					}
					recordTypeSettingsByObject.get(mapping.Object_Name__c).add(mapping);
				}
			}
			return recordTypeSettingsByObject;
		}
		set;
	}

	// Used to determine what settings to use per object being processed
	public static Map<String, List<Field_Tracker_Mapping__mdt>> settingsByObject {
		get {
			if (settingsByObject == null) {
				settingsByObject = new Map<String, List<Field_Tracker_Mapping__mdt>>();

				//SNAPSHOT-3 Added Time_Log_Field_New_Value__c in querying metadata in Apex class
				//to set the corresponding Time Log field with the updated value, when the parent record is updated.
				for (Field_Tracker_Mapping__mdt mapping : [
						SELECT Parent_Record_Object__c,
								Parent_Record_Field__c,
								Time_Log_Field_Mapping__c,
								Time_Log_Field_New_Value__c
						FROM Field_Tracker_Mapping__mdt
				]) {
					if (!settingsByObject.containsKey(mapping.Parent_Record_Object__c)) {
						settingsByObject.put(mapping.Parent_Record_Object__c, new List<Field_Tracker_Mapping__mdt>());
					}
					settingsByObject.get(mapping.Parent_Record_Object__c).add(mapping);
				}
			}
			return settingsByObject;
		}
		set;
	}

	// Used for dynamic querying per object
	public static Map<String, Set<String>> fieldMappingsByObject {
		get {
			if (fieldMappingsByObject == null) {
				fieldMappingsByObject = new Map<String, Set<String>>();
				Set<String> objNames = settingsByObject.keySet();

				for (String objName : objNames) {
					fieldMappingsByObject.put(objName, new Set<String>());
					for (Field_Tracker_Mapping__mdt setting : settingsByObject.get(objName)) {
						fieldMappingsByObject.get(objName).add(setting.Parent_Record_Field__c);
					}
				}
			}
			return fieldMappingsByObject;
		}
		set;
	}

	/**
	 * dynamic upsert helper
	 * @description Casts a List<SObject> to a concrete type and upserts
	 */
	public static void dynamicUpsert(List<SObject> records, Schema.SObjectType sObjectType, List<SObject> parentRecordList) {
		try {
			String listType = 'List<' + sObjectType + '>';
			List<SObject> castRecords = (List<SObject>) Type.forName(listType).newInstance();
			castRecords.addAll(records);
			upsert castRecords;
		} catch (Exception e) {
		}
	}
}