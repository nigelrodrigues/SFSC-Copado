({
    afterRender: function (cmp, helper) {
        this.superAfterRender();
        helper.setFooterPerCommunity(cmp);
    }
})