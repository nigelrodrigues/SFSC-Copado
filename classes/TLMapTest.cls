/**
 * Tests for TLMap
 * @author Grant Adamson, Traction on Demand
 * @date 2017-05-01
 * @group TLMap
 * @modified Jeremy Horan, Traction on Demand, 2018-11-07 - Refactored into addToMap
 */
@IsTest
private class TLMapTest {
    private static List<Account> accounts;

    static {
        accounts = new List<Account>{
                new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Account1'),
                new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Account2')
        };
    }

    @IsTest
    private static void mapByIdToFieldSObjectField() {
        Test.startTest();

        final Map<Id, Object> results = TLMap.mapByIdToField(accounts, 'Name');

        Test.stopTest();


        System.assertEquals(2, results.size(), 'The map should have two entries');
        System.assertEquals(accounts[0].Name, (String)results.get(accounts[0].Id),
                'The map entry for the first record Id should be the first record\'s Name');
        System.assertEquals(accounts[1].Name, (String)results.get(accounts[1].Id),
                'The map entry for the second record Id should be the second record\'s Name');
    }

    @IsTest
    private static void mapByIdToFieldSObjectFieldExcludeNulls() {
        accounts[0].Name = null;

        
        Test.startTest();

        final Map<Id, Object> results = TLMap.mapByIdToField(accounts, 'Name', true);

        Test.stopTest();


        System.assertEquals(1, results.size(), 'The map should have one entry');
        System.assertEquals(false, results.containsKey(accounts[0].Id),
                'The record with the null value should be excluded');
    }

    @IsTest
    private static void mapByIdToFieldString() {
        Test.startTest();

        final Map<Id, Object> results = TLMap.mapByIdToField(accounts, 'Name');

        Test.stopTest();


        System.assertEquals(2, results.size(), 'The map should have two entries');
        System.assertEquals(accounts[0].Name, (String)results.get(accounts[0].Id),
                'The map entry for the first record Id should be the first record\'s Name');
        System.assertEquals(accounts[1].Name, (String)results.get(accounts[1].Id),
                'The map entry for the second record Id should be the second record\'s Name');
    }

    @IsTest
    private static void mapByIdToFieldStringExcludeNulls() {
        accounts[0].Name = null;


        Test.startTest();

        final Map<Id, Object> results = TLMap.mapByIdToField(accounts, 'Name', true);

        Test.stopTest();


        System.assertEquals(1, results.size(), 'The map should have one entry');
        System.assertEquals(false, results.containsKey(accounts[0].Id),
                'The record with the null value should be excluded');
    }

    @IsTest
    private static void testMapByIdEdgeCases() {
        //TODO: Update Tests with more appropriate information and add asserts

        Test.startTest();

        final Map<Id, Object> results1 = TLMap.mapByIdToField(accounts, Account.Name);
        final Map<Id, Object> results2 = TLMap.mapByIdToField(accounts, Account.Name, true);
        final Map<Id, Id> results3 = TLMap.mapByIdFieldToId(accounts, Account.Id);
        final Map<Id, Id> results4 = TLMap.mapByIdFieldToId(accounts, Account.Id, true);
        final Map<Id, Id> results5 = TLMap.mapByIdFieldToId(accounts, 'Id');
        final Map<Id, Id> results6 = TLMap.mapByIdFieldToId(accounts, 'Id', true);

        Test.stopTest();
    }

