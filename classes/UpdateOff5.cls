global class UpdateOff5 implements Database.Batchable<sObject> {

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT ID, Business_Unit__c FROM Case WHERE Business_Unit__c = 'OFF5']);
    }

    global void execute(Database.BatchableContext BC, List<sObject > scope){
        for (sObject s : scope) {
            Case c = (Case) s;
            c.Business_Unit__c = 'Off 5th';
        }
        update scope;
    }

    global void finish(Database.BatchableContext BC){
    }
}