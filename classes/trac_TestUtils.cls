/**
 *  @description Test Utilities
 *  @author      Jeremy Horan, Traction on Demand.
 *  @date        5/29/2019
 */
@IsTest
public class trac_TestUtils {

    /**
	 *  @description initializes web service settings
	 *  @author 	 Jeremy Horan, Traction on Demand.
	 *  @date        2017-05-16
	 */
    public static Web_Service_Settings__c setupWebServiceSettings() {
        /*Web_Service_Settings__c webServiceSettings = new Web_Service_Settings__c(
                Debug__c            = true,
                Timeout__c          = 120000,
                Base_Url__c         = 'https://test.com'
        );*/

        /*Web_Service_Settings__c webServiceSettings = new Web_Service_Settings__c(
                Debug__c            = true,
                Timeout__c          = 120000,
                UCID_Query_Endpoint__c = 'https://ucid-uat-iib.hbc.com/hbcsvc/rapi/system/ucid/customer/getCustomerDetails'
        );*/

        Web_Service_Settings__c webServiceSettings = new Web_Service_Settings__c(
                API_Key__c = 'BAgIdATJjI1jJ5ytc0Onq7JQYOrGNfsNPPoKxUN5',
                Create_Order_Endpoint__c = '/orders',
                Get_Order_Details_Endpoint__c = '/orders/details',
                UCID_Create_Endpoint__c = '/customers/me',
                Timeout__c = 120000,
                Base_Url__c = 'https://uat.thebay.com/live',
                Update_Order_Endpoint__c = '/orders',
                Get_Order_List_Endpoint__c = '/orders/list',
                UCID_Update_Endpoint__c = '/customers/me',
                UCID_Query_Endpoint__c = '/customers/search'
        );

        return webServiceSettings;
    }
}