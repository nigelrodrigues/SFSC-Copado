({
    isEditableToggle : function(component, event, helper) {
        var loyalty = component.get('v.loyalty')
        var appEvent = $A.get("e.c:trac_EditLoyaltyApplicationEvent");
        appEvent.setParams({
            'firstName' : loyalty.first_name,
            'lastName' : loyalty.last_name,
            'email' : loyalty.email
        });
        appEvent.fire();

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
        var LoyaltyNumberFromRecord = component.get('v.loyalty.external_customer_id');
        //var LoyaltyNumberFromRecord = component.get('v.caseRecord.Customer_Loyalty_Id__c'); //alternative loyalty number
        if (LoyaltyNumberFromParam === LoyaltyNumberFromRecord) {
            component.set('v.refreshSearch', true);
        }
    },

})