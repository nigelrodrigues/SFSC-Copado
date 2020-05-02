/**
 * Created by nrodrigues on 4/28/2020.
 */

@IsTest
private class trac_TransferCasesControllerTest {

    static final TLTestFactory factory = new TLTestFactory();

    @IsTest
    static void testChangeOwner() {

        Profile adminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'][0];
        User testUser = (User) factory.createSObject(
                new User(
                        Alias = TLString.generateRandomString(6), Email = TLString.generateRandomEmail(),
                        EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                        LocaleSidKey = 'en_US', ProfileId = adminProfile.Id,
                        TimeZoneSidKey = 'America/Los_Angeles', Username = 'testUserBCaseProcessBatch@tractionondemand.com')
                , true);

        User newOwner = (User) factory.createSObject(
                new User(
                        Alias = TLString.generateRandomString(6), Email = TLString.generateRandomEmail(),
                        EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                        LocaleSidKey = 'en_US', ProfileId = adminProfile.Id,
                        TimeZoneSidKey = 'America/Los_Angeles', Username = 'testUserACaseProcessBatch@tractionondemand.com',
                        ManagerId = testUser.Id)
                , true);

        List<Case> caseList = new List<Case>();

        System.runAs(testUser) {
            caseList.add((Case) factory.createSObject(new Case(
                    SuppliedPhone = '1234567890',
                    SuppliedEmail = 'con@test.com',
                    Business_Unit__c = 'MHF'
            ), true));

            caseList.add((Case) factory.createSObject(new Case(
                    SuppliedName = 'First Last'
            ), true));
        }

        PageReference pageRef = Page.trac_TransferCases;
        Test.setCurrentPage(pageref);

        trac_TransferCasesController controller = new trac_TransferCasesController(new ApexPages.StandardSetController(caseList));

        List<String> caseIdList = new List<String>();
        for(Case aCase : caseList)
            caseIdList.add(aCase.Id);



        Test.StartTest();
        trac_TransferCasesController.changeOwner(String.valueOf(newOwner.Id), caseIdList);
        Test.StopTest();

        Case testCase = [SELECT Id, OWnerId FROM Case WHERE Id=:caseIdList.get(0) LIMIT 1];

        System.assertEquals(testCase.OwnerId, String.valueOf(newOwner.Id) );
    }
}