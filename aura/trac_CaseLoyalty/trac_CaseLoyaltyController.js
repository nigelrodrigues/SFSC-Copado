({
	isEditableChange : function(component, event, helper) {
		var isEditable = !component.get('v.isEditable')
        component.set('v.isEditable', isEditable)
        var displayButtonText = (isEditable) ? "Cancel" : "Edit"
        component.set('v.editButtonText', displayButtonText)
	}
})