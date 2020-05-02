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

        Web_Service_Settings__c webServiceSettings = new Web_Service_Settings__c(
                API_Key__c = 'test',
                Create_Order_Endpoint__c = '/orders',
                Get_Order_Details_Endpoint__c = '/orders/details',
                UCID_Create_Endpoint__c = '/customers/me',
                Timeout__c = 120000,
                Base_Url__c = 'https://uat.thebay.com/live',
                Update_Order_Endpoint__c = '/orders',
                Get_Order_List_Endpoint__c = '/orders/list',
                UCID_Update_Endpoint__c = '/customers/me',
                UCID_Query_Endpoint__c = '/customers/search',
                CNS_Send_Email_Endpoint__c = 'https://api.backoffice.giltaws.com/api-customer-notification/stqa/resend_rendered_message/',
                CNS_Email_Search_Endpoint__c = 'https://api.backoffice.giltaws.com/api-customer-notification/stqa/search_log',
                Email_Search_API_key__c = 'test',
                CNS_Get_Email_Body__c = 'https://api.backoffice.giltaws.com/api-customer-notification/stqa/preview/email',
                Tokenex_Endpoint__c = 'https://www.tokenextest.com',
                Tokenex_Token_Scheme__c = '9996',
                SPA_Get_Adjustment_Endpoint__c = 'https://www.spatestget.com',
                SPA_Update_Adjustment_Endpoint__c  = 'https://www.spatestupdate.com',
                SPA_Get_Order_Adjustments_Endpoint__c  = 'https://www.spatestgetlist.com'
        );

        return webServiceSettings;
    }
}