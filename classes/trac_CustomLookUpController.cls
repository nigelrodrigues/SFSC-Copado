/**
* @description Controller for trac_CustomLookupComponent
* @author      Abhishek Solanki, Traction on Demand
* @date        2019-02-06
*/
public class trac_CustomLookUpController {

    @AuraEnabled
    public static List<sObject> fetchLookUpValues(String searchKeyWord, String ObjectName) {
        /*// Convert to schema.sObjectType
        Schema.SObjectType convertObjectType = Schema.getGlobalDescribe().get(ObjectName);
        // Create an instance of that type
        Sobject genericObject = convertObjectType.newSObject();
        Boolean hasName = genericObject.getSobjectType().getDescribe().fields.getMap().keySet().contains('name');*/

        if (ObjectName == 'Queue') {
            ObjectName = 'Group';
            String searchKey = '%' + searchKeyWord + '%';
            List <sObject> returnList = new List <sObject>();
            String sQuery = 'SELECT Id, Name FROM ' + ObjectName + ' WHERE Type =\'Queue\' AND Name LIKE: searchKey ORDER BY CreatedDate DESC LIMIT 7';
            List <sObject> lstOfRecords = Database.query(sQuery);

            for (sObject obj : lstOfRecords) {
                returnList.add(obj);
            }
            return returnList;
        } else if (ObjectName == 'User') {
            String searchKey = '%' + searchKeyWord + '%';
            List <sObject> returnList = new List <sObject>();
            String sQuery = 'SELECT Id, Name FROM ' + ObjectName + ' WHERE Name LIKE: searchKey ORDER BY CreatedDate DESC LIMIT 7';
            List <sObject> lstOfRecords = Database.query(sQuery);

            for (sObject obj : lstOfRecords) {
                returnList.add(obj);
            }
            return returnList;
        } else {
            return null;
        }
    }
}