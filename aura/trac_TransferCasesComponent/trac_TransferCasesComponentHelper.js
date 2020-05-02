({
    updateOwner: function (component, event, helper) {

        var action = component.get("c.changeOwner");
        let items = component.get("v.caseList");
        let caseIds = [];
        for (let i = 0; i < items.length; i++) {
            caseIds.push(items[i].Id);
        }
        action.setParams({newOwnerId: component.get("v.OwnerId"), caseList: caseIds});

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                window.history.back();
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);

    }
})