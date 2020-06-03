@IsTest
public class trac_WS_GetLoyaltyTest {
    private static final String ENDPOINT = 'https://api-gateway.hbc.io/dev/v1/uad/customer/show?external_customer_id=1200657659&include=purchase_stats,reward_stats,detail,badges,badge_groups,rewards,reward_groups,offers,coupons,redemption_limits,tier_stats,referrals,member_attributes,identities,points_expiration_schedule,points_summary&uuid=6368bf5842b80d&sig=edc5a2661ba97b5756f6cc6b501ce41c';
        //trac_WS_WebServiceHelper.webServiceSettings.Base_Url__c + trac_WS_WebServiceHelper.webServiceSettings.Get_Order_Details_Endpoint__c;
    private static final String RESOURCE = 'trac_GetLoyalty';
    @IsTest static void test_SendingWebService() {
        trac_WS_GetLoyalty webServiceClass = new trac_WS_GetLoyalty();
        webServiceClass.loyaltyId = '1200657659';
        Test.startTest();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStatus('OK');
        mock.setStatusCode(200);
        mock.setStaticResource(RESOURCE);
        Test.setMock(HttpCalloutMock.class, mock);
        System.assertEquals(true, webServiceClass.send());
        System.assertNotEquals(null, webServiceClass.loyaltyResponse);
        Test.stopTest();
    }
    @IsTest static void test_SendingWebServiceFailed() {
        trac_WS_GetLoyalty webServiceClass = new trac_WS_GetLoyalty();
        Test.startTest();
        MultiStaticResourceCalloutMock myMock = new MultiStaticResourceCalloutMock ();
        myMock.setStaticResource(ENDPOINT, RESOURCE);
        myMock.setHeader('Content-Type', 'application/json');
        myMock.setStatusCode(404);
        Test.setMock(HttpCalloutMock.class, myMock);
        System.assertEquals(false, webServiceClass.send());
        System.assertEquals(null, webServiceClass.loyaltyResponse);
        Test.stopTest();
    }
}