    @IsTest
    private static void testAddToMap() {

        String opportunityListJson = '[{"Id":"006f400000GOhTgAAL","Name":"Dickenson Mobile Generators",' +
                '"Amount":15000.00,"CreatedDate":"2018-10-19T20:55:36.000+0000",' +
                '"CloseDate":"2018-08-28","FiscalYear":2015},' +
                '{"Id":"006f400000GOhThAAL","Name":"United Oil Office Portable Generators",' +
                '"Amount":125000.00,"CreatedDate":"2018-11-19T20:55:36.000+0000",' +
                '"CloseDate":"2018-08-16","FiscalYear":2016}]';
        List<Opportunity> opportunities = (List<Opportunity>) JSON.deserialize(opportunityListJson, List<Opportunity>.class);

        Test.startTest();

        Map<Object, SObject> resultSObjectsByObject = new Map<Object, SObject>();
        TLMap.addToMap(resultSObjectsByObject, opportunities, 'Name');
        System.assertEquals(2, resultSObjectsByObject.size(), 'Map should have successfully populated');

        Map<Id, SObject> resultSObjectsById = new Map<Id, SObject>();
        TLMap.addToMap(resultSObjectsById, opportunities, 'Id');
        System.assertEquals(2, resultSObjectsById.size(), 'Map should have successfully populated');

        Map<String, SObject> resultSObjectsByString = new Map<String, SObject>();
        TLMap.addToMap(resultSObjectsByString, opportunities, 'Name');
        System.assertEquals(2, resultSObjectsByString.size(), 'Map should have successfully populated');

        Map<Decimal, SObject> resultSObjectsByDecimal = new Map<Decimal, SObject>();
        TLMap.addToMap(resultSObjectsByDecimal, opportunities, 'Amount');
        System.assertEquals(2, resultSObjectsByDecimal.size(), 'Map should have successfully populated');

        Map<Date, SObject> resultSObjectsByDate = new Map<Date, SObject>();
        TLMap.addToMap(resultSObjectsByDate, opportunities, 'CloseDate');
        System.assertEquals(2, resultSObjectsByDate.size(), 'Map should have successfully populated');

        Map<Datetime, SObject> resultSObjectsByDatetime = new Map<Datetime, SObject>();
        TLMap.addToMap(resultSObjectsByDatetime, opportunities, 'CreatedDate');
        System.assertEquals(2, resultSObjectsByDatetime.size(), 'Map should have successfully populated');

        Map<Id, Id> resultIdsById = new Map<Id, Id>();
        TLMap.addToMap(resultIdsById, opportunities, 'Id', 'Id');
        System.assertEquals(2, resultIdsById.size(), 'Map should have successfully populated');

        Map<Id, String> resultStringsById = new Map<Id, String>();
        TLMap.addToMap(resultStringsById, opportunities, 'Id', 'Name');
        System.assertEquals(2, resultStringsById.size(), 'Map should have successfully populated');

        Map<Id, Decimal> resultDecimalsById = new Map<Id, Decimal>();
        TLMap.addToMap(resultDecimalsById, opportunities, 'Id', 'Amount');
        System.assertEquals(2, resultDecimalsById.size(), 'Map should have successfully populated');

        Map<Id, Date> resultDatesById = new Map<Id, Date>();
        TLMap.addToMap(resultDatesById, opportunities, 'Id', 'CloseDate');
        System.assertEquals(2, resultDatesById.size(), 'Map should have successfully populated');

        Map<Id, Datetime> resultDatetimesById = new Map<Id, Datetime>();
        TLMap.addToMap(resultDatetimesById, opportunities, 'Id', 'CreatedDate');
        System.assertEquals(2, resultDatetimesById.size(), 'Map should have successfully populated');

        Map<String, Id> resultIdsByString = new Map<String, Id>();
        TLMap.addToMap(resultIdsByString, opportunities, 'Name', 'Id');
        System.assertEquals(2, resultIdsByString.size(), 'Map should have successfully populated');

        Map<String, String> resultStringsByString = new Map<String, String>();
        TLMap.addToMap(resultStringsByString, opportunities, 'Name', 'Name');
        System.assertEquals(2, resultStringsByString.size(), 'Map should have successfully populated');

        Map<String, Decimal> resultDecimalsByString = new Map<String, Decimal>();
        TLMap.addToMap(resultDecimalsByString, opportunities, 'Name', 'Amount');
        System.assertEquals(2, resultDecimalsByString.size(), 'Map should have successfully populated');

        Map<String, Date> resultDatesByString = new Map<String, Date>();
        TLMap.addToMap(resultDatesByString, opportunities, 'Name', 'CloseDate');
        System.assertEquals(2, resultDatesByString.size(), 'Map should have successfully populated');

        Map<String, Datetime> resultDatetimesByString = new Map<String, Datetime>();
        TLMap.addToMap(resultDatetimesByString, opportunities, 'Name', 'CreatedDate');
        System.assertEquals(2, resultDatetimesByString.size(), 'Map should have successfully populated');

        Map<Decimal, Id> resultIdsByDecimal = new Map<Decimal, Id>();
        TLMap.addToMap(resultIdsByDecimal, opportunities, 'Amount', 'Id');
        System.assertEquals(2, resultIdsByDecimal.size(), 'Map should have successfully populated');

        Map<Decimal, String> resultStringsByDecimal = new Map<Decimal, String>();
        TLMap.addToMap(resultStringsByDecimal, opportunities, 'Amount', 'Name');
        System.assertEquals(2, resultStringsByDecimal.size(), 'Map should have successfully populated');

        Map<Decimal, Decimal> resultDecimalsByDecimal = new Map<Decimal, Decimal>();
        TLMap.addToMap(resultDecimalsByDecimal, opportunities, 'Amount', 'Amount');
        System.assertEquals(2, resultDecimalsByDecimal.size(), 'Map should have successfully populated');

        Map<Decimal, Date> resultDatesByDecimal = new Map<Decimal, Date>();
        TLMap.addToMap(resultDatesByDecimal, opportunities, 'Amount', 'CloseDate');
        System.assertEquals(2, resultDatesByDecimal.size(), 'Map should have successfully populated');

        Map<Decimal, Datetime> resultDatetimesByDecimal = new Map<Decimal, Datetime>();
        TLMap.addToMap(resultDatetimesByDecimal, opportunities, 'Amount', 'CreatedDate');
        System.assertEquals(2, resultDatetimesByDecimal.size(), 'Map should have successfully populated');

        Map<Date, Id> resultIdsByDate = new Map<Date, Id>();
        TLMap.addToMap(resultIdsByDate, opportunities, 'CloseDate', 'Id');
        System.assertEquals(2, resultIdsByDate.size(), 'Map should have successfully populated');

        Map<Date, String> resultStringsByDate = new Map<Date, String>();
        TLMap.addToMap(resultStringsByDate, opportunities, 'CloseDate', 'Name');
        System.assertEquals(2, resultStringsByDate.size(), 'Map should have successfully populated');

        Map<Date, Decimal> resultDecimalsByDate = new Map<Date, Decimal>();
        TLMap.addToMap(resultDecimalsByDate, opportunities, 'CloseDate', 'Amount');
        System.assertEquals(2, resultDecimalsByDate.size(), 'Map should have successfully populated');

        Map<Date, Date> resultDatesByDate = new Map<Date, Date>();
        TLMap.addToMap(resultDatesByDate, opportunities, 'CloseDate', 'CloseDate');
        System.assertEquals(2, resultDatesByDate.size(), 'Map should have successfully populated');

        Map<Date, Datetime> resultDatetimesByDate = new Map<Date, Datetime>();
        TLMap.addToMap(resultDatetimesByDate, opportunities, 'CloseDate', 'CreatedDate');
        System.assertEquals(2, resultDatetimesByDate.size(), 'Map should have successfully populated');

        Map<Datetime, Id> resultIdsByDatetime = new Map<Datetime, Id>();
        TLMap.addToMap(resultIdsByDatetime, opportunities, 'CreatedDate', 'Id');
        System.assertEquals(2, resultIdsByDatetime.size(), 'Map should have successfully populated');

        Map<Datetime, String> resultStringsByDatetime = new Map<Datetime, String>();
        TLMap.addToMap(resultStringsByDatetime, opportunities, 'CreatedDate', 'Name');
        System.assertEquals(2, resultStringsByDatetime.size(), 'Map should have successfully populated');

        Map<Datetime, Decimal> resultDecimalsByDatetime = new Map<Datetime, Decimal>();
        TLMap.addToMap(resultDecimalsByDatetime, opportunities, 'CreatedDate', 'Amount');
        System.assertEquals(2, resultDecimalsByDatetime.size(), 'Map should have successfully populated');

        Map<Datetime, Date> resultDatesByDatetime = new Map<Datetime, Date>();
        TLMap.addToMap(resultDatesByDatetime, opportunities, 'CreatedDate', 'CloseDate');
        System.assertEquals(2, resultDatesByDatetime.size(), 'Map should have successfully populated');

        Map<Datetime, Datetime> resultDatetimesByDatetime = new Map<Datetime, Datetime>();
        TLMap.addToMap(resultDatetimesByDatetime, opportunities, 'CreatedDate', 'CreatedDate');
        System.assertEquals(2, resultDatetimesByDatetime.size(), 'Map should have successfully populated');

        Test.stopTest();
    }

