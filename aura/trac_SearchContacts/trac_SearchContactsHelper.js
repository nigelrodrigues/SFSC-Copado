({
    searchContact : function(component, event, helper) {
        
        //Assign case supplied email and phone to contact search criteria
        var caseRecord = component.get("v.caseRecord");
        var contactRecord = component.get("v.contactRecord");
        if(caseRecord.SuppliedEmail == null && caseRecord.SuppliedPhone == null){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Required fields for search are empty',
                message: 'Atleast supplied email or supplied phone is required to perform search',
                duration:' 5000',
                type: 'error',
                mode: 'dismissible'
            });
            toastEvent.fire();
        }
        else{
            contactRecord.Email = caseRecord.SuppliedEmail;
            contactRecord.Phone = caseRecord.SuppliedPhone;
            contactRecord.Business_Unit__c = caseRecord.Business_Unit__c;
            component.set("v.contactRecord",contactRecord);
            component.set("v.showSearchFilters","true");
            
            //Call aura method in the trac_ContactSearch component
            var showSearch = component.find('searchModal');
            showSearch.callSearchMethod();
        }
            
        //Hide searchfilter model after calling method
        component.set("v.showSearchFilters","false");
    }
})