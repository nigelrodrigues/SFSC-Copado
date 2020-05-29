/**
 * Created by akong on 5/28/2020.
 */

@IsTest
public class trac_WS_RecordLoyaltyEventTest {

    @TestSetup
    static void setup() {
        trac_TestUtils.setupWebServiceSettings();
    }

    @IsTest
    static void testRecordEventAPISuccess() {
        trac_WS_RecordLoyaltyEvent callout = new trac_WS_RecordLoyaltyEvent();
        callout.loyaltyId = '1000142';
        callout.email = 'test101@pfsweb.com';
        callout.eventType = 'gift';
        callout.value = 10;

        Test.setMock(HttpCalloutMock.class, new RecordEventMock());
        Test.startTest();
        Boolean success = callout.send();
        Test.stopTest();

        System.assertEquals(true, success);
        System.assertEquals(false, callout.isNotFound() );
        System.assertEquals(200, callout.getStatusCode() );
    }

    @IsTest
    static void testRecordEventAPIFail() {
        trac_WS_RecordLoyaltyEvent callout = new trac_WS_RecordLoyaltyEvent();
        callout.loyaltyId = '1000142';
        callout.email = 'test101@pfsweb.com';
        callout.eventType = 'gift';
        callout.value = 10;

        Test.setMock(HttpCalloutMock.class, new RecordEventMock('fail'));
        Test.startTest();
        Boolean success = callout.send();
        Test.stopTest();

        System.assertEquals(false, success);
        System.assertEquals(false, callout.isNotFound() );
        System.assertEquals(200, callout.getStatusCode() );
    }

    @IsTest
    static void testRecordEventAPIError() {
        trac_WS_RecordLoyaltyEvent callout = new trac_WS_RecordLoyaltyEvent();
        callout.loyaltyId = '1000142';
        callout.email = 'test101@pfsweb.com';
        callout.eventType = 'gift';
        callout.value = 10;

        Test.setMock(HttpCalloutMock.class, new RecordEventMock('error'));
        Test.startTest();
        Boolean success = callout.send();
        Test.stopTest();

        System.assertEquals(false, success);
        System.assertEquals(true, callout.isNotFound() );
        System.assertEquals(404, callout.getStatusCode() );
    }

    public class RecordEventMock implements HttpCalloutMock {
        Integer statusCode = 200;
        String responseBody = '{"success":true,"data":{"id":295723617,"points":10}}';
        public RecordEventMock() {
            // default constructor
        }
        public RecordEventMock(String scenario) {
            if (scenario == 'fail') {
                statusCode = 200;
                responseBody = '{"success":false,"data":{"code":602,"message":"Transaction failed"}}';
            } else if (scenario == 'error') {
                statusCode = 404;
                responseBody = '{}';
            }
        }
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(responseBody);
            res.setStatusCode(statusCode);
            return res;
        }
    }
}