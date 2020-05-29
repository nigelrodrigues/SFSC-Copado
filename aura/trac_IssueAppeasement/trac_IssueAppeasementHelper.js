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
    calculateDisplayAmounts: function(cmp) {
        var selectedAmount = cmp.get('v.selectedAmount');
        if (!$A.util.isEmpty(selectedAmount)) {
            selectedAmount = parseInt(selectedAmount);
            cmp.set('v.selectedLabel', this.commaFormatInteger(selectedAmount));

            var displayAmount = '$' + (selectedAmount / 200).toFixed(2) + ' CAD';
            cmp.set('v.displayAmount', displayAmount);

            var finalBalance = this.commaFormatInteger(parseInt(cmp.get('v.pointsAvailable')) + parseInt(selectedAmount));
            cmp.set('v.finalDisplayBalance', finalBalance);
        }
    },
    fireCloseModalEvent: function() {
        var appEvent = $A.get("e.c:trac_CloseModalApplicationEvent");
        appEvent.setParams({"closeModal" : true});
        appEvent.fire();
    },
    commaFormatInteger: function(intNum) {
        var str = intNum.toString();
        var retStr = '';
        for (var i = str.length - 1; i >= 0; i--) {
            retStr = str[i] + retStr;
            if ((str.length - i) % 3 === 0 && i > 0 && i < str.length - 1) {
                retStr = "," + retStr;
            }
        }
        return retStr;
    }
});