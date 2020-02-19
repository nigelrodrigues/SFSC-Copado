/**
 *  @description Tests for TLDatetime
 *  @author      Jeremy Horan, Traction on Demand.
 *  @date        11/1/2018
 */
@IsTest
private class TLDatetimeTest {

    @IsTest
    private static void test_formatDatetimeUTC() {
        Datetime dt = Datetime.newInstanceGmt(1900, 1, 1);
        String formattedDatetime = TLDatetime.formatDatetimeUTC(dt);

        System.assertEquals('1900-01-01T00:00:00Z', formattedDatetime, 'Datetime string should match UTC format');
    }
}