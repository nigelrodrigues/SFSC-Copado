/**
 *  @description Unit Tests for TLQueryBuilder
 *  @author      Graham Barnard, Traction on Demand.
 *  @date        2016-02-18
 */
@isTest
private class TLQueryBuilderTest {
    /**
     *  @description Test when the object name is not set
     *  @author      Graham Barnard, Traction on Demand.
     *  @date        2016-02-18
     */
    @isTest static void testEmptyObjectName() {
        Boolean exceptionThrown = false;

        TLQueryBuilder queryBuilder = new TLQueryBuilder();
        try {
            String resultString = queryBuilder.build();
        }
        catch(Exception e) {
            exceptionThrown = true;
        }

        System.assertEquals(true, exceptionThrown);
    }

    /**
     *  @description Test when the object name is set and nothing else
     *  @author      Graham Barnard, Traction on Demand.
     *  @date        2016-02-18
     */
    @isTest static void testValidBasicQuery() {
        TLQueryBuilder queryBuilder = new TLQueryBuilder();
        queryBuilder.setObject('Account');

        String resultString = queryBuilder.build();
        System.assertEquals('SELECT Id FROM Account', resultString);
    }

    /**
     *  @description Test when the object name is set
     *  @author      Graham Barnard, Traction on Demand.
     *  @date        2016-02-18
     */
    @isTest static void testValidSingleField() {
        TLQueryBuilder queryBuilder = new TLQueryBuilder();
        queryBuilder.setObject('Account');
        queryBuilder.setFields(new List<String>{'Name'});

        String resultString = queryBuilder.build();
        System.assertEquals('SELECT Name FROM Account', resultString);
    }

    /**
     *  @description Test when the object name is set
     *  @author      Graham Barnard, Traction on Demand.
     *  @date        2016-02-18
     */
    @isTest static void testValidMultipleFields() {
        TLQueryBuilder queryBuilder = new TLQueryBuilder();
        queryBuilder.setObject('Account');
        queryBuilder.setFields(new List<String>{'Id, Name'});

        String resultString = queryBuilder.build();
        System.assertEquals('SELECT Id, Name FROM Account', resultString);
    }

    /**
     *  @description Test when the object name is set
     *  @author      Graham Barnard, Traction on Demand.
     *  @date        2016-02-18
     */
    @isTest static void testValidLimit() {
        TLQueryBuilder queryBuilder = new TLQueryBuilder();
        queryBuilder.setObject('Account');
        queryBuilder.setLimit(100);

        String resultString = queryBuilder.build();
        System.assertEquals('SELECT Id FROM Account LIMIT 100', resultString);
    }

    /**
     *  @description Test when the object name is set
     *  @author      Graham Barnard, Traction on Demand.
     *  @date        2016-02-18
     */
    @isTest static void testSingleCondition() {
        TLQueryBuilder queryBuilder = new TLQueryBuilder();
        queryBuilder.setObject('Account');
        queryBuilder.baseOperator.addCondition(new TLQueryBuilder.Condition('Name', TLQueryBuilder.EQUALS_OPERATOR, 'Test'));

        String resultString = queryBuilder.build();
        System.assertEquals('SELECT Id FROM Account WHERE Name = \'Test\'', resultString);
    }

    /**
     *  @description Test when the object name is set
     *  @author      Graham Barnard, Traction on Demand.
     *  @date        2016-02-18
     */
    @isTest static void testInvalidMultipleCondition() {
        Boolean exceptionThrown = false;
        TLQueryBuilder queryBuilder = new TLQueryBuilder();
        queryBuilder.setObject('Account');
        queryBuilder.baseOperator.addCondition(new TLQueryBuilder.Condition('Name', TLQueryBuilder.EQUALS_OPERATOR, 'Test1'));
        queryBuilder.baseOperator.addCondition(new TLQueryBuilder.Condition('Type', TLQueryBuilder.NOT_EQUALS_OPERATOR, 'Test2'));
        queryBuilder.baseOperator.addCondition(new TLQueryBuilder.Condition('Web', TLQueryBuilder.LIKE_OPERATOR, 'Test3'));

        try {
            String resultString = queryBuilder.build();
        }
        catch(Exception e) {
            exceptionThrown = true;
        }

         System.assertEquals(true, exceptionThrown);
   }

