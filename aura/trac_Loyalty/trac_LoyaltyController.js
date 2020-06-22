/**
 * Created by akong on 6/1/2020.
 */
({
    handleShowAppeasementModal: function(cmp, event, helper) {
        console.log("Inside handleShowAppeasementModal");
        var modalBody;
        $A.createComponent(
            "c:trac_IssueAppeasement",
            {
                loyalty: cmp.get('v.loyalty')
            },
            function(content, status) {
                if (status === "SUCCESS") {
                    modalBody = content;
                    var modalPromise = cmp.find('overlayLib').showCustomModal({
                        header: "Issue Appeasement",
                        body: modalBody,
                        showCloseButton: true,
                        closeCallback: function() {}
                    });
                    cmp.set('v.appeasementModalPromise', modalPromise);
                }
            });
    },
    handleCloseModalApplicationEvent: function(cmp) {
        cmp.get('v.appeasementModalPromise').then(
            function (modal) {
                modal.close();
            }
        );
    },
    handleShowRecordTransaction: function(cmp,event) {
        let openButton = event.getSource();
        let container = cmp.find("divRecordTransaction");
        $A.createComponent(
            "c:trac_RecordTransaction",
            {
                loyalty: cmp.get('v.loyalty'),
                caseRecordId: cmp.get('v.caseRecord.Id'),
                openButton: openButton
            },
            function(newComponent, status) {
                if (status === "SUCCESS") {
                    openButton.set('v.disabled',true);
                    let body = container.get("v.body");
                    body.push(newComponent);
                    container.set("v.body",body);
                }
            });
    },
    handleSaveChanges: function(component, event, helper) {
        var loyalty = component.get('v.loyalty')
        var firstName = component.get('v.firstName')
        var lastName = component.get('v.lastName')
        var email = component.get('v.email')
        helper.handleSaveChangesHelper(component, loyalty, firstName, lastName, email)
            .then(() => {
                helper.showToast("Saved successfully!", 'success', 'Changes Submitted')
                component.set('v.isEditable', false)
            })
            .catch(error => helper.handleError(component, error))
    },
    handleChange: function(component, event, helper) {
        var firstNameValid = component.find('firstNameInput').get("v.validity")
        var lastNameValid = component.find('lastNameInput').get("v.validity")
        var emailValid = component.find('emailInput').get("v.validity")
        if(firstNameValid.valid && lastNameValid.valid && emailValid.valid) {
            component.set('v.isDisabled', false)
        } else {
            component.set('v.isDisabled', true)
        }
    },
    handleEditLoyaltyApplicationEvent: function (component, event, helper) {
        var firstName = event.getParam("firstName");
        var lastName = event.getParam("lastName");
        var email = event.getParam("email");
        component.set('v.firstName', firstName)
        component.set('v.lastName', lastName)
        component.set('v.email', email)
    },
});