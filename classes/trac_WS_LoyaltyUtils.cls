/**
 * @description Utility class for Loyalty (Merkle) web services
 * @author Bryan Cantos (HBC), Alex Kong (ToD)
 * @date 2020-05-27
 */

public with sharing class trac_WS_LoyaltyUtils {



    public static final Map<String,Integer> mapMonthShortNameToInteger = new Map<String,Integer>{
        'Jan' => 1, 'Feb' => 2, 'Mar' => 3, 'Apr' => 4, 'May' => 5, 'Jun' => 6, 'Jul' => 7, 'Aug' => 8, 'Sep' => 9, 'Oct' => 10, 'Nov' => 11, 'Dec' => 12
    };

    /**
    * @description Generates the md5 signature hash for Merkle API requests
    * @param secretKey String, the Merkle API secret key
    * @param params Map<String,String>, all of the request parameters
    * @return String, the generated md5 hash
    */


    public static String generateHash(String secretKey, Map<String,String> params) {

        String sig = secretKey;

        List<String> sortedKeys = new List<String>(params.keySet());
        sortedKeys.sort();

        for (String key : sortedKeys) {
            sig += key + params.get(key);
        }

        System.debug('sig before hash: ' + sig);
        Blob requestBlob = Blob.valueOf(sig);
        Blob hash = Crypto.generateDigest('MD5', requestBlob);
        String hashedSig = EncodingUtil.convertToHex(hash);
        System.debug('hashed sig: ' + hashedSig);

        return hashedSig;
    }



    /**
    * @description Parses datetime strings according to regex matches, and returns the
    *   resulting Datetime object
    * @param dtString String, the datetime string to be parsed
    * @return Datetime, the resulting datetime object
    */
    public static Datetime parseDateString(String dtString) {

        Datetime dt = getDateFromExtendedFormat(dtString);
        dt = (dt == null) ? getDateFromStandardFormat(dtString) : dt;
        return dt;
    }

    private static Datetime getDateFromExtendedFormat(String dtString) {

        Datetime dt;

        // Check for Order Date pattern (e.g. Mar. 04, 2020, 06:31 a.m.)
        String regexString = '([A-Za-z]{3})\\. ([0-9]{2}), ([0-9]{4}), ([0-9]{2}):([0-9]{2}) ([ap]\\.[m]\\.)';
        Pattern orderPattern = Pattern.compile(regexString);
        Matcher regexMatch = orderPattern.matcher(dtString);
        if (regexMatch.matches()) {
            // dtString matches Order Date pattern
            String monthStr = regexMatch.group(1);
            Integer month = mapMonthShortNameToInteger.get(monthStr);
            Integer day = Integer.valueOf(regexMatch.group(2));
            Integer year = Integer.valueOf(regexMatch.group(3));
            Integer hour = Integer.valueOf(regexMatch.group(4));
            Integer minute = Integer.valueOf(regexMatch.group(5));
            String ampm = regexMatch.group(6);
            if (ampm == 'p.m.') {
                hour += 12;
            }
            dt = Datetime.newInstance(year, month, day, hour, minute, 0);
        }

        return dt;
    }


    private static Datetime getDateFromStandardFormat(String dtString) {
        Datetime dt;
        dtString = dtString.contains('.') ? dtString.split('\\.')[0] : dtString;

        // Check for Order Date pattern (e.g. 12/15/2020)
        String regexString = '^\\d{1,2}\\/\\d{1,2}\\/\\d{4}'; //date (no time)
        Pattern orderPattern = Pattern.compile(regexString);
        Matcher regexMatch = orderPattern.matcher(dtString);
        if (regexMatch.matches()) {
            String[] dateSplit =  dtString.split('/');
            Integer month = Integer.valueOf(dateSplit[0]);
            Integer day = Integer.valueOf(dateSplit[1]);
            Integer year = Integer.valueOf(dateSplit[2].split(' ')[0]);
            dt = Datetime.newInstance(year, month, day, 0, 0, 0);
        }
        return dt;
    }

}