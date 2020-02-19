/**
 * @description A class used to maintain a roll up relationship by recalculating
 * the rollup after every change. This approach uses lots of DML rows. A benefit
 * of this approach is that if the update to the parent roll up field fails then
 * the roll up will potentially be corrected on the next update.
 * @author John Rogers, Traction on Demand
 * @group Custom Roll Ups
 * @date 2016-02-09
 */
public abstract class TLRollUp extends TLRollUpAbstract {

    @TestVisible private static Map<Id, AggregateResult> aggregateResultMock;

    /**
     * @description Register a child that has been created. If a child
     * was part of a roll up then its parent will be added to the list
     * of parents that will have this roll up recalculated
     * @author John Rogers, Traction on Demand
     * @date        2016-03-23
     * @param       child   The new child
     */
    public override void registerNewChild(SObject child) {
        if(fitsRollUpCriteria(child)) {
            // Child has been added to the roll up
            parentIds.add((Id) child.get(lookupField));
        }
    }

    /**
     * @description Register a child that has been deleted.  If the child was
     * part of the roll up then its parent will be added the list of parents
     * that will have this roll up recalculated.
     * @author John Rogers, Traction on Demand
     * @date        2016-03-23
     * @param       child   The deleted child
     */
    public override void registerDeletedChild(SObject child) {
        if(fitsRollUpCriteria(child)) {
            // Child has been removed from the roll up
            parentIds.add((Id) child.get(lookupField));
        }
    }

    /**
     * @description Register a modified child. Depending on the changes the child's
     * new parent or old parent may be be added the list of parents that will have
     * this roll up recalculated.
     * @author John Rogers, Traction on Demand
     * @date        2016-03-23
     * @param       newChild   The child after the update
     * @param       oldChild   The child prior to the update
     */
    public override void registerModifiedChild(SObject newChild, SObject oldChild) {
        Boolean newFitsRollUpCriteria = fitsRollUpCriteria(newChild);
        Boolean oldFitsRollUpCriteria = fitsRollUpCriteria(oldChild);

        // If the lookup field has changed
        if (oldChild.get(lookupField) != newChild.get(lookupField)) {
            if (newFitsRollUpCriteria) {
                // Added to new parent's roll up
                parentIds.add((Id) newChild.get(lookupField));
            }

            if (oldFitsRollUpCriteria) {
                // Removed from old parent's roll up
                parentIds.add((Id) oldChild.get(lookupField));
            }
            return;
        }

        // If the child has been added/removed from the roll up
        if (newFitsRollUpCriteria != oldFitsRollUpCriteria) {
            if (newFitsRollUpCriteria) {
                // Child has been added to roll up
                parentIds.add((Id) newChild.get(lookupField));
            } else {
                // Child has been removed from the roll up
                parentIds.add((Id) oldChild.get(lookupField));
            }
            return;
        }

        // If the child fits the criteria and the roll up field has changed
        for (TLRollUpAbstract.RollUpRelationship rur : rollUpRelationships) {
            if (newFitsRollUpCriteria && oldChild.get(rur.childField) != newChild.get(rur.childField)) {
                // Child in roll up has been modified
                parentIds.add((Id) newChild.get(lookupField));
            }
        }
    }

    /**
     * @description Performs roll up operations and returns the updated parents
     * @author John Rogers, Traction on Demand
     * @date        2016-05-02
     * @return      The update parent records
     */
    public override List<SObject> updateRollUp() {
        Map<Id, AggregateResult> results = getAggregateResults();

        List<SObject> parents = new List<SObject>();
        parentIds.remove(null);
        for (Id parentId : parentIds) {
            SObject parent = parentType.newSObject();
            parent.Id = parentId;
            AggregateResult result = results.get(parentId);

            if (result != null) {
                Integer i = 0;
                for (TLRollUpAbstract.RollUpRelationship ru : rollUpRelationships) {
                    // Expr[integer] aggregate results are mapped to the rollUpRelationship list order
                    setParentField(parent, ru.parentField, result.get('expr' + i++));
                }
                // If there was no result then there are no children
            } else {
                for (TLRollUpAbstract.RollUpRelationship ru : rollUpRelationships) {
                    setParentField(parent, ru.parentField, ru.getNoChildrenValue());
                }
            }

            parents.add(parent);
        }

        return parents;
    }

    /**
     * @author John Rogers, Traction on Demand
     * @date        2016-05-02
     * @return A map of parentIds to the aggregate result containing the roll up values
     */
    private Map<Id, AggregateResult> getAggregateResults() {
        if (parentIds.isEmpty()) {
            return new Map<Id, AggregateResult>();
        }
        String lookupFieldName = lookupField.getDescribe().getName();
        String query = 'SELECT ';

        List<String> selectClauses = new List<String> { lookupFieldName };
        for (TLRollUpAbstract.RollUpRelationship ru : rollUpRelationships) {
            selectClauses.add(ru.getSelectClause());
        }
        query += String.join(selectClauses, ',');

        query += 'FROM ' + childType.getDescribe().getName() + ' ';
        query += 'WHERE ' + lookupFieldName + ' IN :parentIds ';

        if (!String.isBlank(rollUpCriteriaClause)) {
            query += 'AND (' + rollUpCriteriaClause + ') ';
        }

        query += 'GROUP BY ' + lookupFieldName;

        List<AggregateResult> results = Database.query(query);
        Map<Id, AggregateResult> resultMap = new Map<Id, AggregateResult>();
        for (AggregateResult ru : results) {
            resultMap.put((Id) ru.get(lookupFieldName), ru);
        }

        return (aggregateResultMock != null) ? aggregateResultMock : resultMap;
    }
}