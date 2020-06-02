/**
 * Created by akong on 5/21/2020.
 */

({
    showToast: function(message, type, title) {
        var resultsToast = $A.get("e.force:showToast");
        resultsToast.setParams({
            "title": title,
            "message": message,
            "type" : type
        });
        resultsToast.fire();
    },
    calculateAmounts: function(cmp) {
        var appeasePoints = cmp.get('v.appeasePoints');
        if (!$A.util.isEmpty(appeasePoints)) {
            appeasePoints = parseInt(appeasePoints);

            var appeaseValue = (appeasePoints / 200).toFixed(2);
            cmp.set('v.appeaseValue', appeaseValue);

            var finalBalance = parseInt(cmp.get('v.pointsAvailable')) + appeasePoints;
            cmp.set('v.finalPointBalance', finalBalance);
        }
    },
    fireCloseModalEvent: function() {
        var appEvent = $A.get("e.c:trac_CloseModalApplicationEvent");
        appEvent.setParams({"closeModal" : true});
        appEvent.fire();
    }
});