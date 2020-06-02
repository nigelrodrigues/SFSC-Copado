({

    init: function (component, event, helper) {
        var status = component.get('v.loyalty.status')
        if(status == 'paused')
            component.set('v.isClose', true);
    },

   openModel: function(component, event, helper) {
      // Set isModalOpen attribute to true
      component.set("v.isModalOpen", true);
   },
  
   closeModel: function(component, event, helper) {
      // Set isModalOpen attribute to false  
      component.set("v.isModalOpen", false);
   },
  
   closeAccount: function(component, event, helper) {
      // Set isModalOpen attribute to false
      //Add your code to call apex method or do some processing
      var loyalty = component.get('v.loyalty')
      helper.updateLoyaltyPoints(component, event, helper, loyalty, -Math.abs(loyalty.balance), 'closed_account')
      helper.pauseAccount(component, event, helper, loyalty)
   }
})