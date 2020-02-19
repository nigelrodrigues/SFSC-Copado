/**
 * Created by sjain on 8/8/2019.
 */

public with sharing class todft_AggregationBatchCallerCtrlNew {
    @AuraEnabled
    public static void callAggregationBatch() {
        Id batchJobId = Database.executeBatch(new todft_AggregatedCaseTimeLogBatch(), 200);
    }
}