/**
 *  @description Class to hold all constant data / values such as picklists, record types, formats,
 *               response codes for callouts, error messages etc.
 *
 *               NOTE: Should only be used for universal constants that are applicable to any org
  *                    and not edited on a case by case basis.
 *               It's recommended to create your own constants class for project specific constants
 *
 *  @author      Steve Doucette, Jeremy Horan, Traction on Demand.
 *  @date        10/30/2018
 */
public class TLConstants {

	/* ---------------------- GENERAL ----------------- */

	// Date/Datetime format patterns
	public static final String DATE_FORMAT_US = 'M/d/yyyy';
	public static final String DATE_FORMAT_CDN = 'yyyy/MM/dd';
	public static final String DATETIME_FORMAT_US = 'M/d/yyyy h:mm a';
	public static final String DATETIME_FORMAT_CDN = 'yyyy/MM/dd h:mm a';
	public static final String TIME_FORMAT_US = 'h:mm a';
	public static final String TIME_FORMAT_CDN = 'h:mm a';

	// Locales
	public static final String LOCALE_SID_KEY_CA_ENGLISH = 'en_CA';
	public static final String LOCALE_SID_KEY_US_ENGLISH = 'en_US';
	public static final String LOCALE_SID_KEY_CA_FRENCH = 'fr_CA';
	public static final String LOCALE_SID_KEY_ENGLISH = 'en';
	public static final String LOCALE_SID_KEY_FRENCH = 'fr';

	// Profiles
	public static final String PROFILE_SYSTEM_ADMIN = 'System Administrator';

	// Time Zones
	public static final String TIME_ZONE_PDT = 'America/Los_Angeles';
	public static final String TIME_ZONE_MT = 'America/Denver';
	public static final String TIME_ZONE_CT = 'America/Panama';
	public static final String TIME_ZONE_EDT = 'America/New_York';

    /* ------ TESTING CONSTANTS ------ */
    // Bulk Sizes
    public static final Integer BULK_TEST_SIZE = 201;
    public static final Integer BULK_TEST_SIZE_LOW = 1;
    public static final Integer BULK_TEST_SIZE_MEDIUM = 3;
    public static final Integer BATCH_APEX_CALLOUT_TEST_SIZE = 9;


	/* ---------------------- CASE ----------------- */
	// Origin Values
	public static final String CASE_ORIGIN_PHONE = 'Phone';
	public static final String CASE_ORIGIN_EMAIL = 'Email';
	public static final String CASE_ORIGIN_WEB = 'Web';

	// Status Values
	public static final String CASE_STATUS_NEW = 'New';
	public static final String CASE_STATUS_CLOSED = 'Closed';

	/* ---------------------- OPPORTUNITY ----------------- */
	// StageName Values
	public static final String OPPORTUNITY_STAGE_NAME_CLOSED_WON = 'Closed Won';
	public static final String OPPORTUNITY_STAGE_NAME_CLOSED_LOST = 'Closed Lost';
}