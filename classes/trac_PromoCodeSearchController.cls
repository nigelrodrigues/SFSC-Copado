/**
* @name trac_PromoCodeSearchController
* @author Daniel Labonte, Traction on Demand
* @date 2019-07-04
* @description apex controller for the Promo Code Search lightning web component - the class is able to handle assigning
*              multiple promo codes to a single case, but currently, only a single promo code is to be assigned to a
*              single case.
*/

public without sharing class trac_PromoCodeSearchController {
    public static String businessUnit;
    
    /**
* @description get the number of promo code records associated with the current case
* @param caseId of th current case record
* @return count of related promo codes
*/
    @AuraEnabled
    public static Integer getCurrentCasePromoCode(String caseId) {
        try {
            businessUnit = [SELECT Business_Unit__c FROM Case WHERE Id = :caseId].Business_Unit__c;
        }
        catch (Exception e) {
            PromoCodeException promoCodeException = new PromoCodeException();
            promoCodeException.setMessage(Label.Business_Unit_Error);
            throw promoCodeException;
        }
        return [SELECT Id FROM Promo_Code__c WHERE Case__c = :caseId].size();
    }
    
    public class PromoCodeException extends Exception {
        
    }
    
    /**
* @description method to retrieve available promo code records
* @param value query based on promo code amount
* @return list of available promo code records
*/
    @AuraEnabled
    public static TLAuraResponse applyPromoCode(String value, String reason, String caseId) {
        TLAuraResponse response = new TLAuraResponse(true);
        
        try {
            Case parentCase = [SELECT Id, Business_Unit__c FROM Case WHERE Id = :caseId];
            List<Promo_Code__c> promoCodes = getPromoCodes(value, parentCase.Business_Unit__c);
            
            if (promoCodes.size() == 1) {
                Boolean success = consumePromoCodes(promoCodes[0], reason, caseId);
                if (success) {
                    response.returnValuesMap.put('promoCode', promoCodes[0].Promo_Code__c);
                    
                    getUnusedPromoCodes(value,parentCase.Business_Unit__c);
                }
                else {
                    response = new TLAuraResponse(false, 'Looks like something went wrong, try again and if you still get this error speak to your admin');
                }
            }
            else {
                response = new TLAuraResponse(false, 'No Matching Promo Code Found');
            }
        }
        catch (DmlException e) {
            response = new TLAuraResponse(false, e.getDmlMessage(0));
        }
        catch (Exception e) {
            response = new TLAuraResponse(false, e.getMessage() + '\n' + e.getStackTraceString());
        }
        
        return response;
    }
    
    
    /**
* @description method to associate promo code records with a case record and stamp the user who performed the action
* @param promoCodeRecords map of promo code record ids
* @param caseId string of the case record id
* @return boolean of if there was an error
*/
    @AuraEnabled
    public static Boolean consumePromoCodes(Promo_Code__c promoCodeToUpdate, String reason, String caseId) {
        Boolean success = true;
        
        promoCodeToUpdate.Case__c = caseId;
        promoCodeToUpdate.Consumed_By__c = UserInfo.getUserId();
        promoCodeToUpdate.Consumed__c = true;
        promoCodeToUpdate.Consumed_Date__c = Datetime.now();
        promoCodeToUpdate.Promo_Code_Reason__c = reason;
        
        Database.SaveResult saveResult = Database.update(promoCodeToUpdate);
        if (!saveResult.isSuccess()) {
            success = false;
        } else {
            success = updateCaseWithPromoCode(caseId, promoCodeToUpdate.Id);
        }
        
        return success;
    }
    
    @AuraEnabled
    public static TLAuraResponse getPromoPicklistOptions() {
        TLAuraResponse response = new TLAuraResponse(true);
        
        List<PicklistOptionWrapper> picklistOptions = new List<PicklistOptionWrapper>();
        
        List<String> promoCodePicklistValues = TLPicklist.getPicklistValues('Promo_Code__c', 'Amount_List__c');
        
        for (String picklistValue : promoCodePicklistValues) {
            picklistOptions.add(new PicklistOptionWrapper(picklistValue, picklistValue));
        }
        
        response.returnValuesMap.put('picklistOptions', picklistOptions);
        
        return response;
    }
    
    private static List<Promo_Code__c> getPromoCodes(String value, String businessUnit) {
        if (businessUnit == trac_CaseConstants.BUSINESS_UNIT_MHF) {
            businessUnit = trac_CaseConstants.BUSINESS_UNIT_HB;
        }
        List<Promo_Code__c> promoCodes = [
            SELECT Id, Amount_List__c, Name, Promo_Code__c
            FROM Promo_Code__c
            WHERE Consumed__c = FALSE AND Amount_List__c = :value AND Business_Unit__c = :businessUnit
            LIMIT 1 FOR UPDATE
        ];
        
        return promoCodes;
    }
    
    
    /**
* @description method to update the case with the promo code when its applied - this is for single promo code only
*              if multiple were allowed, then this would be a related list rather than a field on case
* @param caseId id of the case record
* @param promoCodeId id of the promo code record
* @return boolean of were there errors
*/
    private static Boolean updateCaseWithPromoCode(String caseId, String promoCodeId) {
        Boolean success = true;
        
        Promo_Code__c promoCode = [SELECT Id, Promo_Code__c FROM Promo_Code__c WHERE Id = :promoCodeId];
        try {
            update new Case(Id = caseId, Promo_Code_Lookup__c = promoCode.Id, Promo_Code__c = promoCode.Promo_Code__c);
            success = true;
        } catch (Exception e) {
            success = false;
        }
        
        return success;
    }
    
    public class PicklistOptionWrapper {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        
        public PicklistOptionWrapper(String labelString, String valueString) {
            label = labelString;
            value = valueString;
        }
    }
    /**
* @description method to fetch unused promo codes and trigger an email if number of promocodes is less than 750
*/
    @future
    public static void getUnusedPromoCodes(String value, String businessUnit) {
        if (businessUnit == trac_CaseConstants.BUSINESS_UNIT_MHF) {
            businessUnit = trac_CaseConstants.BUSINESS_UNIT_HB;
        }
        String query = 'SELECT Id, Amount_List__c, Name, Promo_Code__c FROM Promo_Code__c WHERE Case__c = null AND Consumed__c = FALSE AND Amount_List__c=:value AND Business_Unit__c=:businessUnit ';
        List<Promo_Code__c> promoCodeList = new List<Promo_Code__c>();
        promoCodeList = Database.query(query);

        List<Promo_Code_Availability__mdt> promoCodeAvailabilityList = new List<Promo_Code_Availability__mdt>();
        String fetchPromoCodeMetaDataQuery = 'SELECT Id, Threshold__c,Business_Unit__c FROM Promo_Code_Availability__mdt WHERE label=:value AND Business_Unit__c=:businessUnit ';
        promoCodeAvailabilityList = Database.query(fetchPromoCodeMetaDataQuery);
     
        if (promoCodeAvailabilityList.size()>0 && promoCodeList.size()== promoCodeAvailabilityList[0].Threshold__c -1) {
            triggerEmail(value,(Integer)promoCodeAvailabilityList[0].Threshold__c,businessUnit);
        }
        //Available PromoCode is less then 750 and trigger email only once when reduced from 750 to 749
        else if (promoCodeAvailabilityList.size()==0 && promoCodeList.size() == 749) {
            triggerEmail(value,750,businessUnit);
        }

    }
    /**
* @description method to trigger an email with a custom email template
*/
    public static void triggerEmail(String amountList,Integer threshold, String businessUnit) {
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setSenderDisplayName('UAD Promo Code Notification');
        message.setReplyTo('no-reply@hbc.com');
        message.setUseSignature(false);
        message.setBccSender(false);
        message.setSaveAsActivity(false);
        message.setSubject('Low Promo Codes Available');
        message.setHtmlBody('Hi,<br><p>The number of unused promo codes - '+ amountList+' for Business unit - '+businessUnit+' is less than '+ threshold+'.'+'</p><br> <br>Thank You');

        message.setTargetObjectId(UserInfo.getUserId());
        
        //fetching all users under Customer Care Leadership role
        List<String> userEmailList = new List<String>();
        for (User usr : [SELECT Id,Name,Email FROM User WHERE UserRole.DeveloperName = 'Customer_Care_Leadership']) {
            userEmailList.add(usr.Email);
        }
        message.toAddresses = userEmailList;
        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>{
            message
                };
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
    }
}