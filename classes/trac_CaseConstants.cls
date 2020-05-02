/**
 * @Name trac_CaseConstants
 * @Author Daniel Labonte, Traction on Demand
 * @Date June 12, 2019 
 * 
 * @Description constants class for the case object
 */

public with sharing class trac_CaseConstants {
    /* STATUSES */
    public static final String STATUS_AWAITING_SERVICE_EXCELLENCE_REVIEW = 'Awaiting Service Excellence Review';
    public static final String STATUS_AWAITING_INTERNAL_REVIEW = 'Awaiting Internal Response';
    public static final String STATUS_TEAM_ASSISTANCE_NEEDED = 'Team Assistance Needed';
    public static final String STATUS_AWAITING_CUSTOMER = 'Awaiting Customer Response';
    public static final String STATUS_PENDING_FRAUD_TEAM = 'Pending Fraud Team';
    public static final String STATUS_SYSTEM_ISSUE = 'System Issue';
    public static final String STATUS_FOLLOW_UP = 'Follow Up';
    public static final String STATUS_POS_TEAM = 'POS Team';
    public static final String STATUS_CLOSED = 'Closed';
    public static final String STATUS_NEW = 'New';
    public static final String STATUS_LIVE_AGENT = 'Live Agent';
    public static final String STATUS_NON_RESPONSIVE_CUSTOMER = 'Non Responsive Customer';

    public static final String CALL_STATUS_ANSWERED = 'Answered';
    public static final String CALL_STATUS_TRANSFERRED = 'Transferred';
    public static final String CALL_STATUS_ENDED = 'Ended';

    public static final String EMAIL_STATUS_CUSTOMER_5 = 'Customer Day 5';
    public static final String EMAIL_STATUS_CUSTOMER_7 = 'Customer Day 7';
    public static final String EMAIL_STATUS_INTERNAL_1 = 'Internal Day 1';
    public static final String EMAIL_STATUS_INTERNAL_2 = 'Internal Day 2';

    /* RECORD TYPES */
    public static final String RECORD_TYPE_DEVNAME_SUPPORT_CASE = 'Support_Case';
    //Contact Record Type Customer
    public static final String RECORD_TYPE_DEVNAME_CUSTOMER_CONTACT = 'Customer';
    public static final String RECORD_TYPE_ID_CUSTOMER_CONTACT = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(RECORD_TYPE_DEVNAME_CUSTOMER_CONTACT).getRecordTypeId();
    public static final String RECORD_TYPE_DEVNAME_OFF_5TH = 'Off_5th_Support_Case';
    public static final String RECORD_TYPE_DEVNAME_SAKS = 'Saks_Support_Case';

    //Case Record Type Click To Call
    public static final String RECORD_TYPE_CLICK_TO_CALL_CASE = 'Click_to_Call';
    public static final String RECORD_TYPE_ID_CLICK_TO_CALL_CASE = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(RECORD_TYPE_CLICK_TO_CALL_CASE).getRecordTypeId();

    /* BUSINESS UNITS */
    public static final String BUSINESS_UNIT_MHF = 'MHF';
    public static final String BUSINESS_UNIT_HB = 'Hudson\'s Bay';
    public static final String BUSINESS_UNIT_LT = 'Lord + Taylor';
    public static final String BUSINESS_UNIT_OFF_5TH = 'Off 5th';
    public static final String BUSINESS_UNIT_SAKS = 'Saks';

    /* LANGUAGES */
    public static final String CASE_LANGUAGE_ENGLISH = 'English';
    public static final String CASE_LANGUAGE_FRENCH = 'French';

    /* BUSINESS HOURS SETTINGS */
    public static final String BUSINESS_HOURS_SETTING_MHF_ENGLISH = 'MHF English';
    public static final String BUSINESS_HOURS_SETTING_MHF_FRENCH = 'MHF French';

    /* QUEUES */
    public static final String QUEUE_POS_BAY = 'POS_Bay';
    public static final String QUEUE_STORE_OPERATIONS = 'Store_Operations';
    public static final String QUEUE_POS_LT = 'POS_LT';
    public static final String QUEUE_POS_MHF = 'POS_MHF';
    public static final String QUEUE_POS_O5 = 'POS_O5';
    public static final String QUEUE_O5_RISK_SUPPORT_JACKSON = 'O5_Risk_Support_Jackson';
    public static final String QUEUE_POS_SAKS = 'POS_Saks';
    public static final String QUEUE_POS_MHF_GIFT_CARD = 'POS_MHF_Gift_Card';
    public static final String QUEUE_CLICK_TO_CALL_CASE = 'Click_to_Call';
    public static final String QUEUE_MHF = 'MHF';
    public static final String QUEUE_MHF_REWARDS = 'MHF_Rewards';
    public static final String QUEUE_MHF_FRENCH = 'MHF_French';

    /* CASE PRIORITY */
    public static final String CASE_PRIORITY_HIGH = 'High';
    
    /* EMAIL MESSAGE */
    public static final Integer MINUTES = -5;

    /* ROLES */
    public static final String ROLE_CC_LEADERSHIP = 'Customer Care Leadership';

    /* CASE ORIGIN */
    public static final String ORIGIN_CHAT = 'Live Agent';
    public static final String ORIGIN_WEB_TO_CASE = 'Support Community';

    /* CASE TOPIC VALUES */
    public static final String CASE_MAJOR_HOME_PURCHASES = 'Major Home Purchases';
    public static final String CASE_HUDSON_BAY_REWARDS = 'Hudson\'s Bay Rewards';
    public static final String CASE_STORE_EXPERIENCE = 'Store Experience';
}