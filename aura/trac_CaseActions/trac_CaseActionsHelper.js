/**
 * Created by jhoran on 7/4/2019.
 */
({
    navigateToLink : function(urlLink){
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": urlLink
        });
        urlEvent.fire();
    },

    navigateToSubtab : function(component, urlLink) {
        console.log('test');
        console.log(urlLink);
        var workspaceAPI = component.find("workspace");

        workspaceAPI.getEnclosingTabId().then(function(tabId) {
            var focusedTabId = tabId;
            workspaceAPI.openSubtab({
                parentTabId: focusedTabId,
                url: urlLink,
                focus: true
            });
        });
    }
})