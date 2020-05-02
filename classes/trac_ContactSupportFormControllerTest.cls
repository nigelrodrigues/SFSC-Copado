/**
 * @Name trac_ContactSupportFormControllerTest
 * @Author Daniel Labonte, Traction on Demand
 * @Date June 18, 2019 
 * 
 * @Description unit test for trac_ContactSupportFormController
 */

@IsTest
private class trac_ContactSupportFormControllerTest {

    static final TLTestFactory factory = new TLTestFactory();

    @IsTest
    static void testGetCaseTypeValues() {
        List<String> caseTypeValues = trac_ContactSupportFormController.getCaseTypeValidations();
        System.assert(caseTypeValues.size() > 0, 'No values were retrieved from the org.');
    }
    @IsTest
    static void testgetCommunityDependentValues() {
     trac_ContactSupportFormController.getCommunityDependentValues();
    //System.assert(trac_ContactSupportFormController.getCommunityDependentValues() > 0, 'No values were retrieved from the org.');
    }

    @IsTest
    static void testgetGuestUserId() {
      String userId = trac_ContactSupportFormController.getGuestUserId();
        system.assert(userId != null, 'User Id found');
    }
    
    @IsTest
    static void testgetCaseFieldLabels() {
        Map<String, String> fieldMap = new Map<String, String>();
        List<String> fieldsList=new List<String>();
        fieldsList.add('Status');
        fieldsList.add('Case_Type__c');
       fieldMap= trac_ContactSupportFormController.getCaseFieldLabels(fieldsList);
    system.assert(fieldMap.keySet().size()==2,'Map of label and field name');  
    }
    
    @IsTest
    static void testAttachFilesToCase() {

        ContentVersion contentVersion_1 = new ContentVersion(
                Title = 'Test.jpg',
                PathOnClient = 'Test.jpg',
                VersionData = Blob.valueOf('My test file')
        );
        insert contentVersion_1;

        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

        Case cs = (Case) factory.createSObject(new Case(SuppliedName = 'First Last'), true);

        Map<String,String> attachmentInfo = new Map<String, String>();
        attachmentInfo.put('name', documents[0].Id);

        Test.startTest();
        String result = trac_ContactSupportFormController.attachFilesToCase(cs.Id, new List<Map<String,String>>{attachmentInfo});
        Test.stopTest();

        System.debug(result);
        System.assertNotEquals(true, Boolean.valueOf(result), 'The attachment was not attached to the case.');
    }
}