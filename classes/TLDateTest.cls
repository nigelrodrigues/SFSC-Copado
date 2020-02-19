/**
 *  @description Tests for TLDate
 *  @author      Jeremy Horan, Traction on Demand.
 *  @date        11/1/2018
 */
@IsTest
private class TLDateTest {

    @IsTest
    private static void test_formatDate() {
        Date d = Date.newInstance(1900, 1, 1);
        String formattedDate = TLDate.formatDate(d, 'yyyy-MM-dd');

        System.assertEquals('1900-01-01', formattedDate, 'Date string should match provided format');
    }

    @IsTest
    private static void test_convertDatetimeToDate() {
        Datetime dt = Datetime.now();

        System.assertEquals(Date.today(), TLDate.convertDatetimeToDate(dt), 'Converted date should be the current date');
    }
}