({
    isEditableToggle : function(component, event, helper) {
        var isEditable = !component.get('v.isEditable')
        component.set('v.isEditable', isEditable)


    },
    goBack : function(component, event, helper) {
        component.set('v.refreshSearch', false);
        component.set('v.loyalty', null)
        component.set('v.isEditable', false)
    },
    handleValueChange : function (component, event, helper) {
        var isEditable = component.get('v.isEditable')
        var displayButtonText = (isEditable) ? "Cancel" : "Edit"
        component.set('v.editButtonText', displayButtonText)

    },
    handleLoyaltyRefreshEvent : function(component, event) {
        var LoyaltyNumberFromParam = event.getParam("LoyaltyNumber");
        var LoyaltyNumberFromRecord = component.get('v.caseRecord.Customer_Loyalty_Id__c');
        //var LoyaltyNumberFromRecord = component.get('v.loyalty.external_customer_id'); //alternative loyalty number
        if (LoyaltyNumberFromParam === LoyaltyNumberFromRecord) {
            $A.get('e.force:refreshView').fire();
        }
    },
})