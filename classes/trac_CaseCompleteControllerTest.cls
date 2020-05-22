/**
* @description Test class for trac_CaseCompleteController
* @author      Abhishek Solanki, Traction on Demand
* @date        2019-03-17
*/
@isTest
public with sharing class trac_CaseCompleteControllerTest {

    static final TLTestFactory factory = new TLTestFactory();

    @isTest
    static void getCaseRecordTypeTest() {
        Case bayCase = (Case) factory.createSObject(
                new Case(
                        RecordTypeId = TLSObj.getRecordTypeIdForName(Case.SObjectType, trac_CaseConstants.RECORD_TYPE_DEVNAME_SUPPORT_CASE),
                        Status = trac_CaseConstants.STATUS_NEW),
                true);
        Case saksCase = (Case) factory.createSObject(
                new Case(
                        RecordTypeId = TLSObj.getRecordTypeIdForName(Case.SObjectType, trac_CaseConstants.RECORD_TYPE_DEVNAME_SAKS),
                        Status = trac_CaseConstants.STATUS_NEW),
                true);

        Test.startTest();
        String saksCaseRecType = trac_CaseCompleteController.getCaseRecordType(saksCase.RecordTypeId);
        String bayCaseRecType = trac_CaseCompleteController.getCaseRecordType(bayCase.RecordTypeId);
        Test.stopTest();

        System.assertEquals('saksoff5th', saksCaseRecType);
        System.assertEquals('bay', bayCaseRecType);
    }

    @IsTest
    static void testGetCaseDetails()
    {
        Case off5thCase = (Case) factory.createSObject(
                new Case(
                        RecordTypeId = TLSObj.getRecordTypeIdForName(Case.SObjectType, trac_CaseConstants.RECORD_TYPE_DEVNAME_OFF_5TH),
                        Status = trac_CaseConstants.STATUS_NEW),
                true);

        Test.startTest();
        Case aCase = trac_CaseCompleteController.getCaseDetails(off5thCase.Id);
        System.assertEquals(false, aCase == null);
        Test.stopTest();
    }
}