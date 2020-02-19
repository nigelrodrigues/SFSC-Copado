/**
 *  @description Utility class for Phone and CTI related methods
 *  @author      Jeremy Horan, Traction on Demand.
 *  @date        8/16/2019
 */
public without sharing class trac_PhoneUtils {

    public static final List<Reference_Data__mdt> referenceDataSettings = [SELECT Salesforce_Value__c, System_Value__c FROM Reference_Data__mdt WHERE System__c = 'Finesse' AND Type__c = 'Business Unit Prefix'];

    public static String getPhoneWithPrefix(Contact contact) {
        String phoneNumber;

        if (contact != null && contact.Business_Unit__c != null && contact.Phone != null && referenceDataSettings != null) {
            String cleanPhoneNumber = TLString.getUnformattedPhoneNumber(contact.Phone);
            phoneNumber = cleanPhoneNumber;
            for (Reference_Data__mdt referenceData : referenceDataSettings) {
                if (contact.Business_Unit__c == referenceData.Salesforce_Value__c) {
                    phoneNumber = referenceData.System_Value__c + getPrefixFromPhone(cleanPhoneNumber) + cleanPhoneNumber;
                    break;
                }
            }
        }

        return phoneNumber;
    }

    private static String getPrefixFromPhone(String phoneNumber) {
        String prefix = '91';

        if (phoneNumber != null) {
            if (phoneNumber.length() > 11) {
                prefix = '9011';
            }
            if (phoneNumber.startsWith('011')) {
                prefix = prefix.removeEnd('011');
            }
            if (phoneNumber.startsWith('1')) {
                prefix = prefix.removeEnd('1');
            }
        }

        return prefix;
    }
}