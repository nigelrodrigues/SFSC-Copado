/**
* @description: Controller Class for SPA Calculator
* @author     : Piyush Bansal, Traction on Demand.
* @date       : 2/11/2020
*/

public with sharing class trac_SPA_CalculatorController {
    
    @AuraEnabled
    public static List<trac_Adjustment> getOrderAdjustments(String orderNumber) {
        System.debug('orderNumber: ' + orderNumber);
        
        trac_WS_GetOrderAdjustments orderAdjustmentsObj = new trac_WS_GetOrderAdjustments();
        orderAdjustmentsObj.orderNumber = orderNumber;
        List<trac_Adjustment> lineAdjustments = new List<trac_Adjustment>();
        try {
            Boolean success = orderAdjustmentsObj.send();
            if(success) {
                lineAdjustments = orderAdjustmentsObj.getOrderAdjustmentsResponse;
            }
        }
        catch(Exception e) {
            
        }
        return lineAdjustments;
    }
    
    @AuraEnabled
    public static Boolean setOrderAdjustments(String adjustmentId,String requestJSON) {
        System.debug('adjustmentId: ' + adjustmentId);
        System.debug('requestJSON: ' + requestJSON);
        trac_Adjustment requestJSONRec = new trac_Adjustment();
        
        if(String.isNotBlank(requestJSON)) {
            requestJSONRec = (trac_Adjustment) JSON.deserialize(requestJSON, trac_Adjustment.class);
        }
        
        trac_WS_UpdateAdjustment updateAdjustment = new trac_WS_UpdateAdjustment();
        updateAdjustment.updateAdjustmentRequest = requestJSONRec;
        updateAdjustment.adjustmentId = adjustmentId;

        if (updateAdjustment.updateAdjustmentRequest.log == null) {
            updateAdjustment.updateAdjustmentRequest.log = new trac_Adjustment.logWrapper();
        }

        User user = getUser(UserInfo.getUserId());
        if (user != null) {
            updateAdjustment.updateAdjustmentRequest.log.modified_by = user.Name;
            updateAdjustment.updateAdjustmentRequest.log.submitted_by = user.Name;
            updateAdjustment.updateAdjustmentRequest.log.submitter_number = user.EmployeeNumber;
        }
        updateAdjustment.updateAdjustmentRequest.log.modified_on = TLDatetime.formatDatetimeUTC(Datetime.now());
        updateAdjustment.updateAdjustmentRequest.log.submitted_on = TLDatetime.formatDatetimeUTC(Datetime.now());
        return updateAdjustment.send();
    }
    @AuraEnabled(Cacheable=true)
    public static List<SPA_Type_Mapping__mdt> getSPATypes(){
        return [
                SELECT Percentage_Value__c, DeveloperName, Label
                FROM SPA_Type_Mapping__mdt
                WHERE Active__c = true
                ORDER BY Order__c ASC
        ];
    }

    private static User getUser(Id userId) {
        List<User> users = [
                SELECT Id, EmployeeNumber, Name
                FROM User
                WHERE Id = :userId
        ];
        return (!users.isEmpty()) ? users[0] : null;
    }
}