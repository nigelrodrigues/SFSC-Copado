@IsTest
public class SCCCommerceCloudConnect_Test {

    @TestSetup
    static void setup() {

        //TODO: Replace using traction test factory
        // SCCTestDataFactory.createContact(new Map<Integer, String>{1=>'fname', 2=>'fname', 3=>'fname'}, new Map<Integer, String>{1=>'lname', 2=>'lname', 3=>'lname'}, new Map<Integer, String>{1=>'test@hotmail.com', 2=>'test@yahoo.com', 3=>'test@salesforce.com'});
        //TODO: Replace using traction test factory
        // SCCTestDataFactory.createAccount(1, 'test account', false);
        //TODO: Replace using traction test factory
        // SCCTestDataFactory.createOrder(5, [SELECT Id FROM Account LIMIT 1].Id, System.today(), 'Draft', '12345', [SELECT Id FROM Contact LIMIT 1].Id);
    }

    @IsTest
    static void testSearchCustomerByEmail() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('ZeroCustomerSearch'));
        SCCCommerceCloudConnect.searchCustomerByEmail('test@hotmail.com', 'abcedfghij');
        Test.stopTest();
	}

    @IsTest
    static void testConnectToCommerceCloud2ProfileOperations() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('AccessToken'));
        SCCCommerceCloudConnect.connectToCommerceCloud2ProfileOperations();
        Test.stopTest();
	}

    @IsTest
    static void testGetCustomerAuthToken() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('CustomerAuthAccessToken'));
        SCCCommerceCloudConnect.getCustomerAuthToken('2016f5bd-59bd-4c06-9233-8d807c8dc613', '2016f5bd59bd4c06');
        Test.stopTest();
	}

    @IsTest
    static void testConnectToCommerceCloud(){
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('AccessToken'));
        Test.startTest();
        SCCCommerceCloudConnect.connectToCommerceCloud(trac_CaseConstants.BUSINESS_UNIT_HB);
        Test.stopTest();
    }

    @IsTest
    static void testGetOrderDetails(){
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('OrderDetails'));
        Test.startTest();
        SCCCommerceCloudConnect.getOrderDetails('00001603', '2016f5bd-59bd-4c06-9233-8d807c8dc613');
        Test.stopTest();
    }

    @IsTest
    static void testGetCustomerDetails(){
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('CustomerDetails'));
        Test.startTest();
        SCCCommerceCloudConnect.getCustomerDetails('00030501', '2016f5bd-59bd-4c06-9233-8d807c8dc613');
        Test.stopTest();
    }

	@IsTest
    static void testGetAddressDetails(){
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('CustomerAddresses'));
        Test.startTest();
        SCCCommerceCloudConnect.getAddressDetails('00030501', '2016f5bd-59bd-4c06-9233-8d807c8dc613');
        Test.stopTest();
    }

	@IsTest
    static void testPostAddressDetails(){
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('CustomerAddress'));
        String reqBody = '{"address_id":"my_home_address""salutation":"","title":"","company_name":"",';
        reqBody += '"first_name":"","second_name":"","last_name":"","postal_code":"","address1":"",';
        reqBody += '"address2":"","city":"","post_box":"","country_code":"","state_code":"","phone":"","suffix":""}';
        Test.startTest();
        SCCCommerceCloudConnect.postAddressDetails(reqBody, '00030501', '2016f5bd-59bd-4c06-9233-8d807c8dc613');
        Test.stopTest();
    }

	@IsTest
    static void testUpdateCCCustomerProfile_One(){
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('CustomerDetails'));
        String reqBody = '{"_resource_state" : "860cde3040519cce439cd99e209f8a87c3ad0b7e2813edbf6f5501f763b73bd5",';
        reqBody += '"_delete":["fax","phone_mobile"],"birthday":"2011-05-06","email":"dude@demandware.com"}';
        Test.startTest();
        SCCCommerceCloudConnect.updateCCCustomerProfile(reqBody, '00030501', '2016f5bd-59bd-4c06-9233-8d807c8dc613');
        Test.stopTest();
    }

    @IsTest
    static void testPushOrderDetails(){
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('OrderDetails'));
        String reqBody = '{"_resource_state" : "847f9c3c5867f641470b3046aeec31f07757991b792d722e10079926f7a289fb","status" : "replaced"}';
        Test.startTest();
        SCCCommerceCloudConnect.pushOrderDetails(reqBody, '00030501', '2016f5bd-59bd-4c06-9233-8d807c8dc613');
        Test.stopTest();
    }

}