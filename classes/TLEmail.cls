/**
 *  @description Utilities for Email processing and generation
 *  @author      Jeremy Horan, Traction on Demand.
 *  @date        10/30/2018
 */
public with sharing class TLEmail {

    /**
     *  @description Send a single Email to multiple recipients with the same subject and message
     *  @author      Jeremy Horan, Traction on Demand.
     *  @date        10/30/2018
     */
    public static List<Messaging.SendEmailResult> sendEmail(List<String> recipients, String subject, String message) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(recipients);
        email.setSubject(subject);
        email.setPlainTextBody(message);
        email.setHtmlBody(message);

        return new TLMailSenderServiceImpl().sendEmail(new List<Messaging.SingleEmailMessage> {email});
    }

    /**
     *  @description Send multiple Emails to multiple recipients with the same subject and message
     *  @author      Jeremy Horan, Traction on Demand.
     *  @date        10/30/2018
     */
    public static List<Messaging.SendEmailResult> sendEmails(List<String> recipients, String subject, String message) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for (String recipient : recipients) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new List<String>{recipient});
            email.setSubject(subject);
            email.setPlainTextBody(message);
            email.setHtmlBody(message);

            emails.add(email);
        }

        return new TLMailSenderServiceImpl().sendEmail(emails);
    }
}