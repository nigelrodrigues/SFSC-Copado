@IsTest
private class trac_AddNoteCtlrTest {

    static final TLTestFactory factory = new TLTestFactory();

    @IsTest
    static void testAddNotes() {
        Test.setMock(HttpCalloutMock.class, new MockOrderResponses('/update'));
        TLAuraResponse response  = trac_AddNoteCtlr.addNotes('SAKS','1234', '12345', '', '');
        System.assertEquals(true, response.isSuccess);

    }

    @IsTest
    static void testAddNotesError() {
        Test.setMock(HttpCalloutMock.class, new MockOrderResponsesError('/update'));
        TLAuraResponse response  =  trac_AddNoteCtlr.addNotes('SAKS','1234', '', '', '');
        System.assertEquals(false, response.isSuccess);

        Integration_Error__c error = [SELECT Id,Service__c FROM Integration_Error__c LIMIT 1];
        System.assertEquals('Add Notes To Order', error.Service__c);

    }

    @IsTest
    static void testApplyReviewNotesHold() {
        Test.setMock(HttpCalloutMock.class, new MockOrderResponses('/update'));
        TLAuraResponse response  = trac_AddNoteCtlr.applyReviewNotesHold('SAKS','1234', 'test notes');
        System.assertEquals(true, response.isSuccess);

    }

    @IsTest
    static void testApplyReviewNotesHoldError() {
        Test.setMock(HttpCalloutMock.class, new MockOrderResponsesError('/update'));
        TLAuraResponse response  =  trac_AddNoteCtlr.applyReviewNotesHold('SAKS','1234', 'test notes');
        System.assertEquals(false, response.isSuccess);

        Integration_Error__c error = [SELECT Id,Service__c FROM Integration_Error__c LIMIT 1];
        System.assertNotEquals(null, error);

    }
}