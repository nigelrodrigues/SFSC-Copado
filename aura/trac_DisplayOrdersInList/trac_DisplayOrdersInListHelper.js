({
    helperShowModal: function(component, evt, helper) {
        var modalBody;
        $A.createComponent("c:trac_OrderItemModal", {
            
        },function(content, status) {
            if (status === "SUCCESS") {
                modalBody = content;
                component.find('overlayLib').showCustomModal({
                    header: "Application Confirmation",
                    body: modalBody,
                    showCloseButton: true,
                    cssClass: "mymodal",
                    closeCallback: function() {
                        alert('You closed the alert!');
                    }
                })
            }
        });
    },

    /**
     * @description         Show toast with the given message, type, and title
     * @author              Rajat Agrawal, Traction on Demand
     * @param message       Message to display
     * @param type          Type of toast to display
     * @param title         Title of Toast message
     */
    showToast : function(message, type, title) {
        var resultsToast = $A.get("e.force:showToast");
        resultsToast.setParams({
            "mode": 'sticky',
            "title": title,
            "message": message,
            "type" : type
        });
        resultsToast.fire();
    },
})