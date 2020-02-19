/**
 *  @description Controller for Urgent Message Lightning component
 *  @author 	 Jeremy Horan, Traction on Demand.
 *  @date        2016-08-04
 */
public with sharing class trac_UrgentMessageCtlr {

	/**
	 *  @description Gets a list of Urgent Messages based on User Profile
	 *  @author 	 Jeremy Horan, Traction on Demand.
	 *  @date        2016-08-04
	 */
	@AuraEnabled
	public static List<Urgent_Message__c> getUrgentMessages(String recordId) {
		List<Urgent_Message__c> urgentMessages = new List<Urgent_Message__c>();

		String banner;

		Id networkId = Network.getNetworkId();
		if (recordId == null && networkId != null) {
			banner = getBannerByCommunity(networkId);
		}
		else {
			banner = getBannerByCase(recordId);
		}

		if (banner != null) {
			urgentMessages = (networkId != null) ? trac_UrgentMessageSelector.findAllActiveByBannerCommunity(banner, Date.today()) : trac_UrgentMessageSelector.findAllActiveByBanner(banner, Date.today());
		}

	    return urgentMessages;
	}

	private static String getBannerByCommunity(Id networkId) {
		String banner;

		if (networkId != null) {
			List<Network> networks = [SELECT Id, Name FROM Network WHERE Id = :networkId];

			List<Community_Business_Unit_Setting__mdt> urgentMessageBusinessUnitSettings = [SELECT Community_Network_Name__c, Business_Unit__c FROM Community_Business_Unit_Setting__mdt WHERE Community_Network_Name__c = :networks[0].Name];
			for (Community_Business_Unit_Setting__mdt urgentMessageBusinessUnitSetting : urgentMessageBusinessUnitSettings) {
				banner = urgentMessageBusinessUnitSetting.Business_Unit__c;
			}
		}

		return banner;
	}

	private static String getBannerByCase(Id caseId) {
		String banner;

		Case bannerCase = getCaseById(caseId);

		if (bannerCase != null && bannerCase.Business_Unit__c != null) {
			banner = bannerCase.Business_Unit__c;
		}

		return banner;
	}

	private static Case getCaseById(Id caseId) {
		List<Case> cases = [
				SELECT Id, Business_Unit__c
				FROM Case
				WHERE Id = :caseId
		];
		return (!cases.isEmpty()) ? cases[0] : null;
	}


	/**
	 *  @description Gets an Urgent Message with given Id
	 *  @author 	 Jeremy Horan, Traction on Demand.
	 *  @date        2016-08-04
	 */
	@AuraEnabled
	public static Urgent_Message__c getUrgentMessage(Id urgentMessageId) {
	    return trac_UrgentMessageSelector.getUrgentMessageById(urgentMessageId);
	}
}