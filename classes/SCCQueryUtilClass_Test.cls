@IsTest
private class SCCQueryUtilClass_Test  {

    @IsTest
    static void testQueries() {

        Case newCase = new Case(Order_Number__c='12345', Business_Unit__c='SAKS');
        insert newCase;

        SCCQueryUtilClass.getInstance()
                .getQueryInstance()
                .setObjectName('Case').setAllFields();

        String query = SCCQueryUtilClass.getInstance()
                        .getQueryInstance()
                        .setObjectName('Case')
                        .setRelatedFields(new Set<String>{'Id', 'Order_Number__c', 'Business_Unit__c'})
                        .setClause('Business_Unit__c', '=', 'SAKS')
                        .setLimit('1')
                        .getQuery();




    }

}