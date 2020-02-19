/**
 *  @description Tests for TLAuraResponse
 *  @author      Jeremy Horan, Traction on Demand.
 *  @date        11/1/2018
 */
@IsTest
private class TLAuraResponseTest {

    /**
	 *  @description Test creating a working response
	 *  @author 	 Jeremy Horan, Traction on Demand.
	 *  @date        2017-03-30
	 */
    @isTest static void test_Positive() {
        TLAuraResponse response = new TLAuraResponse(true);
        String key = 'test';
        response.returnValuesMap.put(key, 'test');
        System.assertNotEquals(null,response.returnValuesMap.get(key));
        System.assertEquals(true,response.isSuccess);
    }

    /**
     *  @description Test creating a response with an error message
     *  @author 	 Jeremy Horan, Traction on Demand.
     *  @date        2017-03-30
     */
    @isTest static void test_Negative() {
        TLAuraResponse response = new TLAuraResponse(false, 'test');
        System.assertNotEquals(null,response.message);
        System.assertEquals(false,response.isSuccess);
    }
}