    @IsTest
    private static void testAddToMapLists() {

        String opportunityListJson = '[{"Id":"006f400000GOhTgAAL","Name":"Dickenson Mobile Generators",' +
                '"Amount":15000.00,"CreatedDate":"2018-10-19T20:55:36.000+0000",' +
                '"CloseDate":"2018-08-28","FiscalYear":2015},' +
                '{"Id":"006f400000GOhThAAL","Name":"United Oil Office Portable Generators",' +
                '"Amount":125000.00,"CreatedDate":"2018-11-19T20:55:36.000+0000",' +
                '"CloseDate":"2018-08-16","FiscalYear":2016}]';
        List<Opportunity> opportunities = (List<Opportunity>) JSON.deserialize(opportunityListJson, List<Opportunity>.class);

        Test.startTest();

        Map<Object, List<SObject>> resultSObjectsByObject = new Map<Object, List<SObject>>();
        TLMap.addToMap(resultSObjectsByObject, opportunities, 'Name');
        System.assertEquals(2, resultSObjectsByObject.size(), 'Map should have successfully populated');

        Map<Id, List<SObject>> resultSObjectsById = new Map<Id, List<SObject>>();
        TLMap.addToMap(resultSObjectsById, opportunities, 'Id');
        System.assertEquals(2, resultSObjectsById.size(), 'Map should have successfully populated');

        Map<String, List<SObject>> resultSObjectsByString = new Map<String, List<SObject>>();
        TLMap.addToMap(resultSObjectsByString, opportunities, 'Name');
        System.assertEquals(2, resultSObjectsByString.size(), 'Map should have successfully populated');

        Map<Decimal, List<SObject>> resultSObjectsByDecimal = new Map<Decimal, List<SObject>>();
        TLMap.addToMap(resultSObjectsByDecimal, opportunities, 'Amount');
        System.assertEquals(2, resultSObjectsByDecimal.size(), 'Map should have successfully populated');

        Map<Date, List<SObject>> resultSObjectsByDate = new Map<Date, List<SObject>>();
        TLMap.addToMap(resultSObjectsByDate, opportunities, 'CloseDate');
        System.assertEquals(2, resultSObjectsByDate.size(), 'Map should have successfully populated');

        Map<Datetime, List<SObject>> resultSObjectsByDatetime = new Map<Datetime, List<SObject>>();
        TLMap.addToMap(resultSObjectsByDatetime, opportunities, 'CreatedDate');
        System.assertEquals(2, resultSObjectsByDatetime.size(), 'Map should have successfully populated');

        Map<Object, List<Id>> resultIdsByObject = new Map<Object, List<Id>>();
        TLMap.addToMap(resultIdsByObject, opportunities, 'Name', 'Id');
        System.assertEquals(2, resultIdsByObject.size(), 'Map should have successfully populated');

        Map<Object, List<String>> resultStringsByObject = new Map<Object, List<String>>();
        TLMap.addToMap(resultStringsByObject, opportunities, 'Name', 'Name');
        System.assertEquals(2, resultStringsByObject.size(), 'Map should have successfully populated');

        Map<Object, List<Decimal>> resultDecimalsByObject = new Map<Object, List<Decimal>>();
        TLMap.addToMap(resultDecimalsByObject, opportunities, 'Name', 'Amount');
        System.assertEquals(2, resultDecimalsByObject.size(), 'Map should have successfully populated');

        Map<Object, List<Date>> resultDatesByObject = new Map<Object, List<Date>>();
        TLMap.addToMap(resultDatesByObject, opportunities, 'Name', 'CloseDate');
        System.assertEquals(2, resultDatesByObject.size(), 'Map should have successfully populated');

        Map<Object, List<Datetime>> resultDatetimesByObject = new Map<Object, List<Datetime>>();
        TLMap.addToMap(resultDatetimesByObject, opportunities, 'Name', 'CreatedDate');
        System.assertEquals(2, resultDatetimesByObject.size(), 'Map should have successfully populated');

        Map<Id, List<Id>> resultIdsById = new Map<Id, List<Id>>();
        TLMap.addToMap(resultIdsById, opportunities, 'Id', 'Id');
        System.assertEquals(2, resultIdsById.size(), 'Map should have successfully populated');

        Map<Id, List<String>> resultStringsById = new Map<Id, List<String>>();
        TLMap.addToMap(resultStringsById, opportunities, 'Id', 'Name');
        System.assertEquals(2, resultStringsById.size(), 'Map should have successfully populated');

        Map<Id, List<Decimal>> resultDecimalsById = new Map<Id, List<Decimal>>();
        TLMap.addToMap(resultDecimalsById, opportunities, 'Id', 'Amount');
        System.assertEquals(2, resultDecimalsById.size(), 'Map should have successfully populated');

        Map<Id, List<Date>> resultDatesById = new Map<Id, List<Date>>();
        TLMap.addToMap(resultDatesById, opportunities, 'Id', 'CloseDate');
        System.assertEquals(2, resultDatesById.size(), 'Map should have successfully populated');

        Map<Id, List<Datetime>> resultDatetimesById = new Map<Id, List<Datetime>>();
        TLMap.addToMap(resultDatetimesById, opportunities, 'Id', 'CreatedDate');
        System.assertEquals(2, resultDatetimesById.size(), 'Map should have successfully populated');

        Map<String, List<Id>> resultIdsByString = new Map<String, List<Id>>();
        TLMap.addToMap(resultIdsByString, opportunities, 'Name', 'Id');
        System.assertEquals(2, resultIdsByString.size(), 'Map should have successfully populated');

        Map<String, List<String>> resultStringsByString = new Map<String, List<String>>();
        TLMap.addToMap(resultStringsByString, opportunities, 'Name', 'Name');
        System.assertEquals(2, resultStringsByString.size(), 'Map should have successfully populated');

        Map<String, List<Decimal>> resultDecimalsByString = new Map<String, List<Decimal>>();
        TLMap.addToMap(resultDecimalsByString, opportunities, 'Name', 'Amount');
        System.assertEquals(2, resultDecimalsByString.size(), 'Map should have successfully populated');

        Map<String, List<Date>> resultDatesByString = new Map<String, List<Date>>();
        TLMap.addToMap(resultDatesByString, opportunities, 'Name', 'CloseDate');
        System.assertEquals(2, resultDatesByString.size(), 'Map should have successfully populated');

        Map<String, List<Datetime>> resultDatetimesByString = new Map<String, List<Datetime>>();
        TLMap.addToMap(resultDatetimesByString, opportunities, 'Name', 'CreatedDate');
        System.assertEquals(2, resultDatetimesByString.size(), 'Map should have successfully populated');

        Map<Decimal, List<Id>> resultIdsByDecimal = new Map<Decimal, List<Id>>();
        TLMap.addToMap(resultIdsByDecimal, opportunities, 'Amount', 'Id');
        System.assertEquals(2, resultIdsByDecimal.size(), 'Map should have successfully populated');

        Map<Decimal, List<String>> resultStringsByDecimal = new Map<Decimal, List<String>>();
        TLMap.addToMap(resultStringsByDecimal, opportunities, 'Amount', 'Name');
        System.assertEquals(2, resultStringsByDecimal.size(), 'Map should have successfully populated');

        Map<Decimal, List<Decimal>> resultDecimalsByDecimal = new Map<Decimal, List<Decimal>>();
        TLMap.addToMap(resultDecimalsByDecimal, opportunities, 'Amount', 'Amount');
        System.assertEquals(2, resultDecimalsByDecimal.size(), 'Map should have successfully populated');

        Map<Decimal, List<Date>> resultDatesByDecimal = new Map<Decimal, List<Date>>();
        TLMap.addToMap(resultDatesByDecimal, opportunities, 'Amount', 'CloseDate');
        System.assertEquals(2, resultDatesByDecimal.size(), 'Map should have successfully populated');

        Map<Decimal, List<Datetime>> resultDatetimesByDecimal = new Map<Decimal, List<Datetime>>();
        TLMap.addToMap(resultDatetimesByDecimal, opportunities, 'Amount', 'CreatedDate');
        System.assertEquals(2, resultDatetimesByDecimal.size(), 'Map should have successfully populated');

        Map<Date, List<Id>> resultIdsByDate = new Map<Date, List<Id>>();
        TLMap.addToMap(resultIdsByDate, opportunities, 'CloseDate', 'Id');
        System.assertEquals(2, resultIdsByDate.size(), 'Map should have successfully populated');

        Map<Date, List<String>> resultStringsByDate = new Map<Date, List<String>>();
        TLMap.addToMap(resultStringsByDate, opportunities, 'CloseDate', 'Name');
        System.assertEquals(2, resultStringsByDate.size(), 'Map should have successfully populated');

        Map<Date, List<Decimal>> resultDecimalsByDate = new Map<Date, List<Decimal>>();
        TLMap.addToMap(resultDecimalsByDate, opportunities, 'CloseDate', 'Amount');
        System.assertEquals(2, resultDecimalsByDate.size(), 'Map should have successfully populated');

        Map<Date, List<Date>> resultDatesByDate = new Map<Date, List<Date>>();
        TLMap.addToMap(resultDatesByDate, opportunities, 'CloseDate', 'CloseDate');
        System.assertEquals(2, resultDatesByDate.size(), 'Map should have successfully populated');

        Map<Date, List<Datetime>> resultDatetimesByDate = new Map<Date, List<Datetime>>();
        TLMap.addToMap(resultDatetimesByDate, opportunities, 'CloseDate', 'CreatedDate');
        System.assertEquals(2, resultDatetimesByDate.size(), 'Map should have successfully populated');

        Map<Datetime, List<Id>> resultIdsByDatetime = new Map<Datetime, List<Id>>();
        TLMap.addToMap(resultIdsByDatetime, opportunities, 'CreatedDate', 'Id');
        System.assertEquals(2, resultIdsByDatetime.size(), 'Map should have successfully populated');

        Map<Datetime, List<String>> resultStringsByDatetime = new Map<Datetime, List<String>>();
        TLMap.addToMap(resultStringsByDatetime, opportunities, 'CreatedDate', 'Name');
        System.assertEquals(2, resultStringsByDatetime.size(), 'Map should have successfully populated');

        Map<Datetime, List<Decimal>> resultDecimalsByDatetime = new Map<Datetime, List<Decimal>>();
        TLMap.addToMap(resultDecimalsByDatetime, opportunities, 'CreatedDate', 'Amount');
        System.assertEquals(2, resultDecimalsByDatetime.size(), 'Map should have successfully populated');

        Map<Datetime, List<Date>> resultDatesByDatetime = new Map<Datetime, List<Date>>();
        TLMap.addToMap(resultDatesByDatetime, opportunities, 'CreatedDate', 'CloseDate');
        System.assertEquals(2, resultDatesByDatetime.size(), 'Map should have successfully populated');

        Map<Datetime, List<Datetime>> resultDatetimesByDatetime = new Map<Datetime, List<Datetime>>();
        TLMap.addToMap(resultDatetimesByDatetime, opportunities, 'CreatedDate', 'CreatedDate');
        System.assertEquals(2, resultDatetimesByDatetime.size(), 'Map should have successfully populated');

        Test.stopTest();
    }

