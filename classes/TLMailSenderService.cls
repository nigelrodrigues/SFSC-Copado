/**
 * Interface for sending email messages, allows for mocking in tests
 * 
 * @author Grant Adamson, Traction on Demand
 * @date 2018-03-16
 * @group TLMailSenderService
 */
public interface TLMailSenderService {
    List<Messaging.SendEmailResult> sendEmail(List<Messaging.SingleEmailMessage> messages);
}