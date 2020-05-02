/**
 * @description ${DESCRIPTION}
 * @name trac_PreChatComponentController.js
 * @author Daniel Labonte, Traction on Demand
 * @date 2019-08-29
 */
({
    doInit: function (cmp, evt, hlp) {
        var action = cmp.get("c.getCommunityDependentValues");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set("v.communityValues", response.getReturnValue());
                cmp.set("v.showForm", "true");
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
    },

    handleFormSubmit: function (cmp, evt, hlp) {
        let fieldsEvent = evt.getParam('fields');
        let nameToFieldLabel = {
            "FirstName": "First Name",
            "LastName": "Last Name",
            "Email": "Email",
            "Subject": "Subject",
            "SuppliedName": "Web Name",
            "Business_Unit__c": "Business Unit",
            "Community_Case_Type__c": "Topic",
            "Order_Number__c": "Order Number",
            "Origin_Is_Chat__c": "Origin Is Chat",
            "Case_Language__c": "Case Language",
            "SuppliedEmail": "Web Email",
            "Language__c": "Language"
        };

        if (fieldsEvent['Case_Language__c'] === 'French') {
            nameToFieldLabel["FirstName"] = "Prénom";
            nameToFieldLabel["LastName"] = "Nom";
            nameToFieldLabel["Email"] = "Adresse e-mail";
            nameToFieldLabel["Community_Case_Type__c"] = "Sujet";
            nameToFieldLabel["Subject"] = "Objet";
            nameToFieldLabel["SuppliedName"] = "Nom Web";
            nameToFieldLabel["Order_Number__c"] = "Numéro de commande";
            nameToFieldLabel["SuppliedEmail"] = "E-mail Web";
        }

        let fields = [];
        for (let prop in fieldsEvent) {
            fields.push({label: nameToFieldLabel[prop], value: fieldsEvent[prop], name: prop});
        }
        fields.push({
            label: nameToFieldLabel["SuppliedName"],
            value: fieldsEvent["FirstName"] + " " + fieldsEvent["LastName"],
            name: "SuppliedName"
        });
        fields.push({label: nameToFieldLabel["SuppliedEmail"], value: fieldsEvent["Email"], name: "SuppliedEmail"});
        fields.push({
            label: nameToFieldLabel["Language__c"],
            value: fieldsEvent["Case_Language__c"],
            name: "Language__c"
        });
        fields.push({label: nameToFieldLabel["Origin_Is_Chat__c"], value: "True", name: "Origin_Is_Chat__c"});
        if (cmp.find("prechatAPI").validateFields(fields).valid) {
            cmp.find("prechatAPI").startChat(fields);
            window.dispatchEvent(new CustomEvent('serviceChatStart', {}));
        } else {
            console.warn("Prechat fields did not pass validation!");
        }
    }
});