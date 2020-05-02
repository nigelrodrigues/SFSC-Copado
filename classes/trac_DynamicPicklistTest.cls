/**
 * Created by nrodrigues on 4/28/2020.
 */

@IsTest
private class trac_DynamicPicklistTest {
    @IsTest
    static void testBehavior() {
        Map<String, RecordTypeInfo> recordTypeInfoByName = SObjectType.Case.getRecordTypeInfosByName();

        VisualEditor.DynamicpickListRows dynamicPicklist = new trac_DynamicPicklist().getValues();

        // excluding Master RT
        System.assertEquals(recordTypeInfoByName.size() - 1 , dynamicPicklist.size());
    }
}