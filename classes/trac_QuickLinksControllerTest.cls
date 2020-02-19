/**
* *@description* Test class for trac_QuickLinksController
* *@author*      Rajat Agrawal, Traction on Demand
* *@date*        2019-07-08
*/
@isTest
private class trac_QuickLinksControllerTest {

    @isTest
    static void testGetQuickLinks() {
        List<External_Link_Setting__mdt> externalLinkSettings = new List<External_Link_Setting__mdt>();
        externalLinkSettings = trac_QuickLinksController.getQuickLinks();
        System.assert(externalLinkSettings.size() > 0, 'Links not found.');
    }
}