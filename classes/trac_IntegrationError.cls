/**
 *  @description Methods to assist with Integration_Error__c functionality
 *  @author 	 Bejal Lewis, Traction on Demand.
 *  @date        2017-08-07
 */
public without sharing class trac_IntegrationError {

    public static List<Integration_Error__c> integrationErrors = new List<Integration_Error__c>();

	/**
	 *  @description Creates an integration error and inserts into database
	 *  @author 	 Bejal Lewis, Traction on Demand.
	 *  @date        2017-08-07
	 */
	public static Integration_Error__c addError(Integration_Error__c integrationError) {
		String currentTime = String.valueOf(Datetime.now());

		integrationError.Title__c = integrationError.Service__c + ': ' + currentTime;

        integrationErrors.add(integrationError);

		return integrationError;
	}

    public static void insertIntegrationErrors() {
        if (!integrationErrors.isEmpty()) {
            insert integrationErrors;
            integrationErrors = new List<Integration_Error__c>();
        }
    }
}