/**
* @Name trac_GetPromoCode
* @Author Daniel Labonte, Traction on Demand
* @Date June 28, 2019 
* 
* @Description ${DESCRIPTION}
*/

public with sharing class trac_GetPromoCode {
    /**
* @description method to retrieve available promo code records
* @param value query based on promo code amount
* @return list of available promo code records
*/
    @AuraEnabled
    public static Object getPromoCode(String value) {
        String searchValue = '%' + value + '%';
        String query = 'SELECT Id, Amount_List__c, Name, Promo_Code__c FROM Promo_Code__c WHERE Case__c = null AND Consumed__c = FALSE AND Amount_List__c LIKE \'' + searchValue + '\' FOR UPDATE';
        return Database.query(query);
    }

    /**
* @description method to associate promo code records with a case record and stamp the user who performed the action
* @param promoCodeRecords map of promo code record ids
* @param caseId string of the case record id
* @return boolean of if there was an error
*/
    @AuraEnabled
    public static Boolean consumePromoCodes(Map<String, String> promoCodeRecords, String caseId) {
        Boolean success = true;

        try {
            List<String> ids = new List<String>();
            List<Promo_Code__c> promoCodesToUpdate = new List<Promo_Code__c>();
            for (String promoCodeId : promoCodeRecords.keySet()) {
                promoCodesToUpdate.add(new Promo_Code__c(
                        Id = promoCodeId,
                        Case__c = caseId,
                        Consumed_By__c = UserInfo.getUserId(),
                        Consumed__c = true
                ));
            }

            if (promoCodeRecords.keySet().size() == [SELECT Id FROM Promo_Code__c WHERE Id IN :promoCodeRecords.keySet() AND Consumed__c = FALSE].size()) {

                success = false;
                List<Database.SaveResult> srs = Database.update(promoCodesToUpdate);
                for (Database.SaveResult sr : srs) {
                    if (!sr.isSuccess()) {
                        success = true;
                    }
                }
            }
        } catch (Exception e) {
            throw new PromoCodeException(e.getMessage());
        }
        return success;
    }
    private class PromoCodeException extends Exception {
    }
}