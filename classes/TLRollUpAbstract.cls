/**
 * @description A roll up of child fields to parent fields. For examples see RollUps.
 * @author John Rogers, Traction on Demand
 * @group Custom Roll Ups
 * @date 2016-02-09
 *
 * WARNING - Roll ups require triggers to fire. Some operations do not fire triggers. See link below for the full list.
 *     https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_triggers_ignoring_operations.htm
 *     Important examples include:
 *         - contact deletion on merging of person accounts
 *         - lookup update of children after merge of leads, contacts or accounts
 *     these must be handled within the parent trigger. Using batch jobs is easiest, but not the most efficient method
 * WARNING - Eager roll ups use aggregate queries to do calculations. When the user's and organization's currency differ
 *      the aggregate query will return the result in the organization's currency.
 */
public abstract class TLRollUpAbstract {

    public static final String POLYMORPHIC_LOOKUP_EXCEPTION = 'More than one possible parent type on ' +
            'lookup field \'{0}\'. Parent type cannot be inferred.';

    public enum RollUpType {
        SUM,
        COUNT,
        MIN,
        MAX
    }

    public class RollUpRelationship {
        public RollUpType ruType;
        public SObjectField childField;
        public SObjectField parentField;
        public Boolean needsUpdate = true;
        public RollUpRelationship(RollUpType ruType, SObjectField childField, SObjectField parentField) {
            this.ruType = ruType;
            this.childField = childField;
            this.parentField = parentField;
        }

        /**
         * @author John Rogers, Traction on Demand
         * @date        2016-05-02
         * @return Aggregate command for query for this roll up relationship
         */
        public String getSelectClause() {
            return String.valueOf(ruType) + '(' + childField + ') ';
        }

        /**
         * @author John Rogers, Traction on Demand
         * @date        2016-05-02
         * @return The roll up value when there are no children
         */
        public Object getNoChildrenValue() {
            if (ruType == RollUpType.SUM || ruType == RollUpType.COUNT) {
                return 0;
            } else {
                return null;
            }
        }
    }

    // The various roll ups for this criteria and lookup field
    public List<RollUpRelationship> rollUpRelationships;

    // The field that relates the parent and the children
    public SObjectField lookupField;

    // The 'where' clause that describes the roll up criteria
    public String rollUpCriteriaClause;

    // The type of the child record
    public SObjectType childType {
        get {
            if (childType == null) {
                return childRelationship.getChildSObject();
            }
            return childType;
        }
    }

    // The type of the parent record
    public SObjectType parentType {
        get {
            if (parentType == null) {
                DescribeFieldResult fieldDescribe = lookupField.getDescribe();
                if (fieldDescribe.isNamePointing()) {
                    // More than one possible parent type, parentType must be manually set
                    List<String> formatArgs = new List<String> {
                            lookupField.getDescribe().getName()
                    };
                    throw new RollUpException(String.format(POLYMORPHIC_LOOKUP_EXCEPTION, formatArgs));
                }

                List<SObjectType> objs = fieldDescribe.getReferenceTo();
                parentType = objs[0];
            }
            return parentType;
        }
        set;
    }

    // The parent-child relationship
    public ChildRelationship childRelationship {
        get {
            if (childRelationship == null) {
                // Find the child relationship
                List<Schema.ChildRelationship> crs = parentType.getDescribe().getChildRelationships();
                for (Schema.ChildRelationship cr : crs) {
                    if (cr.getField() == lookupField) {
                        childRelationship = cr;
                    }
                }
            }
            return childRelationship;
        }
        set;
    }

    // The IDs of the parents to update
    public Set<Id> parentIds = new Set<Id>();

    // The name of the roll up operation
    public String name {
        get {
            if (name == null) {
                name = 'Roll up from ' + childType + ' to ' + parentType +
                        ' via lookup ' + childType + '.' + lookupField;

                if (rollUpCriteriaClause != null) {
                    name += ' if condition "(' + rollUpCriteriaClause + ')" is true';
                }
            }
            return name;
        }
        set;
    }

    @future
    public static void updateRollUp(String ruJson) {
        TLRollUpAbstract ru = (TLRollUpAbstract) JSON.deserializeUntyped(ruJson);
        update ru.updateRollUp();
    }

    /**
     * @author John Rogers, Traction on Demand
     * @date        2016-03-30
     * @return List of parent fields in the roll up relationship
     */
    public List<String> getParentFields() {
        Set<String> fields = new Set<String>();
        for (RollUpRelationship rur : rollUpRelationships) {
            fields.add(rur.parentField.getDescribe().getName());
        }
        List<String> ret = new List<String>();
        ret.addAll(fields);
        return ret;
    }

    /**
     * @author John Rogers, Traction on Demand
     * @date        2016-03-30
     * @return List of child fields in the roll up relationship
     */
    public List<String> getChildFields() {
        Set<String> fields = new Set<String>();
        for (RollUpRelationship rur : rollUpRelationships) {
            fields.add(rur.childField.getDescribe().getName());
        }
        List<String> ret = new List<String>();
        ret.addAll(fields);
        return ret;
    }


