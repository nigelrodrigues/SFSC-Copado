/**
 *  @description Tests for TLString
 *  @author      Jeremy Horan, Traction on Demand.
 *  @date        10/30/2018
 */
@IsTest
private class TLStringTest {

    @IsTest
    private static void test_Guid() {
        String guid1 = TLString.generateGuid();
        String guid2 = TLString.generateGuid();
        System.assertNotEquals(guid1, guid2, 'GUID should be unique');

        String testGuid = 'test';
        TLString.defaultGuid = testGuid;
        String guid3 = TLString.generateGuid();
        System.assertEquals(testGuid, guid3, 'GUID should be defaulted to the test value');
    }

    @IsTest
    private static void test_getUnformattedPhoneNumber() {

        String formattedPhoneNumber = TLString.getUnformattedPhoneNumber('514779256G');

        System.assertEquals('514779256', formattedPhoneNumber, 'String should be 514779256');
    }

    @IsTest
    private static void test_generateRandomEmail() {

        String randomEmail = TLString.generateRandomEmail();

        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
        Pattern pattern = Pattern.compile(emailRegex);
        Matcher matcher = pattern.matcher(randomEmail);

        System.assert(matcher.matches(), 'Email is not a valid email format');
    }

    @IsTest
    private static void test_generateRandomString() {

        String randomString1 = TLString.generateRandomString(5);
        String randomString2 = TLString.generateRandomString(5);

        System.assertEquals(5, randomString1.length(), 'String is not of specified length');
        System.assertNotEquals(randomString1, randomString2, 'Strings are not random');

        String randomString3 = TLString.generateRandomString(5, 10);
        System.assert(randomString1.length() >= 5, 'String is too short');
        System.assert(randomString1.length() <= 10, 'String is too long');
        System.assertNotEquals(randomString1, randomString3, 'String is not random');
    }

}