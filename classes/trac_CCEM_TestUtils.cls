/**
 *  @description Test Utilities
 *  @author 	 Jeremy Horan, Traction on Demand.
 *  @date        2016-09-27
 */
@IsTest
public with sharing class trac_CCEM_TestUtils {

    public static List<Contact> createContacts(Integer num) {
        return createContacts(num, false);
    }

    public static List<Contact> createContacts(Integer num, Boolean doInsert) {
        List<Contact> newContacts = new List<Contact>();

        for(Integer i =0; i < num; i++){
            newContacts.add( new Contact(
                    LastName = generateRandomString(10),
                    Email = generateRandomEmail()
            ));
        }
        if (doInsert) {
            insert newContacts;
        }
        return newContacts;
    }

    public static List<Case> createCases(Integer num) {
        return createCases(num, false);
    }

    public static List<Case> createCases(Integer num, Boolean doInsert) {
        List<Case> newCases = new List<Case>();

        for(Integer i =0; i < num; i++){
            newCases.add( new Case() );
        }
        if (doInsert) {
            insert newCases;
        }
        return newCases;
    }

    public static List<EmailMessage> createEmailMessages(Integer num) {
        return createEmailMessages(num, false);
    }

    public static List<EmailMessage> createEmailMessages(Integer num, Boolean doInsert) {
        List<EmailMessage> newEmailMessages = new List<EmailMessage>();

        for(Integer i =0; i < num; i++){
            newEmailMessages.add( new EmailMessage(Incoming = true) );
        }
        if (doInsert) {
            insert newEmailMessages;
        }
        return newEmailMessages;
    }

    public static String generateRandomString(Integer min, Integer max) {
        final Integer length = Math.round(Math.random() * (max - min)) + min;
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < length) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        return randStr;
    }

    public static String generateRandomEmail() {
        return generateRandomString(5) + '@' + generateRandomString(5) + '.com';
    }

    public static String generateRandomString(Integer characters) {
        return generateRandomString(characters, characters);
    }


}