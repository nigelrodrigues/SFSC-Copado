/**
* Test Class for trac_GetPromoCode
*  
* @author Piyush Bansal, Traction on Demand
* @date 2020-01-15
* @group GetPromoCode
*/

@IsTest
public class trac_GetPromoCodeTest {
    
    //Test case of method GetPromoCode() to fetch the promocodes list
    @IsTest
    static void testGetPromoCode() {
        final Integer COUNT = 6;
        TLTestFactory factory = new TLTestFactory();
        factory.createSObjects(new Promo_Code__c(Consumed__c = false, Amount_List__c='$5.00'), COUNT, true);
        
        Test.startTest();
        List<Promo_Code__c> promoCodeList = (List<Promo_Code__c>)trac_GetPromoCode.getPromoCode('$5.00');
        Test.stopTest();
        
        System.assertEquals(COUNT,promoCodeList.size());
    }
    //Test case of method ConsumePromoCodes()
    @IsTest
    static void testConsumePromoCodes(){
        final Integer COUNT = 6;
        TLTestFactory factory = new TLTestFactory();
        Case cs = (Case)factory.createSObject(new Case(), true);
        List<Promo_Code__c>promoCodeList=factory.createSObjects(new Promo_Code__c(Consumed__c = false, Amount_List__c='$5.00'), COUNT, true);
        
        
        Map<String,String> promoCodesMap = new Map<String,String>();
        for(Promo_Code__c promoCode:promoCodeList){
            promoCodesMap.put(promoCode.Id,promoCode.Promo_Code__c);
            
        }
        Test.startTest();
        Boolean result = trac_GetPromoCode.consumePromoCodes(promoCodesMap,cs.Id);
        Test.stopTest();  
        System.assertEquals(result, false);
        
    }
    //Test case of method ConsumePromoCodes() in case exception is thrown
    @IsTest
    static void testConsumePromoCodesThrowException(){
        Map<String,String> promoCodesMap = new Map<String,String>();
        Boolean result = false;
        TLTestFactory factory = new TLTestFactory();
        try{
            Case cs = (Case)factory.createSObject(new Case(), true);
            Test.startTest();
            result=trac_GetPromoCode.consumePromoCodes(null,cs.Id);
            Test.stopTest(); 
        }
        catch(Exception e){
            System.assertEquals(result, false,'Exception thrown in method of consumePromoCodes()');
        }
        
    }
}