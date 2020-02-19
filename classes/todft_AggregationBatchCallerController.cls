/**
 * Class calls todft_AggregatedCaseTimeLogBatch to process time log records.
 * @author Shubham Jain, Traction on Demand
 * @date 2019-07-18
 */

public with sharing class todft_AggregationBatchCallerController {

    @AuraEnabled
    public static void callAggregationBatch() {
        Id batchJobId = Database.executeBatch(new todft_AggregatedCaseTimeLogBatch(), 200);
    }
}