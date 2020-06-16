({
    isEditableToggle : function(component, event, helper) {
        var isEditable = !component.get('v.isEditable')
        component.set('v.isEditable', isEditable)


    },
    goBack : function(component, event, helper) {
        component.set('v.loyalty', null)

        component.set('v.isEditable', false)
    },
    handleValueChange : function (component, event, helper) {
        var isEditable = component.get('v.isEditable')
        var displayButtonText = (isEditable) ? "Cancel" : "Edit"
        component.set('v.editButtonText', displayButtonText)

    }
})