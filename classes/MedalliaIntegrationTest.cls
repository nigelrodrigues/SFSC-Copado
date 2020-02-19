@isTest()
public class MedalliaIntegrationTest {
    public static testMethod void testOutboundMessageWithBasicAuth() {
        MedalliaIntegration.surveyPayload sp = new MedalliaIntegration.surveyPayload();
        sp.endpoint = 'https://instance.medallia.com/company.feed';
        sp.fieldSet = 'medalliaOutbound_createSurvey';
        sp.service = 'sfdc_test';
        sp.password = 'Medallia123';
        sp.recordid = null;

        Contact c = new Contact();
        c.FirstName = 'Con';
        c.LastName = 'tact';
        c.Email = Crypto.getRandomInteger()+'cont@contac.test.com.medalliadev';
        c.Title = 'test maker';

        insert c;

        sp.recordid = String.valueOf(c.Id);

        List<MedalliaIntegration.surveyPayload> splist = new List<MedalliaIntegration.surveyPayload>();
        splist.add(sp);
        MedalliaIntegration.sendToMedallia(splist);

    }
    public static testMethod void testOutboundMessageWithoutBasicAuth() {
        MedalliaIntegration.surveyPayload sp = new MedalliaIntegration.surveyPayload();
        sp.endpoint = 'https://instance.medallia.com/company.feed';
        sp.fieldSet = 'medalliaOutbound_createSurvey';
        sp.service = 'sfdc_test';
        sp.recordid = null;

        Contact c = new Contact();
        c.FirstName = 'Con';
        c.LastName = 'tact';
        c.Email = Crypto.getRandomInteger()+'cont@contac.test.com.medalliadev';
        c.Title = 'test maker';

        insert c;

        sp.recordid = String.valueOf(c.Id);

        List<MedalliaIntegration.surveyPayload> splist = new List<MedalliaIntegration.surveyPayload>();
        splist.add(sp);
        MedalliaIntegration.sendToMedallia(splist);

    }
    
    public static testMethod void testOutboundMessageNegative() {
        MedalliaIntegration.surveyPayload sp = new MedalliaIntegration.surveyPayload();
        sp.endpoint = 'https://instance.medallia.com/company.feed';
        sp.fieldSet = 'fail_medalliaOutbound_createSurvey';
        sp.service = 'sfdc_test';
        sp.recordid = null;

        Contact c = new Contact();
        c.FirstName = 'Con';
        c.LastName = 'tact';
        c.Email = Crypto.getRandomInteger()+'cont@contac.test.com.medalliadev';
        c.Title = 'test maker';

        insert c;

        sp.recordid = String.valueOf(c.Id);

        List<MedalliaIntegration.surveyPayload> splist = new List<MedalliaIntegration.surveyPayload>();
        splist.add(sp);
        MedalliaIntegration.sendToMedallia(splist);

    }
}