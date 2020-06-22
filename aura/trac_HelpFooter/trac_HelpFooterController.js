({

    navigateToFrench: function (component, event, helper) {
        var urlString = window.location.href;
        var communityName = urlString.substring(urlString.indexOf("com/"), urlString.indexOf("/s/"));
        if (communityName === ('com/' + $A.get("$Label.c.Saks_Off_5th_CommunityName"))) {
            var address = $A.get("$Label.c.Community_Url_ServiceSaksOff5th");
            helper.navigateToUrl(component, address);

        }

    },
    navigateToEnglish: function (component, event, helper) {
        var urlString = window.location.href;
        var communityName = urlString.substring(urlString.indexOf("com/"), urlString.indexOf("/s/"));
        if (communityName === ('com/' + $A.get("$Label.c.ServiceSaksOff5th_CommunityName"))) {
            var address = $A.get("$Label.c.Community_Url_SaksOff5th");
            helper.navigateToUrl(component, address);
        }

    }
})