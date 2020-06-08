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
});
