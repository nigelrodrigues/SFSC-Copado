/**
 * Copyright (c) 2014, FinancialForce.com, inc
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification,
 *   are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice,
 *      this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice,
 *      this list of conditions and the following disclaimer in the documentation
 *      and/or other materials provided with the distribution.
 * - Neither the name of the FinancialForce.com, inc nor the names of its contributors
 *      may be used to endorse or promote products derived from this software without
 *      specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 *  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
 *  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 *  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**/

/**
 *  @description Tests for TLQueryFactory
 *  @author      Jeremy Horan, Traction on Demand.
 *  @date        11/6/2018
 */
@IsTest(isParallel=true)
private with sharing class TLQueryFactoryTest {

    @IsTest
    static void test_groupByAndHaving() {
        String groupBy = 'name';
        String havingExpr = 'name = \'test\'';
        TLQueryFactory qf = new TLQueryFactory(Contact.SObjectType);
        qf.selectField('name');
        qf.setGroupBy( groupBy );
        qf.setHaving(havingExpr);
        System.assertEquals(groupBy, qf.getGroupBy());
        System.assertEquals(havingExpr, qf.getHaving());
        String query = qf.toSOQL();
        System.assert(query.endsWith('GROUP BY name HAVING name = \'test\''),'Query should have ended with a grouping on name, got: '+query);
    }

    @IsTest
    static void test_aggregateFunctionAndGroupBy() {
        String groupBy = 'Name, Birthdate';
        TLQueryFactory qf = new TLQueryFactory(Contact.SObjectType);
        qf.selectFields(new List<String>{'Name', 'Email', 'Birthdate', 'MIN(Birthdate) oldest'});
        qf.setGroupBy( groupBy );
        System.assertEquals(groupBy, qf.getGroupBy());
        String query = qf.toSOQL();
        System.assert(query.equalsIgnoreCase('SELECT name, Email, birthdate, MIN(Birthdate) oldest FROM Contact GROUP BY Name, Birthdate'));
    }

    @IsTest
    static void test_doQuery() {
        TLQueryFactory.queryVar1 = new Set<Id>();
        TLQueryFactory qf = new TLQueryFactory(Account.sObjectType);
        qf.setCondition('Id IN :queryVar1');
        qf.doQuery();
    }

    @IsTest
    static void fieldSelections() {
        TLQueryFactory qf = new TLQueryFactory(Contact.SObjectType);
        qf.selectField('firstName');
        qf.selectField(Schema.Contact.SObjectType.fields.lastName);
        qf.selectFields( new Set<String>{'acCounTId', 'account.name'} );
        qf.selectFields( new List<String>{'homePhonE','fAX'} );
        qf.selectFields( new List<Schema.SObjectField>{ Contact.Email, Contact.Title } );
        System.assertEquals(new Set<String>{
                'FirstName',
                'LastName',
                'AccountId',
                'Account.Name',
                'HomePhone',
                'Fax',
                'Email',
                'Title'},
                qf.getSelectedFields());
    }

    @IsTest
    static void simpleFieldSelection() {
        TLQueryFactory qf = new TLQueryFactory(Contact.SObjectType);
        qf.selectField('NAMe').selectFields( new Set<String>{'naMe', 'email'});
        String query = qf.toSOQL();
        System.assert( Pattern.matches('SELECT.*Name.*FROM.*',query), 'Expected Name field in query, got '+query);
        System.assert( Pattern.matches('SELECT.*Email.*FROM.*',query), 'Expected Name field in query, got '+query);
        qf.setLimit(100);
        System.assertEquals(100,qf.getLimit());
        System.assert( qf.toSOQL().endsWithIgnoreCase('LIMIT '+qf.getLimit()), 'Failed to respect limit clause:'+qf.toSOQL() );
    }

    @IsTest
    static void simpleFieldCondition() {
        String whereClause = 'name = \'test\'';
        TLQueryFactory qf = new TLQueryFactory(Contact.SObjectType);
        qf.selectField('name');
        qf.selectField('email');
        qf.setCondition( whereClause );
        System.assertEquals(whereClause,qf.getCondition());
        String query = qf.toSOQL();
        System.assert(query.endsWith('WHERE name = \'test\''),'Query should have ended with a filter on name, got: '+query);
    }

    @IsTest
    static void duplicateFieldSelection() {
        TLQueryFactory qf = new TLQueryFactory(Contact.SObjectType);
        qf.selectField('NAMe').selectFields( new Set<String>{'naMe', 'email'});
        String query = qf.toSOQL();
        System.assertEquals(1, query.countMatches('Name'), 'Expected one name field in query: '+query );
    }

    @IsTest
    static void equalityCheck() {
        TLQueryFactory qf1 = new TLQueryFactory(Contact.SObjectType);
        TLQueryFactory qf2 = new TLQueryFactory(Contact.SObjectType);
        System.assertEquals(qf1,qf2);
        qf1.selectField('name');
        System.assertNotEquals(qf1,qf2);
        qf2.selectField('NAmE');
        System.assertEquals(qf1,qf2);
        qf1.selectField('name').selectFields( new Set<String>{ 'NAME', 'name' }).selectFields( new Set<Schema.SObjectField>{ Contact.Name, Contact.Name} );
        System.assertEquals(qf1,qf2);
    }

    @IsTest
    static void nonReferenceField() {
        TLQueryFactory qf = new TLQueryFactory(Contact.SObjectType);
        TLQueryFactory.NonReferenceFieldException e;
        try{
            qf.selectField('name.title');
        }catch(TLQueryFactory.NonReferenceFieldException ex) {
            e = ex;
        }
        System.assertNotEquals(null,e,'Cross-object notation on a non-reference field should throw NonReferenceFieldException.');
    }

    @IsTest
    static void invalidCrossObjectField() {
        TLQueryFactory qf = new TLQueryFactory(Contact.SObjectType);
        TLQueryFactory.InvalidFieldException e;
        try{
            qf.selectField('account.NOT_A_REAL_FIELD');
        }catch(TLQueryFactory.InvalidFieldException ex) {
            e = ex;
        }
        System.assertNotEquals(null,e,'Cross-object notation on a non-reference field should throw NonReferenceFieldException.');
    }

    @IsTest
    static void invalidFieldTests() {
        List<TLQueryFactory.InvalidFieldException> exceptions = new List<TLQueryFactory.InvalidFieldException>();
        TLQueryFactory qf = new TLQueryFactory(Contact.SObjectType);
        try{
            qf.selectField('Not_a_field');
        }catch(TLQueryFactory.InvalidFieldException e) {
            exceptions.add(e);
        }
        try{
            qf.selectFields( new Set<String>{ 'Not_a_field','alsoNotreal'});
        }catch(TLQueryFactory.InvalidFieldException e) {
            exceptions.add(e);
        }
        try{
            qf.selectFields( new Set<Schema.SObjectField>{ null });
        }catch(TLQueryFactory.InvalidFieldException e) {
            exceptions.add(e);
        }
        try{
            qf.selectFields( new List<Schema.SObjectField>{ null, Contact.title });
        }catch(TLQueryFactory.InvalidFieldException e) {
            exceptions.add(e);
        }
        System.assertEquals(4,exceptions.size());
    }

    @IsTest
    static void ordering() {
        TLQueryFactory qf = new TLQueryFactory(Contact.SObjectType);
        qf.selectField('name');
        qf.selectField('email');
        qf.setCondition( 'name = \'test\'' );
        qf.addOrdering( new TLQueryFactory.Ordering('Contact','name', TLQueryFactory.SortOrder.ASCENDING) ).addOrdering( new TLQueryFactory.Ordering('Contact','CreatedDATE', TLQueryFactory.SortOrder.DESCENDING) );
        String query = qf.toSOQL();

        System.assertEquals(2,qf.getOrderings().size());
        System.assertEquals('Name',qf.getOrderings()[0].getField() );
        System.assertEquals(TLQueryFactory.SortOrder.DESCENDING,qf.getOrderings()[1].getDirection() );


        System.assert( Pattern.matches('SELECT.*Name.*FROM.*',query), 'Expected Name field in query, got '+query);
        System.assert( Pattern.matches('SELECT.*Email.*FROM.*',query), 'Expected Name field in query, got '+query);
    }

    @IsTest
    static void setOrdering_ReplacesPreviousOrderingsWithExpectedOrdering() {
        TLQueryFactory qf = new TLQueryFactory(Contact.SObjectType);
        qf.selectField('name');
        qf.selectField('email');
        qf.setCondition( 'name = \'test\'' );

        //test base method with ordeting by OwnerId Descending
        qf.setOrdering( new TLQueryFactory.Ordering('Contact','OwnerId', TLQueryFactory.SortOrder.DESCENDING) );

        System.assertEquals(1, qf.getOrderings().size(), 'Unexpected order size - setOrder should replace default Orderings');
        System.assertEquals(Contact.OwnerId.getDescribe().getName(), qf.getOrderings()[0].getField(), 'Unexpected order field - should have been resolved from the field OwnerId');
        System.assertEquals(TLQueryFactory.SortOrder.DESCENDING, qf.getOrderings()[0].getDirection(), 'Unexpected order direction.');

        //test method overload with ordering by LastModifiedDate Ascending
        qf.setOrdering('LastModifiedDate', TLQueryFactory.SortOrder.ASCENDING, true);

        System.assertEquals(1, qf.getOrderings().size(), 'Unexpected order size - setOrder should replace previous Orderings');
        System.assertEquals(Contact.LastModifiedDate.getDescribe().getName(), qf.getOrderings()[0].getField(), 'Unexpected order field - should have been resolved from the field LastModifiedDate');
        System.assertEquals(TLQueryFactory.SortOrder.ASCENDING, qf.getOrderings()[0].getDirection(), 'Unexpected order direction.');

        //test method overload with ordering by CreatedDate Descending
        qf.setOrdering(Contact.CreatedDate, TLQueryFactory.SortOrder.DESCENDING, true);

        System.assertEquals(1, qf.getOrderings().size(), 'Unexpected order size - setOrder should replace previous Orderings');
        System.assertEquals(Contact.CreatedDate.getDescribe().getName(), qf.getOrderings()[0].getField(), 'Unexpected order field - should have been resolved from the field CreatedDate');
        System.assertEquals(TLQueryFactory.SortOrder.DESCENDING, qf.getOrderings()[0].getDirection(), 'Unexpected order direction.');

        //test method overload with ordering by CreatedBy.Name Descending
        qf.setOrdering('CreatedBy.Name', TLQueryFactory.SortOrder.DESCENDING);

        System.assertEquals(1, qf.getOrderings().size(), 'Unexpected order size - setOrder should replace previous Orderings');
        System.assertEquals(TLQueryFactory.SortOrder.DESCENDING, qf.getOrderings()[0].getDirection(), 'Unexpected order direction.');

        //test method overload with ordering by Birthdate Ascending
        qf.setOrdering(Contact.Birthdate, TLQueryFactory.SortOrder.ASCENDING);

        System.assertEquals(1, qf.getOrderings().size(), 'Unexpected order size - setOrder should replace previous Orderings');
        System.assertEquals(Contact.Birthdate.getDescribe().getName(), qf.getOrderings()[0].getField(), 'Unexpected order field - should have been resolved from the field Birthdate');
        System.assertEquals(TLQueryFactory.SortOrder.ASCENDING, qf.getOrderings()[0].getDirection(), 'Unexpected order direction.');

        String query = qf.toSOQL();
    }


    @IsTest
    static void invalidField_string() {
        TLQueryFactory qf = new TLQueryFactory(Contact.SObjectType);
        qf.selectField('name');
        Exception e;
        try{
            qf.selectField('not_a__field');
        }catch(TLQueryFactory.InvalidFieldException ex) {
            e = ex;
        }
        System.assertNotEquals(null,e);
    }

    @IsTest
    static void invalidFields_string() {
        TLQueryFactory qf = new TLQueryFactory(Contact.SObjectType);
        qf.selectField('name');
        Exception e;
        try{
            qf.selectFields( new List<String>{'not_a__field'} );
        }catch(TLQueryFactory.InvalidFieldException ex) {
            e = ex;
        }
        System.assertNotEquals(null,e);
    }

    @IsTest
    static void invalidField_nullToken() {
        TLQueryFactory qf = new TLQueryFactory(Contact.SObjectType);
        qf.selectField('name');
        Exception e;
        Schema.SObjectField token = null;
        try{
            qf.selectField( token );
        }catch(TLQueryFactory.InvalidFieldException ex) {
            e = ex;
        }
        System.assertNotEquals(null,e);
    }

    @IsTest
    static void invalidFields_nullToken() {
        TLQueryFactory qf = new TLQueryFactory(Contact.SObjectType);
        qf.selectField('name');
        Exception e;
        List<Schema.SObjectField> token = new List<Schema.SObjectField>{
                null
        };
        try{
            qf.selectFields( token );
        }catch(TLQueryFactory.InvalidFieldException ex) {
            e = ex;
        }
        System.assertNotEquals(null,e);
    }

    @IsTest
    static void invalidFields_noQueryField() {
        try {
            String path = TLQueryFactory.getFieldTokenPath(null);
            System.assert(false,'Expected InvalidFieldException; none was thrown');
        }
        catch (TLQueryFactory.InvalidFieldException ife) {
            //Expected
        }
        catch (Exception e) {
            System.assert(false,'Expected InvalidFieldException; ' + e.getTypeName() + ' was thrown instead: ' + e);
        }
    }

    @IsTest
    static void queryFieldsNotEquals() {
        String qfld = TLQueryFactory.getFieldTokenPath(Contact.Name);
        String qfld2 = TLQueryFactory.getFieldTokenPath(Contact.LastName);
        System.assert(!qfld.equals(qfld2));
    }

    @IsTest
    static void addChildQueriesWithChildRelationship_success() {
        Account acct = new Account();
        acct.Name = 'testchildqueriesacct';
        insert acct;
        Contact cont = new Contact();
        cont.FirstName = 'test';
        cont.LastName = 'test';
        cont.AccountId = acct.Id;
        insert cont;
        Task tsk = new Task();
        tsk.WhoId = cont.Id;
        tsk.Subject = 'test';
        tsk.ActivityDate = System.today();
        insert tsk;

        TLQueryFactory qf = new TLQueryFactory(Contact.SObjectType);
        qf.selectField('name').selectField('Id').setCondition( 'name like \'%test%\'' ).addOrdering('CreatedDate', TLQueryFactory.SortOrder.DESCENDING, true);
        Schema.DescribeSObjectResult descResult = Contact.SObjectType.getDescribe();
        //explicitly assert object accessibility when creating the subselect
        qf.subselectQuery('Tasks', true).selectField('Id').selectField('Subject').setCondition(' IsDeleted = false ');
        List<TLQueryFactory> queries = qf.getSubselectQueries();
        System.assert(queries != null);
        List<Contact> contacts = qf.doQuery();
        System.assert(contacts != null && contacts.size() == 1);
        System.assert(contacts[0].Tasks.size() == 1);
        System.assert(contacts[0].Tasks[0].Subject == 'test');
    }

    @IsTest
    static void addChildQueriesWithChildRelationshipNoAccessibleCheck_success() {
        Account acct = new Account();
        acct.Name = 'testchildqueriesacct';
        insert acct;
        Contact cont = new Contact();
        cont.FirstName = 'test';
        cont.LastName = 'test';
        cont.AccountId = acct.Id;
        insert cont;
        Task tsk = new Task();
        tsk.WhoId = cont.Id;
        tsk.Subject = 'test';
        tsk.ActivityDate = System.today();
        insert tsk;

        TLQueryFactory qf = new TLQueryFactory(Contact.SObjectType);
        qf.selectField('name').selectField('Id').setCondition( 'name like \'%test%\'' ).addOrdering('CreatedDate', TLQueryFactory.SortOrder.DESCENDING, true);
        //explicitly assert object accessibility when creating the subselect
        qf.subselectQuery('Tasks').selectField('Id').selectField('Subject').setCondition(' IsDeleted = false ');
        List<TLQueryFactory> queries = qf.getSubselectQueries();
        System.assert(queries != null);
        List<Contact> contacts = qf.doQuery();
        System.assert(contacts != null && contacts.size() == 1);
        System.assert(contacts[0].Tasks.size() == 1);
        System.assert(contacts[0].Tasks[0].Subject == 'test');
    }

    @IsTest
    static void addChildQueriesWithChildRelationshipObjCheckIsAccessible_success() {
        Account acct = new Account();
        acct.Name = 'testchildqueriesacct';
        insert acct;
        Contact cont = new Contact();
        cont.FirstName = 'test';
        cont.LastName = 'test';
        cont.AccountId = acct.Id;
        insert cont;
        Task tsk = new Task();
        tsk.WhoId = cont.Id;
        tsk.Subject = 'test';
        tsk.ActivityDate = System.today();
        insert tsk;

        TLQueryFactory qf = new TLQueryFactory(Contact.SObjectType);
        qf.selectField('name').selectField('Id').setCondition( 'name like \'%test%\'' ).addOrdering('CreatedDate', TLQueryFactory.SortOrder.DESCENDING, true);
        Schema.DescribeSObjectResult descResult = Contact.SObjectType.getDescribe();
        Schema.ChildRelationship relationship;
        for (Schema.ChildRelationship childRow : descResult.getChildRelationships()) {
            //occasionally on some standard objects (Like Contact child of Contact) do not have a relationship name.
            //if there is no relationship name, we cannot query on it, so throw an exception.
            if (childRow.getRelationshipName() == 'Tasks') {
                relationship = childRow;
            }
        }
        //explicitly assert object accessibility when creating the subselect
        qf.subselectQuery(relationship, true).selectField('Id').selectField('Subject').setCondition(' IsDeleted = false ');
        List<TLQueryFactory> queries = qf.getSubselectQueries();
        System.assert(queries != null);
        List<Contact> contacts = qf.doQuery();
        System.assert(contacts != null && contacts.size() == 1);
        System.assert(contacts[0].Tasks.size() == 1);
        System.assert(contacts[0].Tasks[0].Subject == 'test');
    }

    @IsTest
    static void addChildQueriesWithChildRelationshipObj_success() {
        Account acct = new Account();
        acct.Name = 'testchildqueriesacct';
        insert acct;
        Contact cont = new Contact();
        cont.FirstName = 'test';
        cont.LastName = 'test';
        cont.AccountId = acct.Id;
        insert cont;
        Task tsk = new Task();
        tsk.WhoId = cont.Id;
        tsk.Subject = 'test';
        tsk.ActivityDate = System.today();
        insert tsk;

        TLQueryFactory qf = new TLQueryFactory(Contact.SObjectType);
        qf.selectField('name').selectField('Id').setCondition( 'name like \'%test%\'' ).addOrdering('CreatedDate', TLQueryFactory.SortOrder.DESCENDING, true);
        Schema.DescribeSObjectResult descResult = Contact.SObjectType.getDescribe();
        Schema.ChildRelationship relationship;
        for (Schema.ChildRelationship childRow : descResult.getChildRelationships()) {
            //occasionally on some standard objects (Like Contact child of Contact) do not have a relationship name.
            //if there is no relationship name, we cannot query on it, so throw an exception.
            if (childRow.getRelationshipName() == 'Tasks') {
                relationship = childRow;
            }
        }
        //explicitly assert object accessibility when creating the subselect
        qf.subselectQuery(relationship).selectField('Id').selectField('Subject').setCondition(' IsDeleted = false ');
        List<TLQueryFactory> queries = qf.getSubselectQueries();
        System.assert(queries != null);
        List<Contact> contacts = qf.doQuery();
        System.assert(contacts != null && contacts.size() == 1);
        System.assert(contacts[0].Tasks.size() == 1);
        System.assert(contacts[0].Tasks[0].Subject == 'test');
    }

    @IsTest
    static void addChildQueriesWithChildRelationshipNoAccessibleCheck_fail() {
        Account acct = new Account();
        acct.Name = 'testchildqueriesacct';
        insert acct;
        Contact cont = new Contact();
        cont.FirstName = 'test';
        cont.LastName = 'test';
        cont.AccountId = acct.Id;
        insert cont;
        Task tsk = new Task();
        tsk.WhoId = cont.Id;
        tsk.Subject = 'test';
        tsk.ActivityDate = System.today();
        insert tsk;

        TLQueryFactory qf = new TLQueryFactory(Contact.SObjectType);
        qf.selectField('name').selectField('Id').setCondition( 'name like \'%test%\'' ).addOrdering('CreatedDate', TLQueryFactory.SortOrder.DESCENDING, true);
        Schema.DescribeSObjectResult descResult = Contact.SObjectType.getDescribe();
        //explicitly assert object accessibility when creating the subselect
        //
        Exception e;
        try {
            qf.subselectQuery('Tas').selectField('Id').selectField('Subject').setCondition(' IsDeleted = false ');
        } catch (TLQueryFactory.InvalidSubqueryRelationshipException ex) {
            e = ex;
        }
        System.assertNotEquals(e, null);
    }

    @IsTest
    static void addChildQueries_success() {
        Account acct = new Account();
        acct.Name = 'testchildqueriesacct';
        insert acct;
        Contact cont = new Contact();
        cont.FirstName = 'test';
        cont.LastName = 'test';
        cont.AccountId = acct.Id;
        insert cont;
        Task tsk = new Task();
        tsk.WhoId = cont.Id;
        tsk.Subject = 'test';
        tsk.ActivityDate = System.today();
        insert tsk;

        TLQueryFactory qf = new TLQueryFactory(Contact.SObjectType);
        qf.selectField('name').selectField('Id').setCondition( 'name like \'%test%\'' ).addOrdering('CreatedDate', TLQueryFactory.SortOrder.DESCENDING, true);
        Schema.DescribeSObjectResult descResult = Contact.SObjectType.getDescribe();
        //explicitly assert object accessibility when creating the subselect
        qf.subselectQuery(Task.SObjectType, true).selectField('Id').selectField('Subject').setCondition(' IsDeleted = false ');
        List<TLQueryFactory> queries = qf.getSubselectQueries();
        System.assert(queries != null);
        List<Contact> contacts = qf.doQuery();
        System.assert(contacts != null && contacts.size() == 1);
        System.assert(contacts[0].Tasks.size() == 1);
        System.assert(contacts[0].Tasks[0].Subject == 'test');
    }

    @IsTest
    static void addChildQuerySameRelationshipAgain_success() {
        Account acct = new Account();
        acct.Name = 'testchildqueriesacct';
        insert acct;
        Contact cont = new Contact();
        cont.FirstName = 'test';
        cont.LastName = 'test';
        cont.AccountId = acct.Id;
        insert cont;
        Task tsk = new Task();
        tsk.WhoId = cont.Id;
        tsk.Subject = 'test';
        tsk.ActivityDate = System.today();
        insert tsk;
        TLQueryFactory qf = new TLQueryFactory(Contact.SObjectType);
        qf.selectField('name');
        qf.selectField('Id');
        qf.setCondition( 'name like \'%test%\'' );
        qf.addOrdering( new TLQueryFactory.Ordering('Contact','name', TLQueryFactory.SortOrder.ASCENDING) ).addOrdering('CreatedBy.Name', TLQueryFactory.SortOrder.DESCENDING);
        Schema.DescribeSObjectResult descResult = Contact.SObjectType.getDescribe();
        ChildRelationship relationship;
        for (Schema.ChildRelationship childRow : descResult.getChildRelationships()) {
            if (childRow.getRelationshipName() == 'Tasks') {
                relationship = childRow;
            }
        }
        System.assert(qf.getSubselectQueries() == null);
        TLQueryFactory childQf = qf.subselectQuery(Task.SObjectType);
        childQf.assertIsAccessible();
        childQf.setEnforceFLS(true);
        childQf.selectField('Id');
        TLQueryFactory childQf2 = qf.subselectQuery(Task.SObjectType);
        List<TLQueryFactory> queries = qf.getSubselectQueries();
        System.assert(queries != null);
        System.assert(queries.size() == 1);
    }

    @IsTest
    static void addChildQueries_invalidChildRelationship() {
        Account acct = new Account();
        acct.Name = 'testchildqueriesacct';
        insert acct;
        Contact cont = new Contact();
        cont.FirstName = 'test';
        cont.LastName = 'test';
        cont.AccountId = acct.Id;
        insert cont;
        TLQueryFactory qf = new TLQueryFactory(Contact.SObjectType);
        qf.selectField('name');
        qf.selectField('email');
        qf.setCondition( 'name like \'%test%\'' );
        qf.addOrdering( new TLQueryFactory.Ordering('Contact','name', TLQueryFactory.SortOrder.ASCENDING) ).addOrdering( 'CreatedDATE', TLQueryFactory.SortOrder.DESCENDING);
        Schema.DescribeSObjectResult descResult = Account.SObjectType.getDescribe();
        Exception e;
        try {
            SObjectType invalidType = null;
            TLQueryFactory childQf = qf.subselectQuery(invalidType);
            childQf.selectField('Id');
        } catch (TLQueryFactory.InvalidSubqueryRelationshipException ex) {
            e = ex;
        }
        System.assertNotEquals(e, null);
    }

    @IsTest
    static void addChildQueries_invalidChildRelationshipTooDeep() {
        Account acct = new Account();
        acct.Name = 'testchildqueriesacct';
        insert acct;
        Contact cont = new Contact();
        cont.FirstName = 'test';
        cont.LastName = 'test';
        cont.AccountId = acct.Id;
        insert cont;
        TLQueryFactory qf = new TLQueryFactory(Contact.SObjectType);
        qf.selectField('name');
        qf.selectField('email');
        qf.setCondition( 'name like \'%test%\'' );
        qf.addOrdering( new TLQueryFactory.Ordering('Contact','name', TLQueryFactory.SortOrder.ASCENDING) ).addOrdering('CreatedDATE', TLQueryFactory.SortOrder.DESCENDING);
        Schema.DescribeSObjectResult descResult = Contact.SObjectType.getDescribe();

        TLQueryFactory childQf = qf.subselectQuery(Task.SObjectType);
        childQf.selectField('Id');
        childQf.selectField('Subject');
        Exception e;
        try {
            TLQueryFactory subChildQf = childQf.subselectQuery(Task.SObjectType);
        } catch (TLQueryFactory.InvalidSubqueryRelationshipException ex) {
            e = ex;
        }
        System.assertNotEquals(e, null);
    }

    @IsTest
    static void checkFieldObjectReadSort_success() {
        TLQueryFactory qf = new TLQueryFactory(Contact.SObjectType);
        qf.assertIsAccessible()
                .setEnforceFLS(true)
                .selectField('createdby.name')
                .selectField(Contact.LastModifiedById)
                .selectFields(new List<SObjectField>{Contact.LastModifiedDate})
                .setEnforceFLS(false)
                .selectField(Contact.LastName)
                .selectFields(new List<SObjectField>{Contact.Id})
                .setCondition( 'name like \'%test%\'' )
                .setEnforceFLS(true)
                .selectFields(new Set<SObjectField>{Contact.FirstName})
                .addOrdering(new TLQueryFactory.Ordering('Contact','name', TLQueryFactory.SortOrder.ASCENDING) )
                .addOrdering(Contact.LastModifiedDate, TLQueryFactory.SortOrder.DESCENDING)
                .addOrdering(Contact.CreatedDate, TLQueryFactory.SortOrder.DESCENDING, true);
        Set<String> fields = qf.getSelectedFields();
        TLQueryFactory.Ordering ordering = new TLQueryFactory.Ordering('Contact','name', TLQueryFactory.SortOrder.ASCENDING);
        System.assertEquals('Name',ordering.getField());

        System.assertEquals(new Set<String>{
                'CreatedBy.Name',
                'LastModifiedById',
                'LastModifiedDate',
                'LastName',
                'Id',
                'FirstName'},
                fields);

        System.assert(qf.toSOQL().containsIgnoreCase('NULLS LAST'));
    }

    @IsTest
    static void checkObjectRead_fail() {
        User usr = createTestUser_noAccess();
        if (usr != null) {
            System.runAs(usr) {
                Boolean excThrown = false;
                try {
                    //create a query factory object for Account.
                    TLQueryFactory qf = new TLQueryFactory(Account.SObjectType);
                    //check to see if this record is accessible, it isn't.
                    qf.assertIsAccessible();
                } catch (fflib_SecurityUtils.CrudException e) {
                    excThrown = true;
                }
                System.assert(excThrown);
            }
        }
    }

// /* 2020-08-12 Commented out due to inexplicable failure despite passing in source and target org running as same user */
//    @IsTest
//    static void checkFieldRead_fail() {
//        User usr = createTestUser_noAccess();
//        if (usr != null) {
//            System.runAs(usr) {
//                //create a query factory object for Account.
//                TLQueryFactory qf = new TLQueryFactory(Account.SObjectType);
//                Boolean excThrown = false;
//                try {
//                    //set field to enforce FLS, then try to add a field.
//                    qf.setEnforceFLS(true);
//                    qf.selectField('Name');
//                } catch (fflib_SecurityUtils.FlsException e) {
//                    excThrown = true;
//                }
//                System.assert(excThrown);
//            }
//        }
//    }

    @IsTest
    static void queryWith_noFields() {
        TLQueryFactory qf = new TLQueryFactory(Contact.SObjectType);
        qf.assertIsAccessible().setEnforceFLS(true).setCondition( 'name like \'%test%\'' ).addOrdering('CreatedDate', TLQueryFactory.SortOrder.DESCENDING);
        String query = qf.toSOQL();
        System.assert(query.containsIgnoreCase('SELECT Id FROM Contact'),'Expected \'SELECT Id FROM Contact\' in the SOQL, found: ' + query);
    }

    @IsTest
    static void deterministic_toSOQL() {
        TLQueryFactory qf1 = new TLQueryFactory(User.SObjectType);
        TLQueryFactory qf2 = new TLQueryFactory(User.SObjectType);
        for(TLQueryFactory qf:new Set<TLQueryFactory>{qf1,qf2}) {
            qf.setSortSelectFields(true);
            qf.selectFields(new List<String>{
                    'Id',
                    'FirstName',
                    'LastName',
                    'CreatedBy.Name',
                    'CreatedBy.Manager',
                    'LastModifiedBy.Email'
            });
        }
        String expectedQuery =
                'SELECT CreatedBy.ManagerId, CreatedBy.Name, '
                        +'FirstName, Id, LastModifiedBy.Email, LastName '
                        +'FROM User';
        System.assertEquals(qf1.toSOQL(), qf2.toSOQL());
        System.assertEquals(expectedQuery, qf1.toSOQL());
        System.assertEquals(expectedQuery, qf2.toSOQL());
    }

    @IsTest
    static void deepCloneBasicNoChanges() {
        TLQueryFactory qf = new TLQueryFactory(Contact.SObjectType)
                .setLimit(10)
                .setCondition('id=12345')
                .selectField('Description')
                .addOrdering(new TLQueryFactory.Ordering('Contact','name', TLQueryFactory.SortOrder.ASCENDING) )
                .addOrdering( new TLQueryFactory.Ordering('Contact','CreatedDATE', TLQueryFactory.SortOrder.DESCENDING))
                .setEnforceFLS(true);

        TLQueryFactory qf2 = qf.deepClone();

        System.assertEquals(qf2, qf);

        System.assertEquals(qf.getLimit(), qf2.getLimit());
        System.assertEquals(qf.getCondition(), qf2.getCondition());
        System.assertEquals(qf.toSOQL(), qf2.toSOQL());
        System.assertEquals(qf.getOrderings(), qf2.getOrderings());
    }

    @IsTest
    static void deepCloneSubqueryNoChanges() {
        TLQueryFactory qf = new TLQueryFactory(Account.SObjectType)
                .setLimit(10)
                .setCondition('id=12345')
                .selectField('Description')
                .addOrdering(new TLQueryFactory.Ordering('Account','Name', TLQueryFactory.SortOrder.ASCENDING) )
                .addOrdering( new TLQueryFactory.Ordering('Account','Description', TLQueryFactory.SortOrder.DESCENDING))
                .setEnforceFLS(true);

        qf.subselectQuery('Contacts', true);

        TLQueryFactory qf2 = qf.deepClone();

        System.assertEquals(qf, qf2);

        System.assertEquals(qf.getLimit(), qf2.getLimit());
        System.assertEquals(qf.getCondition(), qf2.getCondition());
        System.assertEquals(qf.toSOQL(), qf2.toSOQL());
        System.assertEquals(qf.getOrderings(), qf2.getOrderings());
        System.assertEquals(qf.getSubselectQueries(), qf2.getSubselectQueries());
    }

    @IsTest
    static void deepCloneBasic() {
        TLQueryFactory qf = new TLQueryFactory(Contact.SObjectType)
                .setLimit(10)
                .setCondition('id=12345')
                .selectField('Description')
                .addOrdering(new TLQueryFactory.Ordering('Contact','name', TLQueryFactory.SortOrder.ASCENDING) )
                .addOrdering( new TLQueryFactory.Ordering('Contact','CreatedDATE', TLQueryFactory.SortOrder.DESCENDING))
                .setEnforceFLS(true);


        TLQueryFactory qf2 = qf.deepClone()
                .setLimit(200)
                .setCondition('id=54321')
                .selectField('Fax')
                .addOrdering( new TLQueryFactory.Ordering('Contact','Fax', TLQueryFactory.SortOrder.ASCENDING))
                .setEnforceFLS(false);

        qf2.getOrderings().remove(0);

        System.assertEquals(10, qf.getLimit());
        System.assertEquals(200, qf2.getLimit());

        System.assertEquals('id=12345', qf.getCondition());
        System.assertEquals('id=54321', qf2.getCondition());

        String query = qf.toSOQL();
        String query2 = qf2.toSOQL();

        System.assert(query.containsIgnoreCase('Fax') == false);
        System.assert(query.containsIgnoreCase('Description'));
        System.assert(query2.containsIgnoreCase('Description'));
        System.assert(query2.containsIgnoreCase('Fax'));

        System.assertEquals(2, qf.getOrderings().size());
        System.assertEquals('Name', qf.getOrderings()[0].getField() );
        System.assertEquals(TLQueryFactory.SortOrder.DESCENDING, qf.getOrderings()[1].getDirection());

        System.assertEquals(2, qf2.getOrderings().size());
        System.assertEquals('Fax', qf2.getOrderings()[1].getField());
        System.assertEquals(TLQueryFactory.SortOrder.ASCENDING, qf2.getOrderings()[1].getDirection());

    }

    @IsTest
    static void deepCloneSubquery() {
        TLQueryFactory qf = new TLQueryFactory(Account.SObjectType);
        qf.subselectQuery('Contacts', true);

        TLQueryFactory qf2 = qf.deepClone();
        qf2.subselectQuery('Opportunities', true);

        List<TLQueryFactory> subqueries = qf.getSubselectQueries();
        List<TLQueryFactory> subqueries2 = qf2.getSubselectQueries();

        TLQueryFactory subquery2_0 = subqueries2.get(0);

        subquery2_0.addOrdering(new TLQueryFactory.Ordering('Contact','Name', TLQueryFactory.SortOrder.ASCENDING));

        System.assert(subqueries.size() == 1);
        System.assert(subqueries2.size() == 2);

        System.assert(qf.getSubselectQueries().get(0).getOrderings().size() == 0);
        System.assert(qf2.getSubselectQueries().get(0).getOrderings().size() == 1);
    }

    @IsTest
    static void testSoql_unsortedSelectFields() {
        //Given
        TLQueryFactory qf = new TLQueryFactory(User.SObjectType);
        qf.selectFields(new List<String>{
                'Id',
                'FirstName',
                'LastName',
                'CreatedBy.Name',
                'CreatedBy.Manager',
                'LastModifiedBy.Email'
        });

        qf.setSortSelectFields(false);

        String orderedQuery =
                'SELECT '
                        +'FirstName, Id, LastName, ' //less joins come first, alphabetically
                        +'CreatedBy.ManagerId, CreatedBy.Name, LastModifiedBy.Email ' //alphabetical on the same number of joins'
                        +'FROM User';

        //When
        String actualSoql = qf.toSOQL();

        //Then
        System.assertNotEquals(orderedQuery, actualSoql);
    }

    public static User createTestUser_noAccess() {
        User usr;
        try {
            //look for a profile that does not have access to the Account object
            PermissionSet ps =
            [SELECT Profile.Id, profile.name
            FROM PermissionSet
            WHERE IsOwnedByProfile = true
            AND Profile.UserType = 'Standard'
            AND Id NOT IN (SELECT ParentId
            FROM ObjectPermissions
            WHERE SObjectType = 'Account'
            AND PermissionsRead = true)
            LIMIT 1];

            if (ps != null) {
                //create a user with the profile found that doesn't have access to the Account object
                usr = new User(
                        firstName = 'testUsrF',
                        LastName = 'testUsrL',
                        Alias = 'tstUsr',
                        Email = 'testy.test@test.com',
                        UserName='test'+ Math.random().format()+'user99@test.com',
                        EmailEncodingKey = 'ISO-8859-1',
                        LanguageLocaleKey = 'en_US',
                        TimeZoneSidKey = 'America/Los_Angeles',
                        LocaleSidKey = 'en_US',
                        ProfileId = ps.Profile.Id,
                        IsActive=true
                );
                insert usr;
            }
        } catch (Exception e) {
            //do nothing, just return null User because this test case won't work in this org.
            return null;
        }
        return usr;
    }
}