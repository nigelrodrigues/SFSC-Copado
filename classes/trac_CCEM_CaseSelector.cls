/**
 *  @description Holds Queries for Case
 *  @author 	 Jeremy Horan, Traction on Demand.
 *  @date        2016-11-24
 */
public with sharing class trac_CCEM_CaseSelector {
    /**
     *  @description Returns a list of Cases with given IDs
     *  @author      Tanminder Rai, Traction on Demand.
     *  @date        2016-05-19
     */
    public static List<Case> getCasesByIds(Set<Id> caseIds, Set<String> fieldsToQuery){
        Set<String> requiredFields = new Set<String>{'Id', 'IsClosed', 'ClosedDate', 'Origin', 'Business_Unit__c'};

        fieldsToQuery.addAll(requiredFields);

        String query = 'SELECT ';

        for (String field : fieldsToQuery) {
            query += (field + ',');
        }
        query = query.removeEnd(',');

        query += ' FROM Case WHERE Id IN :caseIds';

        List<Case> cases = Database.query(query);
        return cases;
    }
}