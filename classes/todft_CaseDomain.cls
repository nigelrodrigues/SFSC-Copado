/**
 * @author Steve Doucette, Traction on Demand 
 * @date 2018-11-17
 */
public with sharing class todft_CaseDomain extends todft_TriggerHandlerBase {
    public override void handleAfterInsert() {
        todft_FieldLogger.execute(Trigger.new, null);
    }

    public override void handleAfterUpdate() {
        todft_FieldLogger.execute(Trigger.new, Trigger.oldMap);
        todft_CaseService.checkCaseStatus(Trigger.new, Trigger.oldMap);
    }
}