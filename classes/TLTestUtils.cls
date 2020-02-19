/**
 *  @description Utility methods for testing focused on Ease of Use
 *               See new TLTestFactory ()for more detailed object creation
 *  @author      Jeremy Horan, Traction on Demand.
 *  @date        11/6/2018
 */
@IsTest
public class TLTestUtils {

    /**
	 *  @description Test Lead creation utility function - Overloaded for ease of use
	 *  @author 	 Jeremy Horan, Traction on Demand.
	 *  @date        2017-02-21
	 */
    public static List<Lead> createLeads(Integer creationAmount) {
        return createLeads(creationAmount, false);
    }

    /**
     *  @description Test Lead creation utility function - Contains mandatory fields for insert
     *  @author 	 Jeremy Horan, Traction on Demand.
     *  @date        2017-02-21
     */
    public static List<Lead> createLeads(Integer creationAmount, Boolean doInsert) {
        return (List<Lead>) new TLTestFactory().createSObjects(new Lead(), creationAmount, doInsert);
    }

    /**
	 *  @description Test Account creation utility function - Overloaded for ease of use
	 *  @author 	 Jeremy Horan, Traction on Demand.
	 *  @date        2017-02-21
	 */
    public static List<Account> createAccounts(Integer creationAmount) {
        return createAccounts(creationAmount, false);
    }

    /**
     *  @description Test Account creation utility function - Contains mandatory fields for insert
     *  @author 	 Jeremy Horan, Traction on Demand.
     *  @date        2017-02-21
     */
    public static List<Account> createAccounts(Integer creationAmount, Boolean doInsert) {
        return (List<Account>) new TLTestFactory().createSObjects(new Account(), creationAmount, doInsert);
    }

    /**
	 *  @description Test Contact creation utility function - Overloaded for ease of use
	 *  @author 	 Jeremy Horan, Traction on Demand.
	 *  @date        2017-02-21
	 */
    public static List<Contact> createContacts(Integer creationAmount) {
        return createContacts(creationAmount, false);
    }

    /**
     *  @description Test Contact creation utility function - Contains mandatory fields for insert
     *  @author 	 Jeremy Horan, Traction on Demand.
     *  @date        2017-02-21
     */
    public static List<Contact> createContacts(Integer creationAmount, Boolean doInsert) {
        return (List<Contact>) new TLTestFactory().createSObjects(new Contact(), creationAmount, doInsert);
    }

    /**
	 *  @description Test Opportunity creation utility function - Overloaded for ease of use
	 *  @author 	 Jeremy Horan, Traction on Demand.
	 *  @date        2017-02-21
	 */
    public static List<Opportunity> createOpportunities(Integer creationAmount) {
        return createOpportunities(creationAmount, false);
    }

    /**
     *  @description Test Opportunity creation utility function - Contains mandatory fields for insert
     *  @author 	 Jeremy Horan, Traction on Demand.
     *  @date        2017-02-21
     */
    public static List<Opportunity> createOpportunities(Integer creationAmount, Boolean doInsert) {
        return (List<Opportunity>) new TLTestFactory().createSObjects(new Opportunity(), creationAmount, doInsert);
    }

    /**
	 *  @description Test Case creation utility function - Overloaded for ease of use
	 *  @author 	 Jeremy Horan, Traction on Demand.
	 *  @date        2017-02-21
	 */
    public static List<Case> createCases(Integer creationAmount) {
        return createCases(creationAmount, false);
    }

    /**
     *  @description Test Case creation utility function - Contains mandatory fields for insert
     *  @author 	 Jeremy Horan, Traction on Demand.
     *  @date        2017-02-21
     */
    public static List<Case> createCases(Integer creationAmount, Boolean doInsert) {
        return (List<Case>) new TLTestFactory().createSObjects(new Case(), creationAmount, doInsert);
    }