    /**
     *  @description Test when the object name is set
     *  @author      Graham Barnard, Traction on Demand.
     *  @date        2016-02-18
     */
    @isTest static void testValidAndMultipleCondition() {
        TLQueryBuilder queryBuilder = new TLQueryBuilder();
        queryBuilder.setObject('Account');
        queryBuilder.setLogicalOperator(TLQueryBuilder.AND_OPERATOR);
        queryBuilder.baseOperator.addCondition(new TLQueryBuilder.Condition('Name', TLQueryBuilder.EQUALS_OPERATOR, 'Test1'));
        queryBuilder.baseOperator.addCondition(new TLQueryBuilder.Condition('Type', TLQueryBuilder.NOT_EQUALS_OPERATOR, 'Test2'));
        queryBuilder.baseOperator.addCondition(new TLQueryBuilder.Condition('Web', TLQueryBuilder.EQUALS_OPERATOR, 'Test3'));

        String resultString = queryBuilder.build();
        System.assertEquals('SELECT Id FROM Account WHERE Name = \'Test1\' AND Type != \'Test2\' AND Web = \'Test3\'', resultString);
   }

    /**
     *  @description Test when the object name is set
     *  @author      Graham Barnard, Traction on Demand.
     *  @date        2016-02-18
     */
    @isTest static void testValidOrMultipleCondition() {
        TLQueryBuilder queryBuilder = new TLQueryBuilder();
        queryBuilder.setObject('Contact');
        queryBuilder.setLogicalOperator(TLQueryBuilder.OR_OPERATOR);
        queryBuilder.baseOperator.addCondition(new TLQueryBuilder.Condition('FirstName', TLQueryBuilder.EQUALS_OPERATOR, 'First Name'));
        queryBuilder.baseOperator.addCondition(new TLQueryBuilder.Condition('LastName', TLQueryBuilder.NOT_EQUALS_OPERATOR, 'Last Name'));
        queryBuilder.baseOperator.addCondition(new TLQueryBuilder.Condition('Email', TLQueryBuilder.EQUALS_OPERATOR, 'email@test.com'));

        String resultString = queryBuilder.build();
        System.assertEquals('SELECT Id FROM Contact WHERE FirstName = \'First Name\' OR LastName != \'Last Name\' OR Email = \'email@test.com\'', resultString);
   }      

    /**
     *  @description Test when the object name is set
     *  @author      Graham Barnard, Traction on Demand.
     *  @date        2016-02-18
     */
    @isTest static void testLayeredCondition() {
        TLQueryBuilder queryBuilder = new TLQueryBuilder();
        queryBuilder.setObject('Contact');
        queryBuilder.setLogicalOperator(TLQueryBuilder.OR_OPERATOR);

        TLQueryBuilder.AndOperator operator1 = new TLQueryBuilder.AndOperator();
        operator1.addCondition(new TLQueryBuilder.Condition('FirstName', TLQueryBuilder.EQUALS_OPERATOR, 'First Name 1'));
        operator1.addCondition(new TLQueryBuilder.Condition('LastName', TLQueryBuilder.EQUALS_OPERATOR, 'Last Name 1'));

        TLQueryBuilder.AndOperator operator2 = new TLQueryBuilder.AndOperator();
        operator2.addConditions(new List<TLQueryBuilder.Condition>{new TLQueryBuilder.Condition('FirstName', TLQueryBuilder.EQUALS_OPERATOR, 'First Name 2')});
        operator2.addConditions(new List<TLQueryBuilder.Condition>{new TLQueryBuilder.Condition('LastName', TLQueryBuilder.EQUALS_OPERATOR, 'Last Name 2')});

        queryBuilder.baseOperator.addOperator(operator1);
        queryBuilder.baseOperator.addOperators(new List<TLQueryBuilder.Operator>{operator2});

        String resultString = queryBuilder.build();
        System.assertEquals('SELECT Id FROM Contact WHERE (FirstName = \'First Name 1\' AND LastName = \'Last Name 1\') OR (FirstName = \'First Name 2\' AND LastName = \'Last Name 2\')', resultString);
   }      
}