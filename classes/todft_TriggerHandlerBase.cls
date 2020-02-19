/**
 * Base class for all triggers handlers.
 * How to use it:
 * 1) Create a domain class for your SObject (trac_Opportunity for example) that extends trac_TriggerHandlerBase.
 * 2) Override the handler methods that you need.
 * 3) On the trigger, call trac_TriggerHandlerBase.triggerHandler passing a instance of your handler.
 *    Example: trac_TriggerHandlerBase.triggerHandler(new trac_Opportunity());
 */
public virtual class todft_TriggerHandlerBase {
    public static Boolean triggerSwitch = Field_Tracker_Settings__c.getOrgDefaults().Trigger_Switch__c;

    protected List<SObject> newRecordsList;
    protected Map<Id, SObject> oldRecordsMap;
    protected Map<Id, SObject> newRecordsMap;

    public todft_TriggerHandlerBase() {
        oldRecordsMap = Trigger.oldMap;
        newRecordsMap = Trigger.newMap;
        newRecordsList = Trigger.new;
    }

    public static void triggerHandler(todft_TriggerHandlerBase triggerHandler) {
        if (!triggerSwitch) {
            return;
        }

        if(Trigger.isAfter) {
            if(Trigger.isInsert) triggerHandler.handleAfterInsert();
            else if(Trigger.isUpdate) triggerHandler.handleAfterUpdate();
        }
    }

    public virtual void handleAfterInsert() {}

    public virtual void handleAfterUpdate() {}
}