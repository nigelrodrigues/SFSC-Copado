/**
 * @author Nigel Rodrigues, Traction on Demand
 * @date 11-June-2020
 * @description Sub-operations before escalating a case and transferring it to the Loyalty Team.
 */

public with sharing class trac_CaseLoyaltyEscalation {

    @AuraEnabled
    public static TLAuraResponse createCaseAndAttachFile(Case caseRecord, String fileName, String fileContentsToEncode, String contentType, Boolean cloneCase)
    {
        TLAuraResponse response = new TLAuraResponse(true);

        try {
            if( cloneCase )
            {
                Case newCase = caseRecord.clone(false, true, false, false);
                newCase.Status = 'Open';
                newCase.Business_Unit__c = 'Hudson\'s Bay';
                newCase.Case_Type__c = 'Rewards';
                newCase.Category__c = 'Goodwill Points';
                newCase.Subcategory__c = 'Requires Approval';
                newCase.ParentId = caseRecord.Id;
                newCase.Subject = 'Escalation - ' + caseRecord.Subject;
                insert newCase;

                if( fileName!=null )
                {
                    response = attachToCase(newCase, fileName, fileContentsToEncode, contentType);
                }
                response.returnValuesMap.put('caseRecord', newCase);
            }
            else
            {
                response = attachToCase( caseRecord, fileName, fileContentsToEncode, contentType);
            }

        }
        catch(Exception e)
        {
            response = new TLAuraResponse(false, 'Error in creating new case. Please try again.');
        }

        return response;
    }

    private static TLAuraResponse attachToCase(Case parentCase, String fileName, String fileContentsToEncode, String contentType) {

        TLAuraResponse response = new TLAuraResponse(true);

        try {
            fileContentsToEncode = EncodingUtil.urlDecode(fileContentsToEncode, 'UTF-8');

            Attachment newAttachment = new Attachment();
            newAttachment.ParentId = parentCase.Id;
            newAttachment.Name = fileName;
            newAttachment.ContentType = contentType;
            newAttachment.Body = EncodingUtil.base64Decode(fileContentsToEncode);
            insert newAttachment;
        }
        catch(Exception e)
        {
            response = new TLAuraResponse(false, e.getMessage() + e.getStackTraceString());
        }

        return response;
    }


}