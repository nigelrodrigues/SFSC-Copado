/**
 * @author Nigel Rodrigues, Traction on Demand
 * @description Updates the contact with Loyalty information
 */

public with sharing class trac_UpdateLoyaltyInfoOnContact {

    public void updateContacts(List<Id> contactsToUpdate)
    {

        List<Contact> contactList = [SELECT Id,Available_Points__c,
                                        Loyalty_Tier__c,Gift_card_amount__c,Next_gift_card_amount__c,
                                        Points_to_next_reward__c, SFCC_Customer_Number__c,Loyalty_Number__c
                                    FROM Contact
                                    WHERE Id IN :contactsToUpdate];

        trac_WS_GetSaksLoyalty request = new trac_WS_GetSaksLoyalty();
        List<Contact> contactsToBeUpdated = new List<Contact>();

        try{

            for(Contact contact : contactList)
            {
                request.loyaltyId = contact.Loyalty_Number__c;
                if(request.send() && request.getSaksLoyaltyResponse != null)
                {
                    contact.Available_Points__c      = request.getSaksLoyaltyResponse.response.results.member_info.available_points;
                    contact.Loyalty_Tier__c          = request.getSaksLoyaltyResponse.response.results.member_info.tier_status;
                    contact.Gift_card_amount__c      = request.getSaksLoyaltyResponse.response.results.member_info.gift_card_amount;
                    contact.Next_gift_card_amount__c = request.getSaksLoyaltyResponse.response.results.member_info.next_gift_card_amount;
                    contact.Points_to_next_reward__c = request.getSaksLoyaltyResponse.response.results.member_info.points_to_next_reward;
                    contactsToBeUpdated.add(contact);
                }
            }

            update contactsToBeUpdated;

        }
        catch(Exception e)
        {
            Integration_Error__c integrationError = trac_IntegrationError.addError(new Integration_Error__c(
                    Description__c = e.getMessage() + '\n' + e.getStackTraceString(),
                    Endpoint__c = request.dynamicEndpoint,
                    //Request__c = JSON.serializePretty(reqWrapper),
                    Service__c = 'Updating Loyalty SAKS on contact'
            ));
            insert integrationError;
        }

    }

}