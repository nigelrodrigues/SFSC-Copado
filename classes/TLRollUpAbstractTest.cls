/**
 * @description Generic tests for roll ups
 * @group Test Utilities
 * @author John Rogers, Traction on Demand
 * @modified Jeremy Horan, Traction on Demand, 2018-11-07
 *           Wont be used unless you need to test a roll up specifically with DML
 * @date 10-02-2016
 */
public abstract class TLRollUpAbstractTest {

//    // Value used for testing min roll ups
//    private static Integer minValue = -10000;
//
//    // Value used for testing max roll ups
//    private static Integer maxValue = 10000;
//
//    // Subject of the tests
//    public TLRollUpAbstract theRollUp;
//
//    // The number of children to create during typical test
//    public Integer numChildren = 3;
//
//    // The number of parents to create during bulk test
//    public Integer numParentsBulk = 1;
//
//    // The number of children to create during bulk test
//    public Integer numChildrenBulk = 9;
//
//    /**
//     * @description Build a list of children records with a common parent
//     * @author John Rogers, Traction on Demand
//     * @date   2015-12-04
//     * @return The children records
//     */
//    public List<SObject> setup() {
//        return setup(numChildren);
//    }
//
//    /**
//     * @description Build a list of children records with a common parent
//     * @author John Rogers, Traction on Demand
//     * @date   2015-12-04
//     * @param  numChildren Number of records to create
//     * @return The children records
//     */
//    public virtual List<SObject> setup(Integer childCount) {
//        List<SObject> children  = getNewChildren(childCount);
//
//        SObject parent = getNewParent();
//        insert parent;
//
//        for(SObject child : children) {
//            child.put(theRollUp.lookupField, parent.Id);
//            impactRollUp(child);
//            makeFitRollUpCriteria(child);
//        }
//
//        return children;
//    }
//
//    /**
//     * @author John Rogers, Traction on Demand
//     * @date        2016-03-01
//     * @return The given number of children records (not inserted into database)
//     */
//    public abstract List<SObject> getNewChildren(Integer count);
//
//    /**
//     * @author John Rogers, Traction on Demand
//     * @date        2016-03-01
//     * @return A new parent record with roll up field set to 0 (not inserted into database)
//     */
//    public abstract SObject getNewParent();
//
//    /**
//     * @description Makes the given record fit the roll up criteria (so it is included in the roll up)
//     * @author John Rogers, Traction on Demand
//     * @date        2016-03-01
//     * @param       obj The record
//     */
//    public virtual void makeFitRollUpCriteria(SObject obj) { }
//
//    /**
//     * @description Makes the given record not fit the roll up criteria (so it is not included in the roll up)
//     * @author John Rogers, Traction on Demand
//     * @date        2016-03-01
//     * @param       obj The record
//     */
//    public virtual void makeNotFitRollUpCriteria(SObject obj) { }
//
//    // Test the filtering functionality
//    public void test_rollup_filter_remove() {
//        if (theRollUp.rollUpCriteriaClause == null) {
//            return; // Nothing to do
//        }
//
//        List<SObject> objs = setup();
//        insert objs;
//
//        // Make first record impact the roll up
//        impactRollUp(objs[0]);
//
//        // Make first value not fit the filter criteria
//        makeNotFitRollUpCriteria(objs[0]);
//        update objs[0];
//
//        // Remove first value
//        objs.remove(0);
//
//        // Assert that the roll up occurred
//        doAsserts(objs);
//    }
//
//    public void test_rollup_filter_add() {
//        if (theRollUp.rollUpCriteriaClause == null) {
//            return; // Nothing to do
//        }
//
//        List<SObject> objs = setup();
//        insert objs;
//
//        // Make first record impact the roll up
//        impactRollUp(objs[0]);
//
//        // Make first value not fit the filter criteria
//        makeNotFitRollUpCriteria(objs[0]);
//        update objs[0];
//
//        // Make first value fit the filter criteria
//        makeFitRollUpCriteria(objs[0]);
//        update objs[0];
//
//        // Assert that the roll up occurred
//        doAsserts(objs);
//    }
//
//    public void test_rollup_lookupField_change() {
//        List<SObject> objs = setup();
//        insert objs;
//
//        // Make first two records impact the roll up
//        impactRollUp(objs[0]);
//        impactRollUp(objs[1]);
//
//        // Change the parent of the first two records
//        SObject newParent = getNewParent();
//        insert newParent;
//        objs[0].put(theRollUp.lookupField, newParent.Id);
//        objs[1].put(theRollUp.lookupField, newParent.Id);
//        // Remove new parent's children and put into new list
//        List<SObject> newParentChildren = new List<SObject> { objs.remove(0), objs.remove(0) };
//        update newParentChildren;
//
//        // Assert that roll ups on the two parents are correct
//        doAsserts(objs);
//        doAsserts(newParentChildren);
//    }
//
//    public void test_roll_up_on_insert() {
//        List<SObject> objs = setup();
//        insert objs;
//
//        // Assert that the roll up occurred
//        doAsserts(objs);
//    }
//
//    public void test_roll_up_on_update() {
//        List<SObject> objs = setup();
//        insert objs;
//
//        impactRollUp(objs[0]);
//        update objs[0];
//
//        // Assert that the roll up occurred
//        doAsserts(objs);
//    }
//
//    public void test_roll_up_on_delete() {
//        List<SObject> objs = setup();
//        insert objs;
//
//        impactRollUp(objs[0]);
//        update(objs[0]);
//
//        // Remove first value
//        delete objs[0];
//        objs.remove(0);
//
//        // Assert that the roll up occurred
//        doAsserts(objs);
//    }
//
//    public void test_roll_up_on_delete_all() {
//        List<SObject> objs = setup();
//        insert objs;
//
//        // Remove all children
//        delete objs;
//
//        // Assert that the roll up occurred
//        doAsserts(getParent(objs[0]), new List<SObject>());
//    }
//
//    public void test_roll_up_on_undelete() {
//        List<SObject> objs = setup();
//        insert objs;
//
//        impactRollUp(objs[0]);
//        update(objs[0]);
//
//        // Remove first value
//        delete objs[0];
//
//        // Undelete first value
//        undelete objs[0];
//
//        // Assert that the roll up occurred
//        doAsserts(objs);
//    }
//
//    public void test_merge() {
//        if (theRollUp.parentType != Lead.getSObjectType() &&
//                theRollUp.parentType != Account.getSObjectType() &&
//                theRollUp.parentType != Contact.getSObjectType()) {
//            return; // Can't merge this type of parent
//        }
//        List<SObject> children1 = setup();
//        List<SObject> children2 = setup();
//        List<SObject> allChildren = new List<SObject>();
//        allChildren.addAll(children1);
//        allChildren.addAll(children2);
//        insert allChildren;
//
//        // Merge the parents
//        SObject parent1 = getParent(children1[0]);
//        SObject parent2 = getParent(children2[0]);
//
//        Test.startTest();
//            if (parent1.getSObjectType() == Contact.getSObjectType()) {
//                //// Do person account merge if appropriate
//                //Map<Id, Contact> contacts = new Map<Id, Contact>([
//                //    SELECT AccountId
//                //    FROM Contact
//                //    WHERE Id = :parent1.Id OR Id = :parent2.Id
//                //]);
//                //Contact c1 = contacts.get(parent1.Id);
//                //Contact c2 = contacts.get(parent2.Id);
//
//                //Map<Id, Account> accs = new Map<Id, Account> ([
//                //    SELECT Id
//                //    FROM Account
//                //    WHERE IsPersonAccount = true
//                //        AND (Id = :c1.AccountId OR Id = :c2.AccountId)
//                //]);
//                //if (!accs.isEmpty()) {
//                //    merge accs.get(c1.AccountId) accs.get(c2.AccountId);
//                //} else {
//                    merge ((Contact) parent1) ((Contact) parent2);
//                //}
//            } else if (parent1.getSObjectType() == Account.getSObjectType()) {
//                merge ((Account) parent1) ((Account) parent2);
//            } else if (parent1.getSObjectType() == Lead.getSObjectType()) {
//                merge ((Lead) parent1) ((Lead) parent2);
//            }
//        Test.stopTest(); // Recacluate using batch job
//
//        doAsserts(allChildren);
//    }
//
//    public void test_bulk() {
//        List<SObject> parents = new List<SObject>();
//        for (Integer i = 0; i < numParentsBulk; i++) {
//            parents.add(getNewParent());
//        }
//        insert parents;
//
//        Map<Id, List<SObject>> parentToChildren = new Map<Id, List<SObject>>();
//        List<SObject> childrenToInsert = new List<SObject>();
//        for (SObject parent : parents) {
//            List<SObject> children  = getNewChildren(numChildrenBulk);
//
//            Integer count = 0;
//            for(SObject child : children) {
//                count += 1;
//                child.put(theRollUp.lookupField, parent.Id);
//                impactRollUp(child);
//                makeFitRollUpCriteria(child);
//            }
//            parentToChildren.put(parent.Id, children);
//            childrenToInsert.addAll(children);
//        }
//
//        Test.startTest();
//            insert childrenToInsert;
//        Test.stopTest();
//
//        // Assert that the roll ups occurred
//        parents = getParents(childrenToInsert).values();
//        for (SObject parent : parents) {
//            doAsserts(parent, parentToChildren.get(parent.Id));
//        }
//    }
//
//    /**
//     * @description Modifies the given child record so that will impact the roll up when updated
//     * @author John Rogers, Traction on Demand
//     * @date        2016-03-29
//     * @param       child The child
//     */
//    private void impactRollUp(SObject child) {
//        for (TLRollUpAbstract.RollUpRelationship rur : theRollUp.rollUpRelationships) {
//            if (rur.ruType == TLRollUpAbstract.RollUpType.SUM) {
//                Double value = Double.valueOf(child.get(rur.childField));
//                if (value == null) {
//                    value = 1;
//                }
//                child.put(rur.childField, value + 1); // Add one to the sum
//            } else if (rur.ruType == TLRollUpAbstract.RollUpType.MIN) {
//                child.put(rur.childField, --minValue);
//            } else if (rur.ruType == TLRollUpAbstract.RollUpType.MAX) {
//                child.put(rur.childField, ++maxValue);
//            } else if (rur.ruType == TLRollUpAbstract.RollUpType.COUNT) {
//                // Nothing to do
//            } else {
//                System.assert(false, 'Roll up type ' + rur.ruType + ' not supported');
//            }
//        }
//    }
//
//    /**
//     * @author John Rogers, Traction on Demand
//     * @date   2015-12-09
//     * @param  child The child
//     * @return The parent record of the given child
//     */
//    private SObject getParent(SObject child) {
//        Id pid = (Id) child.get(theRollUp.lookupField);
//        return Database.query('' +
//            'SELECT ' + String.join(theRollUp.getParentFields(), ',') + ' ' +
//            'FROM ' + theRollUp.parentType.getDescribe().getName() + ' ' +
//            'WHERE Id=:pid'
//        )[0];
//    }
//
//    /**
//     * @author John Rogers, Traction on Demand
//     * @date   2015-12-09
//     * @param  children The children
//     * @return The parent records of the given children
//     */
//    private Map<Id, SObject> getParents(List<SObject> children) {
//        Set<Id> pids = new Set<Id>();
//        for (SObject child : children) {
//            pids.add((Id) child.get(theRollUp.lookupField));
//        }
//        return new Map<Id, SObject> (Database.query('' +
//            'SELECT ' + String.join(theRollUp.getParentFields(), ',')  + ' ' +
//            'FROM ' + theRollUp.parentType.getDescribe().getName() + ' ' +
//            'WHERE Id IN :pids'
//        ));
//    }
//
//    /**
//     * @description Assert that the roll up values for the given records' parent is correct
//     * @author John Rogers, Traction on Demand
//     * @date        2016-03-01
//     * @param       objs The child records
//     */
//    private void doAsserts(List<SObject> objs) {
//        doAsserts(getParent(objs[0]), objs);
//    }
//
//    /**
//     * @description Assert that the roll up values for the given records' parent is correct
//     * @author John Rogers, Traction on Demand
//     * @date        2016-03-01
//     * @param       parent The parent as stored in database (just queried)
//     * @param       objs The child records
//     */
//    private void doAsserts(SObject parent, List<SObject> objs) {
//        for (TLRollUpAbstract.RollUpRelationship rur : theRollUp.rollUpRelationships) {
//            if (rur.ruType == TLRollUpAbstract.RollUpType.SUM) {
//                doSumAsserts(parent, objs, rur);
//            } else if (rur.ruType == TLRollUpAbstract.RollUpType.COUNT) {
//                doCountAsserts(parent, objs, rur);
//            } else if (rur.ruType == TLRollUpAbstract.RollUpType.MIN) {
//                doMinAsserts(parent, objs, rur);
//            } else if (rur.ruType == TLRollUpAbstract.RollUpType.MAX) {
//                doMaxAsserts(parent, objs, rur);
//            } else {
//                System.assert(false);
//            }
//        }
//    }
//    /**
//     * @description Assert that the roll up values for the given records' parent is correct
//     * @author John Rogers, Traction on Demand
//     * @date        2016-03-01
//     * @param       parent The parent as stored in database (just queried)
//     * @param       objs The child records
//     * @param       rur The relationship to assert is correct
//     */
//    private void doSumAsserts(SObject parent, List<SObject> objs, TLRollUpAbstract.RollUpRelationship rur) {
//        System.assertNotEquals(null, parent.get(rur.parentField));
//        System.assertEquals(getSum(objs, rur.childField), parent.get(rur.parentField));
//    }
//
//    /**
//     * @description Assert that the roll up values for the given records' parent is correct
//     * @author John Rogers, Traction on Demand
//     * @date        2016-03-01
//     * @param       parent The parent as stored in database (just queried)
//     * @param       objs The child records
//     * @param       rur The relationship to assert is correct
//     */
//    private void doCountAsserts(SObject parent, List<SObject> objs, TLRollUpAbstract.RollUpRelationship rur) {
//        System.assertNotEquals(null, parent.get(rur.parentField));
//        System.assertEquals(objs.size(), parent.get(rur.parentField));
//    }
//
//    /**
//     * @description Assert that the roll up values for the given records' parent is correct
//     * @author John Rogers, Traction on Demand
//     * @date        2016-03-01
//     * @param       parent The parent as stored in database (just queried)
//     * @param       objs The child records
//     * @param       rur The relationship to assert is correct
//     */
//    private void doMinAsserts(SObject parent, List<SObject> objs, TLRollUpAbstract.RollUpRelationship rur) {
//        if (objs.isEmpty()) {
//            System.assertEquals(null, parent.get(rur.parentField));
//        } else {
//            System.assertNotEquals(null, parent.get(rur.parentField));
//            System.assertEquals(getMin(objs, rur.childField), parent.get(rur.parentField));
//        }
//    }
//
//    /**
//     * @description Assert that the roll up values for the given records' parent is correct
//     * @author John Rogers, Traction on Demand
//     * @date        2016-03-01
//     * @param       parent The parent as stored in database (just queried)
//     * @param       objs The child records
//     * @param       rur The relationship to assert is correct
//     */
//    private void doMaxAsserts(SObject parent, List<SObject> objs, TLRollUpAbstract.RollUpRelationship rur) {
//        if (objs.isEmpty()) {
//            System.assertEquals(null, parent.get(rur.parentField));
//        } else {
//            System.assertNotEquals(null, parent.get(rur.parentField));
//            System.assertEquals(getMax(objs, rur.childField), parent.get(rur.parentField));
//        }
//    }
//
//    /**
//     * @author John Rogers, Traction on Demand
//     * @date   2015-12-04
//     * @param  objs records to read from
//     * @param  field field to sum
//     * @return The sum of the values in the given field
//     */
//    private static Double getSum(List<SObject> objs, SObjectField field) {
//        Double sum = 0;
//        for (SObject obj : objs) {
//            sum += (Double) obj.get(field);
//        }
//        return sum;
//    }
//
//    /**
//     * @author John Rogers, Traction on Demand
//     * @date   2015-12-04
//     * @param  objs records to read from
//     * @param  field field to examine
//     * @return The minimum value in the given field
//     */
//    private static Double getMin(List<SObject> objs, SObjectField field) {
//        // Get minimum value
//        Double min = null;
//        for (SObject obj : objs) {
//            Double value = Double.valueOf(obj.get(field));
//            if (min == null || (value != null && value < min)) {
//                min = value;
//            }
//        }
//        return min;
//    }
//
//    /**
//     * @author John Rogers, Traction on Demand
//     * @date   2015-12-04
//     * @param  objs records to read from
//     * @param  field field to examine
//     * @return The maximum value in the given field
//     */
//    private static Double getMax(List<SObject> objs, SObjectField field) {
//        // Get maximum value
//        Double max = null;
//        for (SObject obj : objs) {
//            Double value = Double.valueOf(obj.get(field));
//            if (max == null || (value != null && value > max)) {
//                max = value;
//            }
//        }
//        return max;
//    }
}