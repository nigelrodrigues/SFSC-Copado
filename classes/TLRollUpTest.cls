/**
 *  @description Tests for TLRollUp, TLRollUpAbstract
 *  @author      Jeremy Horan, Traction on Demand.
 *  @date        11/7/2018
 */
@IsTest
private class TLRollUpTest {

    //TODO: Proper Asserts

    @IsTest
    private static void testSumRollUp() {
        Account account = new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Parent Account');
        Opportunity opportunity1 = new Opportunity(Id = fflib_IDGenerator.generate(Opportunity.SObjectType), Name = 'Test', AccountId = account.Id);
        Opportunity opportunity2 = new Opportunity(Id = fflib_IDGenerator.generate(Opportunity.SObjectType), Name = 'Test', AccountId = account.Id);

        TLRollUp rollUp = new TestSumRollUp();
        rollUp.parentIds = new Set<Id>{account.Id};
        rollUp.registerNewChild(opportunity1);
        rollUp.registerDeletedChild(opportunity1);
        rollUp.registerModifiedChild(opportunity1, opportunity2);
        rollUp.registerNewChildren(new List<SObject> {opportunity1, opportunity2});
        rollUp.registerDeletedChildren(new List<SObject> {opportunity1, opportunity2});
        rollUp.registerModifiedChildren(new List<SObject>{opportunity1, opportunity2}, new Map<Id, SObject>{opportunity1.Id => opportunity1, opportunity2.Id => opportunity2});
        List<Account> accounts = (List<Account>) rollUp.updateRollUp();
    }

    @IsTest
    private static void testMaxRollUp() {
        Account account = new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Parent Account');

        TLRollUp rollUp = new TestMaxRollUp();
        rollUp.parentIds = new Set<Id>{account.Id};
        List<Account> accounts = (List<Account>) rollUp.updateRollUp();
    }

    @IsTest
    private static void testMinRollUp() {
        Account account = new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Parent Account');

        TLRollUp rollUp = new TestMinRollUp();
        rollUp.parentIds = new Set<Id>{account.Id};
        List<Account> accounts = (List<Account>) rollUp.updateRollUp();
    }

    @IsTest
    private static void testCountRollUp() {
        Account account = new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Parent Account');

        TLRollUp rollUp = new TestCountRollUp();
        rollUp.parentIds = new Set<Id>{account.Id};
        List<Account> accounts = (List<Account>) rollUp.updateRollUp();
    }

    @IsTest
    private static void testExtraMethods() {
        Account account = new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Parent Account');
        Opportunity opportunity1 = new Opportunity(Id = fflib_IDGenerator.generate(Opportunity.SObjectType), Name = 'Test', AccountId = account.Id);
        Opportunity opportunity2 = new Opportunity(Id = opportunity1.Id, Name = 'Updated Test', AccountId = null);

        TLRollUp rollUp = new TestSumRollUp();
        rollUp.parentIds = new Set<Id>{account.Id};
        rollUp.registerNewChild(opportunity2);
        rollUp.registerDeletedChild(opportunity2);
        rollUp.registerModifiedChild(opportunity1, opportunity2);
        rollUp.registerNewChildren(new List<SObject> {opportunity2});
        rollUp.registerDeletedChildren(new List<SObject> {opportunity2});
        rollUp.registerModifiedChildren(new List<SObject>{opportunity2}, new Map<Id, SObject>{opportunity1.Id => opportunity1});
        List<Account> accounts = (List<Account>) rollUp.updateRollUp();

        String rollUpName = rollUp.name;
        rollUp.getChildFields();
        rollUp.getParentFields();
        rollUp.prepForSerialization();
    }

    public without sharing class TestSumRollUp extends TLRollUp {
        public TestSumRollUp() {
            lookupField = Opportunity.AccountId;
            rollUpCriteriaClause = 'Name = \'Test\'';
            rollUpRelationships = new List<TLRollUpAbstract.RollUpRelationship>{
                    new TLRollUpAbstract.RollUpRelationship(
                            TLRollUpAbstract.RollUpType.SUM,
                            Opportunity.Amount,
                            Account.AnnualRevenue
                    )
            };
        }

        public override Boolean fitsRollUpCriteria(SObject obj) {
            return obj.get('Name') == 'Test';
        }
    }

    public without sharing class TestMaxRollUp extends TLRollUp {
        public TestMaxRollUp() {
            lookupField = Opportunity.AccountId;
            rollUpCriteriaClause = 'Name = \'Test\'';
            rollUpRelationships = new List<TLRollUpAbstract.RollUpRelationship>{
                    new TLRollUpAbstract.RollUpRelationship(
                            TLRollUpAbstract.RollUpType.MAX,
                            Opportunity.Amount,
                            Account.AnnualRevenue
                    )
            };
        }

        public override Boolean fitsRollUpCriteria(SObject obj) {
            return obj.get('Name') == 'Test';
        }
    }

    public without sharing class TestMinRollUp extends TLRollUp {
        public TestMinRollUp() {
            lookupField = Opportunity.AccountId;
            rollUpCriteriaClause = 'Name = \'Test\'';
            rollUpRelationships = new List<TLRollUpAbstract.RollUpRelationship>{
                    new TLRollUpAbstract.RollUpRelationship(
                            TLRollUpAbstract.RollUpType.MIN,
                            Opportunity.Amount,
                            Account.AnnualRevenue
                    )
            };
        }

        public override Boolean fitsRollUpCriteria(SObject obj) {
            return obj.get('Name') == 'Test';
        }
    }

    public without sharing class TestCountRollUp extends TLRollUp {
        public TestCountRollUp() {
            lookupField = Opportunity.AccountId;
            rollUpCriteriaClause = 'Name = \'Test\'';
            rollUpRelationships = new List<TLRollUpAbstract.RollUpRelationship>{
                    new TLRollUpAbstract.RollUpRelationship(
                            TLRollUpAbstract.RollUpType.COUNT,
                            Opportunity.Id,
                            Account.NumberOfEmployees
                    )
            };
        }

        public override Boolean fitsRollUpCriteria(SObject obj) {
            return obj.get('Name') == 'Test';
        }
    }
}