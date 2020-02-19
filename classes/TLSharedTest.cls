/**
 * Tests for TLShared
 * @author Grant Adamson, Traction on Demand
 * @date 2017-05-01
 * @modified Jeremy Horan, Traction on Demand - 2018-11-07
 */
@IsTest
private class TLSharedTest {

    @IsTest
    private static void getFieldValueSobject() {
        final Account a = new Account(Name = 'test');

        Test.startTest();

        final String result = (String)TLShared.getFieldValue(a, Account.Name);

        Test.stopTest();

        System.assertEquals(a.Name, result, 'The result should be the value of the name field');
    }
}