/**
 * @author Nigel Rodrigues, Traction on Demand
 * @date 11-June-2020
 * @description Sub-operations before escalating a case and transferring it to the Loyalty Team.
 */

public with sharing class trac_CaseLoyaltyEscalation {

    @AuraEnabled
    public static TLAuraResponse attachToCase(Id parentId, String fileName, String fileContentsToEncode, String contentType) {

        TLAuraResponse response = new TLAuraResponse(true);

        try {
            fileContentsToEncode = EncodingUtil.urlDecode(fileContentsToEncode, 'UTF-8');

            Attachment newAttachment = new Attachment();
            newAttachment.ParentId = parentId;
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