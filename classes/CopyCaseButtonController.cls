/**
 * @description Apex controller for CopyCaseButton lightning component
 * @author      Rajat Agrawal, Traction on Demand
 * @date        2019-06-06
 */
public with sharing class CopyCaseButtonController {

    /**
     * @description Clone the Case record
     * @param       cs, Case record to be cloned
     * @return      Id, Id of the newly created Case record
     */
    @AuraEnabled
    public static Id cloneCase(Case cs) {
        Case clonedCase = cs.clone(false, true, false, false);
        clonedCase.ParentId = cs.Id;
        clonedCase.Subject = 'Copy - ' + cs.Subject;
        insert clonedCase;
        return clonedCase.Id;
    }

}