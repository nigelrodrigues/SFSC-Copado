/**
 * Created by nrodrigues on 6/4/2020.
 */
({
    getTransactions: function (component, event, helper) {
        var action = component.get("c.getTransactionHistory");
        var email = component.get("v.emailInput");
        var customerId = component.get("v.customerIdInput");
        console.log('customerId: ' +customerId);
        action.setParams({
            "email": email,
            "customerId": customerId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var result =  response.getReturnValue();
                if (result == null) {
                    component.set("v.errorMsg", "Connection Error");
                } else {
                    console.log('success? ' + result.isSuccess);
                    if(result.isSuccess) {
                        var transactionsReturned = result.returnValuesMap['transactions'];
                        if(transactionsReturned && transactionsReturned.success) {
                            component.set("v.transactions", transactionsReturned);
                            component.set("v.totalRecords", transactionsReturned.data.length);
                            helper.setRecordsToDisplay(component)
                            console.log('****************' +  JSON.stringify(component.get('v.transactions.data')));
                        }
                        else{
                            component.set("v.isError", true);
                            component.set("v.errorMsg", "There was an error in retrieving the transactions. Error Id: UI-01");
                        }
                    } else {
                        component.set("v.isError", true);
                        component.set("v.errorMsg", result.message);
                    }
                }
            }
            else {
                console.error("failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    },

    setRecordsToDisplay: function(component) {
        var totalRecords = component.get("v.totalRecords");
        let numberOfRecordsToDisplay =0;
        if( totalRecords >= 20 )
        {
            numberOfRecordsToDisplay = 20;
        }
        else
        {
            numberOfRecordsToDisplay = totalRecords;
        }
        component.set("v.recordsToDisplay", numberOfRecordsToDisplay);
    },

});