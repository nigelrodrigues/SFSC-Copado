/**
 *  @description Tests for TLQuery
 *  @author      Jeremy Horan, Traction on Demand.
 *  @date        11/6/2018
 */
@IsTest
private class TLQueryTest {

    @IsTest static void testSelectAllFields() {
        Account account = new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'test1');

        TLQuery.selectAllFields(account.Id);
        TLQuery.selectAllFields(new Set<Id>{account.Id});
        TLQuery.selectAllFields(new List<Id>{account.Id});
    }
}