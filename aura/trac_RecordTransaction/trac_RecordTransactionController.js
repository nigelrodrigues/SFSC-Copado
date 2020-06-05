/**
 * Created by gtorres on 6/5/2020.
 */

({
    handleCancel: function(cmp,event) {
        let openButton = cmp.get('v.openButton');
        openButton.set('v.disabled', false);
        cmp.set('v.openButton', null);
        cmp.destroy();
    }
});