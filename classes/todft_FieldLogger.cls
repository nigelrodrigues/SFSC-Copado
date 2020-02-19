/**
 * @author Steve Doucette, Traction on Demand 
 * @date 2018-11-17
 * @modifiedBy Andrew Fee, Rishabh Garg
 */
public without sharing class todft_FieldLogger {
	//Exception classes
	private class GeneralTimeLogException extends Exception {
	}
	private class FieldMissingOnTimeLogException extends Exception {
	}

	//Constants
	private static final DateTime NOW = DateTime.now();
	private static final String SFDC_SUFFIX = '__c';
	private static final String UNDERSCORE = '_';

	//Made changes by Rishabh for Calculating calendar time duration when a Time Log record "closes"
	//Get Bussiness Hours from org
	private static final List<BusinessHours> defaultBusinessHour = new List<BusinessHours>([
			SELECT Id
			FROM BusinessHours
			WHERE IsDefault = true
	]);

	private static Boolean parentHasBusinessHoursId;

	private static String parentSObjectName = '';

	public static Boolean isParentRecordCreated = false;
	private static Boolean isWorkAgent = false;

	private static Set<Id> parentIds = new Set<Id>();
	private static Map<Id, SObject> newTimeLogsByParent = new Map<Id, SObject>();
	private static Map<Id, SObject> closedTimeLogsByParent = new Map<Id, SObject>();

	private static String parentObjNameForAgent = '';

	public static void executeForWorkAgent(String objectName, List<SObject> parentSObjectRecords, Boolean viaWorkAgent) {
		parentObjNameForAgent = objectName;
		isWorkAgent = viaWorkAgent;
		execute(parentSObjectRecords, null);
	}

	/**
	 * @description Close any existing Time Logs, then create new Time Logs for every new/updated parent record
	 * @param parentRecords - Records being processed
	 */
	public static void execute(List<SObject> parentRecords, Map<Id, SObject> oldParentMap) {
		String parentObjName = '';
		// Determine the type of records we are processing
		if (String.isNotBlank(parentObjNameForAgent)) {
			parentObjName = parentObjNameForAgent;
		} else {
			parentObjName = parentRecords.getSObjectType().getDescribe().getName();
		}

		// get name of Time Log custom object and convert to a SObjectType (Example: Case_Time_log__c)
		String timeLogObjName = parentObjName.substringBefore(SFDC_SUFFIX) + '_Time_Log__c';
		Schema.SObjectType timeLogType = Schema.getGlobalDescribe().get(timeLogObjName.toLowerCase());
		if (timeLogType == null) {
			throw new GeneralTimeLogException('Custom time log object does not exist: ' + timeLogObjName);
		}

		//get all RecordTypes of parent object (if no Record Types, then there will be 1 entry for Master)
		Schema.SObjectType parentObjectType = Schema.getGlobalDescribe().get(parentObjName);
		Map<Id, Schema.RecordTypeInfo> recordTypesById = parentObjectType.getDescribe().getRecordTypeInfosById();
		Boolean parentHasRecordTypes = recordTypesById.size() > 1;
		parentHasBusinessHoursId = parentObjectType.getDescribe().fields.getMap().containsKey('BusinessHoursId');


		//SNAPSHOT-4 - Limit the field values to be tracked
		List<SObject> parentRecordList = new List<SObject>();
		Set<Id> objectRecordIdSet = new Set<Id>();
		for (SObject obj : parentRecords) {
			objectRecordIdSet.add((Id) obj.get('Id'));
		}
		List<String> objectFieldsToTrack = new List<String>();
		if (todft_FieldLoggerUtils.fieldMappingsByObject.containsKey(parentObjName)) {
			objectFieldsToTrack.addAll(todft_FieldLoggerUtils.fieldMappingsByObject.get(parentObjName));
		}

		//SNAPSHOT - 134 To avoid dupicate selection of fields in the query
		Set<String> defaultFieldsToTrack = new Set<String>{
				'Id', 'OwnerId', 'Owner.Name'
		};
		if (parentHasRecordTypes) {
			defaultFieldsToTrack.add('RecordTypeId');
		}
		if (parentHasBusinessHoursId) {
			defaultFieldsToTrack.add('BusinessHoursId');
		}

		if (objectFieldsToTrack != null && !objectFieldsToTrack.isEmpty()) {
			defaultFieldsToTrack.addAll(objectFieldsToTrack);
		}
		String query = 'SELECT ' + String.join((Iterable<String>) defaultFieldsToTrack, ',');

		query += ' FROM ' + parentObjName + ' Where Id IN ';
		query += '(\'' + String.join(new List<Id>(objectRecordIdSet), '\',\'') + '\')';
		List<SObject> parentRecordsList = Database.query(query);
		Map<Id, String> updatedParentOwnerMap = new Map<Id, String>();
		Map<Id, Id> updatedParentOwnerUserMap = new Map<Id, Id>();

		for (SObject obj : parentRecordsList) {
			Boolean flag = false;
			if (closedTimeLogsByParent.containsKey(obj.Id)) {
				flag = true; // We've already updated this time log, therefore no need to check other criteria make sure it's up to date
			}

			Id recTypeId = null;
			if (parentHasRecordTypes) {
				recTypeId = (Id) obj.get('RecordTypeId');
			}
			//filter out records based on Record Type
			Boolean includeRecordType = false;
			if (todft_FieldLoggerUtils.recordTypeSettingsByObject != null && todft_FieldLoggerUtils.recordTypeSettingsByObject.containsKey(parentObjName)) {
				Schema.RecordTypeInfo rt = null;
				if (recTypeId != null) {
					rt = recordTypesById.get(recTypeId);
				}

				for (Trigger_Record_Type__mdt setting : todft_FieldLoggerUtils.recordTypeSettingsByObject.get(parentObjName)) {
					if (rt != null) {
						if ((setting.Record_Type_Name__c == 'Master' && setting.Enable__c == true && rt.getDeveloperName() == 'Master') || (setting.Record_Type_Name__c == rt.getDeveloperName() && setting.Enable__c == true)) {
							includeRecordType = true;
							break;
						}
					} else {
						if (setting.Record_Type_Name__c == 'Master' && setting.Enable__c == true) {
							includeRecordType = true;
						}
					}
				}
			}
			if (!includeRecordType) {
				continue; //skip over records with excluded record types
			}

			// If already set to true ignore logic to improve efficiency
			if (!flag) {
				if (oldParentMap != null && !oldParentMap.isEmpty()) {
					// Check owner change
					if (oldParentMap.get(obj.Id).get('OwnerId') != obj.get('OwnerId')) {
						flag = true;
					}

					//update scenario
					if (todft_FieldLoggerUtils.settingsByObject != null && todft_FieldLoggerUtils.settingsByObject.containsKey(parentObjName)) {
						for (Field_Tracker_Mapping__mdt setting : todft_FieldLoggerUtils.settingsByObject.get(parentObjName)) {
							if (String.valueOf(oldParentMap.get((Id) obj.get('Id')).get(setting.Parent_Record_Field__c)) != String.valueOf(obj.get(setting.Parent_Record_Field__c))) {
								flag = true;
							}
						}
					}
				} else {
					//new parent record (insertion scenario)
					flag = true;
					isParentRecordCreated = true;
				}
			}
			if (flag) {
				// Update owner on time log
				if (obj.getSobject('Owner') != null) {
					String OwnerName = (String) obj.getSobject('Owner').get('Name');
					String OwnerId = (Id) obj.getSObject('Owner').get('Id');
					updatedParentOwnerMap.put((Id) obj.get('Id'), OwnerName);
					updatedParentOwnerUserMap.put((Id) obj.get('Id'), OwnerId);
				}
				parentRecordList.add(obj);
			}
		}

		parentSObjectName = parentObjName;
		// Remove the __c from any parents which are custom objects as the lookup field on Time Logs will have __c regardless
		if (parentObjName.endsWith(SFDC_SUFFIX)) {
			parentObjName = parentObjName.substringBefore(SFDC_SUFFIX);
		}

		if (parentRecordList != null && !parentRecordList.isEmpty()) {
			// If we haven't already, close any existing time logs
			closeExistingTimeLogs(parentRecordList, parentObjName, timeLogObjName, updatedParentOwnerMap, updatedParentOwnerUserMap);
		}

		// Process records - create or update Time Log for each parent record for current execution
		for (SObject obj : parentRecordList) {

			// Create an instance of time log object
			SObject tl = newTimeLogsByParent.get(obj.Id);
			if (tl == null) {
				tl = timeLogType.newSObject();
			}

			// Set static Time Log fields
			tl.put(parentObjName + SFDC_SUFFIX, obj.Id);    // Set lookup field to parent object

			//SNAPSHOT-80 - Set the owner of the Time Log records to the UserID specified in custom setting ("Field Tracker Settings")
			//or the current running user, if the custom setting field is blank.
			Field_Tracker_Settings__c fieldSetting = Field_Tracker_Settings__c.getOrgDefaults();
			if (fieldSetting != null && String.isNotBlank(fieldSetting.Time_Log_Owner__c)) {
				String userOrGroupId = fieldSetting.Time_Log_Owner__c;
				String userOrGroupPrefix = userOrGroupId.substring(0, 3);
				if (userOrGroupPrefix == User.sObjectType.getDescribe().getKeyPrefix() || userOrGroupPrefix == Group.sObjectType.getDescribe().getKeyPrefix()) {
					tl.put('OwnerId', userOrGroupId);
				} else {
					// Set time log owner to that of current object's owner
					tl.put('OwnerId', UserInfo.getUserId());
				}
			} else {
				// Set time log owner to that of current object's owner
				tl.put('OwnerId', UserInfo.getUserId());
			}

			//SNAPSHOT-5 - Track Owner Type of parent record (User vs. Queue)
			//Made changes by Rishabh for tracking owner type of parent record.
			String ownerId = (String) obj.get('OwnerId');
			String ownerPrefix = ownerId.substring(0, 3);
			if (ownerPrefix == Group.sObjectType.getDescribe().getKeyPrefix()) {
				//owner is Queue
				tl.put('Owner_Type__c', 'Queue');
				tl.put('Parent_Owner_User__c', null);
			} else if (ownerPrefix == User.sObjectType.getDescribe().getKeyPrefix()) {
				//owner is User
				tl.put('Owner_Type__c', 'User');
				if (ownerId != null) {
					tl.put('Parent_Owner_User__c', ownerId);
				}
			}
			tl.put('Start_Time__c', NOW);
			if (obj.getSobject('Owner') != null) {
				tl.put('Parent_Owner__c', (String) obj.getSobject('Owner').get('Name'));
			}
			tl.put('Parent_Owner_New__c', '');
//			tl.put('Parent_Owner_User_New__c', '');
			if (todft_FieldLoggerUtils.settingsByObject != null && todft_FieldLoggerUtils.settingsByObject.containsKey(parentSObjectName)) {
				// Set dynamic Time Log fields
				List<Field_Tracker_Mapping__mdt> settings = todft_FieldLoggerUtils.settingsByObject.get(parentSObjectName);
				for (Field_Tracker_Mapping__mdt setting : settings) {
					// Set rest of the relevant fields
					try {
						Object currValue = obj.get(setting.Parent_Record_Field__c);
						if (currValue == null) {
							currValue = 'NULL';
						}
						tl.put(setting.Time_Log_Field_Mapping__c, currValue);
					} catch (SObjectException e) {
					}
				}
			}
			newTimeLogsByParent.put(obj.Id, tl);
		}
		// upsert time logs (upsert must be performed on a concrete entity type)

		todft_FieldLoggerUtils.dynamicUpsert(newTimeLogsByParent.values(), timeLogType, parentRecordList);

		if (parentRecordList != null && !parentRecordList.isEmpty()) {
			// If we haven't already, close any existing time logs
			updateOwnerNewTimeLogs(parentRecordList, parentObjName, timeLogObjName, updatedParentOwnerMap, updatedParentOwnerUserMap);
		}
	}

	private static void updateOwnerNewTimeLogs(List<SObject> parentRecords, String parentObjName, String timeLogObjName, Map<Id, String> updatedParentOwnerMap, Map<Id, Id> updatedParentOwnerUserMap) {
		//Changes done by Rishabh for SNAPSHOT-3
		// Make a map of parent objects
		Map<Id, SObject> parentSObjectMap = new Map<Id, SObject>();
		for (SObject obj : parentRecords) {
			parentSObjectMap.put(obj.Id, obj);
		}
		// Get all related existing time logs for parent records
		String lookupField = parentObjName + SFDC_SUFFIX;
		String queryWhereClause = ' WHERE ' + lookupField + ' IN (\'' + String.join(new List<Id>(parentSObjectMap.keySet()), '\', \'') + '\')';

		if (updatedParentOwnerMap != null && !updatedParentOwnerMap.isEmpty()) {
			//updating Owner New field on case time log when owner changes
			//SNAPSHOT-33,SNAPSHOT-50 - Updates OwnerId on the Time Log record when it "closes"
			String queryStringToOwnerUpdate = 'SELECT Id, Name, Start_Time__c, Owner.Name, End_Time__c, Parent_Owner_New__c, Parent_Owner__c, Parent_Owner_User__c, Parent_Owner_User_New__c, '
					+ lookupField
					+ ' FROM '
					+ timeLogObjName
					+ queryWhereClause + ' AND End_Time__c != NULL ORDER BY Start_Time__c, Name';
			//Get updated ownerId after running assignment rule updation
			//SNAPSHOT-50 : The New Owner field displays the incorrect owner ID when the new owner is a queue
			//Querying Updated ownerId from parentRecord
			List<SObject> tailTimeLogsToOwnerUpdate = (List<SObject>) Database.query(queryStringToOwnerUpdate);
			Map<Id, SObject> parentIdToChildRecordMap = new Map<Id, SObject>();
			for (SObject timeLog : tailTimeLogsToOwnerUpdate) {
				parentIdToChildRecordMap.put((Id) timeLog.get(lookupField), timeLog);
			}
			List<SObject> timeLogRecordToUpdate = new List<SObject>();
			timeLogRecordToUpdate = parentIdToChildRecordMap.values();
			for (SObject timeLog : timeLogRecordToUpdate) {
				if (updatedParentOwnerMap.containsKey((Id) timeLog.get(lookupField))) {
					timeLog.put('Parent_Owner_New__c', updatedParentOwnerMap.get((Id) timeLog.get(lookupField)));
				} else {
					timeLog.put('Parent_Owner_New__c', timeLog.get('Parent_Owner__c'));
				}
				if (updatedParentOwnerUserMap.containsKey((Id) timeLog.get(lookupField))) {
					// if it's a User then update the Parent_Owner_User_New__c field
					String newOwnerId = (String) updatedParentOwnerUserMap.get((Id) timeLog.get(lookupField));
					String newOwnerPrefix = newOwnerId.substring(0, 3);
					if (newOwnerPrefix == User.sObjectType.getDescribe().getKeyPrefix()) {
						timeLog.put('Parent_Owner_User_New__c', (Id) newOwnerId);
					}
				} else {
					// if it's a User then update the Parent_Owner_User_New__c field
					Object userId = timeLog.get('Parent_Owner_User__c');
					String newOwnerId = (String) userId;
					String newOwnerPrefix = newOwnerId.substring(0, 3);
					if (newOwnerPrefix == User.sObjectType.getDescribe().getKeyPrefix()) {
						timeLog.put('Parent_Owner_User_New__c', (Id) newOwnerId);
					}
				}
			}

			if (timeLogRecordToUpdate != null && !timeLogRecordToUpdate.isEmpty()) {
				update timeLogRecordToUpdate;
			}
		}
	}

	/**
	 * Close existing Time Logs
	 * @description To avoid SOQL and DML limits, only runs once per execution
	 * @param parentRecords - Records being processed
	 * @param parentObjName - The object type of the parent records (String)
	 * @param timeLogObjName - The object type of the time log records we are querying (String)
	 */
	private static void closeExistingTimeLogs(List<SObject> parentRecords, String parentObjName, String timeLogObjName, Map<Id, String> updatedParentOwnerMap, Map<Id, Id> updatedParentOwnerUserMap) {
		if (!isWorkAgent) {
			if (isParentRecordCreated) {
				return;
			}
		}

		//Changes done by Rishabh for SNAPSHOT-3
		// Make a map of parent objects
		Map<Id, SObject> parentSObjectMap = new Map<Id, SObject>();
		Set<Id> unclosedParents = new Set<Id>();
		List<SObject> tailTimeLogs = new List<SObject>();
		Map<Id, Id> businessHoursIdByParentId = new Map<Id, Id>();
		for (SObject obj : parentRecords) {
			parentSObjectMap.put(obj.Id, obj);
			if (closedTimeLogsByParent.containsKey(obj.Id)) {
				// Overwrite existing logs with new values
				tailTimeLogs.add(closedTimeLogsByParent.get(obj.Id));
			} else {
				// Need to query missing time logs
				unclosedParents.add(obj.Id);
			}
			if (parentHasBusinessHoursId) {
				Id businessHoursId = (Id) obj.get('BusinessHoursId');
				if (businessHoursId != null) {
					businessHoursIdByParentId.put(obj.Id, businessHoursId);
				}
			} else {
				businessHoursIdByParentId.put(obj.Id, defaultBusinessHour.get(0).Id);
			}
		}

		Map<Id, Id> timeLogIdToCaseIdMap = new Map<Id, Id>();
		String lookupField = parentObjName + SFDC_SUFFIX;

		if (!unclosedParents.isEmpty()) {
			// Get all related existing time logs for parent records
			String queryWhereClause = ' WHERE ' + lookupField;
			queryWhereClause += ' IN (\'' + String.join(new List<Id>(parentSObjectMap.keySet()), '\', \'') + '\')';

			String queryString = 'SELECT Id, Start_Time__c, Owner.Name, Name, Parent_Owner__c, Parent_Owner_User__c, '
					+ lookupField
					+ ' FROM '
					+ timeLogObjName
					+ queryWhereClause + ' AND End_Time__c = NULL';
			// Close existing time logs by setting end time
			tailTimeLogs.addAll((List<SObject>) Database.query(queryString));
		}

		for (SObject tl : tailTimeLogs) {
			closedTimeLogsByParent.put((Id) tl.get(lookupField), tl);
			if (!timeLogIdToCaseIdMap.containsKey((Id) tl.get('Id'))) {
				timeLogIdToCaseIdMap.put((Id) tl.get('Id'), (Id) tl.get(lookupField));
			}
			tl.put('End_Time__c', NOW);
			Datetime endDateTime = Datetime.valueOfGmt(string.valueOf(tl.get('End_Time__c')));
			Datetime startDateTime = Datetime.valueOfGmt(string.valueOf(tl.get('Start_Time__c')));
			Long endDateTimeLong = endDateTime.getTime();
			Long startDateTimeLong = startDateTime.getTime();
			Long milliseconds = endDateTimeLong - startDateTimeLong;
			Long calendarSeconds = milliseconds / 1000;
			tl.put('Calendar_Duration__c', (Integer) calendarSeconds);

			Id businessHoursId = businessHoursIdByParentId.get((Id) tl.get(lookupField));
			// using SObject business hours
			if (businessHoursId != null) {
				Datetime endDateTimeGMT = Datetime.valueOfGmt(string.valueOf(tl.get('End_Time__c')));
				Datetime startDateTimeGMT = Datetime.valueOfGmt(string.valueOf(tl.get('Start_Time__c')));
				Long businessHoursDuration = Math.abs(BusinessHours.diff(businessHoursId, startDateTimeGMT, endDateTimeGMT) / 1000);
				tl.put('Business_Hours_Duration__c', (Decimal) businessHoursDuration);
			}
			// using company default business hours
			else if (defaultBusinessHour != null && !defaultBusinessHour.isEmpty()) {
				businessHoursId = defaultBusinessHour.get(0).Id;
				Long businessHoursDuration = Math.abs(BusinessHours.diff(businessHoursId, startDateTime, endDateTime) / 1000);
				tl.put('Business_Hours_Duration__c', (Decimal) businessHoursDuration);
			}
			if (todft_FieldLoggerUtils.settingsByObject.containsKey(parentSObjectName)) {
				for (Field_Tracker_Mapping__mdt setting : todft_FieldLoggerUtils.settingsByObject.get(parentSObjectName)) {
					if (parentSObjectMap != null && !parentSObjectMap.isEmpty() && parentSObjectMap.containsKey((Id) tl.get(lookupField))) {
						Object newValue = parentSObjectMap.get((Id) tl.get(lookupField)).get(setting.Parent_Record_Field__c);
						if (newValue == null) {
							newValue = 'NULL';
						}
						tl.put(setting.Time_Log_Field_New_Value__c, newValue);
					}
				}
			}
			// Iterate through each returned result
			// updating Owner New field on case time log when owner changes
			//SNAPSHOT-33,SNAPSHOT-50 - Updates OwnerId on the Time Log record when it "closes"
			Id parentId = timeLogIdToCaseIdMap.get((Id) tl.get('Id'));
			if (updatedParentOwnerMap.containsKey(parentId)) {
				tl.put('Parent_Owner_New__c', updatedParentOwnerMap.get(parentId));
			} else {
				tl.put('Parent_Owner_New__c', tl.get('Parent_Owner__c'));
			}
			if (updatedParentOwnerUserMap.containsKey(parentId)) {
				// if it's a User then update the Parent_Owner_User_New__c field
				String newOwnerId = (String) updatedParentOwnerMap.get(parentId);
				String newOwnerIdPrefix = newOwnerId.substring(0, 3);
				if (newOwnerIdPrefix == User.sObjectType.getDescribe().getKeyPrefix()) {
					tl.put('Parent_Owner_User_New__c', updatedParentOwnerMap.get(parentId));
				}
			} else {
				// if it's a User then update the Parent_Owner_User_New__c field
				String newOwnerId = (String) tl.get('Parent_Owner_User__c');
				String newOwnerIdPrefix = newOwnerId.substring(0, 3);
				if (newOwnerIdPrefix == User.sObjectType.getDescribe().getKeyPrefix()) {
					tl.put('Parent_Owner_User_New__c', (Id) newOwnerId);
				}
			}
		}
		if (tailTimeLogs != null && !tailTimeLogs.isEmpty()) {
			update tailTimeLogs;
		}
	}
}