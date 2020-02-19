/**
 *  @description Holds Queries for Profile
 *  @author 	 Jeremy Horan, Traction on Demand.
 *  @date        2016-08-03
 */
public with sharing class trac_ProfileSelector {
	/**
	 *  @description Gets a Profile with given Id
	 *  @author 	 Jeremy Horan, Traction on Demand.
	 *  @date        2016-08-03
	 */
	public static Profile findById(Id profileId) {
		List<Profile> profiles = [
            SELECT Id, Name 
            FROM Profile 
            WHERE Id =: profileId
        ];

		if (profiles.size() > 0) {
			return profiles[0];
		}
		return null;
	}
}