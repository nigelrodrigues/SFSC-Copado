/**
* *@description* Test class for trac_QuickLinksController
* *@author*      Rajat Agrawal, Traction on Demand
* *@date*        2019-07-08
*/
@isTest
private class trac_QuickLinksControllerTest {
    @isTest
    static void testGetQuickLinks() {

        TLAuraResponse response = trac_QuickLinksController.getQuickLinks();
        Map<String,List<External_Link_Setting__mdt>> externalLinkSettingsByBusinessUnit = (Map<String,List<External_Link_Setting__mdt>>) response.returnValuesMap.get('externalLinks');
        System.assert(externalLinkSettingsByBusinessUnit.size() > 0, 'Links not found.');
    }
}