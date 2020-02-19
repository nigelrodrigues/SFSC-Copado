/**
 * Constants class contains all the constants used in Aggregation batch .
 * @author Shubham Jain, Traction on Demand
 * @date 2019-07-18
 */

public with sharing class todft_TimeLogAggregationConstants {

    public static final String GMT_FORMAT = 'yyyy-MM-dd\'T\'HH:mm:ss\'Z\'';

    public static final String STATUS_TYPE_AGGREGATION_IDENTIFIER = 'SS-';

    public static final String OWNER_TYPE_AGGREGATION_IDENTIFIER = 'OO-';

    public static final String OWNER_STATUS_TYPE_AGGREGATION_IDENTIFIER = 'OS-';

    public static final String TOUCHES = 'Touches';

    public static final String STATUS_STATUS_NEW = 'Status - Status New';

    public static final String OWNER_OWNER_NEW = 'Owner - Owner New';

    public static final String OWNER_STATUS = 'Owner - Status';

    public static final String OWNER_TYPE_USER = 'User';
    
    public static final String OWNER_TYPE_QUEUE = 'Queue';

    public static final String CASE_STATUS_GROUP_CUSTOMER = 'Customer';

    public static final String CASE_STATUS_GROUP_COMPANY = 'Company';

}