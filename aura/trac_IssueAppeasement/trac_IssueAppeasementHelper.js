/**
 * Created by akong on 5/21/2020.
 */

({
    calculateDisplayAmounts: function(cmp) {
        var selectedAmount = cmp.get('v.selectedAmount');
        if (!$A.util.isEmpty(selectedAmount)) {
            var displayAmount = '$' + (selectedAmount / 200).toFixed(2) + ' CAD';
            cmp.set('v.displayAmount', displayAmount);

            var finalBalance = this.commaFormatInteger(cmp.get('v.currentBalance') + selectedAmount);
            cmp.set('v.finalDisplayBalance', finalBalance);
        }
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