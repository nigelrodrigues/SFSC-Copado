/**
 *  @description Test Class for trac_UrgentMessageCtlr
 *  @author 	 Jeremy Horan, Traction on Demand.
 *  @date        2016-10-18
 */
@isTest
private class trac_UrgentMessageCtlrTest {

    static final TLTestFactory factory = new TLTestFactory();
	
	@isTest static void test_controller() {

        String testBusinessUnit = 'Hudson\'s Bay';

        Case testCase = (Case) factory.createSObject(new Case(
                Business_Unit__c = testBusinessUnit
        ), true);

		Urgent_Message__c urgentMessage = new Urgent_Message__c(
			Activation_Date__c = Date.today(),
			Body__c = 'TEST',
			Expiration_Date__c = Date.today().addDays(3),
            Banner__c = testBusinessUnit
		);
		insert urgentMessage;

		System.assertEquals(1, trac_UrgentMessageCtlr.getUrgentMessages(testCase.Id).size());
		System.assertNotEquals(null,trac_UrgentMessageCtlr.getUrgentMessage(urgentMessage.Id));
	}	
}