({
    setFooterPerCommunity: function (component) {
        var homeURL = "";
        var baseURL = window.location.origin;
        var urlString = window.location.href;
        var pathlength = urlString.split("?")[0].split("\/").length;
        var homePage = urlString.split('?')[0].split('\/')[pathlength - 1];

        var saksOff5 = $A.get("$Label.c.Saks_Off_5th_CommunityName");
        var serviceOff5 = $A.get("$Label.c.ServiceSaksOff5th_CommunityName");
        var supportSaks = $A.get("$Label.c.Support_Saks_CommunityName");

        if (homePage === "") {
            component.set("v.showContactUs", true);
        } else {
            component.set("v.showContactUs", false);
        }

        var communityName = urlString.substring(urlString.indexOf("https://"), urlString.indexOf("/s/"));

        if (communityName === saksOff5) {
            homeURL = saksOff5 + "/s";
            component.set("v.homeURL", homeURL);
            this.setBackground();
            component.set("v.showFooterBottom", true);
        } else if (communityName === serviceOff5) {
            homeURL = serviceOff5 + "/s";
            component.set("v.homeURL", homeURL);
            component.set("v.showInFrench", true);
            this.setBackground();
            component.set("v.showFooterBottom", true);
        } else if (communityName === supportSaks) {
            homeURL = supportSaks + "/s";
            component.set("v.homeURL", homeURL);
            this.setBackground();
            component.set("v.showFooterBottom", true);
        } else {
            component.set("v.showFooterBottom", false);
        }

        this.setLanguageFooter(component, communityName, saksOff5, serviceOff5);
        this.setFooterOnMobile(component);
    },

    setLanguageFooter: function (component, communityName, saksOff5, serviceOff5) {
        if (communityName === saksOff5 || communityName === serviceOff5) {
            component.set("v.showLanguageSelect", true);
            if (communityName === saksOff5) {
                var cmpTargetEng = component.find("english-footer");
                var cmpTargetFrench = component.find("french-footer");
                $A.util.addClass(cmpTargetEng, "text-bold");
                $A.util.removeClass(cmpTargetFrench, "text-bold");
                $A.util.removeClass(cmpTargetEng, "pointer");
                $A.util.addClass(cmpTargetFrench, "pointer");
            } else {
                var cmpTargetEng = component.find("english-footer");
                var cmpTargetFrench = component.find("french-footer");
                $A.util.addClass(cmpTargetFrench, "text-bold");
                $A.util.removeClass(cmpTargetEng, "text-bold");
                $A.util.removeClass(cmpTargetFrench, "pointer");
                $A.util.addClass(cmpTargetEng, "pointer");
            }
        } else {
            component.set("v.showLanguageSelect", false);
        }
    },

    setFooterOnMobile: function (component) {
        if (navigator.userAgent.match(/Android/i)
            || navigator.userAgent.match(/webOS/i)
            || navigator.userAgent.match(/iPhone/i)
            || navigator.userAgent.match(/iPad/i)
            || navigator.userAgent.match(/iPod/i)
            || navigator.userAgent.match(/BlackBerry/i)
            || navigator.userAgent.match(/Windows Phone/i)) {
            var cmpFooter = component.find("footId");

            cmpFooter.forEach(element => {
                $A.util.removeClass(element, "slds-p-left_xx-large");
                $A.util.removeClass(element, "slds-p-right_xx-large");
            });

        }
    },

    setBackground: function () {
        let footer = document.querySelectorAll('.hbc-help-footer');
        footer.forEach(element => {
            element.classList.replace('hbc-help-footer', 'hbc-help-footer-white');
        });
    },

    navigateToUrl: function (component, address) {
        window.open(address, '_top');
    }
})