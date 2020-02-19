/**
 *  @description Holds Queries for Urgent Messages
 *  @author 	 Jeremy Horan, Traction on Demand.
 *  @date        2016-08-03
 */
public with sharing class trac_UrgentMessageSelector {

	/**
	 *  @description Gets a list of Urgent Messages based on banner
	 *  @author 	 Jeremy Horan, Traction on Demand.
	 *  @date        2016-08-03
	 */
	public static List<Urgent_Message__c> findAllActiveByBanner(String banner, Date activeDate) {
		List<Urgent_Message__c> urgentMessages = [
            SELECT Id, Name 
            FROM Urgent_Message__c 
            WHERE Banner__c INCLUDES (:banner) AND Activation_Date__c <= :activeDate AND (Expiration_Date__c >= :activeDate OR Expiration_Date__c = null)
        ];

		return urgentMessages;
	}

	/**
	 *  @description Gets a list of Urgent Messages based on banner
	 *  @author 	 Jeremy Horan, Traction on Demand.
	 *  @date        2016-08-03
	 */
	public static List<Urgent_Message__c> findAllActiveByBannerCommunity(String banner, Date activeDate) {
		List<Urgent_Message__c> urgentMessages = [
				SELECT Id, Name
				FROM Urgent_Message__c
				WHERE Banner__c INCLUDES (:banner) AND Activation_Date__c <= :activeDate AND (Expiration_Date__c >= :activeDate OR Expiration_Date__c = null) AND Include_In_Community__c = true
		];

		return urgentMessages;
	}

	/**
	 *  @description Returns Urgent Message with given ID
	 *  @author 	 Jeremy Horan, Traction on Demand.
	 *  @date        2016-08-04
	 */
	public static Urgent_Message__c getUrgentMessageById(Id urgentMessageId) {
		List<Urgent_Message__c> urgentMessages = [SELECT Id, Body__c FROM Urgent_Message__c WHERE Id = :urgentMessageId];
		if (urgentMessages.size() > 0) {
			return urgentMessages[0];
		}
		return null;
	}
}