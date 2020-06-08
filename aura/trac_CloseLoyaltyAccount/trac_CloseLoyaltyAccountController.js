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
       console.log('in close account')

      if(component.get('v.isMerkleError') == true) {
          component.set("v.isMerkleError", false);
          component.set("v.isModalOpen", true);
      }

      var loyalty = component.get('v.loyalty')
      helper.updateLoyaltyPoints(component, event, helper, loyalty, -Math.abs(loyalty.balance), 'closed_account')
      .then(() => helper.pauseAccount(component, event, helper, loyalty))
      .catch(error => helper.handleError(component, error))

   }
})