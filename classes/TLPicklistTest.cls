/**
 *  @description
 *  @author      Jeremy Horan, Traction on Demand.
 *  @date        11/1/2018
 */
@IsTest
private class TLPicklistTest {

    @IsTest
    private static void test_getPicklistLabels() {
        List<String> opportunityStages = TLPicklist.getPicklistLabels('Opportunity', 'StageName');

        System.assert(opportunityStages.size() > 0, 'Picklist Labels should be available');
    }

    @IsTest
    private static void test_getPicklistValues() {
        List<String> opportunityStages = TLPicklist.getPicklistValues('Opportunity', 'StageName');

        System.assert(opportunityStages.size() > 0, 'Picklist Values should be available');
    }

    @IsTest
    private static void test_getDependantPicklistValuesByFieldName() {
        Map<String,List<String>> opportunityStagesByType = TLPicklist.getDependantPicklistValuesByFieldName('Opportunity', 'StageName', 'Type');

        System.assert(!opportunityStagesByType.isEmpty(), 'Picklist Values should be available');
    }
}