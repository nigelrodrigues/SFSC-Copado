@isTest
private class CalculateBusinessHoursAgesTest {
    private static testMethod void testBusinessHoursBucketer() {
        Stop_Status__c ss = new Stop_Status__c(Name = trac_CaseConstants.STATUS_AWAITING_CUSTOMER);
        insert ss;

        Case c = new Case();
        c.Status = 'New';
        c.Last_Status_Change__c = System.now();
        insert c;

        c.Status = trac_CaseConstants.STATUS_AWAITING_CUSTOMER;
        update c;

        c.Status = 'New';
        update c;

		Case updatedCase = [SELECT Time_With_Customer__c,Time_With_Support__c,Case_Age_In_Business_Hours__c FROM Case WHERE Id=:c.Id];
		System.assert(updatedCase.Time_With_Customer__c!=null);
        System.assert(updatedCase.Time_With_Support__c!=null);
        System.assert(updatedCase.Case_Age_In_Business_Hours__c==null);

        c.Status = 'Closed';
        update c;

        updatedCase = [SELECT Time_With_Customer__c,Time_With_Support__c,Case_Age_In_Business_Hours__c FROM Case WHERE Id=:c.Id];

        System.assert(updatedCase.Time_With_Customer__c!=null);
        System.assert(updatedCase.Time_With_Support__c!=null);
        System.assert(updatedCase.Case_Age_In_Business_Hours__c!=null);
    }
}