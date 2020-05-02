/**
* @description Controller for trac_TransferCases VF
* @author      Abhishek Solanki, Traction on Demand
* @date        2019-02-06
*/
public class trac_TransferCasesController {
    private ApexPages.StandardSetController standardController;
    public List<Case> selectedCases;
    public String casesSerialized { get; set; }


    public trac_TransferCasesController(ApexPages.StandardSetController standardController) {
        selectedCases = new List<Case>();
        List<Case> tempCaseList = new List<Case>();

        this.standardController = standardController;
        selectedCases = standardController.getSelected();

        for (Case caseObj : [SELECT Id,Status,CaseNumber,Subject FROM Case WHERE Id IN:selectedCases]) {
            tempCaseList.add(caseObj);
        }
        casesSerialized = JSON.serialize(tempCaseList);
    }

    @AuraEnabled
    public static void changeOwner(String newOwnerId, List<String> caseList) {
        List<Case> casesToUpdate = new List<Case>();

        for (String caseId : caseList) {
            Case caseObj = new Case();
            caseObj.Id = caseId;
            caseObj.OwnerId = newOwnerId;

            if (newOwnerId.startsWith('005')) {
                caseObj.Case_Steward__c = newOwnerId;
            }
            casesToUpdate.add(caseObj);
        }

        if (casesToUpdate.size() > 0) {
            update casesToUpdate;
        }
    }

}