    @IsTest
    private static void testAddToMapMath() {

        String opportunityListJson = '[{"Id":"006f400000GOhTgAAL","Name":"Dickenson Mobile Generators",' +
                '"Amount":15000.00,"CreatedDate":"2018-10-19T20:55:36.000+0000",' +
                '"CloseDate":"2018-08-28","FiscalYear":2015},' +
                '{"Id":"006f400000GOhThAAL","Name":"United Oil Office Portable Generators",' +
                '"Amount":null,"CreatedDate":"2018-10-19T20:55:36.000+0000",' +
                '"CloseDate":"2018-08-16","FiscalYear":null}]';
        List<Opportunity> opportunities = (List<Opportunity>) JSON.deserialize(opportunityListJson, List<Opportunity>.class);

        Test.startTest();

        Map<Id, Decimal> decimalsByIds = new Map<Id, Decimal>();
        Map<String, Decimal> decimalsByStrings = new Map<String, Decimal>();
        Map<Id, Integer> integersByIds = new Map<Id, Integer>();
        Map<String, Integer> integersByStrings = new Map<String, Integer>();
        for (Opportunity opportunity : opportunities) {
            TLMap.addToMap(decimalsByIds, opportunity.Amount, opportunity.Id);
            TLMap.addToMap(decimalsByStrings, opportunity.Amount, opportunity.Name);
            TLMap.addToMap(integersByIds, 100, opportunity.Id);
            TLMap.addToMap(integersByStrings, 100, opportunity.Name);
        }

        System.assertEquals(2, decimalsByIds.size(), 'Map should have successfully populated');
        System.assertEquals(2, decimalsByStrings.size(), 'Map should have successfully populated');
        System.assertEquals(2, integersByIds.size(), 'Map should have successfully populated');
        System.assertEquals(2, integersByStrings.size(), 'Map should have successfully populated');

        Test.stopTest();
    }


}