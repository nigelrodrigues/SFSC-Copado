/**
 * Created by nrodrigues on 6/4/2020.
 */

({
    onInit : function (component, event, helper) {
        helper.getTransactions(component, event, helper);
    },
    openModal : function (component, event, helper) {
        var index = event.getParam("count");
        var transactionData = component.get("v.transactions.data");
        transactionData[index].showDetails = true;
        component.set("v.transactions.data", transactionData);
        component.set('v.showModal', true);
        component.set('v.showDetails', true);
    },
    closeModal : function (component, event, helper) {
        var transactionData = component.get("v.transactions.data");
        for (let index = 0; index < transactionData.length; index++) {
            transactionData[index].showDetails = false;
        }
        component.set("v.transactions.data", transactionData);
        helper.setRecordsToDisplay(component);
        component.set('v.showModal', false);
    },
    toggleData : function (component, event, helper) {
        var index = event.getSource().get("v.value");
        var transactionData = component.get("v.transactions.data");
        transactionData[index].showDetails = !transactionData[index].showDetails;
        component.set("v.transactions.data", transactionData);
    },
    displayMoreRecords : function (component, event, helper) {
        var numberOfRecordsToDisplay = component.get("v.recordsToDisplay");
        numberOfRecordsToDisplay+=20;
        var totalRecords = component.get("v.totalRecords");
        if( numberOfRecordsToDisplay > totalRecords )
        {
            numberOfRecordsToDisplay = totalRecords;
        }
        component.set("v.recordsToDisplay", numberOfRecordsToDisplay);
    }
});