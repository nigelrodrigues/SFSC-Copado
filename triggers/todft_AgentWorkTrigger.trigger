trigger todft_AgentWorkTrigger on AgentWork (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    todft_TriggerHandlerBase.triggerHandler(new todft_AgentWorkDomain());
}