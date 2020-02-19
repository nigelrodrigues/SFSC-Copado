/**
 * @name trac_PromoCodeSearchControllerTest
 * @author Daniel Labonte, Traction on Demand
 * @date 2019-07-04
 * @description unit tests for the promo code search apex controller
 */

@IsTest
private class trac_PromoCodeSearchControllerTest {
    static final Integer PROMO_CODES_CONSUME = 2;
    static String AMOUNT_LIST_PICKLIST_VALUE;

    @TestSetup
    static void setup() {
        List<String> pickListValuesList = new List<String>();
        for (Schema.PicklistEntry pickListVal : Promo_Code__c.Amount_List__c.getDescribe().getPicklistValues()){
            pickListValuesList.add(pickListVal.getLabel());
        }
        Double randomNumber = Math.random();
        Integer arraySize = pickListValuesList.size();
        Integer randomIndex = (randomNumber * (arraySize - 1)).intValue();
        for (String selectedValue : pickListValuesList) {
            if (randomIndex == 0) {
                AMOUNT_LIST_PICKLIST_VALUE = selectedValue;
                break;
            }
            randomIndex--;
        }
    }

    @IsTest
    static void testGetCurrentCasePromoCode() {
        final Integer COUNT = 6;
        TLTestFactory factory = new TLTestFactory();
        Case cs = (Case)factory.createSObject(new Case(),true);
        factory.createSObjects(new Promo_Code__c(Amount_List__c=AMOUNT_LIST_PICKLIST_VALUE,Case__c=cs.Id), COUNT, true);

        Test.startTest();
        Integer promoCodeCount = trac_PromoCodeSearchController.getCurrentCasePromoCode(cs.Id);
        Test.stopTest();

        System.assertEquals(COUNT,promoCodeCount,'The number of promo codes found was not the amount expected.');
    }

    @IsTest
    static void testGetPromoCodes() {
        TLTestFactory factory = new TLTestFactory();
        factory.createSObject(new Promo_Code__c(Amount_List__c=AMOUNT_LIST_PICKLIST_VALUE), true);

        Case cs = (Case)factory.createSObject(new Case(),true);

        Object testResult;
        Test.startTest();
        testResult = trac_PromoCodeSearchController.applyPromoCode(AMOUNT_LIST_PICKLIST_VALUE, cs.Id);
        Test.stopTest();

        System.assert(testResult != null, 'No promo codes were retrieved');
    }
}