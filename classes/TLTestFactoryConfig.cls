/**
 * Configuration class for TLTestFactory
 * Defines FieldDefaults providers for different types of SObject
 * @author Grant Adamson, Traction on Demand
 * @date 2018-03-12
 * @group TLTestFactory
 */
@IsTest
public class TLTestFactoryConfig implements TLTestFactory.Configuration {

    public Map<SObjectType, Type> getValuesProviders() {
        return new Map<SObjectType, Type>{
                Account.SObjectType => TLTestFactoryConfig.AccountDefaults.class,
                Contact.SObjectType=> TLTestFactoryConfig.ContactDefaults.class,
                Opportunity.SObjectType => TLTestFactoryConfig.OpportunityDefaults.class,
                Case.SObjectType => TLTestFactoryConfig.CaseDefaults.class
        };
    }

    /**
     * Standard ValuesProvider implementations for common objects
     * For real use, these should be top level classes for each SObject where test data is needed, and then added to
     * the map above
     */
    public class AccountDefaults implements TLTestFactory.ValuesProvider {
        public Map<Schema.SObjectField, Object> getFieldValues() {
            return new Map<Schema.SObjectField, Object> {
                    Account.Name => 'Test Account'
            };
        }

        public Schema.SObjectField getNameField() {
            return Account.Name;
        }
    }

    public class ContactDefaults implements TLTestFactory.ValuesProvider {
        public Map<Schema.SObjectField, Object> getFieldValues() {
            return new Map<Schema.SObjectField, Object> {
                    Contact.FirstName => 'First',
                    Contact.LastName => 'Last'
            };
        }

        public Schema.SObjectField getNameField() {
            return Contact.LastName;
        }
    }

    public class OpportunityDefaults implements TLTestFactory.ValuesProvider {
        public Map<Schema.SObjectField, Object> getFieldValues() {
            return new Map<Schema.SObjectField, Object> {
                    Opportunity.Name => 'Test Opportunity',
                    Opportunity.StageName => 'Closed Won',
                    Opportunity.CloseDate => System.today()
            };
        }

        public Schema.SObjectField getNameField() {
            return Opportunity.Name;
        }
    }

    public class CaseDefaults implements TLTestFactory.ValuesProvider {
        public Map<Schema.SObjectField, Object> getFieldValues() {
            return new Map<Schema.SObjectField, Object> {
                    Case.Subject => 'Test Case'
            };
        }

        public Schema.SObjectField getNameField() {
            return Case.Subject;
        }
    }
}