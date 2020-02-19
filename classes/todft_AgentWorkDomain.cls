/**
 * @author Andrew Fee, Traction on Demand 
 * @date 2018-12-27
 */
public with sharing class todft_AgentWorkDomain extends todft_TriggerHandlerBase {

    public override void handleAfterInsert() {
        //handle Omni-Channel Owner Assignments that don't trigger Case
        todft_AgentWorkService.updateOwnerOfRecords(Trigger.new, null);
    }
}