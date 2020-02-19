/**
 *  @description Tests for TLConstants
 *  @author      Jeremy Horan, Traction on Demand.
 *  @date        11/1/2018
 */
@IsTest
private class TLConstantsTest {

    @IsTest
    private static void constants() {
        /* ---------------------- GENERAL ----------------- */

        // Date/Datetime format patterns
        System.assertEquals(TLConstants.DATE_FORMAT_US, 'M/d/yyyy', 'Constant was changed without test being updated');
        System.assertEquals(TLConstants.DATE_FORMAT_CDN, 'yyyy/MM/dd', 'Constant was changed without test being updated');
        System.assertEquals(TLConstants.DATETIME_FORMAT_US, 'M/d/yyyy h:mm a', 'Constant was changed without test being updated');
        System.assertEquals(TLConstants.DATETIME_FORMAT_CDN, 'yyyy/MM/dd h:mm a', 'Constant was changed without test being updated');
        System.assertEquals(TLConstants.TIME_FORMAT_US, 'h:mm a', 'Constant was changed without test being updated');
        System.assertEquals(TLConstants.TIME_FORMAT_CDN, 'h:mm a', 'Constant was changed without test being updated');

        // Locales
        System.assertEquals(TLConstants.LOCALE_SID_KEY_CA_ENGLISH, 'en_CA', 'Constant was changed without test being updated');
        System.assertEquals(TLConstants.LOCALE_SID_KEY_US_ENGLISH, 'en_US', 'Constant was changed without test being updated');
        System.assertEquals(TLConstants.LOCALE_SID_KEY_CA_FRENCH, 'fr_CA', 'Constant was changed without test being updated');
        System.assertEquals(TLConstants.LOCALE_SID_KEY_ENGLISH, 'en', 'Constant was changed without test being updated');
        System.assertEquals(TLConstants.LOCALE_SID_KEY_FRENCH, 'fr', 'Constant was changed without test being updated');

        // Profiles
        System.assertEquals(TLConstants.PROFILE_SYSTEM_ADMIN, 'System Administrator', 'Constant was changed without test being updated');

        // Time Zones
        System.assertEquals(TLConstants.TIME_ZONE_PDT, 'America/Los_Angeles', 'Constant was changed without test being updated');
        System.assertEquals(TLConstants.TIME_ZONE_MT, 'America/Denver', 'Constant was changed without test being updated');
        System.assertEquals(TLConstants.TIME_ZONE_CT, 'America/Panama', 'Constant was changed without test being updated');
        System.assertEquals(TLConstants.TIME_ZONE_EDT, 'America/New_York', 'Constant was changed without test being updated');

        /* ------ TESTING CONSTANTS ------ */
        // Bulk Sizes
        System.assertEquals(TLConstants.BULK_TEST_SIZE, 201, 'Constant was changed without test being updated');
        System.assertEquals(TLConstants.BULK_TEST_SIZE_LOW, 1, 'Constant was changed without test being updated');
        System.assertEquals(TLConstants.BULK_TEST_SIZE_MEDIUM, 3, 'Constant was changed without test being updated');
        System.assertEquals(TLConstants.BATCH_APEX_CALLOUT_TEST_SIZE, 9, 'Constant was changed without test being updated');


        /* ---------------------- CASE ----------------- */
        // Origin Values
        System.assertEquals(TLConstants.CASE_ORIGIN_PHONE, 'Phone', 'Constant was changed without test being updated');
        System.assertEquals(TLConstants.CASE_ORIGIN_EMAIL, 'Email', 'Constant was changed without test being updated');
        System.assertEquals(TLConstants.CASE_ORIGIN_WEB, 'Web', 'Constant was changed without test being updated');

        // Status Values
        System.assertEquals(TLConstants.CASE_STATUS_NEW, 'New', 'Constant was changed without test being updated');
        System.assertEquals(TLConstants.CASE_STATUS_CLOSED, 'Closed', 'Constant was changed without test being updated');

        /* ---------------------- OPPORTUNITY ----------------- */
        // StageName Values
        System.assertEquals(TLConstants.OPPORTUNITY_STAGE_NAME_CLOSED_WON, 'Closed Won', 'Constant was changed without test being updated');
        System.assertEquals(TLConstants.OPPORTUNITY_STAGE_NAME_CLOSED_LOST, 'Closed Lost', 'Constant was changed without test being updated');
    }
}