    /**
     * @description Prepares the roll up for serialzation by nullifying
     * non-serializable properties
     * @author John Rogers, Traction on Demand
     * @date 2016-02-11
     */
    public void prepForSerialization() {
        childRelationship = null;
    }

    /**
     * @description Returns true if the given child record fits the roll up
     * criteria
     * @author John Rogers, Traction on Demand
     * @date   2016-02-09
     * @param  obj The record
     * @return True if the child record fits the roll up criteria
     */
    public virtual Boolean fitsRollUpCriteria(SObject obj) {
        return true;
    }

    /**
     * @description Collects IDs of parents that need to be updated, then
     * updates those given parent records' roll up fields. To be called in an
     * "after" child trigger context.
     * @author John Rogers, Traction on Demand
     * @date   2016-02-09
     * @throws  RollUpException if not called in an "after" child trigger
     * context.
     * @return  parents The updated parent records
     */
    public List<SObject> execute() {
        assertCorrectTriggerContext();

        // Build parent IDs list
        if (Trigger.isDelete) {
            registerDeletedChildren(Trigger.old);
        } else if (Trigger.isInsert || Trigger.isUndelete) {
            registerNewChildren(Trigger.new);
        } else if (Trigger.isUpdate) {
            registerModifiedChildren(Trigger.new, Trigger.oldMap);
        }

        return updateRollUp();
    }

    /**
     * @description Register children that have been created. If a child
     * was part of a roll up then its parent will be added to the list
     * of parents that will have this roll up recalculated
     * @author John Rogers, Traction on Demand
     * @date        2016-03-23
     * @param       children   The new children
     */
    public void registerNewChildren(List<SObject> children) {
        for(SObject child : children) {
            registerNewChild(child);
        }
    }

    /**
     * @description Register a child that has been created. If a child
     * was part of a roll up then its parent will be added to the list
     * of parents that will have this roll up recalculated
     * @author John Rogers, Traction on Demand
     * @date        2016-03-23
     * @param       child   The new child
     */
    public abstract void registerNewChild(SObject child);

    /**
     * @description Register children that have been deleted.  If a child was
     * part of a roll up then its parent will be added the list of parents
     * that will have this roll up recalculated.
     * @author John Rogers, Traction on Demand
     * @date        2016-03-23
     * @param       children   The deleted children
     */
    public void registerDeletedChildren(List<SObject> children) {
        for(SObject child : children) {
            registerDeletedChild(child);
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
    public abstract void registerDeletedChild(SObject child);

    /**
     * @description Register modified children. Depending on the changes the child's
     * new parent or old parent may be be added the list of parents that will have
     * this roll up recalculated.
     * @author John Rogers, Traction on Demand
     * @date        2016-03-23
     * @param       newChildren   The children after the update
     * @param       oldChildren   The map of child ID -> child prior to the update
     */
    public void registerModifiedChildren(List<SObject> newChildren, Map<Id, SObject> oldChildren) {
        for(SObject newChild : newChildren) {
            registerModifiedChild(newChild, oldChildren.get(newChild.Id));
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
    public abstract void registerModifiedChild(SObject newChild, SObject oldChild);

    /**
     * @description Updates this roll up on the parents whose IDs are in the 'parentIds' set
     * @author John Rogers, Traction on Demand
     * @date   2015-11-30
     * @throws RollUpException if the roll up type is not supported
     * @return The updated parent records
     */
    public abstract List<SObject> updateRollUp();

    /**
     * @description Given a parent record, a field name, and a value, casts the value to the
     * field type and sets the field to the value
     * @author John Rogers, Traction on Demand
     * @date   2015-11-30
     * @param  parent The record to set the field on
     * @param  field The field to set
     * @param  value The value to set the field to
     */
    protected void setParentField(SObject parent, SObjectField field, Object value) {
        Schema.DisplayType type = field.getDescribe().getType();
        if (type == Schema.DisplayType.Integer) {
            parent.put(field, Integer.valueOf(value));
        } else if (type == Schema.DisplayType.Double
                || type == Schema.DisplayType.Currency) {
            parent.put(field, Double.valueOf(value));
        } else {
            parent.put(field, value);
        }
    }

    /**
     * @throws RollUpException if Trigger is not after trigger and not on child object
     * @author John Rogers, Traction on Demand
     * @date        2016-03-23
     */
    protected void assertCorrectTriggerContext() {
        if (Trigger.isAfter == null || !Trigger.isAfter) {
            throw new RollUpException('Incorrect trigger context! "After" trigger context required.');
        } else {
            // Throw exception if not dealing with right SObject type
            SObject sampleChild;
            if (Trigger.isDelete) {
                sampleChild = Trigger.old[0];
            } else {
                sampleChild = Trigger.new[0];
            }

            if (sampleChild.getSObjectType() != childType) {
                throw new RollUpException('Incorrect trigger context! '
                        + childType + ' trigger context required.');
            }
        }
    }

    public class RollUpException extends Exception { }
}