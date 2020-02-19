/**
 * Wrapper for Messaging.sendEmail so that it can be stubbed out in tests
 * 
 * @author Grant Adamson, Traction on Demand
 * @date 2018-03-15
 * @group TLMailSenderService
 */
public class TLMailSenderServiceImpl implements TLMailSenderService {
    /**
     * Wrapper for Messaging.sendEmail method to be used in production invocations. Replaced by a stub in tests
     *
     * @param messages List of Messaging.SingleEmailMessage to send
     *
     * @return List of Messaging.SendEmailResult
     */
    public List<Messaging.SendEmailResult> sendEmail(List<Messaging.SingleEmailMessage> messages) {
        return Messaging.sendEmail(messages);
    }
}