/**
 *  @description Utilities for Query processing and generation
 *  @author      Jeremy Horan, Traction on Demand.
 *  @date        10/30/2018
 */
public class TLQuery {

    public static SObject selectAllFields(Id recordId) {
        Map<Id, SObject> resultsById = new Map<Id, SObject>(selectAllFields(new List<Id> {
                recordId
        }));
        return resultsById.containsKey(recordId) ? resultsById.get(recordId) : null;
    }

    public static List<SObject> selectAllFields(Set<Id> recordIds) {
        return selectAllFields(new List<Id>(
                recordIds
        ));
    }

    public static List<SObject> selectAllFields(List<Id> recordIds) {
        final SObjectType table = recordIds.get(0).getSobjectType();
        final TLQueryFactory query = new TLQueryFactory(table);
        for(SObjectField currentField : table.getDescribe().fields.getMap().values()) {
            if(currentField.getDescribe().isAccessible()) {
                query.selectField(currentField);
            }
        }
        query.setCondition('Id in :recordIds');
        return Database.query(query.toSOQL());
    }
}