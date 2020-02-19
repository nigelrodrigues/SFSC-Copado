({
    handleTopicChange: function(component, event) {
        const searchEvent = $A.get("e.selfService:caseCreateFieldChange");

        searchEvent.setParams({
            'modifiedField' : event.getParam('modifiedField'),
            'modifiedFieldValue': event.getParam('modifiedFieldValue')
        });

        searchEvent.fire();
    }
})