    /**
	 *  @description Test User creation utility function - Overloaded for ease of use
	 *  @author 	 Jeremy Horan, Traction on Demand.
	 *  @date        2017-02-21
	 */
    public static List<User> createUsers(Integer creationAmount) {
        return createUsers('System Administrator', creationAmount, false);
    }

    /**
     *  @description Test User creation utility function - Contains mandatory fields for insert
     *  @author 	 Jeremy Horan, Traction on Demand.
     *  @date        2017-02-21
     */
    public static List<User> createUsers(Integer creationAmount, Boolean doInsert) {
        return createUsers('System Administrator', creationAmount, doInsert);
    }

    /**
	 *  @description Test User creation utility function - Overloaded for ease of use
	 *  @author 	 Jeremy Horan, Traction on Demand.
	 *  @date        2017-02-21
	 */
    public static List<User> createUsers(String profileName, Integer creationAmount) {
        return createUsers(profileName, creationAmount, false);
    }

    /**
     *  @description Test User creation utility function - Contains mandatory fields for insert
     *  @author 	 Jeremy Horan, Traction on Demand.
     *  @date        2017-02-21
     */
    public static List<User> createUsers(String profileName, Integer creationAmount, Boolean doInsert) {

        if (profileName == null) {
            profileName = 'System Administrator';
        }
        Profile profile = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1];

        return (List<User>) new TLTestFactory().createSObjects(new User(ProfileId = profile.Id), creationAmount, doInsert);
    }

    /**
	 *  @description Test Product creation utility function - Overloaded for ease of use
	 *  @author 	 Jeremy Horan, Traction on Demand.
	 *  @date        2017-02-21
	 */
    public static List<Product2> createProducts(Integer creationAmount) {
        return createProducts(creationAmount, false);
    }

    /**
     *  @description Test Product creation utility function - Contains mandatory fields for insert
     *  @author 	 Jeremy Horan, Traction on Demand.
     *  @date        2017-02-21
     */
    public static List<Product2> createProducts(Integer creationAmount, Boolean doInsert) {
        return (List<Product2>) new TLTestFactory().createSObjects(new Product2(), creationAmount, doInsert);
    }

    /**
	 *  @description Test PriceBookEntry creation utility function - Overloaded for ease of use
	 *  @author 	 Jeremy Horan, Traction on Demand.
	 *  @date        2017-02-21
	 */
    public static List<PriceBookEntry> createPriceBookEntries(Id productId, Integer creationAmount) {
        return createPriceBookEntries(productId, creationAmount, false);
    }

    /**
     *  @description Test PriceBookEntry creation utility function - Contains mandatory fields for insert
     *  @author 	 Jeremy Horan, Traction on Demand.
     *  @date        2017-02-21
     */
    public static List<PriceBookEntry> createPriceBookEntries(Id productId, Integer creationAmount, Boolean doInsert) {
        return (List<PriceBookEntry>) new TLTestFactory().createSObjects(new PriceBookEntry(Product2Id = productId), creationAmount, doInsert);
    }

    /**
	 *  @description Test OpportunityLineItem creation utility function - Overloaded for ease of use
	 *  @author 	 Jeremy Horan, Traction on Demand.
	 *  @date        2017-02-21
	 */
    public static List<OpportunityLineItem> createOpportunityLineItems(Id opportunityId, Id pricebookEntryId, Integer creationAmount) {
        return createOpportunityLineItems(opportunityId, pricebookEntryId, creationAmount, false);
    }

    /**
     *  @description Test OpportunityLineItem creation utility function - Contains mandatory fields for insert
     *  @author 	 Jeremy Horan, Traction on Demand.
     *  @date        2017-02-21
     */
    public static List<OpportunityLineItem> createOpportunityLineItems(Id opportunityId, Id pricebookEntryId, Integer creationAmount, Boolean doInsert) {
        return (List<OpportunityLineItem>) new TLTestFactory().createSObjects(new OpportunityLineItem(
                OpportunityId = opportunityId,
                PricebookEntryId = pricebookEntryId
        ), creationAmount, doInsert);
    }

}