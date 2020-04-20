/**
 * Created by jhoran on 7/17/2019.
 */
({



    doInit: function(component, event, helper) {
        helper.setDisabled(component);
        helper.getQuantityOptions(component);

        //Set Cancellation type picklist values
        var action = component.get('c.fetchCancellationReasons');

        action.setCallback(this,function(response){
            var response = response.getReturnValue();

            var optionsList = [];
            for (var key in response) {
                    optionsList.push({value: response[key], label: key});

            };
            component.set('v.cancellationReasonsPicklist', optionsList);

        });
        $A.enqueueAction(action);

    },

    handleOpenModal: function(component, event, helper) {
        component.set("v.isModalOpen", true);
    },

    handleCloseModal: function(component, event, helper) {
        helper.closeModal(component);
    },

    handleCancelOrder: function(component, event, helper) {
        component.set('v.isLoading', true);
        helper.cancelOrderApex(component, helper);
    }
})