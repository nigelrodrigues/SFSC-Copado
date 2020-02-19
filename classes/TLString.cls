/**
 *  @description Utilities for String processing and generation
 *  @author      Jeremy Horan, Traction on Demand.
 *  @date        10/30/2018
 */
public class TLString {
    @TestVisible private static String defaultGuid;

    /**
     *  @description Generates a Random formatted GUID
     *  @author      Jeremy Horan, Traction on Demand.
     *  @date        2017-06-13
     */
    public static String generateGuid() {
        String guid;

        Blob aesKey = Crypto.GenerateAESKey(128);
        String hexKey = EncodingUtil.ConvertToHex(aesKey);

        guid = hexKey.substring(0,8)+ '-' + hexKey.substring(8,12) + '-' + hexKey.substring(12,16) + '-' + hexKey.substring(16,20) + '-' + hexKey.substring(20);

        if(Test.isRunningTest() && defaultGuid != null) {
            guid = defaultGuid;
        }

        return guid;
    }

    /**
     *  @description Generates a random valid email
     *  @author      Jeremy Horan, Traction on Demand.
     *  @date        2017-02-21
     */
    public static String generateRandomEmail() {
        return generateRandomString(5) + '@' + generateRandomString(5) + '.com';
    }

    /**
     *  @description Generates a Random String of specified size
     *  @author      Jeremy Horan, Traction on Demand.
     *  @date        2017-02-21
     */
    public static String generateRandomString(Integer characters) {
        return generateRandomString(characters, characters);
    }

    /**
     *  @description Generates a Random String between the minimum and maximum length
     *  @author      Jeremy Horan, Traction on Demand.
     *  @date        2017-02-21
     */
    public static String generateRandomString(Integer min, Integer max) {
        String randomString = '';

        final Integer length = Math.round(Math.random() * (max - min)) + min;
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';

        while (randomString.length() < length) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randomString += chars.substring(idx, idx+1);
        }
        return randomString;
    }

    /**
     *  @description Returns only the numbers of a phone number
     *  @author      Jeremy Horan, Traction on Demand.
     *  @date        2/1/2018
     */
    public static String getUnformattedPhoneNumber(String phoneNumber) {
        String unformattedPhoneNumber;

        if (phoneNumber != null) {
            unformattedPhoneNumber = phoneNumber.replaceAll('[^0-9]','');
        }

        return unformattedPhoneNumber;
    }

}